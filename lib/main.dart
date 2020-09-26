import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String input;
  String input2;
  List todos = List();

  createTodos() {
    DocumentReference documentReference =
        Firestore.instance.collection("MyTodos").document(input);
    /*DocumentReference documentReference2 =
        Firestore.instance.collection("MyTodos2").document(input2);*/

    Map<String, String> todos = {"todoTitle": input/*, "todoTitle2": input2*/};
    documentReference
        .setData(todos)
        .whenComplete(() => {print("$input created")});
  }

  deleteTodos(item) {
    DocumentReference documentReference =
        Firestore.instance.collection("MyTodos").document(item);
    documentReference.delete().whenComplete(() => print("deleted"));
  }

  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        print("çalıştı");
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        print("hata var");
      });
    }
  }

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrangeAccent[100],
          title: Text("Yapılacaklar Listesi"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.deepOrangeAccent[100],
          child: Icon(Icons.add),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Görev Ekle"),
                    content: Container(
                      height: 100,
                      child: Column(
                        children: [
                          TextField(
                            onChanged: (String value) {
                              input = value;
                            },
                          ),
                          /*Flexible(
                            child: TextField(
                              onChanged: (String value) {
                                input2 = value;
                              },
                            ),
                          ),*/
                        ],
                      ),
                    ),
                    actions: [
                      FlatButton(
                        child: Text("Ekle"),
                        onPressed: () {
                          createTodos();

                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                });
          },
        ),
        body: StreamBuilder(
          stream: Firestore.instance.collection("MyTodos").snapshots(),
          builder: (context, snapshots) {
            return ListView.builder(
              itemCount: snapshots.data.documents.length,
              itemBuilder: (context, index) {
                DocumentSnapshot documentSnapshot =
                    snapshots.data.documents[index];

                return Card(
                  elevation: 8,
                  margin: EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text(documentSnapshot.data()["todoTitle"]),
                    /*subtitle: Text(documentSnapshot.data()["todoTitle2"]),*/
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () {
                        setState(() {
                          deleteTodos(documentSnapshot.data()["todoTitle"]);
                        });
                      },
                    ),
                  ),
                );
              },
            );
          },
        ));
  }
}
