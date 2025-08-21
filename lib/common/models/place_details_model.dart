class PlaceDetailsModel {
  String? name;
  String? id;
  List<String>? types;
  String? formattedAddress;
  Location? location;
  DisplayName? displayName;

  PlaceDetailsModel(
      {this.name,
        this.id,
        this.types,
        this.formattedAddress,
        this.location,
        this.displayName});

  PlaceDetailsModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    types = json['types'].cast<String>();
    formattedAddress = json['formattedAddress'];
    location = json['location'] != null
        ? Location.fromJson(json['location'])
        : null;
    displayName = json['displayName'] != null
        ? DisplayName.fromJson(json['displayName'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['id'] = id;
    data['types'] = types;
    data['formattedAddress'] = formattedAddress;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    if (displayName != null) {
      data['displayName'] = displayName!.toJson();
    }
    return data;
  }
}

class Location {
  double? latitude;
  double? longitude;

  Location({this.latitude, this.longitude});

  Location.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}

class DisplayName {
  String? text;
  String? languageCode;

  DisplayName({this.text, this.languageCode});

  DisplayName.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    languageCode = json['languageCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['languageCode'] = languageCode;
    return data;
  }
}
