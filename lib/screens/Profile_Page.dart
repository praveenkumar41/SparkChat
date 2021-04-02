import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sparkchat/constants.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';
import 'package:sparkchat/screens/Chat_Screen.dart';



class profilepage extends StatefulWidget {
  static const String id = "profilepage";

  @override
  _profilepageState createState() => _profilepageState();
}


class _profilepageState extends State<profilepage> {

  SharedPreferences prefs;
  String photoUrl = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    photoUrl = prefs.getString('photoUrl') ?? '';
    // Force refresh input
    setState(() {
      if(!mounted)
      {
        return;
      }
    });
  }


  void handleUpdateData() {

    setState(() {
      isLoading = true;
    });

    FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'photoUrl': photoUrl
    }).then((data) async {
      await prefs.setString('photoUrl', photoUrl);

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Update success");
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: err.toString());
    });
  }


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
          .child('profiles/img_' + timestamp.toString() + '.jpg');
      StorageUploadTask uploadTask = storageReference.putFile(image);
 //     await uploadTask.onComplete;
      StorageTaskSnapshot storageTaskSnapshot;
      await uploadTask.onComplete.then((value){
        if (value.error == null) {
          storageTaskSnapshot = value;
          storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
            photoUrl = downloadUrl;
            FirebaseFirestore.instance.collection('users').doc(user.uid).update({
              'photoUrl': photoUrl
            }).then((data) async {
              await prefs.setString('photoUrl', photoUrl);
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
        else {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: 'This file is not an image');
        }
      }, onError: (err)
      {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: err.toString());
      });
    });

  }

  @override
  Widget build(BuildContext context) {

    const color = const Color(0xFFB74093);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Positioned(
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
            Padding(
              padding: EdgeInsets.only(left: 80.0),
              child: IconButton(
                  icon: Icon(Icons.check),
                  onPressed: (){
                    handleUpdateData();
                    Navigator.of(context).pop();
                  }
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 35.0),
              child: Row(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 25.0,left: 20.0),
                        child: FlatButton(
                          onPressed: (){
                            uploadimages();
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: CachedNetworkImage(
                              placeholder: (context, url) => Container(

                                child: CircularProgressIndicator(
                                  strokeWidth: 6.0,
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(color),
                                ),

                                width: 30.0,
                                height: 30.0,
                                padding: EdgeInsets.all(0.0),
                                decoration: new BoxDecoration(
                                  color: new Color(0xFF1DA1F2),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(50.0),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Material(
                                child: Image.asset(
                                  'images/profileimage.png',
                                  width: 30.0,
                                  height: 30.0,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(50.0),
                                ),
                                clipBehavior: Clip.hardEdge,
                              ),
                              imageUrl: photoUrl,
                              width: 60.0,
                              height: 60.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                 ),

                  Padding(
                    padding: EdgeInsets.only(top: 26.0,left:0.0),
                    child: Column(
                      children: <Widget>[

                        Padding(
                          padding: EdgeInsets.only(left: 0.0),
                          child: Text("Cristopher,27",style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),),
                        ),

                        Padding(
                          padding: EdgeInsets.only(right: 27.0,top:5.0),
                          child: Text("Hollywood ceo",style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
