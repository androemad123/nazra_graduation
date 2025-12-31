import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../routing/routes.dart';
import '../../resources/styles_manager.dart';
import '../../widgets/app_text_btn.dart';

class FinalBottomSheet extends StatelessWidget {
  const FinalBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.h),
      height: 650.h,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Center(child: Image.asset("assets/images/yay.png")),
          SizedBox(height: 20.h),
          Text(
            "Yey! Password Updated",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          //You will be moved to login screen right now. Enjoy the features!
          SizedBox(
            height: 10.h,
          ),
          Text(
            "You will be moved to login screen right now.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            'Enjoy the features!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(
            height: 10.h,
          ),
          AppTextBtn(
            buttonText: "Login",
            textStyle: semiBoldStyle(fontSize: 18, color: Colors.white),
            verticalPadding: 10.h,
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.loginRoute,
                (route) => true,
              );
            },
          )
        ],
      ),
    );
  }
}
