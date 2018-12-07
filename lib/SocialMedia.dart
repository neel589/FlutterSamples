import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

void main() {
  runApp(LoginPage());
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool pressed = true;
  bool isLoggedIn = false;
  var profileData;
  static final TwitterLogin twitterLogin = new TwitterLogin(
    consumerKey: 'bTgJIaZ26HdUAs8HKeIwy4trb',
    consumerSecret: 'sDjGXQpdmqnUk1YTK0AIXDnhhLk1rhPyGFw8iRnZ6XqZkheNSy',
  );
  GoogleSignInAccount _currentUser;
  String _contactText = "Login with Google";
  GoogleSignIn googleAuth = new GoogleSignIn();
  String _message = 'Logged out.';
  var facebookLogin = FacebookLogin();

  void onLoginStatusChanged(bool isLoggedIn, {profileData}) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
      this.profileData = profileData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text("Facebook Login"),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                ),
                onPressed: () =>
                    facebookLogin.isLoggedIn
                        .then((isLoggedIn) => isLoggedIn ? _logout() : {}),
              ),
            ],
          ),
          body: new Center(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Padding(padding: EdgeInsets.all(12.0)),
                new Center(
                  child: isLoggedIn
                      ? _displayUserData(profileData)
                      : _displayLoginButton(),
                ),
                new Padding(padding: EdgeInsets.all(12.0)),
                new Text(_message,
                  style: TextStyle(fontSize: 15.0,fontStyle: FontStyle.italic,color: Colors.deepOrange),
                ),
                new Center(
                  child: _displayTwitterBtn(),
                ),
                new Padding(padding: EdgeInsets.all(12.0)),
                new Center(
                  child: _displayGoogleBtn(),
                ),
              ],
            ),
          )
      ),
    );
  }

  /*Facebook Login async task*/
  void initiateFacebookLogin() async {
    var facebookLoginResult =
    await facebookLogin.logInWithReadPermissions(['email']);

    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.loggedIn:
        var graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.height(200)&access_token=${facebookLoginResult
                .accessToken.token}');

        var profile = json.decode(graphResponse.body);
        print(profile.toString());

        onLoginStatusChanged(true, profileData: profile);
        break;
    }
  }

  /*get fb user profile data*/
  _displayUserData(profileData) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 200.0,
          width: 200.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage(
                profileData['picture']['data']['url'],
              ),
            ),
          ),
        ),
        SizedBox(height: 28.0),
        Text(
          "Logged in as: ${profileData['name']}",
          style: TextStyle(
            fontSize: 20.0,
            
          ),
        ),
      ],
    );
  }

  /*FB Login button*/
  _displayLoginButton() {
    return RaisedButton(
      child: Text("Login with Facebook"),
      onPressed: () => initiateFacebookLogin(),
    );
  }

  /*Twitter Login button*/
  _displayTwitterBtn() {
    return RaisedButton(
      child: Text("Login With Twitter"),
      onPressed: () => twitterlogin(),
    );
  }
  /*Google login button*/
  _displayGoogleBtn(){
    return RaisedButton(
      child: Text(
          _contactText),
      onPressed: (){
        googleAuth.signIn().then((signedInUser) {
          print('Signed in as ${signedInUser.displayName}');
          _contactText = 'Singed in as $signedInUser.displayName';
          print('email${signedInUser.email}');
        }).catchError((e) {
          print(e);
        });
      },
    );
  }

  /*fb logout method*/
  _logout() async {
    await facebookLogin.logOut();
    onLoginStatusChanged(false);
    print("Logged out");
  }

  /*twitter login async task*/
  void twitterlogin() async {
    final TwitterLoginResult result = await twitterLogin.authorize();
    String newMessage;

    switch (result.status) {
      case TwitterLoginStatus.loggedIn:
        newMessage = 'Logged in! username: ${result.session.username} \nuserID:${result.session.userId}';
        break;
      case TwitterLoginStatus.cancelledByUser:
        newMessage = 'Login cancelled by user.';
        break;
      case TwitterLoginStatus.error:
        newMessage = 'Login Error: ${result.errorMessage}';
        break;
    }
    setState(() {
      _message = newMessage;
    });
  }

  /*logout from twitter*/
  void _twitterlogout() async {
    await twitterLogin.logOut();

    setState(() {
      _message = 'Logged out.';
    });
  }
  /*signout from google*/
  void _signOut(){
    googleAuth.signOut();
    print('Signed out');
  }
}
