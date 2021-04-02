import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sparkchat/constants.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';
import 'package:sparkchat/screens/Chat_Screen.dart';

class allusers extends StatefulWidget {
  static const String id = "allusers";

  String mobile;

  allusers({this.mobile});

  @override
  _allusersState createState() => _allusersState(mobile);
}

class _allusersState extends State<allusers> {
  String mobile;

  _allusersState(this.mobile);

  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInuser;

  List<Contact> _lcontacts;

  List<String> invitecontacts = [];
  List<String> phonecontacts = [];
  List<String> friendscontacts = [];
  List<String> friendsid = [];
  List<String> friendsname = [];

//  List<Contact> contacts = [];
  List<dynamic> friendList = [];
  List<String> friendname = [];
  var all, docsnap;

  List<String> duplicateitems=[];
  List<String> items=[];

  Contact contact;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    CircularProgressIndicator(
      backgroundColor: Colors.lightBlueAccent,
    );

    getPermissions();
    getCurrentUser();
  //  getFriendList();
    displayusers();
  }

  getPermissions() async {
    if (await Permission.contacts.request().isGranted) {
      getAllContacts();
    }
  }

  Future<void> displayusers() async {
    FirebaseFirestore.instance
        .collection('users')
        .document(user.uid)
        .get()
        .then((value) {
      setState(() {
        docsnap = value.data();
        duplicateitems = List.from(docsnap['friendsname'] as Iterable<dynamic>);
        items.addAll(duplicateitems);
      });
    });
  }

  /*
  Future<String> getFriendList() async {
    var firebaseUser = FirebaseAuth.instance.currentUser;

    FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid).get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        setState(() {
          friendList = documentSnapshot.data()['friends'];
          friendname = documentSnapshot.data()['friendsname'];
          //    all=documentSnapshot.data();
          print('Document dataaaaaaaaaaaaaaaaaa:' + friendList[0]);

          print(friendList.length);
        });
      } else {
        print('Document does not exist on the database');
      }
    });
  }
  */


  getAllContacts() async {
    final _contacts = await ContactsService.getContacts();

    //List<Contact> dcon=_contacts.toList();

    if(mounted) {
      setState(() {
        _contacts.forEach((myContact) {
          myContact.phones.forEach((phoneData) {
            String ele =
            phoneData.value.replaceAll("+91", "").replaceAll(" ", "");

            phonecontacts.add(ele);
            print(ele);
          });
        });

        Firestore.instance.collection("users").get().then((querySnapshot) {
          querySnapshot.docs.forEach((result) {
            String ele1 = result
                .data()["mobile"]
                .toString()
                .replaceAll("+91", "")
                .replaceAll(" ", "");
            String ele2 = result.data()["id"].toString();
            String ele3 = result.data()["name"].toString();

            if (phonecontacts.contains(ele1)) {
              friendscontacts.add(ele1);
              friendsid.add(ele2);
              friendsname.add(ele3);

              print("ffffffffffffffffffffffffffffffffffffffffffff");
              print(ele1);
              print(ele2);

              var firebaseUser = FirebaseAuth.instance.currentUser;

              Firestore.instance
                  .collection("users")
                  .doc(firebaseUser.uid)
                  .updateData({
                "friends": FieldValue.arrayUnion([ele2])
              });

              Firestore.instance
                  .collection("users")
                  .doc(firebaseUser.uid)
                  .updateData({
                "friendsname": FieldValue.arrayUnion([ele3])
              });

              Firestore.instance
                  .collection("users")
                  .doc(firebaseUser.uid)
                  .get()
                  .then((value) {
                print(value
                    .data()
                    .values);
              });
            }
          });
        });

/*
      mobilenumbers.forEach((element) {

        String result = element.toString().replaceAll(" ", "").replaceAll("(", "").replaceAll(")","").replaceAll("+91", "");

        if(phonecontacts.contains(result))
        {
          friendscontacts.add(result);
          print(result.toString());
        }
      });
*/
      });
    }
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInuser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  TextEditingController editingController = TextEditingController();


  void filterSearchResults(String query) {
    List<String> dummySearchList = List<String>();
    dummySearchList.addAll(duplicateitems);
    if(query.isNotEmpty) {
      List<String> dummyListData = List<String>();
      dummySearchList.forEach((item) {
        if(item.contains(query)) {
          dummyListData.add(item);
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(duplicateitems);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: docsnap != null && docsnap['friends'].length != null
            ? Container(
                padding: EdgeInsets.all(5),
                child: Column(
                  children: <Widget>[

                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TextField(
                            autofocus: true,
                            onChanged: (value) {
                              filterSearchResults(value);
                            },
                            controller: editingController,
                            decoration: InputDecoration(
                                hintText: "Search users",
                                fillColor: Colors.grey,
                                prefixIcon: Icon(Icons.search),
                                border: InputBorder.none),
                          ),
                        ),

                    FlatButton(
                      child: Row(
                        children: <Widget>[
                          CircleAvatar(
                            child: Icon(
                              Icons.group_add_outlined,
                              size: 25.0,
                            ),
                          ),
                          Text(
                            "  Create Group",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20.0,
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {},
                    ),

                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(items != null
                                ? '${items[index]}'
                                : 'default'),
                            subtitle: Text(docsnap != null
                                ? docsnap['mobile']
                                : 'default'),
                            leading: (docsnap['friends'].length > 0)
                                ? CircleAvatar(
                              backgroundImage:
                              AssetImage("images/profilepic.png"),
                              backgroundColor: Colors.transparent,
                            )
                                : Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                    child: Text("contact.initials()",
                                        style:
                                        TextStyle(color: Colors.white)),
                                    backgroundColor: Colors.transparent)),

                            onTap: (() {
                              Navigator.pushReplacement(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) => chatscreen(
                                            userid: docsnap['friends'][index],
                                            username: docsnap['friendsname']
                                                [index],
                                          )));

                            }),
                          );
                        },
                      ),
                    )
                  ],
                ),
              )
            : Container(),
      ),
    );
  }
}
