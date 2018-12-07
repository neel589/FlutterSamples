import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:multiimage/instagram.dart';
import 'package:multiimage/login_presenter.dart';


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

typedef Future<void> FutureCallBack();

class _LoginPageState extends State<LoginPage> implements LoginViewContract {

  String _loginStatus = 'Press button to log in';
  bool isLoggedIn = false;
  bool _IsLoading;
  var profileData;
  LoginPresenter _presenter;
  static final TwitterLogin twitterLogin = new TwitterLogin(
    consumerKey: 'bTgJIaZ26HdUAs8HKeIwy4trb',
    consumerSecret: 'sDjGXQpdmqnUk1YTK0AIXDnhhLk1rhPyGFw8iRnZ6XqZkheNSy',
  );
  GoogleSignInAccount _currentUser;
  String _contactText = "Login with Google";
  GoogleSignIn googleAuth = new GoogleSignIn();
  String _message = 'Logged out.';
  var facebookLogin = FacebookLogin();
  Token token;
  GlobalKey<ScaffoldState> _scaffoldKey;


  void onLoginStatusChanged(bool isLoggedIn, {profileData}) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
      this.profileData = profileData;
    });
  }

  _LoginScreenState(GlobalKey<ScaffoldState> skey) {
    _presenter = new LoginPresenter(this);
    _scaffoldKey = skey;
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
                onPressed: () => facebookLogin.isLoggedIn
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
                new Text(
                  _message,
                  style: TextStyle(
                      fontSize: 15.0,
                      fontStyle: FontStyle.italic,
                      color: Colors.deepOrange),
                ),
                new Center(
                  child: _displayTwitterBtn(),
                ),
                new Padding(padding: EdgeInsets.all(12.0)),
                new Center(
                  child: _displayGoogleBtn(),
                ),
                new Padding(padding: EdgeInsets.all(12.0)),
                new Center(
                  child: _displyInstagrambtn(),
                )
              ],
            ),
          )),
    );
  }
  @override
  void initState() {
    super.initState();
    _IsLoading = false;
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
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.height(200)&access_token=${facebookLoginResult.accessToken.token}');

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
  _displayGoogleBtn() {
    return RaisedButton(
      child: Text(_contactText),
      onPressed: () {
          googleAuth.signIn().then((signedInUser) {
            setState(() {
              _contactText = 'Singed in as $signedInUser.displayName';
            });
            print('Signed in as ${signedInUser.displayName}');
            print('email${signedInUser.email}');
          }).catchError((e) {
            print(e);
          });
      },
    );
  }
  /*display LinkedIn button*/
  _displyInstagrambtn(){
    return RaisedButton(
      child: Text('Login with Instagram'),
      onPressed: (){
        var widget;
        if(_IsLoading) {
          widget = new Center(
              child: new Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: new CircularProgressIndicator()
              )
          );
        } else if(token != null){
          widget = new Padding(
              padding: new EdgeInsets.all(32.0),
              child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Text(
                      token.full_name,
                      style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.5),),
                    new Text(token.username),
                    new Center(
                      child: new CircleAvatar(
                        backgroundImage: new NetworkImage(token.profile_picture),
                        radius: 50.0,
                      ),
                    ),
                  ]
              )
          );
        }
        else {
          widget = new Padding(
              padding: new EdgeInsets.all(32.0),
              child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Text(
                      'Welcome to FlutterAuth,',
                      style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.5),),
                    new Text('Login to continue'),
                    new Center(
                      child: new Padding(
                          padding: new EdgeInsets.symmetric(vertical: 160.0),
                          child:
                          new InkWell(child:
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Image.asset(
                                'assets/instagram.png',
                                height: 50.0,
                                fit: BoxFit.cover,
                              ),
                              new Text('Continue with Instagram')
                            ],
                          ),onTap: _login,)
                      ),
                    ),
                  ]
              )
          );
        }print('clicked');
        return widget;
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
        newMessage =
            'Logged in! username: ${result.session.username} \nuserID:${result.session.userId}';
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
  void _signOut() {
    googleAuth.signOut();
    print('Signed out');
  }

  void _login(){
    setState(() {
      _IsLoading = true;
    });
    _presenter.perform_login();
  }

  @override
  void onLoginError(String msg) {
    // TODO: implement onLoginError
    setState(() {
      _IsLoading = false;
    });
    showInSnackBar(msg);
  }

  @override
  void onLoginScuccess(Token t) {
    // TODO: implement onLoginScuccess
    setState(() {
      _IsLoading = false;
      token = t;
    });
    showInSnackBar('Login successful');
  }
  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(value)
    ));
  }
}