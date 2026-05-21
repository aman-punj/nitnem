# Issues and Tasks

## Open Tasks

### Design Tokens Audit
- [ ] Audit UI across all screens in `mobile_app/lib/screens` to ensure strict adherence to design tokens defined in `mobile_app/lib/core/design_system/tokens/`.

### Notifications
- [ ] Implement scheduled local notifications:
    - 6:00 AM — Japji Sahib
    - 6:30 PM — Rehras Sahib
- [ ] Integrate with Admin Panel for configurable notification text (future task).

### Admin Panel
- [ ] Cloudinary upload flow
- [ ] Firestore content management UI
- [ ] Dynamic prayer catalog

### Mobile
- [ ] Multi-language transcript support (Hindi, English)
- [ ] Offline asset syncing refinement
- [ ] Feature flags integration

## Known Issues

### GMS Phenotype API Warnings (Non-blocking)
Logcat shows `SecurityException: Unknown calling package name 'com.google.android.gms'` and `Phenotype.API is not available` on some devices and emulators. These are GMS-internal and do not affect app functionality. See [android-release.md](android-release.md) for details.

### ProGuard Keep Rules Must Be Updated With Each New Plugin
When a new Flutter plugin with native Android code is added, a keep rule must be added to `proguard-rules.pro` or the release build will hang on the splash screen. See [android-release.md](android-release.md).
