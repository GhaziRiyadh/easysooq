import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/api_response_model.dart';
import 'package:flutter_grocery/common/models/response_model.dart';
import 'package:flutter_grocery/features/order/domain/models/order_details_model.dart';
import 'package:flutter_grocery/features/order/domain/models/review_body_model.dart';
import 'package:flutter_grocery/features/order/domain/reposotories/order_repo.dart';
import 'package:image_picker/image_picker.dart';


class ReviewProvider extends ChangeNotifier {
  final OrderRepo? orderRepo;
  ReviewProvider({required this.orderRepo});

  bool _isLoading = false;
  List<int> _ratingList = [];
  List<String> _reviewList = [];
  List<bool> _loadingList = [];
  List<bool> _submitList = [];
  bool _deliverymanReviewSubmitted = false;
  int _deliveryManRating = 0;

  bool get isLoading => _isLoading;
  List<int> get ratingList => _ratingList;
  List<String> get reviewList => _reviewList;
  List<bool> get loadingList => _loadingList;
  List<bool> get submitList => _submitList;
  int get deliveryManRating => _deliveryManRating;
  bool get deliverymanReviewSubmitted => _deliverymanReviewSubmitted;

  List<ProductWiseReviewImage> _reviewImageList = [];
  List<ProductWiseReviewImage> get reviewImageList => _reviewImageList;

  void initRatingData(List<OrderDetailsModel> orderDetailsList) {
    _ratingList = [];
    _reviewList = [];
    _loadingList = [];
    _submitList = [];
    _deliveryManRating = 0;
    _reviewImageList = [];
    _deliverymanReviewSubmitted = false;
    for (int i = 0; i < orderDetailsList.length; i++) {
      _ratingList.add(0);
      _reviewList.add('');
      _loadingList.add(false);
      _submitList.add(false);
      _reviewImageList.add(ProductWiseReviewImage(orderDetailsList[i].productId!, []));
    }
  }

  void setRating(int index, int rate) {
    _ratingList[index] = rate;
    notifyListeners();
  }

  void setReview(int index, String review) {
    _reviewList[index] = review;
  }

  void setDeliveryManRating(int rate) {
    _deliveryManRating = rate;
    notifyListeners();
  }

  Future<ResponseModel> submitReview(int index, ReviewBodyModel reviewBody) async {
    _loadingList[index] = true;
    notifyListeners();

    ApiResponseModel response = await orderRepo!.submitReview(reviewBody, _reviewImageList[index].image);
    ResponseModel responseModel;
    if (response.response != null && response.response!.statusCode == 200) {
      _submitList[index] = true;
      responseModel = ResponseModel(true, 'Review submitted successfully');
      notifyListeners();
    } else {
      String? errorMessage;
      if(response.error is String) {
        errorMessage = response.error.toString();
      }else {
        errorMessage = response.error.errors[0].message;
      }
      responseModel = ResponseModel(false, errorMessage);
    }
    _loadingList[index] = false;
    notifyListeners();
    return responseModel;
  }

  Future<ResponseModel> submitDeliveryManReview(ReviewBodyModel reviewBody) async {
    _isLoading = true;
    notifyListeners();
    ApiResponseModel response = await orderRepo!.submitDeliveryManReview(reviewBody);
    ResponseModel responseModel;
    if (response.response != null && response.response!.statusCode == 200) {
      _deliverymanReviewSubmitted = true;
      responseModel = ResponseModel(true, 'Review submitted successfully');
      notifyListeners();
    } else {
      String? errorMessage;
      if(response.error is String) {
        errorMessage = response.error.toString();
      }else {
        errorMessage = response.error.errors[0].message;
      }
      responseModel = ResponseModel(false, errorMessage);
    }
    _isLoading = false;
    notifyListeners();
    return responseModel;
  }



  void pickImage(bool isRemove, int productId) async {
    try{
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 30);
      if(pickedImage != null){
        for(ProductWiseReviewImage productWiseReviewImage in _reviewImageList){
          if(productWiseReviewImage.productId == productId){
            if(!productWiseReviewImage.image!.contains(pickedImage)){
              productWiseReviewImage.image!.add(pickedImage);
            }
          }
        }
      }
    }catch(error) {
      debugPrint('$error');
    }
    notifyListeners();
  }


  void removeImage(int index , int productId){
    for(ProductWiseReviewImage productWiseReviewImage in reviewImageList){
      if(productWiseReviewImage.productId == productId){
        productWiseReviewImage.image!.removeAt(index);
      }
    }
    notifyListeners();
  }

  void updateDeliverymanReviewSubmittedStatus({bool value = false}){
    _deliverymanReviewSubmitted = value;
    notifyListeners();
  }
  
}

class ProductWiseReviewImage {
  int productId;
  List<XFile>? image;

  ProductWiseReviewImage(this.productId, this.image);

  @override
  String toString() {
    String imageString = (image == null || image!.isEmpty)
        ? 'No images'
        : image!.map((file) => file.path).join(', ');

    return 'ProductWiseReview(productId: $productId, image: $imageString)';
  }
}