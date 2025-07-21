# Bible Trivia App

A SwiftUI-based Bible trivia application with Supabase backend.

## Setup

### Prerequisites
- Xcode 15.0+
- iOS 16.0+
- Supabase account

### Configuration

This app requires a configuration file with your Supabase credentials.

#### Method 1: Create a Config.plist file (Recommended)

1. **Create the config file:**
   - Right-click in Xcode on your project
   - Choose "New File" → "Property List"
   - Name it `Config.plist`
   - Make sure it's added to your app target

2. **Add your Supabase credentials:**
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>SUPABASE_URL</key>
       <string>https://your-project-id.supabase.co</string>
       <key>SUPABASE_API_KEY</key>
       <string>your_supabase_anon_public_key</string>
   </dict>
   </plist>
   ```

3. **The app will automatically read from this file**

#### Method 2: Add to Info.plist (Alternative)

Add these keys directly to your `Info.plist`:
```xml
<key>SUPABASE_URL</key>
<string>https://your-project-id.supabase.co</string>
<key>SUPABASE_API_KEY</key>
<string>your_supabase_anon_public_key</string>
```

### Getting Supabase Credentials

1. Go to your [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project
3. Go to Settings → API
4. Copy your Project URL and anon public key

### Installation

1. Clone the repository
2. Open `BibleTrivia.xcodeproj` in Xcode
3. Create your configuration file as described above
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

⚠️ **Important:** Never commit your configuration files with real API keys to version control. The `.gitignore` is configured to prevent this, but always double-check before committing.

For production apps, consider using:
- Xcode build configurations
- Environment-specific config files
- Server-side configuration management 