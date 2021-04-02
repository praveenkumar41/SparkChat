import 'dart:async';
import 'dart:convert';
import 'dart:io' as Io;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sparkchat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter, SystemChannels, rootBundle;
import 'full_photo.dart';
import 'package:stream_transform/stream_transform.dart';

final user = FirebaseAuth.instance.currentUser;
String bothunique = "";
//ScrollController _controller = new ScrollController();

class chatscreen extends StatefulWidget {
  static const String id = "Chat_Screen";

  String userid, username,imgurl;

  chatscreen({this.userid, this.username,this.imgurl});

  @override
  _chatscreenState createState() => _chatscreenState(userid, username,imgurl);
}

class _chatscreenState extends State<chatscreen> {



  String userid, username, messagetext, uniqueid, currentuniqueid, cid = "",imgurl,useridurl,currentidurl,currentusername,parid;
  String lastmsg = "";
  String name = "";
  int maxLength =23;

  final firestore = Firestore.instance;

  var idid = "", val,docsnap,count1,count2;

  bool isEmojiVisible = false;
  bool isKeyboardVisible = false;
  final focusNode = FocusNode();

  StreamController<String> streamController = StreamController();

  var texts;
  SharedPreferences prefs;
  String imageurl = "";
  bool isLoading = false;
  Timer debounce;

  FirebaseUser loggedInuser;

  final _auth = FirebaseAuth.instance;

  TextEditingController chatpad = TextEditingController();

  final ScrollController listScrollController = ScrollController();

  _chatscreenState(this.userid, this.username, this.imgurl);


  /*
  Future<void> c1() async {
    FirebaseFirestore.instance
        .collection('messagesclone').doc(getbothuniqueid()).collection("lastmessage").doc(getbothuniqueid()).get()
        .then((value6) {
      setState(() {
        count1 = value6.data();
      });
    });
  }

  Future<void> c2() async {
    FirebaseFirestore.instance
        .collection('messages').doc(getbothuniqueid()).collection("chats").doc(count1['docid']).get()
        .then((value2) {
      setState(() {
        count2 = value2.data();
      });

      if (count2['reciever'] == user.uid)
      {
        if (listScrollController.offset >= listScrollController.position.maxScrollExtent && !listScrollController.position.outOfRange)
        {
          print("reach the bottom");
          setState(() {

            Firestore.instance
                .collection('messages')
                .doc(getbothuniqueid())
                .collection("chats")
                .doc(count1['docid'])
                .update({
              'isseen': true,
            });
          });
        }
      }

    });
  }
*/

  /*
  Future<void> seenmessages() async{
    await Firestore.instance.collection('messagesclone').doc(getbothuniqueid()).collection("lastmessage").doc(getbothuniqueid()).get().then((value) {

      Firestore.instance.collection('messages').doc(getbothuniqueid()).collection("chats").doc(value.data()['docid']).get().then((value12) {

        setState(() {

          if (value12.data()['reciever'] == user.uid)
          {

            if (listScrollController.offset >= listScrollController.position.maxScrollExtent && !listScrollController.position.outOfRange)
            {
              print("reach the bottom");
              setState(() {

                Firestore.instance
                    .collection('messages')
                    .doc(getbothuniqueid())
                    .collection("chats")
                    .doc(value.data()['docid'])
                    .update({
                  'isseen': true,
                });

              });
            }
          }
        });
      });
    });
  }

  */




  Future<void> readmessages()
  {
    Firestore.instance.collection('messagesclone').doc(getbothuniqueid()).collection("lastmessage").doc(getbothuniqueid()).get().then((value){

      Firestore.instance.collection('messages').doc(getbothuniqueid()).collection("chats").doc(value.data()['docid']).get().then((value11){

        if(value11.data()['reciever'] == user.uid)
        {
          Firestore.instance
              .collection('messages')
              .doc(getbothuniqueid())
              .collection("chats")
              .doc(value.data()['docid'])
              .update({
            'isseen': true,
          });
        }
      });
    });
  }


  _scrollListener() {

    /*
    if(listScrollController.offset >= listScrollController.position.maxScrollExtent && !listScrollController.position.outOfRange) {
      print("reach the bottom");
      setState(() {
        print("reach the bottom");
      });
    }
    */

    if (listScrollController.offset <= listScrollController.position.minScrollExtent && !listScrollController.position.outOfRange)
    {
      print("reach the top");
      setState(() {
        print("reach the top");

      });
    }

  }

