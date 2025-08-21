import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/widgets/custom_asset_image_widget.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/helper/price_converter_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';


class PaymentButtonWidget extends StatelessWidget {
  final String icon;
  final String title;
  final bool isSelected;
  final bool isWallet;
  final double totalPrice;
  final double walletBalance;
  final bool hidePaymentMethod;
  final double? partialAmount;
  final bool chooseAnyPayment;
  final void Function({int? paymentMethodIndex, double? partialAmount}) callBack;
  const PaymentButtonWidget({
    super.key, required this.isSelected,
    required this.icon, required this.title,
    this.isWallet = false,
    required this.walletBalance, required this.totalPrice,
    required this.hidePaymentMethod, this.partialAmount,
    required this.chooseAnyPayment, required this.callBack
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(builder: (ctx, checkoutProvider, _) {
      return  Padding(
        padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        child: isWallet ? _WalletPaymentView (title, icon, walletBalance , totalPrice, isSelected, partialAmount, chooseAnyPayment, callBack) :
        _CashAfterServiceView(icon, title, isSelected, checkoutProvider, hidePaymentMethod, callBack),
      );
    });
  }
}

class _CashAfterServiceView extends StatelessWidget {
  final String icon;
  final String title;
  final bool isSelected;
  final OrderProvider checkoutProvider;
  final bool hidePaymentMethod;
  final void Function({int? paymentMethodIndex}) callBack;
  const _CashAfterServiceView(this.icon, this.title, this.isSelected, this.checkoutProvider, this.hidePaymentMethod, this.callBack);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: hidePaymentMethod ? null : () {
        callBack(paymentMethodIndex : 1);
      },
      child: Opacity(
        opacity: hidePaymentMethod ? 0.4 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical : Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSizeDefault)),
            border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.3), width: 0.3),
          ),
          child: Row(children: [
            const SizedBox(width: Dimensions.paddingSizeSmall),
            CustomAssetImageWidget(icon,height: 20, width: 20,),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: Text(title, style: poppinsRegular.copyWith(
                overflow: TextOverflow.ellipsis, fontSize: Dimensions.fontSizeDefault,
              )),
            ),

            Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.transparent,
                  border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, width: 2)
              ),
              padding: const EdgeInsets.all(2),
              child:  Icon(Icons.circle, color: isSelected ? Theme.of(context).primaryColor : Colors.transparent , size: 10) ,
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
          ]),
        ),
      ),
    );
  }
}


class _WalletPaymentView extends StatelessWidget {
  final String title;
  final String assetName;
  final double walletBalance;
  final double totalPrice;
  final bool isSelected;
  final double? partialAmount;
  final bool chooseAnyPayment;
  final void Function({int? paymentMethodIndex, double? partialAmount}) callBack;

  const _WalletPaymentView(this.title, this.assetName, this.walletBalance, this.totalPrice, this.isSelected, this.partialAmount, this.chooseAnyPayment, this.callBack);

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(builder: (ctx, checkoutProvider, _){

      bool isPartialPayment = totalPrice > walletBalance;
      bool isWalletPaymentApplied = isPartialPayment ? (partialAmount != null) : isSelected;
      double paidAmount =  (isPartialPayment ? walletBalance : totalPrice);
      double remainingWalletBalance = isPartialPayment ? 0 : (walletBalance ) - (totalPrice );
      double remainingBill = (totalPrice) - paidAmount;


      return Opacity(
        opacity: ((walletBalance) <= 0) ? 0.5 : 1,
        child: Stack(children: [

          Column( children: [
            walletCartWidget(context, isWalletPaymentApplied, remainingWalletBalance, walletBalance, isPartialPayment, checkoutProvider, callBack),
            if(isWalletPaymentApplied) const SizedBox(height: Dimensions.paddingSizeDefault),
            if(isWalletPaymentApplied) remainingBalanceWidget(isWalletPaymentApplied, context, isPartialPayment, paidAmount, remainingBill),
            if(isPartialPayment && isWalletPaymentApplied && !chooseAnyPayment) Padding(
              padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall, left: 20, right: 20),
              child: Text(getTranslated("pay_the_rest_amount_hint", context),
                style: poppinsRegular.copyWith(color: Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeSmall),
                textAlign: TextAlign.center,
              ),
            )
          ]) ,

          if((walletBalance) <= 0) Positioned.fill(child: Container(
            color: Colors.transparent,
          ))
        ]),
      );
    });
  }

  Widget remainingBalanceWidget(bool walletPaymentStatus, BuildContext context, bool isPartialPayment, double paidAmount, double remainingBill) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical : Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).hintColor.withValues(alpha: 0.03),
        borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSizeSmall)),
        border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.2), width: 0.3),
      ),
      child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(getTranslated('paid_by_wallet', context),
            style: isPartialPayment ? poppinsRegular.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7) ,
            ) : poppinsMedium,
          ),
          Text(PriceConverterHelper.convertPrice(context,paidAmount),
            style: isPartialPayment ? poppinsRegular.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7) ,
            ) : poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
        ]),

        if(isPartialPayment) const SizedBox(height: Dimensions.paddingSizeSmall,),

        if(isPartialPayment) Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text( getTranslated('remaining_bill', context), style: poppinsMedium,),
          Text( PriceConverterHelper.convertPrice(context,remainingBill),
            style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
        ]),

      ]),
    );
  }

  Widget walletCartWidget(
      BuildContext context, bool walletPaymentStatus,
      double remainingWalletBalance, double walletBalance,
      bool isPartialPayment, OrderProvider orderProvider,
      Function({int? paymentMethodIndex, double? partialAmount}) callBack
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical : Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSizeDefault)),
        border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.3), width: 0.3),
      ),
      child: Center(
        child: Row(children: [
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text((walletPaymentStatus ? getTranslated("wallet_remaining_balance", context) : getTranslated("wallet_balance", context)), style: poppinsRegular.copyWith(
                overflow: TextOverflow.ellipsis, fontSize: Dimensions.fontSizeDefault-1,
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
              )),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall,),
              Row( children: [
                Text(PriceConverterHelper.convertPrice(context ,walletPaymentStatus ? remainingWalletBalance : walletBalance), style: poppinsMedium.copyWith(
                  overflow: TextOverflow.ellipsis, fontSize: Dimensions.fontSizeExtraLarge,
                )),
                if(walletPaymentStatus) Text("  (${getTranslated("applied", context)}) ",
                  style: poppinsRegular.copyWith(color: Theme.of(context).primaryColor),
                ),
              ]),


            ]),
          ),

          walletPaymentStatus ? Row(children: [
            const SizedBox(width: Dimensions.paddingSizeSmall,),
            InkWell(
              onTap: (){
                callBack(partialAmount: null, paymentMethodIndex: null);
                orderProvider.changePaymentMethod(isClear: true, isUpdate: true);
              },
              child: Icon(Icons.close, size: 25, color: Theme.of(context).colorScheme.error,),
            )
          ]) : InkWell(
            onTap: (){
              if(isPartialPayment){
                callBack(partialAmount: walletBalance);
              }else{
                callBack(paymentMethodIndex: 0);
              }
              // orderProvider.updateBringChangeInputOptionStatus(false, isUpdate: false);
              // orderProvider.setBringChangeAmount();
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                border: Border.all(color: Theme.of(context).primaryColor),
              ),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall - 2),
              child: Text(getTranslated("apply", context), style: poppinsMedium.copyWith(color: Theme.of(context).primaryColor),
              ),
            ),
          ),

          const SizedBox(width: Dimensions.paddingSizeSmall),
        ]),
      ),
    );
  }
}
