import 'dart:convert';
import 'package:FasterBusiness/classes/Product.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'Seller.dart';
import 'Order.dart';

class Mservice {
  String _apiUrl = 'http://ec2-3-137-146-7.us-east-2.compute.amazonaws.com/api';
  static Seller mSeller = Seller();
  static List<Product> products = List<Product>();
  static List<Order> orders = List<Order>();
  Dio dio = Dio();
  SharedPreferences _prefs;
  static LocationData userLocation;

  Mservice();

  Future<bool> createNewSeller(File image) async {
    if (image == null) return false;
    String createSellerUrl = _apiUrl + '/sellers/add';
    String imageName = image.path.split('/').last;

    try {
      FormData formData = FormData.fromMap({
        'SellerStorename': mSeller.storeName,
        'SellerFullName': mSeller.fullName,
        'SellerEmail': mSeller.email,
        'SellerPhone': mSeller.phone,
        'SellerPass': mSeller.password,
        'SellerAddress': mSeller.address,
        'SellerImgURL':
            await MultipartFile.fromFile(image.path, filename: imageName),
        'SellerLat': '0',
        'Sellerlong': '0',
        'DeliveryTime': mSeller.deliveryTime,
        'notificationToken': mSeller.notificationToken
      });
      var response = await dio.post(createSellerUrl, data: formData);
      //if (response.statusCode == 400) return false;
      print(response.data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> checkSellerEmail(String email) async {
    String createSellerUrl = _apiUrl + '/sellers/checkemail';
    try {
      var response = await http.post(createSellerUrl,
          body: json.encode({'email': email}),
          headers: {
            "accept": "application/json",
            "content-type": "application/json"
          });

      print(response.body + '\n' + response.statusCode.toString());
      return response.statusCode;
    } catch (e) {
      return 400;
    }
  }

  Future<int> sellerLogin(String email, String password) async {
    String createSellerUrl = _apiUrl + '/sellers/login';

    try {
      var response = await http.post(createSellerUrl,
          headers: {
            "accept": "application/json",
            "content-type": "application/json"
          },
          body: json.encode({'email': email, 'SellerPassword': password}));
      print(response.body);
      Map<String, dynamic> checkToken = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _prefs = await SharedPreferences.getInstance();
        _prefs.setString('token', checkToken['SellerToken']);
        _prefs.setInt('SellerID', checkToken['SellerID']);
      }

      return response.statusCode;
    } catch (e) {
      return 400;
    }
  }

  Future<bool> addNewProduct(
      String prodName, var price, String desc, var category, File image) async {
    if (image == null) return false;
    String createSellerUrl = _apiUrl + '/products';
    String imageName = image.path.split('/').last;

    try {
      FormData formData = FormData.fromMap({
        'ProductName': prodName,
        'SellPrice': price,
        'TimeOfAdd': DateTime.now(),
        'SellerID': await getSellerId(),
        'CategoryID': category,
        'Images': await MultipartFile.fromFile(image.path, filename: imageName),
        'ProdDescription': desc
      });
      dio.options.headers["authorization"] = await getToken();
      var response = await dio.post(
        createSellerUrl,
        data: formData,
      );
      if (response.statusCode == 400) return false;

      print(response.data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> getSellerProducts() async {
    try {
      String authToken = await getToken();
      var sellerId = await getSellerId();
      products.clear();
      String createSellerUrl = _apiUrl + '/products/sellers/$sellerId';
      var response = await http.get(createSellerUrl, headers: {
        "accept": "application/json",
        "content-type": "application/json",
        HttpHeaders.authorizationHeader: authToken,
      });
      Map<String, dynamic> result = jsonDecode(response.body);
      int returnedCode = result['code'];
      if (returnedCode == 0) return false;
      List<dynamic> productsList = result['result'];
      for (int i = 0; i < productsList.length; i++) {
        Product prod = Product(
            result['result'][i]['ProductID'],
            result['result'][i]['ProductName'],
            result['result'][i]['SellPrice'],
            result['result'][i]['Images'],
            result['result'][i]['ProdDescription']);
        products.add(prod);
      }
      //print(response.body);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteProduct(var prodId) async {
    String createSellerUrl = _apiUrl + '/products/delete';
    try {
      String authToken = await getToken();
      var response = await http.put(createSellerUrl,
          headers: {
            "accept": "application/json",
            "content-type": "application/json",
            HttpHeaders.authorizationHeader: authToken,
          },
          body: jsonEncode({'ProductID': prodId}));
      if (response.statusCode == 400) return false;

      print(response.body);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateProduct(var prodId, String name, var price, var category,
      String description) async {
    String createSellerUrl = _apiUrl + '/products/update';
    try {
      String authToken = await getToken();
      var response = await http.put(createSellerUrl,
          headers: {
            "accept": "application/json",
            "content-type": "application/json",
            HttpHeaders.authorizationHeader: authToken,
          },
          body: jsonEncode({
            'ProductID': prodId,
            'ProductName': name,
            'SellPrice': price,
            'CategoryID': category,
            'ProdDescription': description
          }));
      if (response.statusCode == 400) return false;

      print(response.body);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> getSellerInfo() async {
    try {
      String authToken = await getToken();
      var sellerId = await getSellerId();
      String createSellerUrl = _apiUrl + '/sellers/$sellerId';
      var response = await http.get(createSellerUrl, headers: {
        "accept": "application/json",
        "content-type": "application/json",
        HttpHeaders.authorizationHeader: authToken,
      });
      Map<String, dynamic> result = jsonDecode(response.body);
      int returnedCode = result['code'];
      if (returnedCode == 0) return false;
      var reutrnedResult = result['result'];

      mSeller.id = reutrnedResult['SellerID'];
      mSeller.fullName = reutrnedResult['SellerFullName'];
      mSeller.storeName = reutrnedResult['SellerStoreName'];
      mSeller.address = reutrnedResult['SellerAddress'];
      mSeller.email = reutrnedResult['SellerEmail'];
      mSeller.phone = reutrnedResult['SellerPhoneNumber'];
      mSeller.deliveryTime = reutrnedResult['SellerDeliveryTime'];
      mSeller.profileImg = reutrnedResult['SellerProfilImgURL'];

      print(response.body);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setSellerInfo(String sellerName, String storeName, String email,
      String phone, String address, var deliveryTime) async {
    String createSellerUrl = _apiUrl + '/sellers/info';
    try {
      String authToken = await getToken();
      var sellerId = await getSellerId();
      var response = await http.put(createSellerUrl,
          headers: {
            "accept": "application/json",
            "content-type": "application/json",
            HttpHeaders.authorizationHeader: authToken,
          },
          body: jsonEncode({
            'SellerID': sellerId,
            'SellerStorename': storeName,
            'SellerFullName': sellerName,
            'SellerEmail': email,
            'SellerPhone': phone,
            'SellerAddress': address,
            'DeliveryTime': deliveryTime
          }));

      if (response.statusCode == 400) return false;

      print(response.body);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> getActiveOrders() async {
    try {
      var sellerId = await getSellerId();
      String createSellerUrl = _apiUrl + '/orders/sellers/$sellerId';
      orders.clear();
      String authToken = await getToken();
      var response = await http.get(createSellerUrl, headers: {
        "accept": "application/json",
        "content-type": "application/json",
        HttpHeaders.authorizationHeader: authToken,
      });
      print(response.body);

      Map<String, dynamic> result = jsonDecode(response.body);
      int returnedCode = result['code'];
      if (returnedCode == 0) return false;
      List<dynamic> ordersList = result['result'];
      for (int i = 0; i < ordersList.length; i++) {
        Order newOrder = Order();
        newOrder.orderId = ordersList[i]['OrderID'];
        newOrder.buyername = ordersList[i]['RecipientName'];
        newOrder.creationTime =
            DateTime.parse(ordersList[i]['OrderCreationTime']);
        newOrder.isActive = ordersList[i]['IsCompleted'];
        newOrder.buyerAddress = ordersList[i]['RecipientAddress'];
        newOrder.lat = ordersList[i]['RecipientLocLat'];
        newOrder.long = ordersList[i]['RecipientLocLong'];
        newOrder.buyerPhone = ordersList[i]['RecipientPhone'];
        try {
          newOrder.deliveryTime =
              DateTime.parse(ordersList[i]['OrderDeliveryTime']);
        } catch (e) {
          newOrder.deliveryTime = DateTime.now().add(Duration(hours: 5));
        }

        orders.add(newOrder);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> getOrderProducts(var orderIndex) async {
    try {
      String orderId = orders[orderIndex].orderId;
      orders[orderIndex].products.clear();
      String createSellerUrl = _apiUrl + '/orders/$orderId';
      String authToken = await getToken();
      var response = await http.get(createSellerUrl, headers: {
        "accept": "application/json",
        "content-type": "application/json",
        HttpHeaders.authorizationHeader: authToken,
      });

      Map<String, dynamic> result = jsonDecode(response.body);
      int returnedCode = result['code'];
      if (returnedCode == 0) return false;
      List<dynamic> productsList = result['result'];
      for (int i = 0; i < productsList.length; i++) {
        Product newProduct = Product(
            productsList[i]['ProductID'],
            productsList[i]['ProductName'],
            productsList[i]['SellPrice'],
            productsList[i]['Images'],
            null);
        orders[orderIndex].addProduct(newProduct, productsList[i]['Quantity']);
      }
      print(response.body);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> completeOrder(var orderIndex) async {
    try {
      String orderId = orders[orderIndex].orderId;
      String createSellerUrl = _apiUrl + '/orders/complete';
      String authToken = await getToken();
      var response = await http.put(createSellerUrl,
          headers: {
            "accept": "application/json",
            "content-type": "application/json",
            HttpHeaders.authorizationHeader: authToken,
          },
          body: jsonEncode({'OrderID': orderId}));

      if (response.statusCode == 400) return false;

      print(response.body);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setDeliveryTime(var orderIndex, var time) async {
    String orderId = orders[orderIndex].orderId;
    String createSellerUrl = _apiUrl + '/orders/deliveryTime';
    String authToken = await getToken();
    var response = await http.put(createSellerUrl,
        headers: {
          "accept": "application/json",
          "content-type": "application/json",
          HttpHeaders.authorizationHeader: authToken,
        },
        body: jsonEncode(
            {'OrderID': orderId, 'OrderDeliveryTime': time.toString()}));

    //if (response.statusCode == 400) return false;

    print(response.body);

    return true;
  }

  Future<bool> setSellerPosition(var lat, var long) async {
    try {
      String createSellerUrl = _apiUrl + '/sellers/position';
      var sellerId = await getSellerId();
      String authToken = await getToken();
      var response = await http.put(createSellerUrl,
          headers: {
            "accept": "application/json",
            "content-type": "application/json",
            HttpHeaders.authorizationHeader: authToken,
          },
          body: jsonEncode({
            'SellerID': sellerId,
            'SellerLocationLat': lat,
            'SellerLocatonLong': long
          }));

      //if (response.statusCode == 400) return false;

      print(response.body);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> setSellerPassword(String email, String phone) async {
    String createSellerUrl = _apiUrl + '/sellers/setpassword';
    //var sellerId = await getSellerId();
    //String authToken = await getToken();
    var response = await http.post(createSellerUrl,
        headers: {
          "accept": "application/json",
          "content-type": "application/json",
        },
        body: jsonEncode({'email': email, 'SellerPhoneNumber': phone}));

    print(response.body);

    return response.statusCode;
  }

  Future<int> checkSellerCode(var code) async {
    try {
      String createSellerUrl = _apiUrl + '/sellers/code';
      var response = await http.post(createSellerUrl,
          headers: {
            "accept": "application/json",
            "content-type": "application/json",
          },
          body: jsonEncode({'SellerCode': code}));
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 400) return 400;

      Map<String, dynamic> result = jsonDecode(response.body);
      //int returnedCode = result['code'];
      //if (returnedCode == 0) return false;
      List<dynamic> codeList = result['message'];
      if (codeList.isEmpty) return 404;
      if (codeList[0]['isUsed'] == 1) return 404;
      return 200;
    } catch (e) {
      return 400;
    }
  }

  Future<bool> changeCodeStatue(var code) async {
    try {
      String createSellerUrl = _apiUrl + '/sellers/codestatue';
      var response = await http.put(createSellerUrl,
          headers: {
            "accept": "application/json",
            "content-type": "application/json",
          },
          body: jsonEncode({'SellerCode': code}));
      print(response.body);
      print(response.statusCode);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> getToken() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      String token = _prefs.getString('token') ?? '';
      return token;
    } catch (e) {}
  }

  Future<int> getSellerId() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      int token = _prefs.getInt('SellerID') ?? '';
      return token;
    } catch (e) {}
  }

  Future<bool> checkConnection() async {
    try {
      var response = await http.get(_apiUrl);
      if (response.statusCode == 200) return true;
      return false;
    } catch (e) {
      return false;
    }
  }
}
