import 'dart:io';
import 'package:FasterBusiness/Screens/LoginScreen.dart';
import 'package:FasterBusiness/classes/mService.dart';
import 'package:FasterBusiness/config/CustomToast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';

class CompleteInfo extends StatefulWidget {
  @override
  _CompleteInfoState createState() => _CompleteInfoState();
}

class _CompleteInfoState extends State<CompleteInfo> {
  final _sellerNameController = TextEditingController();
  final _sellerPhoneController = TextEditingController();
  final _sellerEmailController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _storeAddressController = TextEditingController();
  final _sellerDeliveryTimeController = TextEditingController();
  final _sellerCodeController = TextEditingController();
  File _profilImage = null;
  final picker = ImagePicker();
  bool _isPresonalInfoValidated,
      _isStoreInfoValidated,
      _isCodevalidated = false;

  FirebaseMessaging _firebaseMessage = FirebaseMessaging();

  @override
  void initState() {
    _sellerEmailController.text = Mservice.mSeller.email;
    _sellerPhoneController.text = Mservice.mSeller.phone;
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
              height: double.infinity,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(top: 40.0, left: 10.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          child: IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                        ),
                        Text(
                          'Inscription',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Montserrat-bold',
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          width: 50.0,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    InkWell(
                      onTap: getImageFromGallery,
                      child: Stack(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              height: 100.0,
                              width: 100.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50.0),
                                  image: DecorationImage(
                                      image: _profilImage == null
                                          ? AssetImage('assets/avatar.png')
                                          : FileImage(_profilImage),
                                      fit: BoxFit.cover)),
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(35, 75.0),
                            child: Align(
                              alignment: Alignment.center,
                              child: Container(
                                height: 30.0,
                                width: 30.0,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.blue),
                                child: Icon(
                                  Icons.add_photo_alternate,
                                  color: Colors.white,
                                  size: 18.0,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 22.0,
                    ),
                    Text(
                      Mservice.mSeller.storeName ?? 'Nom de boutique',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Montserrat',
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      Mservice.mSeller.email,
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Montserrat',
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15.0),
                      width: 230.0,
                      child: RaisedButton(
                        onPressed: () async {
                          try {
                            if (_profilImage == null) {
                              mToast().errorMessage(
                                  'Selectioner une image de profile');
                              return;
                            }
                            if (_isPresonalInfoValidated == false ||
                                _isStoreInfoValidated == false ||
                                _isCodevalidated == false) {
                              mToast()
                                  .errorMessage('Remplir les infomations SVP');
                              return;
                            }
                            //_loadAnimation();
                            int checkCode = await Mservice()
                                .checkSellerCode(_sellerCodeController.text);
                            if (checkCode == 400) {/*no connection*/}
                            if (checkCode == 404) {
                              mToast().errorMessage("code n'est pas valide");
                              return;
                            }
                            if (checkCode == 200) {
                              bool changeCodeStatue = await Mservice()
                                  .changeCodeStatue(_sellerCodeController.text);

                              await _firebaseMessage.getToken().then((token) =>
                                  Mservice.mSeller.notificationToken = token);
                              print(Mservice.mSeller.notificationToken);

                              bool result = await Mservice()
                                  .createNewSeller(_profilImage);
                              Navigator.pop(context);
                              if (result) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => LoginScreen()));
                              } else
                                return;
                            }
                          } catch (e) {}
                        },
                        padding: EdgeInsets.all(13.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        color: Color(0xFFFBBE07),
                        child: Text(
                          'Confirmer',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                    ),
                    _storeInfo()
                  ],
                ),
              )),
        ),
      ),
    );
  }

  Future getImageFromGallery() async {
    try {
      final pickedImage = await picker.getImage(source: ImageSource.gallery);
      setState(() {
        _profilImage = File(pickedImage.path);
      });
    } catch (e) {}
  }

  Widget _storeInfo() {
    return Container(
      margin: EdgeInsets.only(top: 40.0),
      child: Column(
        children: <Widget>[
          _sellerInfoItem(),
          _storeInfoItem(),
          _checkingItem(),
          _cancelItem()
        ],
      ),
    );
  }

  Widget _sellerInfoItem() {
    return InkWell(
      onTap: () {
        _bottomPopupSheetSeller(context);
      },
      child: Container(
        margin:
            EdgeInsets.only(left: 40.0, right: 45.0, top: 20.0, bottom: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.person_pin,
                  size: 24.0,
                ),
                SizedBox(
                  width: 18.0,
                ),
                Text(
                  'Information presonel',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
            )
          ],
        ),
      ),
    );
  }

  Widget _storeInfoItem() {
    return InkWell(
      onTap: () {
        _bottomPopupSheetStore(context);
      },
      child: Container(
        margin:
            EdgeInsets.only(left: 40.0, right: 45.0, top: 20.0, bottom: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.shopping_basket,
                  size: 24.0,
                ),
                SizedBox(
                  width: 18.0,
                ),
                Text(
                  'Boutique',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18.0,
            )
          ],
        ),
      ),
    );
  }

  Widget _checkingItem() {
    return InkWell(
      onTap: () {
        _bottomPopupSheetChecking(context);
      },
      child: Container(
        margin:
            EdgeInsets.only(left: 40.0, right: 45.0, top: 20.0, bottom: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.security,
                  size: 24.0,
                ),
                SizedBox(
                  width: 15.0,
                ),
                Text(
                  'Vérification',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18.0,
            )
          ],
        ),
      ),
    );
  }

  Widget _cancelItem() {
    return InkWell(
      onTap: () {
        Mservice.mSeller.fullName = null;
        Mservice.mSeller.storeName = null;
        Mservice.mSeller.password = null;
        Mservice.mSeller.phone = null;
        Mservice.mSeller.address = null;
        Mservice.mSeller.email = null;
        Mservice.mSeller.code = null;

        Navigator.pop(context);
      },
      child: Container(
        margin: EdgeInsets.only(left: 40.0, right: 20.0, top: 20.0),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.cancel,
              size: 24.0,
            ),
            SizedBox(
              width: 15.0,
            ),
            Text(
              'Annuler l\'inscription',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'N° Téléphone',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(width: 2, color: Colors.grey),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 50.0,
          child: TextField(
            controller: _sellerPhoneController,
            keyboardType: TextInputType.phone,
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Montserrat',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.phone_android,
                color: Colors.grey,
              ),
              hintText: 'Entrer votre N° téléphone',
              hintStyle: TextStyle(
                color: Colors.grey,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Email',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(width: 2, color: Colors.grey),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 50.0,
          child: TextField(
            controller: _sellerEmailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Montserrat',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.grey,
              ),
              hintText: 'Entrer votre email',
              hintStyle: TextStyle(
                color: Colors.grey,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSellerNameTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Nom Complet',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
              fontSize: 14.0),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(width: 2, color: Colors.grey),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 50.0,
          child: TextField(
            controller: _sellerNameController,
            keyboardType: TextInputType.text,
            style: TextStyle(
              color: Colors.black,
              fontSize: 15.0,
              fontFamily: 'Montserrat',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.person,
                color: Colors.grey,
              ),
              hintText: 'Entrer votre nom',
              hintStyle: TextStyle(
                color: Colors.grey,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoreNameTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Nom de boutique',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
              fontSize: 15.0),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(width: 2, color: Colors.grey),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 50.0,
          child: TextField(
            controller: _storeNameController,
            keyboardType: TextInputType.text,
            style: TextStyle(
                color: Colors.black, fontFamily: 'Montserrat', fontSize: 15.0),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.store,
                color: Colors.grey,
              ),
              hintText: 'Entrer le nom de boutique',
              hintStyle: TextStyle(
                color: Colors.grey,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoreAddressTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Adresse',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
              fontSize: 15.0),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(width: 2, color: Colors.grey),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 50.0,
          child: TextField(
            controller: _storeAddressController,
            keyboardType: TextInputType.text,
            style: TextStyle(
                color: Colors.black, fontFamily: 'Montserrat', fontSize: 15.0),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.location_on,
                color: Colors.grey,
              ),
              hintText: 'Entrer l\'adresse de boutique',
              hintStyle: TextStyle(
                color: Colors.grey,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryTimeTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Temps de livraison (h)',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
              fontSize: 15.0),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(width: 2, color: Colors.grey),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 50.0,
          child: TextField(
            controller: _sellerDeliveryTimeController,
            keyboardType: TextInputType.number,
            style: TextStyle(
                color: Colors.black, fontFamily: 'Montserrat', fontSize: 15.0),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.location_on,
                color: Colors.grey,
              ),
              hintText: 'Entrer le temps de livraison',
              hintStyle: TextStyle(
                color: Colors.grey,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSerialTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Code',
          style: TextStyle(
            fontSize: 15.0,
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(width: 2, color: Colors.grey),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 50.0,
          child: TextField(
            controller: _sellerCodeController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 15.0,
              color: Colors.black,
              fontFamily: 'Montserrat',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.confirmation_number,
                color: Colors.grey,
              ),
              hintText: 'Entrer votre code',
              hintStyle: TextStyle(
                color: Colors.grey,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _bottomPopupSheetSeller(context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height - 150,
            padding: EdgeInsets.only(top: 8.0),
            decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0))),
            child: Container(
              margin: EdgeInsets.only(top: 40.0, left: 45.0, right: 45.0),
              child: ListView(
                children: <Widget>[
                  _buildSellerNameTF(),
                  SizedBox(
                    height: 15.0,
                  ),
                  _buildPhoneTF(),
                  SizedBox(
                    height: 15.0,
                  ),
                  _buildEmailTF(),
                  SizedBox(
                    height: 15.0,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15.0),
                    width: 230.0,
                    child: RaisedButton(
                      onPressed: () {
                        if (!_userInfoInputsValidation()) return;
                        setState(() {
                          Mservice.mSeller.fullName =
                              _sellerNameController.text;
                          Mservice.mSeller.email = _sellerEmailController.text;
                          Mservice.mSeller.phone = _sellerPhoneController.text;
                        });
                        Navigator.pop(context);
                      },
                      padding: EdgeInsets.all(16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      color: Color(0xFFFBBE07),
                      child: Text(
                        'Sauvgarder',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        backgroundColor: Colors.transparent);
  }

  void _bottomPopupSheetStore(context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height - 150,
            padding: EdgeInsets.only(top: 8.0),
            decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0))),
            child: Container(
              margin: EdgeInsets.only(top: 40.0, left: 45.0, right: 45.0),
              child: ListView(
                children: <Widget>[
                  _buildStoreNameTF(),
                  SizedBox(
                    height: 15.0,
                  ),
                  _buildStoreAddressTF(),
                  SizedBox(
                    height: 15.0,
                  ),
                  _buildDeliveryTimeTF(),
                  SizedBox(
                    height: 15.0,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15.0),
                    width: 230.0,
                    child: RaisedButton(
                      onPressed: () {
                        if (!_storeInfoInputsvalidation()) return;
                        setState(() {
                          Mservice.mSeller.address =
                              _storeAddressController.text;
                          Mservice.mSeller.storeName =
                              _storeNameController.text;
                          Mservice.mSeller.deliveryTime =
                              _sellerDeliveryTimeController.text;
                        });
                        Navigator.pop(context);
                      },
                      padding: EdgeInsets.all(16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      color: Color(0xFFFBBE07),
                      child: Text(
                        'Sauvgarder',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        backgroundColor: Colors.transparent);
  }

  void _bottomPopupSheetChecking(context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height - 150,
            padding: EdgeInsets.only(top: 8.0),
            decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0))),
            child: Container(
              margin: EdgeInsets.only(top: 40.0, left: 45.0, right: 45.0),
              child: ListView(
                children: <Widget>[
                  _buildSerialTF(),
                  SizedBox(
                    height: 15.0,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15.0),
                    width: 230.0,
                    child: RaisedButton(
                      onPressed: () {
                        if (_sellerCodeController.text.isEmpty) {
                          mToast()
                              .errorMessage('Entrer le code de confirmation ');
                          return;
                        }
                        _isCodevalidated = true;
                        Mservice.mSeller.code = _sellerCodeController.text;
                        Navigator.pop(context);
                      },
                      padding: EdgeInsets.all(16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      color: Color(0xFFFBBE07),
                      child: Text(
                        'Sauvgarder',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Si vous n\'avez pas un code d'entré\n\n",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      final Uri _emailLaunchUri = Uri(
                          scheme: 'mailto',
                          path: 'faster_business@outlook.com',
                          queryParameters: {
                            'subject': 'Code d\'inscription : FASTER business'
                          });

                      launch(_emailLaunchUri.toString());
                    },
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Nous contacter',
                        style: TextStyle(
                          color: Colors.red[300],
                          fontSize: 17.0,
                          fontFamily: 'Montserrat-bold',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                ],
              ),
            ),
          );
        },
        backgroundColor: Colors.transparent);
  }

  bool _userInfoInputsValidation() {
    if (_sellerNameController.text.length < 5) {
      mToast().errorMessage('Nom trés est court ');
      return false;
    }
    if (_sellerPhoneController.text.length < 5) {
      mToast().errorMessage('Vérifier votre N° téléphone');
      return false;
    }
    if (_sellerEmailController.text.length < 5 ||
        !_sellerEmailController.text.contains('@')) {
      mToast().errorMessage('Vérifier votre email');
      return false;
    }
    _isPresonalInfoValidated = true;
    return true;
  }

  bool _storeInfoInputsvalidation() {
    if (_storeNameController.text.length < 4) {
      mToast().errorMessage('Nom de boutique est trés court');
      return false;
    }
    if (_storeAddressController.text.length < 4) {
      mToast().errorMessage('adresse est trés court');
      return false;
    }
    if (_storeAddressController.text.isEmpty) {
      mToast().errorMessage('Donnez un temps de livraison');
      return false;
    }
    _isStoreInfoValidated = true;
    return true;
  }

  void _loadAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Shimmer.fromColors(
          baseColor: Colors.grey[400],
          highlightColor: Colors.grey[500],
          child: Text(
            'Traitement...',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 15.0,
              fontFamily: 'Montserrat-bold',
            ),
          ),
        ),
        content: Container(
          height: 80.0,
          width: 80.0,
          child: SpinKitDoubleBounce(
            color: Colors.green,
            size: 70.0,
          ),
        ),
      ),
    );
  }
}
