import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:io';
import 'dart:math' as math;

import '../dashboard/dashboard_screen.dart';

// User Verification Screen
class UserVerificationScreen extends StatefulWidget {
  @override
  _UserVerificationScreenState createState() => _UserVerificationScreenState();
}

class _UserVerificationScreenState extends State<UserVerificationScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  int _currentStep = 0;
  List<File> _uploadedImages = [];
  bool _isVerifying = false;
  bool _verificationComplete = false;

  // Camera variables
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;
  File? _capturedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFFee403a)),
          onPressed: () => Navigator.pop(context),
        ),
        title: LinearProgressIndicator(
          value: (_currentStep + 1) / 2,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFee403a)),
        ),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentStep = index),
        children: [
          _buildImageUploadStep(),
          _buildFaceVerificationStep(),
        ],
      ),
    );
  }

  Widget _buildImageUploadStep() {
    return Padding(
      padding: EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step 1 of 2',
            style: TextStyle(
              color: Color(0xFFee403a),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Upload Your Photos',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Add at least 2 photos to verify your identity',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 40),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.8,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                final hasImage = index < _uploadedImages.length;
                return _buildImageUploadCard(index, hasImage);
              },
            ),
          ),
          SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _uploadedImages.length >= 2 ? _nextToFaceVerification : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFee403a),
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
              ),
              child: Text(
                'Continue to Face Verification',
                style: TextStyle(
                  color: _uploadedImages.length >= 2 ? Colors.white : Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadCard(int index, bool hasImage) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: hasImage ? Color(0xFFee403a) : Colors.grey[300]!,
                width: 2,
              ),
              color: hasImage ? Color(0xFFee403a).withOpacity(0.1) : Colors.grey[50],
              boxShadow: hasImage ? [
                BoxShadow(
                  color: Color(0xFFee403a).withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                )
              ] : [],
            ),
            child: InkWell(
              onTap: () => _pickImage(index),
              borderRadius: BorderRadius.circular(18),
              child: hasImage
                  ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: Image.file(
                        _uploadedImages[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(0xFFee403a).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Color(0xFFee403a),
                      size: 30,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    index == 0 ? 'Main Photo' : 'Photo ${index + 1}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  if (index < 2)
                    Text(
                      'Required',
                      style: TextStyle(
                        color: Color(0xFFee403a),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFaceVerificationStep() {
    return Padding(
      padding: EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step 2 of 2',
            style: TextStyle(
              color: Color(0xFFee403a),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Face Verification',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Look at the camera and hold still for verification',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 60),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isVerifying ? _pulseAnimation.value : 1.0,
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _verificationComplete
                                  ? Colors.green
                                  : _isVerifying
                                  ? Color(0xFFee403a)
                                  : Colors.grey[300]!,
                              width: 4,
                            ),
                            color: Colors.grey[50],
                            boxShadow: _isVerifying || _verificationComplete ? [
                              BoxShadow(
                                color: (_verificationComplete ? Colors.green : Color(0xFFee403a))
                                    .withOpacity(0.3),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              )
                            ] : [],
                          ),
                          child: _verificationComplete
                              ? Icon(
                            Icons.check_circle,
                            size: 80,
                            color: Colors.green,
                          )
                              : Icon(
                            Icons.person,
                            size: 80,
                            color: _isVerifying ? Color(0xFFee403a) : Colors.grey[400],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 40),
                  Text(
                    _verificationComplete
                        ? 'Verification Complete!'
                        : _isVerifying
                        ? 'Verifying... Hold still'
                        : 'Position your face in the circle',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _verificationComplete
                          ? Colors.green
                          : _isVerifying
                          ? Color(0xFFee403a)
                          : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_isVerifying) ...[
                    SizedBox(height: 20),
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFee403a)),
                    ),
                  ],
                  if (_verificationComplete) ...[
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Text(
                        '✓ Identity verified successfully',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _verificationComplete
                  ? _completeVerification
                  : _isVerifying
                  ? null
                  : _startFaceVerification,
              style: ElevatedButton.styleFrom(
                backgroundColor: _verificationComplete ? Colors.green : Color(0xFFee403a),
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
              ),
              child: Text(
                _verificationComplete
                    ? 'Continue to Dashboard'
                    : _isVerifying
                    ? 'Verifying...'
                    : 'Start Verification',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _pickImage(int index) async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFee403a),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImageFromSource(ImageSource.camera, index);
                    },
                    icon: Icon(Icons.camera_alt, color: Colors.white),
                    label: Text('Camera', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFee403a),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImageFromSource(ImageSource.gallery, index);
                    },
                    icon: Icon(Icons.photo_library, color: Colors.white),
                    label: Text('Gallery', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFf86f54),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPermissionDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.security, color: Color(0xFFee403a)),
            SizedBox(width: 10),
            Text('Permission Required'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFee403a),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Settings', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _pickImageFromSource(ImageSource source, int index) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          if (index < _uploadedImages.length) {
            _uploadedImages[index] = File(image.path);
          } else {
            _uploadedImages.add(File(image.path));
          }
        });

        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo ${index + 1} uploaded successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      if (index < _uploadedImages.length) {
        _uploadedImages.removeAt(index);
      }
    });

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Photo removed'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _nextToFaceVerification() {
    _pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _startFaceVerification() async {
    setState(() => _isVerifying = true);

    // Simulate face verification process (5 seconds)
    await Future.delayed(Duration(seconds: 5));

    setState(() {
      _isVerifying = false;
      _verificationComplete = true;
    });

    HapticFeedback.heavyImpact();
  }

  void _completeVerification() {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Account verified successfully! Welcome to Pickle! 🎉'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: Duration(seconds: 2),
      ),
    );


    // Navigate to dashboard (placeholder for now)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DashboardScreen()),
    );
  }
}