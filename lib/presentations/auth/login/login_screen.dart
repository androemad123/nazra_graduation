import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';


import '../../../app/provider/theme_provider.dart';
import '../../../generated/l10n.dart';
import '../../../routing/routes.dart';
import '../../resources/color_manager.dart';
import '../../resources/styles_manager.dart';
import '../../resources/value_manager.dart';
import '../../widgets/app_text_btn.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/divider_with_text.dart';
import '../../widgets/social_auth_btn.dart';

// Bloc imports

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool rememberMe = false;

  void _onLoginPressed(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      // context.read<AuthBloc>().add(
      //   AuthLoginRequested(
      //     email: _emailCtrl.text.trim(),
      //     password: _passwordCtrl.text.trim(),
      //   ),
      // );
            Navigator.pushReplacementNamed(context, Routes.homeScreenState);

    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

        return Scaffold(
          body: Stack(
            children: [
              Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: themeProvider.isDarkMode
                        ? [
                      Theme.of(context).colorScheme.surface,
                      Theme.of(context).colorScheme.secondary,
                      Theme.of(context).colorScheme.surface,
                    ]
                        : [
                      Theme.of(context).colorScheme.surface,
                      Theme.of(context).colorScheme.background,
                      Theme.of(context).colorScheme.surface,
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: true,
                minimum: EdgeInsets.only(top: 70.h),
                child: Padding(
                  padding: EdgeInsets.all(AppPadding.p18),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                ColorManager.brown,
                                ColorManager.brown,
                                ColorManager.cream,
                              ],
                            ).createShader(bounds),
                            child: Text(
                              S.of(context).welcome,
                              style: semiBoldStyle(
                                fontSize: 40.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            S.of(context).back,
                            style: semiBoldStyle(
                                fontSize: 40.sp, color: Colors.black),
                          ),
                          SizedBox(height: 20.h),

                          // Email field
                          AppTextField(
                            hintText: S.of(context).emailHint,
                            isPassword: false,
                            controller: _emailCtrl,
                            prefixIcon: Icons.email_outlined,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return S.of(context).pleaseFillAllFields;
                              }
                              if (!val.contains('@')) {
                                return 'Invalid email';
                              }
                              return null;
                            },
                          ),

                          // Password field
                          AppTextField(
                            hintText: S.of(context).passwordHint,
                            isPassword: true ,
                            controller: _passwordCtrl,
                            prefixIcon: Icons.lock_outline,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return S.of(context).pleaseFillAllFields;
                              }
                              return null;
                            },
                          ),

                          Row(
                            children: [
                              Checkbox(
                                value: rememberMe,
                                onChanged: (val) =>
                                    setState(() => rememberMe = val ?? false),
                              ),
                              Text(
                                S.of(context).rememberMe,
                                style: regularStyle(
                                  fontSize: 14.sp,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color ??
                                      Colors.black,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushNamed('/forgetPasswordRoute');
                                },
                                child: Text(S.of(context).forgotPassword,
                                    style: regularStyle(
                                      fontSize: 14.sp,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color ??
                                          Colors.black,
                                    )),
                              ),
                            ],
                          ),
                          SizedBox(height: 30.h),

                          // Login button
                          AppTextBtn(
                            buttonText:   S.of(context).login,
                            textStyle: semiBoldStyle(
                              fontSize: 18.sp,
                              color: Colors.white,
                            ),
                            onPressed:
                                 () => _onLoginPressed(context),
                          ),
                          SizedBox(height: 30.h),

                          DividerWithText(
                            text: S.of(context).orContinueWith,
                            lineColor: Colors.grey.shade400,
                            textStyle: regularStyle(
                              fontSize: 14.sp,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color ??
                                  Colors.black,
                            ),
                          ),
                          SizedBox(height: 30.h),

                          // Social buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SocialAuthBtn(
                                assetPath: 'assets/images/google.jpg',
                                onTap: () {},
                              ),
                              SizedBox(width: 25.w),
                              SocialAuthBtn(
                                assetPath: 'assets/images/facebook.jpg',
                                onTap: () {},
                              ),
                              SizedBox(width: 25.w),
                              SocialAuthBtn(
                                assetPath: 'assets/images/apple.jpg',
                                onTap: () {},
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),

                          Center(
                            child: RichText(
                              text: TextSpan(
                                text: S.of(context).dontHaveAccount,
                                style: regularStyle(
                                  fontSize: 16.sp,
                                  color: Colors.black54,
                                ),
                                children: [
                                  TextSpan(
                                    text: S.of(context).signupButton,
                                    style: semiBoldStyle(
                                      fontSize: 16.sp,
                                      color: ColorManager.brown,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => Navigator.of(context)
                                          .pushNamed(Routes.signUpRoute),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Loading overlay
            ],

        )

    );
  }
}
