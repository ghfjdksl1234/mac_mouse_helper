# GitHub builds and releases

Repository: [macgebi/mac_mouse_helper](https://github.com/macgebi/mac_mouse_helper).

## Download a build

1. Open **Actions → Build macOS app** and select a successful run for the desired commit.
2. Under **Artifacts**, download **Where-is-My-Mouse-macOS-universal**. You must be signed in with access to the repository.
3. Extract the downloaded artifact. It contains `Where-is-My-Mouse-macOS-universal.zip` and a `.sha256` checksum file.
4. Extract the app ZIP and move `Where is My Mouse.app` into Applications before enabling permissions or launch at login.

The ZIP inside the artifact preserves the app bundle's executable permissions and signature. Artifacts are kept for 14 days. Releases provide longer-lived downloads, subject to the repository's visibility. This repository is currently private; its builds are not public downloads.

The workflow uses a GitHub-hosted `macos-15` Apple Silicon runner. It runs the core checks, compiles `arm64` and `x86_64` slices, combines them, signs the bundle, and verifies both the bundle and an extracted copy of the ZIP. The package requires macOS 13 or later. Compilation of the Intel slice does not constitute a native Intel hardware test, and CI cannot validate physical mouse gestures or monitor alignment.

No Apple account, signing certificate, or custom GitHub secret is required for this initial setup. The built-in `GITHUB_TOKEN` is read-only during the build; only the version-tag draft-release job receives permission to write releases. Actions are pinned to commit hashes, with monthly Dependabot update checks.

## Trigger another build

Push a commit to a branch to build it automatically. Pull requests are checked too. Once the workflow is merged into `master`, **Actions → Build macOS app → Run workflow** can also start a manual build of a selected branch.

If Actions is disabled in this older repository, enable it in **Settings → Actions → General**. Repository or organization policies must allow the official `actions/checkout`, `actions/upload-artifact`, and `actions/download-artifact` actions.

GitHub-hosted macOS jobs in private repositories use the account's Actions allowance. If GitHub refuses to start a job, check the Actions usage/billing page and the job's annotation. The workflow limits each build to 20 minutes and retains its small artifacts for 14 days. [GitHub runner documentation](https://docs.github.com/en/actions/reference/runners/github-hosted-runners).

## Prepare a release

1. Merge the desired changes into `master` and wait for a successful build.
2. Set `CFBundleShortVersionString` and increment `CFBundleVersion` in `Resources/Info.plist`; commit and push those changes.
3. Tag that commit with `v` followed by the exact short version, then push the tag. For the current version, the tag would be `v1.0.3`:

```sh
git switch master
git pull --ff-only
git tag v1.0.3
git push origin v1.0.3
```

The workflow checks the tag against the app version, builds the app, and creates a **draft** release containing the ZIP and checksum. Review its notes and click **Publish release** when ready. A rerun can refresh a draft's assets, but refuses to replace assets of an already published release. Never reuse a published version tag for a different build.

Do not manually create a published release first: push the tag and let Actions prepare its draft. Creating a release without pushing a new tag does not trigger this workflow's release job.

## First-launch approval and future signing

These builds are **ad-hoc signed, not Apple-notarized**. A browser download may be blocked by Gatekeeper. If you trust the source and build, try opening the app, then use **System Settings → Privacy & Security → Open Anyway** and confirm. This is separate from granting Input Monitoring and Accessibility inside the app. See [Apple's guidance for opening apps](https://support.apple.com/en-us/102445).

For ordinary public distribution with a verified developer identity, the next step is Apple Developer ID signing and notarization. It requires an Apple Developer Program membership, a **Developer ID Application** certificate/private key, and notarization credentials. The certificate and credentials belong in GitHub encrypted secrets, never in source control or chat.

The build script already accepts `SIGNING_IDENTITY`, adds a secure timestamp for non-ad-hoc identities, and enables the hardened runtime. A later signing job would import the certificate into a temporary keychain, build with that identity, submit the ZIP with `xcrun notarytool submit --wait`, staple the accepted ticket to the app, and repackage it. That credentialed release path is not implemented or required by this initial workflow. [Apple notarization documentation](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution).
