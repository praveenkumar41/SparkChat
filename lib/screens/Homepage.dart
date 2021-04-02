import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sparkchat/constants.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sparkchat/screens/All_users.dart';
import 'dart:developer';
import 'package:sparkchat/screens/Chat_Screen.dart';
import 'package:sparkchat/screens/Profile_Page.dart';
import 'package:sparkchat/screens/welcome_screen.dart';

List<String> friendsnameatfront = [];
List<String> friendsidatfront = [];
List<String> friendsimageatfront = [];
List<String> emptylist = [];

class homepage extends StatefulWidget {
  static const String id = "Homepage";
  String mobile;

  homepage({this.mobile});

  @override
  _homepageState createState() => _homepageState(mobile);
}

class _homepageState extends State<homepage> {
  String mobile;

  _homepageState(this.mobile);

  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInuser;

  List<Contact> _lcontacts;

//  List<String> emptylist = [];

  List<String> invitecontacts = [];
  List<String> phonecontacts = [];
  List<String> friendscontacts = [];
  List<String> friendsid = [];
  List<String> friendsname = [];

//  List<Contact> contacts = [];
  List<String> friendList = [];
  List<String> friendname = [];
  var all, docsnap;

  List<String> chatsid = [];

  var idid = "", val;

  // List<String> friendsnameatfront = [];
  // List<String> friendsidatfront = [];

  Contact contact;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    getPermissions();
    getCurrentUser();
    //getFriendList();
    displayusers();
    setState(() {
      getfriendlistatfront();
  //    getfriendimageatfront();
    });
    //  copyCollection();
  }

  Future<void> getfriendlistatfront() async {
    await Firestore.instance
        .collection("users")
        .doc(user.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        if (documentSnapshot.data()['chatsid'] != null) {
          chatsid = List.from(
              documentSnapshot.data()['chatsid'] as Iterable<dynamic>);

          if (chatsid.length > 0) {
            friendsnameatfront = [];
            friendsidatfront = [];

            for (int i = 0; i < chatsid.length; i++) {
              Firestore.instance
                  .collection("messagesclone")
                  .doc(chatsid[i])
                  .collection("chats")
                  .doc(chatsid[i])
                  .get()
                  .then((DocumentSnapshot documentSnapshot11) {
                setState(() {
                  if (documentSnapshot11.exists) {
                    if (documentSnapshot11.data()['sender'] != null) {
                      var dd11 = documentSnapshot11.data()['sender'];

                      if (dd11 == "true") {
                        Firestore.instance
                            .collection("messages")
                            .doc(chatsid[i])
                            .collection("chats")
                            .limit(1)
                            .get()
                            .then((value) {
                          var dd = value.docs[0];

                          if (dd.data()['reciever'] == user.uid) {
                            setState(() {
                              friendsnameatfront.add(dd.data()['sendername']);
                              friendsidatfront.add(dd.data()['sender']);
                              friendsimageatfront.add(dd.data()['senderurl']);
                            });
                          } else if (dd.data()['sender'] == user.uid) {
                            setState(() {
                              friendsnameatfront.add(dd.data()['recievername']);
                              friendsidatfront.add(dd.data()['reciever']);
                              friendsimageatfront.add(dd.data()['recieverurl']);
                            });
                          }
                        });
                      }
                    }
                  }
                });
              });
            }
          }
        }
      }
    });
  }

