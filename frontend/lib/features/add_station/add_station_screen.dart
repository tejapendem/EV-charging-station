import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddStationScreen extends ConsumerStatefulWidget {
  const AddStationScreen({super.key});

  @override
  ConsumerState<AddStationScreen> createState() => _AddStationScreenState();
}

class _AddStationScreenState extends ConsumerState<AddStationScreen> {
  int _currentStep = 0;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final Set<String> _selectedChargerTypes = {};
  final List<String> _uploadedPhotos = [];
  bool _isSubmitting = false;

  final _chargerTypes = ['CCS2', 'Type 2', 'CHAdeMO', 'Bharat DC-001', 'Bharat AC-001'];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  bool get _step1Valid => _nameController.text.trim().isNotEmpty && _descriptionController.text.trim().length >= 20;
  bool get _step2Valid => _addressController.text.trim().isNotEmpty && _cityController.text.trim().isNotEmpty && _stateController.text.trim().isNotEmpty && _pincodeController.text.trim().length == 6;
  bool get _step3Valid => _latitudeController.text.trim().isNotEmpty && _longitudeController.text.trim().isNotEmpty;
  bool get _step4Valid => _selectedChargerTypes.isNotEmpty;
  bool get _step5Valid => _uploadedPhotos.isNotEmpty;

  bool get _canProceed {
    switch (_currentStep) {
      case 0: return _step1Valid;
      case 1: return _step2Valid;
      case 2: return _step3Valid;
      case 3: return _step4Valid;
      case 4: return _step5Valid;
      default: return false;
    }
  }

  void _nextStep() { if (_currentStep < 4 && _canProceed) setState(() => _currentStep++); }
  void _previousStep() { if (_currentStep > 0) setState(() => _currentStep--); }

  void _submit() {
    setState(() => _isSubmitting = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isSubmitting = false);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
            title: const Text('Submitted for Review'),
            content: const Text('Your station has been submitted for admin approval. You will be notified once it is verified.'),
            actions: [
              FilledButton(
                onPressed: () { Navigator.of(context).pop(); Navigator.of(context).pop(); },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    });
  }

  final _stepLabels = ['Basic Info', 'Address', 'Location', 'Charger Types', 'Photos'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Station')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: List.generate(5, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index <= _currentStep ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Step ${_currentStep + 1} of 5', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                Text(_stepLabels[_currentStep], style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildStepContent(theme, colorScheme),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: colorScheme.surface, border: Border(top: BorderSide(color: colorScheme.outlineVariant))),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _currentStep == 4 ? _submit : _nextStep,
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: _isSubmitting
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(_currentStep == 4 ? 'Submit' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(ThemeData theme, ColorScheme colorScheme) {
    switch (_currentStep) {
      case 0: return _buildBasicInfoStep(theme, colorScheme);
      case 1: return _buildAddressStep(theme, colorScheme);
      case 2: return _buildLocationStep(theme, colorScheme);
      case 3: return _buildChargerTypesStep(theme, colorScheme);
      case 4: return _buildPhotosStep(theme, colorScheme);
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildBasicInfoStep(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 48, color: colorScheme.primary),
        const SizedBox(height: 16),
        Text('Station Details', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Tell us about your charging station', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 24),
        TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Station Name *', hintText: 'e.g., Tata Power EV Charging Hub', prefixIcon: const Icon(Icons.ev_station), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), onChanged: (_) => setState(() {})),
        const SizedBox(height: 16),
        TextField(controller: _descriptionController, maxLines: 4, decoration: InputDecoration(labelText: 'Description *', hintText: 'Describe the station, location details, etc. (min 20 chars)', prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 64), child: Icon(Icons.description)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), alignLabelWithHint: true), onChanged: (_) => setState(() {})),
      ],
    );
  }

