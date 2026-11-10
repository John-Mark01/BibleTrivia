# BibleTrivia

SwiftUI iOS app (iOS 18+, Swift 5 mode) with a Supabase backend. Users play Bible quizzes grouped by topic, earn points and levels, and keep a daily streak.

## Build & test

```sh
# Build
xcodebuild -project BibleTrivia.xcodeproj -scheme BibleTrivia -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build

# Unit tests (no network)
xcodebuild test -project BibleTrivia.xcodeproj -scheme BibleTrivia -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# + live integration test against the dev backend
TEST_RUNNER_BT_EMAIL=… TEST_RUNNER_BT_PASSWORD=… xcodebuild test …
```

`Config.xcconfig` (gitignored, copy from `Config.example.xcconfig`) provides `SUPABASE_URL` / `SUPABASE_API_KEY`. **Debug builds use the dev project, Release uses production.**

The Xcode project uses **synchronized folders**: `BibleTrivia/` and `BibleTriviaTests/` are picked up automatically. Never hand-edit `project.pbxproj` to add files.

## Supabase

| | Project ref |
|---|---|
| Production ("Bible Trivia") | `curjrjrzqgpdvizmnxhn` |
| Dev ("Bible Trivia Dev") | `sgdvlomeynxrsbdfvbrk` |

- The schema lives in `supabase/migrations/`. Every DDL change is a new migration, applied to **dev first** and to prod only once the app works against it. Never change prod schema directly.
- `supabase/seed.sql` has sample content for dev.
- There are **no Edge Functions**. The API is Postgres RPCs in `public`, defined in `*_v1_backend.sql`.

### Backend rules (security model)

- Clients may only `SELECT`. Content tables can be read by any signed-in user; user tables only by the row's owner. The one direct write is `users.name/age`.
- Every other write goes through a `SECURITY DEFINER` RPC that:
  - takes the user from `auth.uid()` (never accept a user id parameter);
  - sets `search_path = ''` and fully qualifies names;
  - is granted `EXECUTE` to `authenticated` only (default privileges revoke it from everyone else).
- **Scores are computed on the server** (`grade_answers`). Clients send `{question_id, answer_id}` pairs, never correctness. Points are `round(quiz.total_points × correct / total)`, awarded once per quiz. Level comes from points (`level_for_points`). Passing is ≥ 70%.
- Streaks count calendar days in the user's time zone (`check_in(p_time_zone)`), called once per sign-in.
- After DDL, run the Supabase security advisors. The only expected warnings are the client RPCs being callable by `authenticated`.

Client RPCs: `check_in`, `get_my_profile`, `get_topics_with_progress`, `get_available_quizzes`, `get_my_sessions`, `start_quiz_session` (idempotent), `save_quiz_progress`, `complete_quiz_session`, `abandon_quiz_session`, `delete_my_account`.

## App architecture

```
BibleTrivia/
  App/        BibleTriviaApp, AppDependencies (composition root), RootView, Router, PreviewEnvironment
  Core/       AppConfig, AppError, AlertManager, LoadingManager, Validation, Constants
  Core/API/   BibleTriviaAPI (protocol), SupabaseAPI (live), PreviewAPI + SampleData (DEBUG)
  Models/     Immutable value types decoded straight from RPC JSON (Quiz, Question, Answer, Topic, QuizSession, QuizAttempt, UserProfile…)
  Stores/     @MainActor @Observable state: AuthManager, UserStore, TopicStore, QuizStore, QuizPlayer, PagedList
  Views/      Screens by feature (Home, Play, Topics, Quiz, Account, Onboarding, Modals, Rows)
  Components/ Reusable UI (buttons, progress views, alert dialog, cards)
```

- **No singletons.** `AppDependencies` builds every object once. Views get them with `@Environment(Type.self)` (`inject(_:)`); stores get them through `init`.
- **One API surface.** All backend calls except auth go through `BibleTriviaAPI`, one method per RPC. `SupabaseAPI` decodes with `JSONDecoder.api` (snake_case keys, Postgres timestamps) and maps errors to `AppError`. Auth lives in `AuthManager`, which uses `SupabaseClient.auth` directly.
- **Auth state drives the root.** `AuthManager.state` (`.unknown/.signedOut/.signedIn`) is updated from `authStateChanges`. `RootView` swaps Welcome ↔ `MainTabView` and loads or resets data with `.task(id: state)`. Sign-in screens never navigate themselves.
- **Quiz play.** `QuizStore.start/resume` creates a `QuizPlayer` (pure, testable state machine: playing → finished → reviewing). Submitting the last answer calls `QuizStore.complete()`, so the server grades it, and results come from `QuizCompletion`. Exiting mid-quiz calls `saveAndExit()`. `QuizView` releases the player in `onDisappear`. `QuizStore` keeps `UserStore` and `TopicStore` in sync during play.
- **Pagination.** `PagedList` with `begin/finish/fail`. Views call `loadMore…IfNeeded(after:)` from each row's `.task`.
- **Errors.** Stores catch and call `alerts.show(error)`. Use `loading.perform {}` only for blocking actions (auth, start/save/complete), never for background refreshes.
- **Navigation.** `Router.path` is a `[Destination]` bound to the single `NavigationStack`. Add a case to `Router.Destination` and its view in `Destination.view`.
- **Modals.** Use `.quizStartModal($quiz)` / `.topicModal($topic)` rather than re-implementing start/navigation logic in each screen.
- **Previews.** Wrap in `PreviewEnvironment { … }`. It uses `PreviewAPI` sample data, so previews make no network calls.

## Conventions

- New stores and anything touching UI state: `@MainActor @Observable final class`.
- Models are `struct … : Identifiable, Hashable, Sendable, Decodable`. Let `convertFromSnakeCase` map keys; don't add `CodingKeys` unless names differ.
- Fonts via `.applyFont(.medium, size:, textColor:)`; colours are asset colours prefixed `bt` (`.btPrimary`, …).
- Spelling: "quizzes" (not quizez/quizzez), "explanation".
- Add unit tests in `BibleTriviaTests/` (Swift Testing) for store logic and decoding. Decoding fixtures should be real RPC responses.

## Known gaps for v1

- Apple/Google sign-in buttons show "coming soon".
- Avatars are a placeholder image (`Avatars/jacob`).
- Friends and Notifications rows are placeholders.
- Production still has the old schema until the migration is promoted (see `supabase/README.md`).