  List<MessageBubble> messageBubbles = [];

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

  String getbothuniqueid() {
    Firestore.instance.collection("users").doc(user.uid).get().then((event) {
      Firestore.instance.collection("users").doc(userid).get().then((event11) {
        if(mounted)
        {
            setState(() {
              uniqueid = event11.data()['uniqueid'];
              currentuniqueid = event.data()['uniqueid'];
              useridurl=event11.data()['photoUrl'];
              currentidurl=event.data()['photoUrl'];
              currentusername=event.data()['name'];
            });
        }

        try {
          var id1 = int.tryParse(currentuniqueid);
          var id2 = int.tryParse(uniqueid);

          print(id1.toString());
          print(id2.toString());

          var chattingid = id1 + id2;

          if (chattingid != null) {
            cid = chattingid.toString();
            print(cid);
            print("ggggggggggggggggggggggggggggggggggggggggggggggggggggg");
          }
        } on FormatException {
          print('Format error!');
        }
      });
  });

    if (cid != "") {
      return cid;
    }
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    imageurl = prefs.getString('imageurl') ?? '';
    // Force refresh input
    setState(() {
      if (!mounted) {
        return;
      }
    });
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

  @override
  void dispose() {
    chatpad.dispose();
    super.dispose();
  }


  @override
  void initState() {
    getCurrentUser();
    displayusers();
    readmessages();

    chatpad.addListener(() {

      if(chatpad.text=="")
      {

        Firestore.instance
            .collection('messagesclone')
            .doc(getbothuniqueid())
            .collection("lastmessage")
            .doc(getbothuniqueid())
            .update({
          'sender_typing':false,
          'reciever_typing':false,
        });
      }
      else
      {
        Firestore.instance
            .collection('messagesclone')
            .doc(getbothuniqueid())
            .collection("lastmessage")
            .doc(getbothuniqueid())
            .update({
          'sender_typing':true,
          'reciever_typing':true,
        });
      }
    });

    _validateValues() {
      if (chatpad.text.length > 3) {

      }else{

      }
    }

    listScrollController.addListener(_scrollListener);
  //  readLastMessage();
    readLocal();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          isEmojiVisible = false;
        });
      }
    });
  }

  /*
  void messsagedisplay() async {
    await for (var snapshot in firestore.collection("messages").doc(
        user.uid + userid).collection("chats").snapshots()) {
      for (var msg in snapshot.documents) {
        print(msg.data());
      }
    }
  }
*/

  void uploadimages() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        isLoading = true;
      });
    }

    setState(() async {
      final user = await FirebaseAuth.instance.currentUser;

      int timestamp = new DateTime.now().millisecondsSinceEpoch;
      StorageReference storageReference = FirebaseStorage.instance
          .ref()
          .child('chats/img_' + timestamp.toString() + '.jpg');
      StorageUploadTask uploadTask = storageReference.putFile(image);

      StorageTaskSnapshot storageTaskSnapshot;

      await uploadTask.onComplete.then((value) {
        if (value.error == null) {
          storageTaskSnapshot = value;
          storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
            imageurl = downloadUrl;

            Firestore.instance
                .collection('messages')
                .doc(getbothuniqueid())
                .collection("chats")
                .add({
              'sender': user.uid,
              'reciever': userid,
              'message': "",
              'id': getbothuniqueid(),
              'type': "image",
              'imageurl': imageurl,
              'isseen': false,
              'messagetime': FieldValue.serverTimestamp(),
            }).then((data) async {
              await prefs.setString('imageurl', imageurl);
              setState(() {
                isLoading = false;
              });
              Fluttertoast.showToast(msg: "Upload success");
            }).catchError((err) {
              setState(() {
                isLoading = false;
              });
              Fluttertoast.showToast(msg: err.toString());
            });
          }, onError: (err) {
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: 'This file is not an image');
          });
        }
      });
    });
  }


  /*

  void readLastMessage() {
    Firestore.instance
        .collection("messages")
        .doc(getbothuniqueid())
        .collection("chats")
        .orderBy("messagetime")
        .limit(1)
        .get()
        .then((value) {
      setState(() {
        lastmsg = value.docs[0].data()['message'];
      });
      print(
          "llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll");
      print(lastmsg);
    });
  }

  */

  Widget buildSticker() {
    return EmojiPicker(
        rows: 5,
        columns: 7,
        //buttonMode: ButtonMode.MATERIAL,
        //recommendKeywords: ["racing", "horse"],
        //  numRecommended: 10,
        onEmojiSelected: (emoji, category) {
          setState(() {
            chatpad.text = chatpad.text + emoji.emoji;
          });
        });
  }

  Future<void> sendTextmessage(String text) async
  {
    DocumentReference dref = await Firestore.instance
        .collection('messages')
        .doc(getbothuniqueid())
        .collection("chats")
        .document();

    DocumentSnapshot ds = await dref.get();
    var doc_id = ds.reference.documentID;

    dref.set({
      'sender': user.uid,
      'reciever': userid,
      'recievername': username,
      'message': text,
      'id': getbothuniqueid(),
      'docid': doc_id,
      'type': "text",
      'isseen': false,
      'recieverurl':useridurl,
      'senderurl':currentidurl,
      'sendername': currentusername,
      'messagetime': FieldValue.serverTimestamp(),
    });


    await Firestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
      'lastmessage': text,
    });

    await Firestore.instance
        .collection('users')
        .doc(userid)
        .update({
      'lastmessage': text,
    });



    await Firestore.instance
        .collection('messagesclone')
        .doc(getbothuniqueid())
        .collection("chats")
        .doc(getbothuniqueid())
        .set({
      'sender': "true",
    });

    await Firestore.instance.collection("users").doc(user.uid).update({
      "chatsid": FieldValue.arrayUnion([getbothuniqueid()])
    });

    await Firestore.instance.collection("users").doc(userid).update({
      "chatsid": FieldValue.arrayUnion([getbothuniqueid()])
    });

    await Firestore.instance
        .collection('messagesclone')
        .doc(getbothuniqueid())
        .collection("lastmessage")
        .doc(getbothuniqueid())
        .set({
      'message': text,
      'sender': user.uid,
      'reciever': userid,
      'docid': doc_id,
      'sender_typing':false,
      'reciever_typing':false,
    });
  }


  @override
  Widget build(BuildContext context) {
    const color = const Color(0xFF1DA1F2);

    return Scaffold(
      appBar:PreferredSize(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(0.0),
            child: Container(
              color: Colors.lightBlueAccent,
              child: Padding(
                padding: EdgeInsets.all(4.0),
                child: Row(
                  children: <Widget>[
                       IconButton(
                        icon: Icon(
                          Icons.arrow_back_outlined,size: 27.0,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),

                    imgurl !=null ?
                    Padding(
                      padding: EdgeInsets.only(bottom: 5.0,top: 5.0),
                      child: CachedNetworkImage(
                        imageUrl: imgurl,
                        imageBuilder: (context, imageProvider) =>
                            Container(
                              width: 35.0,
                              height: 35.0,
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
                            Padding(
                              padding: EdgeInsets.only(bottom: 5.0),
                              child: Icon(
                                  Icons.account_circle_sharp,size: 35.0,
                                ),
                            ),
                      ),
                    ):

                    Padding(
                      padding: EdgeInsets.only(bottom: 5.0),
                      child:  IconButton(
                        icon: Icon(
                          Icons.account_circle_sharp,size: 35.0,
                        ),
                        onPressed: () {},
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(left: 6.0),
                      child: Text(username,style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 21.0,
                      ),),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),preferredSize: Size.fromHeight(100),
      ),


      /*AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          tooltip: "Return back",
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        actions: <Widget>[

          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //  messsagedisplay();
              }),
        ],
        title: Text(username),
        backgroundColor: Colors.lightBlueAccent,
      ),
      */
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Column(
              children: <Widget>[
                Positioned.fill(
                    child: isLoading
                        ? Container(
                      child: Center(
                        child: LinearProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(color)),
                      ),
                      color: Colors.white.withOpacity(0.8),
                    )
                        : Container(),
                  ),
              ],
            ),

            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection("messages")
                  .doc(getbothuniqueid())
                  .collection("chats")
                  .orderBy('messagetime')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                  );
                }

                final fuser = FirebaseAuth.instance.currentUser.uid;

                final messages = snapshot.data.documents.reversed;
                messageBubbles = [];
                for (var message in messages) {
                  final messageText = message.data()['message'];
                  final messageSender = message.data()['sender'];
                  final messagetype = message.data()['type'];
                  final imgurl = message.data()['imageurl'];
                  final receiver = message.data()['receiver'];

                  final cuser = user.uid;

                  final messageBubble = MessageBubble(
                    message: messageText,
                    isme: cuser == messageSender,
                    type: messagetype,
                    imgurl: imgurl,
                    receiver: receiver,
                  );
                  messageBubbles.add(messageBubble);
                }

                return Expanded(
                  child: ListView(
                    reverse: true,
                    controller: listScrollController,
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                    children: messageBubbles,
                  ),
                );
              },
            ),

            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(0.0),
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(0, 3),
                              blurRadius: 5,
                              color: Colors.grey)
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isEmojiVisible
                                  ? Icons.keyboard_rounded
                                  : Icons.emoji_emotions_outlined,
                              //   Icons.emoji_emotions_outlined,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              focusNode.unfocus();
                              focusNode.canRequestFocus = false;
                              setState(() {
                                isEmojiVisible = !isEmojiVisible;
                              });
                            },
                          ),

                           Expanded(
                                child: TextField(
                                  onChanged: (value) {
                                    messagetext = value;
                                    print(messagetext);
                                    streamController.add(value);
                                  },

                                  autofocus: false,
                                  //keyboardType: TextInputType.multiline,
                                  //maxLengthEnforced: true,
                                 // autocorrect: true,
                                  focusNode: focusNode,
                                  controller: chatpad,
                                  decoration: InputDecoration(
                                      hintText: "Type Something...",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none),
                                ),
                              ),
                          IconButton(
                            icon:
                                Icon(Icons.image_outlined, color: Colors.grey),
                            onPressed: uploadimages,
                          ),
                          IconButton(
                            icon: Icon(Icons.send_rounded, color: Colors.grey),
                            onPressed: () async {
                              final user =
                                  await FirebaseAuth.instance.currentUser;

                              if (chatpad.text != "") {
                                sendTextmessage(chatpad.text);
                                chatpad.clear();
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Enter some messages");
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            isEmojiVisible ? buildSticker() : Container(),
          ],
        ),
      ),
    );
  }
}

