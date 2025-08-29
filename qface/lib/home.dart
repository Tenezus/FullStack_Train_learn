import 'dart:convert';
import'package:hive_ce/hive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:http/http.dart' as http;


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
Future<List<Post>> AllQuotes() async{
  final respone = await http.get(Uri.parse("https://qf-h0y3.onrender.com/quotes"));
  if(respone.statusCode == 200){
    final List<dynamic> jsonResponse = jsonDecode(respone.body);
    return jsonResponse.map((data) => Post.fromJson(data)).toList();
  } else throw Exception("Failed to load Quotes");
}



class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}


class _homeState extends State<home> {

  @override
  Widget build(BuildContext context) {

    //la fonction to poste the quotes
    Future<void> PostQuote(String username, String content,String user_photo) async{//send the username, the quote, user_photo
      final response = await http.post(
          Uri.parse("https://qf-h0y3.onrender.com/postQuote"),
          headers: <String, String>{
            'Content-Type':'application/json; charset=UTF-8'
          },
          body: jsonEncode(<String, String>{
            'content': content,
            'author': username,
            'user_photo': user_photo,
          })
      );
      if(response.statusCode == 201){
        //Navigator.pop(context);
        // showDialog(context: context, builder: (context)=>AlertDialog(
        //   backgroundColor: Color(0xffffffff),
        //   content: Text("votre citation a ete poster avec succes", style: TextStyle(color: Colors.black),),
        //   actions: [
        //     TextButton(onPressed: ()=>{Navigator.pop(context)}, child: Text("Ok")),
        //   ],
        // )); mince la partie la c'est pas bon, Merci jetbrains
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Votre a bien ete poster")));
      }else{
        print('Status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception("Une erreur s'est produit, veuillez reessayer");
      }
    }

    //user info:final _qfacebox = Hive.box("QfaceBox");
    final _qfacebox = Hive.box("QfaceBox");
    final username = _qfacebox.get('username');
    final user_photo = _qfacebox.get('user_photo');
    final contentController = TextEditingController();

    //
    //if(){}
    //open dialog
    void DialogPost() async{
      showDialog(
        // barrierColor: Color(0xffffffff),
          context: context,
          builder: (context)=>AlertDialog(
            backgroundColor: Color(0xffffffff),
            title: Text("Poster une citation"),
            content: TextField(
              controller: contentController,
              minLines: 4,
              maxLines: 30,
              decoration: InputDecoration(
                hintText: "Ecriver votre citation ici ...",
                fillColor: Color(0xfff2f2f2),
                border: OutlineInputBorder(
                  gapPadding: 1,
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Color(0xff000000)),
                )
              ),
            ),
            actions: [
              //conversion et poste des donnees
              TextButton(onPressed: ()=>{Navigator.pop(context)}, child: Text("Retour", style: TextStyle(color: Colors.red),)),
              TextButton(onPressed: ()=>{PostQuote(username, contentController.text, user_photo),Navigator.pop(context)}, child: Text("Poster", style: TextStyle(color: Colors.blue,),))
            ],
          )
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: DialogPost, child: Icon(Icons.add, color: Color(0xff000000),), backgroundColor: Colors.white,),
      backgroundColor: Color(0xfff2f2f2),
      body: FutureBuilder<List<Post>>(
          future: AllQuotes(),
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
                                            child: Column(
                                              children: [
                                                Expanded(child: Text("commentaires bientot dispo")),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                                  child: TextField(
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Color(0xfff2f2f2f2),
                                                      border: InputBorder.none,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
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
