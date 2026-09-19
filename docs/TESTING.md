# Hardware acceptance checklist

Use the packaged app, preferably from a stable location in Applications. Keep one running copy. These checks intentionally require real movement and observation rather than synthetic pointer events.

## Permissions and lifecycle

- A first launch shows settings without prompting for permissions. Previews and guides work immediately.
- On a fresh profile, Shake to locate and Help crossing displays are unchecked in the menu and off on Overview and feature pages.
- Enable each feature from each of those three locations while permission is missing. System Settings and the draggable helper must open. A pending menu item shows a dash, then a check after the required permissions are granted. Turning it off cancels setup.
- For crossing with neither permission, Input Monitoring opens first; after granting it while the app stays running, Accessibility opens next. Denying or closing a permission prompt must not cause repeated prompts. Toggle off and on to retry, including after a prior version was denied. If macOS requires a restart, finish any remaining permission from General.
- Upgrading an older installation without permissions clears its old automatic feature defaults once. Working, authorized features and unrelated preferences remain unchanged.
- On macOS Tahoe, verify every status-menu title has the same left edge, including Launch at login, Settings, and Quit. Quit must still work with the menu and Command-Q.
- Enable Input Monitoring and Accessibility from General. After granting access (and reopening if macOS requests it), automatic helpers work while another app is focused.
- Revoke access: General reflects the change, and crossing no longer occurs.
- Use the floating permission helper with System Settings frontmost: drag the app tile into Input Monitoring. Verify the exact installed `.app` is supplied and the original app remains in place. A drop must not be treated as authorization until macOS reports permission granted. Repeat for Accessibility.
- Cancel a drag, then try Show in Finder and Copy app path → + → Shift–Command–G as alternatives. The helper should stay visible above System Settings, remain movable, and close normally.
- Close the settings window: helpers remain active and are available from the menu bar.
- Pause/resume, sleep/wake, lock/unlock, switch Spaces, and enter a full-screen app. No frozen overlays or unexpected pointer motion should remain.
- Disconnect, rearrange, rotate, and reconnect a monitor with guides visible. Panels rebuild, old guides disappear, and the display count updates.
- Turn login launch on, verify in Login Items, then off. If approval is needed, the UI should reflect that rather than falsely showing enabled.

## Locate

- Shake horizontally, vertically, and diagonally on each screen. The circle starts at the farthest desktop corner and shrinks toward the pointer.
- Compare with the original app: a bright red–yellow–red radial band, 10% of the radius up to 60 points wide, shrinking linearly over 1.5 seconds. Verify the band stays opaque on light, dark, and visually busy backgrounds. Its inside and outside remain transparent.
- Move the pointer during the animation: the ring continues to follow it.
- Try ordinary long movements, tiny jitter, and dragging. They should not trigger locating.
- Compare low/high sensitivity, different mouse report rates, and a trackpad.
- Enable macOS Reduce Motion: locating should use a small fading ring.

## Blocked edges

Arrange a tall primary screen and shorter secondary screen sharing an edge, offset vertically.

- Push across the overlapping portion: macOS crosses naturally.
- Push outward at a non-overlapping portion: a brief sustained push crosses to the neighboring screen at a proportional height. The arrow becomes larger, follows the pointer, and settles back.
- Tap the edge once or stop pushing: there should be no warp.
- Push an outside edge with no adjacent display: nothing should happen.
- Drag a window, text selection, or file into an edge: no assisted jump.
- Repeat for left, right, top, and bottom arrangements, and for displays left of/above the primary (negative coordinates).
- Add a third monitor covering the otherwise blocked edge: ordinary travel to that screen should remain untouched.
- Check no immediate bounce back after a crossing; move away and deliberately return.
- Change pointer scale/duration and edge resistance; compare the visible behavior.

## Alignment

- Show guides; click and work through them. They must not block interaction.
- Physical alignment: use a ruler to check 45 mm line spacing on displays with different pixel densities, then physically adjust the screens so matching numbered lines meet.
- Desktop coordinates: check continuous shared y-coordinates in the macOS arrangement, including vertical offsets.
- Check the nine default lines have distinct colors and matching numbers on both monitors. Increase to eleven; matching numbers must retain the same colors on all displays. Number labels allow matching without relying on color alone.
- Change thickness from 2 to 10 points over a bright and a dark background. Verify the dark outline keeps light colors visible.
- Change count, spacing, offset, and labels while guides remain visible. Lines outside a display's physical bounds are clipped; reduce spacing when necessary. Hide with the shortcut and menu.
- Quit with guides visible: all lines vanish. Restart: guides stay off.
