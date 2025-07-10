# Supabase Integration Details for notes_app_frontend

The app integrates with Supabase using the `supabase_flutter` Dart library.

## Environment
- SUPABASE_URL: https://mzxyorlnbfdkneiezgjz.supabase.co
- SUPABASE_KEY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im16eHlvcmxuYmZka25laWV6Z2p6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIwNDUxMDksImV4cCI6MjA2NzYyMTEwOX0.URYpbwtC2u5ORBlUzpWPNspXMWq_cLBOKWMOgGbilyQ

## Remote Table as Created on Supabase

Table name: `notes`

| Column      | Type                     | Nullable | Default             | Description                       |
|-------------|--------------------------|----------|---------------------|-----------------------------------|
| id          | uuid                     | false    | gen_random_uuid()   | Primary key (UUID, not "text")    |
| title       | text                     | false    |                     | Note title                        |
| content     | text                     | true     |                     | Note content (nullable in DB)     |
| created_at  | timestamptz              | false    | now()               | Creation timestamp (snake_case)   |
| updated_at  | timestamptz              | false    | now()               | Last update (snake_case)          |
| tags        | text[] (array)           | true     |                     | (NOT used by app)                 |
| lastEdited  | timestamptz              | true     |                     | (NOT used by app)                 |

### Important Notes

- The original app code expects: `id`, `title`, and `content` as non-null.
- Table provides: `id` as UUID (Dart treats as String), `content` is nullable (client code should handle this as empty string or default).
- Timestamps in table use snake_case (`created_at`, `updated_at`), while the app's Dart model uses camelCase (`createdAt`, `updatedAt`).
    - Flutter mapping code converts between these when transforming to/from map (`fromMap` / `toMap`).
- Table includes extra columns: `tags` and `lastEdited`, which are not used by the current app version.
- The remote_note_service.dart Dart logic does a `Note.fromMap` translation and gracefully handles the actual schema.

> Enable Row Level Security (RLS) if necessary. The mobile app uses anonymous access via service role for full table access.

## Usage
- App syncs local notes with Supabase on demand (refresh/sync).
- All CRUD operations are performed on both local and remote.
- User authentication is **NOT** required; uses anon key access with the provided anon key.

## Table/Model Property Mapping

| Dart Model Property | Supabase Table Column |
|---------------------|----------------------|
| id                  | id                   |
| title               | title                |
| content             | content              |
| createdAt           | created_at           |
| updatedAt           | updated_at           |

## How the Client Handles Schema Differences

- The Dart model treats `id` as String but works fine with UUID (String representation).
- `createdAt` and `updatedAt` fields are mapped from/to `created_at` and `updated_at` using the Dart map keys.
- If "content" is NULL in the DB, the app will default to empty string in the model.
- Any extra DB columns are ignored by the client unless explicitly handled.

## Example DB Row

```json
{
  "id": "fd972338-52f2-4ee9-9b80-02abcb654007",
  "title": "My note",
  "content": "Sample content",
  "created_at": "2024-04-09T14:01:23.000Z",
  "updated_at": "2024-04-09T14:02:19.000Z"
}
```

## Recommendations for Backend

- If stricter null checks are required, set `content` column to NOT NULL.
- If you want timestamp fields as camelCase, rename columns to match or adjust the client.
- Remove unused columns if you want a minimal schema.

