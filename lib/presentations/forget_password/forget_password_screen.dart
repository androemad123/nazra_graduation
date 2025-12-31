import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../routing/routes.dart';
import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';
import '../resources/value_manager.dart';
import '../widgets/app_text_btn.dart';
import '../widgets/app_text_field.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  TextEditingController textEditingController = TextEditingController();
  final _key = GlobalKey<FormState>();
  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }
  void _onSendCode() {
    if (!_key.currentState!.validate()) {
      return;
    }
    Navigator.pushNamed(
      context,
      Routes.otpScreenRoute,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Forget Password",
          style: theme.textTheme.titleLarge,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(AppPadding.p16),
        child: SingleChildScrollView(
          child: Form(
            key: _key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset("assets/images/confirm_mail.png"),
                SizedBox(
                  height: 50,
                ),
                Text(
                  "Enter your Email",
                  style: semiBoldStyle(fontSize: 24, color: Colors.black),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Enter your email address to receive a reset code.",
                  style: regularStyle(fontSize: 12, color: ColorManager.gray),
                ),
                SizedBox(
                  height: 35,
                ),
                AppTextField(
                  controller: textEditingController,
                  hintText: "Email",
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your email";
                    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return "Please enter a valid email";
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 20.h,
                ),
                AppTextBtn(
                  buttonText: "Send Code",
                  textStyle: semiBoldStyle(fontSize: 18, color: Colors.white),
                  onPressed: _onSendCode,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
