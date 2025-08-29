import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:qface/auth/authStatus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  //supabase initialisation
  await Supabase.initialize(
      url: "https://qxfmtqrnjdfiptrfpzsq.supabase.co",
      anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF4Zm10cXJuamRmaXB0cmZwenNxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQxNzc5MDEsImV4cCI6MjA2OTc1MzkwMX0.29C3HfFi8O3S9Z6PE1htx1nkg7kwI6iWSsB1fHjvVhA"
  );

  //initialize hive database
  await Hive.initFlutter();
  //create new box called QfaceBox
  await Hive.openBox("QfaceBox");

  //func to run flutter class MyApp
  runApp(Qf_());
}


class Qf_ extends StatefulWidget {
  const Qf_({super.key});

  @override
  State<Qf_> createState() => _MyAppState();
}

class _MyAppState extends State<Qf_> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: authStatus(),
    );
  }
}