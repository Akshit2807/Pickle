import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
// Geolocator and Geocoding are not used in this screen based on current logic,
// but I'll leave them if they are planned for other parts of this file.
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
import 'dart:io';
// import 'dart:math' as math; // Not currently used

import '../dashboard/dashboard_screen.dart';

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

  final ImagePicker _picker = ImagePicker();

  // Camera variables
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  List<CameraDescription>? _cameras;
  final ValueNotifier<String> _capturedImagePath = ValueNotifier<String>("");

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 700), // Adjusted duration for a smoother pulse
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate( // Subtle pulse
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    // Pulse will be started when _isVerifying is true without a captured image.

    _capturedImagePath.value = "";
    // Initialize camera when the widget is created,
    // it will be ready when the user reaches the second page.
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (!status.isGranted) {
        if (mounted) {
          _showPermissionDialog('Camera permission is required for face verification.');
        }
        return;
      }
    }

    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No camera found on this device.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high, // Use high for better quality capture
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg, // Explicitly set format
      );

      _initializeControllerFuture = _cameraController!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {}); // Update UI once camera is initialized
      }).catchError((Object e) {
        if (mounted) {
          if (e is CameraException) {
            switch (e.code) {
              case 'CameraAccessDenied':
                _showPermissionDialog('Camera access was denied. Please enable it in settings.');
                break;
              case 'CameraAccessDeniedWithoutPrompt':
                 _showPermissionDialog('Camera access was denied. Please enable it in settings.');
                break;
              default:
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error initializing camera: ${e.description}'),
                    backgroundColor: Colors.red,
                  ),
                );
                break;
            }
          } else {
             ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('An unknown error occurred with the camera.'),
                    backgroundColor: Colors.red,
                  ),
                );
          }
        }
      });
    } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not retrieve available cameras.'),
              backgroundColor: Colors.red,
            ),
          );
       }
    }
     if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    _cameraController?.dispose();
    _capturedImagePath.dispose();
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
          onPressed: () {
            if (_currentStep == 1 && (_isVerifying || _verificationComplete)) {
              // If on face verification step and process started, allow going back to reset
              _resetFaceVerificationState();
              _pageController.previousPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else if (_currentStep == 0) {
              Navigator.pop(context);
            } else {
               _pageController.previousPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          },
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
        onPageChanged: (index) {
          setState(() => _currentStep = index);
          if (index == 1 && (_cameraController == null || !_cameraController!.value.isInitialized)) {
            // If navigating to face verification and camera isn't ready, try initializing again.
             _initializeCamera();
          } else if (index == 0) {
            // If navigating back to image upload, ensure face verification state is reset.
            _resetFaceVerificationState();
          }
        },
        children: [
          _buildImageUploadStep(),
          _buildFaceVerificationStep(),
        ],
      ),
    );
  }
 void _resetFaceVerificationState() {
    setState(() {
      _isVerifying = false;
      _verificationComplete = false;
      _capturedImagePath.value = "";
       _pulseController.stop();
       _pulseController.reset();
    });
    // Re-initialize camera if it was disposed or needs resetting
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _initializeCamera();
    } else if (_cameraController != null && !_cameraController!.value.isStreamingImages && !_cameraController!.value.isTakingPicture) {
      // If controller exists but not streaming (e.g., after stopImageStream), re-initialize or re-start stream if needed.
      // For simplicity here, we re-initialize.
      _cameraController?.dispose().then((_) {
         _initializeCamera();
      });
    }
  }
  Widget _buildImageUploadStep() {
    // ... (Your existing _buildImageUploadStep code - no changes needed here from snippet)
    // For brevity, assuming this part remains the same as your provided code
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
              itemCount: 4, // Assuming max 4 photos
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
    // ... (Your existing _buildImageUploadCard code)
    // For brevity, assuming this part remains the same as your provided code
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
                  if (index < 2) // Assuming first 2 photos are required
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
                        scale: (_isVerifying && _capturedImagePath.value.isEmpty) ? _pulseAnimation.value : 1.0,
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _verificationComplete
                                  ? Colors.green
                                  : (_isVerifying || _capturedImagePath.value.isNotEmpty)
                                  ? Color(0xFFee403a)
                                  : Colors.grey[300]!,
                              width: 4,
                            ),
                            color: Colors.grey[50],
                            boxShadow: (_isVerifying || _verificationComplete || _capturedImagePath.value.isNotEmpty) ? [
                              BoxShadow(
                                color: (_verificationComplete ? Colors.green : Color(0xFFee403a))
                                    .withOpacity(0.3),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              )
                            ] : [],
                          ),
                          child: ValueListenableBuilder<String>(
                            valueListenable: _capturedImagePath,
                            builder: (context, imagePath, child) {
                              return FutureBuilder<void>(
                                future: _initializeControllerFuture,
                                builder: (context, snapshot) {
                                  if (_verificationComplete) {
                                    return Icon(Icons.check_circle, size: 80, color: Colors.green);
                                  }
                                  if (imagePath.isNotEmpty) {
                                    return ClipOval(child: Image.file(File(imagePath), fit: BoxFit.cover, width: 250, height: 250));
                                  }
                                  if (snapshot.connectionState == ConnectionState.done &&
                                      _cameraController != null &&
                                      _cameraController!.value.isInitialized) {
                                    return ClipOval(child: CameraPreview(_cameraController!));
                                  }
                                  return Icon(Icons.person_outline, size: 80, color: Colors.grey[400]);
                                },
                              );
                            }
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 40),
                  ValueListenableBuilder<String>(
                    valueListenable: _capturedImagePath,
                    builder: (context, imagePath, child) {
                      return Text(
                        _verificationComplete
                            ? 'Verification Complete!'
                            : _isVerifying
                                ? (imagePath.isNotEmpty ? 'Verifying... Hold still' : 'Capturing... Look at the camera')
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
                      );
                    }
                  ),
                  if (_isVerifying && _capturedImagePath.value.isEmpty) ...[ // Show progress only during "Capturing..."
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
                  : (_isVerifying || _cameraController == null || (_cameraController !=null && !_cameraController!.value.isInitialized))
                      ? null // Disabled if verifying or camera not ready
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
                        ? (_capturedImagePath.value.isNotEmpty ? 'Verifying...' : 'Capturing...')
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
    // ... (Your existing _pickImage method)
    // For brevity, assuming this part remains the same
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
                      backgroundColor: Color(0xFFf86f54), // Slightly different color for gallery
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
    // ... (Your existing _showPermissionDialog method)
    // For brevity, assuming this part remains the same
        if (!mounted) return;
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
    // ... (Your existing _pickImageFromSource method)
    // For brevity, assuming this part remains the same
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
        if (mounted) {
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    // ... (Your existing _removeImage method)
    // For brevity, assuming this part remains the same
    setState(() {
      if (index < _uploadedImages.length) {
        _uploadedImages.removeAt(index);
      }
    });

    HapticFeedback.lightImpact();
    if (mounted) {
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
  }

  void _nextToFaceVerification() {
    _pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
     // Ensure camera is ready or initializing when moving to the face verification step
    if (_cameraController == null || (_cameraController != null && !_cameraController!.value.isInitialized)) {
      _initializeCamera();
    }
  }

 void _startFaceVerification() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera not ready. Please wait or check permissions.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      _initializeCamera(); // Attempt to re-initialize
      return;
    }

    setState(() {
      _isVerifying = true;
      _capturedImagePath.value = ""; // Clear previous capture
      _pulseController.repeat(reverse: true); // Start pulsing animation
    });

    // Short delay to allow user to focus, and for "Capturing..." text to show
    await Future.delayed(Duration(milliseconds: 800));

    try {
      // Ensure camera is not already streaming or capturing
      if (_cameraController!.value.isTakingPicture) return;

      final XFile image = await _cameraController!.takePicture();
      _capturedImagePath.value = image.path;

      _pulseController.stop(); // Stop pulsing once image is captured
      _pulseController.reset();

      if (mounted) setState(() {}); // Rebuild to show the captured image and "Verifying..."

      // Hold the captured image for 1 second (simulates processing before "backend verification")
      await Future.delayed(Duration(seconds: 1));

      // Simulate actual verification process (e.g., API call) - 2 seconds
      await Future.delayed(Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isVerifying = false;
          _verificationComplete = true;
        });
      }
      HapticFeedback.heavyImpact();

      // Consider stopping image stream and disposing camera if verification is final
      // and no retry is immediately offered on this screen.
      // For now, we'll keep it active in case of back navigation or retry logic.
      // await _cameraController?.stopImageStream();
      // await _cameraController?.dispose();
      // _cameraController = null;

    } catch (e) {
      print('Error taking picture: $e');
       _pulseController.stop();
       _pulseController.reset();
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _capturedImagePath.value = ""; // Clear image path on error
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture image. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  void _completeVerification() {
    if (mounted) {
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
    }

    // Dispose camera before navigating away
    _cameraController?.dispose().then((_) {
        _cameraController = null;
         if (mounted) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DashboardScreen()),
            );
        }
    }).catchError((e) { // In case dispose fails, still navigate
        print("Error disposing camera: $e");
         if (mounted) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DashboardScreen()),
            );
        }
    });


  }
}

