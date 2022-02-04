import 'package:FasterBusiness/classes/mService.dart';
import 'package:FasterBusiness/config/CheckConnection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shimmer/shimmer.dart';

class AccountSettings extends StatefulWidget {
  @override
  _AccountSettingsState createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  @override
  final _sellerNameController = TextEditingController();
  final _sellerPhoneController = TextEditingController();
  final _sellerEmailController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _storeAddressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _deliveryTimeController = TextEditingController();
  bool _passwordHashed = true;
  String _image;
  String _storeName;
  String _sellerEmail;
  bool _isLoading = true;

  @override
  void initState() {
    _loadData().then((value) => this._changeLoadScreen());
    super.initState();
  }

  Future _loadData() async {
    bool result = await Mservice().getSellerInfo();
    _sellerNameController.text = Mservice.mSeller.fullName;
    _sellerEmailController.text = Mservice.mSeller.email;
    _sellerPhoneController.text = Mservice.mSeller.phone;
    _storeNameController.text = Mservice.mSeller.storeName;
    _storeAddressController.text = Mservice.mSeller.address;
    _deliveryTimeController.text = Mservice.mSeller.deliveryTime.toString();
    _passwordController.text = 'JeSuisMotDePasse!';
    _image = Mservice.mSeller.profileImg;
    _storeName = Mservice.mSeller.storeName;
    _sellerEmail = Mservice.mSeller.email;
  }

  void _changeLoadScreen() {
    setState(() {
      _isLoading = false;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: _isLoading
              ? _loadingScreen()
              : Container(
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
                              'Votre Compte',
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
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 100.0,
                            width: 100.0,
                            decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(50.0),
                                image: DecorationImage(
                                    image: NetworkImage(_image ??
                                        'https://ccivr.com/wp-content/uploads/2019/07/empty-profile.png'),
                                    fit: BoxFit.cover)),
                          ),
                        ),
                        SizedBox(
                          height: 22.0,
                        ),
                        Text(
                          _storeName,
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
                          _sellerEmail,
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
                              bool result = await Mservice().setSellerInfo(
                                  _sellerNameController.text,
                                  _storeNameController.text,
                                  _sellerEmailController.text,
                                  _sellerPhoneController.text,
                                  _storeAddressController.text,
                                  _deliveryTimeController.text);
                              if (!result) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => NoConnection()));
                                return;
                              }
                              Navigator.pop(context);
                            },
                            padding: EdgeInsets.all(13.0),
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
                        _storeInfo()
                      ],
                    ),
                  )),
        ),
      ),
    );
  }

  Widget _storeInfo() {
    return Container(
      margin: EdgeInsets.only(top: 55.0),
      child: Column(
        children: <Widget>[
          _sellerInfoItem(),
          SizedBox(
            height: 5.0,
          ),
          _storeInfoItem(),
          //_checkingItem(),
          SizedBox(
            height: 5.0,
          ),
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

  Widget _cancelItem() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        margin: EdgeInsets.only(left: 40.0, right: 20.0, top: 20.0),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.arrow_back_ios,
              size: 24.0,
            ),
            SizedBox(
              width: 15.0,
            ),
            Text(
              'Retour',
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

  Widget _buildSellerPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Mot de passe',
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
            obscureText: _passwordHashed,
            controller: _passwordController,
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
                Icons.lock,
                color: Colors.grey,
              ),
              suffixIcon: _passwordHashed
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _passwordHashed = !_passwordHashed;
                          _passwordController.clear();
                        });
                      },
                      icon: Icon(Icons.visibility_off))
                  : IconButton(
                      onPressed: () {
                        setState(() {
                          _passwordHashed = !_passwordHashed;
                        });
                      },
                      icon: Icon(Icons.visibility)),
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

  Widget _buildStoreDeliveryTimeTF() {
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
            controller: _deliveryTimeController,
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
                  _buildSellerPasswordTF(),
                  SizedBox(
                    height: 15.0,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15.0),
                    width: 230.0,
                    child: RaisedButton(
                      onPressed: () {
                        setState(() {
                          Mservice.mSeller.fullName =
                              _sellerNameController.text;
                          Mservice.mSeller.phone = _sellerPhoneController.text;
                          Mservice.mSeller.email = _sellerEmailController.text;
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
                  SizedBox(
                    height: 450.0,
                  )
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
                  _buildStoreDeliveryTimeTF(),
                  SizedBox(
                    height: 15.0,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15.0),
                    width: 230.0,
                    child: RaisedButton(
                      onPressed: () {
                        setState(() {
                          Mservice.mSeller.storeName =
                              _storeNameController.text;
                          Mservice.mSeller.address =
                              _storeAddressController.text;
                          Mservice.mSeller.deliveryTime =
                              _deliveryTimeController.text;
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
                  SizedBox(
                    height: 400.0,
                  )
                ],
              ),
            ),
          );
        },
        backgroundColor: Colors.transparent);
  }

  Widget _loadingScreen() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: SpinKitRing(
        color: Colors.blue,
        size: 50.0,
      ),
    );
  }
}
