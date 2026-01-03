import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dotted_border/dotted_border.dart';

import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';
import '../widgets/app_text_btn.dart';

class AddComplaintScreen extends StatefulWidget {
  const AddComplaintScreen({super.key});

  @override
  State<AddComplaintScreen> createState() => _AddComplaintScreenState();
}

class _AddComplaintScreenState extends State<AddComplaintScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedProblemType;
  List<File> _imageFiles = [];

  final List<String> problemTypes = [
    "Pothole",
    "Street Light Out",
    "Traffic Light Malfunction",
    "Garbage Overflow",
    "Water Leak",
    "Exposed Wires",
    "Dangerous Structure",
    "Stray Animals",
    "Dead Tree",
    "Homeless",
    "Other",
  ];

  void _showPickerDialog() {
    // UI-only: do nothing for now
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a complaint'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Problem type dropdown
            Text(
              "Type of problem",
              style: regularStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: ColorManager.lighterBeige,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: Text(
                    'Select the type of problem',
                    style: regularStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  value: _selectedProblemType,
                  isExpanded: true,
                  dropdownColor: ColorManager.lighterBeige,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: problemTypes
                      .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: regularStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                  ))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedProblemType = val),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Description
            Text(
              "Problem description",
              style: regularStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                  color: ColorManager.lighterBeige,
                  borderRadius: BorderRadius.circular(12)),
              child: TextField(
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                controller: _descriptionController,
                maxLines: 5,
                maxLength: 200,
                style: regularStyle(fontSize: 14, color: Colors.black87),
                decoration: InputDecoration(
                  counterText: "",
                  border: InputBorder.none,
                  hintText: 'Write a description of the problem...',
                  hintStyle: regularStyle(fontSize: 14, color: Colors.black38),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Add Photo
            Text(
              "Add photos",
              style: regularStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: _showPickerDialog,
              child: DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  radius: Radius.circular(12),
                  color: Colors.black12,
                  dashPattern: [10, 5],
                  strokeWidth: 2,
                  padding: EdgeInsets.zero,
                ),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF8F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.all(12.w),
                  child: _imageFiles.isEmpty
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_rounded,
                        size: 40.sp,
                        color: Colors.brown.shade300,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Click to add images",
                        style: regularStyle(fontSize: 14, color: Colors.black87),
                      ),
                      Text(
                        "Attaching photos helps resolve the issue faster.",
                        style: regularStyle(fontSize: 12, color: Colors.black38),
                      ),
                    ],
                  )
                      : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _imageFiles.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _imageFiles.length) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.brown.shade200),
                          ),
                          child: const Center(
                            child: Icon(Icons.add_a_photo),
                          ),
                        );
                      }
                      final image = _imageFiles[index];
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: GestureDetector(
                              onTap: () => setState(() => _imageFiles.removeAt(index)),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Location
            Text(
              "Location",
              style: regularStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 20.h),
            SizedBox(height: 20.h),

            // Submit Button
            AppTextBtn(
              buttonText: "Submit",
              textStyle: semiBoldStyle(fontSize: 16, color: Colors.white),
              onPressed: () {}, // UI-only
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
