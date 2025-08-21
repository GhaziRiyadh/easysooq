import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/config_model.dart';
import 'package:flutter_grocery/common/widgets/custom_alert_dialog_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_button_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_image_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_single_child_list_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_zoom_widget.dart';
import 'package:flutter_grocery/features/checkout/widgets/offline_payment_widget.dart';
import 'package:flutter_grocery/features/checkout/widgets/payment_method_bottom_sheet_widget.dart';
import 'package:flutter_grocery/features/order/domain/models/order_model.dart';
import 'package:flutter_grocery/features/order/domain/models/timeslote_model.dart';
import 'package:flutter_grocery/features/order/widgets/payment_info_widget.dart';
import 'package:flutter_grocery/features/order/widgets/switch_payment_confirmation_widget.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/date_converter_helper.dart';
import 'package:flutter_grocery/helper/order_helper.dart';
import 'package:flutter_grocery/helper/price_converter_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:flutter_grocery/features/order/widgets/order_map_info_widget.dart';
import 'package:flutter_grocery/features/order/widgets/ordered_product_list_widget.dart';
import 'package:provider/provider.dart';

class OrderInfoWidget extends StatelessWidget {
  final OrderModel? orderModel;
  final TimeSlotModel? timeSlot;

  const OrderInfoWidget({super.key, required this.orderModel, required this.timeSlot});

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);

    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        int itemsQuantity = OrderHelper.getOrderItemQuantity(orderProvider.orderDetails);


        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Order info
            ResponsiveHelper.isDesktop(context) ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [

                Row(children: [

                  Row(children: [
                    Text('${getTranslated('order_id', context)} :', style: poppinsRegular),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Text(orderProvider.trackModel!.id.toString(), style: poppinsSemiBold),
                  ]),
                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                    decoration: BoxDecoration(
                      color: OrderStatus.pending.name == orderProvider.trackModel!.orderStatus ? ColorResources.colorBlue.withValues(alpha: 0.08)
                          : OrderStatus.out_for_delivery.name == orderProvider.trackModel!.orderStatus ? ColorResources.ratingColor.withValues(alpha: 0.08)
                          : OrderStatus.canceled.name == orderProvider.trackModel!.orderStatus ? ColorResources.redColor.withValues(alpha: 0.08) : ColorResources.colorGreen.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(Dimensions.radiusSizeTen),
                    ),
                    child: Text(
                      getTranslated(orderProvider.trackModel!.orderStatus, context),
                      style: poppinsRegular.copyWith(color: OrderStatus.pending.name == orderProvider.trackModel!.orderStatus ? ColorResources.colorBlue
                          : OrderStatus.out_for_delivery.name == orderProvider.trackModel!.orderStatus ? ColorResources.ratingColor
                          : OrderStatus.canceled.name == orderProvider.trackModel!.orderStatus ? ColorResources.redColor : ColorResources.colorGreen),
                    ),
                  ),


                ]),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                timeSlot != null ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [
                    Text('${getTranslated('delivered_time', context)}:', style: poppinsRegular),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Text(DateConverterHelper.convertTimeRange(timeSlot!.startTime!, timeSlot!.endTime!, context), style: poppinsMedium),
                  ]),

                ]) : const SizedBox(),
                SizedBox(height: timeSlot != null ? Dimensions.paddingSizeSmall : 0),

                if(orderProvider.trackModel?.deliveryDate != null) Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                  child: Row(children: [
                    Text('${getTranslated('estimate_delivery_date', context)}: ', style: poppinsRegular),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Text(DateConverterHelper.isoStringToLocalDateOnly(orderProvider.trackModel!.deliveryDate!), style: poppinsMedium),
                  ]),
                ),

                Row(children: [

                  Text('${getTranslated(itemsQuantity > 1 ? 'items' : 'item', context)}:', style: poppinsRegular),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),


                  Text('$itemsQuantity', style: poppinsSemiBold),

                ]),

              ])),

              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const _OrderTypeWidget(),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Text(DateConverterHelper.isoStringToLocalDateOnly(orderProvider.trackModel!.createdAt!), style: poppinsRegular.copyWith(color: Theme.of(context).disabledColor)),
                const SizedBox(height: Dimensions.paddingSizeDefault),


              ]),

            ]) : const SizedBox(),

            ResponsiveHelper.isDesktop(context) ? const SizedBox() : Row( crossAxisAlignment: CrossAxisAlignment.start, children: [

              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                
                  Row(children: [
                    Text('${getTranslated('order_id', context)} : ', style: poppinsRegular),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                
                    Text(orderProvider.trackModel!.id.toString(), style: poppinsSemiBold),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Row(children: [

                    Text('${getTranslated(itemsQuantity > 1 ? 'items' : 'item', context)}:', style: poppinsRegular),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),


                    Text('$itemsQuantity', style: poppinsSemiBold),

                  ]),

                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Text(DateConverterHelper.isoStringToLocalDateOnly(orderProvider.trackModel!.createdAt!), style: poppinsRegular.copyWith(color: Theme.of(context).disabledColor)),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),


                  timeSlot != null ? FittedBox(
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                      Row(children: [
                        Text('${getTranslated('delivered_time', context)}:', style: poppinsRegular),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Text(DateConverterHelper.convertTimeRange(timeSlot!.startTime!, timeSlot!.endTime!, context), style: poppinsMedium),
                      ]),
                    ]),
                  ) : const SizedBox(),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  if(orderProvider.trackModel?.deliveryDate != null) Padding(
                    padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                    child: FittedBox(
                      child: Row(children: [
                        Text('${getTranslated('estimate_delivery_date', context)}: ', style: poppinsRegular),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      
                        Text(DateConverterHelper.isoStringToLocalDateOnly(orderProvider.trackModel!.deliveryDate!), style: poppinsMedium),
                      ]),
                    ),
                  ),


                ]),
              ),

              Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.start, children: [
                const _OrderTypeWidget(),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    color: OrderStatus.pending.name == orderProvider.trackModel!.orderStatus ? ColorResources.colorBlue.withValues(alpha: 0.08)
                        : OrderStatus.out_for_delivery.name == orderProvider.trackModel!.orderStatus ? ColorResources.ratingColor.withValues(alpha: 0.08)
                        : OrderStatus.canceled.name == orderProvider.trackModel!.orderStatus ? ColorResources.redColor.withValues(alpha: 0.08) : ColorResources.colorGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSizeTen),
                  ),
                  child: Text(
                    getTranslated(orderProvider.trackModel!.orderStatus, context),
                    style: poppinsRegular.copyWith(color: OrderStatus.pending.name == orderProvider.trackModel!.orderStatus ? ColorResources.colorBlue
                        : OrderStatus.out_for_delivery.name == orderProvider.trackModel!.orderStatus ? ColorResources.ratingColor
                        : OrderStatus.canceled.name == orderProvider.trackModel!.orderStatus ? ColorResources.redColor : ColorResources.colorGreen),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                if(orderProvider.trackModel!.orderType == 'delivery' &&
                    (splashProvider.configModel?.googleMapStatus ?? false) &&
                    (orderProvider.trackModel?.deliveryAddress?.longitude != null && (orderProvider.trackModel?.deliveryAddress?.latitude != null))
                )  InkWell(
                  onTap: () {
                    if(orderProvider.trackModel!.deliveryAddress != null) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => OrderMapInfoWidget(address: orderProvider.trackModel!.deliveryAddress)));
                    }
                    else{
                      showCustomSnackBarHelper(getTranslated('address_not_found', context), isError: true);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 1.5, color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
                    ),
                    child: Image.asset(Images.deliveryAddressIcon, color: Theme.of(context).primaryColor, height: 20, width: 20),
                  ),
                ),




              ]),

            ]),
            const SizedBox(height: Dimensions.paddingSizeDefault),


            if(orderProvider.trackModel!.offlinePayment !=null && orderProvider.trackModel!.offlinePayment?.status == 2 && orderProvider.trackModel?.paymentMethod == "offline_payment")
            _OfflinePaymentDeniedNoteWidget(offlinePayment: orderProvider.trackModel!.offlinePayment!),

            /// Payment info
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusSizeTen),
                boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 5)],
              ),
              child: orderProvider.trackModel?.paymentMethod == 'offline_payment' ? _OfflinePaymentInfoWidget(orderModel: orderProvider.trackModel,) : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(
                        getTranslated('payment_info', context),
                        style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                      ),

                    if(orderProvider.trackModel?.paymentMethod == 'offline_payment' && (!ResponsiveHelper.isDesktop(context)))
                      SizedBox(
                        width: 120, height: 50,
                        child: CustomButtonWidget(
                          borderRadius: Dimensions.paddingSizeDefault,
                          margin: Dimensions.paddingSizeSmall,
                          buttonText: getTranslated('see_details', context),
                          onPressed: (){
                            ResponsiveHelper().showDialogOrBottomSheet(context, CustomAlertDialogWidget(
                              child: PaymentInfoWidget(deliveryAddress: orderModel?.deliveryAddress),
                            ));
                          },
                          backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          borderColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                          textStyle: poppinsRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).textTheme.titleMedium?.color,
                          ),
                        ),
                      )
                  ]),
                  Divider(height: 15, color: Theme.of(context).dividerColor.withValues(alpha: 0.3), thickness: 0.5,),

                  Row(children: [
                    Text('${getTranslated('status', context)} : ', style: poppinsRegular),

                    Text(
                      getTranslated(orderProvider.trackModel!.paymentStatus, context),
                      style: poppinsMedium,
                    ),

                  ]),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Row(children: [
                    Text('${getTranslated('method', context)} : ', style: poppinsRegular, maxLines: 1, overflow: TextOverflow.ellipsis),

                    Row(children: [
                      (orderProvider.trackModel!.paymentMethod != null && orderProvider.trackModel!.paymentMethod!.isNotEmpty) && orderProvider.trackModel!.paymentMethod == 'cash_on_delivery' ? Text(
                        getTranslated('cash_on_delivery', context), style: poppinsMedium
                      ) : Text(
                        (orderProvider.trackModel!.paymentMethod != null && orderProvider.trackModel!.paymentMethod!.isNotEmpty)
                            ? '${orderProvider.trackModel!.paymentMethod![0].toUpperCase()}${orderProvider.trackModel!.paymentMethod!.substring(1).replaceAll('_', ' ')}'
                            : 'Digital Payment', style: poppinsMedium,
                      ),

                      if(orderProvider.trackModel?.paymentStatus == 'partially_paid')
                        Text(' + ${getTranslated('wallet', context)}', style: poppinsMedium),

                      if(orderProvider.trackModel?.paymentMethod == 'offline_payment' && ResponsiveHelper.isDesktop(context))
                        SizedBox(
                          width: 120, height: 45,
                          child: CustomButtonWidget(
                            borderRadius: Dimensions.paddingSizeDefault,
                            margin: Dimensions.paddingSizeSmall,
                            buttonText: getTranslated('see_details', context),
                            onPressed: (){
                              ResponsiveHelper().showDialogOrBottomSheet(context, CustomAlertDialogWidget(
                                child: PaymentInfoWidget(deliveryAddress: orderModel?.deliveryAddress),
                              ));
                            },
                            backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            borderColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                            textStyle: poppinsRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).textTheme.titleMedium?.color,
                            ),
                          ),
                        )

                    ]),
                  ]),

                  if(orderProvider.trackModel?.paymentMethod == 'cash_on_delivery' && orderProvider.trackModel!.bringChangeAmount != null && orderProvider.trackModel!.bringChangeAmount! > 0)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusSizeDefault
                        ),
                        color: Colors.blue.withValues(alpha: 0.1)
                      ),
                      margin: EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                      child: Row(
                        spacing: Dimensions.paddingSizeExtraSmall, crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(padding: const EdgeInsets.only(top: 2),
                            child: Icon(Icons.info, color: Colors.blue, size: 18,),
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: poppinsRegular.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                  height: 1.5
                                ),
                                children: <TextSpan>[
                                  TextSpan(text: getTranslated("you_have_asked_for_bring", context),  style: poppinsRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                                  )),
                                  TextSpan(text: " ${PriceConverterHelper.convertPrice(context, orderProvider.trackModel!.bringChangeAmount!)} ", style: poppinsSemiBold),
                                  TextSpan(text: getTranslated('in_change_when_making_the_delivery', context),  style: poppinsRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),

                                  )),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )

                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            const OrderedProductListWidget(),


            (orderProvider.trackModel?.orderNote?.isNotEmpty ?? false) ? Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
              width: Dimensions.webScreenWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(width: 1, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.6)),
              ),
              child: Text(orderProvider.trackModel?.orderNote ?? '', style: poppinsRegular.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6),
              )),
            ) : const SizedBox(),

           if(orderProvider.trackModel?.orderImageList?.isNotEmpty ?? false) Container(
             padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
             decoration: BoxDecoration(
               borderRadius: BorderRadius.circular(10),
               color: Theme.of(context).cardColor,
               boxShadow: [BoxShadow(color: Theme.of(context).shadowColor, spreadRadius: 1, blurRadius: 5)],
             ),
             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
               Text(
                 splashProvider.configModel?.orderImageLabelName ?? '',
                 style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
               ),
               Divider(height: Dimensions.paddingSizeLarge, color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),

               Row(
                 children: [
                   CustomSingleChildListWidget(
                     scrollDirection: Axis.horizontal,
                     itemCount: orderProvider.trackModel?.orderImageList?.length ?? 0,
                     itemBuilder: (index){

                       return InkWell(
                         onTap: (){

                           if(ResponsiveHelper.isDesktop(context)) {

                             showDialog(context: context, builder: (ctx)=> CustomAlertDialogWidget(child: ClipRRect(
                               borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault)),
                               child: CustomZoomWidget(
                                 image: CustomImageWidget(
                                     fit: BoxFit.contain,
                                     width: 400, height: 400,
                                     image: '${splashProvider.configModel?.baseUrls?.orderImageUrl}/${orderProvider.trackModel?.orderImageList?[index].image}'
                                 ),
                               ),
                             )));

                           }else {
                             Navigator.of(context).pushNamed(
                               RouteHelper.getProductImagesRoute(
                                 getTranslated('image', context),
                                 jsonEncode([orderProvider.trackModel?.orderImageList?[index].image ?? '']),
                                 splashProvider.configModel?.baseUrls?.orderImageUrl ?? '',
                               ),
                             );
                           }
                         },
                         child: Padding(
                           padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                           child: ClipRRect(
                             borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault)),
                             child: CustomImageWidget(
                                 width: 100, height: 100,
                                 image: '${splashProvider.configModel?.baseUrls?.orderImageUrl}/${orderProvider.trackModel?.orderImageList?[index].image}'
                             ),
                           ),
                         ),
                       );
                     },
                   ),
                 ],
               ),
             ]),
           ),

            if(orderProvider.trackModel?.orderImageList?.isNotEmpty ?? false) const SizedBox(height: Dimensions.paddingSizeDefault),

          ],
        );
      }
    );
  }
}

