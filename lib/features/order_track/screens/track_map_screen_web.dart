import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/enums/footer_type_enum.dart';
import 'package:flutter_grocery/common/widgets/footer_web_widget.dart';
import 'package:flutter_grocery/features/order_track/providers/tracker_provider.dart';
import 'package:flutter_grocery/features/order_track/widgets/track_map_deliveryman_info.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/order_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../order/domain/models/order_model.dart';



class TrackMapScreenWeb extends StatefulWidget {
  final OrderModel? order;
  final int? deliverymanId;
  final int? orderId;
  final LatLng initialUserLocation;

  const TrackMapScreenWeb({super.key, this.order, this.deliverymanId, this.orderId, required this.initialUserLocation});

  @override
  State<TrackMapScreenWeb> createState() => _TrackMapScreenWebState();
}

class _TrackMapScreenWebState extends State<TrackMapScreenWeb> {

  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? _mapController;

  bool _isInteractingWithMap = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<TrackerProvider>(builder: (ctx, timerProvider, _){

      final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);

      return SingleChildScrollView(
       physics: _isInteractingWithMap ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics(),
        child: Column(children: [

          const SizedBox(height: Dimensions.paddingSizeLarge),
          Center(
            child: SizedBox(
              width: Dimensions.webScreenWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                  boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withValues(alpha: 0.5), blurRadius: Dimensions.radiusSizeSmall)],
                ),
                padding:  const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),

                child: Column( spacing: Dimensions.paddingSizeDefault, children: [
                  RichText(text: TextSpan(text: getTranslated('your_delivery_is', context),
                    style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge,color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:1)),
                    children: <TextSpan>[
                      const TextSpan(text: "  "),
                      TextSpan(
                        text: getTranslated("on_the_way", context),
                        style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                      )
                    ],
                  )),

                  SizedBox(
                    height: 400,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
                      child: MouseRegion(
                        onEnter: (event) => _onPanStart(),
                        onExit: (event) => _onPanEnd(),
                        child: GoogleMap(
                          mapType: MapType.normal,
                          initialCameraPosition: CameraPosition(target: widget.initialUserLocation, zoom: 16),
                          onMapCreated: (GoogleMapController mapController) {
                            _controller.complete(mapController);
                            _mapController = mapController;
                            timerProvider.startLocationService(
                              deliverymanId: widget.deliverymanId,
                              orderId: widget.orderId,
                              mapController: _mapController,
                              userLocation: widget.initialUserLocation,
                            );
                          },
                          zoomControlsEnabled: true,
                          myLocationButtonEnabled: false,
                          markers: timerProvider.markers,
                        ),
                      ),
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
                      border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.5), width: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.radiusSizeDefault,
                      horizontal: Dimensions.paddingSizeLarge,
                    ),
                    margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),

                    child: Row(spacing: Dimensions.paddingSizeDefault,children: [
                      Expanded(flex: 3,child: TrackMapDeliverymanInfo(
                        deliveryMan: widget.order?.deliveryMan, oderId: widget.orderId,
                        order: widget.order,
                      )),
                      const _VerticalDivider(),
                      if(widget.order?.branchId != null) Expanded( flex : 3,child: _DeliveryInfoWidget(
                        title: "store_address",
                        address: '${OrderHelper.getBranch(id: widget.order!.branchId!, branchList: splashProvider.configModel?.branches ?? [])?.address}',
                        icon: Icons.store_mall_directory,
                        iconColor: Theme.of(context).primaryColor,
                      )),
                      const _VerticalDivider(),
                      Expanded(flex: 2, child: _DeliveryInfoWidget(
                        title: "delivery_address",
                        icon: Icons.location_on_rounded,
                        iconColor : Colors.green,
                        address: widget.order?.deliveryAddress?.address
                      ))
                    ]),
                  ),
                ]),
              ),
            ),
          ),

          const SizedBox(height: 55),
          const FooterWebWidget(footerType: FooterType.nonSliver ),

        ]),
      );
    });
  }

  void _onPanStart() {
    setState(() {
      _isInteractingWithMap = true;
    });
  }
  void _onPanEnd() {
    setState(() {
      _isInteractingWithMap = false;
    });
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40, width: 0.5,
      color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
    );
  }
}


class _DeliveryInfoWidget extends StatelessWidget {
  final String? address;
  final String? title;
  final IconData icon;
  final Color iconColor;
  const _DeliveryInfoWidget({this.address, this.title, required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(spacing: Dimensions.paddingSizeExtraSmall, children: [
        Icon(icon, color: iconColor, size: 18,),
        Text(getTranslated(title, context),
          style: poppinsMedium.copyWith(color: Theme.of(context).hintColor),
          overflow: TextOverflow.ellipsis,
        ),
      ]),
      Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge - 3),
        child:  Text( address  ?? "",
          style: poppinsMedium, overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    ]);
  }
}

