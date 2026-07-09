# Refactor Instructions for Copilot — PlayHub App Restructure (Week 4)

## Goal

Reorganize the existing Xcode project (currently flat files for Tap Frenzy,
Light It Up, and Quiz Rush) into the folder structure below. **This is a
pure refactor** — move, rename, and reference-fix only. Do not add new
features, do not change game logic, do not touch UI behavior. Every mode
must build and run identically after this pass.

## Rules for Copilot

1. **Do not invent new logic.** If a file doesn't exist yet (e.g.
   `GameMode.swift`), create the minimal version needed to compile — don't
   guess at future features from later weeks.
2. **One type per file, file name matches the type name.**
3. **Preserve all existing `@Published` properties, method signatures, and
   view behavior** in files being moved — only change file location,
   file name, and (where noted) the type name.
4. **Fix every import and reference** after a move — Xcode does not do this
   automatically when you drag files in Finder; if moving via terminal/git,
   confirm target membership in the `.pbxproj` or re-add via Xcode's
   "Add Files" so build phases stay correct.
5. **Work in the exact step order below.** Build after every step. Do not
   start step *N+1* if step *N* doesn't compile.
6. **Group folders are physical folders on disk**, not just Xcode groups —
   use "Create folder references" / real directories so the repo structure
   on disk matches Xcode's navigator.
7. Commit after each step with the message suggested — this gives a commit
   history showing model → service → ViewModel → view → polish, which is
   part of the marked checklist.

## Target structure

```
PlayHubApp/
├── App/
│   └── PlayHubApp.swift
├── Models/
│   ├── GameMode.swift
│   ├── GameSession.swift
│   └── TriviaQuestion.swift
├── ViewModels/
│   ├── TapFrenzyVM.swift
│   ├── LightItUpVM.swift
│   ├── QuizRushVM.swift
│   └── StatsVM.swift
├── Services/
│   ├── TriviaAPI.swift
│   ├── NotificationService.swift
│   └── LocationService.swift
└── Views/
    ├── Tabs/
    │   ├── HomeTab.swift
    │   ├── StatsTab.swift
    │   ├── MapTab.swift
    │   └── SettingsTab.swift
    ├── Games/
    │   ├── TapFrenzyView.swift
    │   ├── LightItUpView.swift
    │   └── QuizRushView.swift
    └── Shared/
        ├── ResultView.swift
        └── ScoreBadge.swift
```

## File-by-file mapping (what exists today → where it goes)

