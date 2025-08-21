import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/widgets/custom_ink_well_widget.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';


class PreviewScreen extends StatefulWidget {
  final List<String> images;
  final int selectedIndex;
  const PreviewScreen({super.key, required this.images, required this.selectedIndex});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    _currentPage = widget.selectedIndex;
    _pageController =  PageController(initialPage: widget.selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: isDesktop ? Colors.transparent : Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
                controller: _pageController,
                onPageChanged: (i) async {
                  setState(() {
                    _currentPage = i;
                  });
                },
                itemCount: widget.images.length,
                itemBuilder: (context, index) {
                  String image = '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.reviewImageUrl}/${widget.images[index]}';
                  return  PhotoView(
                    backgroundDecoration: BoxDecoration(color: isDesktop ? Colors.transparent : Colors.black),
                    tightMode: true,
                    imageProvider: NetworkImage(kIsWeb ? '${AppConstants.baseUrl}/image-proxy?url=$image' : image),
                   // heroAttributes: PhotoViewHeroAttributes(tag: widget.images[index]),
                  );
                }),

            Positioned(top: isDesktop ? 0 : 10, right: 0, child: isDesktop ? InkWell(
              onTap: ()=> Navigator.pop(context),
              borderRadius: BorderRadius.circular(100),
              child: Container(
                  padding: EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ), child: Icon(Icons.clear, size: Dimensions.paddingSizeLarge),
              ),
            ) : IconButton(
              splashRadius: 5,
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.clear, color: Colors.white),
            )),

            if(_isPreviousPageExist())
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: isDesktop ? Colors.white : Colors.black),
                  ),
                  margin: EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                  child: CustomInkWellWidget(
                    onTap: _previousPage,
                    radius: 50,
                    padding: EdgeInsets.all(Dimensions.paddingSizeSmall).copyWith(left: Dimensions.paddingSizeDefault),
                    child: Icon(Icons.arrow_back_ios, color: isDesktop ? Colors.white : Colors.black),
                  ),
                ),
              ),

            if (_isNextPageExist())
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: isDesktop ? Colors.white : Colors.black),
                  ),
                  margin: EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                  child: CustomInkWellWidget(
                    onTap: _nextPage,
                    radius: 50,
                    padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Icon(Icons.arrow_forward_ios, color: isDesktop ? Colors.white : Colors.black),
                  ),
                ),
              ),

          ],
        ),
      ),
    );
  }

  bool _isNextPageExist() => _currentPage < widget.images.length - 1;

  bool _isPreviousPageExist() => _currentPage > 0;

  void _nextPage() {
    if (_isNextPageExist()) {
      _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _previousPage() {
    if (_isPreviousPageExist()) {
      _pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }
}
