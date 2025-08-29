import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/authentication.dart';
import 'package:qface/service/database_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class signUp extends StatefulWidget {
  const signUp({super.key});

  @override
  State<signUp> createState() => _signUpState();
}

class _signUpState extends State<signUp> {
  //auth service
  final authService = AuthService();

  //the input controller
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _userNameController = TextEditingController();

  //open the qfacebox database
  final _qfaceBox = Hive.box("QfaceBox");


  //function for sign up
  void sign_up() async{
    final UserName = _userNameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPassword.text;
    var fileName = "user.png";

    //verify if the passwords match
    if(password != confirmPassword){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("the passwords doesn't match please try again")));
      return;
    }

    //trying sign up action with supabase //insert username
    try{
      await authService.signUpWithEmailPassword(email, password);
      Navigator.pop(context);
    } catch(e){
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("an error occured: $e")));
      }
    }
    //uploading data
    final database = Supabase.instance.client;
    //url example https://qxfmtqrnjdfiptrfpzsq.supabase.co/storage/v1/object/public/profil/uploads/1755293603569
    //upload profile picture
    if(_imageFile != null){
      isUploading = true;
      try{
        fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final path = "uploads/$fileName";
        //uploading data in the user table
        await database.from('users').insert({
          'username':'$UserName',
          'email': '$email',
          'user_photo':'$fileName'
        });

        //local database with finaly hive, no sqlite
        _qfaceBox.put('username', UserName);
        _qfaceBox.put('email', email);
        _qfaceBox.put('user_photo', fileName);

        //await DatabaseService().addUserInfo(UserName, email, fileName);

        await Supabase.instance.client.storage.from("profil").upload(path, _imageFile!);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ok, 200: $path")));
      }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("error : $e")));
      }finally{
        isUploading = false;
      }
    }
    isUploading = true;
  }

  //Ask permission to acces files
  Future<void> requestPermission() async{
    if(Platform.isAndroid){
      if(await Permission.photos.isDenied || await Permission.photos.isPermanentlyDenied){
        await Permission.photos.request();
      }
    }
  }

  //
  File? _imageFile;
  bool isUploading = false;

  //select an image
  Future<void> selectImage() async{
    try{
      if(Platform.isAndroid){
        await Permission.photos.request();
      }
      final ImagePicker selectedImage = ImagePicker();
      final XFile? image = await selectedImage.pickImage(source: ImageSource.gallery);
      if(image != null){
        setState(() {
          _imageFile = File(image.path);
        });
      }
    }catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("select an image")));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
        title: Text("Return to the login page", style: TextStyle(fontSize: 20),),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Color(0xfff2f2f2),
      ),

      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          child: Column(
            children: [

              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: TextField(
                  controller: _userNameController,
                  decoration: InputDecoration(
                    fillColor: Color(0xfff2f2f2),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Colors.black,
                        )
                    ),
                    label: Text("Pseudo"),
                    hintText: "exmaple: QQ29",
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Colors.black,
                        )
                    ),
                    label: Text("Email"),
                    hintText: "example@gmail.com",
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Colors.black,
                        )
                    ),
                    label: Text("Password"),
                    //hintText: "Password ...",
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: TextField(
                  controller: _confirmPassword,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Colors.black,
                        )
                    ),
                    label: Text("Confirm Password"),
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: (){
                    showModalBottomSheet(context: context, 
                        builder:(BuildContext context){
                          return Container(
                            height: 200,
                            color: Color(0xffffffff),
                            child: GestureDetector(
                              onTap: selectImage,
                              child: Center(child: Text("Select an Image from your galey"),),
                            ),
                          );
                        }
                    ); 
                  },
                  child: Text("Choose a profil picture")
              ),

              //add picture profil picture
              ElevatedButton(onPressed: ()=>{sign_up()/*, uploadSelectedImage()*/}, child: Text("Sign In"),),

            ],//children of the Column widget
          ),
        ),
      )
    );
  }
}