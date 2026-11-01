import base64
from datetime import datetime, timedelta, timezone
import json
from pathlib import Path
import plistlib
import tempfile
import unittest
from unittest.mock import patch
import zipfile

import prepare_release as release


class SigningValidationTest(unittest.TestCase):
    def profile(self):
        return {
            "ExpirationDate": datetime.now(timezone.utc) + timedelta(days=30),
            "TeamIdentifier": ["TEAM123"],
            "ApplicationIdentifierPrefix": ["PREFIX123"],
            "DeveloperCertificates": [b"example certificate"],
            "Entitlements": {"application-identifier": "PREFIX123.example.app", "get-task-allow": False, "aps-environment": "production"},
        }

    def test_valid_distribution_profile_accepts_legacy_app_id_prefix(self):
        self.assertEqual(1, len(release.validate_profile(self.profile(), "example.app", "TEAM123")))

    def test_wrong_app_or_team_is_rejected(self):
        for app, team in (("other.app", "TEAM123"), ("example.app", "OTHER")):
            with self.assertRaises(ValueError):
                release.validate_profile(self.profile(), app, team)

    def test_expired_profile_is_rejected(self):
        profile = self.profile()
        profile["ExpirationDate"] = datetime.now(timezone.utc) - timedelta(seconds=1)
        with self.assertRaisesRegex(ValueError, "expired"):
            release.validate_profile(profile, "example.app", "TEAM123")

    def test_development_adhoc_and_enterprise_profiles_are_rejected(self):
        for key, value in (("ProvisionedDevices", ["device"]), ("ProvisionsAllDevices", True)):
            profile = self.profile()
            profile[key] = value
            with self.assertRaises(ValueError):
                release.validate_profile(profile, "example.app", "TEAM123")
        profile = self.profile()
        profile["Entitlements"]["get-task-allow"] = True
        with self.assertRaises(ValueError):
            release.validate_profile(profile, "example.app", "TEAM123")

    def test_profile_must_support_production_push(self):
        profile = self.profile()
        profile["Entitlements"]["aps-environment"] = "development"
        with self.assertRaisesRegex(ValueError, "push"):
            release.validate_profile(profile, "example.app", "TEAM123")

    def test_key_properties_escape_password_characters(self):
        self.assertEqual(r"\ p\=a\:ss\\word\n\u00e9", release.java_property(" p=a:ss\\word\né"))

    def test_invalid_base64_and_missing_secrets_fail(self):
        with patch.dict("os.environ", {"TEST_SECRET": "not base64!"}, clear=True):
            with self.assertRaises(ValueError):
                release.decode("TEST_SECRET")
            with self.assertRaises(ValueError):
                release.required("MISSING_SECRET")

    def test_setup_refuses_to_overwrite_local_credentials(self):
        with tempfile.TemporaryDirectory() as directory, patch.dict("os.environ", {}, clear=True):
            with self.assertRaisesRegex(ValueError, "ephemeral"):
                release.prepare("android", Path(directory))

    def test_android_firebase_package_mismatch_fails_before_signing(self):
        firebase = {"client": [{"client_info": {"android_client_info": {"package_name": "wrong.app"}}}]}
        environment = {"GITHUB_ACTIONS": "true", "APP_IDENTIFIER": "example.app", "GOOGLE_MAPS_API_KEY": "example-key",
                       "GOOGLE_SERVICES_JSON_BASE64": base64.b64encode(json.dumps(firebase).encode()).decode()}
        with tempfile.TemporaryDirectory() as directory, patch.dict("os.environ", environment, clear=True):
            with self.assertRaisesRegex(ValueError, "package name"):
                release.prepare("android", Path(directory))

    def test_ipa_verification_checks_actual_exported_version_and_bundle_id(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(release, "ROOT", Path(directory)), patch.dict("os.environ", {"APP_IDENTIFIER": "example.app"}):
            root = Path(directory)
            (root / "build/ci").mkdir(parents=True)
            (root / "build/ios/ipa").mkdir(parents=True)
            (root / "build/ci/ios-version.json").write_text(json.dumps({"version": "3.0.1", "build_number": 28}))
            ipa = root / "build/ios/ipa/app.ipa"
            info = {"CFBundleShortVersionString": "3.0.1", "CFBundleVersion": "28", "CFBundleIdentifier": "example.app"}
            with zipfile.ZipFile(ipa, "w") as archive:
                archive.writestr("Payload/Runner.app/Info.plist", plistlib.dumps(info))
            release.verify_ios()
            info["CFBundleVersion"] = "27"
            with zipfile.ZipFile(ipa, "w") as archive:
                archive.writestr("Payload/Runner.app/Info.plist", plistlib.dumps(info))
            with self.assertRaisesRegex(ValueError, "does not match"):
                release.verify_ios()

    def test_cleanup_removes_secret_files_even_when_keychain_restore_fails(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(release, "ROOT", Path(directory)), patch.dict("os.environ", {"GITHUB_ACTIONS": "true"}):
            root = Path(directory)
            temporary = root / "temporary-signing"
            release.write_private(temporary / "original-keychains.json", '["login.keychain-db"]')
            release.write_private(temporary / "AuthKey.p8", "private key")
            release.write_private(root / "android/key.properties", "password=secret")
            with patch.object(release, "run", side_effect=ValueError("security restore failed")):
                with self.assertRaisesRegex(ValueError, "cleanup"):
                    release.cleanup(temporary)
            self.assertFalse(temporary.exists())
            self.assertFalse((root / "android/key.properties").exists())


if __name__ == "__main__":
    unittest.main()
