import 'package:festeasy_app/app/app.dart';
import 'package:festeasy_app/bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mvmoxejnuyulsfkbdrrf.supabase.co',
    anonKey:
        // The anonKey is intentionally longer than 80 characters.
        // ignore: lines_longer_than_80_chars
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im12bW94ZWpudXl1bHNma2JkcnJmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI4ODExNDYsImV4cCI6MjA3ODQ1NzE0Nn0'
        '.5hCZXEZ924_UkmHr2LJ8KO1ef-_ULLseh78wbZDCi8Q',
  );
  await bootstrap(() => const App());
}
