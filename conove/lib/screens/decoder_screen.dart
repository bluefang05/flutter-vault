import 'package:flutter/material.dart';
import '../data/gesture_database.dart';
import '../widgets/dictionary/gesture_card.dart';
import '../widgets/dictionary/body_part_filter.dart';
import '../core/constants/app_colors.dart';
import 'gesture_detail_screen.dart';
import '../core/services/storage_service.dart';

class DecoderScreen extends StatefulWidget {
  const DecoderScreen({super.key});

  @override
  State<DecoderScreen> createState() => _DecoderScreenState();
}

class _DecoderScreenState extends State<DecoderScreen> {
  String _selectedBodyPart = 'Ojos';
  List<String> _bookmarkedIds = [];

  @override
  void initState() {
    super.initState();
    _bookmarkedIds = StorageService.getBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    final gestures = GestureDatabase.getByBodyPart(_selectedBodyPart);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Decodificador en Vivo'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Guidance banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.primaryContainer.withValues(alpha: 0.35),
            child: Row(
              children: [
                const Icon(Icons.touch_app_rounded, color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Selecciona la zona donde observaste el gesto para ver su significado inmediato.',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Body Part selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: BodyPartFilterBar(
              selectedPart: _selectedBodyPart,
              onSelected: (part) {
                setState(() {
                  _selectedBodyPart = part.isEmpty ? 'Todos' : part;
                });
              },
            ),
          ),
          const SizedBox(height: 14),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '${gestures.length} señales encontradas en "$_selectedBodyPart":',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 8),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: gestures.length,
              itemBuilder: (context, index) {
                final item = gestures[index];
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
                    ).then((_) {
                      setState(() {
                        _bookmarkedIds = StorageService.getBookmarks();
                      });
                    });
                  },
                  onBookmarkToggle: () async {
                    await StorageService.toggleBookmark(item.id);
                    setState(() {
                      _bookmarkedIds = StorageService.getBookmarks();
                    });
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
