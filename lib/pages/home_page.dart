
import 'package:flutter/material.dart';
import 'package:flutter_login_demo/services/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage>   with SingleTickerProviderStateMixin{
  signOut() async {
    try { 
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }
  String input ="";

  createTodos(){
      DocumentReference documentReference =
          Firestore.instance.collection("MyTodos").document(input);
      Map<String,String> todos ={
          "todoTitle" :input
      };
      documentReference.setData(todos).whenComplete((){
          print("$input created");
      });

  }

  deleteTodos(item){
    DocumentReference documentReference =
    Firestore.instance.collection("MyTodos").document(item);

    documentReference.delete().whenComplete((){
      print("$input deleted");
    });

  }
  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Color.fromRGBO(70, 148, 226, 1),
        title: new Text('Devbase'),
        actions: <Widget>[
          new FlatButton(
              child: new Text('Çıkış Yap',
                  style: new TextStyle(fontSize: 12.0, color: Colors.white)),
              onPressed: signOut),

        ],
      ),
      body: StreamBuilder(
        stream:  Firestore.instance.collection("MyTodos").snapshots(),
        builder: (context,snapshots){
            if (!snapshots.hasData){
              return Center(child:CircularProgressIndicator() ,);
            }
            else{
              return ListView.builder(
                  itemCount: snapshots.data.documents.length,
                  itemBuilder: (context,index){
                    DocumentSnapshot documentsnapshot = snapshots.data.documents[index];
                    return Dismissible(
                      onDismissed: (direction){
                        deleteTodos(documentsnapshot["todoTitle"]);
                      },
                      key: Key(documentsnapshot["todoTitle"]),
                      child: Card(
                        elevation: 4,
                        margin: EdgeInsets.all(5),

                        child: ListTile(
                          contentPadding: EdgeInsets.all(10),
                          title: Text(documentsnapshot["todoTitle"],style: TextStyle(color: Colors.black),),
                          trailing: IconButton(icon: Icon(Icons.delete,color: Colors.red,),onPressed: (){
                            deleteTodos(documentsnapshot["todoTitle"]);
                          },),
                        ),
                      ),
                    );
                  }
              );
            }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          showDialog(context: context,builder: (BuildContext context){
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(8)),
              title: Text("TODO Ekle",style: TextStyle(color: Colors.black),),
              content: TextField(
                onChanged: (String val){input=val;},
                style: TextStyle(color: Colors.black),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: (){
                    createTodos();
                      Navigator.of(context).pop();
                  },
                  child: Text("Ekle",style: TextStyle(color: Colors.black),),
                )
              ],
            );
          });
        },
      ),
    );
  }
}
