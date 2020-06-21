import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_login_demo/pages/home_page.dart';
import 'package:flutter_login_demo/services/authentication.dart';



class Todo{
       createTodos(input,userid){
         DocumentReference documentReference =
         Firestore.instance.collection("MyTodos").document(input);
         Map<String,String> todos ={
           "todoTitle" :input,
            "Who":userid

         };
         documentReference.setData(todos).whenComplete((){
           print("created");
         });
      }
       createTask(input,selecteduser,token,userid){
         DocumentReference documentReference =
         Firestore.instance.collection("Tasks").document(input);
         Map<String,String> todos ={
           "todoTitle" :input,
           "Who":selecteduser,
           "Token":token,
           "UserId" :userid
         };
         documentReference.setData(todos).whenComplete((){
           print("created");
         });
       }
       deleteTodos(input){
         DocumentReference documentReference =
         Firestore.instance.collection("MyTodos").document(input);

         documentReference.delete().whenComplete((){
           print("$input deleted");
         });

       }
}
