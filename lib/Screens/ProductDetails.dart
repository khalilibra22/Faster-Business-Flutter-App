import 'package:FasterBusiness/classes/mService.dart';
import 'package:FasterBusiness/config/CheckConnection.dart';
import 'package:FasterBusiness/config/CustomToast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

class ProductDetails extends StatefulWidget {
  final prodId;
  bool isNewProduct;

  ProductDetails({this.prodId, this.isNewProduct});
  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  File _productImage = null;
  //bool isNewProduct;
  final _productNameController = TextEditingController();
  final _productPriceController = TextEditingController();
  final _productDescController = TextEditingController();
  final picker = ImagePicker();

  @override
  void initState() {
    if (widget.prodId > -1) {
      _productNameController.text = Mservice.products[widget.prodId].name;
      _productPriceController.text =
          Mservice.products[widget.prodId].price.toString();
      _productDescController.text = Mservice.products[widget.prodId].desc;
    }

    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.only(top: 0.0),
            decoration: BoxDecoration(
              color: Color(0xFFFFFFFF),
            ),
            child: Container(
              margin: EdgeInsets.only(bottom: 5.0),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: widget.isNewProduct
                          ? () {
                              getImageFromGallery();
                            }
                          : null,
                      child: Stack(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              height: 250.0,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(25.0),
                                      topRight: Radius.circular(25.0)),
                                  image: DecorationImage(
                                      image: widget.prodId > -1
                                          ? NetworkImage(Mservice
                                              .products[widget.prodId].image)
                                          : (_productImage == null
                                              ? AssetImage(
                                                  'assets/uploadprod.jpg')
                                              : FileImage(_productImage)),
                                      fit: BoxFit.cover)),
                            ),
                          ),
                          widget.isNewProduct
                              ? Transform.translate(
                                  offset: const Offset(150.0, 230.0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      height: 40.0,
                                      width: 40.0,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          color: Color(0xFF24ACF2)),
                                      child: Icon(
                                        Icons.add_photo_alternate,
                                        color: Colors.white,
                                        size: 20.0,
                                      ),
                                    ),
                                  ),
                                )
                              : Container()
                        ],
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.only(top: 35.0, left: 20.0, right: 20.0),
                      child: Column(
                        children: <Widget>[
                          _buildTextField(
                              'Nom de produit',
                              'Entrer le nom de produit',
                              Icons.add_shopping_cart,
                              TextInputType.text,
                              _productNameController,
                              50.0),
                          SizedBox(
                            height: 10.0,
                          ),
                          _buildTextField(
                              'Prix (DZD)',
                              'Entrer le prix de produit',
                              Icons.monetization_on,
                              TextInputType.number,
                              _productPriceController,
                              50.0),
                          SizedBox(
                            height: 10.0,
                          ),

                          _buildTextField(
                              'Detaille',
                              'Détailles sur le produit',
                              Icons.more,
                              TextInputType.multiline,
                              _productDescController,
                              150.0),
                          SizedBox(
                            height: 10.0,
                          ),
                          //_categoriesList(),
                          SizedBox(
                            height: 10.0,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10.0),
                            width: double.infinity,
                            child: RaisedButton(
                              onPressed: () async {
                                if (!_inputsValidation()) return;
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
                                if (widget.prodId == -1) {
                                  bool result = await Mservice().addNewProduct(
                                      _productNameController.text,
                                      _productPriceController.text,
                                      _productDescController.text,
                                      1,
                                      _productImage);

                                  if (!result) {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                NoConnection()));
                                    return;
                                  }
                                  Navigator.pop(context);
                                } else {
                                  bool result = await Mservice().updateProduct(
                                      Mservice.products[widget.prodId].id,
                                      _productNameController.text,
                                      _productPriceController.text,
                                      1,
                                      _productDescController.text);
                                  if (!result) {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                NoConnection()));
                                    return;
                                  }
                                  Navigator.pop(context);
                                }
                              },
                              padding: EdgeInsets.all(16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              color: Color(0xFFFBBE07),
                              child: Text(
                                widget.prodId == -1 ? 'Ajouter' : 'Mise à jour',
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
                    SizedBox(
                      height: 30.0,
                    )
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 30.0, left: 8.0),
            height: 40.0,
            width: 40.0,
            child: FloatingActionButton(
              backgroundColor: Color(0x83000000),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back_ios,
                size: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String title, String hint, final icon, final type,
      final controller, double height) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            fontSize: 15.0,
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.topLeft,
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
          height: height,
          child: TextField(
            controller: controller,
            keyboardType: type,
            minLines: 1,
            maxLines: 3,
            style: TextStyle(
              fontSize: 15.0,
              color: Colors.black,
              fontFamily: 'Montserrat',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                icon,
                color: Colors.grey,
              ),
              hintText: 'Entrer les infrormations ici',
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

  Future getImageFromGallery() async {
    try {
      final pickedImage = await picker.getImage(source: ImageSource.gallery);
      setState(() {
        _productImage = File(pickedImage.path);
      });
    } catch (e) {}
  }

  bool _inputsValidation() {
    if (_productImage == null && widget.prodId == -1) {
      mToast().errorMessage('Ajouter l\'image de votre produit');
      return false;
    }
    if (_productNameController.text.length < 5) {
      mToast().errorMessage('Le nom de produit est trés court');
      return false;
    }
    if (_productPriceController.text.isEmpty) {
      mToast().errorMessage('Donner le prix de votre produit');
      return false;
    }
    if (_productDescController.text.isEmpty) {
      mToast().errorMessage('Donner la description de votre produit');
      return false;
    }
    return true;
  }
}