class _OrderTypeWidget extends StatelessWidget {
  const _OrderTypeWidget();

  @override
  Widget build(BuildContext context) {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(context, listen: false);

    return orderProvider.trackModel?.orderType != 'delivery' ? Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusSizeTen),
      ),
      child: Text(
        getTranslated(orderProvider.trackModel?.orderType == 'pos' ? 'pos_order' : 'self_pickup', context),
        style: poppinsRegular,
      ),
    ) : const SizedBox();
  }

}

class _OfflinePaymentInfoWidget extends StatelessWidget {
  final OrderModel? orderModel;
  const _OfflinePaymentInfoWidget({this.orderModel});

  @override
  Widget build(BuildContext context) {

    final ConfigModel? configModel = Provider.of<SplashProvider>(context, listen: false).configModel;

    double orderAmount = 0;
    if(orderModel!.orderPartialPayments !=null && orderModel!.orderPartialPayments!.isNotEmpty){
      orderModel!.orderPartialPayments?.forEach((element){
        if(element.paidWith == "offline_payment"){
          orderAmount = element.paidAmount ?? 0;
        }
      });
    }else{
      orderAmount = orderModel?.orderAmount ?? 0 ;
    }


    return orderModel?.offlinePaymentInformation == null
        ? _IncompleteOfflinePayment(orderModel: orderModel,)
        : Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: Dimensions.paddingSizeExtraSmall, children: [


      Row(children: [
        Expanded(
          child: Text(getTranslated('payment_method', context),
            style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
          decoration: BoxDecoration(
            color: orderModel?.paymentStatus == "paid" ? Colors.green.withValues(alpha: 0.05) : Theme.of(context).colorScheme.error.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(Dimensions.radiusSizeTen),
          ),
          child: Text(
            getTranslated(orderModel?.paymentStatus, context),
            style: poppinsRegular.copyWith(
              color: orderModel?.paymentStatus == "paid" ? Colors.green : Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ]),

      Row(children: [
        Text(getTranslated('offline_payment', context), style: poppinsRegular, maxLines: 1, overflow: TextOverflow.ellipsis),
        SizedBox(width: 10),

        if(orderModel?.paymentStatus == "paid" || orderModel?.orderStatus == "canceled") InkWell(
          onTap : (){
            ResponsiveHelper().showDialogOrBottomSheet(context, CustomAlertDialogWidget(
              child: PaymentInfoWidget(deliveryAddress: orderModel?.deliveryAddress),
            ));
          },
          child: Text(getTranslated("see_details", context), style: poppinsMedium.copyWith(
            decoration: TextDecoration.underline, color: Theme.of(context).primaryColor, decorationColor: Theme.of(context).primaryColor,
            fontSize: Dimensions.fontSizeSmall,
          ) ),
        ),
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, spacing: Dimensions.paddingSizeExtraSmall, children: [
        Text("${getTranslated('payment_name', context)} : ${orderModel?.offlinePaymentInformation?.paymentName ?? "" }", style: poppinsRegular, maxLines: 1, overflow: TextOverflow.ellipsis),
        Expanded(child: Text(
          PriceConverterHelper.convertPrice(context, orderAmount),
          style: poppinsBold.copyWith(fontSize: Dimensions.fontSizeDefault,),
          textAlign: TextAlign.end,
        )),
      ]),
      SizedBox(height: 5),
      orderModel?.paymentStatus != "paid" && orderModel?.orderStatus != "canceled" ? Row( spacing: 15, children: [
        Expanded(
          flex: 6,
          child: TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(1, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(width: 0.5, color: Theme.of(context).primaryColor)),
            ),
            onPressed: () {
              if(configModel?.cashOnDelivery ?? false){
                showDialog(context: context, barrierDismissible: false, builder: (context) => SwitchPaymentConfirmationWidget(
                  orderID: orderModel?.id.toString() ?? "",
                  paymentMethod : "cash_on_delivery",
                  callback: (String message, bool isSuccess, String orderID) {
                    if (isSuccess) {
                      showCustomSnackBarHelper('$message ${'order_id'.tr}: $orderID', isError: false);
                    } else {
                      showCustomSnackBarHelper(message);
                    }
                  },
                ));
              }else{
                showCustomSnackBarHelper(getTranslated('payment_method_unavailable_talk_to_admin', context));
              }

            },
            child: Text('switch_to_COD'.tr, style: poppinsRegular.copyWith(
              color: Theme.of(context).primaryColor,
              fontSize: Dimensions.fontSizeDefault,
            )),
          ),
        ),

        Expanded(
          flex: 7,
          child: CustomButtonWidget(
            buttonText: 'update_payment_info'.tr,
            textStyle: poppinsRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Colors.white
            ),

            onPressed: (){
              ResponsiveHelper().showDialogOrBottomSheet(
                context, isScrollControlled: true,
                OfflinePaymentWidget(
                  totalAmount: orderAmount ,
                  orderOfflineData: orderModel?.offlinePaymentInformation,
                  partialAmount:  null,
                  orderId: orderModel?.id.toString(),
                ),
              );
            },
          ),
        ),
      ]) : SizedBox()
    ]);
  }
}

class _IncompleteOfflinePayment extends StatelessWidget {
  final OrderModel? orderModel;
  const _IncompleteOfflinePayment({this.orderModel});