/*
  Future<void> getfriendimageatfront() async {
    friendsimageatfront = [];

    for (int i = 0; i < friendsidatfront.length; i++) {
      await Firestore.instance
          .collection("users")
          .doc(friendsidatfront[i])
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          if (documentSnapshot.data()['photoUrl'] != null) {
            setState(() {
              friendsimageatfront.add(documentSnapshot.data()['photoUrl']);
              print(friendsimageatfront.length);
              print("pppppppppppppppppppppppppppppppppppppppppppppp");
            });
          }
        }
      });
    }
  }
  */

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
      });
    });
  }

  /*

  Future<String> getFriendList() async {
    var firebaseUser = FirebaseAuth.instance.currentUser;

    friendname=[];
    friendList=[];

    FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        setState(() {
          friendList = List.from(documentSnapshot.data()['friends'] as Iterable<dynamic>);
          friendname = List.from(documentSnapshot.data()['friendsname'] as Iterable<dynamic>);
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

/*
  Future<void> copyCollection() async{
    DocumentReference copyFrom = Firestore.instance.collection('messages').doc("14254743789").collection("chats").doc("2ubCftVuSitt1Dltm6CF");
    DocumentReference copyTo = Firestore.instance.collection('sellFeed').doc('0001').collection("chats").doc("ffffffffffffffff");

    copyFrom.get().then((value) => {
      copyTo.setData(Map.fromEntries(value.data().entries))
    });
  }
*/

  getAllContacts() async {
    final _contacts = await ContactsService.getContacts();

    //List<Contact> dcon=_contacts.toList();

    setState(() {
      //    contacts=_lcontacts;

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

/*
            var result11 = Firestore.instance
                .collection("users").doc('')
                .get();
            result11.docs.forEach((res) {
              print(res.data());
            });
*/
            Firestore.instance
                .collection("users")
                .doc(firebaseUser.uid)
                .get()
                .then((value) {
              print(value.data().values);
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

  @override
  Widget build(BuildContext context) {
    const color = const Color(0xFF1DA1F2);

    return WillPopScope(
      onWillPop: _onBackpressed,
      child: Scaffold(
        appBar: AppBar(
          leading: docsnap['photoUrl'] != null
              ? Padding(
               padding: EdgeInsets.only(left: 5.0),

               child: GestureDetector(
                 onTap: (){
                   Navigator.pushNamed(context, profilepage.id);
                 },
                 child: CachedNetworkImage(
                      imageUrl: docsnap['photoUrl'],
                      imageBuilder: (context, imageProvider) => Container(
                        width: 35.0,
                        height: 35.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                      placeholder: (context, url) => Container(
                        child: CircularProgressIndicator(
                          strokeWidth: 0.4,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.transparent),
                        ),
                        width: 35.0,
                        height: 35.0,
                        padding: EdgeInsets.all(0.0),
                        decoration: new BoxDecoration(
                          color: new Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.all(
                            Radius.circular(50.0),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.account_circle_sharp,size: 35.0,),
                    ),
               ),
              )
              : Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: InkWell(
                    customBorder: new CircleBorder(),
                    onTap: () {
                      Navigator.pushNamed(context, profilepage.id);
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.black26,
                      radius: 18.0,
                      child: Padding(
                        padding: EdgeInsets.all(0.0),
                        child: Icon(
                          Icons.person,
                          color: Colors.black54,
                          size: 21.0,
                        ),
                      ),
                    ),
                  ),
                ),
          leadingWidth: 35.0,
          titleSpacing: 10.0,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            Container(
              padding: const EdgeInsets.all(0.0),
              child: InkWell(
                customBorder: new CircleBorder(),
                // highlightColor: Colors.grey,
                onTap: () {},
                child: CircleAvatar(
                  backgroundColor: Colors.black26,
                  radius: 17.0,
                  child: IconButton(
                      //    highlightColor: Colors.grey,
                      icon: Icon(
                        Icons.search,
                        color: Colors.black54,
                        size: 21.0,
                      ),
                      onPressed: () {
                        showSearch(context: context, delegate: Datasearch());
                      }),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(10.0),
              child: InkWell(
                customBorder: new CircleBorder(),
                onTap: () {},
                child: CircleAvatar(
                  backgroundColor: Colors.black26,
                  radius: 17.0,
                  child: Padding(
                    padding: EdgeInsets.only(right: 7.0),
                    child: IconButton(
                        // highlightColor: Colors.grey,
                        icon: Icon(
                          Icons.person_add,
                          color: Colors.black54,
                          size: 21.0,
                        ),
                        onPressed: () {
                          _auth.signOut();
                          Navigator.pushReplacementNamed(context, WelcomeScreen.id);
                        }),
                  ),
                ),
              ),
            )
          ],
          title: Text(
            'SparkChat',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
        ),
        body: friendsnameatfront != null && friendsnameatfront.length != 0
            ? Container(
                padding: EdgeInsets.all(5),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: friendsidatfront.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(friendsnameatfront!=null
                                ? friendsnameatfront[index]
                                : 'default'),
                            subtitle: Text(docsnap['lastmessage']!=null
                                ? docsnap['lastmessage']
                                : 'start your conversation'),
                            leading: (friendsimageatfront.length != 0)
                                ? GestureDetector(
                                  onTap: (){

                                  },
                                  child: CachedNetworkImage(
                                        imageUrl: friendsimageatfront[index],
                                        imageBuilder: (context, imageProvider) =>
                                            Container(
                                          width: 40.0,
                                          height: 40.0,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover),
                                          ),
                                        ),
                                        placeholder: (context, url) =>
                                            CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.account_circle_sharp,size: 40.0,),

                                    ),
                                )
                                : Icon(
                                    Icons.account_circle,
                                    size: 40.0,
                                    color: Colors.grey,
                                  ),
                            onTap: (() {
                              Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) => chatscreen(
                                            userid: friendsidatfront[index],
                                            username: friendsnameatfront[index],
                                            imgurl: friendsimageatfront[index],
                                          )));
                            }),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            : Container(),

        /*        ? Container(
                padding: EdgeInsets.all(5),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: docsnap['friends'].length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(docsnap != null
                                ? docsnap['friendsname'][index]
                                : 'default'),
                            subtitle: Text(docsnap != null
                                ? docsnap['friends'][index]
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
                              Navigator.push(
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
*/
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.chat_outlined),
          onPressed: () {
            Navigator.pushNamed(context, allusers.id);
          },
        ),
      ),
    );
  }

  Future<bool> _onBackpressed() async {
    Navigator.pop(context, true);
    return true;
  }
}

