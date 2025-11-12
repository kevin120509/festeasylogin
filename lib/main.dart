import 'package:festeasy_app/app/app.dart';
import 'package:festeasy_app/bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mwldonzgeruhrsfirfop.supabase.co',
    anonKey:
        // The anonKey is intentionally longer than 80 characters.
        // ignore: lines_longer_than_80_chars
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im13bGRvbnpnZXJ1aHJzZmlyZm9wIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI5MTYwMzAsImV4cCI6MjA3ODQ5MjAzMH0.ZefZzLerTtke3rj3lD1DItLVbcBkUMBZ65p98Hk2H6w'
  );
  await bootstrap(() => const App());
}
