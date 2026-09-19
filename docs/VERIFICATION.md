# Build verification

Verified on September 16, 2026, on Apple Silicon, macOS 26.6.2, Swift 6.3.3, using Command Line Tools.

## Completed

- Debug and optimized release builds of the native app succeeded.
- `./scripts/test.sh`: **13 tests, 206 assertions, zero failures**.
- App bundle `Info.plist` validates successfully.
- Ad-hoc code signature passes `codesign --verify --deep --strict`.
- Packaged executable launched and completed its app-level smoke test without a crash: five settings pages, locator animation, temporary pointer overlay, alignment-guide display, and shutdown cleanup.
- Smoke test detected two connected monitors. Screenshots of all five settings pages were generated and visually inspected. The overview screenshot is saved in `docs/overview.png`.
- `dist/Where is My Mouse.app` and `dist/Where is My Mouse.zip` are ready for local use.

The development sandbox cannot access WindowServer or Apple's icon conversion service. Icon packaging and the native app smoke test succeeded when those build/verification commands ran outside the sandbox. No system privacy setting was changed by the verification workflow.

## Remaining hardware verification

A normal Launch Services launch was requested successfully. Final interactive inspection was blocked by the Mac being locked. The smoke test was launched from the development process; its permission status does not establish that an independent Launch Services launch will have the same permissions. Check General and grant any missing permissions through macOS.

The test suite validates the detection and geometry logic. It does **not** prove that this Mac's mouse driver delivers the expected deltas while pinned at a real blocked edge, that a background pointer warp succeeds after a real shake/push, or that a monitor's reported dimensions match its physical dimensions. Run `docs/TESTING.md` with the unlocked multi-monitor setup to validate those behaviors. The smoke test exercises rendering and lifecycle, not true hardware gestures.

## Original locator appearance update

- Compared the original `GrandCircleView.m` and `ShakeDisplayManager.m` at revision `a563e689a06d3b6226e63cadc0813b321e9cbd73` with the new renderer.
- Restored the same AppKit red–yellow–red gradient, 10%-of-radius band capped at 60 points, and opaque linear 1.5-second contraction.
- Rendered the production drawing code on light, dark, and transparent backgrounds without capturing the desktop; visually inspected light and dark results.
- Rebuilt the release app and passed the five-page/overlay smoke check. Inspected the locator settings and workspace preview; corrected a SwiftUI Canvas rendering difference with explicit clipping to preserve the transparent center.
- Rebuilt and smoke-checked the corrected app successfully, verified its code signature, and refreshed the app archive and overview screenshot. The mouse-detection core is unchanged from the 13-test baseline above.

## Status-bar and login startup update (1.0.1)

- Built and installed the signed app at `~/Applications/Where is My Mouse.app`.
- Launched it through Launch Services with explicit login opt-in and a background launch. A report produced by the running installed app confirms: version `1.0.1`, login status `enabled`, status item visible, accessory activation policy (no Dock icon), and no settings window opened by the background launch.
- Opening the installed app again requests Settings; closing the settings window does not terminate the helper. Window restoration is disabled so macOS does not restore Settings at login.
- The installed app independently reports Input Monitoring and Accessibility as **not yet granted**. Automatic shake recognition and crossing assistance remain inactive until the user enables these in General. This supersedes the development-process permission values from earlier smoke tests.
- A real reboot was not performed. The login registration was verified through `SMAppService` from the installed application itself. Core detection is unchanged from the 13-test baseline.

## Colored alignment guides and permission helper (1.0.2)

- Release build and code-signature verification passed. Replaced the installed app and refreshed the ZIP; archive integrity verification passed.
- Native smoke test passed: all five settings pages, the floating permission helper, actual app file-URL pasteboard payload, guides on two displays, locator, pointer overlay, and cleanup.
- Visually inspected the alignment settings, General settings, permission helper, and full-size guide render. Guide colors and line numbers match across displays. Screenshots are saved in `docs/alignment-settings.png` and `docs/permission-helper.png`.
- The independently launched installed app reports version `1.0.2`, nine guides, four-point thickness, 30 mm spacing, and a valid drag file URL pointing to `~/Applications/Where is My Mouse.app`.
- Its runtime report confirms that launch at login remains enabled, the status item is visible, there is no Dock icon, and Settings is open. Input Monitoring and Accessibility still require the user's authorization; no privacy permissions were changed during verification.
- The drag payload was checked using a separate named pasteboard, without replacing the user's clipboard. Acceptance of the drop by System Settings, cancellation of a live drag, and enabling the permission switches remain manual checks in `docs/TESTING.md`.
- Core motion and geometry logic is unchanged from the 13-test, 206-assertion baseline.

## GitHub build setup (September 17, 2026)

- Reran the core suite: 13 tests, 206 assertions, zero failures.
- Validated the workflow with actionlint 1.7.12 and shell scripts with `bash -n`.
- Compiled both Apple Silicon and Intel release binaries using separate SwiftPM caches, combined them into a universal executable, and verified both architecture slices with `lipo`.
- Verified the app's Info.plist and ad-hoc signature, created the downloadable ZIP and SHA-256 checksum, extracted it, and checked the extracted app's executable permission, architecture slices, and signature.
- Developer ID signing, notarization, native Intel execution, physical gestures, and macOS permission prompts are outside these CI/package checks.

## Fresh defaults, permission setup, and menu alignment (1.0.3)

- Core suite: 16 tests, 231 assertions, zero failures. New cases cover permission requirements, ordered grants, denial without repeated prompts, explicit retries, cancellation, and shared setup.
- Isolated preferences checks: 10 assertions, zero failures. Fresh features stay off even when permission exists; migration clears unsupported legacy defaults once and preserves working features, unrelated settings, and later opt-ins.
- Universal build and ZIP extraction/signature/architecture verification passed.
- Native smoke test uses an isolated preference suite and verifies fresh features are unchecked and all menu indentation levels are zero. The status-menu Quit action now uses an app-owned selector so Tahoe does not add a lone standard-action icon column to the last section. The main application menu retains its standard Quit action.
- Enabling either feature from the status menu or either Settings location calls the same permission setup methods, including opening the System Settings pane directly after a prior denial. Old macOS registration is not needed to explain the original failure: the old toggle handlers never called those methods.
- Real OS permission grants, reopening after macOS requests a restart, and final visual menu alignment are manual acceptance checks in `docs/TESTING.md`. No privacy grants or installed-app preferences were changed by these checks.
