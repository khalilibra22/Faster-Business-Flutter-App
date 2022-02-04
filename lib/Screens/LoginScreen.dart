import 'package:FasterBusiness/Screens/splashScreen.dart';
import 'package:FasterBusiness/classes/mService.dart';
import 'package:FasterBusiness/config/CustomToast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:toast/toast.dart';
import 'configuration.dart';
import 'SignupScreen.dart';
import '../Animations/FadeAnimation.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool PasswordVisbility = true;
  bool _isLoading = false;
  final EmailController = TextEditingController();
  final PasswordCottroller = TextEditingController();
  final _frogetEmailController = TextEditingController();
  final _frogetPhoneController = TextEditingController();

  bool _isPasswordForget = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF73AEF5),
                      Color(0xFF61A4F1),
                      Color(0xFF478DE0),
                      Color(0xFF398AE5),
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 120.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FadeAnimation(
                        1,
                        Column(
                          children: <Widget>[
                            Text(
                              'Connexion',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Montserrat',
                                fontSize: 30.0,
                                letterSpacing: 2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            _isLoading
                                ? SpinKitDoubleBounce(
                                    color: Colors.white,
                                    size: 20.0,
                                  )
                                : Container()
                          ],
                        ),
                      ),
                      SizedBox(height: 30.0),
                      FadeAnimation(1.1, _buildEmailTF()),
                      SizedBox(
                        height: 30.0,
                      ),
                      FadeAnimation(1.2, _buildPasswordTF()),
                      FadeAnimation(1.3, _buildForgotPasswordBtn()),
                      FadeAnimation(1.4, _buildLoginBtn()),
                      FadeAnimation(1.5, _buildSignupBtn()),
                    ],
                  ),
                ),
              ),
              _isPasswordForget ? _passwordFoget() : Container()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Email',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: EmailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Montserrat',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.white,
              ),
              hintText: 'Entrer votre email',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Mot de passe',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: PasswordCottroller,
            obscureText: PasswordVisbility,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Montserrat',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              suffixIcon: PasswordVisbility
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          PasswordVisbility = !PasswordVisbility;
                        });
                      },
                      icon: Icon(Icons.visibility_off))
                  : IconButton(
                      onPressed: () {
                        setState(() {
                          PasswordVisbility = !PasswordVisbility;
                        });
                      },
                      icon: Icon(Icons.visibility)),
              hintText: 'Entrer votre mot de passe',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: FlatButton(
        onPressed: () {
          setState(() {
            _isPasswordForget = true;
          });
        },
        padding: EdgeInsets.only(right: 0.0),
        child: Text(
          'Mot de passe oublier?',
          style: kLabelStyle,
        ),
      ),
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () async {
          if (!_inputsValidate()) return;
          setState(() {
            _isLoading = true;
          });
          int result = await Mservice()
              .sellerLogin(EmailController.text, PasswordCottroller.text);
          setState(() {
            _isLoading = false;
          });
          if (result != 200) {
            if (result == 404) {
              mToast().errorMessage('Email ou mot de passe incorrect');
              return;
            }
            if (result == 400) {
              return;
            }
          }
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => LaunchScreen()));
        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'CONNEXION',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat-bold',
          ),
        ),
      ),
    );
  }

  Widget _buildSignupBtn() {
    return Column(
      children: <Widget>[
        Text(
          'Vous n\'avez pas de compte?',
          style: TextStyle(
              color: Colors.white,
              letterSpacing: 1.5,
              fontSize: 14.5,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold),
        ),
        InkWell(
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => SignupScreen()));
          },
          child: Container(
            margin: EdgeInsets.only(top: 20.0),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.white),
                borderRadius: BorderRadius.circular(30.0)),
            child: Text(
              'Devient un vendeur',
              style: TextStyle(
                  color: Colors.white,
                  letterSpacing: 1.5,
                  fontSize: 14.5,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold),
            ),
          ),
        )
      ],
    );
  }

  bool _inputsValidate() {
    if (EmailController.text.isEmpty || PasswordCottroller.text.isEmpty) {
      Toast.show('Remplir les champs', context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.TOP,
          backgroundColor: Color(0xAABF3D69));
      return false;
    }
    if (EmailController.text.length < 5 ||
        !EmailController.text.contains('@')) {
      Toast.show('Vérifier votre email', context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.TOP,
          backgroundColor: Color(0xAABF3D69));
      return false;
    }
    if (PasswordCottroller.text.length < 6) {
      Toast.show('Mot de passe +6 charactere', context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.TOP,
          backgroundColor: Color(0xAABF3D69));
      return false;
    }

    return true;
  }

  Widget _passwordFoget() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF73AEF5),
            Color(0xFF61A4F1),
            Color(0xFF478DE0),
            Color(0xFF398AE5),
          ],
          stops: [0.1, 0.4, 0.7, 0.9],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 120.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FadeAnimation(
                    1,
                    Text(
                      'Récupération',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontSize: 30.0,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  FadeAnimation(
                    1,
                    Text(
                      ' de mot de passe',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontSize: 20.0,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 30.0),
                  FadeAnimation(1.1, _forgetEmailTF()),
                  SizedBox(
                    height: 30.0,
                  ),
                  FadeAnimation(1.2, _forgetPhoneTF()),
                  FadeAnimation(1.3, _buildResetPasswordBtn()),
                ],
              ),
            ),
          ),
          FadeAnimation(
            1,
            Container(
              width: 40.0,
              height: 40.0,
              margin: EdgeInsets.only(top: 40.0, left: 15.0),
              child: FloatingActionButton(
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 20.0,
                ),
                backgroundColor: Color(0x55000000),
                onPressed: () {
                  setState(() {
                    _isPasswordForget = false;
                  });
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _forgetEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Email',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: _frogetEmailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Montserrat',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.white,
              ),
              hintText: 'Entrer votre email',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _forgetPhoneTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'N° Téléphone',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: _frogetPhoneController,
            keyboardType: TextInputType.phone,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Montserrat',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.phone_iphone,
                color: Colors.white,
              ),
              hintText: 'Entrer votre N° téléphone',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResetPasswordBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () async {
          int result = await Mservice().setSellerPassword(
              _frogetEmailController.text, _frogetPhoneController.text);
          if (result != 200) {
            if (result == 404) {
              mToast().infoMessage('Informations fausses');
            }
            if (result == 400) return;
            return;
          }
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => LoginScreen()));
        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'ENVOYER',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat-bold',
          ),
        ),
      ),
    );
  }
}
