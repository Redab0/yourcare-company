# Store builds: YourCare Partner

Repository: `Redab0/yourcare-company`. Android package and Apple bundle ID: `com.yourcarehere.partner`.

Shared scope/ownership: [canonical mobile delivery brief](../../../../you-care-backend/docs/features/mobile-store-cicd/brief.md). The matching Customer pipeline lives in `Redab0/yourcare-client`.

## Behavior

- **Checks** runs on pull requests and pushes to `develop`, `main` and `master`: version/signing regression tests, locked Flutter dependency installation, analysis and app tests. Existing analyzer warnings/information are reported; analyzer errors fail the job.
- **Upload store builds** runs manually from GitHub Actions or on a new `store-*` tag. It reruns Checks for the selected commit, builds signed AAB/IPA files, uploads Android to **internal testing** and iOS to **TestFlight**, and retains binaries, symbols and version evidence for 14 days. Each platform can succeed independently.
- Store builds use `API_ENV=production`. This is the normal store configuration and does not select the development backend.
- Workflow dispatch selects `both`, `android` or `ios`, and a `patch` (default), `minor` or `major` marketing-version bump. Tags use patch. A tag's text is a release marker; its version is never used as a replacement for the store query.
- The Android and Apple version sequences are independent. If Play has `3.0.0`/27, the next patch build is `3.0.1`/28. If Apple has `3.0.2`/8, its next patch build is `3.0.3`/9.
- The version is passed through Flutter's `--build-name`/`--build-number`; CI does not commit version bumps. The pubspec version remains the local-development baseline.

## One-time GitHub setup

