import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:qface/auth/authentication.dart';
import 'package:qface/page/signUp.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  //auth service
  final authService = AuthService();
  
  //the input controller
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userNameController = TextEditingController();

  //open hive database
  final _qfaceBox = Hive.box('QfaceBox');

  //function for the login button if is pressed
  void onPressed() async{
    // take the values from input
    final email = _emailController.text;
    final password = _passwordController.text;
    final userName = _userNameController.text;

    //select user_photo directly from user table
    Future<String> fetchUserPhoto(email) async{
      try{final response = await Supabase.instance.client.from("users").select('user_photo').eq("username", userName).single(); return response['user_photo'] as String;}catch(e){return "user.png";}
    }

    //assigne the value of the string
    final user_photo = await fetchUserPhoto(email);

    //hive insertion
    _qfaceBox.put("username", userName);
    _qfaceBox.put("email", email);
    _qfaceBox.put("user_photo", user_photo);
    
    //try a login
    try{
      await authService.signInWithEmailPassword(email, password);
    }catch(e){
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("there was an error occured, please try again or create an account")));
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
        title: Center(child: Text("Hey :) welcome back smiley user", style: TextStyle(fontSize: 20),),),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Color(0xfff2f2f2),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          verticalDirection: VerticalDirection.down,
          children: [

            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: TextField(
                controller: _userNameController,
                decoration: InputDecoration(
                  focusColor: Colors.black,
                  label: Text("Pseudo"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Colors.black,
                    ),
                  ),
                  //hintText: "example@gmail.com",

                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  focusColor: Colors.black,
                  label: Text("Email"),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: Colors.black,
                      ),
                  ),
                  //hintText: "example@gmail.com",

                ),
              ),
            ),


            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  label: Text("Password"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Colors.black,

                    )
                  ),
                  //hintText: "Password ...",

                ),
              ),
            ),

            ElevatedButton(onPressed: onPressed, child: Text("Sign In"),),

            Padding(

                padding: EdgeInsets.symmetric(vertical: 20),
              child: Container(
                child: Center(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=> signUp())),
                    child: Text("Don't have an acoount? Let create one.", style: TextStyle(color: Colors.purpleAccent),),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
