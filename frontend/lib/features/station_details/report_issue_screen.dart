import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportIssueScreen extends ConsumerStatefulWidget {
  final String stationId;

  const ReportIssueScreen({super.key, required this.stationId});

  @override
  ConsumerState<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends ConsumerState<ReportIssueScreen> {
  String? _selectedIssueType;
  final _descriptionController = TextEditingController();
  final List<String> _selectedPhotos = [];
  bool _isSubmitting = false;

  final _issueTypes = ['Closed Station', 'Wrong Location', 'Pricing Issue', 'Charger Not Working'];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isValid => _selectedIssueType != null && _descriptionController.text.trim().length >= 10;

  void _submit() {
    if (!_isValid) return;
    setState(() => _isSubmitting = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isSubmitting = false);
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Issue reported successfully! Thank you.'), behavior: SnackBarBehavior.floating),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report an Issue'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Submit'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.flag_outlined, size: 48, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text('What\'s wrong?', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Help us improve by reporting issues at this station.', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            Text('Issue Type', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ..._issueTypes.map((type) {
              final selected = _selectedIssueType == type;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => setState(() => _selectedIssueType = type),
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
                        Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant, size: 20),
                        const SizedBox(width: 12),
                        Text(type, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: selected ? FontWeight.w600 : null)),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            Text('Description', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Describe the issue in detail...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                alignLabelWithHint: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Text('Add Photos (optional)', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                ..._selectedPhotos.map((photo) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        Container(width: 80, height: 80, decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)), child: const Center(child: Icon(Icons.image, size: 32))),
                        Positioned(
                          top: 4, right: 4,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPhotos.remove(photo)),
                            child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, size: 14, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                GestureDetector(
                  onTap: () => setState(() => _selectedPhotos.add('photo_${_selectedPhotos.length}')),
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(border: Border.all(color: colorScheme.outlineVariant), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, color: colorScheme.primary, size: 24),
                        const SizedBox(height: 4),
                        Text('Add', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.primary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isValid && !_isSubmitting ? _submit : null,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _isSubmitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Submit Report'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
