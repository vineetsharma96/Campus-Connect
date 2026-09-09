import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../academic/domain/academic_models.dart';
import '../../domain/admin_models.dart';

class FacultyEditorDialog extends StatefulWidget {
  final FacultyMember? existingFaculty;
  final Future<bool> Function(FacultyPayload payload) onSave;

  const FacultyEditorDialog({
    super.key,
    this.existingFaculty,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    FacultyMember? existingFaculty,
    required Future<bool> Function(FacultyPayload payload) onSave,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FacultyEditorDialog(
        existingFaculty: existingFaculty,
        onSave: onSave,
      ),
    );
  }

  @override
  State<FacultyEditorDialog> createState() => _FacultyEditorDialogState();
}

class _FacultyEditorDialogState extends State<FacultyEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _designationController;
  late final TextEditingController _deptController;
  late final TextEditingController _emailController;
  late final TextEditingController _officeController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final f = widget.existingFaculty;
    _nameController = TextEditingController(text: f?.fullName ?? '');
    _designationController = TextEditingController(text: f?.designation ?? '');
    _deptController = TextEditingController(text: f?.department ?? '');
    _emailController = TextEditingController(text: f?.email ?? '');
    _officeController = TextEditingController(text: f?.officeLocation ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _designationController.dispose();
    _deptController.dispose();
    _emailController.dispose();
    _officeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final payload = FacultyPayload(
      id: widget.existingFaculty?.id,
      fullName: _nameController.text,
      designation: _designationController.text,
      department: _deptController.text,
      email: _emailController.text,
      officeLocation: _officeController.text,
    );

    setState(() => _isSaving = true);
    final success = await widget.onSave(payload);
    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existingFaculty != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing
                            ? 'Edit Faculty Record'
                            : 'Add Faculty Member',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Dr. John Doe',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => (val == null || val.trim().isEmpty)
                        ? 'Name required'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _designationController,
                    decoration: const InputDecoration(
                      labelText: 'Designation',
                      hintText: 'Associate Professor',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => (val == null || val.trim().isEmpty)
                        ? 'Designation required'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _deptController,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      hintText: 'Computer Science',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => (val == null || val.trim().isEmpty)
                        ? 'Department required'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Official Email',
                      hintText: 'faculty@campus.edu',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => (val == null || val.trim().isEmpty)
                        ? 'Email required'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _officeController,
                    decoration: const InputDecoration(
                      labelText: 'Cabin / Office Location',
                      hintText: 'Block B, Cabin 204',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => (val == null || val.trim().isEmpty)
                        ? 'Office location required'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _isSaving ? null : _submit,
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              isEditing
                                  ? 'Update Directory'
                                  : 'Register Faculty',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
