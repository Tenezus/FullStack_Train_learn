import 'package:qface/allPages.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

import '../page/login.dart';

class authStatus extends StatelessWidget {
  const authStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final session = snapshot.hasData? snapshot.data!.session : null;
          if(session != null){
            return allPages();
          }else{
            return login();
          }
        }
    );
  }
}
