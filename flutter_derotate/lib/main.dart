import 'dart:convert';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'dart:typed_data';

const STATUS_WAIT = 0;
const STATUS_IMAGE_LOADED = 1;
const STATUS_FINISHED = 2;

void main() {
  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Derotate",
    home: new MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File img;
  bool isImg2Img = true;
  Uint8List derotatedImage;
  int status = STATUS_WAIT;
  String strResponse = '';

  // The function which will upload the image as a file
  void upload(File imageFile) async {
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();

    String base = "http://54.145.131.146";

    var uri = isImg2Img
        ? Uri.parse(base + '/img2img/')
        : Uri.parse(base + '/img2class/');

    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('file', stream, length,
        filename: basename(imageFile.path));

    request.files.add(multipartFile);
    var response = await request.send();
    print(response.statusCode);
    if (isImg2Img) {
      derotatedImage = await response.stream.toBytes();
    } else {
      response.stream.transform(utf8.decoder).listen((value) {
        strResponse = value;
      });
    }

    setState(() {
      status = STATUS_FINISHED;
    });
  }

  void image_picker(int a) async {
    setState(() {});
    debugPrint("Image Picker Activated");
    if (a == 0) {
      img = await ImagePicker.pickImage(source: ImageSource.camera);
    } else {
      img = await ImagePicker.pickImage(source: ImageSource.gallery);
    }

//    txt = "Analyzing...";
    debugPrint(img.toString());
    upload(img);
    setState(() {
      status = STATUS_IMAGE_LOADED;
    });
  }

  Widget textComments(BuildContext context) {
    String comment = '';
    switch (status) {
      case STATUS_WAIT:
        comment = "";
        break;
      case STATUS_IMAGE_LOADED:
        comment = isImg2Img ? "Derotating image" : "Analyzing image";
        break;
      case STATUS_FINISHED:
        if (isImg2Img) {
          comment = "Here is the derotated image!";
        } else {
          comment = strResponse;
        }
        break;
    }

    return Center(
      child: new Text(
        comment,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24.0,
        ),
      ),
    );
  }

  Widget result(BuildContext context) {
    if (derotatedImage != null) {
      return Image.memory(derotatedImage);
    } else {
      if (img != null) {
        return Image.file(img);
      } else {
        return Center(
          child: new Text(
            "Upload/capture the rotated image you want to derotate",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24.0,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text("Derotate"),
      ),
      body: new Container(
        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 25),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Image-to-Class"),
                  Switch(
                    value: isImg2Img,
                    onChanged: (value) {
                      setState(() {
                        isImg2Img = value;
                        print(isImg2Img);
                      });
                    },
                    activeTrackColor: Colors.lightBlueAccent,
                    activeColor: Colors.blue,
                  ),
                  Text("Image-to-Image"),
                ],
              ),
              result(context),
              textComments(context),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new FloatingActionButton(
                    onPressed: () {
                      image_picker(0);
                    },
                    child: new Icon(Icons.camera_alt),
                  ),
                  new FloatingActionButton(
                      onPressed: () {
                        image_picker(1);
                      },
                      child: new Icon(Icons.file_upload)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
