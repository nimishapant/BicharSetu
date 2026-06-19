import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'repo/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color _accent = Color(0xFF6A3DE8);
const Color _redAccent = Color(0xFFE53935);
const Color _bg = Color(0xFFF0F0F0);
const Color _surface = Colors.white;
const Color _textDark = Color(0xFF1A1A1A);
const Color _textMid = Color(0xFF8A8A8A);
const Color _pillBg = Color(0xFFE8E8E8);
const Color _border = Color(0xFFE0E0E0);

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _aboutCtrl = TextEditingController();
  final _professionCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _birthdayCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  static const int _aboutMaxLength = 150;
  static const int _maxGalleryPhotos = 4;

  bool _isLoading = false;
  bool _isFetching = true;
  bool _isUploadingPhoto = false;
  bool _isUploadingCoverPhoto = false;
  bool _isUploadingGallery = false;
  String _profilePhotoUrl = '';
  String _coverPhotoUrl = '';
  List<String> _galleryPhotos = [];

  @override
  void initState() {
    super.initState();
    _aboutCtrl.addListener(() => setState(() {}));
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = await AuthService().getCurrentUserModel();
      if (user != null) {
        _usernameCtrl.text = user.username;
        _emailCtrl.text = user.email;
        _aboutCtrl.text = user.aboutMe;
        _professionCtrl.text = user.profession;
        _locationCtrl.text = user.location;
        _birthdayCtrl.text = user.birthday;
        _websiteCtrl.text = user.website;
        _profilePhotoUrl = user.profilePhoto;
        _coverPhotoUrl = user.coverPhoto;
        _galleryPhotos = List<String>.from(user.galleryPhotos);
      }
    } catch (_) {
      // Fallback to empty fields.
    } finally {
      if (mounted) {
        setState(() => _isFetching = false);
      }
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _aboutCtrl.dispose();
    _professionCtrl.dispose();
    _locationCtrl.dispose();
    _birthdayCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  Future<void> _onUpdateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await AuthService().updateUserProfile(
        username: _usernameCtrl.text,
        email: _emailCtrl.text,
        aboutMe: _aboutCtrl.text,
        profession: _professionCtrl.text,
        location: _locationCtrl.text,
        birthday: _birthdayCtrl.text,
        website: _websiteCtrl.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _accent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                'Profile updated successfully!',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Failed to update profile.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<ImageSource?> _chooseImageSource() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadProfilePhoto() async {
    if (_isUploadingPhoto) return;
    final source = await _chooseImageSource();
    if (source == null || !mounted) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1080,
    );
    if (picked == null || !mounted) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final photoUrl = await AuthService().uploadProfilePhotoFromXFile(picked);
      if (!mounted) return;
      setState(() => _profilePhotoUrl = photoUrl);
      _showSnack('Profile photo updated');
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to upload photo: $e');
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _pickAndUploadCoverPhoto() async {
    if (_isUploadingCoverPhoto) return;
    final source = await _chooseImageSource();
    if (source == null || !mounted) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (picked == null || !mounted) return;

    setState(() => _isUploadingCoverPhoto = true);
    try {
      final coverUrl = await AuthService().uploadCoverPhotoFromXFile(picked);
      if (!mounted) return;
      setState(() => _coverPhotoUrl = coverUrl);
      _showSnack('Cover photo updated');
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to upload cover: $e');
    } finally {
      if (mounted) setState(() => _isUploadingCoverPhoto = false);
    }
  }

  Future<void> _pickAndUploadGalleryPhoto() async {
    if (_isUploadingGallery || _galleryPhotos.length >= _maxGalleryPhotos) return;
    final source = await _chooseImageSource();
    if (source == null || !mounted) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1080,
    );
    if (picked == null || !mounted) return;

    setState(() => _isUploadingGallery = true);
    try {
      final url = await AuthService().uploadGalleryPhotoFromXFile(picked);
      if (!mounted) return;
      setState(() => _galleryPhotos = [..._galleryPhotos, url]);
      _showSnack('Photo added');
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to upload photo: $e');
    } finally {
      if (mounted) setState(() => _isUploadingGallery = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
        children: [
          _ProfileEditAppBar(),
          Expanded(
            child: _isFetching
                ? const Center(
                    child: CircularProgressIndicator(color: _accent),
                  )
                : Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ProfileHeroSection(
                            coverPhotoUrl: _coverPhotoUrl,
                            profilePhotoUrl: _profilePhotoUrl,
                            isUploadingCover: _isUploadingCoverPhoto,
                            isUploadingProfile: _isUploadingPhoto,
                            onCoverTap: _pickAndUploadCoverPhoto,
                            onProfileTap: _pickAndUploadProfilePhoto,
                          ),
                          _GalleryStrip(
                            photos: _galleryPhotos,
                            isUploading: _isUploadingGallery,
                            maxPhotos: _maxGalleryPhotos,
                            onAddTap: _pickAndUploadGalleryPhoto,
                          ),
                          const SizedBox(height: 16),
                          const _SectionPill(label: 'Personal Information'),
                          const SizedBox(height: 14),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                _AboutMeCard(
                                  controller: _aboutCtrl,
                                  maxLength: _aboutMaxLength,
                                ),
                                const SizedBox(height: 14),
                                _BasicDetailsCard(
                                  usernameCtrl: _usernameCtrl,
                                  emailCtrl: _emailCtrl,
                                  professionCtrl: _professionCtrl,
                                  locationCtrl: _locationCtrl,
                                  birthdayCtrl: _birthdayCtrl,
                                  websiteCtrl: _websiteCtrl,
                                ),
                                const SizedBox(height: 24),
                                _UpdateButton(
                                  onTap: _onUpdateProfile,
                                  isLoading: _isLoading,
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
        ),
      ),
    );
  }
}

class _ProfileEditAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: _textDark,
          ),
          const Expanded(
            child: Text(
              'ProfileEdit',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded, color: _textDark, size: 26),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.auto_awesome, color: _redAccent, size: 24),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeroSection extends StatelessWidget {
  const _ProfileHeroSection({
    required this.coverPhotoUrl,
    required this.profilePhotoUrl,
    required this.isUploadingCover,
    required this.isUploadingProfile,
    required this.onCoverTap,
    required this.onProfileTap,
  });

  final String coverPhotoUrl;
  final String profilePhotoUrl;
  final bool isUploadingCover;
  final bool isUploadingProfile;
  final VoidCallback onCoverTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 194,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: onCoverTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4D0E8),
                    image: coverPhotoUrl.isEmpty
                        ? null
                        : DecorationImage(
                            image: NetworkImage(coverPhotoUrl),
                            fit: BoxFit.cover,
                          ),
                  ),
                  foregroundDecoration: coverPhotoUrl.isEmpty
                      ? null
                      : BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.05),
                              Colors.black.withValues(alpha: 0.25),
                            ],
                          ),
                        ),
                ),
                if (isUploadingCover)
                  const CircularProgressIndicator(color: Colors.white),
                if (!isUploadingCover)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        color: coverPhotoUrl.isEmpty
                            ? Colors.white.withValues(alpha: 0.9)
                            : Colors.white,
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coverPhotoUrl.isEmpty ? 'Add cover photo' : 'Change cover',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            bottom: 0,
            child: GestureDetector(
              onTap: onProfileTap,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFEDE8FB),
                      border: Border.all(color: _surface, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _buildAvatar(),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: _accent,
                        shape: BoxShape.circle,
                      ),
                      child: isUploadingProfile
                          ? const Padding(
                              padding: EdgeInsets.all(6),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 15,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (profilePhotoUrl.isEmpty) {
      return const Icon(Icons.person_rounded, size: 48, color: Color(0xFFB0A8CC));
    }
    return ClipOval(
      child: Image.network(
        profilePhotoUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.person_rounded,
          size: 48,
          color: Color(0xFFB0A8CC),
        ),
      ),
    );
  }
}

