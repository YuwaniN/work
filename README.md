# Reflex Arcade

A SwiftUI iOS game collection — three fast-paced mini-games with persistent stats, location-based mapping, daily notifications, and a trivia API integration.

---

## Architecture Overview

The app follows a **Model–View–ViewModel (MVVM)** pattern with a service layer for persistence and networking.

```
ios_1/
├── App/              App entry point and navigation
├── Models/           Data structures (Card, GameMode, GameSession, Level, TriviaQuestion)
├── Services/         Business logic (GameSessionStore, LocationService, NotificationService, TriviaAPI)
├── ViewModels/       Observable state objects (LightItUpVM, QuizRushVM, StatsVM, TapFrenzyVM)
└── Views/
    ├── Games/        Game screens (LightItUpView, QuizRushView, TapFrenzyView)
    ├── Shared/       Reusable components (ResultView, ScoreBadge — placeholder)
    └── Tabs/         Tab screens (HomeTab, MapTab, SettingsTab, StatsTab)
```

### Entry Point

`PlayHubApp.swift` hosts a `TabView` with four tabs: **Home**, **Stats**, **Map**, and **Settings**. No global state is managed at the app level — each view owns its own view model via `@StateObject`.

### Data Flow

```
User Action → View → ViewModel @Published properties → View updates
                 ↕
           Service layer (UserDefaults / URLSession / CoreLocation / UserNotifications)
```

1. **ViewModels** hold `@Published` properties and expose methods that the views call.
2. **Services** are stateless enums or singletons — `GameSessionStore` persists to `UserDefaults`, `TriviaAPI` fetches from the Open Trivia DB, `LocationService` wraps `CLLocationManager`, and `NotificationService` manages daily reminders.
3. **GameSession** objects are created by each game VM at round end, annotated with the player's current location, then appended to `GameSessionStore`.
4. **StatsVM** reads all sessions to power the Stats and Map tabs.

---

## Features

### Games

| Game            | Description                          | Mechanics                                                                                                                                                                |
| --------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Tap Frenzy**  | Tap the green circle, avoid the gray | 10‑second rounds; combo multiplier grows with rapid taps (≤0.5 s); score += multiplier + 1 on green, score − 1 on gray                                                   |
| **Light It Up** | Memory-style grid: tap lit cards     | 60‑second rounds (configurable 30/60/90 s), 3 lives; 4 progressive levels (L1–L4) increase grid size, reduce lit duration, and eventually light two cards simultaneously |
| **Quiz Rush**   | 10-question trivia rounds            | +10 per correct answer, streak bonus, −5 per wrong answer; questions fetched live from [Open Trivia DB](https://opentdb.com); HTML entities decoded automatically        |

### Persistence & Stats

- **GameSessionStore** saves every completed game to `UserDefaults` as JSON (`Codable`).
- **Stats tab** shows:
  - Total games played and cumulative score
  - Personal best per game mode
  - A bar chart of all session scores
  - The 10 most recent games with timestamps
- **Settings tab** lets you reset all data.

### Location Mapping

- Each game session records the player's **latitude/longitude** at the moment of completion via `LocationService`.
- The **Map tab** plots all sessions as interactive markers on a MapKit `Map`, color-coded by game mode. Tapping a marker shows a detail sheet with the mode, score, and date.
- Location permission is requested on the Home tab's first appearance.

### Daily Challenge Notifications

- The **Settings tab** has a toggle to schedule a daily notification at a configurable time.
- Uses `UNUserNotificationCenter` with a repeating calendar trigger.

### Share Scores

- Every game result screen includes a `ShareLink` to share the player's score via the system share sheet.

---

## Known Limitations

- **`ResultView` / `ScoreBadge` are unused** — The shared components in `Views/Shared/` are placeholders ("Coming soon"). Each game view currently embeds its own result UI inline.
- **`GameSessionStore` persists to `UserDefaults`** — Not suitable for large numbers of sessions. All data is lost if the user clears app data or uninstalls the app. No iCloud sync or export feature exists.
- **No loading state for the Map tab** — Sessions are loaded on `.onAppear`, but the map appears immediately. On first launch with no data, it shows an empty-state message.
- **Trivia API dependency** — Quiz Rush requires an internet connection. The app handles errors gracefully (shows a retry screen), but offline play is not supported.
- **Single location per session** — The location recorded is a single point at the moment the game ends, not a trace.
- **Tap Frenzy color timer is fixed at 3 s** — The interval for toggling green/gray is hard-coded; there is no difficulty progression.
- **Light It Up level progression is time-based** — Level advances based on elapsed time rather than player performance, which can feel detached from skill.
- **Reachability check** — There is no proactive network reachability check. Quiz Rush attempts to fetch questions and shows a failure screen if it fails.
- **Accessibility** — The app uses standard SwiftUI controls but lacks VoiceOver labels, dynamic type support, and reduced-motion accommodations in several areas.

---

## Reflection

The app successfully delivers three distinct arcade-style mini-games in a clean, tab-based interface with persistent scoring and location mapping. The MVVM architecture keeps game logic testable and separated from UI code, and the service layer abstracts external dependencies (networking, location, notifications) behind simple interfaces.

**What went well:**

- The `GameSession` / `GameSessionStore` / `StatsVM` pipeline provides a clean, end-to-end data flow from gameplay → persistence → visualization (stats + map).
- Each game VM is self-contained with its own state machine, making them easy to reason about in isolation.
- The `Level` enum elegantly encapsulates Light It Up's difficulty progression with clear per-level parameters.

**What could be improved:**

- The unused placeholder views (`ResultView`, `ScoreBadge`) should be either removed or fully implemented to avoid confusion.
- `UserDefaults` works for light data but would benefit from migrating to `SwiftData` or Core Data for a production app with many players.
- The `MapTab` creates a separate `StatsVM` instance — sharing a single `StatsVM` (e.g., via `@StateObject` at the `TabView` level and `@ObservedObject` in the tabs) would ensure the stats and map always show consistent data.
- Tap Frenzy's difficulty could be made to ramp up over time (e.g., shrinking the tap target or speeding up the color toggle).
- Adding unit tests for the scoring logic and `Level` progression would improve confidence during refactoring.
