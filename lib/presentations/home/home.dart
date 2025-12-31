import 'package:app/presentations/home/rotating_banner.dart';
import 'package:flutter/material.dart';

import '../../routing/routes.dart';
import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0, // Hides the default AppBar
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome!',
                          style: semiBoldStyle(
                              fontSize: 25, color: Color(0xff2E2E2E))),
                      SizedBox(height: 4),
                      Text(
                        'Your report makes the difference',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),

                  ),
                ],
              ),
              SizedBox(height: 24),

              // Rotating Banner (Custom Widget)
              AutoImageRotator(),
              SizedBox(height: 24),

              // Add New Complaint Card
              _buildFeatureCard(
                icon: Icons.camera_alt_outlined,
                title: 'Add New Complaint',
                subtitle: 'Upload a photo of the issue easily',
                onTap: () {
                  Navigator.pushNamed(context, Routes.addComplaintScreen);
                  print('Add New Complaint tapped');
                },
              ),
              SizedBox(height: 16),

              // Track Your Complaint Card
              _buildFeatureCard(
                icon: Icons.access_time,
                title: 'Track Your Complaint',
                subtitle: 'Follow the status of your report step by step',
                onTap: () {
                  // Handle navigation to Track Your Complaint screen
                  print('Track Your Complaint tapped');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shadowColor: ColorManager.gray,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorManager.lightBrown, // Light brown background
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 50), // Brown icon
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style:
                            semiBoldStyle(fontSize: 18, color: Colors.black87)),
                    SizedBox(height: 4),
                    Text(subtitle,
                        style:
                            regularStyle(fontSize: 14, color: Colors.black38)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
