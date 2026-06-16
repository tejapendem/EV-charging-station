import 'package:flutter/material.dart';

class ErrorState extends StatelessWidget {
  final String? message;
  final String? actionLabel;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorState({
    super.key,
    this.message,
    this.actionLabel,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  const ErrorState.network({
    super.key,
    this.message = 'No internet connection',
    this.actionLabel = 'Retry',
    this.onRetry,
    this.icon = Icons.wifi_off,
  });

  const ErrorState.server({
    super.key,
    this.message = 'Something went wrong',
    this.actionLabel = 'Try Again',
    this.onRetry,
    this.icon = Icons.cloud_off,
  });

  const ErrorState.location({
    super.key,
    this.message = 'Unable to get your location',
    this.actionLabel = 'Enable Location',
    this.onRetry,
    this.icon = Icons.location_off,
  });

  const ErrorState.auth({
    super.key,
    this.message = 'Authentication failed',
    this.actionLabel = 'Sign In',
    this.onRetry,
    this.icon = Icons.lock_outline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops!',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message ?? 'An unexpected error occurred',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 20),
                label: Text(actionLabel ?? 'Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final VoidCallback? onRetry;

  const ErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: theme.colorScheme.errorContainer,
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.onErrorContainer,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close,
                color: theme.colorScheme.onErrorContainer,
                size: 18,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
