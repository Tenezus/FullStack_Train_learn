import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> FetchData() async {
  final response = await http.get(Uri.parse("https://qf-2zbg.onrender.com/quotes"));
  if(response.statusCode == 200){
    var data = jsonDecode(response.body);
    print(data);
  } else {
    throw Exception("there is an error");
  }
}

void main(){
  FetchData();
}