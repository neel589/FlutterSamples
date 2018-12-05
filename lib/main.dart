import 'package:flutter/material.dart';
import 'package:multiimage/ImagePicFrmCamra.dart';
import 'package:multiimage/SocialMedia.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(home: new HomeScreen());
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Flutter Demo"),
      ),
      body: Column(
        children: <Widget>[
          new Padding(padding: EdgeInsets.all(15.0)),
          new Center(
            child: new Text(
              "Please Select the options",
              style: TextStyle(
                fontSize: 25.0,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          new Padding(padding: EdgeInsets.all(15.0)),
          new RaisedButton(
            child: Text(
              'Image Selection from Gallery',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            onPressed: () {
              print("Gallary pic");
              Navigator.push(
                context,
                new MaterialPageRoute(builder: (context) => new ImagePic()),
              );
            },
          ),
          new Padding(padding: EdgeInsets.all(15.0)),
          RaisedButton(
            child: Text(
              'Social Media Auth',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            padding: EdgeInsets.all(15.0),
            onPressed: () {
              print("Gallary pic");
              Navigator.push(
                context,
                new MaterialPageRoute(builder: (context) => new LoginPage()),
              );
            },
          )
        ],
      ),
    );
  }
}
