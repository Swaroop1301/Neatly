import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../domain/models/folder.dart';
import '../../../providers/documents_provider.dart';
import '../home/widgets/document_card.dart';
import '../../shared/empty_state.dart';
import '../../shared/glass_container.dart';

class FolderDetailScreen extends ConsumerStatefulWidget {
  final FolderModel folder;

  const FolderDetailScreen({super.key, required this.folder});

  @override
  ConsumerState<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends ConsumerState<FolderDetailScreen> {
  String? _typeFilter;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = AppColors.getFolderColor(widget.folder.colorName);
    final docsAsync = ref.watch(folderDocumentsProvider(widget.folder.id!));

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          // Colored header
          SliverToBoxAdapter(
            child: Hero(
              tag: 'folder_hero_${widget.folder.id}',
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.18),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Stack(
                    children: [
                      // Radial glow
                      Center(
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                color.withOpacity(0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Content
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            Icon(
                              PhosphorIconsDuotone.folder,
                              size: 56,
                              color: color,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.folder.name,
                              style: AppTextStyles.titleLarge.copyWith(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.folder.documentCount} documents',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Back button
                      Positioned(
                        top: 8,
                        left: 12,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: GlassContainer(
                            padding: const EdgeInsets.all(8),
                            borderRadius: AppRadius.pill,
                            child: Icon(
                              PhosphorIconsDuotone.arrowLeft,
                              size: 20,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Filter chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding, AppSpacing.lg,
                  AppSpacing.screenPadding, AppSpacing.md),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      isActive: _typeFilter == null,
                      onTap: () => setState(() => _typeFilter = null),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'PDF',
                      isActive: _typeFilter == 'pdf',
                      onTap: () => setState(() => _typeFilter = 'pdf'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'DOCX',
                      isActive: _typeFilter == 'docx',
                      onTap: () => setState(() => _typeFilter = 'docx'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'PPTX',
                      isActive: _typeFilter == 'pptx',
                      onTap: () => setState(() => _typeFilter = 'pptx'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Document list
          docsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
            data: (docs) {
              final filtered = _typeFilter != null
                  ? docs.where((d) => d.fileType == _typeFilter).toList()
                  : docs;

              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: PhosphorIconsDuotone.fileMagnifyingGlass,
                    title: 'No documents',
                    subtitle: 'This folder is empty.',
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final doc = filtered[index];
                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.screenPadding,
                        0,
                        AppSpacing.screenPadding,
                        index == filtered.length - 1
                            ? AppSpacing.bottomNavClearance
                            : AppSpacing.md,
                      ),
                      child: DocumentCard(
                        document: doc,
                        onTap: () {
                          if (doc.id != null) {
                            context.push('/document/${doc.id}');
                          }
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
                  childCount: filtered.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? accent
              : (isDark
                  ? AppColors.darkBackgroundTertiary
                  : AppColors.lightBackgroundTertiary),
          borderRadius: AppRadius.pillRadius,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isActive
                ? Colors.white
                : (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary),
          ),
        ),
      ),
    );
  }
}
