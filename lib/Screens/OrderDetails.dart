import 'package:FasterBusiness/classes/OrderedProduct.dart';
import 'package:FasterBusiness/classes/mService.dart';
import 'package:FasterBusiness/config/CheckConnection.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../config/mLocation.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class OrderDetails extends StatefulWidget {
  final orderIndex;
  OrderDetails({this.orderIndex});
  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  bool _isLoading = true;
  DateTime mTime = null;
  LatLng _sellerLocation = null;
  LatLng _buyerLocation = null;
  String _deliveryTime = DateTime.now().toString();
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  bool _isPopup = false;
  bool _isfinished = false;
  GoogleMapController _controller;
  Set<Marker> _markers = {};
  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    print(Mservice.orders[widget.orderIndex].deliveryTime);
    _date = Mservice.orders[widget.orderIndex].deliveryTime ??
        DateTime.now().add(Duration(hours: 2));
    _loadData().then((value) => this._changeScreen());
    super.initState();
  }

  Widget build(BuildContext context) {
    // Start Location Marker

    mTime = Mservice.orders[widget.orderIndex].deliveryTime;
    return Scaffold(
      body: _isLoading
          ? _loadingScreen()
          : Stack(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.4,
                  color: Colors.grey[400],
                  child: GoogleMap(
                    markers:
                        _markers != null ? Set<Marker>.from(_markers) : null,
                    onMapCreated: _onMapCreated,
                    initialCameraPosition:
                        CameraPosition(target: _buyerLocation, zoom: 14.0),
                    mapType: MapType.normal,
                    //polylines: Set<Polyline>.of(polylines.values),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.4 + 20.0,
                      left: 15.0),
                  width: double.infinity,
                  child: CustomScrollView(slivers: <Widget>[
                    SliverToBoxAdapter(
                        child: Container(
                            margin: EdgeInsets.only(
                                top: 5.0, left: 0.0, right: 15.0),
                            //height: 120.0,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                color: Color(0xF7FD5D3D6)),
                            padding: EdgeInsets.only(
                                top: 10.0,
                                left: 15.0,
                                right: 10.0,
                                bottom: 15.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(children: <Widget>[
                                  Icon(Icons.person, color: Colors.blue),
                                  SizedBox(
                                    width: 7.0,
                                  ),
                                  Text(
                                      Mservice
                                          .orders[widget.orderIndex].buyername,
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0)),
                                ]),
                                SizedBox(
                                  height: 5.0,
                                ),
                                InkWell(
                                  onTap: () async {
                                    try {
                                      await launch(
                                          'tel:${Mservice.orders[widget.orderIndex].buyerPhone}');
                                    } catch (e) {}
                                  },
                                  onLongPress: () async {
                                    try {
                                      await launch(
                                          'tel:${Mservice.orders[widget.orderIndex].buyerPhone}');
                                    } catch (e) {}
                                  },
                                  child: Row(children: <Widget>[
                                    Icon(Icons.phone_iphone,
                                        color: Colors.green[500]),
                                    SizedBox(
                                      width: 7.0,
                                    ),
                                    Text(
                                        Mservice.orders[widget.orderIndex]
                                            .buyerPhone,
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.0)),
                                  ]),
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                Row(children: <Widget>[
                                  Icon(Icons.location_on,
                                      color: Colors.red[300]),
                                  SizedBox(
                                    width: 7.0,
                                  ),
                                  Text(
                                      Mservice.orders[widget.orderIndex]
                                                  .buyerAddress ==
                                              'null'
                                          ? 'Voir sur le map ...'
                                          : Mservice.orders[widget.orderIndex]
                                              .buyerAddress,
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0)),
                                ]),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(children: <Widget>[
                                      Icon(Icons.date_range,
                                          color: Colors.purpleAccent),
                                      SizedBox(
                                        width: 7.0,
                                      ),
                                      Text(
                                          'Jour de livraison: ' +
                                              mTime.toString().substring(0, 10),
                                          style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.0)),
                                    ]),
                                    FlatButton(
                                        onPressed: () async {
                                          _date = await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2020),
                                              lastDate: DateTime(2030));
                                          if (_date == null) return;
                                          setState(() {
                                            _deliveryTime =
                                                '${_date.toString().substring(0, 10)} ${_time.toString().substring(10, 15)}:00';
                                            mTime =
                                                DateTime.parse(_deliveryTime);
                                          });

                                          print(DateTime.parse(_deliveryTime));
                                          DateTime mmTime =
                                              DateTime.parse(_deliveryTime);

                                          bool result = await Mservice()
                                              .setDeliveryTime(
                                                  widget.orderIndex, mmTime);
                                        },
                                        child: Text('Changer',
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                color: Colors.red[400],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13.0)))
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(children: <Widget>[
                                      Icon(Icons.watch_later,
                                          color: Colors.brown),
                                      SizedBox(
                                        width: 7.0,
                                      ),
                                      Text(
                                          'Temps de livraison: ' +
                                              mTime
                                                  .toString()
                                                  .substring(10, 16),
                                          style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.0)),
                                    ]),
                                    FlatButton(
                                        onPressed: () async {
                                          _time = await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now());
                                          if (_time == null) return;
                                          setState(() {
                                            _deliveryTime =
                                                '${_date.toString().substring(0, 10)} ${_time.toString().substring(10, 15)}:00';
                                            mTime =
                                                DateTime.parse(_deliveryTime);
                                            //print(_deliveryTime);
                                          });

                                          DateTime mmTime =
                                              DateTime.parse(_deliveryTime);

                                          bool result = await Mservice()
                                              .setDeliveryTime(
                                                  widget.orderIndex, mmTime);
                                          if (!result) return;
                                        },
                                        child: Text('Changer',
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                color: Colors.red[400],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13.0)))
                                  ],
                                ),
                                Row(children: <Widget>[
                                  Mservice.orders[widget.orderIndex].isActive ==
                                          0
                                      ? Icon(Icons.warning,
                                          color: Colors.red[500])
                                      : Icon(Icons.check_circle,
                                          color: Colors.green[500]),
                                  SizedBox(
                                    width: 7.0,
                                  ),
                                  Mservice.orders[widget.orderIndex].isActive ==
                                          0
                                      ? Text('En attente',
                                          style: TextStyle(
                                              fontFamily: 'Montserrat-bold',
                                              color: Colors.red[500],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.0))
                                      : Text('Livré',
                                          style: TextStyle(
                                              fontFamily: 'Montserrat-bold',
                                              color: Colors.green[500],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.0)),
                                ]),
                                Align(
                                  child: Container(
                                    margin: EdgeInsets.only(top: 15.0),
                                    //width: 230.0,
                                    child: RaisedButton(
                                      onPressed: () async {
                                        setState(() {
                                          _isPopup = true;
                                        });
                                        bool result = await Mservice()
                                            .completeOrder(widget.orderIndex);
                                        if (!result) {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      NoConnection()));
                                          return;
                                        }
                                        _isfinished = result;
                                        setState(() {
                                          Mservice.orders[widget.orderIndex]
                                              .isActive = 1;
                                        });
                                      },
                                      padding: EdgeInsets.all(13.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                      color: Color(0xFFFBBE07),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.check_circle),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                          Text(
                                            'Livré',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Montserrat',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ))),
                    SliverToBoxAdapter(
                      child: Container(
                        height: 10.0,
                      ),
                    ),
                    SliverToBoxAdapter(
                        child: Container(
                      margin: EdgeInsets.only(top: 5.0, left: 0.0, right: 15.0),
                      //height: 120.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: Color(0xF7FD5D3D6)),
                      padding: EdgeInsets.only(
                          top: 10.0, left: 10.0, right: 10.0, bottom: 15.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Les produits commandés',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat-bold',
                              )),
                          SizedBox(
                            height: 8.0,
                          ),
                          Row(
                            children: <Widget>[
                              Text('Total:',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Montserrat-bold',
                                  )),
                              SizedBox(
                                width: 5.0,
                              ),
                              Text(
                                  Mservice.orders[widget.orderIndex]
                                          .getTotal()
                                          .toString() +
                                      ' DZD',
                                  style: TextStyle(
                                    color: Colors.green[500],
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Montserrat-bold',
                                  ))
                            ],
                          ),
                          /*  SizedBox(
                            height: 15.0,
                          ),
                          Column(
                            children: <Widget>[
                              _productListItem(),
                              _productListItem(),
                              _productListItem(),
                              _productListItem(),
                              _productListItem(),
                              _productListItem()
                            ],
                          ) */
                        ],
                      ),
                    )),
                    SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                      return _productListItem(
                          Mservice.orders[widget.orderIndex].products[index]);
                    },
                            childCount: Mservice
                                .orders[widget.orderIndex].products.length))
                  ]),
                ),
                _buyerLocation == LatLng(0.0, 0.0)
                    ? Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.4,
                        color: Color(0x99000000),
                        child: Icon(
                          Icons.location_off,
                          size: 60.0,
                          color: Colors.white,
                        ))
                    : Container(),
                Container(
                  height: 40.0,
                  width: 40.0,
                  margin: EdgeInsets.only(top: 30.0, left: 20.0),
                  child: FloatingActionButton(
                    backgroundColor: Color(0x33000000),
                    child: Icon(
                      Icons.arrow_left,
                      color: Colors.white,
                      size: 38.0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                _isPopup ? _orderCompletedPopup() : Container(),
              ],
            ),
    );
  }

  Widget _productListItem(OrderProductItem item) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0), color: Color(0xF7FD5D3D6)),
      margin: EdgeInsets.only(bottom: 10.0, top: 10.0, right: 15.0),
      child: Row(
        children: <Widget>[
          Container(
            height: 78.0,
            width: 85.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.0),
                    bottomLeft: Radius.circular(12.0)),
                image: DecorationImage(
                    image: NetworkImage(item.prod.image), fit: BoxFit.cover)),
          ),
          SizedBox(
            width: 8.0,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(item.prod.name,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat-bold',
                    )),
                SizedBox(
                  height: 4.0,
                ),
                Row(
                  children: <Widget>[
                    Text('Prix:',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat-bold',
                        )),
                    SizedBox(
                      width: 5.0,
                    ),
                    Text(item.prod.price.toString() + ' DZD',
                        style: TextStyle(
                          color: Colors.green[500],
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat-bold',
                        ))
                  ],
                ),
                SizedBox(
                  height: 4.0,
                ),
                Row(
                  children: <Widget>[
                    Text('Qnt:',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat-bold',
                        )),
                    SizedBox(
                      width: 5.0,
                    ),
                    Text(item.quantity.toString(),
                        style: TextStyle(
                          color: Colors.red[400],
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat-bold',
                        ))
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  /* Future _getSellerLocation() async {
    Mlocation location = Mlocation();
    await location.grantPermission();

    LocationData mLocaation = await location.getLocation();
    _sellerLocation = LatLng(mLocaation.latitude, mLocaation.longitude);
  } */

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

  Future _loadData() async {
    bool result = await Mservice().getOrderProducts(widget.orderIndex);
    if (!result) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => NoConnection()));
      return;
    }
    /* await _getSellerLocation();
    if (_sellerLocation == null) return; */
    if (Mservice.orders[widget.orderIndex].lat == 0 ||
        Mservice.orders[widget.orderIndex].long == 0) {
      _buyerLocation = LatLng(0.0, 0.0);
      print('no location ');
      return;
    }
    _buyerLocation = LatLng(Mservice.orders[widget.orderIndex].lat,
        Mservice.orders[widget.orderIndex].long);

    print(_buyerLocation.latitude);
    print(_buyerLocation.longitude);

    /*  Marker startMarker = Marker(
      markerId: MarkerId('seller'),
      position: _sellerLocation,
      infoWindow: InfoWindow(
        title: 'VOUS',
        //snippet: _startAddress,
      ),
      icon: BitmapDescriptor.defaultMarker,
    ); */

