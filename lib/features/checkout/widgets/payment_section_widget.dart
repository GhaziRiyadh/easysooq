import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/checkout_helper.dart';
import 'package:flutter_grocery/helper/price_converter_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/custom_shadow_widget.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:provider/provider.dart';

import 'payment_method_bottom_sheet_widget.dart';
class PaymentSectionWidget extends StatelessWidget {
  final double total;
  const PaymentSectionWidget({super.key, required this.total});


  void openDialog(BuildContext context){
    final OrderProvider orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (!CheckOutHelper.isSelfPickup(orderType: orderProvider.orderType) && orderProvider.addressIndex == -1) {
      showCustomSnackBarHelper(getTranslated('select_delivery_address', context),isError: true);
    }else if (orderProvider.timeSlots == null || orderProvider.timeSlots!.isEmpty) {
      showCustomSnackBarHelper(getTranslated('select_a_time', context),isError: true);
    }else {
      ResponsiveHelper().showDialogOrBottomSheet(context,  PaymentMethodBottomSheetWidget(totalPrice: total,), isScrollControlled: true);
    }

  }


  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(builder: (context, orderProvider, _) {
      bool showPayment = orderProvider.selectedPaymentMethod != null;

      return CustomShadowWidget(
        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
        padding: const EdgeInsets.only(top : Dimensions.paddingSizeDefault, bottom: 7),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Text(getTranslated('payment_method', context), style: poppinsBold.copyWith(
                fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeLarge : Dimensions.fontSizeDefault,
                fontWeight: ResponsiveHelper.isDesktop(context) ? FontWeight.w700 : FontWeight.w600,
              )),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: TextButton(
                onPressed: ()=> openDialog(context),
                child: Text(getTranslated(showPayment ? 'change' : 'add', context), style: poppinsBold.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontSize:  Dimensions.fontSizeDefault ,
                )),
              ),
            ),
          ]),

          const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Divider(thickness: 0.5, height: 0.5, color: Theme.of(context).hintColor.withValues(alpha: 0.4)),
          ),

          if(!showPayment ) Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal : Dimensions.paddingSizeDefault ),
            child: InkWell(
              onTap: ()=> openDialog(context),
              child: Row(children: [
                const Icon(Icons.add_circle_outline, size: Dimensions.paddingSizeLarge),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Text(
                  getTranslated('add_payment_method', context),
                  style: poppinsSemiBold.copyWith(fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeDefault : Dimensions.fontSizeSmall),
                ),
              ]),
            ),
          ),

          if(showPayment) Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeLarge),
            child: _SelectedPaymentView(total:  total),
          ),

        ]),
      );
    });
  }
}


class _SelectedPaymentView extends StatelessWidget {
  const _SelectedPaymentView({
    required this.total,
  });

  final double total;

  @override
  Widget build(BuildContext context) {
    final OrderProvider checkoutProvider = Provider.of<OrderProvider>(context, listen: false);

    double paidAmount = checkoutProvider.partialAmount !=null && checkoutProvider.partialAmount! > 0
        ? (total -  checkoutProvider.partialAmount!) : total;

    return  Column(children: [
      if(checkoutProvider.partialAmount == null) rowTextWidget(
          title: checkoutProvider.selectedOfflineMethod != null
              ? '${getTranslated('offline_payment', context)} (${checkoutProvider.selectedOfflineMethod?.methodName})'
              : checkoutProvider.selectedPaymentMethod?.getWayTitle ?? '',
          subTitle: PriceConverterHelper.convertPrice(context,paidAmount),
          context: context
      ),

      if(checkoutProvider.partialAmount != null) ...[
        rowTextWidget(
            title: getTranslated('paid_by_wallet', context) ,
            subTitle: PriceConverterHelper.convertPrice(context, checkoutProvider.partialAmount),
            context: context
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        rowTextWidget(
            title: "${ checkoutProvider.selectedOfflineMethod != null
                ? "${getTranslated('paid_by', context)} ${checkoutProvider.selectedOfflineMethod?.methodName}"
                : checkoutProvider.selectedPaymentMethod?.getWayTitle ?? ''} (${getTranslated('due', context)})",
            subTitle: PriceConverterHelper.convertPrice(context, paidAmount),
            context: context
        ),
      ],

      if(checkoutProvider.selectedOfflineValue != null) Padding(
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
        child: Column(children: checkoutProvider.selectedOfflineValue!.map((method) => Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
          child: Row(children: [
            Flexible(child: Text(method.keys.single, style: poppinsRegular.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7), fontSize: Dimensions.fontSizeSmall,
            ), maxLines: 1, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            Flexible(child: Text(' :  ${method.values.single}', style: poppinsRegular.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7), fontSize: Dimensions.fontSizeSmall,
            ), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
        )).toList()),
      ),
    ]);
  }

  Widget rowTextWidget({required String title, required String subTitle, required BuildContext context}){
    return  Row(children: [
      Expanded(child: Text(title,
        style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeDefault,
          color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
        ),
      )),
      Text(subTitle, textDirection: TextDirection.ltr,
        style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault),
      )
    ]);
  }
}
