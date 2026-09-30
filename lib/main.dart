import 'package:flutter/material.dart';
import 'package:gullak/screens/home_screen.dart';
import 'package:gullak/utils/constants.dart';

void main() => runApp(const GullakApp());

class GullakApp extends StatelessWidget {
  const GullakApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gullak',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.deepOrange,
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: const HomeScreen(),
      );
}