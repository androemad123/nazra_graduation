import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../routing/routes.dart';
import '../resources/styles_manager.dart';
import '../resources/value_manager.dart';
import '../widgets/app_text_btn.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _keys = List.generate(6, (_) => GlobalKey<FormState>());
  void _onVerifyCode() {
    if (!_keys[0].currentState!.validate() ||
        !_keys[1].currentState!.validate() ||
        !_keys[2].currentState!.validate() ||
        !_keys[3].currentState!.validate() ||
        !_keys[4].currentState!.validate() ||
        !_keys[5].currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text("Please enter the complete code"),
          actions: [
            TextButton(
              onPressed: () {
                for (var key in _keys) {
                  key.currentState!.reset();
                }
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.pushNamed(context, Routes.newPasswordRoute);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
          title: Text(
        "Enter OTP Code",
        style: theme.textTheme.titleLarge,
      )),
      body: Padding(
        padding: EdgeInsets.all(AppPadding.p16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                  child: Image.asset(
                'assets/images/enter_OTB.png',
              )),
              SizedBox(
                height: 30.h,
              ),
              Text("Check Your Email", style: theme.textTheme.titleLarge),
              SizedBox(
                height: 10.h,
              ),
              Text(
                "We have sent the code to your email",
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                "Please enter it below to verify your identity.",
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(
                height: 30.h,
              ),
              ListTile(
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _codeContainer(context, _controllers[0], _keys[0]),
                    _codeContainer(context, _controllers[1], _keys[1]),
                    _codeContainer(context, _controllers[2], _keys[2]),
                    _codeContainer(context, _controllers[3], _keys[3]),
                    _codeContainer(context, _controllers[4], _keys[4]),
                    _codeContainer(context, _controllers[5], _keys[5]),
                  ],
                ),
              ),
              SizedBox(
                height: 50.h,
              ),
              AppTextBtn(
                buttonText: "Verify Code",
                textStyle: semiBoldStyle(fontSize: 18, color: Colors.white),
                onPressed: _onVerifyCode,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _codeContainer(
    BuildContext context,
    TextEditingController controller,
    GlobalKey<FormState> key,
  ) {
    return Form(
      key: key,
      child: Container(
        height: 60.h,
        width: 40.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.onSecondary,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppPadding.p8),
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                  label: Padding(
                    padding: EdgeInsets.only(top: AppPadding.p8),
                    child: Center(child: Text('*')),
                  ),
                  labelStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 28.sp),
                  floatingLabelBehavior: FloatingLabelBehavior.never),
              onChanged: (value) {
                if (value.length == 1) {
                  FocusScope.of(context).nextFocus();
                } else if (value.isEmpty) {
                  FocusScope.of(context).previousFocus();
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "";
                }
                return null;
              },
            ),
          ),
        ),
      ),
    );
  }
}
