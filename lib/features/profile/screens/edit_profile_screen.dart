import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/image_picker_helper.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/auth_session_manager.dart';
import '../../../core/widgets/app_image.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  bool _isLoading = false;
  bool _isFetching = true;
  bool _isUploadingAvatar = false;
  String _avatarUrl = '';

  // Onboarding & Questionnaire state values
  String _selectedGender = 'Male';
  String _heightUnit = 'CM';
  String _weightUnit = 'Kg';
  String _activityLevel = 'Moderate';
  String _workoutPlace = 'Home';
  String _fitnessLevel = 'Beginner';
  String _duration = '30 min';
  String _trainingDays = '5 Days';
  List<String> _selectedGoals = ['Build Muscle', 'Stay Active'];

  // Preset options matching onboarding flow
  final List<String> _genderOptions = ['Male', 'Female'];
  final List<String> _activityOptions = ['Sedentary', 'Moderate', 'High Active'];
  final List<String> _workoutPlaceOptions = ['Home', 'Gym', 'Outdoor'];
  final List<String> _fitnessLevelOptions = ['Beginner', 'Intermediate', 'Advanced'];
  final List<String> _durationOptions = ['10 min', '20 min', '30 min', '40 min', '50 min', '60 min'];
  final List<String> _trainingDaysOptions = ['1 Day', '2 Days', '3 Days', '4 Days', '5 Days', '6 Days', 'Everyday'];
  final List<String> _availableGoals = [
    'Lose Weight',
    'Build Muscle',
    'Six Pack',
    'Improve Fitness',
    'Increase Strength',
    'Stay Active',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isFetching = true);

    // Initial local values
    _nameController.text = AuthSessionManager.instance.userName ?? 'Athlete';
    _emailController.text = AuthSessionManager.instance.userEmail ?? 'user@example.com';
    _avatarUrl = AuthSessionManager.instance.userAvatar ?? '';

    try {
      final res = await ApiClient.instance.get(ApiConstants.me);
      if (res.isOk && res.data != null) {
        dynamic userData = res.data;
        if (userData is Map && userData.containsKey('data')) {
          userData = userData['data'];
        }

        if (userData is Map) {
          _nameController.text = userData['name']?.toString() ?? _nameController.text;
          _emailController.text = userData['email']?.toString() ?? _emailController.text;
          _avatarUrl = userData['avatar']?.toString() ?? _avatarUrl;

          if (userData['gender'] != null) {
            _selectedGender = userData['gender'].toString();
          }

          final prof = userData['profile'] is Map ? userData['profile'] as Map : null;
          if (prof != null) {
            _heightController.text = prof['height']?.toString() ?? '175';
            _heightUnit = prof['heightUnit']?.toString() ?? 'CM';
            _weightController.text = prof['weight']?.toString() ?? '75';
            _weightUnit = prof['weightUnit']?.toString() ?? 'Kg';
            _ageController.text = prof['age']?.toString() ?? '25';
            _activityLevel = prof['activityLevel']?.toString() ?? 'Moderate';
            _workoutPlace = prof['workoutPlace']?.toString() ?? 'Home';
            _fitnessLevel = prof['fitnessLevel']?.toString() ?? 'Beginner';
            _duration = prof['duration']?.toString() ?? '30 min';
            _trainingDays = prof['trainingDays']?.toString() ?? '5 Days';

            if (prof['goals'] is List) {
              _selectedGoals = (prof['goals'] as List).map((e) => e.toString()).toList();
            }
          }

          // Sync loaded profile to session
          await AuthSessionManager.instance.saveSession(
            token: AuthSessionManager.instance.token ?? '',
            userId: AuthSessionManager.instance.userId ?? '',
            isGuest: AuthSessionManager.instance.isGuest,
            name: _nameController.text,
            email: _emailController.text,
            avatar: _avatarUrl,
          );
        }
      }
    } catch (e) {
      debugPrint('[EditProfile] Error fetching user profile: $e');
    }

    if (mounted) {
      setState(() => _isFetching = false);
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      final picked = await ImagePickerHelper.pickImage();
      if (picked == null) return;

      final String filename = picked['name']?.toString() ?? 'photo.jpg';
      final String? mimeType = picked['mimeType']?.toString();
      final List<int> bytes = picked['bytes'] as List<int>;

      if (bytes.isEmpty) return;

      setState(() => _isUploadingAvatar = true);

      final res = await ApiClient.instance.postMultipart(
        ApiConstants.uploadPhoto,
        fileField: 'photo',
        bytes: bytes,
        filename: filename,
        mimeType: mimeType,
      );

      if (!mounted) return;
      setState(() => _isUploadingAvatar = false);

      if (res.isOk && res.data != null) {
        String? uploadedUrl;
        dynamic resData = res.data;
        if (resData is Map) {
          if (resData.containsKey('url')) {
            uploadedUrl = resData['url']?.toString();
          } else if (resData['data'] is Map && resData['data'].containsKey('url')) {
            uploadedUrl = resData['data']['url']?.toString();
          }
        }

        if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
          setState(() {
            _avatarUrl = uploadedUrl!;
          });
          _showToast('Profile photo uploaded successfully!');
        } else {
          _showToast('Photo uploaded but server did not return image URL', isError: true);
        }
      } else {
        _showToast(res.error ?? 'Failed to upload photo', isError: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
        _showToast('Error picking photo: $e', isError: true);
      }
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showToast('Please enter your full name', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final body = {
        'name': name,
        'avatar': _avatarUrl,
        'gender': _selectedGender,
        'height': double.tryParse(_heightController.text.trim()) ?? 175,
        'heightUnit': _heightUnit,
        'weight': double.tryParse(_weightController.text.trim()) ?? 75,
        'weightUnit': _weightUnit,
        'age': int.tryParse(_ageController.text.trim()) ?? 25,
        'activityLevel': _activityLevel,
        'goals': _selectedGoals,
        'workoutPlace': _workoutPlace,
        'fitnessLevel': _fitnessLevel,
        'duration': _duration,
        'trainingDays': _trainingDays,
      };

      final res = await ApiClient.instance.post(ApiConstants.questionnaire, body);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (res.isOk) {
        await AuthSessionManager.instance.saveSession(
          token: AuthSessionManager.instance.token ?? '',
          userId: AuthSessionManager.instance.userId ?? '',
          isGuest: false,
          name: name,
          avatar: _avatarUrl,
        );

        _showToast('Profile updated successfully!');
        Navigator.of(context).pop(true);
      } else {
        _showToast(res.error ?? 'Failed to update profile', isError: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showToast('Connection error. Please try again.', isError: true);
      }
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? const Color(0xFF2C1414) : const Color(0xFF1B1B1D),
        content: Text(
          message,
          style: GoogleFonts.outfit(
            color: isError ? const Color(0xFFFF5B5B) : AppColors.primaryLime,
            fontWeight: FontWeight.w600,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16.0),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: SafeArea(
        child: _isFetching
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryLime),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar (Back Arrow + Title)
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'My Profile',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Avatar Edit Banner Header
                    GestureDetector(
                      onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                      child: Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLime.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primaryLime,
                                  width: 2.0,
                                ),
                              ),
                              child: ClipOval(
                                child: _avatarUrl.isNotEmpty
                                    ? AppImage(
                                        imagePath: _avatarUrl,
                                        width: 96,
                                        height: 96,
                                        fit: BoxFit.cover,
                                        errorWidget: const Center(
                                          child: Icon(
                                            Icons.person_rounded,
                                            color: AppColors.primaryLime,
                                            size: 52,
                                          ),
                                        ),
                                      )
                                    : const Center(
                                        child: Icon(
                                          Icons.person_rounded,
                                          color: AppColors.primaryLime,
                                          size: 52,
                                        ),
                                      ),
                              ),
                            ),
                            if (_isUploadingAvatar)
                              Positioned.fill(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: AppColors.primaryLime,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLime,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.backgroundBlack,
                                    width: 2.0,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.black,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // SECTION 1: ACCOUNT INFORMATION
                    _buildSectionHeader('Account Information'),
                    const SizedBox(height: 14),

                    // User Name Field (Editable)
                    _buildLabel('Full Name'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _nameController,
                      hintText: 'Enter full name',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 14),

                    // Email Field (READ ONLY / Display Only)
                    _buildLabel('Email Address (Read Only)'),
                    const SizedBox(height: 6),
                    _buildReadOnlyField(
                      controller: _emailController,
                      icon: Icons.mail_outline_rounded,
                    ),
                    const SizedBox(height: 28),

                    // SECTION 2: BODY METRICS & PERSONAL INFO (ONBOARDING)
                    _buildSectionHeader('Body Metrics & Personal Info'),
                    const SizedBox(height: 14),

                    // Gender Selector
                    _buildLabel('Gender'),
                    const SizedBox(height: 8),
                    Row(
                      children: _genderOptions.map((g) {
                        final isSelected = _selectedGender.toLowerCase() == g.toLowerCase();
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedGender = g),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8.0),
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primaryLime : const Color(0xFF161619),
                                borderRadius: BorderRadius.circular(14.0),
                                border: Border.all(
                                  color: isSelected ? AppColors.primaryLime : Colors.white.withValues(alpha: 0.12),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  g,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? Colors.black : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Age Field
                    _buildLabel('Age'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _ageController,
                      hintText: 'Enter age (years)',
                      icon: Icons.calendar_month_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 14),

                    // Height Field with Unit Toggle (CM / FT)
                    _buildLabel('Height'),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _heightController,
                            hintText: 'Enter height',
                            icon: Icons.height_rounded,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildUnitToggle(
                          unit1: 'CM',
                          unit2: 'FT',
                          selectedUnit: _heightUnit,
                          onUnitChanged: (u) => setState(() => _heightUnit = u),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Weight Field with Unit Toggle (Kg / Lbs)
                    _buildLabel('Weight'),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _weightController,
                            hintText: 'Enter weight',
                            icon: Icons.monitor_weight_outlined,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildUnitToggle(
                          unit1: 'Kg',
                          unit2: 'Lbs',
                          selectedUnit: _weightUnit,
                          onUnitChanged: (u) => setState(() => _weightUnit = u),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // SECTION 3: FITNESS PREFERENCES (ONBOARDING)
                    _buildSectionHeader('Fitness Preferences'),
                    const SizedBox(height: 14),

                    // Fitness Goals Multi-Select Chips
                    _buildLabel('Main Fitness Goals'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _availableGoals.map((goal) {
                        final isSelected = _selectedGoals.contains(goal);
                        return ChoiceChip(
                          label: Text(
                            goal,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.black : Colors.white70,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedGoals.add(goal);
                              } else {
                                if (_selectedGoals.length > 1) {
                                  _selectedGoals.remove(goal);
                                }
                              }
                            });
                          },
                          selectedColor: AppColors.primaryLime,
                          backgroundColor: const Color(0xFF161619),
                          side: BorderSide(
                            color: isSelected ? AppColors.primaryLime : Colors.white.withValues(alpha: 0.12),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Activity Level Dropdown
                    _buildLabel('Activity Level'),
                    const SizedBox(height: 6),
                    _buildDropdownSelector(
                      value: _activityLevel,
                      items: _activityOptions,
                      icon: Icons.directions_run_rounded,
                      onChanged: (val) => setState(() => _activityLevel = val),
                    ),
                    const SizedBox(height: 14),

                    // Workout Location Selector
                    _buildLabel('Workout Place'),
                    const SizedBox(height: 6),
                    _buildDropdownSelector(
                      value: _workoutPlace,
                      items: _workoutPlaceOptions,
                      icon: Icons.fitness_center_rounded,
                      onChanged: (val) => setState(() => _workoutPlace = val),
                    ),
                    const SizedBox(height: 14),

                    // Fitness Level Selector
                    _buildLabel('Fitness Experience Level'),
                    const SizedBox(height: 6),
                    _buildDropdownSelector(
                      value: _fitnessLevel,
                      items: _fitnessLevelOptions,
                      icon: Icons.trending_up_rounded,
                      onChanged: (val) => setState(() => _fitnessLevel = val),
                    ),
                    const SizedBox(height: 14),

                    // Workout Duration Selector
                    _buildLabel('Preferred Workout Duration'),
                    const SizedBox(height: 6),
                    _buildDropdownSelector(
                      value: _duration,
                      items: _durationOptions,
                      icon: Icons.timer_outlined,
                      onChanged: (val) => setState(() => _duration = val),
                    ),
                    const SizedBox(height: 14),

                    // Weekly Training Days Selector
                    _buildLabel('Training Days Per Week'),
                    const SizedBox(height: 6),
                    _buildDropdownSelector(
                      value: _trainingDays,
                      items: _trainingDaysOptions,
                      icon: Icons.calendar_today_rounded,
                      onChanged: (val) => setState(() => _trainingDays = val),
                    ),
                    const SizedBox(height: 36),

                    // Primary Save Profile Button (Lime Pill)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLime,
                          foregroundColor: const Color(0xFF111113),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        onPressed: _isLoading ? null : _saveProfile,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Color(0xFF111113),
                                ),
                              )
                            : Text(
                                'Save Profile',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  // Section Header Divider Text
  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryLime,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 2,
          width: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryLime,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  // Label text above fields
  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.white70,
      ),
    );
  }

  // Standard Pill Input Field
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161619),
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.0,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textAlignVertical: TextAlignVertical.center,
        style: GoogleFonts.outfit(
          fontSize: 14,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          hintText: hintText,
          hintStyle: GoogleFonts.outfit(
            fontSize: 14,
            color: Colors.white38,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.white54,
            size: 20,
          ),
        ),
      ),
    );
  }

  // Read-Only Disabled Field (for Email)
  Widget _buildReadOnlyField({
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF101012),
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 1.0,
        ),
      ),
      child: TextField(
        controller: controller,
        enabled: false,
        textAlignVertical: TextAlignVertical.center,
        style: GoogleFonts.outfit(
          fontSize: 14,
          color: Colors.white54,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          prefixIcon: Icon(
            icon,
            color: Colors.white38,
            size: 20,
          ),
          suffixIcon: const Padding(
            padding: EdgeInsets.only(right: 14.0),
            child: Icon(
              Icons.lock_outline_rounded,
              color: Colors.white38,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  // Unit Toggle Button (CM/FT or Kg/Lbs)
  Widget _buildUnitToggle({
    required String unit1,
    required String unit2,
    required String selectedUnit,
    required ValueChanged<String> onUnitChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161619),
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [unit1, unit2].map((u) {
          final isSelected = selectedUnit.toLowerCase() == u.toLowerCase();
          return GestureDetector(
            onTap: () => onUnitChanged(u),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryLime : Colors.transparent,
                borderRadius: BorderRadius.circular(22.0),
              ),
              child: Text(
                u,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.black : Colors.white60,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Dark Modal Selector Container (Fixes white highlight / canvas flash on web)
  Widget _buildDropdownSelector({
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String> onChanged,
  }) {
    final selectedText = items.contains(value) ? value : items.first;

    return GestureDetector(
      onTap: () {
        _showSelectionBottomSheet(
          value: value,
          items: items,
          onChanged: onChanged,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: const Color(0xFF161619),
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white54,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedText,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white54,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showSelectionBottomSheet({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161619),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...items.map((item) {
                  final isSelected = item == value;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    tileColor: isSelected ? AppColors.primaryLime.withValues(alpha: 0.12) : Colors.transparent,
                    title: Text(
                      item,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.primaryLime : Colors.white,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryLime, size: 20)
                        : null,
                    onTap: () {
                      onChanged(item);
                      Navigator.of(ctx).pop();
                    },
                  );
                }),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
