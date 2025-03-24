import 'package:easy_lib/homepage.dart';
import 'package:easy_lib/kartuanggota.dart';
import 'package:easy_lib/searchpage.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyLib',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: HomePage(),
      initialRoute: '/', // Nanti ganti ke login
      routes: {
        '/home': (context) => HomePage(),
        '/search': (context) => SearchScreen(),
        '/kartuanggota': (context) => KartuanggotaPage(),
      },
    );
  }
}
