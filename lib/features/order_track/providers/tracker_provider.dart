import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/api_response_model.dart';
import 'package:flutter_grocery/features/order/domain/models/delivery_man_model.dart';
import 'package:flutter_grocery/features/order_track/domain/repositories/time_repo.dart';
import 'package:flutter_grocery/helper/api_checker_helper.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackerProvider with ChangeNotifier {
  final TrackerRepo? trackerRepo;
  TrackerProvider({required this.trackerRepo});

  Duration? _duration;

  Timer? _locationServiceTimer;
  Duration? get duration => _duration;
  DeliveryManModel? _deliveryManModel;
  Set<Marker> _markers = {};
  Set<Marker> get markers => _markers;
  bool _isBottomSheetExpanded = false;

  @override
  void dispose() {
    stopLocationService(); // Ensure timer is stopped when provider is disposed
    super.dispose();
  }





  Future<void> startLocationService({int? deliverymanId, int? orderId ,GoogleMapController? mapController, LatLng? userLocation}) async {

    getDeliveryManData(deliverymanId : deliverymanId,orderId: orderId,  mapController: mapController, userLocation: userLocation);

    _locationServiceTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      getDeliveryManData(deliverymanId : deliverymanId, orderId: orderId, mapController: mapController, userLocation: userLocation);

      if (kDebugMode) {
        print("------------------------- Location service started ----------------------- ");
      }
    });
  }

  void stopLocationService() {
    _locationServiceTimer!.cancel();
    if (kDebugMode) {
      print("------------------------- Location service disposed ----------------------- ");
    }
  }


  Future<void> getDeliveryManData({int? deliverymanId, int? orderId , GoogleMapController? mapController, LatLng? userLocation}) async {
    ApiResponseModel apiResponse = await trackerRepo!.getDeliveryManData(deliverymanId: deliverymanId, orderId: orderId);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _deliveryManModel = DeliveryManModel.fromJson(apiResponse.response!.data);
      _setMarker(mapController: mapController, userLocation: userLocation);
    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }
    notifyListeners();
  }

  void setSouthwestPadding( {required bool isExpanded, GoogleMapController? mapController, LatLng? userLocation}){
    _isBottomSheetExpanded = isExpanded;
    _setMarker(mapController: mapController, userLocation: userLocation);
  }

  void _setMarker({GoogleMapController? mapController, LatLng? userLocation}) async {
    try {

      final BitmapDescriptor deliverymanIcon = await  _convertAssetToUnit8List(Images.deliveryBoyMarker);
      final BitmapDescriptor userIcon = await  _convertAssetToUnit8List(Images.destinationMarker);

      if (mapController != null ) {

        LatLng ? deliverymanLocation;

        if(_deliveryManModel != null){
          deliverymanLocation = LatLng(_deliveryManModel?.latitude ?? 23.0, _deliveryManModel?.longitude ?? 90.0);
        }

        _mapBound(controller: mapController, userLocation: userLocation, deliverymanLocation: deliverymanLocation);

        _markers = HashSet<Marker>();

        if(userLocation !=null){
          _markers.add(Marker(
            markerId: const MarkerId('destination'),
            position: userLocation,
            infoWindow: InfoWindow(
              title: 'Destination',
              snippet: '${userLocation.latitude}, ${userLocation.longitude}',
            ),
            icon: userIcon,
          ));
        }

       if(deliverymanLocation != null){
         _markers.add(Marker(
           markerId: const MarkerId('delivery_boy'),
           position: deliverymanLocation,
           infoWindow: InfoWindow(
             title: 'Delivery Man',
             snippet: '${deliverymanLocation.latitude}, ${deliverymanLocation.longitude}',
           ),
           icon: deliverymanIcon,
         ));
       }
      }

    }catch(e) {
      debugPrint('error ===> $e');
    }

    notifyListeners();

  }


  void _mapBound({GoogleMapController? controller, LatLng? userLocation, LatLng? deliverymanLocation}) async {
    List<LatLng> latLongList = [];

    if(userLocation !=null){
      latLongList.add(userLocation);
    }
    if(deliverymanLocation !=null){
      latLongList.add(deliverymanLocation);
    }

    await controller?.getVisibleRegion();

    LatLngBounds bounds = _boundsFromLatLngList(latLongList);
    double distance = 1;

    if(userLocation != null && deliverymanLocation !=null){
      /// Distance in KM
      distance = Geolocator.distanceBetween(userLocation.latitude, userLocation.longitude, deliverymanLocation.latitude, deliverymanLocation.longitude)/1000;
    }

    LatLng southwest = LatLng(bounds.southwest.latitude - distance/(_isBottomSheetExpanded? 100 : 1000), bounds.southwest.longitude);
    LatLng northeast = bounds.northeast;
    LatLngBounds adjustedBounds = LatLngBounds(southwest: southwest, northeast: northeast);

    Future.delayed(const Duration(milliseconds: 100), () {
      controller?.animateCamera(CameraUpdate.newLatLngBounds(adjustedBounds, 100));
    });

  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1 ?? 0, y1 ?? 0), southwest: LatLng(x0 ?? 0, y0 ?? 0));
  }

  Future<BitmapDescriptor> _convertAssetToUnit8List(String imagePath, {double height = 50 ,double width = 50}) async {
    return BitmapDescriptor.asset(ImageConfiguration(size: Size(width, height)), imagePath,);
  }

}
