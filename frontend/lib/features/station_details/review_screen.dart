import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  final String stationId;

  const ReviewScreen({super.key, required this.stationId});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final _commentController = TextEditingController();
  int _overallRating = 0;
  int _cleanlinessRating = 0;
  int _availabilityRating = 0;
  int _serviceRating = 0;
  final List<String> _selectedPhotos = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  bool get _isValid => _overallRating > 0 && _commentController.text.trim().isNotEmpty;

  void _submit() {
    if (!_isValid) return;
    setState(() => _isSubmitting = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isSubmitting = false);
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully!'), behavior: SnackBarBehavior.floating),
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
        title: const Text('Add Review'),
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
            Center(
              child: Text('Rate your experience', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32),
            _RatingSection(
              label: 'Overall Rating',
              rating: _overallRating,
              onChanged: (v) => setState(() => _overallRating = v),
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 24),
            Text('Detailed Ratings', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            _RatingRow(label: 'Cleanliness', rating: _cleanlinessRating, onChanged: (v) => setState(() => _cleanlinessRating = v), colorScheme: colorScheme),
            const SizedBox(height: 12),
            _RatingRow(label: 'Availability', rating: _availabilityRating, onChanged: (v) => setState(() => _availabilityRating = v), colorScheme: colorScheme),
            const SizedBox(height: 12),
            _RatingRow(label: 'Service', rating: _serviceRating, onChanged: (v) => setState(() => _serviceRating = v), colorScheme: colorScheme),
            const SizedBox(height: 32),
            Text('Write your review', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Share your experience at this charging station...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                alignLabelWithHint: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            Text('Add Photos', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                ..._selectedPhotos.map((photo) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
                          child: const Center(child: Icon(Icons.image, size: 32)),
                        ),
                        Positioned(
                          top: 4, right: 4,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPhotos.remove(photo)),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: const Icon(Icons.close, size: 14, color: Colors.white),
                            ),
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
                  : const Text('Submit Review'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _RatingSection extends StatelessWidget {
  final String label;
  final int rating;
  final ValueChanged<int> onChanged;
  final ColorScheme colorScheme;

  const _RatingSection({required this.label, required this.rating, required this.onChanged, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starValue = index + 1;
            return GestureDetector(
              onTap: () => onChanged(starValue),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  starValue <= rating ? Icons.star : Icons.star_border,
                  size: 44,
                  color: starValue <= rating ? Colors.amber : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _RatingRow extends StatelessWidget {
  final String label;
  final int rating;
  final ValueChanged<int> onChanged;
  final ColorScheme colorScheme;

  const _RatingRow({required this.label, required this.rating, required this.onChanged, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 100, child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
        const Spacer(),
        ...List.generate(5, (index) {
          final starValue = index + 1;
          return GestureDetector(
            onTap: () => onChanged(starValue),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                starValue <= rating ? Icons.star : Icons.star_border,
                size: 28,
                color: starValue <= rating ? Colors.amber : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ),
          );
        }),
      ],
    );
  }
}
