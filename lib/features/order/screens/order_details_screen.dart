import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/enums/footer_type_enum.dart';
import 'package:flutter_grocery/common/models/payment_response_model.dart';
import 'package:flutter_grocery/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
import 'package:flutter_grocery/common/widgets/footer_web_widget.dart';
import 'package:flutter_grocery/common/widgets/no_data_widget.dart';
import 'package:flutter_grocery/common/widgets/web_app_bar_widget.dart';
import 'package:flutter_grocery/features/order/domain/models/order_model.dart';
import 'package:flutter_grocery/features/order/domain/models/timeslote_model.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/features/order/widgets/order_amount_widget.dart';
import 'package:flutter_grocery/features/order/widgets/order_details_button_view.dart';
import 'package:flutter_grocery/features/order/widgets/order_info_widget.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:flutter_grocery/helper/order_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/helper/string_parser.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:provider/provider.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel? orderModel;
  final int? orderId;
  final String? phoneNumber;
  final String? token;
  final String? flag;

  const OrderDetailsScreen({super.key,  this.orderModel,  this.orderId, this.phoneNumber, this.token, this.flag});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {

  void _loadData(BuildContext context) async {
    final splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (widget.orderModel == null) {
      await splashProvider.initConfig();
    }
    splashProvider.getOfflinePaymentMethod(true);
    await orderProvider.initializeTimeSlot();

    if(widget.orderId != null){
      orderProvider.getOrderDetails(orderID: widget.orderId.toString(), phoneNumber: widget.phoneNumber);
      orderProvider.trackOrder(widget.orderId.toString(), null, Get.context!, false, phoneNumber: widget.phoneNumber, isUpdate: false);
    }else if(_isValidToken(widget.token))  {
      String transactionId = _extractTransactionId(widget.token!);
      PaymentResponseModel? paymentResponse = await Provider.of<OrderProvider>(Get.context!, listen: false).getDigitalPaymentResponse(transactionId: transactionId);
      if(paymentResponse?.orderId != null){
         orderProvider.getOrderDetails(orderID: paymentResponse!.orderId!, phoneNumber: widget.phoneNumber);
         orderProvider.trackOrder(paymentResponse.orderId!, null, Get.context!, false, phoneNumber: widget.phoneNumber, isUpdate: false);

         Future.delayed(Duration(microseconds: 500), (){
           if(widget.flag == "success"){
             showCustomSnackBarHelper(getTranslated('your_payment_confirm_successfully', Get.context!), isError: false);
           }else{
             showCustomSnackBarHelper(getTranslated('payment_failed', Get.context!));
           }
         });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData(context);
  }

  bool _isValidToken(String? token) {
    if (token == null || token == "null" || token.isEmpty) return false;
    String transactionReference = StringParser.parseString(utf8.decode(base64Url.decode(token)), "transaction_reference",);
    return transactionReference.isNotEmpty;
  }

  String _extractTransactionId(String token) {
    return StringParser.parseString(
      utf8.decode(base64Url.decode(token)),
      "transaction_reference",
    );
  }

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);

    return PopScope(
      canPop: ResponsiveHelper.isWeb() ? true : false,
      onPopInvokedWithResult: (bool didPop, _) {
        if(didPop) return;

        if (Navigator.canPop(context) && !ResponsiveHelper.isDesktop(context)) {
          Navigator.pop(context);
          return;
        } else if(!didPop && !Navigator.canPop(context)){
          Navigator.of(context).pushNamedAndRemoveUntil(RouteHelper.menu, (route) => false);
          splashProvider.setPageIndex(0);
          return;
        }
      },
      child: Scaffold(
        appBar: (ResponsiveHelper.isDesktop(context) ? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBarWidget()): CustomAppBarWidget(
          title: 'order_details'.tr,
          onBackPressed: (){
            if(!Navigator.canPop(context)){
              Navigator.of(context).pushNamedAndRemoveUntil(RouteHelper.menu, (route) => false);
              splashProvider.setPageIndex(0);
            } else{
              Navigator.pop(context);
            }
          },
        )) as PreferredSizeWidget?,
        body: Consumer<OrderProvider>(builder: (context, orderProvider, _) {
          double deliveryCharge = OrderHelper.getDeliveryCharge(orderModel: orderProvider.trackModel);
          double itemsPrice = OrderHelper.getOrderDetailsValue(orderDetailsList: orderProvider.orderDetails, type: OrderValue.itemPrice);
          double discount = OrderHelper.getOrderDetailsValue(orderDetailsList: orderProvider.orderDetails, type: OrderValue.discount);
          double extraDiscount = OrderHelper.getExtraDiscount(trackOrder: orderProvider.trackModel);
          double tax = OrderHelper.getOrderDetailsValue(orderDetailsList: orderProvider.orderDetails, type: OrderValue.tax);
          bool isVatInclude = OrderHelper.isVatTaxInclude(orderDetailsList: orderProvider.orderDetails);
          TimeSlotModel? timeSlot = OrderHelper.getTimeSlot(timeSlotList: orderProvider.allTimeSlots, timeSlotId: orderProvider.trackModel?.timeSlotId);

          double subTotal =  OrderHelper.getSubTotalAmount(itemsPrice: itemsPrice, tax: tax, isVatInclude: isVatInclude);

          double total = OrderHelper.getTotalOrderAmount(
            subTotal: subTotal, discount: discount, extraDiscount: extraDiscount,
            deliveryCharge: deliveryCharge, couponDiscount: orderProvider.trackModel?.couponDiscountAmount,
          );


          return (orderProvider.orderDetails == null || orderProvider.trackModel == null) ? Center(child: CustomLoaderWidget(color: Theme.of(context).primaryColor)) : orderProvider.orderDetails!.isNotEmpty ?  Column(
            children: [
              Expanded(child: CustomScrollView(slivers: [
                if(ResponsiveHelper.isDesktop(context)) SliverToBoxAdapter(child: Center(
                  child: Container(
                    width: Dimensions.webScreenWidth,
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Expanded(
                          flex: 6,
                          child: OrderInfoWidget(orderModel: widget.orderModel, timeSlot: timeSlot),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeLarge),

                        Expanded(
                          flex: 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              OrderAmountWidget(
                                extraDiscount: extraDiscount,
                                itemsPrice: itemsPrice,
                                tax: tax,
                                subTotal: subTotal,
                                discount: discount,
                                couponDiscount: orderProvider.trackModel?.couponDiscountAmount ?? 0,
                                deliveryCharge: deliveryCharge,
                                total: total,
                                isVatInclude: isVatInclude,
                                paymentList: OrderHelper.getPaymentList(orderProvider.trackModel),
                                orderModel: widget.orderModel,
                                phoneNumber: widget.phoneNumber,
                                weightChargeAmount: orderProvider.trackModel?.weightChargeAmount,
                              ),
                              const SizedBox(height: Dimensions.paddingSizeDefault),

                            ]),
                        ),

                      ],
                    ),
                  ),
                )),

                if(!ResponsiveHelper.isDesktop(context)) SliverToBoxAdapter(child: Column(children: [
                  Center(child: SizedBox(
                    width: 1170,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                        vertical: Dimensions.paddingSizeDefault,
                      ),
                      child: Column(children: [
                        OrderInfoWidget(orderModel: widget.orderModel, timeSlot: timeSlot),

                        OrderAmountWidget(
                          extraDiscount: extraDiscount,
                          itemsPrice: itemsPrice,
                          tax: tax,
                          subTotal: subTotal,
                          discount: discount,
                          couponDiscount: orderProvider.trackModel?.couponDiscountAmount ?? 0,
                          deliveryCharge: deliveryCharge,
                          total: total,
                          isVatInclude: isVatInclude,
                          paymentList: OrderHelper.getPaymentList(orderProvider.trackModel),
                          weightChargeAmount: orderProvider.trackModel?.weightChargeAmount,
                        ),
                      ]),
                    ),
                  )),
                ])),


                const FooterWebWidget(footerType: FooterType.sliver),

              ])),

              if(!ResponsiveHelper.isDesktop(context)) Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.2), spreadRadius: 1, blurRadius: 5)],
                ),
                child: OrderDetailsButtonView(orderModel: widget.orderModel, phoneNumber: widget.phoneNumber),
              ),

            ],

          ) : NoDataWidget(isShowButton: true, image: Images.box, title: 'order_not_found'.tr);
        }),
      ),
    );
  }
}





