import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../academic/domain/academic_hierarchy_models.dart';

final mentorNoticesProvider =
    FutureProvider<List<MentorNoticeItem>>((ref) async {
  final client = Supabase.instance.client;
  final response = await client
      .from('mentor_notices')
      .select('id, title, message, created_at')
      .order('created_at', ascending: false);

  return (response as List)
      .map((j) => MentorNoticeItem.fromJson(j as Map<String, dynamic>))
      .toList();
});

class MentorNoticesScreen extends ConsumerWidget {
  const MentorNoticesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticesAsync = ref.watch(mentorNoticesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentor Advisory Desk',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: noticesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text('Unable to load advisory notices: $err')),
        data: (notices) {
          if (notices.isEmpty) {
            return const Center(
              child: Text('No mentor directives published for your batch.'),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(mentorNoticesProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: notices.length,
              itemBuilder: (context, index) {
                final n = notices[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                        color: AppColors.secondaryTeal.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.school_rounded,
                              size: 16, color: AppColors.secondaryTeal),
                          const SizedBox(width: 6),
                          const Text(
                            'MENTOR DIRECTIVE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.secondaryTeal,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${n.createdAt.day}/${n.createdAt.month}/${n.createdAt.year}',
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(n.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(n.message, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
