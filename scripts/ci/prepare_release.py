#!/usr/bin/env python3
"""Materialize ephemeral GitHub Actions signing inputs without logging secrets."""
import base64
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import plistlib
import secrets
import shlex
import shutil
import subprocess
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[2]


def required(name):
    value = os.environ.get(name, "")
    if not value.strip():
        raise ValueError(f"Missing GitHub Actions secret: {name}")
    return value


def decode(name):
    try:
        return base64.b64decode("".join(required(name).split()), validate=True)
    except (ValueError, base64.binascii.Error) as error:
        raise ValueError(f"{name} must be valid base64") from error


def write_private(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data if isinstance(data, bytes) else data.encode())
    path.chmod(0o600)


def java_property(value):
    result = ""
    for char in value:
        if char in "\\:=#! ":
            result += "\\" + char
        elif char in "\n\r\t":
            result += {"\n": "\\n", "\r": "\\r", "\t": "\\t"}[char]
        elif ord(char) > 127:
            encoded = char.encode("utf-16-be").hex()
            result += "".join("\\u" + encoded[i:i + 4] for i in range(0, len(encoded), 4))
        else:
            result += char
    return result


def run(*arguments):
    result = subprocess.run(arguments, capture_output=True, check=False)
    if result.returncode:
        # Security command arguments may contain passwords; never echo them.
        raise ValueError(f"{arguments[0]} {arguments[1]} failed; check certificate/password/toolchain configuration")
    return result.stdout


def validate_profile(profile, bundle_id, team_id, now=None):
    now = now or datetime.now(timezone.utc)
    expiration = profile["ExpirationDate"].replace(tzinfo=timezone.utc)
    if expiration <= now:
        raise ValueError("App Store provisioning profile has expired")
    entitlements = profile["Entitlements"]
    if profile.get("TeamIdentifier") != [team_id]:
        raise ValueError("Provisioning profile does not match APPLE_TEAM_ID")
    prefix = profile["ApplicationIdentifierPrefix"][0]
    if entitlements.get("application-identifier") != f"{prefix}.{bundle_id}":
        raise ValueError("Provisioning profile does not match this app's bundle ID")
    if entitlements.get("get-task-allow") or profile.get("ProvisionedDevices") or profile.get("ProvisionsAllDevices"):
        raise ValueError("An App Store distribution profile is required")
    if entitlements.get("aps-environment") != "production":
        raise ValueError("Provisioning profile must include production push notifications")
    return [hashlib.sha1(cert).hexdigest().upper() for cert in profile["DeveloperCertificates"]]


def prepare(platform, temporary):
    if os.environ.get("GITHUB_ACTIONS") != "true":
        raise ValueError("Signing setup is restricted to ephemeral GitHub Actions runners")
    os.umask(0o077)
    bundle_id = required("APP_IDENTIFIER")
    maps_key = required("GOOGLE_MAPS_API_KEY").strip()
    if not maps_key.isalnum() and not all(char.isalnum() or char in "_-" for char in maps_key):
        raise ValueError("GOOGLE_MAPS_API_KEY contains unexpected characters")
    temporary.mkdir(parents=True, exist_ok=True)
    write_private(temporary / "build-defines.json", json.dumps({"API_ENV": "production", "GOOGLE_MAPS_API_KEY": maps_key}))

    if platform == "android":
        firebase_bytes = decode("GOOGLE_SERVICES_JSON_BASE64")
        firebase = json.loads(firebase_bytes)
        packages = [client["client_info"]["android_client_info"]["package_name"] for client in firebase.get("client", [])]
        if bundle_id not in packages:
            raise ValueError("google-services.json does not contain this app's package name")
        credentials = required("PLAY_SERVICE_ACCOUNT_JSON")
        if json.loads(credentials).get("type") != "service_account":
            raise ValueError("PLAY_SERVICE_ACCOUNT_JSON must be a service account JSON key")
        alias, password, key_password = (required(name) for name in ("ANDROID_KEY_ALIAS", "ANDROID_KEYSTORE_PASSWORD", "ANDROID_KEY_PASSWORD"))
        write_private(temporary / "play-service-account.json", credentials)
        write_private(temporary / "upload-keystore.jks", decode("ANDROID_KEYSTORE_BASE64"))
        properties = {"storeFile": str(temporary / "upload-keystore.jks"), "storePassword": password, "keyAlias": alias, "keyPassword": key_password}
        write_private(ROOT / "android/key.properties", "".join(f"{key}={java_property(value)}\n" for key, value in properties.items()))
        write_private(ROOT / "android/app/google-services.json", firebase_bytes)
        return

    firebase_bytes = decode("GOOGLE_SERVICE_INFO_PLIST_BASE64")
    if plistlib.loads(firebase_bytes).get("BUNDLE_ID") != bundle_id:
        raise ValueError("GoogleService-Info.plist does not match this app's bundle ID")
    for name in ("APP_STORE_CONNECT_KEY_ID", "APP_STORE_CONNECT_ISSUER_ID", "APPLE_TEAM_ID"):
        required(name)
    write_private(temporary / "AuthKey.p8", decode("APP_STORE_CONNECT_PRIVATE_KEY_BASE64"))
    write_private(temporary / "distribution.p12", decode("IOS_DISTRIBUTION_P12_BASE64"))
    write_private(temporary / "profile.mobileprovision", decode("IOS_APP_STORE_PROFILE_BASE64"))
    profile = plistlib.loads(run("security", "cms", "-D", "-i", str(temporary / "profile.mobileprovision")))
    team_id = required("APPLE_TEAM_ID")
    certificate_hashes = validate_profile(profile, bundle_id, team_id)
    keychain = str(temporary / "release.keychain-db")
    keychain_password = secrets.token_urlsafe(32)
    original_keychains = shlex.split(run("security", "list-keychains", "-d", "user").decode())
    write_private(temporary / "original-keychains.json", json.dumps(original_keychains))
    run("security", "create-keychain", "-p", keychain_password, keychain)
    run("security", "set-keychain-settings", "-lut", "21600", keychain)
    run("security", "unlock-keychain", "-p", keychain_password, keychain)
    run("security", "import", str(temporary / "distribution.p12"), "-P", os.environ.get("IOS_DISTRIBUTION_P12_PASSWORD", ""), "-k", keychain, "-T", "/usr/bin/codesign", "-T", "/usr/bin/security")
    run("security", "set-key-partition-list", "-S", "apple-tool:,apple:,codesign:", "-k", keychain_password, keychain)
    run("security", "list-keychains", "-d", "user", "-s", keychain, *original_keychains)
    identities = run("security", "find-identity", "-v", "-p", "codesigning", keychain).decode()
    certificate_sha1 = next((fingerprint for fingerprint in certificate_hashes if fingerprint in identities), None)
    if not certificate_sha1:
        raise ValueError("The imported signing certificate/private key does not match the provisioning profile")
    # Xcode 16+ uses UserData; also install in the legacy location for tool compatibility.
    destinations = [Path.home() / "Library/Developer/Xcode/UserData/Provisioning Profiles", Path.home() / "Library/MobileDevice/Provisioning Profiles"]
    installed = [directory / f"{profile['UUID']}.mobileprovision" for directory in destinations]
    write_private(temporary / "installed-profiles.json", json.dumps([str(path) for path in installed]))
    for path in installed:
        write_private(path, (temporary / "profile.mobileprovision").read_bytes())
    write_private(temporary / "signing.json", json.dumps({"team_id": team_id, "profile_uuid": profile["UUID"], "profile_name": profile["Name"], "certificate_sha1": certificate_sha1}))
    export = {"method": "app-store-connect", "destination": "export", "signingStyle": "manual", "teamID": team_id,
              "signingCertificate": certificate_sha1, "provisioningProfiles": {bundle_id: profile["UUID"]},
              "manageAppVersionAndBuildNumber": False, "uploadSymbols": True}
    write_private(temporary / "ExportOptions.plist", plistlib.dumps(export))
    write_private(ROOT / "ios/Runner/GoogleService-Info.plist", firebase_bytes)
    write_private(ROOT / "ios/Flutter/Secrets.xcconfig", f"GOOGLE_MAPS_API_KEY={maps_key}\n")


