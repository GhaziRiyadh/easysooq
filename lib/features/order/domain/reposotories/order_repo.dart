import 'package:dio/dio.dart';
import 'package:flutter_grocery/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_grocery/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_grocery/common/models/place_order_model.dart';
import 'package:flutter_grocery/features/order/domain/models/review_body_model.dart';
import 'package:flutter_grocery/common/models/api_response_model.dart';
import 'package:flutter_grocery/helper/date_converter_helper.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderRepo {
  final DioClient? dioClient;
  final SharedPreferences? sharedPreferences;
  OrderRepo({required this.dioClient, required this.sharedPreferences,});

  Future<ApiResponseModel> getOrderList() async {
    try {
      final response = await dioClient!.get(AppConstants.orderListUri);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }


  Future<ApiResponseModel> getOrderDetails(String? orderID, String? phoneNumber) async {
    try {
      final response = await dioClient!.post(AppConstants.orderDetailsUri, data: {
        'order_id' : orderID, 'phone' : phoneNumber == 'null' ? null : phoneNumber,
      });
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> cancelOrder(String orderID) async {
    try {
      Map<String, dynamic> data = <String, dynamic>{};
      data['order_id'] = orderID;
      data['_method'] = 'put';
      final response = await dioClient!.post(AppConstants.orderCancelUri, data: data);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> trackOrder(String? orderID, String? phoneNumber) async {
    try {
      final response = await dioClient!.post(AppConstants.trackUri, data: {
        'order_id' : orderID, 'phone' : phoneNumber == 'null' ? null : phoneNumber,
      });
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> placeOrder(PlaceOrderModel orderBody, {List<XFile?>? imageNote}) async {
    try {
      final response = await dioClient!.postMultipart(
        AppConstants.placeOrderUri,
        files: imageNote ?? [],
        fileKey: 'order_images',
        data: orderBody.toJson(),
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> getDeliveryManData({String? deliverymanId, String? orderId}) async {
    try {
      final response = await dioClient!.get('${AppConstants.lastLocationUri}$deliverymanId&order_id=$orderId');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> getTimeSlot() async {
    try {
      final response = await dioClient!.get(AppConstants.timeslotUri);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  List<String> getDateList() {
    List<String> dates = [];
    dates.add(DateConverterHelper.slotDate(DateTime.now()));
    dates.add(DateConverterHelper.slotDate(DateTime.now().add(const Duration(days: 1))));
    dates.add(DateConverterHelper.slotDate(DateTime.now().add(const Duration(days: 2))));

    return dates;
  }


  Future<ApiResponseModel> submitReview(ReviewBodyModel reviewBody, List<XFile?>? files) async {
    try {
      final response = await dioClient!.postMultipart(AppConstants.reviewUri, data: reviewBody.toJson(), files: files, fileKey: files != null ? 'attachment' : null);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> submitDeliveryManReview(ReviewBodyModel reviewBody) async {
    try {
      final response = await dioClient!.post(AppConstants.deliveryManReviewUri, data: reviewBody);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> getDistanceInMeter(LatLng originLatLng, LatLng destinationLatLng) async {
    try {
      Response response = await dioClient!.get('${AppConstants.distanceMatrixUri}'
          '?origin_lat=${originLatLng.latitude}&origin_lng=${originLatLng.longitude}'
          '&destination_lat=${destinationLatLng.latitude}&destination_lng=${destinationLatLng.longitude}');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel>  storeOfflineData({String? orderId, String? isPartial, OfflinePaymentInfo? paymentInfo}) async {
    try {
      final response = await dioClient!.post(AppConstants.storeOfflineData, data: {
        "order_id" : orderId,
        "is_partial" : isPartial,
        'payment_info' : paymentInfo?.toJson()
      });
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<void>  setLastIncompleteOfflineBookingId(int bookingId) async {
    await sharedPreferences?.setInt(AppConstants.lastIncompleteOfflineBookingId, bookingId);
  }

  int getLastIncompleteOfflineBookingId() {
    return sharedPreferences?.getInt(AppConstants.lastIncompleteOfflineBookingId) ?? 0;
  }

  Future<ApiResponseModel>  switchPaymentMethod({required String orderId,  required String paymentMethod,  int isPartial = 0, double? bringChangeAmount}) async {
    try {
      final response = await dioClient!.post(AppConstants.switchPaymentMethod, data: {
        "order_id" : orderId,
        "is_partial" : isPartial,
        "payment_method" : paymentMethod,
        "bring_change_amount" : bringChangeAmount
      });
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> getDigitalPaymentResponse({String? transactionId}) async {
    try {
      final response = await dioClient!.get("${AppConstants.digitalPaymentResponse}?transaction_id=$transactionId");
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

}