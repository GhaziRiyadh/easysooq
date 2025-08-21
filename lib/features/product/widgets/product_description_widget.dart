import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/providers/product_provider.dart';
import 'package:flutter_grocery/common/widgets/paginated_list_widget.dart';
import 'package:flutter_grocery/features/product/widgets/product_review_widget.dart';
import 'package:flutter_grocery/features/product/widgets/rating_bar_widget.dart';
import 'package:flutter_grocery/features/product/widgets/rating_line_widget.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDescriptionWidget extends StatelessWidget {
  final Function(int index) onTabChange;
  final Function(bool status) onChangeButtonStatus;
  final int tabIndex;
  final bool showSeeMoreButton;
  final ScrollController scrollController;
  const ProductDescriptionWidget({
    super.key, required this.tabIndex,
    required this.onTabChange,
    required this.showSeeMoreButton,
    required this.onChangeButtonStatus,
    required this.scrollController,
  });


  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(builder: (context, productProvider, _) {
      return Column(crossAxisAlignment:CrossAxisAlignment.start, children: [

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Expanded(
              flex: ResponsiveHelper.isDesktop(context) ? 1 : 3,
              child: InkWell(
                hoverColor: Colors.transparent,
                onTap: (){
                  onTabChange(0);
                },
                child: Column(
                  children: [

                    Text(getTranslated('description', context), style: poppinsSemiBold.copyWith(
                      color: tabIndex == 0 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                    )),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Container(
                      height: 3,
                      color: tabIndex == 0 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.05),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              flex: ResponsiveHelper.isDesktop(context) ? 1 : 3,
              child: InkWell(
                hoverColor: Colors.transparent,
                onTap: (){
                  onTabChange(1);
                },
                child: Column(

                  children: [

                    Text(getTranslated('review', context), style: poppinsSemiBold.copyWith(
                      color: tabIndex == 1 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                    )),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Container(
                      height: 3,
                      color: tabIndex == 1 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.05),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(flex: 6, child: Column(children: [
              const Text('', style: poppinsSemiBold),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Container(
                height: 3,
                color: Theme.of(context).disabledColor.withValues(alpha: 0.05),
              ),

            ])),
          ]),
        ),


        tabIndex == 0 ? Stack(children: [
          Container(
            height: (productProvider.product != null && productProvider.product!.description != null && productProvider.product!.description!.length > 300) && showSeeMoreButton ? 100 : null,
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall).copyWith(bottom: showSeeMoreButton ? 0 : 40),
            width: Dimensions.webScreenWidth,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: HtmlWidget(
                productProvider.product?.description ?? getTranslated('no_description', context),
                textStyle: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                onTapUrl: (String url) {
                  return launchUrl(Uri.parse(url));
                },
              ),
            ),
          ),

          if( (productProvider.product?.description?.length ?? 0) > (ResponsiveHelper.isDesktop(context) ? 700 : 300) && showSeeMoreButton) Positioned.fill(child: Align(
            alignment: Alignment.bottomCenter, child: Container(
            decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
              Theme.of(context).cardColor.withValues(alpha: 0),
              Theme.of(context).cardColor,
            ])),
            width: Dimensions.webScreenWidth, height: 55,
          ),
          )),

          if((productProvider.product?.description?.length ?? 0) > (ResponsiveHelper.isDesktop(context) ? 700 : 300)) Positioned.fill(child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                alignment: Alignment.center,
                margin: showSeeMoreButton ? const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge) : null,
                height: 38, width: 100,
                child: InkWell(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                  onTap: ()=> onChangeButtonStatus(!showSeeMoreButton),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeExtraSmall, vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: const Alignment(0, 10),
                      colors: [
                        Theme.of(context).cardColor,
                        Theme.of(context).primaryColor,
                      ]), // Gradient fro,
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                    ),
                    child: Text(getTranslated(showSeeMoreButton ?  'see_more' : 'see_less', context), style: poppinsRegular),
                  ),
                )),
          )),


        ]) : Column(children: [

          if(ResponsiveHelper.isDesktop(context))
            SizedBox(height: Dimensions.paddingSizeLarge),

          Container(
            margin: EdgeInsets.all(Dimensions.paddingSizeSmall).copyWith(top: Dimensions.paddingSizeLarge),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
              boxShadow: [BoxShadow(
                offset: Offset(0, 1),
                blurRadius: 8,
                color: Colors.black.withValues(alpha: 0.08)
              )]
            ),
            width: 700,
            child: Column(children: [
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              Container(
                padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? 35 : Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                  color: Theme.of(context).hintColor.withValues(alpha: 0.05),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('${productProvider.product!.rating!.isNotEmpty
                        ? productProvider.product!.rating!.first.average!.toStringAsFixed(1) : 0.0}',
                        style: poppinsRegular.copyWith(
                          fontSize: ResponsiveHelper.isDesktop(context) ? 35 : Dimensions.fontSizeMaxLarge,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).primaryColor,
                        )),
                    //const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    RatingBarWidget(
                      rating: productProvider.product!.rating!.isNotEmpty
                          ? productProvider.product!.rating![0].average!
                          : 0.0, size: Dimensions.paddingSizeLarge,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Text(
                      '${productProvider.product!.activeReviews!.length} ${getTranslated('review', context)}',
                      style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.60)),
                    ),


                  ],),
              ),

              const SizedBox(height: Dimensions.paddingSizeSmall),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                child: RatingLineWidget(),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

            ]),
          ),

          if(ResponsiveHelper.isDesktop(context))
            SizedBox(height: Dimensions.fontSizeMaxLarge),

          PaginatedListWidget(
            scrollController: scrollController,
            offset: productProvider.productReviews?.offset,
            totalSize: productProvider.productReviews?.totalSize,
            limit: productProvider.productReviews?.limit,
            loaderBottomMargin: 70,
            onPaginate: (int? offset) async {
             await productProvider.getProductReviews(id: productProvider.product?.id.toString(), offset: offset);
            },
            itemView: ListView.builder(
              itemCount: productProvider.productReviews?.reviewList?.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              itemBuilder: (context, index) {
                return productProvider.productReviews?.reviewList != null ? ProductReviewWidget(
                  review: productProvider.productReviews?.reviewList![index],
                ) : const ReviewShimmer();
              },
            ),
          ),
        ]) ,
      ]);
    });
  }
}
