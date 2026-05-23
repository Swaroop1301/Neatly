import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../providers/documents_provider.dart';
import '../../../providers/folders_provider.dart';
import '../../../providers/ai_queue_provider.dart';
import '../../../providers/settings_provider.dart';
import 'widgets/ai_status_pill.dart';
import 'widgets/quick_stat_card.dart';
import 'widgets/document_card.dart';
import '../../shared/empty_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = ref.watch(settingsProvider).accentColor;
    final documentsAsync = ref.watch(documentsProvider);
    final foldersAsync = ref.watch(foldersProvider);
    final aiQueue = ref.watch(aiQueueProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        bottom: false,
        child: documentsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (documents) {
            return CustomScrollView(
              slivers: [
                // Custom header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenPadding, AppSpacing.lg,
                        AppSpacing.screenPadding, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getGreeting(),
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    documents.isEmpty
                                        ? 'Nothing uploaded yet.'
                                        : '${documents.where((d) => d.aiStatus == 'done').length} files sorted.',
                                    style: AppTextStyles.displayMedium.copyWith(
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Avatar circle
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accent.withOpacity(0.12),
                                border: Border.all(
                                  color: accent.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                PhosphorIconsDuotone.user,
                                size: 18,
                                color: accent,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 400.ms).slideY(
                            begin: -0.1, curve: Curves.easeOutCubic),
                      ],
                    ),
                  ),
                ),

                // AI Status Pill
                if (aiQueue.pendingCount > 0)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenPadding, AppSpacing.lg,
                          AppSpacing.screenPadding, 0),
                      child: AiStatusPill(
                        pendingCount: aiQueue.pendingCount,
                        accent: accent,
                      ),
                    ),
                  ),

                // Quick Stats Row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenPadding, AppSpacing.xxl,
                        AppSpacing.screenPadding, 0),
                    child: _QuickStatsRow(accent: accent),
                  ),
                ),

                // Folders Section
                foldersAsync.when(
                  loading: () => const SliverToBoxAdapter(child: SizedBox()),
                  error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
                  data: (folders) {
                    if (folders.isEmpty) {
                      return const SliverToBoxAdapter(child: SizedBox());
                    }
                    return SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                AppSpacing.screenPadding, AppSpacing.xxl,
                                AppSpacing.screenPadding, AppSpacing.md),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Folders',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                                Text(
                                  'See all',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 160,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.screenPadding),
                              itemCount: folders.length,
                              itemBuilder: (context, index) {
                                final folder = folders[index];
                                final color =
                                    AppColors.getFolderColor(folder.colorName);
                                return Container(
                                  width: 140,
                                  margin: const EdgeInsets.only(
                                      right: AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.12),
                                    borderRadius: AppRadius.xlRadius,
                                    border: Border.all(
                                      color: color.withOpacity(0.3),
                                      width: 0.5,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        PhosphorIconsDuotone.folder,
                                        size: 36,
                                        color: color,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            folder.name,
                                            style: AppTextStyles.titleSmall
                                                .copyWith(
                                              color: isDark
                                                  ? AppColors.darkTextPrimary
                                                  : AppColors.lightTextPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${folder.documentCount} files',
                                            style:
                                                AppTextStyles.caption.copyWith(
                                              color: isDark
                                                  ? AppColors.darkTextSecondary
                                                  : AppColors
                                                      .lightTextSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                                    .animate()
                                    .fadeIn(
                                      delay: (index * 80).ms,
                                      duration: 350.ms,
                                    )
                                    .slideX(
                                      begin: 0.2,
                                      delay: (index * 80).ms,
                                      curve: Curves.easeOutCubic,
                                    );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Recent Documents Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenPadding, AppSpacing.xxl,
                        AppSpacing.screenPadding, AppSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        if (documents.length > 5)
                          Text(
                            'View all',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: accent,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                if (documents.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: PhosphorIconsDuotone.fileArrowUp,
                      title: 'No documents yet',
                      subtitle:
                          'Upload a PDF, Word, or PowerPoint file to get started.',
                      actionLabel: 'Upload File',
                      onAction: () {
                        ref
                            .read(documentsProvider.notifier)
                            .pickAndUploadFiles(multiple: true);
                      },
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= documents.length) return null;
                        final doc = documents[index];
                        return Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.screenPadding,
                            0,
                            AppSpacing.screenPadding,
                            index == documents.length - 1
                                ? AppSpacing.bottomNavClearance
                                : AppSpacing.md,
                          ),
                          child: DocumentCard(
                            document: doc,
                            onTap: () {
                              final id = doc.id;
                              if (id == null) return;
                              context.push('/document/$id');
                            },
                            onDelete: () {
                              ref
                                  .read(documentsProvider.notifier)
                                  .deleteDocument(doc.id!);
                            },
                            onFavouriteToggle: () {
                              ref
                                  .read(documentsProvider.notifier)
                                  .toggleFavourite(doc.id!);
                            },
                          )
                              .animate()
                              .fadeIn(
                                delay: (index * 40).ms,
                                duration: 350.ms,
                              )
                              .slideY(
                                begin: 0.1,
                                delay: (index * 40).ms,
                                curve: Curves.easeOutCubic,
                              ),
                        );
                      },
                      childCount: documents.length,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _QuickStatsRow extends ConsumerWidget {
  final Color accent;

  const _QuickStatsRow({required this.accent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(documentsProvider);
    final folders = ref.watch(foldersProvider);

    final totalFiles = db.valueOrNull?.length ?? 0;
    final totalFolders = folders.valueOrNull?.length ?? 0;
    final thisWeek = db.valueOrNull
            ?.where((d) =>
                d.uploadedAt.isAfter(
                    DateTime.now().subtract(const Duration(days: 7))))
            .length ??
        0;

    return Row(
      children: [
        Expanded(
          child: QuickStatCard(
            value: '$totalFiles',
            label: 'Total files',
          ).animate().fadeIn(duration: 350.ms).slideY(
                begin: 0.2,
                curve: Curves.easeOutCubic,
              ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: QuickStatCard(
            value: '$totalFolders',
            label: 'Folders',
          )
              .animate()
              .fadeIn(delay: 80.ms, duration: 350.ms)
              .slideY(
                begin: 0.2,
                delay: 80.ms,
                curve: Curves.easeOutCubic,
              ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: QuickStatCard(
            value: '$thisWeek',
            label: 'This week',
          )
              .animate()
              .fadeIn(delay: 160.ms, duration: 350.ms)
              .slideY(
                begin: 0.2,
                delay: 160.ms,
                curve: Curves.easeOutCubic,
              ),
        ),
      ],
    );
  }
}
