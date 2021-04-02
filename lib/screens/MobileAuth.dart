 import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sparkchat/constants.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:sparkchat/screens/Homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class mobileauth extends StatefulWidget {
  static const String id="MobileAuth";

  String mail,pass,name,date;

  mobileauth({this.mail, this.pass,this.name, this.date});

  @override
  _mobileauthState createState() => _mobileauthState(mail,pass,name,date);
}

class _mobileauthState extends State<mobileauth> {

  String mail, pass,name,date;

  _mobileauthState(this.mail, this.pass,this.name,this.date);

  GlobalKey<FormState> _formKey = GlobalKey();
  String msg="";
  String phonenum="";
  String _smsVerificationCode="";
 // AuthCredential credential;
  String phoneNo;
  String smsOTP;
  String verificationId;
  String errorMessage = '';
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser loggedInuser;

  //final _auth=FirebaseAuth.instance;

  get verifiedSuccess => null;

  Future<void> verifyPhone() async {

    final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      smsOTPDialog(context).then((value) {
        print('sign in');
      });

    };
    final PhoneVerificationCompleted verifiedSuccess= (AuthCredential auth){};
    final PhoneVerificationFailed verifyFailed= (Exception e){
      print('${e}');
    };
    try {
      await _auth.verifyPhoneNumber(

          phoneNumber: this.phoneNo, // PHONE// NUMBER TO SEND OTP
          codeAutoRetrievalTimeout: (String verId) {
            this.verificationId = verId;
          },
          codeSent:
          smsOTPSent, // WHEN CODE SENT THEN WE OPEN DIALOG TO ENTER OTP.
          timeout: const Duration(seconds: 20),
          verificationCompleted:verifiedSuccess,
          verificationFailed: verifyFailed,

      );
    } catch (e) {
      handleError(e);
    }
  }

  /*
   void linkCredential(AuthCredential credential) {
     final FirebaseUser currentUser = _auth.currentUser;

   //  currentUser.linkWithCredential(credential);

     currentUser.linkWithCredential(credential).then((user) {
       print('helllllllllllllllllllllllllllllllllllllllllllll'+user.user.uid);
     }).catchError((error) {
       print(error.toString());
     });

   }
   */

  void mobilenumbersave() async {



    final user =await FirebaseAuth.instance.currentUser;

    var rnd = new Random();
    var next = rnd.nextDouble() * 10000000000;
    while (next < 100000) {
      next *= 10;
    }

    var ss=next.toInt();
    String chatid=ss.toString();

    Firestore.instance.collection('users').document(user.uid).setData({
      'name':name,
      'mailid':mail,
      'dob':date,
      'mobile':phonenum.toString(),
      'id':user.uid,
      'uniqueid':chatid,
      'lastmessage':'',
      'photoUrl':"https://firebasestorage.googleapis.com/v0/b/spark-chat-24c0e.appspot.com/o/profiles%2Fimg_1612101006568.jpg?alt=media&token=b8aaf57c-3241-4b7c-bea3-7c4e1ad2fc66"
    });

    print("updateddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd");
  }


  Future<bool> smsOTPDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Enter SMS Code'),
            content: Container(
              height: 85,
              child: Column(children: [

                 OTPTextField(
                  length: 6,
                  width: MediaQuery.of(context).size.width,
                  textFieldAlignment: MainAxisAlignment.spaceAround,
                  fieldWidth: 30,
                  fieldStyle: FieldStyle.underline,
                  style: TextStyle(
                      fontSize: 16
                  ),
                  onCompleted: (pin) {
                    print("Completed: " + pin);
                  },
                  onChanged: (value) {
                     this.smsOTP = value;
                   },
                ),

                (errorMessage != ''
                    ? Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                )
                    : Container())
              ]),
            ),
            contentPadding: EdgeInsets.all(10),
            actions: <Widget>[
              FlatButton(
                child: Text('Done'),
                onPressed: ()
                {
                     signIn();
                },
              )
            ],
          );
        });
  }


  signIn() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verificationId,
        smsCode: smsOTP,
      );
/*
      final FirebaseUser user = (await _auth.currentUser.linkWithCredential(credential)) as FirebaseUser;
      final FirebaseUser currentUser = await _auth.currentUser;
      assert(user.uid == currentUser.uid);
*/
      await _auth.currentUser.linkWithCredential(credential).then((user)
      {
        print('ddddddddddddddddddddddddddddddddddddddddddddddddddddddddd');
        mobilenumbersave();

  //      Navigator.of(context).pushNamed(homepage.id);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => homepage(mobile: phonenum,)),
        );
       // Navigator.of(context).pop();

      });
    } catch (e) {
      handleError(e);
    }
  }


  handleError(PlatformException error) {
    print(error);
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        FocusScope.of(context).requestFocus(new FocusNode());
        setState(() {
          errorMessage = 'Invalid Code';
        });
        Navigator.of(context).pop();
        smsOTPDialog(context).then((value) {
          print('sign in');
        });
        break;
      default:
        setState(() {
          errorMessage = error.message;
        });

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: new Scaffold(
          body: Center(
            child: new Padding(
              padding: EdgeInsets.only(
                  left:20.0,top:50.0,right:20.0
              ),

              child: Center(
                child: new Form(
                  key: _formKey,
                  child: new Column(
                    children: <Widget>[
                      IntlPhoneField(
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          //border: OutlineInputBorder(
                           // borderSide: BorderSide(),
                         // ),
                        ),
                        onChanged: (phone) {
                          setState(()
                          {
                            print(phone.completeNumber);
                            phonenum=phone.completeNumber;
                            this.phoneNo = phone.completeNumber;
                          });
                        },
                      ),
                      SizedBox(
                        height: 6,
                      ),

                          Padding(
                            padding: EdgeInsets.only(right:0.0,top:20.0),
                            child: MaterialButton(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                              child: Text('send verification code'),
                              color: Colors.black12,
                              textColor: Colors.black,
                              onPressed: () {
                         //       _formKey.currentState.validate();
                                verifyPhone();
                              },
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );

  }
}
