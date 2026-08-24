part of '../main.dart';

class _CategoryOption {
  const _CategoryOption({
    required this.label,
    required this.asset,
    required this.color,
  });

  final String label;
  final String asset;
  final Color color;
}

const _availableCategories = [
  _CategoryOption(
    label: 'Trabajo',
    asset: MissionCategoryAssets.work,
    color: Color(0xFFFFB765),
  ),
  _CategoryOption(
    label: 'Ejercicio',
    asset: MissionCategoryAssets.exercise,
    color: Color(0xFF73CBB0),
  ),
  _CategoryOption(
    label: 'Estudio',
    asset: MissionCategoryAssets.study,
    color: Color(0xFF92A5E8),
  ),
  _CategoryOption(
    label: 'Salud',
    asset: MissionCategoryAssets.health,
    color: Color(0xFFE58BA5),
  ),
  _CategoryOption(
    label: 'Limpieza',
    asset: MissionCategoryAssets.cleaning,
    color: Color(0xFF86CD82),
  ),
  _CategoryOption(
    label: 'Descanso',
    asset: MissionCategoryAssets.rest,
    color: Color(0xFFB5A4E3),
  ),
  _CategoryOption(
    label: 'Personal',
    asset: MissionCategoryAssets.personalProject,
    color: Color(0xFFF39E75),
  ),
  _CategoryOption(
    label: 'Social',
    asset: MissionCategoryAssets.socialFamily,
    color: Color(0xFFEAA6C8),
  ),
];

class _MissionEditorSheet extends StatefulWidget {
  const _MissionEditorSheet({required this.mission});

  final Mission? mission;

  @override
  State<_MissionEditorSheet> createState() => _MissionEditorSheetState();
}

class _MissionEditorSheetState extends State<_MissionEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  String? _selectedCategoryAsset;
  Color? _selectedColor;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.mission?.title ?? '');
    _subtitleController = TextEditingController(
      text: widget.mission?.subtitle ?? 'Personal · Todos los días',
    );
    _selectedCategoryAsset = widget.mission?.categoryAsset;
    _selectedColor = widget.mission?.color;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.mission == null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
        decoration: const BoxDecoration(
          color: Color(0xFFFFFCF6),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDAD3C7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isNew ? 'Nueva misión' : 'Editar misión',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isNew
                    ? '¿Qué quieres hacer todos los días?'
                    : 'Actualiza esta misión diaria.',
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _titleController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Ej. Ordenar mi escritorio',
                  filled: true,
                  fillColor: const Color(0xFFF2EDE3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _subtitleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Detalle u horario',
                  hintText: 'Ej. Salud · Antes de las 6:00 p. m.',
                  filled: true,
                  fillColor: const Color(0xFFF2EDE3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Categoría',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF6B5F54),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableCategories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _availableCategories[index];
                    final isSelected = _selectedCategoryAsset == cat.asset;
                    return ChoiceChip(
                      selected: isSelected,
                      avatar: Image.asset(cat.asset, width: 18, height: 18),
                      label: Text(
                        cat.label,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.w900
                              : FontWeight.w700,
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF493D36),
                        ),
                      ),
                      selectedColor: const Color(0xFF7656D6),
                      backgroundColor: const Color(0xFFF2EDE3),
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF7656D6)
                              : const Color(0xFFE4DBCF),
                        ),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategoryAsset = selected ? cat.asset : null;
                          _selectedColor = selected ? cat.color : null;
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    isNew ? 'Crear misión' : 'Guardar cambios',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final subtitle = _subtitleController.text.trim();
    final categoryAsset =
        _selectedCategoryAsset ?? MissionCategoryAssets.inferFromText(title);
    final color = _selectedColor ?? const Color(0xFFE58BA5);
    Navigator.pop(
      context,
      MissionDraft(
        title,
        subtitle.isEmpty ? 'Personal · Todos los días' : subtitle,
        categoryAsset: categoryAsset,
        color: color,
      ),
    );
  }
}
