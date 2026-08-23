import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../app_repository.dart';
import '../models.dart';
import '../services/native_file_service.dart';
import '../utils.dart';
import '../widgets/common.dart';

class ClientRecordsPage extends StatefulWidget {
  final AppRepository repository;
  final Client client;

  const ClientRecordsPage({
    super.key,
    required this.repository,
    required this.client,
  });

  @override
  State<ClientRecordsPage> createState() => _ClientRecordsPageState();
}

class _ClientRecordsPageState extends State<ClientRecordsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _controller = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addConsent() async {
    String type = 'Servicio';
    bool accepted = true;
    bool storePhotos = false;
    bool promotion = false;
    final signedName = TextEditingController(text: widget.client.name);
    final notes = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Registrar consentimiento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: const [
                    DropdownMenuItem(value: 'Servicio', child: Text('Realización del servicio')),
                    DropdownMenuItem(value: 'Fotografías', child: Text('Almacenamiento de fotografías')),
                    DropdownMenuItem(value: 'Promoción', child: Text('Uso promocional')),
                    DropdownMenuItem(value: 'Cancelación', child: Text('Política de cancelación')),
                    DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                  ],
                  onChanged: (value) => setDialogState(() => type = value ?? type),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: signedName,
                  decoration: const InputDecoration(labelText: 'Nombre de quien acepta'),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: accepted,
                  title: const Text('Aceptado'),
                  onChanged: (value) => setDialogState(() => accepted = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: storePhotos,
                  title: const Text('Autoriza guardar fotografías'),
                  onChanged: (value) => setDialogState(() => storePhotos = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: promotion,
                  title: const Text('Autoriza uso promocional'),
                  subtitle: const Text('Es independiente de guardar las fotografías.'),
                  onChanged: (value) => setDialogState(() => promotion = value),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notes,
                  minLines: 2,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Notas o condiciones',
                    hintText: 'Describe lo explicado y cualquier limitación.',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar')),
          ],
        ),
      ),
    );
    if (saved == true) {
      await widget.repository.addConsent(
        ConsentRecord(
          clientId: widget.client.id!,
          type: type,
          textVersion: '1',
          accepted: accepted,
          allowPhotoStorage: storePhotos,
          allowPromotion: promotion,
          signedName: signedName.text.trim(),
          date: DateTime.now(),
          notes: notes.text.trim(),
        ),
      );
      setState(() {});
    }
    signedName.dispose();
    notes.dispose();
  }

  Future<void> _addPhoto() async {
    final consents = await widget.repository.getConsents(widget.client.id!);
    final canStore = consents.any((item) => item.accepted && item.allowPhotoStorage);
    if (!mounted) return;
    if (!canStore) {
      final proceed = await confirmAction(
        context,
        title: 'No hay autorización registrada',
        message: 'No encontramos un consentimiento que autorice guardar fotografías. Puedes cancelar y registrarlo primero.',
        confirmLabel: 'Continuar bajo mi responsabilidad',
      );
      if (!proceed) return;
    }
    final file = await NativeFileService.pickFile(mimeType: 'image/*');
    if (file == null || !mounted) return;
    String kind = 'Antes';
    bool promotion = false;
    final notes = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Datos de la fotografía'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(file.bytes, height: 180, fit: BoxFit.cover),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: kind,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: const [
                    DropdownMenuItem(value: 'Antes', child: Text('Antes')),
                    DropdownMenuItem(value: 'Después', child: Text('Después')),
                    DropdownMenuItem(value: 'Seguimiento', child: Text('Seguimiento')),
                    DropdownMenuItem(value: 'Documento', child: Text('Documento')),
                  ],
                  onChanged: (value) => setDialogState(() => kind = value ?? kind),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: promotion,
                  title: const Text('Autorizada para promoción'),
                  onChanged: (value) => setDialogState(() => promotion = value),
                ),
                TextField(
                  controller: notes,
                  decoration: const InputDecoration(labelText: 'Notas'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar')),
          ],
        ),
      ),
    );
    if (saved == true) {
      try {
        await widget.repository.addClientPhoto(
          ClientPhoto(
            clientId: widget.client.id!,
            kind: kind,
            fileName: file.name,
            mimeType: file.mimeType,
            bytes: file.bytes,
            date: DateTime.now(),
            promotionAuthorized: promotion,
            notes: notes.text.trim(),
          ),
        );
        setState(() {});
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$error')));
        }
      }
    }
    notes.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client.name),
        bottom: TabBar(
          controller: _controller,
          tabs: const [
            Tab(text: 'Consentimientos', icon: Icon(Icons.fact_check_outlined)),
            Tab(text: 'Fotografías', icon: Icon(Icons.photo_library_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: [_consents(), _photos()],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => FloatingActionButton.extended(
          onPressed: _controller.index == 0 ? _addConsent : _addPhoto,
          icon: Icon(_controller.index == 0 ? Icons.add_task : Icons.add_a_photo_outlined),
          label: Text(_controller.index == 0 ? 'Consentimiento' : 'Agregar foto'),
        ),
      ),
    );
  }

  Widget _consents() {
    return FutureBuilder<List<ConsentRecord>>(
      future: widget.repository.getConsents(widget.client.id!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data ?? const <ConsentRecord>[];
        if (items.isEmpty) {
          return EmptyState(
            icon: Icons.fact_check_outlined,
            title: 'Sin consentimientos registrados',
            message: 'Documenta por separado el servicio, las fotografías y cualquier uso promocional.',
            actionLabel: 'Registrar consentimiento',
            onAction: _addConsent,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(item.accepted ? Icons.check_circle : Icons.cancel, color: item.accepted ? Colors.green : Colors.red),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item.type, style: const TextStyle(fontWeight: FontWeight.bold))),
                        Text(formatDate(item.date)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Firmado por: ${item.signedName.isEmpty ? 'No indicado' : item.signedName}'),
                    Text('Guardar fotos: ${item.allowPhotoStorage ? 'Sí' : 'No'}'),
                    Text('Uso promocional: ${item.allowPromotion ? 'Sí' : 'No'}'),
                    if (item.notes.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(item.notes),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _photos() {
    return FutureBuilder<List<ClientPhoto>>(
      future: widget.repository.getClientPhotos(widget.client.id!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data ?? const <ClientPhoto>[];
        if (items.isEmpty) {
          return EmptyState(
            icon: Icons.photo_library_outlined,
            title: 'No hay fotografías',
            message: 'Las imágenes permanecen en la base local y se incluyen en el respaldo ZIP.',
            actionLabel: 'Agregar fotografía',
            onAction: _addPhoto,
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.78,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => _PhotoCard(
            photo: items[index],
            onDelete: () async {
              final confirmed = await confirmAction(
                context,
                title: 'Eliminar fotografía',
                message: 'Esta acción no puede deshacerse salvo que exista un respaldo anterior.',
                confirmLabel: 'Eliminar',
              );
              if (!confirmed) return;
              await widget.repository.deleteClientPhoto(items[index].id!);
              setState(() {});
            },
          ),
        );
      },
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final ClientPhoto photo;
  final VoidCallback onDelete;

  const _PhotoCard({required this.photo, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.memory(
              Uint8List.fromList(photo.bytes),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image_outlined)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 4, 6),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(photo.kind, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(formatDate(photo.date), style: const TextStyle(fontSize: 11)),
                      if (photo.promotionAuthorized)
                        const Text('Promoción autorizada', style: TextStyle(fontSize: 10, color: Colors.green)),
                    ],
                  ),
                ),
                IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
