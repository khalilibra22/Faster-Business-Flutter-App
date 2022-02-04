import 'package:FasterBusiness/classes/Product.dart';

import 'OrderedProduct.dart';

class Order {
  String orderId;
  String buyername;
  String buyerAddress;
  String buyerPhone;
  var lat;
  var long;
  var deliveryTime;
  var creationTime;
  List<OrderProductItem> products = List<OrderProductItem>();
  var isActive;

  Order();

  double getTotal() {
    double sum = 0.0;

    for (int i = 0; i < products.length; i++) {
      sum += products[i].prod.price * products[i].quantity;
    }
    return sum;
  }

  void addProduct(Product product, int quantity) {
    OrderProductItem item = OrderProductItem();
    item.prod = product;
    item.quantity = quantity;
    products.add(item);
  }
}
