import 'package:FasterBusiness/Screens/OrderDetails.dart';
import 'package:FasterBusiness/classes/mService.dart';
import 'package:FasterBusiness/config/CheckConnection.dart';
import 'package:FasterBusiness/config/CustomToast.dart';
import 'package:FasterBusiness/config/mLocation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:shimmer/shimmer.dart';
import '../classes/Order.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LocationData _mloc = null;
  bool _isLoading = true;
  List<Color> backgroundColors = [
    Color(0xFF0075B6),
    Color(0xFFDB7A67),
    Color(0xFFF1A522),
    Color(0xFF26AC7F),
    Color(0xFFD95380)
  ];
  //FirebaseMessaging _firebaseMessage = FirebaseMessaging();
  @override
  void initState() {
    _loadData().then((value) => this._changeLoadingScreen());
    //_firebaseMessage.getToken().then((token) => print(token));

    super.initState();
  }

  Future _loadData() async {
    Mlocation loc = Mlocation();
    await loc.grantPermission();
    if (Mservice.userLocation != null) {
      bool setPosition = await Mservice().setSellerPosition(
          Mservice.userLocation.latitude, Mservice.userLocation.longitude);
    }

    bool result = await Mservice().getActiveOrders();
    if (!result) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => NoConnection()));
      return;
    }
  }

  void _changeLoadingScreen() {
    setState(() {
      _isLoading = false;
    });
  }

  Future<bool> _onRefresh() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await _loadData().then((value) => this._changeLoadingScreen());
      return true;
    } catch (e) {}
  }

  Widget build(BuildContext context) {
    return Scaffold(
        //backgroundColor: Color(0xFF5094E5),
        body: Stack(
      children: <Widget>[
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
              image: DecorationImage(
            image: NetworkImage(
                'http://ec2-3-137-146-7.us-east-2.compute.amazonaws.com/upload/images/ordercover.jpg'),
            fit: BoxFit.cover,
          )),
        ),
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Tout les commandes',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0)),
              SizedBox(
                height: 10.0,
              ),
              Text('# commandes: ' + Mservice.orders.length.toString(),
                  style: TextStyle(
                      fontFamily: 'Montserrat-bold',
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0)),
            ],
          ),
          margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.4 - 90,
              left: 40.0,
              right: 40.0),
          height: 120.0,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black38, blurRadius: 30, offset: Offset(0, 10))
            ],
          ),
        ),
        RefreshIndicator(
          onRefresh: _onRefresh,
          child: Container(
            margin: EdgeInsets.only(
                top: (MediaQuery.of(context).size.height * 0.4) + 50,
                left: 15.0,
                right: 15.0),
            child: _isLoading
                ? _loadingDataAnimation()
                : (Mservice.orders.isNotEmpty
                    ? ListView.builder(
                        itemCount: Mservice.orders.length,
                        itemBuilder: (context, index) =>
                            _ordersListItem(Mservice.orders[index], index))
                    : _listEmpty()),
          ),
        )
      ],
    ));
  }

  Widget _ordersListItem(Order order, int position) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => OrderDetails(
                  orderIndex: position,
                )));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 15.0, right: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  height: 80.0,
                  width: 80.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40.0),
                      color: backgroundColors[position % 5]
                      /* image: DecorationImage(
                          image: AssetImage('assets/product.jpg'),
                          fit: BoxFit.cover) */
                      ),
                  child: Text(order.buyername.substring(0, 2).toUpperCase(),
                      style: TextStyle(
                          letterSpacing: 3,
                          fontFamily: 'Montserrat-bold',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0)),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(order.buyername,
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0)),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                        'Creé le : ' +
                            order.creationTime.toString().substring(0, 16),
                        style: TextStyle(
                            fontFamily: 'Montserrat-bold',
                            color: Colors.grey[600],
                            fontSize: 14.0)),
                    SizedBox(
                      height: 5.0,
                    ),
                    Row(
                      children: <Widget>[
                        Text('Statut: ',
                            style: TextStyle(
                                fontFamily: 'Montserrat-bold',
                                color: Colors.black,
                                fontSize: 14.0)),
                        order.isActive == 0
                            ? Text('En attente ',
                                style: TextStyle(
                                    fontFamily: 'Montserrat-bold',
                                    color: Colors.red[400],
                                    fontSize: 14.0))
                            : Text('Livré',
                                style: TextStyle(
                                    fontFamily: 'Montserrat-bold',
                                    color: Colors.green[400],
                                    fontSize: 14.0)),
                      ],
                    )
                  ],
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.blue,
              size: 25,
            )
          ],
        ),
      ),
    );
  }

  Widget _loadingDataAnimation() {
    return Shimmer.fromColors(
        child: ListView(
          //primary: false,
          //padding: EdgeInsets.only(left: 55.0, right: 40.0),
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
        highlightColor: Colors.grey[300]);
  }

  Widget _animationItem() {
    return Container(
        alignment: Alignment.centerLeft,
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Container(
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(40.0),
              ),
              height: 80.0,
              width: 80.0),
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
                  width: 220.0),
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
                  width: 230),
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
                  width: 150.0),
            ],
          )
        ]));
  }

  Widget _listEmpty() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: ListView(
          children: <Widget>[
            Shimmer.fromColors(
              baseColor: Colors.grey[500],
              highlightColor: Colors.grey[400],
              child: Icon(
                Icons.grid_off,
                color: Colors.grey[500],
                size: 80.0,
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Center(
              child: Text('Il n\' y a pas des commandes maitenant',
                  style: TextStyle(
                      fontFamily: 'Montserrat-bold',
                      color: Colors.grey[500],
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0)),
            ),
            SizedBox(
              height: 5.0,
            ),
            Center(
              child: Text('Glisser pour actualiser',
                  style: TextStyle(
                      fontFamily: 'Montserrat-bold',
                      color: Colors.grey[500],
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0)),
            ),
            Shimmer.fromColors(
              baseColor: Colors.grey[500],
              highlightColor: Colors.grey[400],
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 60.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
