import 'package:flutter/material.dart';
import 'package:qface/page/myQuotes.dart';
import 'package:qface/settings.dart';
import 'package:qface/auth/authentication.dart';
import 'createQuote.dart';
import 'home.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:hive_ce/hive.dart';

class allPages extends StatefulWidget {
  const allPages({super.key});

  @override
  State<allPages> createState() => _allPagesState();
}

class _allPagesState extends State<allPages> {
  //supabase service
  final authService = AuthService();

  //get user inf in the database QfaceBox
  final _qfaceBox = Hive.box("QfaceBox");

  //fonction pour se deconnecter
  void SignOut() async{
    Navigator.pop(context);
    await _qfaceBox.clear();
    await authService.signOut();
  }

  @override
  Widget build(BuildContext context) {

    //get the email
    final email = authService.getCurrentUserEmail().toString();

    //var name, mail, user_photo = "";
    final username = _qfaceBox.get('username');
    final user_photo = _qfaceBox.get('user_photo');

    return DefaultTabController(

      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool InnerBoxIsScrolled){
            return<Widget>[
              new SliverAppBar(
                title: Text("Qface"),
                actions: [
                  GestureDetector(
                    onTap: ()=>{
                      showDialog(
                          context: context,
                          builder: (context)=>AlertDialog(
                            backgroundColor: Color(0xfff2f2f2),
                            title: Text("Parametres rapides"),
                            content: Container(
                              child: Column(
                                children: [
                                  
                                  Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                        color: Color(0xfff2f2f2),
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: ()=>{showDialog(context: context, builder: (context)=>AlertDialog(
                                            content: Image.network("https://YourSupabaseUrl/storage/v1/object/public/profil/uploads/"+user_photo),
                                          ))},
                                          child: ProfilePicture(
                                            name: username,
                                            fontsize: 12,
                                            radius: 50,
                                            img: "https://YourSupabaseUrl/storage/v1/object/public/profil/uploads/"+user_photo,
                                          ),
                                        ),

                                        //mini separateur horizontal
                                        SizedBox(width: 10,),

                                        //nom et email utilisateur
                                        Column(
                                          children: [
                                            Text(username, style: TextStyle(fontSize: 14),),
                                            Text(email, style: TextStyle(fontSize: 14),),
                                          ],
                                        ),
                                        //
                                        //Align(alignment: Alignment.centerRight, child: Image.asset("icons_Images/chevron.png", height: 75, width: 75,),)
                                      ],
                                    ),
                                  ),
                                  
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 0),
                                    child: GestureDetector(
                                      onTap: ()=>{
                                        Navigator.pop(context),
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>myQuotes()))
                                      },
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: Color(0xfff2f2f2)
                                        ),
                                        child: Center(
                                          child: Text("Historique de Postes>"),
                                        ),
                                      ),
                                    ),
                                  ),

                                  //ligne horizontale grise
                                  Divider(
                                    height: 2,
                                    thickness: 1,
                                    color: Color(0xfff2f2f2),
                                  ),

                                  //boutton se deconnecter
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                    child: GestureDetector(
                                      onTap: SignOut,
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [

                                              Text("Se deconnecter", style: TextStyle(color: Colors.white),),
                                              SizedBox(width: 10,),
                                              Image.asset("icons_Images/exit.png", height: 25, width: 25,)
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                                    child: GestureDetector(
                                      onTap: ()=>{},
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                            color: Color(0xfff2f2f2),
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        child: Center(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text("Supprimer mon compte", style: TextStyle(color: Colors.red),),
                                              SizedBox(width: 10,),
                                              Image.asset("icons_Images/bin.png", height: 25, width: 25,)
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  Align(alignment: Alignment.bottomCenter, child: Text("From Tenezus Ztools", ),)
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(onPressed: (){Navigator.pop(context);}, child: Text("Fermer", style: TextStyle(color: Colors.black),)),
                            ],
                          )
                      )
                    },
                    child: Icon(Icons.settings),
                  ),
                  SizedBox(width: 10,),
                ],

                pinned: true,
                floating: true,
                backgroundColor: Color(0xffffffff),
                elevation: 0,
                scrolledUnderElevation: 0,

                bottom: TabBar(
                  //controller: _controller,
                  indicatorColor: Colors.black,
                  indicatorSize: TabBarIndicatorSize.label,
                  isScrollable: false,
                  tabs: [
                    Image.asset("icons_Images/home.png", width: 25, height: 25,),
                    //Tab(icon: Icon(Icons.add, color: Colors.grey.shade500),),
                    Image.asset("icons_Images/award.png", width: 22.5, height: 22.5,),
                  ],
                ),

              )
            ];
          },

          body: TabBarView(
            //controller: _controller,
            children: <Widget>[
              home(),
              //createQuote(),
              settings(),
            ],
          ),
        ),
      ),
    );
  }
}
