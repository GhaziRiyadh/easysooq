class PaymentResponseModel {
  String? orderId;


  PaymentResponseModel(
      {this.orderId});

  PaymentResponseModel.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_id'] = orderId;
    return data;
  }
}