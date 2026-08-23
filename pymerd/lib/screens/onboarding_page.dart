import 'package:flutter/material.dart';

import '../app_repository.dart';
import 'home_shell.dart';

class OnboardingPage extends StatefulWidget {
  final AppRepository repository;

  const OnboardingPage({super.key, required this.repository});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _businessController = TextEditingController();
  final _ownerController = TextEditingController();
  String _businessType = 'Estética y masajes';
  String _workplace = 'Desde casa';
  bool _simpleMode = true;
  bool _saving = false;

  @override
  void dispose() {
    _businessController.dispose();
    _ownerController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await widget.repository.completeOnboarding(
      businessName: _businessController.text.trim(),
      ownerName: _ownerController.text.trim(),
      businessType: _businessType,
      workplace: _workplace,
      simpleMode: _simpleMode,
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeShell(repository: widget.repository)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.storefront_rounded,
                      size: 72,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'PYME RD',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tu negocio organizado desde el celular.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _businessController,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del negocio',
                        hintText: 'Ej.: Bienestar con Ana',
                      ),
                      validator: (value) => (value ?? '').trim().isEmpty ? 'Escribe el nombre de tu negocio.' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _ownerController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Tu nombre',
                        helperText: 'Opcional',
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _businessType,
                      decoration: const InputDecoration(labelText: 'Tipo de negocio'),
                      items: const [
                        DropdownMenuItem(value: 'Estética y masajes', child: Text('Estética y masajes')),
                        DropdownMenuItem(value: 'Salón o barbería', child: Text('Salón o barbería')),
                        DropdownMenuItem(value: 'Comida y bebidas', child: Text('Comida y bebidas')),
                        DropdownMenuItem(value: 'Tienda o reventa', child: Text('Tienda o reventa')),
                        DropdownMenuItem(value: 'Delivery o distribución', child: Text('Delivery o distribución')),
                        DropdownMenuItem(value: 'Servicios técnicos', child: Text('Servicios técnicos')),
                        DropdownMenuItem(value: 'Manualidades o fabricación', child: Text('Manualidades o fabricación')),
                        DropdownMenuItem(value: 'Servicios profesionales', child: Text('Servicios profesionales')),
                        DropdownMenuItem(value: 'Negocio general', child: Text('Negocio general')),
                      ],
                      onChanged: (value) => setState(() => _businessType = value ?? _businessType),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _workplace,
                      decoration: const InputDecoration(labelText: '¿Dónde trabajas o atiendes?'),
                      items: const [
                        DropdownMenuItem(value: 'Desde casa', child: Text('Desde casa')),
                        DropdownMenuItem(value: 'En un local', child: Text('En un local')),
                        DropdownMenuItem(value: 'A domicilio', child: Text('A domicilio')),
                        DropdownMenuItem(value: 'En varios lugares', child: Text('En varios lugares')),
                      ],
                      onChanged: (value) => setState(() => _workplace = value ?? _workplace),
                    ),
                    const SizedBox(height: 14),
                    SwitchListTile(
                      value: _simpleMode,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      title: const Text('Empezar con la vista sencilla'),
                      subtitle: const Text('Muestra primero citas, cobros, gastos y el cuadre.'),
                      onChanged: (value) => setState(() => _simpleMode = value),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: _saving ? null : _continue,
                      icon: _saving
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.arrow_forward_rounded),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Preparar mi negocio'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Tus datos se guardan localmente en este dispositivo.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}