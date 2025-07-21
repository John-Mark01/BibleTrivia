# Bible Trivia App

A SwiftUI-based Bible trivia application with Supabase backend.

## Setup

### Prerequisites
- Xcode 15.0+
- iOS 16.0+
- Supabase account

### Environment Variables

This app requires the following environment variables to be set:

1. **For Xcode Development:**
   - Open your Xcode scheme editor (Product → Scheme → Edit Scheme)
   - Go to Run → Environment Variables
   - Add these variables:
     ```
     SUPABASE_URL = your_supabase_project_url
     SUPABASE_API_KEY = your_supabase_anon_key
     ```

2. **For Command Line Testing:**
   ```bash
   export SUPABASE_URL="https://your-project.supabase.co"
   export SUPABASE_API_KEY="your_supabase_anon_key"
   ```

### Getting Supabase Credentials

1. Go to your [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project
3. Go to Settings → API
4. Copy your Project URL and anon public key

### Installation

1. Clone the repository
2. Open `BibleTrivia.xcodeproj` in Xcode
3. Set up environment variables as described above
4. Build and run

## Features

- User authentication
- Bible trivia quizzes
- Progress tracking
- Streak system
- Multiple difficulty levels

## Architecture

- **MVVM Pattern** with SwiftUI
- **Supabase** for backend services
- **Router Pattern** for navigation
- **Observable** classes for state management

## Security

This app uses environment variables for sensitive configuration. Never commit API keys or secrets to version control. 