import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:http/http.dart' as http;
import 'package:qface/auth/authentication.dart';

//data model
//id, content, author, created_at, like
class Post{
  final int id;
  final String content;
  final String author;
  final String created_at;
  final int like;
  final String user_photo ;
  Post({required this.id, required this.content,required this.author, required this.created_at, required this.like, required this.user_photo});
  factory Post.fromJson(Map<String, dynamic> json){
    return Post(
        id: json['Id'],
        content: json['Content'],
        author: json['Author'],
        created_at: json['Created_at'],
        like: json['Like'],
        user_photo: json['User_photo']
    );
  }
}

//the function to fetch datas from the API
Future<List<Post>> BestQuotes() async{
  final respone = await http.get(Uri.parse("https://qf-h0y3.onrender.com/5best"));
  if(respone.statusCode == 200){
    final List<dynamic> jsonResponse = jsonDecode(respone.body);
    return jsonResponse.map((data) => Post.fromJson(data)).toList();
  } else throw Exception("Failed to load Quotes");
}



class settings extends StatefulWidget {
  const settings({super.key});

  @override
  State<settings> createState() => _settingsState();
}

class _settingsState extends State<settings> {
  final authService = AuthService();
  void SignOut() async{
    await authService.signOut();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xfff2f2f2),
      body: FutureBuilder<List<Post>>(
          future: BestQuotes(),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(child: CircularProgressIndicator(color: Colors.blue,),);
            }else if(snapshot.hasError){
              return Center(child: Text("Error ${snapshot.error}"),);
            }else if(snapshot.hasData){
              final posts = snapshot.data!;
              return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index){
                    final post = posts[index];
                    return Card(

                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        color: Color(0xffffffff),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: ()=>{
                                      showDialog(
                                          context: context,
                                          builder: (context)=>AlertDialog(
                                            backgroundColor: Color(0xfff2f2f2),
                                            content: Image.network("https://qxfmtqrnjdfiptrfpzsq.supabase.co/storage/v1/object/public/profil/uploads/"+post.user_photo),
                                          )
                                      )
                                    },
                                    child: ProfilePicture(
                                      name: post.author,
                                      radius: 25,
                                      fontsize: 21,
                                      img: "https://qxfmtqrnjdfiptrfpzsq.supabase.co/storage/v1/object/public/profil/uploads/"+post.user_photo,
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Text(post.author, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),),
                                ],
                              ),
                              SizedBox(height: 20,),
                              Text('"'+post.content+'"', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),),
                              SizedBox(height: 20,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: ()=>{
                                      showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context){
                                            return SizedBox(
                                              height: 50,
                                              child: Text("Comment bientot disponible"),
                                            );
                                          }
                                      )
                                    },
                                    child: Container(
                                      child: Image.asset("icons_Images/chat.png", width: 25, height: 25,),
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      children: [
                                        Text(post.like.toString()),
                                        Image.asset("icons_Images/love.png", width: 25, height: 25,),

                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Text(post.created_at),
                            ],
                          ),
                        )
                    );
                  }
              );
            } else {
              return Center(child: Text("No Posts found"),);
            }
          }
      ),
    );
  }
}
