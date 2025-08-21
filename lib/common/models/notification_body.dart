class NotificationBody {
  String? title;
  String? body;
  int? orderId;
  String? type;
  String? image;
  String? userImage;
  String? userName;
  String? senderType;

  NotificationBody({this.title, this.body, this.orderId, this.type, this.userImage, this.userName, this.senderType});

  NotificationBody.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    body = json['body'];
    type = json['type'];
    image = (json['image'] != null && json['image'] !="") ? json['image'] : null;
    userImage = json['profile_image'] != null && json['profile_image'] != "" ? json['profile_image'] : null;
    userName = json['name'] != null && json['name'] != "" ? json['name'] : null;
    orderId = int.tryParse(json['order_id'].toString());
    senderType = json['sender_type'] != null && json['sender_type'] != "" ? json['sender_type'] : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['body'] = body;
    data['type'] = type;
    data['image'] = image;
    data['profile_image'] = userImage;
    data['name'] = userName;
    data['order_id'] = type;
    data['sender_type'] = senderType;
    return data;
  }
}
