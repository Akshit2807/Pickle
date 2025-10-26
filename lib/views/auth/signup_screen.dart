import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pickle/models/user.dart';
import 'package:pickle/controllers/auth_controller.dart';
import 'package:pickle/views/dashboard/dashboard_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AuthController _authController;
  late User _user;

  final List<GlobalKey<FormState>> _formKeys = List.generate(4, (_) => GlobalKey<FormState>());

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _authController = Get.find<AuthController>();
    _user = User();
    _authController.resetSignupFlow();
  }

  @override
  void dispose() {
    _pageController.dispose();
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
            if (_authController.currentStep > 0) {
              _previousStep();
            } else {
              Get.back();
            }
          },
        ),
        title: Obx(() => LinearProgressIndicator(
          value: (_authController.currentStep + 1) / 4,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFee403a)),
        )),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildBasicInfoStep(),
                _buildDemographicsStep(),
                _buildPreferencesStep(),
                _buildPersonalityStep(),
              ],
            ),
          ),
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    final nameController = TextEditingController(text: _user.name);
    final emailController = TextEditingController(text: _user.email);
    final phoneController = TextEditingController(text: _user.phone);
    final passwordController = TextEditingController(text: _user.password);
    final confirmPasswordController = TextEditingController();

    return SingleChildScrollView(
      padding: EdgeInsets.all(30),
      child: Form(
        key: _formKeys[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(
              'Basic Information',
              'Let\'s start with the basics',
              1,
            ),
            SizedBox(height: 30),
            _buildTextField(
              controller: nameController,
              label: 'First Name',
              icon: Icons.person_outline,
              onChanged: (value) {
                _user.name = value;
              },
              validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              onChanged: (value) {
                _user.email = value;
              },
              validator: (value) {
                if (value?.isEmpty == true) return 'Email is required';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: phoneController,
              label: 'Phone Number (Optional)',
              icon: Icons.phone_outlined,
              onChanged: (value) {
                _user.phone = value;
              },
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: passwordController,
              label: 'Password',
              icon: Icons.lock_outline,
              isPassword: true,
              isPasswordVisible: _isPasswordVisible,
              onVisibilityToggle: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              onChanged: (value) {
                _user.password = value;
              },
              validator: (value) {
                if (value?.isEmpty == true) return 'Password is required';
                if (value!.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: confirmPasswordController,
              label: 'Confirm Password',
              icon: Icons.lock_outline,
              isPassword: true,
              isPasswordVisible: _isConfirmPasswordVisible,
              onVisibilityToggle: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
              validator: (value) {
                if (value?.isEmpty == true) return 'Please confirm your password';
                if (value != passwordController.text) return 'Passwords do not match';
                return null;
              },
            ),
            SizedBox(height: 30),
            _buildSocialLoginSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDemographicsStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(30),
      child: Form(
        key: _formKeys[1],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(
              'About You',
              'Help us get to know you better',
              2,
            ),
            SizedBox(height: 30),
            _buildGenderSelection(),
            SizedBox(height: 30),
            _buildInterestedInSelection(),
            SizedBox(height: 30),
            _buildDatePicker(),
            SizedBox(height: 30),
            _buildLocationField(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(30),
      child: Form(
        key: _formKeys[2],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(
              'Your Preferences',
              'Set your dating preferences',
              3,
            ),
            SizedBox(height: 30),
            _buildAgeRangeSlider(),
            SizedBox(height: 30),
            _buildDistanceSlider(),
            SizedBox(height: 30),
            _buildRelationshipGoals(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalityStep() {
    final bioController = TextEditingController(text: _user.bio);

    return SingleChildScrollView(
      padding: EdgeInsets.all(30),
      child: Form(
        key: _formKeys[3],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(
              'Express Yourself',
              'Tell us about your personality',
              4,
            ),
            SizedBox(height: 30),
            _buildTextField(
              controller: bioController,
              label: 'About Me',
              icon: Icons.edit_outlined,
              maxLines: 4,
              onChanged: (value) {
                _user.bio = value;
              },
              validator: (value) => value?.isEmpty == true ? 'Please tell us about yourself' : null,
            ),
            SizedBox(height: 30),
            _buildInterestsSection(),
            SizedBox(height: 30),
            _buildLifestyleSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepHeader(String title, String subtitle, int step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step $step of 4',
          style: TextStyle(
            color: Color(0xFFee403a),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onVisibilityToggle,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFFee403a)),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Color(0xFFee403a),
          ),
          onPressed: onVisibilityToggle,
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xFFee403a), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300])),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or sign up with',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[300])),
          ],
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildSocialButton('Google', Icons.g_mobiledata, () {}),
            ),
            SizedBox(width: 15),
            Expanded(
              child: _buildSocialButton('Facebook', Icons.facebook, () {}),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(String text, IconData icon, VoidCallback onPressed) {
    return Container(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.grey[700]),
        label: Text(text, style: TextStyle(color: Colors.grey[700])),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I am',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 15),
        Wrap(
          spacing: 10,
          children: ['Man', 'Woman', 'Non-binary', 'Other'].map((gender) {
            final isSelected = _user.gender == gender;
            return FilterChip(
              label: Text(gender),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _user.gender = selected ? gender : null;
                });
              },
              selectedColor: Color(0xFFee403a).withOpacity(0.2),
              checkmarkColor: Color(0xFFee403a),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInterestedInSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interested in',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 15),
        Wrap(
          spacing: 10,
          children: ['Men', 'Women', 'Non-binary', 'Everyone'].map((interest) {
            final isSelected = _user.interestedIn == interest;
            return FilterChip(
              label: Text(interest),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _user.interestedIn = selected ? interest : null;
                });
              },
              selectedColor: Color(0xFFee403a).withOpacity(0.2),
              checkmarkColor: Color(0xFFee403a),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 15),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _user.birthDate ?? DateTime(2000),
              firstDate: DateTime(1950),
              lastDate: DateTime.now().subtract(Duration(days: 365 * 18)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Color(0xFFee403a),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              setState(() {
                _user.birthDate = date;
              });
            }
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 18),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(15),
              color: Colors.grey[50],
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Color(0xFFee403a)),
                SizedBox(width: 15),
                Text(
                  _user.birthDate != null
                      ? '${_user.birthDate!.day}/${_user.birthDate!.month}/${_user.birthDate!.year}'
                      : 'Select your birth date',
                  style: TextStyle(
                    fontSize: 16,
                    color: _user.birthDate != null
                        ? Colors.black87
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    final locationController = TextEditingController(text: _user.location);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 15),
        TextFormField(
          controller: locationController,
          onChanged: (value) {
            _user.location = value;
          },
          decoration: InputDecoration(
            labelText: 'Enter your city',
            prefixIcon: Icon(Icons.location_on_outlined, color: Color(0xFFee403a)),
            suffixIcon: IconButton(
              icon: Icon(Icons.my_location, color: Color(0xFFee403a)),
              onPressed: () => _getCurrentLocation(locationController),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Color(0xFFee403a), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  void _getCurrentLocation(TextEditingController controller) async {
    try {
      // Check and request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationPermissionDialog();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationPermissionDialog();
        return;
      }

      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
              SizedBox(width: 16),
              Text('Getting your location...'),
            ],
          ),
          backgroundColor: Color(0xFFee403a),
          duration: Duration(seconds: 3),
        ),
      );

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '';

        if (place.locality != null && place.locality!.isNotEmpty) {
          address += place.locality!;
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.administrativeArea!;
        }
        if (place.country != null && place.country!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.country!;
        }

        setState(() {
          controller.text = address.isNotEmpty ? address : 'Current Location';
          _user.location = controller.text;
        });

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location updated successfully! 📍'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get location. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.location_on, color: Color(0xFFee403a)),
            SizedBox(width: 10),
            Text('Location Permission'),
          ],
        ),
        content: Text(
          'Location access is required to find matches near you. Please enable location permission in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
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

  Widget _buildAgeRangeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Age Range: ${(_user.ageRange?.start ?? 18).round()} - ${(_user.ageRange?.end ?? 30).round()}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 15),
        RangeSlider(
          values: _user.ageRange ?? RangeValues(18, 30),
          min: 18,
          max: 65,
          divisions: 47,
          activeColor: Color(0xFFee403a),
          inactiveColor: Color(0xFFee403a).withOpacity(0.3),
          onChanged: (values) {
            setState(() {
              _user.ageRange = values;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDistanceSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distance: ${(_user.distanceRange ?? 25).round()} km',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 15),
        Slider(
          value: _user.distanceRange ?? 25,
          min: 1,
          max: 100,
          divisions: 99,
          activeColor: Color(0xFFee403a),
          inactiveColor: Color(0xFFee403a).withOpacity(0.3),
          onChanged: (value) {
            setState(() {
              _user.distanceRange = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildRelationshipGoals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Looking for',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 15),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: ['Casual dating', 'Serious relationship', 'Marriage', 'Friendship', 'Not sure yet'].map((goal) {
            final isSelected = _user.relationshipGoals == goal;
            return FilterChip(
              label: Text(goal),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _user.relationshipGoals = selected ? goal : null;
                });
              },
              selectedColor: Color(0xFFee403a).withOpacity(0.2),
              checkmarkColor: Color(0xFFee403a),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInterestsSection() {
    final interests = [
      'Travel', 'Music', 'Photography', 'Fitness', 'Cooking', 'Reading',
      'Movies', 'Art', 'Sports', 'Gaming', 'Dancing', 'Technology'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interests (Select up to 5)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 15),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: interests.map((interest) {
            final userInterests = _user.interests ?? [];
            final isSelected = userInterests.contains(interest);
            return FilterChip(
              label: Text(interest),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final currentInterests = _user.interests ?? [];
                  if (selected && currentInterests.length < 5) {
                    _user.interests = [...currentInterests, interest];
                  } else if (!selected) {
                    _user.interests = currentInterests.where((i) => i != interest).toList();
                  }
                });
              },
              selectedColor: Color(0xFFee403a).withOpacity(0.2),
              checkmarkColor: Color(0xFFee403a),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLifestyleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lifestyle',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 15),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: ['Non-smoker', 'Smoker', 'Social drinker', 'Non-drinker', 'Pet lover', 'No pets'].map((lifestyle) {
            final isSelected = _user.lifestyle == lifestyle;
            return FilterChip(
              label: Text(lifestyle),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _user.lifestyle = selected ? lifestyle : null;
                });
              },
              selectedColor: Color(0xFFee403a).withOpacity(0.2),
              checkmarkColor: Color(0xFFee403a),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Obx(() => Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          if (_authController.currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : _previousStep,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Color(0xFFee403a)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  'Back',
                  style: TextStyle(
                    color: Color(0xFFee403a),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_authController.currentStep > 0) SizedBox(width: 15),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFee403a),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.symmetric(vertical: 15),
                elevation: 5,
              ),
              child: _isSubmitting
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      _authController.currentStep == 3 ? 'Complete' : 'Continue',
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
    ));
  }

  void _nextStep() async {
    if (_formKeys[_authController.currentStep].currentState?.validate() ?? true) {
      if (_authController.currentStep < 3) {
        _authController.nextStep();
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        // Final step - create account with Firebase
        await _completeSignup();
      }
    }
  }

  Future<void> _completeSignup() async {
    setState(() => _isSubmitting = true);

    final success = await _authController.signUp(
      email: _user.email!,
      password: _user.password!,
      userData: _user,
    );

    setState(() => _isSubmitting = false);

    if (success) {
      // Navigate directly to dashboard - user is already logged in after signup
      Get.offAll(() => DashboardScreen());
      Get.snackbar(
        'Success',
        'Welcome to Pickle! Your account has been created.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  void _previousStep() {
    _authController.previousStep();
    _pageController.previousPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}