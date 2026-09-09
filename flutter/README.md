# CareConnect — Flutter client

The mobile build of CareConnect. See the [Flutter mobile client](../README.md#flutter-mobile-client)
section of the root README for screens, architecture, assigned-constraint mapping, and AI usage.

## Quick start

```bash
flutter pub get
./run.sh        # boots an iPhone simulator + Android emulator and runs on both
# or: ./dev.sh  # interactively pick one device
```

## Tests

```bash
flutter analyze
flutter test --coverage    # writes coverage/lcov.info
```

217 tests, 98.9% line coverage against a 60% floor. See [`docs/security-scan.md`](docs/security-scan.md)
for the dependency and secrets scan.

## Adding a screen

1. Add the path and name to `lib/core/routing/routes.dart` (most already exist).
2. Replace the `PendingScreen` in `lib/core/routing/app_router.dart` with the real screen —
   one line per route, inside the `ShellRoute` and wrapped in `page(...)` so it inherits the
   persistent navigation and swaps without a transition.
3. Build the screen inside `AppScaffold`, which supplies the app bar. Navigation is not the
   screen's concern — `AppShell` owns it, and `kDestinations` already lists every destination.

## Team member contributions — Week 4

| Member | Screens |
|:-------|:--------|
| Justin Zhang | Welcome, Sign In, Sign Up, Home, My Day|
| Rehman Uddin | Appointments, Medicines, Memories|
| Victor Lee | Contacts, Messaging, Accessibility Settings|