class Datasearch extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {}

  @override
  Widget buildSuggestions(BuildContext context) {
    emptylist = [];

    final suggestionlist = query.isEmpty
        ? emptylist
        : friendsnameatfront
            .where((element) => element.startsWith(query))
            .toList();

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        onTap: () {
//        showResults(context);

          Navigator.pushReplacement(
              context,
              new MaterialPageRoute(
                  builder: (context) => chatscreen(
                        userid: friendsidatfront[index],
                        username: friendsnameatfront[index],
                      )));
        },
        leading: (friendsimageatfront.length > 0)
            ? GestureDetector(
              onTap: (){},
              child: CachedNetworkImage(
          imageUrl: friendsimageatfront[index],
          imageBuilder: (context, imageProvider) =>
                Container(
                  width: 37.0,
                  height: 37.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover),
                  ),
                ),
          placeholder: (context, url) =>
                CircularProgressIndicator(),
          errorWidget: (context, url, error) =>
                Icon(Icons.account_circle_sharp),

        ),
            )
            : Icon(
          Icons.account_circle,
          size: 37.0,
          color: Colors.grey,
        ),
        title: RichText(
            text: TextSpan(
          text: suggestionlist[index]!=null ? suggestionlist[index].substring(0, query.length):'default',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
          children: [
            TextSpan(
                text: suggestionlist[index].substring(query.length),
                style: TextStyle(color: Colors.grey)),
          ],
        )),
        subtitle: Text(
            friendsidatfront.length > 0 ? friendsidatfront[index] : 'default'),
      ),
      itemCount: suggestionlist.length,
    );
  }
}

/*
class Listdisplay extends StatelessWidget {

  Listdisplay(this.suggestionlist,this.query, this.emptylist);

  List<String> suggestionlist,emptylist;
  String query;

  @override
  Widget build(BuildContext context) {

    return ListView.builder(itemBuilder: (context,index)=> ListTile(
      onTap: (){
//        showResults(context);

        Navigator.pushReplacement(
            context,
            new MaterialPageRoute(
                builder: (context) => chatscreen(
                  userid: friendsidatfront[index],
                  username: friendsnameatfront[index],
                )));


      },

      leading: (friendsnameatfront.length > 0)
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
      title: RichText(text:TextSpan(
        text: suggestionlist[index].substring(0,query.length),
        style:TextStyle(
          color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20.0,
        ),
        children: [
          TextSpan(
              text: suggestionlist[index].substring(query.length),
              style: TextStyle(color: Colors.grey)
          ),
        ],
      )),
      subtitle: Text(friendsidatfront != null
          ? friendsidatfront[index]
          : 'default'),
    ),
      itemCount: suggestionlist.length,
    );
  }
}
*/
