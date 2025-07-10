# Supabase Integration Details for notes_app_frontend

The app integrates with Supabase using the `supabase_flutter` Dart library.

## Environment
- SUPABASE_URL: https://mzxyorlnbfdkneiezgjz.supabase.co
- SUPABASE_KEY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im16eHlvcmxuYmZka25laWV6Z2p6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIwNDUxMDksImV4cCI6MjA2NzYyMTEwOX0.URYpbwtC2u5ORBlUzpWPNspXMWq_cLBOKWMOgGbilyQ

## Required Table
Table name: `notes`
| Column    | Type      | Nullable | Description         |
|-----------|-----------|----------|---------------------|
| id        | text      | false    | Primary key (UUID)  |
| title     | text      | false    | Note title          |
| content   | text      | false    | Note content        |
| createdAt | timestamptz | false  | Creation timestamp  |
| updatedAt | timestamptz | false  | Last update         |

> Enable Row Level Security (RLS) if necessary. The mobile app uses anonymous access via service role for full table access.

## Usage
- App syncs local notes with Supabase on demand (refresh/sync).
- All CRUD operations are performed on both local and remote.
- User authentication is NOT required; uses anon key access.
