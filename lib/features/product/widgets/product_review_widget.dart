import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/review_model.dart';
import 'package:flutter_grocery/common/widgets/custom_single_child_list_widget.dart';
import 'package:flutter_grocery/features/product/screens/preview_screen.dart';
import 'package:flutter_grocery/helper/date_converter_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/custom_image_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ProductReviewWidget extends StatelessWidget {
  final Review? review;
  const ProductReviewWidget({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
        color: Theme.of(context).hintColor.withValues(alpha: 0.05),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

          ClipOval(child: CustomImageWidget(
            image: '${splashProvider.baseUrls?.customerImageUrl}/${review?.user?.image ?? ''}',
            height: 50, width: 50, fit: BoxFit.cover,
          )),
          SizedBox(width: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeExtraSmall),

          Expanded(child: Column(crossAxisAlignment:CrossAxisAlignment.start, children: [

              Row(children: [
                Expanded(
                  child: Text(
                    review?.user != null ? '${review?.user?.fName ?? ''} ${review?.user?.lName ?? ''}' : getTranslated('user_not_available', context),
                    style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: Dimensions.paddingSizeExtraSmall),

                if(review?.createdAt != null) Text(DateConverterHelper.getDateToDateDifference(
                  DateConverterHelper.convertStringToDatetime(review?.createdAt ?? ''), context,
                )),
              ]),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Row(children: [

                const Icon(Icons.star_rounded, color: ColorResources.ratingColor, size: 20),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                Text('${review?.rating}', style: poppinsMedium.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.80),
                  fontSize: Dimensions.fontSizeDefault,
                )),

              ]),
              SizedBox(height: Dimensions.paddingSizeSmall),

              Text(review?.comment ?? '', style: poppinsRegular.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.70),
                fontSize: Dimensions.fontSizeDefault,
              )),
              SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : Dimensions.radiusSizeDefault),
            ])),
        ]),

        CustomSingleChildListWidget(
          scrollDirection: Axis.horizontal,
          itemCount: review?.attachment?.length ?? 0,
          itemBuilder: (index){
            return _ReviewImageWidget(imageList: review?.attachment ?? [], index: index);
          },
        ),
      ]),
    );
  }
}

class _ReviewImageWidget extends StatelessWidget {
  const _ReviewImageWidget({
    required this.imageList,
    required this.index,
  });

  final List<String> imageList;
  final int index;

  @override
  Widget build(BuildContext context) {
    final widthSize = MediaQuery.sizeOf(context).width;
    final heightSize = MediaQuery.sizeOf(context).height;

    return Container(
      margin: EdgeInsets.only(right: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeDefault : Dimensions.radiusSizeDefault),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
          border: Border.all(width: 1, color: Colors.black.withValues(alpha: 0.03))
      ),
      child: InkWell(
        onTap: () {
          if(ResponsiveHelper.isDesktop(context)){
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault)),
                  insetPadding: EdgeInsets.symmetric(horizontal: widthSize * 0.3, vertical: heightSize * 0.2),
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  child: PreviewScreen(images: imageList, selectedIndex: index),
                );
              },
            );
          }
          else{
            Navigator.push(context, MaterialPageRoute(builder: (_)=> PreviewScreen(images: imageList, selectedIndex: index)));
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
          child: CustomImageWidget(image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.reviewImageUrl}/${imageList[index]}', width: 75, height: 75, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class ReviewShimmer extends StatelessWidget {
  const ReviewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).cardColor,
      ),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        enabled: true,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipOval(
              child: Container(
                height: 50,
                width: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Container(
                    height: 16,
                    width: 100,
                    color: Colors.white,
                  ),
                  Container(
                    height: 14,
                    width: 80,
                    color: Colors.white,
                  ),
                ]),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Row(children: [
                  const Icon(Icons.star_rounded, color: ColorResources.ratingColor, size: 20),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Container(
                    height: 14,
                    width: 20,
                    color: Colors.white,
                  ),
                ]),
                SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall),
                Container(
                  height: 14,
                  width: double.infinity,
                  color: Colors.white,
                ),
                const SizedBox(height: Dimensions.radiusSizeDefault),
                CustomSingleChildListWidget(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  itemBuilder: (index) {
                    return Container(
                      padding: const EdgeInsets.only(right: Dimensions.radiusSizeDefault),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
                        border: Border.all(width: 1, color: Colors.black.withValues(alpha: 0.03)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
                        child: Container(width: 75, height: 75, color: Colors.white),
                      ),
                    );
                  },
                ),
              ]),
            ),
          ]),
        ]),
      ),
    );
  }
}

