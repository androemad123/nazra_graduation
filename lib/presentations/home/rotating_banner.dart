import 'dart:async';
import 'package:flutter/material.dart';

class AutoImageRotator extends StatefulWidget {
  const AutoImageRotator({super.key});

  @override
  State<AutoImageRotator> createState() => _AutoImageRotatorState();
}

class _AutoImageRotatorState extends State<AutoImageRotator> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  late Timer _timer;

  final List<String> _images = [
    'assets/images/banner.png',
    'assets/images/banner.png',
    'assets/images/banner.png',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_pageController.hasClients) {
        _currentIndex = (_currentIndex + 1) % _images.length;
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: PageView.builder(
          controller: _pageController,
          itemCount: _images.length,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          itemBuilder: (context, index) {
            return Image.asset(
              _images[index],
              fit: BoxFit.fitWidth,
              width: double.infinity,
            );
          },
        ),
      ),
    );
  }
}
