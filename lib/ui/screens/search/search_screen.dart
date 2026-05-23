import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../providers/search_provider.dart';
import '../home/widgets/document_card.dart';
import '../../shared/empty_state.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      ref.read(searchProvider.notifier).search(_controller.text);
    });
  }

  void _onSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      ref.read(searchProvider.notifier).saveSearch(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding, AppSpacing.lg,
                  AppSpacing.screenPadding, AppSpacing.md),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBackgroundTertiary
                      : AppColors.lightBackgroundTertiary,
                  borderRadius: AppRadius.pillRadius,
                  border: Border.all(
                    color: _focusNode.hasFocus
                        ? accent.withOpacity(0.5)
                        : (isDark
                            ? AppColors.darkBorderMedium
                            : AppColors.lightBorderMedium),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Icon(
                      PhosphorIconsDuotone.magnifyingGlass,
                      size: 20,
                      color: _focusNode.hasFocus ? accent : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        onSubmitted: _onSubmitted,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search documents, content, folders...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    if (_controller.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _controller.clear();
                          ref.read(searchProvider.notifier).clearResults();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            PhosphorIconsDuotone.x,
                            size: 18,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),
            ),

            // Content
            Expanded(
              child: _controller.text.isEmpty
                  ? _buildRecentSearches(searchState, isDark, accent)
                  : _buildResults(searchState, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches(
      SearchState state, bool isDark, Color accent) {
    if (state.recentSearches.isEmpty) {
      return EmptyState(
        icon: PhosphorIconsDuotone.magnifyingGlass,
        title: 'Search everything',
        subtitle: 'Find documents by name, content, or tags.',
      );
    }

    return ListView(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      children: [
        Text(
          'RECENT SEARCHES',
          style: AppTextStyles.labelSmall.copyWith(
            color: isDark
                ? AppColors.darkTextTertiary
                : AppColors.lightTextTertiary,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...state.recentSearches.map((query) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: ListTile(
                dense: true,
                leading: Icon(
                  PhosphorIconsDuotone.clockCounterClockwise,
                  size: 18,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
                title: Text(
                  query,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                trailing: GestureDetector(
                  onTap: () {
                    ref
                        .read(searchProvider.notifier)
                        .deleteRecentSearch(query);
                  },
                  child: Icon(
                    PhosphorIconsDuotone.x,
                    size: 16,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                  ),
                ),
                onTap: () {
                  _controller.text = query;
                  ref.read(searchProvider.notifier).search(query);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.smRadius,
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildResults(SearchState state, bool isDark) {
    if (state.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.results.isEmpty) {
      return EmptyState(
        icon: PhosphorIconsDuotone.magnifyingGlass,
        title: 'No results found',
        subtitle: 'Try different keywords or check the spelling.',
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      children: [
        Text(
          '${state.results.length} result${state.results.length == 1 ? '' : 's'} for "${state.query}"',
          style: AppTextStyles.caption.copyWith(
            color: isDark
                ? AppColors.darkTextTertiary
                : AppColors.lightTextTertiary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...state.results.asMap().entries.map((entry) {
          final index = entry.key;
          final doc = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == state.results.length - 1
                  ? AppSpacing.bottomNavClearance
                  : AppSpacing.md,
            ),
            child: DocumentCard(
              document: doc,
              highlightQuery: state.query,
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
        }),
      ],
    );
  }
}
