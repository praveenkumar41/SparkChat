import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sparkchat/screens/MobileAuth.dart';
import 'package:sparkchat/screens/Homepage.dart';

class LoginScreen extends StatefulWidget {

  static const String id="login_screen";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _auth=FirebaseAuth.instance;
  String _email;
  String _password;

  bool _obscureText = true;
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();
  TextEditingController mail = TextEditingController();


  void _submit() {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();

      performLogin();
    }
  }

  void performLogin(){
    try{
      final user=_auth.signInWithEmailAndPassword(email: _email, password: _password);
      if(user!=null)
      {
        Navigator.pushNamed(context,homepage.id);
      }
    }
    catch(e)
    {
      print(e);
    }
  }

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: new Scaffold(
          key: scaffoldKey,
          body: Center(
            child: new Padding(
              padding: EdgeInsets.only(
                  left:20.0,top:210.0,right:20.0
              ),

              child: Center(
                child: new Form(
                  key: formKey,
                  child: new Column(
                    children: <Widget>[
                      new TextFormField(
                        onChanged: (text){
                          setState(() {
                            _email=text;
                          });
                        },
                        controller: mail,
                        decoration: new InputDecoration(labelText: "Email"),
                          validator: (val) {
                            if(val.isEmpty)
                              {
                                return 'EmailID Required';
                              }
                            else if(!val.contains('@gmail.com'))
                              {
                                return 'Invalid EmailID';
                              }
                            else{
                              return null;
                            }
                          },
                          onSaved: (val) => _email = val,

                      ),
                      new TextFormField(
                        onChanged: (text){
                          _password=text;
                        },
                        decoration: new InputDecoration(
                            labelText: "Password",
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
                          if(val.isEmpty)
                          {
                            return 'Password Required';
                          }
                          else{
                            return null;
                          }
                        },

                        obscureText:_obscureText,
                      ),

                      new Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                      ),
                      new RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.blue)),
                        child: new Text(
                          "login",
                          style: new TextStyle(color: Colors.white),
                        ),
                        color: Colors.blue,
                        onPressed:_submit,
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
