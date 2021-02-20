import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:photoUpload/authentication_service.dart';
import 'package:photoUpload/screens/image_upload_screen.dart';
import 'package:photoUpload/screens/login.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Photo Gallery'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(EvaIcons.logOut),
            onPressed: () {
              Provider.of<AuthenticationService>(context, listen: false)
                  .logOut()
                  .whenComplete(() {
                Navigator.pushReplacement(
                  context,
                  PageTransition(
                      child: LoginScreen(),
                      type: PageTransitionType.bottomToTop),
                );
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
                child: AddImage(), type: PageTransitionType.bottomToTop),
          );
        },
        child: Icon(EvaIcons.plus),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('imageURLs')
            .where('userid',
                isEqualTo:
                    Provider.of<AuthenticationService>(context).getUserUid)
            .snapshots(),
        builder: (context, snapshot) {
          return !snapshot.hasData
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Container(
                  child: GridView.builder(
                    itemCount: snapshot.data.docs.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3),
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.all(4),
                        child: FadeInImage.memoryNetwork(
                          fit: BoxFit.cover,
                          placeholder: kTransparentImage,
                          image: snapshot.data.docs[index]['url'],
                        ),
                      );
                    },
                  ),
                );
        },
      ),
    );
  }
}
