import 'dart:math';

import 'package:FasterBusiness/Screens/AccountSettings.dart';
import 'package:FasterBusiness/Screens/AllProductsScreen.dart';
import 'package:FasterBusiness/Screens/splashScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class DrawerScreen extends StatefulWidget {
  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen>
    with SingleTickerProviderStateMixin {
  bool _isClosedMenu = true;
  SharedPreferences _prefs;
  Offset _productsOffest = Offset(0, 0);
  Offset _ordersOffest = Offset(0, 0);
  Offset _logoutOffest = Offset(0, 0);
  AnimationController animationController;
  Animation degOneTranslationAnimation,
      degTwoTranslationAnimation,
      degThreeTranslationAnimation;
  Animation rotationAnimation;

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    degOneTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.2), weight: 75.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.2, end: 1.0), weight: 25.0),
    ]).animate(animationController);
    degTwoTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.4), weight: 55.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.4, end: 1.0), weight: 45.0),
    ]).animate(animationController);
    degThreeTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.75), weight: 35.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.75, end: 1.0), weight: 65.0),
    ]).animate(animationController);
    rotationAnimation = Tween<double>(begin: 180.0, end: 0.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOut));
    super.initState();
    animationController.addListener(() {
      setState(() {});
    });
  }

  Widget build(BuildContext context) {
    return Positioned(
        right: 30,
        bottom: 30,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
            IgnorePointer(
              child: Container(
                color: Colors
                    .transparent, // comment or change to transparent color
                height: 150.0,
                width: 150.0,
              ),
            ),
            Transform.translate(
              offset: Offset.fromDirection(
                  (3 * pi) / 2, degOneTranslationAnimation.value * 100),
              child: Transform(
                transform: Matrix4.rotationZ(
                    getRadiansFromDegree(rotationAnimation.value))
                  ..scale(degOneTranslationAnimation.value),
                alignment: Alignment.center,
                child: CircularButton(
                  color: Colors.blue,
                  width: 50,
                  height: 50,
                  icon: Icon(
                    Icons.store_mall_directory,
                    color: Colors.white,
                  ),
                  onClick: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AllProductsPage()));
                  },
                ),
              ),
            ),
            Transform.translate(
              offset: Offset.fromDirection(
                  pi, degTwoTranslationAnimation.value * 100),
              child: Transform(
                transform: Matrix4.rotationZ(
                    getRadiansFromDegree(rotationAnimation.value))
                  ..scale(degTwoTranslationAnimation.value),
                alignment: Alignment.center,
                child: CircularButton(
                  color: Colors.black,
                  width: 50,
                  height: 50,
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onClick: () async {
                    _prefs = await SharedPreferences.getInstance();
                    _prefs.remove('token');

                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => LaunchScreen()));
                  },
                ),
              ),
            ),
            Transform.translate(
              offset: Offset.fromDirection(
                  (5 * pi) / 4, degThreeTranslationAnimation.value * 100),
              child: Transform(
                transform: Matrix4.rotationZ(
                    getRadiansFromDegree(rotationAnimation.value))
                  ..scale(degThreeTranslationAnimation.value),
                alignment: Alignment.center,
                child: CircularButton(
                  color: Color(0xFFF1A522),
                  width: 50,
                  height: 50,
                  icon: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                  onClick: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AccountSettings()));
                  },
                ),
              ),
            ),
            Transform(
              transform: Matrix4.rotationZ(
                  getRadiansFromDegree(rotationAnimation.value)),
              alignment: Alignment.center,
              child: CircularButton(
                color: Colors.red,
                width: 60,
                height: 60,
                icon: Icon(
                  _isClosedMenu ? Icons.menu : Icons.close,
                  color: Colors.white,
                ),
                onClick: () {
                  if (animationController.isCompleted) {
                    animationController.reverse();
                    setState(() {
                      _isClosedMenu = true;
                    });
                  } else {
                    animationController.forward();
                    setState(() {
                      _isClosedMenu = false;
                    });
                  }
                },
              ),
            )
          ],
        ));

    /* return Align(
      alignment: Alignment.bottomRight,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Transform.translate(
            offset: _logoutOffest,
            child: Container(
                margin: EdgeInsets.only(right: 35.0, bottom: 35.0),
                height: 50.0,
                width: 50.0,
                child: FloatingActionButton(
                    elevation: 0.0,
                    heroTag: 4,
                    backgroundColor: Color(0xFF000000),
                    child: Icon(Icons.exit_to_app),
                    onPressed: () {})),
          ),
          Transform.translate(
            offset: _ordersOffest,
            child: Container(
                margin: EdgeInsets.only(right: 35.0, bottom: 35.0),
                height: 50.0,
                width: 50.0,
                child: FloatingActionButton(
                    elevation: 0.0,
                    heroTag: 3,
                    backgroundColor: Color(0xFFFF9800),
                    child: Icon(Icons.format_list_bulleted),
                    onPressed: () {})),
          ),
          Transform.translate(
            offset: _productsOffest,
            child: Container(
                margin: EdgeInsets.only(right: 35.0, bottom: 35.0),
                height: 50.0,
                width: 50.0,
                child: FloatingActionButton(
                    elevation: 0.0,
                    heroTag: 2,
                    backgroundColor: Color(0xFF1C3A60),
                    child: Icon(Icons.settings),
                    onPressed: () {})),
          ),
          Container(
              margin: EdgeInsets.only(right: 35.0, bottom: 35.0),
              height: 55.0,
              width: 55.0,
              child: FloatingActionButton(
                  heroTag: 1,
                  backgroundColor: Colors.red[400],
                  child: Icon(Icons.menu),
                  onPressed: () {
                    _openCloseMenu();
                  })),
        ],
      ),
    ); */
  }

  void _openCloseMenu() {
    if (_isClosedMenu) {
      setState(() {
        _isClosedMenu = false;
        _ordersOffest = Offset(10, -90);
        _productsOffest = Offset(-60, -65);
        _logoutOffest = Offset(-85, 10);
      });
    } else {
      setState(() {
        _isClosedMenu = true;
        _ordersOffest = Offset(0, 0);
        _productsOffest = Offset(0, 0);
        _logoutOffest = Offset(0, 0);
      });
    }
  }

  double getRadiansFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }
}

class CircularButton extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final Icon icon;
  final Function onClick;

  CircularButton(
      {this.color, this.width, this.height, this.icon, this.onClick});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      width: width,
      height: height,
      child: IconButton(icon: icon, enableFeedback: true, onPressed: onClick),
    );
  }
}
