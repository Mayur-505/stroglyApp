import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../models/category_workout_models.dart';
import '../widgets/category_workout_tile.dart';
import '../widgets/workout_customization_flow_sheet.dart';

class WorkoutSearchScreen extends StatefulWidget {
  const WorkoutSearchScreen({super.key});

  @override
  State<WorkoutSearchScreen> createState() => _WorkoutSearchScreenState();
}

class _WorkoutSearchScreenState extends State<WorkoutSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _activeSearch = '';
  List<String> _bodyFocusTags = [];
  List<String> _hotTopicTags = [];

  List<CategoryWorkoutItem> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchTags();
    _searchController.addListener(() {
      final text = _searchController.text.trim();
      if (text != _activeSearch) {
        setState(() {
          _activeSearch = text;
        });
        if (text.isNotEmpty) {
          _performSearch(text);
        } else {
          setState(() {
            _searchResults = [];
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTags() async {
    final res = await ApiClient.instance.get(ApiConstants.searchTags);
    if (!mounted) return;

    if (res.isOk && res.data is Map) {
      final data = res.data as Map<String, dynamic>;
      final bf = data['bodyFocusTags'];
      final ht = data['hotTopicTags'];

      setState(() {
        if (bf is List && bf.isNotEmpty) {
          _bodyFocusTags = bf.map((item) {
            if (item is Map) return item['name']?.toString() ?? '';
            return item.toString();
          }).where((s) => s.isNotEmpty).toList();
        }
        if (ht is List && ht.isNotEmpty) {
          _hotTopicTags = ht.map((item) {
            if (item is Map) return item['name']?.toString() ?? '';
            return item.toString();
          }).where((s) => s.isNotEmpty).toList();
        }
      });
    }
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isSearching = true);
    final res = await ApiClient.instance.get(
      ApiConstants.searchWorkouts,
      queryParams: {'query': query},
    );

    if (!mounted) return;

    if (res.isOk && res.data is List) {
      final list = res.data as List;
      setState(() {
        _searchResults = list
            .map((item) => CategoryWorkoutItem.fromJson(item as Map<String, dynamic>))
            .toList();
        _isSearching = false;
      });
    } else {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  void _onTagTap(String tag) {
    _searchController.text = tag;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: tag.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input + Close Button Header
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1B1D),
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: Colors.white54,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Search workouts, plans...',
                                hintStyle: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (_activeSearch.isNotEmpty)
                            GestureDetector(
                              onTap: () => _searchController.clear(),
                              child: const Icon(
                                Icons.clear_rounded,
                                color: Colors.white54,
                                size: 18,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1B1D),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                          width: 1.0,
                        ),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Search Results (if searching) or Tags view
              Expanded(
                child: _activeSearch.isNotEmpty
                    ? _buildSearchResultsView()
                    : _buildTagsView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultsView() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryLime),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 48, color: Colors.white38),
            const SizedBox(height: 12),
            Text(
              'No workouts found for "$_activeSearch"',
              style: GoogleFonts.outfit(fontSize: 15, color: Colors.white60),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final workout = _searchResults[index];
        return CategoryWorkoutTile(
          item: workout,
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => WorkoutCustomizationFlowSheet(
                workout: workout,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTagsView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Body Focus
          Text(
            'Body Focus',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 10,
            runSpacing: 12,
            children: _bodyFocusTags.map((tag) {
              final isSelected = _activeSearch.toLowerCase() == tag.toLowerCase();
              return _buildTagChip(
                tag: tag,
                isSelected: isSelected,
                onTap: () => _onTagTap(tag),
              );
            }).toList(),
          ),

          const SizedBox(height: 28),

          // Section 2: Hot Topics
          Text(
            'Hot Topics',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 10,
            runSpacing: 12,
            children: _hotTopicTags.map((tag) {
              final isSelected = _activeSearch.toLowerCase() == tag.toLowerCase();
              return _buildTagChip(
                tag: tag,
                isSelected: isSelected,
                onTap: () => _onTagTap(tag),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip({
    required String tag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLime : const Color(0xFF1B1B1D),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? AppColors.primaryLime : Colors.white.withValues(alpha: 0.10),
            width: 1.0,
          ),
        ),
        child: Text(
          tag,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.black : Colors.white70,
          ),
        ),
      ),
    );
  }
}
