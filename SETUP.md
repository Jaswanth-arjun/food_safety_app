# Setup Instructions for Contributors

## Before Running the App

Your Supabase credentials are **not included** in this repository for security reasons.

### 1. Get Your Supabase Credentials

1. Go to [Supabase Dashboard](https://supabase.com)
2. Select your project
3. Go to **Settings → API**
4. Copy:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **Anon Key** (public, safe for client)
   - **Service Role Key** (keep secret, never share)

### 2. Configure Your Local Constants

1. Copy the example file:
   ```bash
   cp lib/config/constants.dart.example lib/config/constants.dart
   ```

2. Edit `lib/config/constants.dart` and replace:
   ```dart
   static const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
   static const String supabaseAnonKey = 'YOUR_ANON_KEY_HERE';
   static const String supabaseServiceRoleKey = 'YOUR_SERVICE_ROLE_KEY_HERE';
   ```

### 3. Set Up Supabase Storage

1. Go to your Supabase Dashboard
2. Navigate to **Storage** in the sidebar
3. Click **Create bucket**
4. Name it `avatars` (all lowercase)
5. Set it as **Public** (so profile images can be viewed)
6. Click **Create bucket**

### 4. Run the App

```bash
flutter pub get
flutter run
```

## Important Notes

- **Never commit** `lib/config/constants.dart` with real credentials
- The file is in `.gitignore` and Git will ignore it
- Only `lib/config/constants.dart.example` should be in version control
- Each developer maintains their own local `constants.dart` file

## Troubleshooting

**Login Failed: Host Lookup Error?**
- Make sure `lib/config/constants.dart` has valid Supabase URL
- Check INTERNET permission is in `android/app/src/main/AndroidManifest.xml`
- Verify your Supabase project is active

**App Won't Compile?**
- Run `flutter clean && flutter pub get`
- Make sure you have valid placeholder values (not empty strings)

## Security Checklist

✅ `lib/config/constants.dart` is in `.gitignore`
✅ Use only the **Anon Key** in client apps
✅ Never share the **Service Role Key**
✅ Rotate keys in Supabase if they're ever exposed
✅ Keep `.env` files out of version control
