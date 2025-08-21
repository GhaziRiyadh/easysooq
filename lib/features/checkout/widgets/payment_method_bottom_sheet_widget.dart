import 'dart:convert' as convert;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/cart_model.dart';
import 'package:flutter_grocery/common/models/config_model.dart';
import 'package:flutter_grocery/common/models/place_order_model.dart';
import 'package:flutter_grocery/common/providers/cart_provider.dart';
import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
import 'package:flutter_grocery/features/address/providers/location_provider.dart';
import 'package:flutter_grocery/features/checkout/domain/models/check_out_model.dart';
import 'package:flutter_grocery/features/coupon/providers/coupon_provider.dart';
import 'package:flutter_grocery/features/order/domain/models/offline_payment_model.dart';
import 'package:flutter_grocery/features/order/widgets/bring_change_input_widget.dart';
import 'package:flutter_grocery/features/wallet_and_loyalty/widgets/add_fund_dialogue_widget.dart';
import 'package:flutter_grocery/helper/checkout_helper.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:flutter_grocery/helper/price_converter_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/features/profile/providers/profile_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/custom_button_widget.dart';
import 'package:flutter_grocery/features/checkout/widgets/offline_payment_widget.dart';
import 'package:flutter_grocery/features/checkout/widgets/payment_button_widget.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

class PaymentMethodBottomSheetWidget extends StatefulWidget {
  final double totalPrice;
  final double? weight;
  final String? orderId;
  final bool isAlreadyPartialApplied;
  const PaymentMethodBottomSheetWidget({super.key, required this.totalPrice, this.weight, this.orderId,  this.isAlreadyPartialApplied = false});

  @override
  State<PaymentMethodBottomSheetWidget> createState() => _PaymentMethodBottomSheetWidgetState();
}

class _PaymentMethodBottomSheetWidgetState extends State<PaymentMethodBottomSheetWidget> {



  String partialPaymentCombinator = "all";
  final JustTheController? toolTip = JustTheController();
  TextEditingController? _bringAmountController;
  List<PaymentMethod> paymentList = [];
  int? _paymentMethodIndex;
  double? _partialAmount;
  PaymentMethod? _paymentMethod;
  OfflinePaymentModel? _selectedOfflineMethod;
  List<Map<String, String>>? _selectedOfflineValue;


  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ProfileProvider profileProvider  = Provider.of<ProfileProvider>(context, listen: false);
    final ConfigModel configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;

