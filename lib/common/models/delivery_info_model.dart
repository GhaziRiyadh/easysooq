class DeliveryInfoModel {
  int? id;
  String? name;
  int? status;
  DeliveryChargeSetup? deliveryChargeSetup;
  List<DeliveryChargeByArea>? deliveryChargeByArea;
  bool? deliveryWeightSettingsStatus;
  String? deliveryWeightChargeType;
  String? deliveryCountChargeFrom;
  String? deliveryAdditionalChargePerUnit;
  String? deliveryCountChargeFromOperation;
  List<DeliveryWeightRange>? deliveryWeightRange;

  DeliveryInfoModel({
    this.id,
    this.name,
    this.status,
    this.deliveryChargeSetup,
    this.deliveryChargeByArea,
    this.deliveryWeightSettingsStatus,
    this.deliveryWeightChargeType,
    this.deliveryCountChargeFrom,
    this.deliveryAdditionalChargePerUnit,
    this.deliveryCountChargeFromOperation,
    this.deliveryWeightRange,
  });

  DeliveryInfoModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        status = json['status'],
        deliveryChargeSetup = json['delivery_charge_setup'] != null
            ? DeliveryChargeSetup.fromJson(json['delivery_charge_setup'])
            : null,
        deliveryChargeByArea = json['delivery_charge_by_area'] != null
            ? (json['delivery_charge_by_area'] as List)
            .map((v) => DeliveryChargeByArea.fromJson(v))
            .toList()
            : null,
        deliveryWeightSettingsStatus = "${json['delivery_weight_settings_status']}" == '1',
        deliveryWeightChargeType = json['delivery_weight_charge_type'],
        deliveryCountChargeFrom = json['delivery_count_charge_from'],
        deliveryAdditionalChargePerUnit = json['delivery_additional_charge_per_unit'],
        deliveryCountChargeFromOperation = json['delivery_count_charge_from_operation'],
        deliveryWeightRange = json['delivery_weight_range'] != null
            ? (json['delivery_weight_range'] as List)
            .map((v) => DeliveryWeightRange.fromJson(v))
            .toList()
            : null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'status': status,
    'delivery_charge_setup': deliveryChargeSetup?.toJson(),
    'delivery_charge_by_area':
    deliveryChargeByArea?.map((v) => v.toJson()).toList(),
    'delivery_weight_settings_status': deliveryWeightSettingsStatus == true ? 1 : 0,
    'delivery_weight_charge_type': deliveryWeightChargeType,
    'delivery_count_charge_from': deliveryCountChargeFrom,
    'delivery_additional_charge_per_unit': deliveryAdditionalChargePerUnit,
    'delivery_count_charge_from_operation': deliveryCountChargeFromOperation,
    'delivery_weight_range':
    deliveryWeightRange?.map((v) => v.toJson()).toList(),
  };
}

class DeliveryChargeSetup {
  int? id;
  int? branchId;
  String? deliveryChargeType;
  double? deliveryChargePerKilometer;
  double? minimumDeliveryCharge;
  double? minimumDistanceForFreeDelivery;
  double? fixedDeliveryCharge;
  String? createdAt;
  String? updatedAt;

  DeliveryChargeSetup({
    this.id,
    this.branchId,
    this.deliveryChargeType,
    this.deliveryChargePerKilometer,
    this.minimumDeliveryCharge,
    this.minimumDistanceForFreeDelivery,
    this.fixedDeliveryCharge,
    this.createdAt,
    this.updatedAt,
  });

  DeliveryChargeSetup.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        branchId = json['branch_id'],
        deliveryChargeType = json['delivery_charge_type'],
        deliveryChargePerKilometer = double.tryParse(json['delivery_charge_per_kilometer'].toString()),
        minimumDeliveryCharge = double.tryParse(json['minimum_delivery_charge'].toString()),
        minimumDistanceForFreeDelivery = double.tryParse(json['minimum_distance_for_free_delivery'].toString()),
        fixedDeliveryCharge = double.tryParse(json['fixed_delivery_charge'].toString()),
        createdAt = json['created_at'],
        updatedAt = json['updated_at'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'branch_id': branchId,
    'delivery_charge_type': deliveryChargeType,
    'delivery_charge_per_kilometer': deliveryChargePerKilometer,
    'minimum_delivery_charge': minimumDeliveryCharge,
    'minimum_distance_for_free_delivery': minimumDistanceForFreeDelivery,
    'fixed_delivery_charge': fixedDeliveryCharge,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class DeliveryChargeByArea {
  int? id;
  int? branchId;
  String? areaName;
  double? deliveryCharge;
  String? createdAt;
  String? updatedAt;

  DeliveryChargeByArea({
    this.id,
    this.branchId,
    this.areaName,
    this.deliveryCharge,
    this.createdAt,
    this.updatedAt,
  });

  DeliveryChargeByArea.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        branchId = json['branch_id'],
        areaName = json['area_name'],
        deliveryCharge = double.tryParse(json['delivery_charge'].toString()),
        createdAt = json['created_at'],
        updatedAt = json['updated_at'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'branch_id': branchId,
    'area_name': areaName,
    'delivery_charge': deliveryCharge,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class DeliveryWeightRange {
  String? minWeight;
  String? minOperation;
  String? maxWeight;
  String? maxOperation;
  String? deliveryCharge;

  DeliveryWeightRange({
    this.minWeight,
    this.minOperation,
    this.maxWeight,
    this.maxOperation,
    this.deliveryCharge,
  });

  DeliveryWeightRange.fromJson(Map<String, dynamic> json)
      : minWeight = json['min_weight'],
        minOperation = json['min_operation'],
        maxWeight = json['max_weight'],
        maxOperation = json['max_operation'],
        deliveryCharge = json['delivery_charge'];

  Map<String, dynamic> toJson() => {
    'min_weight': minWeight,
    'min_operation': minOperation,
    'max_weight': maxWeight,
    'max_operation': maxOperation,
    'delivery_charge': deliveryCharge,
  };
}