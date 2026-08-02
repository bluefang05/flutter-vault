part of '../main.dart';

class _MissionEditorSheet extends StatefulWidget {
  const _MissionEditorSheet({required this.mission});

  final Mission? mission;

  @override
  State<_MissionEditorSheet> createState() => _MissionEditorSheetState();
}

class _MissionEditorSheetState extends State<_MissionEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.mission?.title ?? '');
    _subtitleController = TextEditingController(
      text: widget.mission?.subtitle ?? 'Personal · Todos los días',
    );
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
    Navigator.pop(
      context,
      MissionDraft(
        title,
        subtitle.isEmpty ? 'Personal · Todos los días' : subtitle,
      ),
    );
  }
}
