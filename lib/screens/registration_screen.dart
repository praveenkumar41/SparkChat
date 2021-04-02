import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sparkchat/screens/MobileAuth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sparkchat/screens/MobileAuth.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = "registration_screen";

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  TextEditingController date = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController mail = TextEditingController();
  TextEditingController password = TextEditingController();

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();

  final firestore=Firestore.instance;
  final _auth=FirebaseAuth.instance;
  DateTime selecteddate = DateTime.now();
  String _email,_password,_date,_name;
  bool mailvalid,passvalid;

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selecteddate,
        firstDate: DateTime(1901, 1),
        lastDate: DateTime(2100));
    if (picked != null && picked != selecteddate)
      setState(() {
        selecteddate = picked;
        date.value = TextEditingValue(text: picked.toString().split(' ')[0]);
      });
  }

  bool validatemail(String text)
  {
    bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(text);
        if(emailValid)
        {
          return true;
        }
        else
        {
          return false;
        }
  }

  bool validatpassword(String text)
  {
    String  passpattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = new RegExp(passpattern);
    bool passvalid= regExp.hasMatch(text);

        if(passvalid)
        {
          return true;
        }
        else
        {
          return false;
        }
  }

  void _submit() {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();

          performLogin();
    }
  }

  void performLogin() async{
/*
    firestore.collection('users').add({
      'name':_name,
      'emailid':_email,
      'dob':date.text,
    });
*/
    try {
      final newUser = await _auth
          .createUserWithEmailAndPassword(
          email: _email, password: _password);
      if (newUser != null) {

        Navigator.of(context).pop();
     //   Navigator.pushNamed(context, mobileauth.id);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => mobileauth(mail: _email,pass: _password,name: _name,date:date.text,)),
        );

      }
    }
    catch (e) {
      print(e);
    }
  }

  bool _obscureText = true;

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: new Scaffold(
          key: scaffoldKey,
          body: Center(
        child: new Padding(
          padding: EdgeInsets.only(left: 20.0, top: 70.0, right: 20.0),
          child: Center(
            child: new Form(
              key: formKey,
              child: new Column(
                children: <Widget>[
                  new TextFormField(
                    onChanged: (text){
                      _name=text;
                    },
                    maxLength: 50,
                    controller: name,
                    maxLines: 1,
                    decoration: new InputDecoration(labelText: "Name",

                     // border: InputBorder.none,
                     // fillColor: Colors.black12,
                     // filled: true,
                    ),

                    validator: (val) {
                      if(val.isEmpty)
                      {
                        return 'Name Required';
                      }
                      else{
                        return null;
                      }
                    },
                  ),

                  new TextFormField(
                    onChanged: (text){
                      _email=text;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: new InputDecoration(labelText: "EmailID",
                    ),
                    validator: (val) {
                      if(val.isEmpty)
                        {
                          return 'EmailID Required';
                        }
                      else if(!val.contains('@gmail.com'))
                        {
                          return 'Invalid EmailID';
                        }
                      else
                        {
                          return null;
                        }
                    },
                    onSaved: (val) {
                      _email = val;
                    },
                    controller: mail,
                  ),
                  SizedBox(
                    height: 0,
                  ),
                  new TextFormField(
                    onChanged: (text){

                      _password=text;
                    },
                    keyboardType: TextInputType.text,
                    decoration: new InputDecoration(labelText: "Password",

                      suffixIcon: IconButton(
                        padding: new EdgeInsets.only(top:13.0),
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color:Colors.grey,
                        ),
                        onPressed: () {
                          // Update the state i.e. toogle the state of passwordVisible variable
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),

                    validator: (val) {
                      String  pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                      RegExp regExp = new RegExp(pattern);
                      bool torf= regExp.hasMatch(val);
                      if(val.isEmpty)
                        {
                           return 'Password Required';
                        }
                      else if(!torf)
                        {
                          return 'Password should contain combination\n of uppercase (A-Z),lowercase (a-z),\n numbers (0-9) and special characters';
                        }
                      else{
                         return null;
                      }
                    },
                    onSaved: (val) => _password = val,
                    obscureText:_obscureText,
                    controller: password,
                  ),
                  SizedBox(
                    height: 0,
                  ),
                  GestureDetector(
                    onTap: ()=>_selectDate(context),
                    child: AbsorbPointer(
                      child: new TextFormField(
                        controller: date,
                        keyboardType: TextInputType.datetime,
                        decoration: InputDecoration(
                          labelText: "Date of birth",
                        ),
                        validator: (val) {
                          if(val.isEmpty)
                          {
                            return 'DOB Required';
                          }
                          else{
                            return null;
                          }
                        },
                      ),
                    ),
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                  ),
                  new RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.blue)),
                    child: new Text(
                      "Next",
                      style: new TextStyle(color: Colors.white),
                    ),
                    color: Colors.blue,
                    onPressed: _submit,
                  )
                ],
              ),
            ),
          ),
        ),
      )),
    );
  }
}