  @override
  Widget build(BuildContext context) {


    double? orderAmount = orderModel?.orderAmount;
    double? dueAmount;
    bool isPartialPayment = orderModel?.orderPartialPayments != null && (orderModel?.orderPartialPayments?.isNotEmpty ?? false);

    if(isPartialPayment){
      orderModel?.orderPartialPayments?.forEach((element){
        if(element.paidWith == "wallet_payment"){
          dueAmount = element.dueAmount ?? 0;
        }
      });
    }
    
    return Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: Dimensions.paddingSizeExtraSmall, children: [

      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, spacing: Dimensions.paddingSizeExtraSmall, children: [
        Text(getTranslated('payment_method', context),
          style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
        ),
        Expanded(child: Text(
          PriceConverterHelper.convertPrice(context, dueAmount ?? orderAmount),
          style: poppinsBold.copyWith(fontSize: Dimensions.fontSizeDefault,),
          textAlign: TextAlign.end,
        )),
      ]),

      Text(getTranslated('offline_payment', context), style: poppinsRegular, maxLines: 1, overflow: TextOverflow.ellipsis),
      SizedBox(),

      Row( spacing: 15, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

        Container(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(Dimensions.radiusSizeTen),
          ),
          child: Text(
            getTranslated("payment_incomplete", context),
            style: poppinsRegular.copyWith( color: Theme.of(context).colorScheme.error),
          ),
        ),

        SizedBox(
          width: 130,
          child: CustomButtonWidget(
            height: 45,
            buttonText: getTranslated("pay_now", context),
            textStyle: poppinsRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Colors.white
            ),

            onPressed: orderModel?.orderStatus != "pending" ? null : (){
              ResponsiveHelper().showDialogOrBottomSheet(
                context,  PaymentMethodBottomSheetWidget(
                totalPrice: dueAmount ?? orderAmount ?? 0,
                orderId: orderModel?.id.toString(),
                isAlreadyPartialApplied: isPartialPayment,
              ), isScrollControlled: true,
              );
            },
          ),
        ),
      ])
    ]);
  }
}

class _OfflinePaymentDeniedNoteWidget extends StatelessWidget {
  final OfflinePayment offlinePayment;
  const _OfflinePaymentDeniedNoteWidget({required this.offlinePayment});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
        border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5), width: 0.5),
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.08)
      ),
      padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
      margin: EdgeInsets.only(bottom : Dimensions.paddingSizeDefault),
      child: Column(spacing: Dimensions.paddingSizeExtraSmall, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('# ${getTranslated('denied_note', context)}', style: poppinsSemiBold.copyWith(
          fontSize: Dimensions.fontSizeLarge,
          color: Theme.of(context).colorScheme.error,
        )),
        
        Text(offlinePayment.deniedNote ?? "", style: poppinsRegular.copyWith(
         color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8)
        ))
        
      ]),
    );
  }
}





