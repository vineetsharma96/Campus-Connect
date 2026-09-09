import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../auth/domain/auth_state_model.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class SyllabusItem {
  final String id;
  final String title;
  final String subjectName;
  final String documentUrl;

  const SyllabusItem({
    required this.id,
    required this.title,
    required this.subjectName,
    required this.documentUrl,
  });

  factory SyllabusItem.fromJson(Map<String, dynamic> json) {
    final sub = json['subjects'] as Map<String, dynamic>? ?? {};
    return SyllabusItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Syllabus',
      subjectName: sub['name'] as String? ?? 'Core Course',
      documentUrl: json['document_url'] as String? ?? '',
    );
  }
}

final studentSyllabusProvider = FutureProvider<List<SyllabusItem>>((ref) async {
  final authState = ref.watch(authControllerProvider);
  if (authState is! Authenticated) return [];

  final client = Supabase.instance.client;
  final response = await client
      .from('syllabi')
      .select('id, title, document_url, subjects(name)')
      .order('title');

  return (response as List)
      .map((j) => SyllabusItem.fromJson(j as Map<String, dynamic>))
      .toList();
});

class CourseSyllabusScreen extends ConsumerWidget {
  const CourseSyllabusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syllabusAsync = ref.watch(studentSyllabusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrolled Course Syllabus',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: syllabusAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Unable to load syllabus: $err')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
                child:
                    Text('No syllabus available for your course & semester.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ListTile(
                  leading: const Icon(Icons.description_rounded,
                      color: AppColors.primaryBlue),
                  title: Text(item.title,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(item.subjectName),
                  trailing: IconButton(
                    icon: const Icon(Icons.download_rounded,
                        color: AppColors.primaryBlue),
                    onPressed: () async {
                      final uri = Uri.tryParse(item.documentUrl);
                      if (uri != null && await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
