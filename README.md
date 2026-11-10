# Bible Trivia App

A SwiftUI-based Bible trivia application with Supabase backend.

## Setup

### Prerequisites
- Xcode 16.0+
- iOS 18.0+
- Supabase account

### Configuration

1. Copy `Config.example.xcconfig` to `Config.xcconfig` (gitignored).
2. Fill in the Supabase URL and publishable key for production, and for the dev project under the `[config=Debug]` lines.
3. Debug builds talk to the dev project; Release builds talk to production.

Backend schema, migrations and how to promote them: see [`supabase/README.md`](supabase/README.md).

### Installation

1. Clone the repository
2. Open `BibleTrivia.xcodeproj` in Xcode
3. Create your configuration file as described above
4. Build and run (`⌘R`), run tests with `⌘U`

## Features

- User authentication
- Bible trivia quizzes
- Progress tracking
- Streak system
- Multiple difficulty levels

## Architecture

See [`CLAUDE.md`](CLAUDE.md) for the full architecture and conventions. In short: SwiftUI with `@Observable` stores, a single `BibleTriviaAPI` over Supabase RPCs, server-side scoring, and Row Level Security that only lets clients read their own data.
