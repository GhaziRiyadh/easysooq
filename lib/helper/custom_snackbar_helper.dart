import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showCustomSnackBarHelper(String message, {bool isError = true, Duration? duration, Widget? content, EdgeInsetsGeometry? margin, Color? backgroundColor, EdgeInsetsGeometry? padding}) {
  ScaffoldMessenger.of(Get.context!).clearSnackBars();
  final double width = MediaQuery.of(Get.context!).size.width;
  ScaffoldMessenger.of(Get.context!)..hideCurrentSnackBar()..showSnackBar(SnackBar(key: UniqueKey(), content: content ??  Text(message, style: poppinsLight.copyWith(color: Colors.white),),
      margin: ResponsiveHelper.isDesktop(Get.context!) ? margin ??  EdgeInsets.only(
        right: width * 0.75, bottom: Dimensions.paddingSizeLarge, left: Dimensions.paddingSizeExtraSmall,
      ) : null,
      duration: duration ?? const Duration(milliseconds: 4000),
      behavior: ResponsiveHelper.isDesktop(Get.context!) ? SnackBarBehavior.floating : SnackBarBehavior.fixed ,
      dismissDirection: DismissDirection.down,
      backgroundColor: backgroundColor ?? (isError ? Colors.red : Colors.green),
    padding: padding,

      ),
  );
}


void showFlutterDefaultToaster({required String message, bool isError = true, Color? backgroundColor}){
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    backgroundColor: backgroundColor ?? (isError ? Colors.red : Colors.green),
  );
}

enum ToasterMessageType {success, error, info}

void showFlutterCustomToaster(String? message, {ToasterMessageType type = ToasterMessageType.error,
  double margin = Dimensions.paddingSizeSmall,int duration = 3,
  Color? backgroundColor, Widget? customWidget, double borderRadius = Dimensions.radiusSizeSmall,
  bool showDefaultSnackBar = true,
  String? icon, String? toasterTitle,
  required BuildContext context,
}) {
  FToast fToast = FToast();
  fToast.init(context);
  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    margin: EdgeInsets.only(bottom: 50),
    decoration: BoxDecoration(
      color: const Color(0xFF393f47), borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
    ),
    child: Row(  mainAxisSize: MainAxisSize.min, children: [
      icon !=null  ? Image.asset(icon, width: 25,) : Icon( type == ToasterMessageType.error ? CupertinoIcons.multiply_circle_fill : type == ToasterMessageType.info ?  Icons.info  : Icons.check_circle,
        color: type == ToasterMessageType.info  ?  Colors.blueAccent : type == ToasterMessageType.error? const Color(0xffFF9090).withValues(alpha: 0.5) : const Color(0xff039D55),
        size: 20,
      ),
      const SizedBox(width: Dimensions.paddingSizeSmall),

      Flexible(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if(toasterTitle !=null) Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(getTranslated(toasterTitle, context), style: poppinsMedium.copyWith(color : Colors.white, ), maxLines: 3, overflow: TextOverflow.ellipsis,),
          ),
          Text(getTranslated(message ?? "", context), style: poppinsRegular.copyWith(color : Colors.white.withValues(alpha:0.8), height: toasterTitle !=null ?  1.0 : 1.2), maxLines: 3, overflow: TextOverflow.ellipsis),
        ]),
      ),
    ]),
  );

  fToast.showToast(
    child: toast,
    gravity: ToastGravity.BOTTOM,
    toastDuration: Duration(seconds: duration),
  );

}