class PredictionModel {
  PlacePrediction? placePrediction;

  PredictionModel({this.placePrediction});

  PredictionModel.fromJson(Map<String, dynamic> json) {
    placePrediction = json['placePrediction'] != null
        ? PlacePrediction.fromJson(json['placePrediction'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (placePrediction != null) {
      data['placePrediction'] = placePrediction!.toJson();
    }
    return data;
  }
}

class PlacePrediction {
  String? placeId;
  SuggestionText? text;

  PlacePrediction({this.placeId, this.text});

  PlacePrediction.fromJson(Map<String, dynamic> json) {
    placeId = json['placeId'];
    text = json['text'] != null ? SuggestionText.fromJson(json['text']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['placeId'] = placeId;
    if (text != null) {
      data['text'] = text!.toJson();
    }
    return data;
  }
}

class SuggestionText {
  String? text;

  SuggestionText({this.text});

  SuggestionText.fromJson(Map<String, dynamic> json) {
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    return data;
  }
}
