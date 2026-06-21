.PHONY: help \
        admin-install admin-dev admin-deploy \
        mobile-get mobile-release-apk mobile-release-bundle mobile-release

# ── Defaults ──────────────────────────────────────────────────────────────────

help:
	@echo ""
	@echo "  Admin panel"
	@echo "    make admin-install        npm install"
	@echo "    make admin-dev            local dev server"
	@echo "    make admin-deploy         install → build → deploy  [main]"
	@echo ""
	@echo "  Mobile"
	@echo "    make mobile-get           flutter pub get"
	@echo "    make mobile-release-apk   release APK"
	@echo "    make mobile-release-bundle release App Bundle (Play Store)"
	@echo "    make mobile-release       APK + App Bundle"
	@echo ""

# ── Admin panel ───────────────────────────────────────────────────────────────

admin-install:
	cd admin_panel && npm install

admin-dev:
	cd admin_panel && npm run dev

admin-deploy: admin-install
	cd admin_panel && npm run build && cd .. && firebase deploy --only hosting

# ── Mobile app ────────────────────────────────────────────────────────────────

mobile-get:
	cd mobile_app && flutter pub get

mobile-release-apk:
	cd mobile_app && flutter build apk --release

mobile-release-bundle:
	cd mobile_app && flutter build appbundle --release

mobile-release: mobile-release-apk mobile-release-bundle
