import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/services/image_picker_service.dart';
import '../../app/services/cloudinary_service.dart';
import '../../app/services/ml_api_service.dart';
import '../../app/repositories/complaint_repository.dart';
import '../../app/bloc/location_bloc/location_bloc.dart';
import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';
import '../widgets/app_text_btn.dart';
import 'map_sample.dart';

class AddComplaintScreen extends StatefulWidget {
  const AddComplaintScreen({super.key});

  @override
  State<AddComplaintScreen> createState() => _AddComplaintScreenState();
}

class _AddComplaintScreenState extends State<AddComplaintScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedProblemType;

  List<File> _imageFiles = [];
  final ImagePickerService _imageService = ImagePickerService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final MlApiService _mlApiService = MlApiService();
  final ComplaintRepository _complaintRepository = ComplaintRepository();

  bool _isSubmitting = false;

  final List<String> problemTypes = [
    'Pothole',
    'Street Light Out',
    'Traffic Light Malfunction',
    'Garbage Overflow',
    'Water Leak',
    'Exposed Wires',
    'Dangerous Structure',
    'Stray Animals',
    'Dead Tree',
    'Homeless',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationBloc = context.read<LocationBloc>();
      if (locationBloc.state is LocationInitial) {
        locationBloc.add(FetchLocation());
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // ── Image picker ───────────────────────────────────────────────────────────

  void _showPickerDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  final image = await _imageService.pickFromGallery();
                  if (image != null) setState(() => _imageFiles.add(image));
                  if (mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  final image = await _imageService.pickFromCamera();
                  if (image != null) setState(() => _imageFiles.add(image));
                  if (mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Validation snack bar ───────────────────────────────────────────────────

  void _showValidationSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _handleSubmit() async {
    if (_selectedProblemType == null || _selectedProblemType!.isEmpty) {
      _showValidationSnackBar('Please select a problem type');
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      _showValidationSnackBar('Please enter a description');
      return;
    }
    if (_imageFiles.isEmpty) {
      _showValidationSnackBar('Please add at least one photo');
      return;
    }

    final locationBloc = context.read<LocationBloc>();
    final locationState = locationBloc.state;
    if (locationState is! LocationLoaded) {
      locationBloc.add(FetchLocation());
      _showValidationSnackBar('Please wait for location to load');
      return;
    }

    setState(() => _isSubmitting = true);

    // Show the animated progress sheet – it owns the entire upload lifecycle.
    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _UploadProgressSheet(
        imageFiles: List.unmodifiable(_imageFiles),
        cloudinaryService: _cloudinaryService,
        mlApiService: _mlApiService,
        complaintRepository: _complaintRepository,
        description: _descriptionController.text.trim(),
        category: _selectedProblemType!,
        position: locationState.position,
        address: locationState.address,
        onSuccess: () {
          if (mounted) Navigator.of(context).pop();
        },
      ),
    );

    if (mounted) setState(() => _isSubmitting = false);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

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
            // ── Problem type ──────────────────────────────────────────────
            Text('Type of problem',
                style: regularStyle(fontSize: 16, color: Colors.black87)),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: ColorManager.lighterBeige,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: Text('Select the type of problem',
                      style: regularStyle(
                          fontSize: 16, color: Colors.grey.shade600)),
                  value: _selectedProblemType,
                  isExpanded: true,
                  dropdownColor: ColorManager.lighterBeige,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: problemTypes
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e,
                                style: regularStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600)),
                          ))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _selectedProblemType = val),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // ── Description ───────────────────────────────────────────────
            Text('Problem description',
                style: regularStyle(fontSize: 16, color: Colors.black87)),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: ColorManager.lighterBeige,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                controller: _descriptionController,
                maxLines: 5,
                maxLength: 200,
                style: regularStyle(fontSize: 14, color: Colors.black87),
                decoration: InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  hintText: 'Write a description of the problem...',
                  hintStyle:
                      regularStyle(fontSize: 14, color: Colors.black38),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // ── Photos ────────────────────────────────────────────────────
            Text('Add photos',
                style: regularStyle(fontSize: 16, color: Colors.black87)),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: _showPickerDialog,
              child: DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  radius: const Radius.circular(12),
                  color: Colors.black12,
                  dashPattern: const [10, 5],
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
                            Icon(Icons.camera_alt_rounded,
                                size: 40.sp,
                                color: Colors.brown.shade300),
                            SizedBox(height: 8.h),
                            Text('Click to add images',
                                style: regularStyle(
                                    fontSize: 14, color: Colors.black87)),
                            Text(
                              'Attaching photos helps resolve the issue faster.',
                              style: regularStyle(
                                  fontSize: 12, color: Colors.black38),
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
                                    border: Border.all(
                                        color: Colors.brown.shade200),
                                  ),
                                  child: Center(
                                    child: Icon(Icons.add_a_photo,
                                        color: Colors.brown.shade300),
                                  ),
                                ),
                              );
                            }
                            final image = _imageFiles[index];
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(image,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity),
                                ),
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: GestureDetector(
                                    onTap: () => setState(
                                        () => _imageFiles.removeAt(index)),
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

            // ── Location ──────────────────────────────────────────────────
            Text('Location',
                style: regularStyle(fontSize: 16, color: Colors.black87)),
            SizedBox(height: 20.h),
            const MapSample(),
            SizedBox(height: 20.h),

            // ── Submit ────────────────────────────────────────────────────
            AppTextBtn(
              buttonText: _isSubmitting ? 'Submitting…' : 'Submit',
              textStyle: semiBoldStyle(fontSize: 16, color: Colors.white),
              onPressed: _isSubmitting ? (){} : _handleSubmit,
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Animated upload-progress bottom sheet
// ============================================================================

enum _Step { uploading, analyzing, saving, done, error }

class _UploadProgressSheet extends StatefulWidget {
  final List<File> imageFiles;
  final CloudinaryService cloudinaryService;
  final MlApiService mlApiService;
  final ComplaintRepository complaintRepository;
  final String description;
  final String category;
  final dynamic position; // geolocator Position
  final String? address;
  final VoidCallback onSuccess;

  const _UploadProgressSheet({
    required this.imageFiles,
    required this.cloudinaryService,
    required this.mlApiService,
    required this.complaintRepository,
    required this.description,
    required this.category,
    required this.position,
    this.address,
    required this.onSuccess,
  });

  @override
  State<_UploadProgressSheet> createState() => _UploadProgressSheetState();
}

class _UploadProgressSheetState extends State<_UploadProgressSheet>
    with TickerProviderStateMixin {
  _Step _step = _Step.uploading;
  String? _errorMessage;

  late final AnimationController _pulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final AnimationController _checkCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  late final Animation<double> _checkScale =
      CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut);

  static const _labels = [
    'Uploading photos',
    'Analysing with AI',
    'Saving complaint',
  ];
  static const _icons = [
    Icons.cloud_upload_outlined,
    Icons.psychology_outlined,
    Icons.save_outlined,
  ];
  static const _accent = Color(0xFF6D4C41);
  static const _green = Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _checkCtrl.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    try {
      // ── 1. Upload images ────────────────────────────────────────────────
      _set(_Step.uploading);
      final imageUrls = await widget.cloudinaryService.uploadImages(
        imageFiles: widget.imageFiles,
        description: widget.description,
        category: widget.category,
      );
      if (imageUrls.isEmpty) {
        throw Exception('Failed to upload images. Please try again.');
      }

      // ── 2. ML analysis ──────────────────────────────────────────────────
      _set(_Step.analyzing);
      final mlResult = await widget.mlApiService.analyzeImages(
        imageUrls: imageUrls,
        description: widget.description,
        category: widget.category,
      );

      Map<String, dynamic>? normalizedMl;
      if (mlResult != null) {
        final aiData = mlResult['data'];
        normalizedMl = {
          'is_issue': mlResult['is_issue'] ?? true,
          'data': aiData is Map<String, dynamic>
              ? Map<String, dynamic>.from(aiData)
              : <String, dynamic>{},
        };
      }

      // ── 3. Save to Firestore ─────────────────────────────────────────────
      _set(_Step.saving);
      final complaintId = await widget.complaintRepository.addComplaint(
        imageUrls: imageUrls,
        description: widget.description,
        category: widget.category,
        location: widget.position,
        address: widget.address!,
        mlAnalysisResult: normalizedMl,
      );

      if (complaintId == null) {
        throw Exception('Failed to save complaint. Please try again.');
      }

      // ── Done ─────────────────────────────────────────────────────────────
      _set(_Step.done);
      await _checkCtrl.forward();
      await Future.delayed(const Duration(milliseconds: 1000));

      if (mounted) {
        Navigator.of(context).pop(); // close sheet
        widget.onSuccess();          // pop AddComplaintScreen
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _step = _Step.error;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  void _set(_Step s) {
    if (mounted) setState(() => _step = s);
  }

  int get _activeIdx {
    switch (_step) {
      case _Step.uploading: return 0;
      case _Step.analyzing: return 1;
      case _Step.saving:    return 2;
      case _Step.done:      return 3;
      case _Step.error:     return -1;
    }
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isErr  = _step == _Step.error;
    final isDone = _step == _Step.done;

    return PopScope(
      canPop: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(28.w, 20.h, 28.w, 40.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle (decorative only)
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 30.h),

            // Hero icon area
            _heroIcon(isDone, isErr),
            SizedBox(height: 22.h),

            // Title
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                isDone
                    ? 'Complaint Submitted! 🎉'
                    : isErr
                        ? 'Something went wrong'
                        : 'Submitting your complaint…',
                key: ValueKey(_step),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: isDone
                      ? _green
                      : isErr
                          ? Colors.red.shade700
                          : Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 6.h),

            // Sub-text / steps
            if (isErr) ...[
              SizedBox(height: 8.h),
              Text(
                _errorMessage ?? 'An unexpected error occurred.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.sp, color: Colors.black54),
              ),
              SizedBox(height: 28.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ] else if (isDone) ...[
              Text(
                'Your complaint has been recorded and will be reviewed shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.sp, color: Colors.black45),
              ),
            ] else ...[
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  _labels[_activeIdx.clamp(0, 2)],
                  key: ValueKey(_activeIdx),
                  style: TextStyle(fontSize: 14.sp, color: Colors.black45),
                ),
              ),
              SizedBox(height: 32.h),
              _stepRow(),
            ],

            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Widget _heroIcon(bool isDone, bool isErr) {
    if (isDone) {
      return ScaleTransition(
        scale: _checkScale,
        child: Container(
          width: 72.w,
          height: 72.w,
          decoration: BoxDecoration(
            color: _green.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_circle_rounded,
              size: 48.sp, color: _green),
        ),
      );
    }

    if (isErr) {
      return Container(
        width: 72.w,
        height: 72.w,
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.error_outline_rounded,
            size: 48.sp, color: Colors.red.shade600),
      );
    }

    // Pulsing background + spinner
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, child) => Container(
        width: 72.w,
        height: 72.w,
        decoration: BoxDecoration(
          color: Colors.brown.shade50
              .withOpacity(0.55 + 0.45 * _pulseCtrl.value),
          shape: BoxShape.circle,
        ),
        child: child,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.brown.shade400),
        ),
      ),
    );
  }

  Widget _stepRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_labels.length, (i) {
        final done   = _activeIdx > i;
        final active = _activeIdx == i;

        final fg = done || active ? Colors.white : Colors.black26;
        final bg = done
            ? _green
            : active
                ? _accent
                : Colors.black12;

        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(_icons[i], color: fg, size: 22.sp),
            ),
            if (i < _labels.length - 1)
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                width: 38.w,
                height: 3.h,
                color: done ? _green : Colors.black12,
              ),
          ],
        );
      }),
    );
  }
}
