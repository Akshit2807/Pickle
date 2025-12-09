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

  // Controllers for Basic Info Step
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  final List<GlobalKey<FormState>> _formKeys = List.generate(
    4,
    (_) => GlobalKey<FormState>(),
  );

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

    // Initialize controllers
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color),
          onPressed: () {
            if (_authController.currentStep > 0) {
              _previousStep();
            } else {
              Get.back();
            }
          },
        ),
        title: Obx(
          () => LinearProgressIndicator(
            value: (_authController.currentStep + 1) / 4,
            backgroundColor: theme.dividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
          ),
        ),
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
              controller: _nameController,
              label: 'First Name',
              icon: Icons.person_outline,
              onChanged: (value) {
                _user.name = value;
              },
              validator: (value) =>
                  value?.isEmpty == true ? 'Name is required' : null,
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              onChanged: (value) {
                _user.email = value;
              },
              validator: (value) {
                if (value?.isEmpty == true) return 'Email is required';
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value!)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number (Optional)',
              icon: Icons.phone_outlined,
              onChanged: (value) {
                _user.phone = value;
              },
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: _passwordController,
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
                if (value!.length < 6)
                  return 'Password must be at least 6 characters';
                return null;
              },
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              icon: Icons.lock_outline,
              isPassword: true,
              isPasswordVisible: _isConfirmPasswordVisible,
              onVisibilityToggle: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
              onChanged: (value) {
                // No need to store, just for validation
              },
              validator: (value) {
                if (value?.isEmpty == true)
                  return 'Please confirm your password';
                if (value != _passwordController.text)
                  return 'Passwords do not match';
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
            _buildStepHeader('About You', 'Help us get to know you better', 2),
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
              validator: (value) => value?.isEmpty == true
                  ? 'Please tell us about yourself'
                  : null,
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step $step of 4',
          style: TextStyle(
            color: theme.colorScheme.secondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.textTheme.bodyMedium?.color,
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
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      cursorColor: theme.colorScheme.secondary,
      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: label,
        // labelStyle inherited from theme
        // prefixIconColor inherited from theme
        prefixIcon: Icon(icon),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: theme.colorScheme.secondary,
                ),
                onPressed: onVisibilityToggle,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        // focusedBorder inherited from theme
        filled: true,
        fillColor: theme.inputDecorationTheme.fillColor,
      ),
    );
  }

  Widget _buildSocialLoginSection() {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: theme.dividerColor)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or sign up with',
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
            ),
            Expanded(child: Divider(color: theme.dividerColor)),
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

  Widget _buildSocialButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    final theme = Theme.of(context);
    return Container(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: theme.iconTheme.color),
        label: Text(
          text,
          style: TextStyle(color: theme.textTheme.bodyMedium?.color),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: theme.dividerColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelection() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I am',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: 15),
        Wrap(
          spacing: 10,
          children: ['Man', 'Woman', 'Non-binary', 'Other'].map((gender) {
            final isSelected = _user.gender == gender;
            return FilterChip(
              label: Text(
                gender,
                style: TextStyle(
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.textTheme.bodyLarge?.color,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _user.gender = selected ? gender : null;
                });
              },
              selectedColor: theme.primaryColor,
              checkmarkColor: theme.colorScheme.onPrimary,
              backgroundColor: theme.cardColor,
              side: BorderSide(
                color: const Color(0xFFF2AEBF).withValues(alpha: 0.3),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInterestedInSelection() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interested in',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: 15),
        Wrap(
          spacing: 10,
          children: ['Men', 'Women', 'Non-binary', 'Everyone'].map((interest) {
            final isSelected = _user.interestedIn == interest;
            return FilterChip(
              label: Text(
                interest,
                style: TextStyle(
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.textTheme.bodyLarge?.color,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _user.interestedIn = selected ? interest : null;
                });
              },
              selectedColor: theme.primaryColor,
              checkmarkColor: theme.colorScheme.onPrimary,
              backgroundColor: theme.cardColor,
              side: BorderSide(
                color: const Color(0xFFF2AEBF).withValues(alpha: 0.3),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
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
                  data: theme.copyWith(
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFF7F4F6), // offWhite
                      ),
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
              border: Border.all(
                color: const Color(
                  0xFFF2AEBF,
                ).withValues(alpha: 0.4), // burgundySwatch[200]
              ),
              borderRadius: BorderRadius.circular(15),
              color: theme.inputDecorationTheme.fillColor,
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: theme.colorScheme.secondary),
                SizedBox(width: 15),
                Text(
                  _user.birthDate != null
                      ? '${_user.birthDate!.day}/${_user.birthDate!.month}/${_user.birthDate!.year}'
                      : 'Select your birth date',
                  style: TextStyle(
                    fontSize: 16,
                    color: _user.birthDate != null
                        ? theme.textTheme.bodyLarge?.color
                        : theme.hintColor,
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
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: 15),
        TextFormField(
          controller: locationController,
          onChanged: (value) {
            _user.location = value;
          },
          cursorColor: theme.colorScheme.secondary,
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            labelText: 'Enter your city',
            // labelStyle inherited from theme
            // prefixIconColor inherited from theme
            prefixIcon: Icon(Icons.location_on_outlined),
            suffixIcon: IconButton(
              icon: Icon(Icons.my_location, color: theme.colorScheme.secondary),
              onPressed: () => _getCurrentLocation(locationController),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            // focusedBorder inherited from theme
            filled: true,
            fillColor: theme.inputDecorationTheme.fillColor,
          ),
        ),
      ],
    );
  }

  void _getCurrentLocation(TextEditingController controller) async {
    final theme = Theme.of(context);
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
          backgroundColor: theme.primaryColor,
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
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
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
            backgroundColor: theme.primaryColor,
            behavior: SnackBarBehavior.fixed,
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
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: theme.cardColor,
        title: Row(
          children: [
            Icon(Icons.location_on, color: theme.colorScheme.secondary),
            SizedBox(width: 10),
            Text(
              'Location Permission',
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            ),
          ],
        ),
        content: Text(
          'Location access is required to find matches near you. Please enable location permission in settings.',
          style: TextStyle(color: theme.textTheme.bodyMedium?.color),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Settings',
              style: TextStyle(color: theme.colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeRangeSlider() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Age Range: ${(_user.ageRange?.start ?? 18).round()} - ${(_user.ageRange?.end ?? 30).round()}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: 15),
        RangeSlider(
          values: _user.ageRange ?? RangeValues(18, 30),
          min: 18,
          max: 65,
          divisions: 47,
          activeColor: theme.primaryColor,
          inactiveColor: theme.primaryColor.withOpacity(0.3),
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distance: ${(_user.distanceRange ?? 25).round()} km',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: 15),
        Slider(
          value: _user.distanceRange ?? 25,
          min: 1,
          max: 100,
          divisions: 99,
          activeColor: theme.primaryColor,
          inactiveColor: theme.primaryColor.withOpacity(0.3),
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Looking for',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: 15),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              [
                'Casual dating',
                'Serious relationship',
                'Marriage',
                'Friendship',
                'Not sure yet',
              ].map((goal) {
                final isSelected = _user.relationshipGoals == goal;
                return FilterChip(
                  label: Text(
                    goal,
                    style: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _user.relationshipGoals = selected ? goal : null;
                    });
                  },
                  selectedColor: theme.primaryColor,
                  checkmarkColor: theme.colorScheme.onPrimary,
                  backgroundColor: theme.cardColor,
                  side: BorderSide(
                    color: const Color(0xFFF2AEBF).withValues(alpha: 0.3),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildInterestsSection() {
    final theme = Theme.of(context);
    final interests = [
      'Travel',
      'Music',
      'Photography',
      'Fitness',
      'Cooking',
      'Reading',
      'Movies',
      'Art',
      'Sports',
      'Gaming',
      'Dancing',
      'Technology',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interests (Select up to 5)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: 15),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: interests.map((interest) {
            final userInterests = _user.interests ?? [];
            final isSelected = userInterests.contains(interest);
            return FilterChip(
              label: Text(
                interest,
                style: TextStyle(
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.textTheme.bodyLarge?.color,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final currentInterests = _user.interests ?? [];
                  if (selected && currentInterests.length < 5) {
                    _user.interests = [...currentInterests, interest];
                  } else if (!selected) {
                    _user.interests = currentInterests
                        .where((i) => i != interest)
                        .toList();
                  }
                });
              },
              selectedColor: theme.primaryColor,
              checkmarkColor: theme.colorScheme.onPrimary,
              backgroundColor: theme.cardColor,
              side: BorderSide(
                color: const Color(0xFFF2AEBF).withValues(alpha: 0.3),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLifestyleSection() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lifestyle',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: 15),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              [
                'Non-smoker',
                'Smoker',
                'Social drinker',
                'Non-drinker',
                'Pet lover',
                'No pets',
              ].map((lifestyle) {
                final isSelected = _user.lifestyle == lifestyle;
                return FilterChip(
                  label: Text(
                    lifestyle,
                    style: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _user.lifestyle = selected ? lifestyle : null;
                    });
                  },
                  selectedColor: theme.primaryColor,
                  checkmarkColor: theme.colorScheme.onPrimary,
                  backgroundColor: theme.cardColor,
                  side: BorderSide(
                    color: const Color(0xFFF2AEBF).withValues(alpha: 0.3),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    final theme = Theme.of(context);
    return Obx(
      () => Container(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            if (_authController.currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : _previousStep,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: const Color(
                        0xFFF2AEBF,
                      ).withValues(alpha: 0.4), // burgundySwatch[200]
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'Back',
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
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
                  backgroundColor: theme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  elevation: 5,
                ),
                child: _isSubmitting
                    ? CircularProgressIndicator(
                        color: theme.colorScheme.onPrimary,
                      )
                    : Text(
                        _authController.currentStep == 3
                            ? 'Complete'
                            : 'Continue',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextStep() async {
    if (_formKeys[_authController.currentStep].currentState?.validate() ??
        true) {
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
    final theme = Theme.of(context);
    setState(() => _isSubmitting = true);

    final success = await _authController.signUp(user: _user);

    setState(() => _isSubmitting = false);

    if (success) {
      // Navigate directly to dashboard - user is already logged in after signup
      Get.offAll(() => DashboardScreen());
      Get.snackbar(
        'Success',
        'Welcome to Pickle! Your account has been created.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.primaryColor,
        colorText: theme.colorScheme.onPrimary,
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
