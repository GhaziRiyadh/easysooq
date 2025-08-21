// import 'package:flutter/material.dart';
// import 'package:flutter_restaurant/features/order_track/providers/tracker_provider.dart';
// import 'timer_widget.dart';
// import 'package:flutter_restaurant/localization/language_constrants.dart';
// import 'package:flutter_restaurant/utill/dimensions.dart';
// import 'package:flutter_restaurant/utill/styles.dart';
// import 'package:provider/provider.dart';
//
// class TrackMapTimerWidget extends StatelessWidget {
//   const TrackMapTimerWidget({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<TrackerProvider>( builder: (context, orderTimer, _) {
//       int? days, hours, minutes, seconds;
//       if (orderTimer.duration != null) {
//         days = orderTimer.duration!.inDays;
//         hours = orderTimer.duration!.inHours - days * 24;
//         minutes = orderTimer.duration!.inMinutes - (24 * days * 60) - (hours * 60);
//         seconds = orderTimer.duration!.inSeconds - (24 * days * 60 * 60) - (hours * 60 * 60) - (minutes * 60);
//
//         return days > 0 || hours > 0 ? Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
//             if(days > 0) TimerBox(time: days, text: getTranslated('day', context), isBorder: true),
//             if(days > 0) const SizedBox(width: 5),
//
//             if(days > 0) Text(':', style: TextStyle(color: Theme.of(context).primaryColor)),
//             if(days > 0) const SizedBox(width: 5),
//
//             TimerBox(time: hours, text: getTranslated('hour', context), isBorder: true),
//             const SizedBox(width: 5),
//
//             Text(':', style: TextStyle(color: Theme.of(context).primaryColor)),
//             const SizedBox(width: 5),
//
//             TimerBox(time: minutes, text: getTranslated('min', context), isBorder: true),
//             const SizedBox(width: 5),
//
//             Text(':', style: TextStyle(color: Theme.of(context).primaryColor)),
//             const SizedBox(width: 5),
//             TimerBox(time: seconds,text: getTranslated('sec', context), isBorder: true,),
//
//             const SizedBox(width: 5),
//           ]),
//         ) : Row(mainAxisAlignment: MainAxisAlignment.start, children: [
//           Text('${minutes < 5 ? 0 : minutes - 5} - ${minutes < 5 ? 5 : minutes}',
//             style: rubikMedium,
//           ),
//           const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//           Text(getTranslated('minutes', context)!, style: rubikMedium),
//
//         ]);
//       }else{
//         return const SizedBox();
//       }
//
//     });
//   }
// }