import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_grocery/main.dart';

class ResponsiveHelper {

  static bool isMobilePhone() {
    if (!kIsWeb) {
      return true;
    }else {
      return false;
    }
  }

  static bool isWeb() {
    return kIsWeb;
  }

  static bool isMobile() {
    final size = MediaQuery.of(Get.context!).size.width;
    if (size < 650 || !kIsWeb) {
      return true;
    } else {
      return false;
    }
  }

  static bool isTab(context) {
    final size = MediaQuery
        .of(context)
        .size
        .width;
    if (size < 1300 && size >= 660) {
      return true;
    } else {
      return false;
    }
  }

  static bool isDesktop(context) {
    final size = MediaQuery
        .of(context)
        .size
        .width;
    if (size >= 1300) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> showDialogOrBottomSheet(BuildContext context, Widget view, {bool isScrollControlled = true, bool isDismissible = true, bool enableDrag = true})  async {
    if(ResponsiveHelper.isDesktop(context)) {
      await showDialog(
        barrierDismissible: isDismissible,
        context: context, builder: (ctx)=> Center(child: view),
      );
    }else{
      await   showModalBottomSheet(
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        backgroundColor: Colors.transparent,
        isScrollControlled: isScrollControlled,
        useSafeArea: true,
        context: context,
        builder: (ctx) => view,
      );
    }
  }
}