class _GalleryStrip extends StatelessWidget {
  const _GalleryStrip({
    required this.photos,
    required this.isUploading,
    required this.maxPhotos,
    required this.onAddTap,
  });

  final List<String> photos;
  final bool isUploading;
  final int maxPhotos;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    final slots = maxPhotos;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: SizedBox(
        height: 84,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: slots,
          separatorBuilder: (context, index) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            if (index < photos.length) {
              return _GalleryTile(imageUrl: photos[index]);
            }
            final isAddSlot = index == photos.length;
            return _GalleryTile(
              isAdd: isAddSlot,
              isLoading: isAddSlot && isUploading,
              onTap: isAddSlot && photos.length < maxPhotos ? onAddTap : null,
            );
          },
        ),
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({
    this.imageUrl,
    this.isAdd = false,
    this.isLoading = false,
    this.onTap,
  });

  final String? imageUrl;
  final bool isAdd;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border, width: 1.2),
          image: imageUrl != null
              ? DecorationImage(
                  image: NetworkImage(imageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: isAdd
            ? Center(
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        Icons.add_photo_alternate_outlined,
                        color: _textMid.withValues(alpha: 0.8),
                        size: 28,
                      ),
              )
            : null,
      ),
    );
  }
}

class _SectionPill extends StatelessWidget {
  const _SectionPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _pillBg,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A4A4A),
          ),
        ),
      ),
    );
  }
}

