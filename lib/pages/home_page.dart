
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_demo/services/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_login_demo/services/Todo.dart';


class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.logoutCallback,this.task})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  String task;


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
  String deger = "";

  final formKey =GlobalKey<FormState>();

  var selecteduser;
  var token;
  @override

  void setState(fn) {
    HomePage().task=deger;
    super.setState(fn);
  }
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

@override
  void initState() {
  _firebaseMessaging.getToken().then((deviceToken){
    token = deviceToken;
  });
  _firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> response) async {
        print("onMessage: $response");
    },
    onLaunch: (Map<String, dynamic> response) async {
      print("onLaunch: $response");
    },
    onResume: (Map<String, dynamic> response) async {
      print("onResume: $response");
    },
  );
    // TODO: implement initState
    super.initState();
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
      body:StreamBuilder<QuerySnapshot>(
            stream:  Firestore.instance.collection("Tasks").snapshots(),

            builder: (context,snapshots){

              if (!snapshots.hasData){

                return Center(child:CircularProgressIndicator() ,);
              }
              else{
                return ListView.builder(
                    itemCount: snapshots.data.documents.length,
                    itemBuilder: (context,index){
                      DocumentSnapshot documentsnapshot = snapshots.data.documents[index];
                      if(widget.userId == documentsnapshot["Who"]) {
                        return Dismissible(
                          onDismissed: (direction){
                            Todo().deleteTodos(documentsnapshot["todoTitle"]);
                          },
                          key: Key(documentsnapshot["todoTitle"]),
                          child: Card(
                            elevation: 4,
                            margin: EdgeInsets.all(5),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(10),
                              title: Text(documentsnapshot["todoTitle"],style: TextStyle(color: Colors.black),),
                              subtitle: Text(documentsnapshot["Who"],style: TextStyle(color: Colors.black),),
                              trailing: IconButton(icon: Icon(Icons.delete,color: Colors.red,),onPressed: (){

                                Todo().deleteTodos(documentsnapshot["todoTitle"]);

                              },),
                            ),
                          ),
                        );
                      }
                      else{
                        return Text("Görevin Yok");
                      }
                    }
                );
              }
            },
          ),


      floatingActionButton: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: (){
                showDialog(context: context,builder: (BuildContext context){
                  return AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(8)),
                    title: Text("TODO Ekle",style: TextStyle(color: Colors.black),),
                    content: TextField(
                      onChanged: (String val){
                        deger=val;
                      },
                      style: TextStyle(color: Colors.black),
                    ),
                    actions: <Widget>[

                      FlatButton(
                        onPressed: (){
                          Todo().createTodos(deger,selecteduser);

                          Navigator.of(context).pop();
                        },
                        child: Text("Ekle",style: TextStyle(color: Colors.black),),
                      ),
                    ],
                  );
                });
              },
            ),
          ),

          Align(
            alignment: Alignment.centerRight,

            child: Container(
              margin: EdgeInsets.only(top: 480.0),
              child: FloatingActionButton(

                child: Icon(Icons.new_releases),
                onPressed: (){
                  showDialog(context: context,builder: (BuildContext context){
                    return AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(8)),
                      title: Text("Görev Ata",style: TextStyle(color: Colors.black),),
                      content:Form(
                        key:formKey,
                        child: Column(
                          children: <Widget>[

                            StreamBuilder<QuerySnapshot>(
                              stream:Firestore.instance.collection("users").snapshots(),
                              builder: (context,snapshot){
                                if(!snapshot.hasData){
                                 return Text("Loading");
                                }
                                else{
                                  List<DropdownMenuItem> users=[];
                                  for(int i =0;i<snapshot.data.documents.length;i++){
                                    DocumentSnapshot snap = snapshot.data.documents[i];
                                    users.add(
                                      DropdownMenuItem(
                                        child: Text(
                                            snap.documentID,
                                          style: TextStyle(color: Colors.black,fontSize: 12.0),
                                        ),
                                        value: "${snap.documentID}",

                                      )
                                    );
                                  }
                                  return DropdownButton(
                                    items: users,
                                    onChanged : (a){
                                      setState(() {
                                        selecteduser=a;
                                      });
                                    },
                                    hint: Text("Kişi Seç",style: TextStyle(color: Colors.black),),
                                    value: selecteduser,
                                    isExpanded: false,

                                  );

                              }
                              },
                            ),


                            TextField(
                              onChanged: (String val){
                                deger=val;
                              },
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                  hintText: "Görev"
                              ),
                            ),
                          ],
                        ),
                      ),

                      actions: <Widget>[
                        FlatButton(
                          onPressed: (){

                            setState(() {
                                print("Tokenn " + token);
                                Todo().createTask(deger,selecteduser,token,selecteduser);
                            });
                            Navigator.of(context).pop();
                          },
                          child: Text("Görev Ver",style: TextStyle(color: Colors.black),),
                        ),

                      ],
                    );
                  });
                },
              ),
            )
          )

        ],
      )
    );
  }
}

