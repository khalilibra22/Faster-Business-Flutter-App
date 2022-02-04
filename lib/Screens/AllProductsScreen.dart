import 'package:FasterBusiness/Screens/ProductDetails.dart';
import 'package:FasterBusiness/classes/Product.dart';
import 'package:FasterBusiness/classes/mService.dart';
import 'package:FasterBusiness/config/CheckConnection.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AllProductsPage extends StatefulWidget {
  @override
  _AllProductsPageState createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  @override
  bool _isEmptyList = false;
  bool _isLoading = true;

  @override
  void initState() {
    _getData().then((value) => this._chnageScreen());
    super.initState();
  }

  Future _getData() async {
    bool result = await Mservice().getSellerProducts();
    if (!result) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => NoConnection()));
      return;
    }
    if (Mservice.products.isEmpty) {
      setState(() {
        _isEmptyList = true;
      });
    }
  }

  void _chnageScreen() {
    setState(() {
      _isLoading = false;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF24ACF2),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                Container(
                    width: 125.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[],
                    ))
              ],
            ),
          ),
          SizedBox(height: 25.0),
          Padding(
            padding: EdgeInsets.only(left: 40.0),
            child: Row(
              children: <Widget>[
                Text('FASTER',
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0)),
                SizedBox(width: 10.0),
                Text('Produits',
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontSize: 25.0))
              ],
            ),
          ),
          SizedBox(height: 40.0),
          Container(
            height: MediaQuery.of(context).size.height - 180.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(75.0)),
            ),
            child: Stack(
              children: <Widget>[
                RefreshIndicator(
                  onRefresh: () async {
                    try {
                      setState(() {
                        _isLoading = true;
                      });
                      await _getData().then((value) => this._chnageScreen());
                      return true;
                    } catch (e) {}
                  },
                  child: ListView(
                    primary: false,
                    padding: EdgeInsets.only(left: 0.0, right: 20.0),
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(top: 60.0),
                          child: Container(
                              height:
                                  MediaQuery.of(context).size.height - 240.0,
                              child: _isLoading
                                  ? _loadingDataAnimation()
                                  : (!_isEmptyList
                                      ? ListView.builder(
                                          itemCount: Mservice.products.length,
                                          itemBuilder: (context, index) =>
                                              _buildProductItem(
                                                  Mservice.products[index],
                                                  index))
                                      : _emptyProductsList()))),
                      SizedBox(height: 10.0),
                    ],
                  ),
                ),
                Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                        margin: EdgeInsets.only(bottom: 25.0, right: 25.0),
                        child: FloatingActionButton(
                            backgroundColor: Color(0xFF24ACF2),
                            child: Icon(
                              Icons.add,
                              size: 30.0,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ProductDetails(
                                      prodId: -1, isNewProduct: true)));
                            }))),
                Container(
                  margin: EdgeInsets.only(top: 10.0),
                  height: 45.0,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.arrow_drop_down_circle,
                        color: Colors.grey,
                      ),
                      Text('Glisser pour acualiser',
                          style: TextStyle(
                              fontFamily: 'Montserrat-bold',
                              color: Colors.grey,
                              fontSize: 14.0)),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProductItem(Product mProduct, int position) {
    return Dismissible(
      onDismissed: (direction) {
        setState(() {
          var prodId = Mservice.products[position].id;
          Mservice.products.removeAt(position);
          _deleteProduct(prodId);
        });
      },
      key: Key(Mservice.products[position].name + position.toString()),
      background: Container(
        padding: EdgeInsets.only(left: 13.0),
        color: Colors.red[500],
        child: Row(
          children: <Widget>[
            Icon(
              Icons.remove_circle,
              color: Colors.white,
            ),
            SizedBox(
              width: 5.0,
            ),
            Text('Supprimer',
                style: TextStyle(
                    fontFamily: 'Montserrat-bold',
                    fontSize: 12.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      child: Padding(
          padding: EdgeInsets.only(left: 25.0, right: 15.0, top: 10.0),
          child: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProductDetails(
                          prodId: position,
                          isNewProduct: false,
                        )));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                      child: Row(children: [
                    Hero(
                        tag: position,
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(35.0),
                                image: DecorationImage(
                                    image: NetworkImage(mProduct.image),
                                    fit: BoxFit.cover)),
                            height: 70.0,
                            width: 70.0)),
                    SizedBox(width: 10.0),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(mProduct.name,
                              style: TextStyle(
                                  fontFamily: 'Montserrat-bold',
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.bold)),
                          Container(
                            width: 170,
                            child: Text(mProduct.price.toString() + ' DA',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                    fontFamily: 'Montserrat-bold',
                                    fontSize: 17.0,
                                    color: Colors.green)),
                          ),
                        ])
                  ])),
                  Icon(Icons.arrow_forward_ios,
                      size: 22.0, color: Color(0xFF24ACF2)),
                ],
              ))),
    );
  }

  Future _deleteProduct(var prodId) async {
    bool result = await Mservice().deleteProduct(prodId);
  }

  Widget _emptyProductsList() {
    return Container(
      margin: EdgeInsets.only(top: 100.0),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.grid_off,
            color: Colors.grey[500],
            size: 70.0,
          ),
          SizedBox(
            height: 10.0,
          ),
          Text("Il n' y a pas des produits",
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                  fontFamily: 'Montserrat-bold',
                  fontSize: 14.0,
                  color: Colors.grey[500])),
          SizedBox(
            height: 10.0,
          ),
          Text("Créer un nouveau",
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                  fontFamily: 'Montserrat-bold',
                  fontSize: 14.0,
                  color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _loadingDataAnimation() {
    return Shimmer.fromColors(
        child: ListView(
          primary: false,
          padding: EdgeInsets.only(left: 35.0, right: 0.0),
          children: <Widget>[
            SizedBox(
              height: 0.0,
            ),
            _animationItem(),
            SizedBox(
              height: 13.0,
            ),
            _animationItem(),
            SizedBox(
              height: 13.0,
            ),
            _animationItem(),
            SizedBox(
              height: 13.0,
            ),
            _animationItem(),
            SizedBox(
              height: 13.0,
            ),
            _animationItem(),
            SizedBox(
              height: 13.0,
            ),
            _animationItem()
          ],
        ),
        baseColor: Colors.grey[400],
        highlightColor: Colors.grey[500]);
  }

  Widget _animationItem() {
    return Container(
        alignment: Alignment.centerLeft,
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Container(
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(35.0),
              ),
              height: 70.0,
              width: 70.0),
          SizedBox(width: 5.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  height: 12.0,
                  width: 100.0),
              SizedBox(
                height: 5.0,
              ),
              Container(
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  height: 12.0,
                  width: 200.0),
              SizedBox(
                height: 5.0,
              ),
              Container(
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  height: 12.0,
                  width: 210),
              SizedBox(
                height: 5.0,
              ),
              /* Container(
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  height: 12.0,
                  width: 150.0), */
            ],
          )
        ]));
  }
}