  Widget _buildAddressStep(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.location_on, size: 48, color: colorScheme.primary),
        const SizedBox(height: 16),
        Text('Station Address', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Provide the complete address', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 24),
        TextField(controller: _addressController, decoration: InputDecoration(labelText: 'Address *', prefixIcon: const Icon(Icons.home), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), onChanged: (_) => setState(() {})),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: TextField(controller: _cityController, decoration: InputDecoration(labelText: 'City *', prefixIcon: const Icon(Icons.location_city), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), onChanged: (_) => setState(() {}))),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: _stateController, decoration: InputDecoration(labelText: 'State *', prefixIcon: const Icon(Icons.map), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), onChanged: (_) => setState(() {}))),
        ]),
        const SizedBox(height: 16),
        TextField(controller: _pincodeController, keyboardType: TextInputType.number, maxLength: 6, decoration: InputDecoration(labelText: 'Pincode *', prefixIcon: const Icon(Icons.pin_drop), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), counterText: ''), onChanged: (_) => setState(() {})),
      ],
    );
  }

  Widget _buildLocationStep(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.gps_fixed, size: 48, color: colorScheme.primary),
        const SizedBox(height: 16),
        Text('GPS Coordinates', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Set the exact location on map', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 24),
        Container(
          height: 200,
          decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, size: 48, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                const SizedBox(height: 8),
                Text('Tap to pick location on map', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(onPressed: () {}, icon: const Icon(Icons.my_location, size: 18), label: const Text('Auto-Detect')),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: TextField(controller: _latitudeController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: 'Latitude *', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), onChanged: (_) => setState(() {}))),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: _longitudeController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: 'Longitude *', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), onChanged: (_) => setState(() {}))),
        ]),
      ],
    );
  }

  Widget _buildChargerTypesStep(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.bolt, size: 48, color: colorScheme.primary),
        const SizedBox(height: 16),
        Text('Charger Types', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Select available charger types', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 24),
        ..._chargerTypes.map((type) {
          final selected = _selectedChargerTypes.contains(type);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => setState(() => selected ? _selectedChargerTypes.remove(type) : _selectedChargerTypes.add(type)),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: selected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: selected ? colorScheme.primary : colorScheme.outlineVariant, width: selected ? 2 : 1),
                ),
                child: Row(
                  children: [
                    Icon(selected ? Icons.check_box : Icons.check_box_outline_blank, color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(type, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                        Text(_chargerTypeDesc(type), style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  String _chargerTypeDesc(String type) {
    switch (type) {
      case 'CCS2': return 'Up to 350kW, Combined Charging System';
      case 'Type 2': return 'Up to 22kW, AC Charging (Mennekes)';
      case 'CHAdeMO': return 'Up to 62.5kW, DC Fast Charging';
      case 'Bharat DC-001': return 'Up to 15kW, Indian DC Standard';
      case 'Bharat AC-001': return 'Up to 3.3kW, Indian AC Standard';
      default: return '';
    }
  }

  Widget _buildPhotosStep(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.photo_library, size: 48, color: colorScheme.primary),
        const SizedBox(height: 16),
        Text('Add Photos', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Upload photos of the station (at least 1)', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12, runSpacing: 12,
          children: [
            ..._uploadedPhotos.map((photo) {
              return Stack(
                children: [
                  Container(width: 120, height: 120, decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)), child: const Center(child: Icon(Icons.image, size: 40))),
                  Positioned(
                    top: 4, right: 4,
                    child: GestureDetector(
                      onTap: () => setState(() => _uploadedPhotos.remove(photo)),
                      child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, size: 16, color: Colors.white)),
                    ),
                  ),
                ],
              );
            }),
            GestureDetector(
              onTap: () => setState(() => _uploadedPhotos.add('photo_${_uploadedPhotos.length}')),
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(border: Border.all(color: colorScheme.outlineVariant, style: BorderStyle.solid), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 32, color: colorScheme.primary),
                    const SizedBox(height: 4),
                    Text('Add Photo', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.primary)),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (_uploadedPhotos.isEmpty) ...[
          const SizedBox(height: 24),
          Center(child: FilledButton.tonalIcon(onPressed: () => setState(() => _uploadedPhotos.add('photo_0')), icon: const Icon(Icons.camera_alt), label: const Text('Take Photo'))),
          const SizedBox(height: 8),
          Center(child: OutlinedButton.icon(onPressed: () => setState(() => _uploadedPhotos.add('photo_0')), icon: const Icon(Icons.photo_library), label: const Text('Upload from Gallery'))),
        ],
      ],
    );
  }
}
