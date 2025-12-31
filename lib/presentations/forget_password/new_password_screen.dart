import 'package:app/presentations/forget_password/widgets/final_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../resources/styles_manager.dart';
import '../resources/value_manager.dart';
import '../widgets/app_text_btn.dart';
import '../widgets/app_text_field.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final passController = TextEditingController();
  final confirmPassController = TextEditingController();
  bool isObscure1 = true;
  bool isObscure2 = true;
  final _key = GlobalKey<FormState>();

  void _onUpdatePassword() {
    if (!_key.currentState!.validate()) {
      return;
    }
    showModalBottomSheet(
      context: context,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => FinalBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var children = [
                Center(child: Image.asset("assets/images/create_Password.png")),
                SizedBox(
                  height: 30.h,
                ),
                Text("Create New Password", style: theme.textTheme.titleLarge),
                SizedBox(
                  height: 10.h,
                ),
                Text(
                  "Enter and confirm your new",
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  "password to secure your account.",
                  style: theme.textTheme.bodyMedium,
                ),
                SizedBox(
                  height: 10.h,
                ),
                AppTextField(
                  controller: passController,
                  hintText: "Password",
                  isPassword: true,
                  obscureText: isObscure1,
                  prefixIcon: Icons.lock_outline,
                  onToggleObscure: () {
                    setState(() {
                      isObscure1 = !isObscure1;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your password";
                    }
                    return null;
                  },
                ),
                AppTextField(
                  controller: confirmPassController,
                  hintText: "Confirm Password",
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  obscureText: isObscure2,
                  onToggleObscure: () {
                    setState(() {
                      isObscure2 = !isObscure2;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please confirm your password";
                    } else if (value != passController.text) {
                      return "Passwords do not match";
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
                  onPressed: _onUpdatePassword,
                )
              ];
    return Scaffold(
      appBar: AppBar(
        title: Text("Set New Password"),
      ),
      body: Padding(
        padding: EdgeInsets.all(AppPadding.p16),
        child: SingleChildScrollView(
          child: Form(
            key: _key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