class _AboutMeCard extends StatelessWidget {
  const _AboutMeCard({
    required this.controller,
    required this.maxLength,
  });

  final TextEditingController controller;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.drag_handle_rounded, color: Colors.amber[700], size: 22),
              const SizedBox(width: 8),
              const Text(
                'About Me',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const Spacer(),
              Text(
                '${controller.text.length}/$maxLength',
                style: const TextStyle(
                  fontSize: 12,
                  color: _textMid,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: controller,
            maxLines: 3,
            maxLength: maxLength,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            style: const TextStyle(fontSize: 14.5, color: _textDark),
            decoration: const InputDecoration(
              hintText: 'Tell Us About Yourself Msg',
              hintStyle: TextStyle(color: _textMid, fontSize: 14),
              border: InputBorder.none,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: _border),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: _accent, width: 1.4),
              ),
              counterText: '',
              contentPadding: EdgeInsets.only(bottom: 8),
            ),
          ),
        ],
      ),
    );
  }
}

class _BasicDetailsCard extends StatelessWidget {
  const _BasicDetailsCard({
    required this.usernameCtrl,
    required this.emailCtrl,
    required this.professionCtrl,
    required this.locationCtrl,
    required this.birthdayCtrl,
    required this.websiteCtrl,
  });

  final TextEditingController usernameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController professionCtrl;
  final TextEditingController locationCtrl;
  final TextEditingController birthdayCtrl;
  final TextEditingController websiteCtrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline_rounded, color: _accent.withValues(alpha: 0.85), size: 22),
              const SizedBox(width: 8),
              const Text(
                'Basic Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _DetailField(
            label: 'USERNAME',
            controller: usernameCtrl,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Username cannot be empty' : null,
          ),
          _DetailField(
            label: 'EMAIL ADDRESS',
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email cannot be empty';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          _DetailField(
            label: 'PROFESSION',
            controller: professionCtrl,
            hint: 'e.g. Doctor, Artist, Writer',
          ),
          _DetailField(
            label: 'LOCATION',
            controller: locationCtrl,
            hint: 'e.g. Kathmandu, Nepal',
          ),
          _DetailField(
            label: 'BIRTHDAY',
            controller: birthdayCtrl,
            hint: 'e.g. 15 January 2000',
          ),
          _DetailField(
            label: 'WEBSITE',
            controller: websiteCtrl,
            hint: 'e.g. https://yourwebsite.com',
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField({
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.validator,
    this.showDivider = true,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _textMid,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
            fontSize: 15,
            color: _textDark,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: _textMid.withValues(alpha: 0.75),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.only(bottom: 10),
          ),
        ),
        if (showDivider) const Divider(height: 1, color: _border),
      ],
    );
  }
}

class _UpdateButton extends StatelessWidget {
  const _UpdateButton({required this.onTap, this.isLoading = false});
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: isLoading ? null : onTap,
        style: FilledButton.styleFrom(
          backgroundColor: _accent,
          disabledBackgroundColor: _accent.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
              )
            : const Text(
                'Save Profile',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}
