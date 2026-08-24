import 'package:flutter/material.dart';
import '../models/category.dart';
import '../data/gesture_database.dart';
import '../widgets/dictionary/gesture_card.dart';
import '../widgets/dictionary/body_part_filter.dart';
import '../core/constants/app_colors.dart';
import '../core/services/feedback_service.dart';
import '../core/services/storage_service.dart';
import 'gesture_detail_screen.dart';
import 'compare_screen.dart';

class DictionaryScreen extends StatefulWidget {
  final CategoryType? initialCategory;

  const DictionaryScreen({super.key, this.initialCategory});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  CategoryType? _selectedCategory;
  String _selectedBodyPart = '';
  List<String> _bookmarkedIds = [];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _loadBookmarks();
  }

  void _loadBookmarks() {
    setState(() {
      _bookmarkedIds = StorageService.getBookmarks();
    });
  }

  void _toggleBookmark(String gestureId) async {
    await StorageService.toggleBookmark(gestureId);
    _loadBookmarks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    var filteredList = GestureDatabase.search(query);

    if (_selectedCategory != null) {
      filteredList = filteredList.where((g) => g.category == _selectedCategory).toList();
    }

    if (_selectedBodyPart.isNotEmpty) {
      filteredList = filteredList.where((g) => g.bodyPart.toLowerCase().contains(_selectedBodyPart.toLowerCase())).toList();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual de Señales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows_rounded),
            tooltip: 'Comparador Visual A/B',
            onPressed: () {
              FeedbackService.lightClick();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CompareScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmarks_rounded),
            tooltip: 'Ver Guardados',
            onPressed: () {
              FeedbackService.lightClick();
              // Filter to show only bookmarks
              setState(() {
                if (_selectedBodyPart == 'Guardados') {
                  _selectedBodyPart = '';
                } else {
                  _selectedBodyPart = 'Guardados';
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filters Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Column(
              children: [
                // Search Field
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Buscar gesto, emoción o situación...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Body Part Chips
                BodyPartFilterBar(
                  selectedPart: _selectedBodyPart,
                  onSelected: (part) {
                    setState(() {
                      _selectedBodyPart = part;
                    });
                  },
                ),
              ],
            ),
          ),

          // Categories horizontal list
          SizedBox(
            height: 34,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: CategoryInfo.allCategories.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isSelected = _selectedCategory == null;
                  return FilterChip(
                    label: const Text('Todas las categorías'),
                    selected: isSelected,
                    onSelected: (_) {
                      FeedbackService.tabPop();
                      setState(() => _selectedCategory = null);
                    },
                    selectedColor: AppColors.primaryContainer,
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  );
                }

                final cat = CategoryInfo.allCategories[index - 1];
                final isSelected = _selectedCategory == cat.type;

                return FilterChip(
                  label: Text(cat.shortTitle),
                  selected: isSelected,
                  onSelected: (_) {
                    FeedbackService.tabPop();
                    setState(() => _selectedCategory = isSelected ? null : cat.type);
                  },
                  selectedColor: cat.containerColor,
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // List of Gestures
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth >= 640;
                final isWide = constraints.maxWidth >= 960;
                final columns = isWide ? 3 : (isTablet ? 2 : 1);

                if (filteredList.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 54, color: AppColors.textMutedLight),
                          const SizedBox(height: 12),
                          const Text(
                            'No se encontraron señales',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Intenta con otra palabra clave o selecciona "Todos" en los filtros.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: AppColors.textMutedLight),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (isTablet) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: isWide ? 1.55 : 1.4,
                        ),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final item = filteredList[index];
                          final isBookmarked = _bookmarkedIds.contains(item.id);

                          return GestureCard(
                            item: item,
                            isBookmarked: isBookmarked,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GestureDetailScreen(gestureId: item.id),
                                ),
                              ).then((_) => _loadBookmarks());
                            },
                            onBookmarkToggle: () => _toggleBookmark(item.id),
                          );
                        },
                      ),
                    ),
                  );
                }

                // Mobile 1-Column List
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final item = filteredList[index];
                    final isBookmarked = _bookmarkedIds.contains(item.id);

                    return GestureCard(
                      item: item,
                      isBookmarked: isBookmarked,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GestureDetailScreen(gestureId: item.id),
                          ),
                        ).then((_) => _loadBookmarks());
                      },
                      onBookmarkToggle: () => _toggleBookmark(item.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