Create an environment named **`store-release`** in [repository environments](https://github.com/Redab0/yourcare-company/settings/environments). Add the secrets below to that environment. Limit allowed release branches/tags to the source you intend to ship. GitHub-hosted macOS runners must be enabled with sufficient Actions minutes.

| Environment secret | Value |
| --- | --- |
| `PLAY_SERVICE_ACCOUNT_JSON` | Raw JSON for a Google Cloud service account invited to this app in Play Console; enable Android Publisher API and grant app access plus testing-release permissions. |
| `ANDROID_KEYSTORE_BASE64` | Base64 of the **existing Play upload keystore**. Use the key already registered for this app. |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password. |
| `ANDROID_KEY_ALIAS` | Alias of the registered upload key. |
| `ANDROID_KEY_PASSWORD` | Private key password. |
| `GOOGLE_SERVICES_JSON_BASE64` | Base64 of this app's `android/app/google-services.json`. |
| `GOOGLE_MAPS_ANDROID_API_KEY` | Android Maps/Places key restricted for this package and the Play app-signing certificate. Add the upload-certificate SHA-1 if testing the AAB outside Play. |
| `APP_STORE_CONNECT_KEY_ID` | Key ID of a **team** App Store Connect API key. |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID for that key. |
| `APP_STORE_CONNECT_PRIVATE_KEY_BASE64` | Base64 of its downloaded `AuthKey_*.p8` file. Use an App Manager key with access to this app. |
| `IOS_DISTRIBUTION_P12_BASE64` | Base64 of an exported Apple Distribution certificate **including its private key**. |
| `IOS_DISTRIBUTION_P12_PASSWORD` | Export password; can be empty for a passwordless P12. |
| `IOS_APP_STORE_PROFILE_BASE64` | Base64 of a current **App Store Connect distribution** `.mobileprovision`, matching this bundle ID and the supplied distribution certificate; Push Notifications must be enabled. |
| `GOOGLE_SERVICE_INFO_PLIST_BASE64` | Base64 of this app's `ios/Runner/GoogleService-Info.plist`. |
| `GOOGLE_MAPS_IOS_API_KEY` | iOS Maps/Places key restricted for this bundle ID. |

The Customer repository needs its own app-specific environment secrets. Apple API key/distribution certificate can be shared when the Apple team and app permissions allow it; provisioning profiles, Firebase configuration and Android upload-key registration must match each app. Developer API keys and signing private keys are never placed in build artifacts. Firebase/Maps client configuration is intentionally bundled and should use provider restrictions.

To copy an encoded file into a GitHub secret on macOS without printing it:

```sh
base64 -i /absolute/path/to/file | tr -d '\n' | pbcopy
```

Optional environment **variables**:

| Variable | Default | Purpose |
| --- | --- | --- |
| `APPLE_TEAM_ID` | `796XPXGJ9F` | Apple Developer team; profile validation checks this value. |
| `XCODE_VERSION` | `26.2` | Installed Xcode on `macos-15`; update alongside the pinned Flutter SDK when runner images retire it. |
| `PLAY_RELEASE_STATUS` | `completed` | Internal testing release status. Set `draft` if Play still considers the app a draft; finish the release in Play Console. |

Flutter is pinned to `3.35.4` in both workflows; Ruby/Fastlane/CocoaPods are pinned in `.ruby-version`, `Gemfile` and `Gemfile.lock`. The iOS signing setup imports the P12 into a temporary keychain, validates the profile, applies manual signing to the Runner Release configuration only, and verifies the exported IPA's version and bundle ID before upload. Signing material is cleaned up in an always-run step.

## Store prerequisites and version policy

1. Both store app records must already exist with the exact package/bundle ID. Upload an initial signed Android build manually and complete required Play Console setup before the API can publish further builds. Apple requires an existing app/version record, but can start with no uploaded build.
2. Play's tracks API exposes a **release name**, not the binary's `versionName`. Every active release with version codes must use its numeric app version as its name (`3.0.0`, `v3.0.0`, `27 (3.0.0)` or `3.0.0 (27)`). Rename arbitrary labels such as “October rollout” in Play Console to the binary's actual version before the first run. This pipeline sets future names to the built numeric version automatically. It reads all tracks, including custom tracks, and uses the highest numeric version and highest visible uploaded bundle/APK/track code.
3. Apple queries all pages of App Store versions, TestFlight builds and build uploads, including pending/failed uploads. It uses the highest numeric marketing version and an integer build number above all existing build-number leading components. For a legacy build `18.99.4`, the next integer is at least `19`.
4. An empty/unparseable store history, failed authentication, insufficient permissions or failed store request stops the release. There is no local/pubspec fallback. Version lookup errors are never treated as “first release.”
5. GitHub serializes release runs across refs for each repository. It keeps one active and one pending run per group; a newer pending run replaces the older pending run. Avoid concurrent manual uploads or other publishing tools for the same app, since they do not share this lock. A store duplicate-code rejection fails visibly; query fresh store state on a new run.

Google internal testers must be configured in Play Console. Apple builds wait for processing (up to 30 minutes); configure an internal TestFlight group to automatically receive new builds. This pipeline does not submit to public App Review or distribute to external testers. Export-compliance questions, agreements and other store-required actions still need to be completed in the consoles.

## First run and retries

1. Commit/push the workflow and supporting files. For the **Run workflow** button, the workflow must be present on GitHub's default branch (`develop` in the inspected checkout).
2. Open [Upload store builds](https://github.com/Redab0/yourcare-company/actions/workflows/store-release.yml), select the intended source branch, choose `both` and `patch`, then run it. Alternatively push a new unique `store-*` tag on the release commit.
3. Check the run summary and the artifact's `build/ci/<platform>-version.json`, then verify the build in Play Console internal testing and App Store Connect TestFlight. Artifact retention alone does not establish upload success.
4. If one platform fails, dispatch a **new** run for that platform. It re-queries the store and increments from the state it sees. Do not blindly reuse an old AAB/IPA or assume an upload failed just because processing timed out. Check store state first.

The pipeline is configured in source. Store authentication, signed compilation and delivery are only verified after a real GitHub run with these credentials.

At setup verification, Partner's existing Flutter suite had 13 failures in six Laundry suites. The upload workflow deliberately keeps the full test suite as a gate; resolve those failures before releasing. The canonical brief records the checks and affected suites.

## Local automation checks

Select Ruby 3.3.10 before running these commands:

```sh
bundle install
bundle exec ruby fastlane/test/store_version_test.rb
python3 -m unittest discover -s scripts/ci -p '*_test.py'
```

Signing preparation and cleanup intentionally require an ephemeral GitHub Actions runner; they must not overwrite your local signing files. Keep the existing local release process for manual builds.

References: [Google Play track/release API](https://developers.google.com/android-publisher/api-ref/rest/v3/edits.tracks), [Fastlane Play setup](https://docs.fastlane.tools/actions/upload_to_play_store/), [Fastlane TestFlight upload](https://docs.fastlane.tools/actions/upload_to_testflight/), [GitHub workflow concurrency](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/control-workflow-concurrency).