/*

class messagestream extends StatelessWidget {
  List<MessageBubble> messageBubbles = [];

  String both;

  messagestream(this.both);


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection("messages")
          .doc(both)
          .collection("chats")
          .orderBy('messagetime')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }

        final fuser = FirebaseAuth.instance.currentUser.uid;

        final messages = snapshot.data.documents.reversed;

        messageBubbles = [];

        for (var message in messages) {
          final messageText = message.data()['message'];
          final messageSender = message.data()['sender'];
          final messagetype = message.data()['type'];
          final imgurl = message.data()['imageurl'];
          final receiver = message.data()['receiver'];

          _markPeerMessagesAsRead(messageText,messageSender,receiver);

          final cuser = user.uid;

          final messageBubble = MessageBubble(
            message: messageText,
            isme: cuser == messageSender,
            type: messagetype,
            imgurl: imgurl,
            receiver: receiver,
          );
          messageBubbles.add(messageBubble);
        }

        return Expanded(
          child: ListView(
            reverse: true,
            controller: _controller,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}
*/

class MessageBubble extends StatelessWidget {
  MessageBubble(
      {this.message, this.isme, this.type, this.imgurl, this.receiver});

  final String message;
  final bool isme;
  final String type;
  final String imgurl;
  final String receiver;

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance.currentUser;

