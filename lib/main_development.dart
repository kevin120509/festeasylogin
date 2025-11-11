import 'package:festeasy_app/app/app.dart';
import 'package:festeasy_app/bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://waclnfeejhtbnsvuvunp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndhY2xuZmVlamh0Ym5zdnV2dW5wIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI4NjkyMDIsImV4cCI6MjA3ODQ0NTIwMn0.GN47kxutx8EfPVedzFbYe9X7ioJliESbb_OaAGQ0Awo',
  );

  await bootstrap(() => const App());
}
