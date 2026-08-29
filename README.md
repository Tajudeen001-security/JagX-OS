# JagX OS

**Custom Android launcher & system UI** built with Flutter.

JagX OS replaces the default home screen and delivers a complete OS-like experience:

- Custom home screen with dock & multi-page grid
- App drawer with search
- Status bar
- Quick settings panel
- Lock screen
- Settings app with theming
- Gesture navigation foundations
- Onboarding flow
- AMOLED-friendly dark theme
- Designed to run on any Android 7+ device (tested focus: Itel A100 and similar)

**License:** JRILICENSE  
**Package:** `com.jagx.os`

## Quick start (developer)

```bash
git clone https://github.com/Tajudeen001-security/JagX-OS.git
cd JagX-OS
flutter pub get
flutter run
```

To set as default launcher on a device:

1. Install the APK
2. Press the Home button
3. Choose **JagX OS** → Always

## Build signed / release APK

GitHub Actions automatically builds a release APK on every push to `main`.

Download the artifact from the Actions tab or from the generated GitHub Release.

Locally:

```bash
flutter build apk --release
```

## Architecture decisions

See the Grok skill `jagx-os` for the full rationale. Summary:

- Flutter for UI speed and theming quality
- Riverpod for scalable state
- Declared as HOME + DEFAULT launcher so it cleanly replaces the system home
- No root required
- Min SDK 24 for broad device coverage including budget Itel phones

## Roadmap (next 20 features)

1. Real installed-app listing & launching
2. Folders on home screen
3. Widget host
4. Live wallpaper support
5. Icon packs
6. Notification shade integration
7. Full gesture navigation
8. PIN / pattern lock
9. Biometric unlock
10. App categories in drawer
11. Hidden apps
12. Search everywhere
13. Battery & data usage widgets
14. Custom icon shapes
15. Backup / restore layout
16. Multi-user profiles (basic)
17. Accessibility improvements
18. Landscape mode polish
19. Tablet layout
20. Optional system overlay for persistent status

## Branding

Logo and visual identity are generated under the JagX brand with the JRILICENSE notice on every source file and in the About screen.

---

Built with care so it feels like a real operating system, not just another launcher.