| Current file | New location | Rename? | Notes |
|---|---|---|---|
| `TapFrenzyView.swift` | `Views/Games/TapFrenzyView.swift` | No | Move only |
| Tap Frenzy's inline `@State` logic | `ViewModels/TapFrenzyVM.swift` | New extraction | Pull `score`, `timeRemaining`, `multiplier`, `isGreen`, timers into an `ObservableObject` — same pattern as `QuizRushViewModel`. View keeps only `@StateObject` + layout. |
| Light It Up view/logic (wherever it currently lives) | `Views/Games/LightItUpView.swift` + `ViewModels/LightItUpVM.swift` | Extract VM | Same split as Tap Frenzy |
| `QuizQuestion.swift` | `Models/TriviaQuestion.swift` | **Yes** — rename struct `QuizQuestion` → `TriviaQuestion` | Keep `TriviaResponse` / `TriviaQuestionDTO` in the same file, or split into `Services/TriviaAPI.swift` if preferred — see below |
| `TriviaService.swift` | `Services/TriviaAPI.swift` | **Yes** — rename struct `TriviaService` → `TriviaAPI` | Keep the DTOs (`TriviaResponse`, `TriviaQuestionDTO`) here since they're API-shape-specific, not app models |
| `QuizRushViewModel.swift` | `ViewModels/QuizRushVM.swift` | **Yes** — rename class `QuizRushViewModel` → `QuizRushVM` | Update every reference to the type name (the view's `@StateObject`) |
| `QuizRushView.swift` | `Views/Games/QuizRushView.swift` | No | Move only, update `@StateObject` type reference after VM rename |

## New files to stub out (compile-ready, minimal)

- `Models/GameMode.swift` — an enum: `.tapFrenzy`, `.lightItUp`, `.quizRush`, each with a `displayName` and SF Symbol name (`gamecontroller`, `bolt`, `questionmark.circle` or similar).
- `Models/GameSession.swift` — struct per the slide: `id: UUID`, `mode: GameMode`, `score: Int`, `timestamp: Date`, `latitude: Double`, `longitude: Double`. Conform to `Codable` and `Identifiable`.
- `ViewModels/StatsVM.swift` — `ObservableObject` that will later read persisted `GameSession`s. For this step, stub with an empty `@Published var sessions: [GameSession] = []` and a `load()` method that does nothing yet.
- `Services/NotificationService.swift` — empty struct/class shell with a `requestPermission()` stub and a `scheduleDaily(at:)` stub — no real `UNUserNotificationCenter` calls yet.
- `Services/LocationService.swift` — empty class shell wrapping `CLLocationManager`, no real permission/location logic yet.
- `Views/Tabs/HomeTab.swift`, `StatsTab.swift`, `MapTab.swift`, `SettingsTab.swift` — each a placeholder `View` with just a `Text("Coming soon")` and `.navigationTitle(...)`. These get built out in later steps, not this refactor pass.
- `Views/Shared/ResultView.swift`, `ScoreBadge.swift` — placeholder views for now; existing per-game "Game Over" / "Quiz Complete" UI stays inline in each game view until a later step extracts it.
- `App/PlayHubApp.swift` — the `@main App` struct. Root view becomes a `TabView` with 4 tabs (`HomeTab`, `StatsTab`, `MapTab`, `SettingsTab`), each wrapped in its own `NavigationStack`. `HomeTab` is where Tap Frenzy / Light It Up / Quiz Rush get launched from.

## Step order

1. **Create the folder skeleton** (all folders above, even empty ones) and commit.
   `git commit -m "chore: create PlayHub folder structure"`
2. **Move + rename the Quiz Rush files** per the mapping table. Fix all internal references (`QuizRushViewModel` → `QuizRushVM`, `QuizQuestion` → `TriviaQuestion`, `TriviaService` → `TriviaAPI`). Build.
   `git commit -m "refactor: move Quiz Rush into Models/ViewModels/Services/Views structure"`
3. **Extract Tap Frenzy's ViewModel** out of the existing single-file view into `TapFrenzyVM.swift`, move the view into `Views/Games/`. Build.
   `git commit -m "refactor: extract TapFrenzyVM, move TapFrenzyView"`
4. **Extract Light It Up's ViewModel** the same way. Build.
   `git commit -m "refactor: extract LightItUpVM, move LightItUpView"`
5. **Add the model stubs** (`GameMode`, `GameSession`) and the service/tab/shared stubs listed above — these should compile but do nothing yet. Build.
   `git commit -m "feat: stub GameMode, GameSession, tab views, and service shells"`
6. **Build the TabView shell** in `PlayHubApp.swift`, wire `HomeTab` to present the three existing games exactly as before (no regressions). Build and manually verify all three games still play correctly.
   `git commit -m "feat: add TabView shell with 4 tabs, wire games into HomeTab"`

## Verification checklist after the refactor

- [ ] Project builds with zero errors/warnings introduced by the move
- [ ] Tap Frenzy still plays exactly as before
- [ ] Light It Up still plays exactly as before
- [ ] Quiz Rush still fetches, plays, and shows results as before
- [ ] All four tabs are visible and navigable (Stats/Map/Settings can be placeholders for now)
- [ ] No file contains more than one primary type
- [ ] No logic changed — only location, file names, and the two renamed types
