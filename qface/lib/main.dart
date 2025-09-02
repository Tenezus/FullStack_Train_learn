import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:qface/auth/authStatus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  //supabase initialisation
  await Supabase.initialize(
      url: "Your supabase project's url",
      anonKey: "Your project's anonKey"
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