def verify_ios():
    ipas = list((ROOT / "build/ios/ipa").glob("*.ipa"))
    if len(ipas) != 1:
        raise ValueError("Expected exactly one exported IPA")
    expected = json.loads((ROOT / "build/ci/ios-version.json").read_text())
    with zipfile.ZipFile(ipas[0]) as archive:
        paths = [name for name in archive.namelist() if name.startswith("Payload/") and name.count("/") == 2 and name.endswith(".app/Info.plist")]
        if len(paths) != 1:
            raise ValueError("Expected exactly one main app in the IPA")
        info = plistlib.loads(archive.read(paths[0]))
    if (info["CFBundleShortVersionString"], str(info["CFBundleVersion"]), info["CFBundleIdentifier"]) != (expected["version"], str(expected["build_number"]), required("APP_IDENTIFIER")):
        raise ValueError("Exported IPA version/build/bundle ID does not match the store-derived values")


def cleanup(temporary):
    if os.environ.get("GITHUB_ACTIONS") != "true":
        raise ValueError("Cleanup is restricted to ephemeral GitHub Actions runners")
    errors = []

    def attempt(action):
        try:
            action()
        except (ValueError, OSError) as error:
            errors.append(str(error))

    original = temporary / "original-keychains.json"
    if original.exists():
        attempt(lambda: run("security", "list-keychains", "-d", "user", "-s", *json.loads(original.read_text())))
    keychain = temporary / "release.keychain-db"
    if keychain.exists():
        attempt(lambda: run("security", "delete-keychain", str(keychain)))
    installed = temporary / "installed-profiles.json"
    if installed.exists():
        for path in json.loads(installed.read_text()):
            attempt(lambda path=path: Path(path).unlink(missing_ok=True))
    for path in ("android/key.properties", "android/app/google-services.json", "ios/Runner/GoogleService-Info.plist", "ios/Flutter/Secrets.xcconfig"):
        attempt(lambda path=path: (ROOT / path).unlink(missing_ok=True))
    if temporary.exists():
        attempt(lambda: shutil.rmtree(temporary))
    if errors:
        raise ValueError("Signing cleanup encountered errors: " + "; ".join(errors))


if __name__ == "__main__":
    try:
        operation = sys.argv[1]
        temporary = Path(required("RUNNER_TEMP")) / "yourcare-release"
        if operation == "cleanup":
            cleanup(temporary)
        elif operation == "verify-ios":
            verify_ios()
        elif operation in ("android", "ios"):
            prepare(operation, temporary)
        else:
            raise ValueError("Expected android, ios, verify-ios or cleanup")
    except (ValueError, KeyError, IndexError, OSError, plistlib.InvalidFileException):
        # Include only known validation errors, never raw JSON/plist or subprocess inputs.
        error = sys.exc_info()[1]
        print(f"Release configuration error: {error}", file=sys.stderr)
        sys.exit(1)
