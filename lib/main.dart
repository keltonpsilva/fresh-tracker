import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'features/welcome/wellcome-screen.dart';

void main() {
  // Initialize database factory for web
  // databaseFactory = databaseFactoryFfiWeb; // 👈 required
  if (kIsWeb) {
    // Use web-compatible database
    //databaseFactory = databaseFactoryWeb;
  } else {
    // Use FFI for desktop/mobile
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fresh Track',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}
