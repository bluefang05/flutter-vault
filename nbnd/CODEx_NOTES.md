# NBND Notes

- Target Android compatibility: API 21.
- Current Android package: `com.enmanuelapp.nbnd`.
- Main app entry: `lib/app/nbnd_app.dart`.
- Game screen uses a live AdMob banner at the top when the setting is enabled.
- AdMob is vendored at 5.3.1 with WebView Android pinned to 4.10.1 so release
  builds keep `minSdk 21`; newer plugin lines require API 24.
- Release disables minify/resource shrinking because R8 can obfuscate
  WorkManager/Room internals pulled by Ads and crash during AndroidX Startup.
- Remove old device installs of `com.example.nbnd`; the current launcher package
  is only `com.enmanuelapp.nbnd`.
- Persistent state now uses local JSON storage instead of `shared_preferences`.
- Keep the context short. Prefer fixing one blocker at a time.
- `anhedonia` ya existe como perfil con inmortalidad temporal.
- Manual i18n currently covers ES, EN, PT, FR and DE.
- Engagement rule: skill-based flow only. No loot boxes, daily pressure, loss
  aversion, or mechanics intended to create dark flow.
- Gameplay has clean-pass streaks, near-miss bonuses, adaptive recovery after
  damage, and short breathing windows between pressure cycles.
- Golden recovery orbs spawn every 18-28 seconds, restore one spoon half up to
  the profile maximum, and use a static halo when reduced flashes is enabled.
