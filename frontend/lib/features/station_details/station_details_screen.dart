import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ev_connect_india/providers/station_provider.dart';
import 'package:ev_connect_india/providers/location_provider.dart';
import 'package:ev_connect_india/providers/favorites_provider.dart';
import 'package:ev_connect_india/config/routes.dart';
import 'package:ev_connect_india/models/station.dart';
import 'package:ev_connect_india/models/review.dart';
import 'package:ev_connect_india/widgets/skeleton_loader.dart';
import 'package:ev_connect_india/widgets/charger_type_chip.dart';
import 'package:ev_connect_india/widgets/amenity_icon.dart';
import 'package:ev_connect_india/widgets/rating_bar.dart';
import 'package:ev_connect_india/widgets/error_state.dart';

class StationDetailsScreen extends ConsumerStatefulWidget {
  final String stationId;

  const StationDetailsScreen({super.key, required this.stationId});

  @override
  ConsumerState<StationDetailsScreen> createState() => _StationDetailsScreenState();
}

class _StationDetailsScreenState extends ConsumerState<StationDetailsScreen> {
  final _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    ref.read(stationDetailProvider(widget.stationId).notifier).loadStation(widget.stationId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final detailState = ref.watch(stationDetailProvider(widget.stationId));
    final favoritesState = ref.watch(favoritesProvider);

    if (detailState.isLoading) {
      return _buildSkeleton(theme, colorScheme);
    }

    if (detailState.error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorState(
          message: detailState.error!,
          onRetry: () => ref.read(stationDetailProvider(widget.stationId).notifier).loadStation(widget.stationId),
        ),
      );
    }

    final station = detailState.station;
    if (station == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Station not found')),
      );
    }

    final isFavorite = favoritesState.isFavorite(station.id);
    final sampleReviews = station.reviews ?? [];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (station.imageUrls.isNotEmpty) ...[
                    PageView.builder(
                      controller: _pageController,
                      itemCount: station.imageUrls.length,
                      onPageChanged: (i) => setState(() => _currentImageIndex = i),
                      itemBuilder: (context, index) {
                        return Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Center(
                            child: Icon(Icons.ev_station, size: 48, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                          ),
                        );
                      },
                    ),
                  ] else
                    Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: Icon(Icons.ev_station, size: 48, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                      ),
                    ),
                  Positioned(
                    bottom: 16, left: 0, right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        station.imageUrls.isEmpty ? 1 : station.imageUrls.length,
                        (i) => Container(
                          width: _currentImageIndex == i ? 20 : 8, height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: _currentImageIndex == i ? colorScheme.primary : Colors.white.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : null),
                onPressed: () => ref.read(favoritesProvider.notifier).toggleFavorite(station.id),
              ),
              IconButton(icon: const Icon(Icons.share), onPressed: () {}),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(station.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(child: Text('${station.address}${station.city != null ? ', ${station.city}' : ''}${station.state != null ? ', ${station.state}' : ''}', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant))),
                    ],
                  ),
                  if (station.distanceKm != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.near_me, size: 14, color: colorScheme.primary),
                        const SizedBox(width: 4),
                        Text('${station.distanceKm!.toStringAsFixed(1)} km away', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      RatingBar(rating: station.rating),
                      const SizedBox(width: 8),
                      Text('${station.rating.toStringAsFixed(1)}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Text('(${station.totalReviews} reviews)', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _ActionButton(icon: Icons.navigation, label: 'Navigate', color: colorScheme.primary, onTap: () => context.push(Routes.map, extra: station)),
                      const SizedBox(width: 8),
                      _ActionButton(icon: Icons.save_alt, label: 'Save', onTap: () {}),
                      const SizedBox(width: 8),
                      _ActionButton(icon: Icons.share, label: 'Share', onTap: () {}),
                      const SizedBox(width: 8),
                      _ActionButton(icon: Icons.flag_outlined, label: 'Report', onTap: () => context.push(Routes.reportIssue(station.id))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Charger Types'),
                  const SizedBox(height: 12),
                  ...station.connectors.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        ChargerTypeChip(connector: c),
                        const SizedBox(width: 12),
                        Text('${c.powerKw.toInt()}kW', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 4),
                        Text('· ${c.totalConnectors} connectors (${c.availableConnectors} available)', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                        if (c.pricePerKwh != null) ...[
                          const Spacer(),
                          Text('₹${c.pricePerKwh!.toStringAsFixed(2)}/kWh', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                        ],
                      ],
                    ),
                  )),
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Pricing'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Price Range', style: theme.textTheme.bodyMedium),
                        Text(station.pricing.priceRange, style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  if (station.amenities.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _SectionTitle(title: 'Amenities'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12, runSpacing: 12,
                      children: station.amenities.map((amenity) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AmenityIcon(amenity: amenity),
                              const SizedBox(width: 8),
                              Text(amenity.type.displayName, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Opening Hours'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Icon(Icons.schedule, color: colorScheme.primary),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(station.isOpen24x7 ? 'Open 24/7' : 'See operating hours', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                            Text(station.isOpen24x7 ? 'All days of the week' : 'Varies by day', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (station.phoneNumber != null) ...[
                    const SizedBox(height: 24),
                    _SectionTitle(title: 'Contact'),
                    const SizedBox(height: 12),
                    Material(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        leading: Icon(Icons.phone, color: colorScheme.primary),
                        title: Text(station.phoneNumber!),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        onTap: () {},
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SectionTitle(title: 'Reviews'),
                      TextButton.icon(
                        onPressed: () => context.push(Routes.addReview(station.id)),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Review'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (sampleReviews.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text('No reviews yet. Be the first to review!', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                      ),
                    )
                  else
                    ...sampleReviews.map((review) => _ReviewCard(review: review, colorScheme: colorScheme, theme: theme)),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Scaffold _buildSkeleton(ThemeData theme, ColorScheme colorScheme) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SkeletonLoader(width: double.infinity, height: 260),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonLoader(width: 250, height: 28),
                  const SizedBox(height: 12),
                  const SkeletonLoader(width: double.infinity, height: 16),
                  const SizedBox(height: 8),
                  const SkeletonLoader(width: 120, height: 16),
                  const SizedBox(height: 24),
                  Row(children: List.generate(4, (_) => const Padding(padding: EdgeInsets.only(right: 8), child: SkeletonLoader(width: 72, height: 72)))),
                  const SizedBox(height: 24),
                  const SkeletonLoader(width: 100, height: 20),
                  const SizedBox(height: 12),
                  const SkeletonLoader(width: double.infinity, height: 60),
                  const SizedBox(height: 24),
                  const SkeletonLoader(width: 120, height: 20),
                  const SizedBox(height: 12),
                  ...List.generate(2, (_) => const Padding(padding: EdgeInsets.only(bottom: 12), child: Row(children: [SkeletonLoader(width: 80, height: 32), SizedBox(width: 12), SkeletonLoader(width: 100, height: 16)]))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.outlineVariant), borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Icon(icon, color: color ?? theme.colorScheme.onSurface, size: 22),
              const SizedBox(height: 4),
              Text(label, style: theme.textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600));
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _ReviewCard({required this.review, required this.colorScheme, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(review.userName.isNotEmpty ? review.userName[0].toUpperCase() : '?', style: TextStyle(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.userName, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      Text(_formatDate(review.createdAt), style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                RatingBar(rating: review.rating.toDouble()),
              ],
            ),
            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(review.comment, style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.4)),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
