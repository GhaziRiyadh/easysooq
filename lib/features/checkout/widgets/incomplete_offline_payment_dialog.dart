import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/config_model.dart';
import 'package:flutter_grocery/common/widgets/custom_button_widget.dart';
import 'package:flutter_grocery/features/checkout/widgets/payment_method_bottom_sheet_widget.dart';
import 'package:flutter_grocery/features/order/domain/models/order_model.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/features/order/widgets/order_cancel_widget.dart';
import 'package:flutter_grocery/features/order/widgets/switch_payment_confirmation_widget.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:flutter_grocery/helper/price_converter_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';

class IncompleteOfflinePaymentDialog extends StatefulWidget {
  final OrderModel? order;
  const IncompleteOfflinePaymentDialog({super.key, this.order});

  @override
  State<IncompleteOfflinePaymentDialog> createState() => _IncompleteOfflinePaymentDialogState();
}

class _IncompleteOfflinePaymentDialogState extends State<IncompleteOfflinePaymentDialog> {

  @override
  void initState() {
    super.initState();
    Provider.of<OrderProvider>(context, listen: false).setLastIncompleteOfflineBookingId(widget.order?.id ?? 0);
  }

  @override
  Widget build(BuildContext context) {

    final ConfigModel? configModel = Provider.of<SplashProvider>(context, listen: false).configModel;
    double? bookingAmount = widget.order?.orderAmount;
    double? dueAmount;
    bool isPartialPayment = widget.order?.orderPartialPayments != null && (widget.order?.orderPartialPayments?.isNotEmpty ?? false);

    if(isPartialPayment){
      widget.order?.orderPartialPayments?.forEach((element){
        if(element.paidWith == "wallet_payment"){
          dueAmount = element.dueAmount ?? 0;
        }
      });
    }


    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius :BorderRadius.only(
          topLeft: const Radius.circular(Dimensions.paddingSizeDefault),
          topRight : const Radius.circular(Dimensions.paddingSizeDefault),
          bottomLeft: ResponsiveHelper.isDesktop(context) ?  const Radius.circular(Dimensions.paddingSizeDefault) : Radius.zero,
          bottomRight:  ResponsiveHelper.isDesktop(context) ?  const Radius.circular(Dimensions.paddingSizeDefault) : Radius.zero,
        ),
      ),
      child: Consumer<OrderProvider>(builder: (ctx, orderProvider,_){
        return SizedBox(width: Dimensions.webScreenWidth / 2.5, child: Stack(
          clipBehavior: Clip.none,
          children: [

            Padding(
              padding: const EdgeInsets.symmetric( horizontal : Dimensions.paddingSizeLarge),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeLarge),
                  child: Text( getTranslated("your_payment_was_incomplete", context), textAlign: TextAlign.center,
                    style: poppinsBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                      color: Theme.of(context).hintColor.withValues(alpha: 0.05)
                  ),
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),

                  child: Row(children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(getTranslated('order_id', context), style: poppinsLight),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall,),
                      Text('#${widget.order?.id ?? ""}', style: poppinsMedium,),
                    ]),

                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(child: Column(crossAxisAlignment: isPartialPayment ? CrossAxisAlignment.center : CrossAxisAlignment.end, children: [
                      Text(getTranslated('amount', context), style: poppinsLight,),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall,),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child:  Text(PriceConverterHelper.convertPrice( context, bookingAmount ?? 0), style: poppinsMedium, maxLines: 1, overflow: TextOverflow.ellipsis,),
                      ),
                    ])),

                    if(isPartialPayment) const SizedBox(width: Dimensions.paddingSizeSmall),

                    if(isPartialPayment) Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(getTranslated('due_amount', context), style: poppinsLight,),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall,),
                      Text(PriceConverterHelper.convertPrice(context, dueAmount ?? 0), style: poppinsMedium,),
                    ]),
                  ]),

                ),

                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Text(getTranslated("your_payment_was_incomplete_please_pay", context),
                    style: poppinsMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5)),
                    textAlign: TextAlign.center,
                  ),
                ) ,

                const SizedBox(height: Dimensions.paddingSizeDefault),



                CustomButtonWidget(
                  buttonText:  getTranslated("confirm_payment_now", context),
                  onPressed: () {
                    Navigator.of(context).pop();

                    ResponsiveHelper().showDialogOrBottomSheet(
                      context,  PaymentMethodBottomSheetWidget(
                      totalPrice: dueAmount ?? widget.order?.orderAmount ?? 0,
                      orderId: widget.order?.id.toString(),
                      isAlreadyPartialApplied: isPartialPayment,
                    ),
                      isScrollControlled: true,
                    );

                  },
                ),

                const SizedBox(height : Dimensions.paddingSizeLarge),
                configModel?.cashOnDelivery != false  ? TextButton(
                  onPressed: ()  async  {

                    Navigator.of(context).pop();

                    showDialog(context: context, barrierDismissible: false, builder: (context) => SwitchPaymentConfirmationWidget(
                      orderID:  widget.order?.id.toString() ?? "",
                      paymentMethod : "cash_on_delivery",
                      callback: (String message, bool isSuccess, String orderID) {
                        if (isSuccess) {
                          showCustomSnackBarHelper('$message ${'order_id'.tr}: $orderID', isError: false);
                        } else {
                          showCustomSnackBarHelper(message);
                        }
                      },
                    ));
                  },
                  style: TextButton.styleFrom(
                    backgroundColor:   Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    minimumSize: const Size(Dimensions.webScreenWidth, 45),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall)),
                  ),
                  child: Text(  getTranslated('switch_to_cas', context), textAlign: TextAlign.center,
                    style: poppinsMedium.copyWith(color:  Theme.of(context).textTheme.bodyLarge!.color,
                      fontSize:  Dimensions.fontSizeDefault,
                    ),
                  ),
                ) : SizedBox(),

                SizedBox(height : configModel?.cashOnDelivery != false  ? Dimensions.paddingSizeSmall : 0),

                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    showDialog(context: context, barrierDismissible: false, builder: (context) => OrderCancelWidget(
                      orderID: widget.order?.id.toString() ?? "",
                      fromOrder: false,
                      callback: (String message, bool isSuccess, String orderID) {

                      },
                    ));
                  },
                  style: TextButton.styleFrom(
                    backgroundColor:   Colors.transparent,
                    minimumSize: const Size(Dimensions.webScreenWidth, 45),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall)),
                  ),
                  child: Text( getTranslated('cancel_order', context), textAlign: TextAlign.center,
                    style: poppinsMedium.copyWith(color:  Theme.of(context).colorScheme.error,
                      fontSize:  Dimensions.fontSizeDefault,
                    ),
                  ),
                ),
                if(!ResponsiveHelper.isDesktop(context)) const SizedBox(width: Dimensions.paddingSizeLarge),

                const SizedBox(height: Dimensions.paddingSizeExtraLarge)

              ]),
            ),

            Positioned(
              top: 10,
              right: 0,
              child: InkWell(
                onTap: ()=> Navigator.of(context).pop(),
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).hintColor.withValues(alpha: 0.25)
                  ),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  child: const Icon(Icons.close, size: 20, color: Colors.white,),
                ),
              ),
            ),
          ],
        ));
      }),
    );
  }
}
