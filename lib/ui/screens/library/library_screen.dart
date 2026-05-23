import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../providers/folders_provider.dart';
import '../../../providers/documents_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../domain/models/folder.dart';
import '../../shared/empty_state.dart';
import 'folder_detail_screen.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = ref.watch(settingsProvider).accentColor;
    final foldersAsync = ref.watch(foldersProvider);
    final docsAsync = ref.watch(documentsProvider);
    final totalDocs = docsAsync.valueOrNull?.length ?? 0;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding, AppSpacing.lg,
                    AppSpacing.screenPadding, AppSpacing.xxl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Library',
                      style: AppTextStyles.displayMedium.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        PhosphorIconsDuotone.sortAscending,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms),
              ),
            ),

            // Folders grid
            foldersAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Error: $e')),
              ),
              data: (folders) {
                if (folders.isEmpty && totalDocs == 0) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: PhosphorIconsDuotone.folders,
                      title: 'No folders yet',
                      subtitle:
                          'Upload a document and AI will organise it for you.',
                      actionLabel: 'Upload Document',
                      onAction: () {
                        ref
                            .read(documentsProvider.notifier)
                            .pickAndUploadFiles(multiple: true);
                      },
                    ),
                  );
                }

                // Add "All Files" card at the beginning
                final allItems = [null, ...folders]; // null = All Files card

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding, 0,
                      AppSpacing.screenPadding,
                      AppSpacing.bottomNavClearance),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1.0, // Better box size
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = allItems[index];

                        if (item == null) {
                          // "All Files" special card
                          return _AllFilesCard(
                            count: totalDocs,
                            accent: accent,
                            isDark: isDark,
                          )
                              .animate()
                              .fadeIn(duration: 350.ms)
                                .slideY(
                                  begin: 0.1,
                                  curve: Curves.easeOutCubic,
                                )
                                .scale(
                                  begin: const Offset(0.9, 0.9),
                                  duration: 350.ms,
                                  curve: Curves.easeOutBack,
                                );
                        }

                        final color =
                            AppColors.getFolderColor(item.colorName);
                        return _FolderGridCard(
                          folder: item,
                          color: color,
                          isDark: isDark,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    FolderDetailScreen(folder: item),
                              ),
                            );
                          },
                        )
                            .animate()
                            .fadeIn(
                              delay: (index * 60).ms,
                              duration: 350.ms,
                            )
                            .slideY(
                              begin: 0.1,
                              delay: (index * 60).ms,
                              curve: Curves.easeOutCubic,
                            )
                            .scale(
                              begin: const Offset(0.9, 0.9),
                              delay: (index * 60).ms,
                              duration: 400.ms,
                              curve: Curves.easeOutBack,
                            );
                      },
                      childCount: allItems.length,
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

class _AllFilesCard extends StatelessWidget {
  final int count;
  final Color accent;
  final bool isDark;

  const _AllFilesCard({
    required this.count,
    required this.accent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.xlRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkBackgroundSecondary.withOpacity(0.5)
                : AppColors.lightBackgroundSecondary.withOpacity(0.7),
            borderRadius: AppRadius.xlRadius,
            border: Border.all(
              color: accent.withOpacity(0.2),
              width: 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withOpacity(0.08),
                Colors.transparent,
              ],
            ),
          ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(PhosphorIconsDuotone.files, size: 36, color: accent),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'All Files',
                style: AppTextStyles.titleSmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$count files',
                style: AppTextStyles.caption.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);
  }
}

class _FolderGridCard extends StatelessWidget {
  final FolderModel folder;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _FolderGridCard({
    required this.folder,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Hero(
        tag: 'folder_hero_${folder.id}',
        child: ClipRRect(
          borderRadius: AppRadius.xlRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: color.withOpacity(isDark ? 0.08 : 0.15),
                borderRadius: AppRadius.xlRadius,
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(PhosphorIconsDuotone.folder, size: 36, color: color),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    folder.name,
                    style: AppTextStyles.titleSmall.copyWith(
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
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
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