    return SingleChildScrollView(
      child: Center(child: SizedBox(width: 550, child: Column(mainAxisSize: MainAxisSize.min, children: [
        SafeArea(
          bottom: !kIsWeb && Platform.isAndroid,
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
            width: 550,
            margin: const EdgeInsets.only(top: kIsWeb ? 0 : 30),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: ResponsiveHelper.isMobile() ? const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSizeLarge))
                  :  BorderRadius.all(Radius.circular(Dimensions.radiusSizeDefault)),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeExtraSmall,
            ),
            child: SafeArea(
              child: Consumer<OrderProvider>(
                  builder: (ctx, orderProvider, _) {
              
                    double bottomPadding = MediaQuery.of(context).padding.bottom;
              
                    double walletBalance = profileProvider.userInfoModel?.walletBalance ?? 0;
                    bool isPartialPayment = widget.totalPrice > walletBalance;
                    bool isWalletSelectAndNotPartial = _paymentMethodIndex == 0 && !isPartialPayment;
              
                    bool hideCOD = isWalletSelectAndNotPartial
                        || (_partialAmount !=null && (partialPaymentCombinator == "digital_payment" || partialPaymentCombinator == "offline_payment"));
              
                    bool hideDigital = isWalletSelectAndNotPartial
                        || (_partialAmount !=null && (partialPaymentCombinator == "cod" || partialPaymentCombinator == "offline_payment"));
              
                    bool hideOffline = isWalletSelectAndNotPartial
                        || (_partialAmount !=null && (partialPaymentCombinator == "cod" || partialPaymentCombinator == "digital_payment"));
              
              
                    return Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
              
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      !ResponsiveHelper.isDesktop(context) ? Align(
                        alignment: Alignment.center,
                        child: Container(
                          height: 4, width: 35,
                          decoration: BoxDecoration(color: Theme.of(context).disabledColor.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10)),
                        ),
                      ) : const SizedBox(),
              
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(Icons.clear, size: 20,),
                          ),
                        ),
                      ),
              
                      Text(getTranslated('choose_payment_method', context), style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Text(getTranslated('total_bill', context), style: poppinsRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7)
                      )),
                      Text(PriceConverterHelper.convertPrice(context,widget.totalPrice), style: poppinsBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              
                      const SizedBox(height:  Dimensions.paddingSizeDefault),
              
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height * 0.2,
                          maxHeight: MediaQuery.of(context).size.height * 0.5,
                        ),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge * (ResponsiveHelper.isDesktop(context) ? 2 : 1),),
                            child: Column(children: [
              
                              configModel.walletStatus! && authProvider.isLoggedIn() && walletBalance > 0 && !widget.isAlreadyPartialApplied ? PaymentButtonWidget(
                                icon: Images.walletIcon,
                                isWallet: true,
                                title: getTranslated('pay_via_wallet', context),
                                isSelected: _paymentMethodIndex == 0,
                                hidePaymentMethod: false ,
                                walletBalance: walletBalance,
                                totalPrice: widget.totalPrice,
                                partialAmount: _partialAmount,
                                chooseAnyPayment:  _paymentMethodIndex != null || _paymentMethod != null,
                                callBack: ({int? paymentMethodIndex, double? partialAmount}){
                                  setState(() {
                                    _paymentMethodIndex = paymentMethodIndex;
                                    _partialAmount = partialAmount;
                                    _paymentMethod = null;
                                    _bringAmountController?.text = "";
                                    orderProvider.updateBringChangeInputOptionStatus(false, isUpdate: false);
                                    orderProvider.setBringChangeAmount();
                                  });
                                },
                              ) : const SizedBox(),
              
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              
                              configModel.cashOnDelivery! ? PaymentButtonWidget(
                                icon: Images.cashOnDelivery,
                                title: getTranslated('cash_on_delivery', context),
                                walletBalance: walletBalance,
                                hidePaymentMethod: hideCOD,
                                totalPrice: widget.totalPrice,
                                isSelected: _paymentMethodIndex == 1,
                                chooseAnyPayment: _paymentMethodIndex != null || _paymentMethod != null,
                                callBack: ({int? paymentMethodIndex, double? partialAmount}){
                                  setState(() {
                                    _paymentMethodIndex = paymentMethodIndex;
                                    _paymentMethod = null;
                                    _selectedOfflineValue = null;
                                    _selectedOfflineMethod = null;
                                  });
                                },
                              ) : const SizedBox(),
              
                              if(configModel.cashOnDelivery! )
                                BringChangeInputWidget(amountController: _bringAmountController, hidePaymentMethod: hideCOD,),
              
              
                              const SizedBox(height: Dimensions.paddingSizeSmall),
                              if(paymentList.isNotEmpty) Opacity(
                                opacity: (hideOffline && hideDigital) ? 0.4 : 1 ,
                                child: Stack( children: [
                                  PaymentMethodView(
                                    toolTip: toolTip,
                                    paymentList: paymentList,
                                    hideDigital: hideDigital,
                                    hideOffline: hideOffline,
                                    selectedPaymentMethod: _paymentMethod?.getWayTitle,
                                    selectedOfflineMethod: _selectedOfflineMethod,
                                    selectedOfflineValue: _selectedOfflineValue,
                                    onTap: (index){
                                      setState(() {
                                        _paymentMethod =  paymentList[index];
                                        _paymentMethodIndex = null;
                                        _selectedOfflineMethod = null;
                                        _selectedOfflineValue = null;
                                        _bringAmountController?.text = "";
                                        orderProvider.updateBringChangeInputOptionStatus(false, isUpdate: false);
                                        orderProvider.setBringChangeAmount();
                                      });
              
                                    },
              
                                    callBack: ({OfflinePaymentModel? offlinePaymentModel, List<Map<String, String>>? selectedOfflineValue}){
                                      setState(() {
                                        _selectedOfflineValue = selectedOfflineValue;
                                        _selectedOfflineMethod = offlinePaymentModel;
                                      });
                                    },
                                  ),
              
                                  if( hideOffline && hideDigital) Positioned.fill(child: Container(
                                    color: Colors.transparent,
                                  )),
              
                                ]),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                            ]),
                          ),
                        ),
                      ),
              
              
                      const SizedBox(height: Dimensions.paddingSizeDefault),
              
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge * (ResponsiveHelper.isDesktop(context) ? 2 : 1),),
                        child: orderProvider.isLoading   ? CustomLoaderWidget(color: Theme.of(context).primaryColor) : CustomButtonWidget(
                          buttonText: getTranslated('proceed', context),
                          onPressed: _paymentMethodIndex == null
                              && _paymentMethod == null
                              || (_paymentMethod != null && _paymentMethod?.type == 'offline' && _selectedOfflineMethod == null)
                              ? null : () {
              
                            if(_paymentMethod?.type == 'offline' && _selectedOfflineValue == null || (widget.orderId !=null && widget.orderId != "null" && orderProvider.selectedOfflineValue != null)){
              
                              if(widget.orderId !=null && widget.orderId != "null" && _selectedOfflineMethod != null){
              
                                ResponsiveHelper().showDialogOrBottomSheet(
                                  context, isScrollControlled: true,
                                  OfflinePaymentWidget(
                                    totalAmount: widget.totalPrice,
                                    selectedOfflineMethod: _selectedOfflineMethod,
                                    partialAmount: isPartialPayment && _partialAmount != null ? (widget.totalPrice - walletBalance) : widget.totalPrice,
                                    orderId: widget.orderId,
                                  ),
                                );
                              }else{
                                _placeOfflineOrder(orderProvider: orderProvider, weight: widget.weight, context: context);
                              }
              
                            }else{
                              if(_paymentMethodIndex == 1){
                                orderProvider.setBringChangeAmount(amountController: _bringAmountController);
                              }
                              orderProvider.savePaymentMethod(index: _paymentMethodIndex, method: _paymentMethod, partialAmount: _partialAmount, selectedOfflineValue: _selectedOfflineValue, selectedOfflineMethod: _selectedOfflineMethod);
              
                              /// Switch payment method for existing order
                              if(widget.orderId !=null && widget.orderId != "null"){
                                String paymentMethod = orderProvider.selectedOfflineValue != null
                                    ? 'offline_payment' : orderProvider.selectedPaymentMethod!.getWay!;
              
                                if(paymentMethod == 'wallet_payment' || paymentMethod == 'cash_on_delivery' || paymentMethod == 'offline_payment'){
                                  orderProvider.switchPaymentMethod(
                                    orderId: widget.orderId!,
                                    paymentMethod:  orderProvider.selectedPaymentMethod!.getWay!,
                                    isPartial: _partialAmount !=null && _partialAmount! > 0 ? 1 : 0,
                                    bringChangeAmount: double.tryParse(_bringAmountController?.text ?? "0"),
                                  );
                                }else{
                                  _switchOfflineToDigital(orderAmount: widget.totalPrice, paymentMethod: paymentMethod, partialAmount: _partialAmount, orderId: widget.orderId ?? "");
                                }
              
                              }else{
                                Navigator.of(context).pop();
                              }
              
                            }
                          },
                        ),
                      ),
              
                      SizedBox(height: bottomPadding> 0 ? 0 : Dimensions.paddingSizeDefault,)
              
                    ]);
                  }
              ),
            ),
          ),
        ),
      ]))),
    );
  }

  @override
  void initState() {
    super.initState();

    _bringAmountController = TextEditingController();

    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final ConfigModel configModel = splashProvider.configModel!;
    splashProvider.getOfflinePaymentMethod(false);

    partialPaymentCombinator = configModel.partialPaymentCombineWith?.toLowerCase() ?? "all";

    paymentList.addAll(configModel.activePaymentMethodList ?? []);

    if(configModel.isOfflinePayment!){
      paymentList.add(PaymentMethod(
        getWay: 'offline', getWayTitle: getTranslated('offline', context),
        type: 'offline',
        getWayImage: Images.offlinePayment,
      ));
    }
    _initializeData();
  }


  _initializeData (){
    final OrderProvider orderProvider =  Provider.of<OrderProvider>(context, listen: false);
    _paymentMethodIndex = orderProvider.paymentMethodIndex;
    _partialAmount = orderProvider.partialAmount ;
    _paymentMethod = orderProvider.paymentMethod;
    _selectedOfflineMethod = orderProvider.selectedOfflineMethod;
    _selectedOfflineValue = orderProvider.selectedOfflineValue;

    if(orderProvider.paymentMethodIndex != 1){
      orderProvider.setBringChangeAmount(isUpdate: false);
      orderProvider.updateBringChangeInputOptionStatus(false, isUpdate: false);
    }else{
      _bringAmountController?.text = "${orderProvider.bringChangeAmount?.floor() ?? ""}";
    }

  }

  _placeOfflineOrder({required OrderProvider orderProvider, required  double? weight, required BuildContext context}){

    CheckOutModel? checkOutData = orderProvider.getCheckOutData;
    final bool isSelfPickup = CheckOutHelper.isSelfPickup(orderType: checkOutData?.orderType);
    final configModel = Provider.of<SplashProvider>(context, listen: false).configModel;
    List<CartModel> cartList = Provider.of<CartProvider>(context, listen: false).cartList;
    List<Cart> carts = [];


    for (int index = 0; index < cartList.length; index++) {
      Cart cart = Cart(
        productId: cartList[index].id, price: cartList[index].price,
        discountAmount: cartList[index].discountedPrice,
        quantity: cartList[index].quantity, taxAmount: cartList[index].tax,
        variant: '', variation: [Variation(type: cartList[index].variation?.type)],
      );
      carts.add(cart);
    }

    PlaceOrderModel placeOrderBody = PlaceOrderModel(
      cart: carts, orderType: checkOutData?.orderType,
      couponCode: checkOutData?.couponCode,
      orderNote: checkOutData?.orderNote,
      branchId: configModel!.branches![orderProvider.branchIndex].id,
      deliveryAddressId: !isSelfPickup
          ? Provider.of<LocationProvider>(context, listen: false).addressList![orderProvider.addressIndex].id
          : 0, distance: isSelfPickup ? 0 : orderProvider.distance,
      couponDiscountAmount: Provider.of<CouponProvider>(context, listen: false).discount,
      timeSlotId: orderProvider.timeSlots![orderProvider.selectTimeSlot].id,
      paymentMethod:  'offline_payment',
      deliveryDate: orderProvider.getDateList()[orderProvider.selectDateSlot],
      couponDiscountTitle: '',
      orderAmount: (checkOutData!.amount ?? 0) + (orderProvider.deliveryCharge ?? 0) + (weight ?? 0),
      selectedDeliveryArea: orderProvider.selectedAreaID,
      isPartial: _partialAmount != null && _partialAmount! > 0 ? '1' : '0' ,
      bringChangeAmount: orderProvider.bringChangeAmount,
    );
    orderProvider.placeOrder(placeOrderBody, _callback);
  }

  void _callback(bool isSuccess, String message, String orderID, ) async {
    if (isSuccess) {
      Provider.of<OrderProvider>(Get.context!, listen: false).stopLoader();
      Provider.of<CartProvider>(Get.context!, listen: false).clearCartList();
      double walletBalance =  Provider.of<ProfileProvider>(Get.context!, listen: false).userInfoModel?.walletBalance ?? 0;
      bool isPartialPayment = widget.totalPrice > walletBalance;
      Navigator.of(context).pop();

      ResponsiveHelper().showDialogOrBottomSheet(
        context, isScrollControlled: true, isDismissible: false, enableDrag: false,
        OfflinePaymentWidget(
          totalAmount: widget.totalPrice,
          selectedOfflineMethod: _selectedOfflineMethod,
          partialAmount: isPartialPayment && _partialAmount != null ? (widget.totalPrice - walletBalance) : widget.totalPrice,
          orderId: orderID,
          fromCheckout: true,
        ),
      );
      showFlutterCustomToaster(
        "now_pay_you_bill_using_the_payment_method",
        toasterTitle: "your_order_has_placed_successfully",
        context: context, type: ToasterMessageType.success,
        duration: 4
      );
    } else {
      showFlutterCustomToaster(message.replaceAll("_", " "), context: context);
    }
  }

  _switchOfflineToDigital({required String paymentMethod, required double orderAmount, double? partialAmount, required  String orderId}){

    String? hostname = html.window.location.hostname;
    String protocol = html.window.location.protocol;
    String port = html.window.location.port;

    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ProfileProvider profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    String url = "customer_id=${profileProvider.userInfoModel?.id ?? authProvider.getGuestId()}&&is_guest=${authProvider.getGuestId() != null ? '1' :'0'}"
        "&&callback=${AppConstants.baseUrl}${RouteHelper.orderDetails}&&order_amount=$orderAmount";

    String webUrl = "customer_id=${profileProvider.userInfoModel?.id ?? authProvider.getGuestId()}&&is_guest=${authProvider.getGuestId() != null ? '1' :'0'}"
        "&&callback=$protocol//$hostname${kDebugMode ? ':$port' : ''}${RouteHelper.orderDetails}&&order_amount=$orderAmount&&status=";

    String tokenUrl = convert.base64Encode(convert.utf8.encode(ResponsiveHelper.isWeb() ? webUrl : url));
    String selectedUrl = '${AppConstants.baseUrl}/payment-mobile?token=$tokenUrl&&payment_method=$paymentMethod&&payment_platform=${kIsWeb ? 'web' : 'app'}&&is_partial=${partialAmount == null ? '0' : '1'}&&order_id=$orderId&&switch_offline_to_digital=1';

    if(ResponsiveHelper.isWeb()){
      html.window.open(selectedUrl,"_self");

    }else{
      Navigator.pushReplacementNamed(Get.context!, RouteHelper.getPaymentRoute(
        url: selectedUrl,
        id: orderId
      ));

    }
  }
}