    const color = const Color(0xFFB74093);

    return Padding(
      padding: EdgeInsets.all(2.0),
      child: Column(
        crossAxisAlignment:
            isme ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          type == "text"
              ? Material(
                  borderRadius: isme
                      ? BorderRadius.only(
                          topLeft: Radius.circular(30.0),
                          bottomLeft: Radius.circular(30.0),
                          topRight: Radius.circular(30.0))
                      : BorderRadius.only(
                          topRight: Radius.circular(30.0),
                          bottomLeft: Radius.circular(30.0),
                          bottomRight: Radius.circular(30.0)),
                  elevation: 5.0,
                  color: isme ? Colors.lightBlueAccent : Colors.white,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: 15.0,
                        color: isme ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                )
              : type == "image"
                  ? Container(
                      child: FlatButton(
                        child: Material(
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(color),
                              ),
                              width: 200.0,
                              height: 200.0,
                              padding: EdgeInsets.all(70.0),
                              decoration: BoxDecoration(
                                color: new Color(0xFF1DA1F2),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Material(
                              child: Image.asset(
                                'images/img_not_available.jpeg',
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                            imageUrl: imgurl,
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      FullPhoto(url: imgurl)));
                        },
                        padding: EdgeInsets.all(0),
                      ),
                    )
                  : Container(),
        ],
      ),
    );
  }
}
