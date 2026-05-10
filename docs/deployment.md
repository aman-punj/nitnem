# Deployment

## Mobile
- Flutter app build/deploy remains unchanged.
- Ensure `pubspec.yaml` includes `scrollable_positioned_list`.

## Admin Panel
1. `cd admin_panel`
2. `npm install`
3. `npm run build`
4. Deploy to Firebase Hosting target.

## Config
- Set `VITE_FIREBASE_*` env vars.
- Add Cloudinary upload credentials/server endpoint before production use.
