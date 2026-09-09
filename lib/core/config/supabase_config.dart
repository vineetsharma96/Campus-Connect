abstract final class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://plyhvnfhepqteiswylsk.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBseWh2bmZoZXBxdGVpc3d5bHNrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg4NTE1MDgsImV4cCI6MjEwNDQyNzUwOH0.zZm8789qcz3sBEZSAHU0kld-FA1WlXeZaUIPjn3IVfk',
  );
}
