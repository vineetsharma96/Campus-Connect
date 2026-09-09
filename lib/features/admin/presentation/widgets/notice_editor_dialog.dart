import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../notices/domain/notice_models.dart';
import '../../domain/admin_models.dart';

class NoticeEditorDialog extends StatefulWidget {
  final NoticeItem? existingNotice;
  final Future<bool> Function(NoticePayload payload) onSave;

  const NoticeEditorDialog({
    super.key,
    this.existingNotice,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    NoticeItem? existingNotice,
    required Future<bool> Function(NoticePayload payload) onSave,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => NoticeEditorDialog(
        existingNotice: existingNotice,
        onSave: onSave,
      ),
    );
  }

  @override
  State<NoticeEditorDialog> createState() => _NoticeEditorDialogState();
}

class _NoticeEditorDialogState extends State<NoticeEditorDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late NoticeCategory _category;
  late bool _isImportant;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final NoticeItem? n = widget.existingNotice;
    _titleController = TextEditingController(text: n?.title ?? '');
    _contentController = TextEditingController(text: n?.content ?? '');
    _category = n?.category ?? NoticeCategory.academic;
    _isImportant = n?.isImportant ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final NoticePayload payload = NoticePayload(
      id: widget.existingNotice?.id,
      title: _titleController.text,
      content: _contentController.text,
      category: _category,
      isImportant: _isImportant,
    );

    setState(() => _isSaving = true);
    final bool success = await widget.onSave(payload);
    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to publish notice. Check admin rights.'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isEditing = widget.existingNotice != null;

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
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        isEditing ? 'Edit Official Notice' : 'Publish Notice',
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
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Notice Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (String? val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Title is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<NoticeCategory>(
                    initialValue: _category == NoticeCategory.all
                        ? NoticeCategory.academic
                        : _category,
                    decoration: const InputDecoration(
                      labelText: 'Notice Category',
                      border: OutlineInputBorder(),
                    ),
                    items: NoticeCategory.values
                        .where((NoticeCategory c) => c != NoticeCategory.all)
                        .map((NoticeCategory c) =>
                            DropdownMenuItem<NoticeCategory>(
                              value: c,
                              child: Text(c.label),
                            ))
                        .toList(),
                    onChanged: (NoticeCategory? c) {
                      if (c != null) {
                        setState(() => _category = c);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _contentController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Notice Content & Directives',
                      border: OutlineInputBorder(),
                    ),
                    validator: (String? val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Content is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SwitchListTile(
                    title: const Text(
                      'Mark as High Priority',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    subtitle:
                        const Text('Pins notice with critical red alert card'),
                    value: _isImportant,
                    activeThumbColor: AppColors.errorRed,
                    onChanged: (bool val) => setState(() => _isImportant = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: AppSpacing.md),
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
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isEditing
                                  ? 'Save Changes'
                                  : 'Broadcast to Campus',
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
