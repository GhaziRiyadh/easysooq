class DistanceModel {
  //List<Rows>? rows;
  double? distanceMeters;


  DistanceModel(
      {
        //this.rows,
        this.distanceMeters,
      });

  DistanceModel.fromJson(Map<String, dynamic> json) {
    // if (json['rows'] != null) {
    //   rows = [];
    //   json['rows'].forEach((v) {
    //     rows!.add(Rows.fromJson(v));
    //   });
    // }
    distanceMeters =  double.tryParse(json['distanceMeters'].toString());

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // if (rows != null) {
    //   data['rows'] = rows!.map((v) => v.toJson()).toList();
    // }
    data['distanceMeters'] = distanceMeters;
    return data;
  }
}

// class Rows {
//   List<Elements>? elements;
//
//   Rows({this.elements});
//
//   Rows.fromJson(Map<String, dynamic> json) {
//     if (json['elements'] != null) {
//       elements = [];
//       json['elements'].forEach((v) {
//         elements!.add(Elements.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     if (elements != null) {
//       data['elements'] = elements!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class Elements {
//   Distance? distance;
//   Distance? duration;
//   String? status;
//
//   Elements({this.distance, this.duration, this.status});
//
//   Elements.fromJson(Map<String, dynamic> json) {
//     distance = json['distance'] != null
//         ? Distance.fromJson(json['distance'])
//         : null;
//     duration = json['duration'] != null
//         ? Distance.fromJson(json['duration'])
//         : null;
//     status = json['status'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     if (distance != null) {
//       data['distance'] = distance!.toJson();
//     }
//     if (duration != null) {
//       data['duration'] = duration!.toJson();
//     }
//     data['status'] = status;
//     return data;
//   }
// }
//
// class Distance {
//   String? text;
//   double? value;
//
//   Distance({this.text, this.value});
//
//   Distance.fromJson(Map<String, dynamic> json) {
//     text = json['text'];
//     value = json['value'].toDouble();
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['text'] = text;
//     data['value'] = value;
//     return data;
//   }
// }
