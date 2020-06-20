import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_demo/services/authentication.dart';


class LoginSignupPage extends StatefulWidget {
  LoginSignupPage({this.auth, this.loginCallback});

  final BaseAuth auth;
  final VoidCallback loginCallback;

  @override
  State<StatefulWidget> createState() => new _LoginSignupPageState();
}


class _LoginSignupPageState extends State<LoginSignupPage> {
  final _formKey = new GlobalKey<FormState>();

  String _email;
  String _password;
  String _name;
  String _errorMessage;

  bool _isLoginForm;
  bool _isLoading;

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (validateAndSave()) {
      String userId = "";
      try {
        if (_isLoginForm) {
          userId = await widget.auth.signIn(_email, _password);

        } else {
          userId = await widget.auth.signUp(_email, _password);
          DocumentReference documnentReference =
              Firestore.instance.collection("users").document(userId);
          Map<String,String> users ={
            "useruid" :userId,
            "username":_name
          };
          documnentReference.setData(users).whenComplete((){
            print("$userId has added");
          });

        }
        setState(() {
          _isLoading = false;
        });

        if (userId.length > 0 && userId != null && _isLoginForm) {
          widget.loginCallback();
          print(userId);
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
          _formKey.currentState.reset();
        });
      }
    }
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    _isLoginForm = true;
    super.initState();
  }

  void resetForm() {
    _formKey.currentState.reset();
    _errorMessage = "";
  }

  void toggleFormMode() {
    resetForm();
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Stack(
      children: <Widget>[
        _showForm(),
        _showCircularProgress(),
      ],
    ));
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  Widget _showForm() {
    return new Center(
      child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/arka.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          padding: EdgeInsets.all(16.0),
          child: new Form(
            key: _formKey,
            child: new ListView(
              shrinkWrap: true,
              children: <Widget>[
                SizedBox(
                  height: 100.0,
                ),
                showName(),
                showEmailInput(),
                showPasswordInput(),
                showPrimaryButton(),
                showSecondaryButton(),
                showErrorMessage(),
              ],
            ),
          )),
    );
  }

  Widget showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.white,
            height: 1.0,
            fontWeight: FontWeight.w700),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget showLogo() {
    return new Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 48.0,
          child: Image.asset('assets/arka.jpg'),
        ),
      ),
    );
  }

  Widget showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            border: new UnderlineInputBorder(
              borderSide: new BorderSide(color: Colors.teal),
            ),
            hintText: 'Email',
            hintStyle: TextStyle(fontSize: 20.0, color: Colors.white),
            icon: new Icon(
              Icons.mail,
              color: Colors.white,
            )),
        validator: (value) => value.isEmpty ? 'Email boş olamaz' : null,
        onSaved: (value) => _email = value.trim(),
      ),
    );
  }
  Widget showName() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            border: new UnderlineInputBorder(
              borderSide: new BorderSide(color: Colors.teal),
            ),
            hintText: 'İsim',
            hintStyle: TextStyle(fontSize: 20.0, color: Colors.white),
            icon: new Icon(
              Icons.account_circle,
              color: Colors.white,
            )),
        validator: (value) => value.isEmpty ? 'İsim Boş Olamaz' : null,
        onSaved: (value) => _name = value.trim(),
      ),
    );
  }
  Widget showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            border: new UnderlineInputBorder(
              borderSide: new BorderSide(color: Colors.teal),
            ),
            hintText: 'Şifre',
            hintStyle: TextStyle(fontSize: 20.0, color: Colors.white),
            icon: new Icon(
              Icons.lock,
              color: Colors.white,
            )),
        validator: (value) => value.isEmpty ? 'Şifre Boş Olamaz' : null,
        onSaved: (value) => _password = value.trim(),
      ),
    );
  }

  Widget showSecondaryButton() {
    return new FlatButton(
        child: new Text(
            _isLoginForm
                ? 'Hesap Oluştur'
                : 'Zaten bir hesabın varmı? Giriş Yap',
            style: new TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        onPressed: toggleFormMode);
  }

  Widget showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.white,
            child: new Text(_isLoginForm ? 'Giriş Yap' : 'Hesap Oluştur',
                style: new TextStyle(fontSize: 20.0, color: Colors.blueAccent)),
            onPressed: validateAndSubmit,
          ),
        ));
  }
}
