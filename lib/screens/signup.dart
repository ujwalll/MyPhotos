import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:photoUpload/screens/login.dart';
import 'package:photoUpload/screens/home.dart';
import 'package:photoUpload/authentication_service.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: ,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RaisedButton(
                    onPressed: () async {
                      await Provider.of<AuthenticationService>(context,
                              listen: false)
                          .signUp(
                              email: emailController.text,
                              password: passwordController.text)
                          .whenComplete(() {
                        if (Provider.of<AuthenticationService>(context,
                                    listen: false)
                                .getUserUid !=
                            null) {
                          Navigator.pushReplacement(
                            context,
                            PageTransition(
                                child: HomeScreen(),
                                type: PageTransitionType.bottomToTop),
                          );
                        } else {
                          print('Control reached here');
                          return showDialog<void>(
                            context: context,
                            barrierDismissible: false, // user must tap button!
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Invalid email or password'),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      Text(
                                          'Password must be atleast 6 characters!'),
                                      Text('Please try again!'),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      });
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.blue,
                  ),
                  RaisedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        PageTransition(
                          child: LoginScreen(),
                          type: PageTransitionType.rightToLeft,
                        ),
                      );
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
