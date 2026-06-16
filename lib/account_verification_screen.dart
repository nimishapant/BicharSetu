import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'model/user_model.dart';
import 'repo/auth_service.dart';

const Color _gold = Color(0xFFC4A052);
const Color _maroon = Color(0xFF7A2035);
const Color _bg = Color(0xFFECECEC);
const Color _surface = Color(0xFFF5F5F5);
const Color _fieldFill = Color(0xFFFAFAFA);
const Color _textDark = Color(0xFF2A2A2A);
const Color _textMid = Color(0xFF8A8A8A);
const Color _border = Color(0xFFD8D8D8);

enum _VerificationCategory { account, profession, both }

enum _DocumentType { passport, citizenNid, drivingLicense }

class AccountVerificationScreen extends StatefulWidget {
  const AccountVerificationScreen({super.key});

  @override
  State<AccountVerificationScreen> createState() =>
      _AccountVerificationScreenState();
}

class _AccountVerificationScreenState extends State<AccountVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();

  _VerificationCategory _category = _VerificationCategory.account;
  _DocumentType _documentType = _DocumentType.passport;
  File? _frontDocument;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final UserModel? user = await AuthService().getCurrentUserModel();
      if (user != null) {
        _fullNameCtrl.text = user.username;
        _emailCtrl.text = user.email;
      }
    } catch (_) {
      // Keep empty defaults.
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _contactCtrl.dispose();
    _countryCtrl.dispose();
    _stateCtrl.dispose();
    _cityCtrl.dispose();
    _zipCtrl.dispose();
    super.dispose();
  }

  String get _categoryPrice {
    switch (_category) {
      case _VerificationCategory.account:
        return 'Nrs149';
      case _VerificationCategory.profession:
        return 'Nrs199';
      case _VerificationCategory.both:
        return 'Nrs348';
    }
  }

  Future<void> _pickDocument() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (picked == null || !mounted) return;
    setState(() => _frontDocument = File(picked.path));
  }

  void _onSaveAndContinue() {
    if (!_formKey.currentState!.validate()) return;
    if (_frontDocument == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload the front side of your document.'),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _VerificationStepTwoScreen(
          category: _category,
          price: _categoryPrice,
          fullName: _fullNameCtrl.text.trim(),
        ),
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
            _VerificationAppBar(onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: _gold),
                    )
                  : Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _SectionCard(
                              step: '00',
                              title: 'Verification Category',
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _CategoryCard(
                                      icon: Icons.person_outline_rounded,
                                      label: 'Account',
                                      price: 'Nrs149',
                                      selected: _category ==
                                          _VerificationCategory.account,
                                      onTap: () => setState(() =>
                                          _category =
                                              _VerificationCategory.account),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _CategoryCard(
                                      icon: Icons.work_outline_rounded,
                                      label: 'Profession',
                                      price: 'Nrs199',
                                      selected: _category ==
                                          _VerificationCategory.profession,
                                      onTap: () => setState(() =>
                                          _category =
                                              _VerificationCategory.profession),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _CategoryCard(
                                      icon: Icons.layers_outlined,
                                      label: 'Both',
                                      price: 'Nrs348',
                                      selected: _category ==
                                          _VerificationCategory.both,
                                      onTap: () => setState(() =>
                                          _category =
                                              _VerificationCategory.both),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            _SectionCard(
                              step: '01',
                              title: 'Identity Details',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FormField(
                                    label: 'FULL NAME *',
                                    controller: _fullNameCtrl,
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Required'
                                            : null,
                                  ),
                                  const SizedBox(height: 14),
                                  _FormField(
                                    label: 'EMAIL (READ ONLY)',
                                    controller: _emailCtrl,
                                    readOnly: true,
                                    fillColor: const Color(0xFFEFEFEF),
                                  ),
                                  const SizedBox(height: 14),
                                  _FormField(
                                    label: 'CONTACT NUMBER *',
                                    controller: _contactCtrl,
                                    keyboardType: TextInputType.phone,
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Required'
                                            : null,
                                  ),
                                  const SizedBox(height: 18),
                                  const Text(
                                    'RESIDENTIAL ADDRESS:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: _maroon,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _FormField(
                                          label: 'COUNTRY *',
                                          controller: _countryCtrl,
                                          validator: (v) =>
                                              (v == null || v.trim().isEmpty)
                                                  ? 'Required'
                                                  : null,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _FormField(
                                          label: 'STATE *',
                                          controller: _stateCtrl,
                                          validator: (v) =>
                                              (v == null || v.trim().isEmpty)
                                                  ? 'Required'
                                                  : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _FormField(
                                          label: 'CITY *',
                                          controller: _cityCtrl,
                                          validator: (v) =>
                                              (v == null || v.trim().isEmpty)
                                                  ? 'Required'
                                                  : null,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _FormField(
                                          label: 'ZIP CODE',
                                          controller: _zipCtrl,
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            _SectionCard(
                              step: '02',
                              title: 'Identity Documents',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        _DocTypeChip(
                                          label: 'Passport',
                                          selected: _documentType ==
                                              _DocumentType.passport,
                                          onTap: () => setState(() =>
                                              _documentType =
                                                  _DocumentType.passport),
                                        ),
                                        const SizedBox(width: 8),
                                        _DocTypeChip(
                                          label: 'Citizen/NID',
                                          selected: _documentType ==
                                              _DocumentType.citizenNid,
                                          onTap: () => setState(() =>
                                              _documentType =
                                                  _DocumentType.citizenNid),
                                        ),
                                        const SizedBox(width: 8),
                                        _DocTypeChip(
                                          label: 'Driving License',
                                          selected: _documentType ==
                                              _DocumentType.drivingLicense,
                                          onTap: () => setState(() =>
                                              _documentType =
                                                  _DocumentType.drivingLicense),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'FRONT SIDE *',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: _maroon,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _DocumentUploadBox(
                                    file: _frontDocument,
                                    onTap: _pickDocument,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            _BottomActionBar(
              onCancel: () => Navigator.of(context).pop(),
              onContinue: _onSaveAndContinue,
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationStepTwoScreen extends StatelessWidget {
  const _VerificationStepTwoScreen({
    required this.category,
    required this.price,
    required this.fullName,
  });

  final _VerificationCategory category;
  final String price;
  final String fullName;

  String get _categoryLabel {
    switch (category) {
      case _VerificationCategory.account:
        return 'Account';
      case _VerificationCategory.profession:
        return 'Profession';
      case _VerificationCategory.both:
        return 'Both';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _VerificationAppBar(
              onBack: () => Navigator.of(context).pop(),
              stepLabel: 'STEP 2 OF 2',
              title: 'REVIEW & SUBMIT',
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Review & Submit',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _ReviewRow(label: 'Applicant', value: fullName),
                      _ReviewRow(label: 'Category', value: _categoryLabel),
                      _ReviewRow(label: 'Amount', value: price),
                      const SizedBox(height: 16),
                      Text(
                        'Your verification request will be reviewed within 3–5 business days.',
                        style: TextStyle(
                          fontSize: 13,
                          color: _textMid.withValues(alpha: 0.95),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _BottomActionBar(
              cancelLabel: 'Back',
              continueLabel: 'SUBMIT REQUEST',
              onCancel: () => Navigator.of(context).pop(),
              onContinue: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: _gold,
                    content: const Text(
                      'Verification request submitted successfully!',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _textMid,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationAppBar extends StatelessWidget {
  const _VerificationAppBar({
    required this.onBack,
    this.stepLabel = 'STEP 1 OF 2',
    this.title = 'ACCOUNT IDENTITY',
  });

  final VoidCallback onBack;
  final String stepLabel;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: _textDark,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  stepLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _maroon,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _textMid,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.step,
    required this.title,
    required this.child,
  });

  final String step;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _gold.withValues(alpha: 0.5)),
                ),
                child: Text(
                  step,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _gold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: _fieldFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _gold : _border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? _maroon : _textMid, size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? _maroon : _textMid,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? _textDark : _textMid,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    this.validator,
    this.readOnly = false,
    this.keyboardType,
    this.fillColor,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool readOnly;
  final TextInputType? keyboardType;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _maroon,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _textDark,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor ?? _fieldFill,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _gold, width: 1.4),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}

class _DocTypeChip extends StatelessWidget {
  const _DocTypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _gold : _fieldFill,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? _gold : _border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : _textMid,
          ),
        ),
      ),
    );
  }
}

class _DocumentUploadBox extends StatelessWidget {
  const _DocumentUploadBox({required this.file, required this.onTap});

  final File? file;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _fieldFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _border,
            width: 1.2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: file != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(file!, fit: BoxFit.cover),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _gold.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_camera_outlined,
                      color: _gold,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tap to upload front side',
                    style: TextStyle(
                      fontSize: 13,
                      color: _textMid.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.onCancel,
    required this.onContinue,
    this.cancelLabel = 'Cancel',
    this.continueLabel = 'SAVE & CONTINUE',
  });

  final VoidCallback onCancel;
  final VoidCallback onContinue;
  final String cancelLabel;
  final String continueLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _textDark,
                  side: const BorderSide(color: _border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  cancelLabel,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: FilledButton(
                onPressed: onContinue,
                style: FilledButton.styleFrom(
                  backgroundColor: _gold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  continueLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
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
