# CareConnect — Flutter client

The mobile build of CareConnect for **SWEN 661 Team 2 (The Acuity Health Group)**,
targeting care recipients who are deaf or hard of hearing.

> **Scope of this branch.** This branch carries the three screens assigned to
> **Victor Lee** — **Contacts**, **Messaging** (reached from Contacts) and
> **Accessibility Settings** — the shared application shell they run on, and
> Justin Zhang's screens (**Welcome, Sign In, Sign Up, Home, My Day**), merged
> in from `WK4-Justin`. Rehman Uddin's screens (Appointments, Medicines,
> Memories) land on his own branch; their navigation destinations already exist
> here as clearly-labelled placeholders. See [Adding a screen](#adding-a-screen).
>
> Every screen here is built to match the **Week 3 design prototype**. Where the
> prototype and the earlier React web client disagreed, the prototype won.

---

## What the application does

CareConnect is a daily companion for a care recipient and the people looking
after them. This client is built on one governing rule, taken from the team's
Assignment 3 design philosophy:

> **Anything the application communicates through sound must also be
> communicated visually or in text.** Sound may supplement a notification. It is
> never the only carrier.

That rule is why the Contacts screen has no call button, why a voicemail arrives
as a transcript rather than a play button, why "Notify" replaces "give me a
ring" with a silent flash on the other person's phone, and why the Settings
screen will not let you switch the visible alert banner off.

### The assigned constraints, and where each one is answered

| # | Constraint | Where it lives in this code |
|:--|:-----------|:----------------------------|
| 1 | Captions for video | `MessageBubble` states in words whether a video carries captions; size, colour and on/off live in Settings → Captions, with a live preview |
| 2 | Text alternative for audio | A `MessageKind.voicemail` renders its transcript as the message body (`lib/screens/messaging/widgets/message_bubble.dart`) |
| 3 | No sound-only alerts | `visualAlertBanners` has no setter and cannot be switched off, even by editing the stored preferences (`lib/models/accessibility_settings.dart`) |
| 4 | Clear visual notifications | `AlertBanner`, the in-thread `CareConnect alert` card, and the `VisualFlash` pulse — each carries an icon, a heading and a body that says *what* happened |
| 5 | User control of audio | Settings → Audio carries the alert-volume slider (zero is a valid setting) and the pause-control note; L/R balance supports a single aided ear |

---

## Screens in this branch

| Screen | Route | What it does |
|:-------|:------|:-------------|
| **Welcome** | `/welcome` | The cold-start splash: the brand, the hearing-accessibility pitch, and the two ways in. Doesn't count toward the 7–10 screen requirement — it has no functionality beyond the two buttons below it. |
| **Sign In** | `/sign-in` | Email/password sign in. Continues to the Home dashboard. |
| **Sign Up** | `/sign-up` | Account creation: name, email, password with confirmation. Continues to Home. |
| **Home / Dashboard** | `/home` | The day's summary: an upcoming-appointment banner, today's task progress, the next thing to do, and a simulated incoming video call with answer/decline and in-call controls (mute, pause, captions), all reachable without sound. |
| **My Day** | `/my-day` | Every task for the day as a checklist — medication, check-ins, appointments — each one tappable to mark done, with a shared progress bar against Home. |
| **Contacts** | `/contacts` | One list, Joyce first with a **Primary** pill, then the GP, the two children and the medical helpline. Each row shows the lettered avatar, the relationship, a preview of the latest message, and a count of messages **waiting** — a number *and* the word, never a bare dot. The banner at the top explains Notify. Tapping a row opens the conversation. |
| **Messaging** | `/contacts/:contactId` | The conversation, opened from a card. Day separators, delivery state written out ("Read"), transcripts for voicemail, caption status for video, in-thread CareConnect alerts, a validated composer, and the **Notify** action. Warns, with a link into Settings, when captions are off and the thread contains a video. On a tablet it also offers the prototype's "Call *name* now" — a captioned video call, never audio-only. |
| **Accessibility Settings** | `/settings` | A live WCAG conformance badge, then Visual Alerts, Captions (size, colour, live preview), Audio (volume, L/R balance), Vibration (three named rhythms, tap to feel), and Account. Persisted with `SharedPreferences`. |

That's **7 functional screens** (Welcome is deliberately not counted), against
the assignment's 7–10. Placeholders exist at `/appointments`, `/medicines` and
`/memories`, Rehman's screens, so the prototype's six-destination navigation
works end to end. They are **not** functional screens and do not count toward
the requirement either.

### Screenshots

Captured from a live iOS Simulator run (`flutter/docs/screenshots/`):

| | |
|:--|:--|
| [Contacts (phone)](docs/screenshots/01-contacts-phone.png) | The roster, Joyce first with the Primary pill, waiting counts as a number and a word |
| [Messaging (phone)](docs/screenshots/02-messaging-phone.png) | A conversation with day separators, delivery state, and the Notify banner |
| [Messaging — video captions (phone)](docs/screenshots/03-messaging-video-captions-phone.png) | Maria's thread, showing the "Captions available" badge on a video message |
| [Accessibility Settings (phone)](docs/screenshots/04-accessibility-settings-phone.png) | The WCAG conformance badge, Visual Alerts and Captions sections |
| [Contacts (tablet)](docs/screenshots/05-contacts-tablet.png) | The same screen at the tablet breakpoint: a persistent sidebar and a two-column grid |
| [Welcome (phone)](docs/screenshots/06-welcome-phone.png) | The cold-start screen: brand, accessibility pitch, and the two ways in |
| [Sign In (phone)](docs/screenshots/07-sign-in-phone.png) | Email/password sign in |
| [Sign Up (phone)](docs/screenshots/08-sign-up-phone.png) | Account creation with password confirmation |
| [Home / Dashboard (phone)](docs/screenshots/09-home-dashboard-phone.png) | The day's summary: upcoming appointment, task progress, next thing to do |
| [My Day (phone)](docs/screenshots/10-my-day-phone.png) | The full daily checklist, each task tappable to mark done |

Screens are laid out for **phone and tablet**: contact rows stack in one column
below 720dp and go two across above it; the phone's bottom bar becomes the
prototype's left sidebar on a tablet, with Settings listed in it rather than
behind the app-bar gear.

### Notify — the signature interaction

The prototype's answer to a phone call. Tapping it:

1. plays one bright, **non-strobing** pulse across the screen, carrying the
   words "Alert sent to *name*" — a preview of what the other person sees;
2. fires a haptic, if vibration is on in Settings;
3. writes a line into the conversation saying the alert went and that no sound
   was played.

Step 3 matters more than it looks. An action whose only trace was a flash would
leave a deaf user with no way to check afterwards that it actually went.

The pulse is deliberately a single slow fade rather than a strobe: anything
flashing more than three times a second risks triggering a seizure (WCAG 2.2
success criterion 2.3.1), and the pattern that helps this app's users must not
be the pattern that harms someone else.

---

## Architecture

```
lib/
├── main.dart                    # entry point; wires the concrete repositories
├── app.dart                     # MultiProvider + MaterialApp.router + theme
├── core/
│   ├── routing/                 # route names, paths, and the GoRouter
│   ├── theme/                   # Assignment 3 palette and typography scale
│   └── utils/                   # pure formatters, validators, haptic patterns
├── models/                      # Contact, Message, AccessibilitySettings,
│                                #   VibrationPattern, DailyTask
├── data/                        # repository interfaces + prototype fixtures
├── state/                       # ChangeNotifier controllers (no widget imports)
├── widgets/                     # shared UI: scaffold, banners, badges
└── screens/
    ├── splash/                  # Welcome
    ├── auth/                    # Sign In, Sign Up
    ├── home/                    # Home / Dashboard
    ├── my_day/                  # My Day
    ├── contacts/
    ├── messaging/
    ├── settings/
    └── pending/                 # Rehman's destinations, clearly labelled
```

**State management — Provider.** Four `ChangeNotifier` controllers
(`ContactsController`, `MessagesController`, `SettingsController`,
`DailyTasksController`) are supplied by a `MultiProvider` in `app.dart`. None
of them import a Flutter widget, so every one is unit tested directly.
`setState` is used only for genuinely local state — the composer's draft text,
the Notify flash trigger, and the Home screen's simulated call.

Shared state earns its keep in two visible places: opening a conversation clears
that contact's badge back on the Contacts screen without passing anything
through the route, and switching captions off in Settings makes a warning appear
inside any conversation that contains a video.

**Navigation — go_router (Navigator 2.0).** Routes are declared in
`lib/core/routing/app_router.dart`.

The six top-level destinations live inside a `ShellRoute`, so `AppShell` — and
with it the bottom bar, or the sidebar on a tablet — is built once and stays
mounted while only the page underneath changes. Each of those pages is a
`NoTransitionPage`: switching tabs swaps the content with no slide and no fade,
because the navigation is furniture and should not move. Settings is also in the
shell, so a tablet keeps its sidebar there, but it is *pushed* rather than
switched to, and the phone's bottom bar hides while it is open — it is a screen
you come back from, not a seventh tab.

Welcome, Sign In and Sign Up sit outside the shell too, ahead of it: `Routes.initial`
opens on Welcome, so a cold start walks through the onboarding flow before ever
reaching the tab bar. The conversation screen also sits outside the shell, on
the root navigator, so it covers the navigation the way a drill-down should and
keeps a normal push animation and back-swipe. The contact is identified by the `contactId` path
parameter, so the screen works from a tap and from a cold deep link alike. An id
that no longer exists lands on a recoverable "contact is not in your list"
screen; an unknown path lands on the router's error screen. Screens that can be
reached by deep link carry an explicit back button rather than the automatic
one, which would render nothing when there is no history to pop.

**Persistence.** `SharedPreferences`, one key per preference
(`lib/data/settings_repository.dart`), so a preference added later cannot
invalidate the whole stored object. A corrupt or partially written store falls
back to safe defaults rather than throwing on startup.

**Accessibility.** Every interactive element carries a `Semantics` label,
interactive targets are at least 48dp, section headings are marked as headers so
a screen reader can jump between them, and status is always "a word plus a
shape" — never colour alone, which is why switches print "On"/"Off", the badge
prints "waiting", and the selected navigation tab is bold and underlined as well
as coloured. Colours and their measured contrast ratios come straight from the
Assignment 3 design system (`lib/core/theme/app_colors.dart`); both caption
colours were checked against the caption panel (white 8.5:1, yellow 8.1:1).

---

## Getting started

These steps assume no prior programming experience. There are two parts:
installing some free tools (once), then running two commands (every time).

### 1. Install the tools

You need three things. If you already have one, skip it.

1. **Flutter** — follow the install guide for your computer at
   <https://docs.flutter.dev/get-started/install>. It walks you through
   downloading Flutter and adding it to your terminal.
2. **Xcode** (Mac only, needed to show the app on an iPhone) — install it for
   free from the Mac App Store, then open it once so it can finish setting
   up.
3. **Android Studio** (needed to show the app on Android) — download it from
   <https://developer.android.com/studio> and install it. The first time you
   open it, a setup wizard appears; click through it with the defaults (it
   downloads what it needs automatically). Once it's done, click
   **More Actions > Virtual Device Manager > Create device**, pick any
   phone, and click Next until you reach Finish. This creates the Android
   emulator the app will run on.

To check everything installed correctly, open a terminal and run:

```bash
flutter doctor
```

If it prints any ✗, it will tell you exactly what to do to fix it.

### 2. Run the app

Open a terminal in this repository and run:

```bash
cd flutter
flutter pub get
./run.sh
```

`run.sh` starts an iPhone simulator and an Android emulator for you and opens
the app on both. The first time can take a few minutes while everything
boots and builds; it's much faster after that. Once the app windows open,
you're running CareConnect.

To stop it, go back to the terminal and press `q`.

<details>
<summary>Advanced: running on just one platform, or a real device</summary>

```bash
flutter devices              # list everything currently available
flutter run -d <device-id>   # run on one specific device
```

If you'd rather pick from a menu, plain `flutter run` will prompt you as
long as at least one simulator, emulator, or device is already running.

</details>

### Release builds

`android/` and `ios/` are committed, so these work right after `flutter pub
get` — no extra setup step:

```bash
flutter build apk --release          # Android
flutter build ios --release --no-codesign   # iOS, macOS only
```

`--no-codesign` skips Apple's device-signing requirement, which needs a
personal Apple Developer account to set up and isn't needed just to confirm
the app builds. To install a build on your own iPhone, drop `--no-codesign`
and see [Apple's code-signing guide](https://developer.apple.com/library/content/documentation/IDEs/Conceptual/AppDistributionGuide/MaintainingCertificates/MaintainingCertificates.html) —
in short, open `ios/Runner.xcworkspace` in Xcode, sign in with your Apple
ID, and pick it as the Team under Signing & Capabilities.

If you ever need to regenerate the platform folders (e.g. after a Flutter
upgrade), do it through a throwaway project rather than `flutter create .` in
place, which would overwrite `lib/main.dart`:

```bash
cd flutter
flutter create --platforms=android,ios --project-name careconnect_mobile ../_platform_tmp
cp -r ../_platform_tmp/android ../_platform_tmp/ios .
rm -rf ../_platform_tmp
```

---

## Tests

```bash
cd flutter
flutter analyze                      # expected: No issues found!
flutter test                         # all tests should pass
flutter test --coverage              # writes coverage/lcov.info
```

### Coverage report

```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html        # or: start coverage\html\index.html
```

The report is written to `flutter/coverage/html/index.html`. Attach the summary
screenshot to the submission; the assignment floor is **60 % line coverage** —
this branch currently sits at **98.9 %** across 217 tests.

If `genhtml` is not installed (it ships with `lcov`), the Dart alternative is:

```bash
dart pub global activate coverage
```

### Security scan

[`osv-scanner`](https://github.com/google/osv-scanner) was run against
`pubspec.lock` to check every resolved dependency for known vulnerabilities,
paired with a manual check of `lib/` for hardcoded secrets, plaintext network
calls, and unsafe dynamic execution. No issues were found on either front.
See [`docs/security-scan.md`](docs/security-scan.md) for the full report and
the exact commands to reproduce it.

### What is tested

**Unit tests** (`test/models/`, `test/state/`, `test/utils/`)

- `Contact` — the design's own avatar initials and the fallback that derives
  them, honorific handling, helpline naming, semantic labels, equality
- `Message` — transcript and caption headings, authorship, the sentence a screen
  reader announces, delivery-status labels
- `AccessibilitySettings` — prototype defaults, volume and balance clamping
  (including `NaN`), the written balance label, map round-trip, graceful
  recovery from a corrupt or partial store, and that the visual banner cannot be
  switched off through storage
- `VibrationPattern` — the three named rhythms are well formed, bounded in
  length, printed as well as felt, and actually distinguishable from each other
- `Formatters` / `Validators` — 12-hour clock edge cases (midnight, noon),
  calendar-day vs elapsed-hours day labels, composer length and blank rules
- `ContactsController` — load, failure, ordering, lookup, unmodifiable exposure
- `MessagesController` — thread caching, transcript previews, the
  waiting-messages rule, Notify records, send validation
- `SettingsController` and all three repositories — persistence, no-op writes,
  clamping on write, and a `SharedPreferences` round-trip
- `DailyTasksController` — starting totals, toggling a task on and off,
  progress as a fraction, and the appointment notification's visibility

**Widget tests** (`test/widgets/`)

- Contacts renders the design's five contacts with their initials, relationships
  and Primary pill, previews a video by its captions, shows waiting counts as a
  number and a word, and — asserted explicitly — offers **no voice-call
  affordance anywhere**
- A failed load on either screen explains itself and recovers on retry, and is
  asserted *not* to read as "no contacts" or "no messages": an unreachable
  conversation and one nobody has written in are different problems
- Contacts stacks one column on a phone and two plus a sidebar on a tablet
- The conversation renders bubbles in order, groups them by day, stamps them
  "8:02 am" as the prototype does, shows a voicemail as a transcript, states
  caption availability, and renders a CareConnect alert
- Notify plays the flash, writes the record into the thread, and tells the truth
  in its sub-line when vibration is off
- The composer rejects blank and whitespace-only messages with a written reason,
  sends, and counts characters down
- Settings renders every prototype section, writes each switch state out as a
  word, refuses to unlock the visual banner, flips the conformance badge when
  captions go off, repaints the caption preview in yellow, drives both sliders,
  and previews a vibration rhythm without changing any setting
- Navigation: list → conversation → back, bottom bar, app-bar gear, tablet
  sidebar, deep links, the unknown-route screen, and the cross-screen caption
  warning
- The navigation bar does not move while a tab changes (its rect is identical
  one frame into the switch), the outgoing page is gone on the next frame rather
  than sliding out, and the bar hides on Settings while the tablet sidebar
  stays
- Welcome renders the brand and accessibility pitch and gets to Sign Up from
  "Get started"; Sign In and Sign Up render their forms and Sign In continues
  to Home
- Home renders the dashboard, and a simulated incoming call can be declined or
  answered, with in-call controls (mute, pause, captions) and a route back to
  Home when the call ends
- My Day shows the daily task count and title, and tapping a task flips its
  done state and the shared progress count

---

## Adding a screen

1. Add the path and name to `lib/core/routing/routes.dart` (most already exist).
2. Replace the `PendingScreen` in `lib/core/routing/app_router.dart` with the
   real screen — one line per route. Keep it inside the `ShellRoute` and wrapped
   in `page(...)` so it inherits the persistent navigation and swaps without a
   transition.
3. Build the screen inside `AppScaffold`, which supplies the app bar. The
   navigation is not the screen's concern — `AppShell` owns it, and
   `kDestinations` already lists every destination.

---

## Known issues and limitations

- **Data is in memory.** `MockContactRepository`, `MockMessageRepository` and
  `InMemoryDailyTasksRepository` seed from the prototype's fixtures, and
  messages sent or tasks toggled during a session are kept only for the life
  of the process. Only the accessibility settings persist to disk.
- **Video, audio and the captioned call are represented, not implemented.**
  Requesting a call opens a written confirmation; there is no media pipeline
  behind it yet, and the alert-volume and balance settings are stored and
  displayed but not yet applied to a real audio stream.
- **Vibration patterns are approximated.** Flutter's `HapticFeedback` exposes
  named impacts rather than an arbitrary waveform, so each rhythm is played as a
  sequence of impacts and pauses. That is enough to tell them apart by feel; a
  true waveform needs a platform channel.
- **Authentication is not wired to a backend.** Sign In and Sign Up validate
  their forms and route on to Home, but neither checks credentials against a
  real account store yet. Sign out in Settings is present and says plainly
  that it is not wired up, rather than failing silently.
- Assignment 3 mentions requesting an ASL interpreter. The Week 3 prototype has
  no surface for it, so it is not built here.
- No font asset is bundled; the app uses each platform's system sans-serif, which
  the design system permits and which inherits the reader's platform font
  settings.

---

## Team member contributions — Week 4

| Member | Screens |
|:-------|:--------|
| Justin Zhang | Welcome, Sign In, Sign Up, Home, My Day — merged into this branch from `WK4-Justin` |
| Rehman Uddin | Appointments, Medicines, Memories — pending, still on his own branch |
| **Victor Lee** | **Contacts, Messaging, Accessibility Settings** — plus the shared shell: theme, router, navigation, models, repositories, Provider controllers, and the shared widgets; merged in Justin's screens, fixed a tablet-layout overflow bug in `StatusBadge` uncovered while screenshotting, and added the missing `DailyTasksController` unit test |

---

## AI usage summary

Claude (Opus) was used on this branch to:

- scaffold the Flutter project and translate the Assignment 3 colour palette and
  typography scale into `ThemeData`;
- read the Week 3 design prototype and rebuild the three screens against it,
  including the contact roster, the Notify interaction, and the five Settings
  sections;
- draft the Provider controllers, the repositories and the shared widgets;
- generate unit and widget test cases, including edge cases the author had not
  listed — `NaN` slider values, whitespace-only messages, corrupt preference
  values, calendar-day vs elapsed-hours date grouping, and an attempt to disable
  the visual alert banner by editing stored preferences;
- write this README;
- merge Justin's Welcome/Sign In/Sign Up/Home/My Day screens from `WK4-Justin`
  into this branch's shell — wiring the new routes, the `DailyTasksController`
  provider, and the test harness, then fixing the small breakage that surfaced
  (a stale `Routes.initial` assertion, two `withOpacity` deprecation warnings,
  an unused import);
- run an OSV-Scanner dependency scan and a manual secrets/network-call review
  (`docs/security-scan.md`);
- capture the simulator screenshots in `docs/screenshots/`, which is how the
  tablet `RenderFlex` overflow in `StatusBadge` was actually found — it only
  showed up once the Contacts screen was seen rendered live, not from
  `flutter analyze` or the test suite.

Rejected AI suggestions: telephone call-to-action buttons on contact cards, and
transient snack-bar confirmations. Both were replaced — the first with text and
captioned-video actions, the second with dismissible dialogs, because the team's
design philosophy rules out timed windows that penalise a user reading at their
own pace. A strobing implementation of the Notify flash was also rejected in
favour of a single fade, for the seizure-risk reason given above.

All generated code was reviewed, and every test was run before submission.
