import 'dart:io';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as Path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photoUpload/authentication_service.dart';
import 'package:provider/provider.dart';

class AddImage extends StatefulWidget {
  @override
  _AddImageState createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  CollectionReference imgRef;
  firebase_storage.Reference ref;
  List<File> _image = [];
  final picker = ImagePicker();
  bool uploading = false;
  double val = 0;
  @override
  void initState() {
    super.initState();
    imgRef = FirebaseFirestore.instance.collection('imageURLs');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              FontAwesomeIcons.cloudUploadAlt,
            ),
            onPressed: () {
              setState(() {
                uploading = true;
              });
              uploadImageToFirebase().whenComplete(() {
                setState(() {
                  uploading = false;
                });
                Navigator.pop(context);
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GridView.builder(
            itemCount: _image.length + 1,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            itemBuilder: (context, index) {
              return index == 0
                  ? Center(
                      child: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          !uploading ? chooseImage() : null;
                        },
                      ),
                    )
                  : Container(
                      margin: EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(
                            _image[index - 1],
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
            },
          ),
          uploading
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        child: Text(
                          'Uploading images..',
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      CircularProgressIndicator(
                        value: val,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Container(
                        child: Text(
                          'It may take some time. Please wait.',
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  chooseImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image.add(File(pickedFile.path));
    });
    if (pickedFile.path == null) retrieveLostData();
  }

  Future<void> retrieveLostData() async {
    final LostData response = await picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _image.add(File(response.file.path));
      });
    } else {
      print(response.file);
    }
  }

  Future uploadImageToFirebase() async {
    int i = 1;
    for (var img in _image) {
      setState(() {
        val = i / _image.length;
      });
      ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('images/${Path.basename(img.path)}/${TimeOfDay.now()}');
      await ref.putFile(img).whenComplete(() async {
        await ref.getDownloadURL().then((value) {
          imgRef.add({
            'url': value,
            'userid': Provider.of<AuthenticationService>(context, listen: false)
                .getUserUid,
            'creationTime': DateTime.now(),
          });
        });
      });
      i++;
    }
  }
}
