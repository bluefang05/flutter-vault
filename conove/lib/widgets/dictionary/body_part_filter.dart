import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/feedback_service.dart';

class BodyPartFilterBar extends StatelessWidget {
  final String selectedPart;
  final ValueChanged<String> onSelected;

  const BodyPartFilterBar({
    super.key,
    required this.selectedPart,
    required this.onSelected,
  });

  static const List<String> parts = [
    'Todos',
    'Ojos',
    'Boca',
    'Cejas',
    'Voz',
    'Brazos',
    'Espacio',
    'Digital',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: parts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final part = parts[index];
          final isSelected = (selectedPart == part) || (selectedPart.isEmpty && part == 'Todos');

          return ChoiceChip(
            label: Text(
              part,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondaryLight,
              ),
            ),
            selected: isSelected,
            selectedColor: AppColors.primary,
            backgroundColor: Theme.of(context).cardTheme.color,
            showCheckmark: false,
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.lightBorder,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onSelected: (_) {
              FeedbackService.lightClick();
              onSelected(part == 'Todos' ? '' : part);
            },
          );
        },
      ),
    );
  }
}
