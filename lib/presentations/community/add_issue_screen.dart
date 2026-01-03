import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dotted_border/dotted_border.dart';

import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';
import '../widgets/app_text_btn.dart';

class AddIssueScreen extends StatefulWidget {
  const AddIssueScreen({super.key});

  @override
  State<AddIssueScreen> createState() => _AddIssueScreenState();
}

class _AddIssueScreenState extends State<AddIssueScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;
  List<File> _imageFiles = [];

  final List<String> _categories = [
    'Garbage & Waste',
    'Road & Sidewalk Damage',
    'Trees & Vegetation',
    'Water & Utilities',
    'Safety & Security',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showPickerDialog() {
    // UI-only: do nothing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Issue'),
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
            // Title
            Text(
              "Title",
              style: regularStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: ColorManager.lighterBeige,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _titleController,
                style: regularStyle(fontSize: 14, color: Colors.black87),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Issue Title',
                  hintStyle: regularStyle(fontSize: 14, color: Colors.black38),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Category dropdown
            Text(
              "Category",
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
                  hint: Text('Select Category',
                      style: regularStyle(
                          fontSize: 16, color: Colors.grey.shade600)),
                  value: _selectedCategory,
                  isExpanded: true,
                  dropdownColor: ColorManager.lighterBeige,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: _categories
                      .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: regularStyle(
                          fontSize: 16, color: Colors.grey.shade600),
                    ),
                  ))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val),
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // Description
            Text(
              "Description",
              style: regularStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                  color: ColorManager.lighterBeige,
                  borderRadius: BorderRadius.circular(12)),
              child: TextField(
                controller: _descriptionController,
                maxLines: 5,
                maxLength: 200,
                style: regularStyle(fontSize: 14, color: Colors.black87),
                decoration: InputDecoration(
                  counterText: "",
                  border: InputBorder.none,
                  hintText: 'Describe the issue...',
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
                        style: regularStyle(
                            fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  )
                      : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _imageFiles.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _imageFiles.length) {
                        return GestureDetector(
                          onTap: _showPickerDialog,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                              border:
                              Border.all(color: Colors.brown.shade200),
                            ),
                            child: Center(
                              child: Icon(Icons.add_a_photo,
                                  color: Colors.brown.shade300),
                            ),
                          ),
                        );
                      }

                      final image = _imageFiles[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // Location placeholder
            Text(
              "Location",
              style: regularStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 60.h),

            // Submit Button
            AppTextBtn(
              buttonText: "Submit Issue",
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