// Destination Location Marker
    Marker destinationMarker = Marker(
      markerId: MarkerId('buyer'),
      position: _buyerLocation,
      infoWindow: InfoWindow(
        title: 'Client',
        //snippet: _destinationAddress,
      ),
      icon: BitmapDescriptor.defaultMarker,
    );
    //_markers.add(startMarker);
    _markers.add(destinationMarker);
    //_createPolylines(_sellerLocation, _buyerLocation);
  }

  void _changeScreen() {
    setState(() {
      _isLoading = false;
    });
  }

  Widget _orderCompletedPopup() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Color(0xAA000000),
      child: !_isfinished
          ? SpinKitRing(
              color: Colors.green,
              size: 50.0,
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 60.0,
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text('Cammande livré',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat-bold',
                    )),
                SizedBox(
                  height: 5.0,
                ),
                FlatButton(
                  color: Colors.green[300],
                  onPressed: () => Navigator.pop(context),
                  child: Text('Retour',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat-bold',
                      )),
                )
              ],
            ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;
    });
  }

  /* void _createPolylines(LatLng start, LatLng destination) async {
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyDo3IiIHUbtvgD6FvJkqeTAKM3ixGU9fx4', // Google Maps API Key
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.driving,
    );

    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    // Defining an ID
  } */
}
