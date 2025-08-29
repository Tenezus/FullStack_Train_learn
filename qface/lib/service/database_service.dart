import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DatabaseService{
  static Database? db;

  //create database Qface
  Future<Database> getDatabase() async{
    final dbDirPath =await getDatabasesPath();
    final dbPath = join(dbDirPath, "Qface.db");
    final dataBase = await openDatabase(
      dbPath,
      onCreate:(db, version){
        db.execute(''' CREATE TABLE user(username varchar(255), email(255), user_photo(255)), created_at timestamp default current_timestamp ''');
      },
      version: 1
    );
    return dataBase;
  }

  //search if database exists or not
  Future<Database> getDB() async{
    if(db!= null) return db!;
    db = await getDatabase();
    return db!;
  }

  //insert datas in the database:
  Future<void> addUserInfo(String username, String email, String user_photo) async{
    final db = await getDB();
    await db.insert(
        "user",
        {
          "username": username,
          "email": email,
          "user_photo": user_photo
        }
    );
  }

  //selct datas from the Qface database on the user table
  Future<Map<String, dynamic>?> getUserInfo(String email) async{
    final db = await getDB();
    final List<Map<String, dynamic>> row = await db.query('select * from user where email = $email');
    return row.first;
  }

}