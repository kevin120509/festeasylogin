import 'package:festeasy_app/app/app.dart';
import 'package:festeasy_app/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
