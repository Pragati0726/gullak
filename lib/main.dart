import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gullak/utils/constants.dart';
import 'screens/auth_gate.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Declare the environment variables here:
  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://zyghbbxloslqmkiqqpjc.supabase.co',
  );
  const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_wHS0W7n6cnJulNQafU1pxA_vgB40zk8',
  );

  // 2. Pass them directly to initialize:
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const GullakApp());
}



// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Supabase.initialize(
//     url: 'https://zyghbbxloslqmkiqqpjc.supabase.co',
//     anonKey: 'sb_publishable_wHS0W7n6cnJulNQafU1pxA_vgB40zk8',
//   );

//   runApp(const GullakApp());
// }



// Convenient global helper to access the Supabase client anywhere in the project
final supabase = Supabase.instance.client;

class GullakApp extends StatelessWidget {
  const GullakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gullak',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepOrange,
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const AuthGate(),
    );
  }
}