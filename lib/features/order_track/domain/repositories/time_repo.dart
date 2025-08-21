import 'package:flutter_grocery/common/models/api_response_model.dart';
import 'package:flutter_grocery/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_grocery/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrackerRepo {
  final DioClient? dioClient;
  final SharedPreferences? sharedPreferences;
  TrackerRepo({required this.dioClient, required this.sharedPreferences});


  Future<ApiResponseModel> getDeliveryManData({int? deliverymanId, int? orderId}) async {
    try {
      final response = await dioClient!.get('${AppConstants.lastLocationUri}$deliverymanId&order_id=$orderId');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }


}