import 'package:flutter/material.dart';

class RatingBar extends StatelessWidget {
  final double rating;
  final double size;
  final int starCount;
  final bool showValue;

  const RatingBar({
    super.key,
    required this.rating,
    this.size = 18,
    this.starCount = 5,
    this.showValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(starCount, (index) {
          final starValue = index + 1;
          final fill = rating >= starValue
              ? 1.0
              : (rating >= starValue - 0.5 ? 0.5 : 0.0);
          return Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Icon(
              fill == 1.0
                  ? Icons.star
                  : fill == 0.5
                      ? Icons.star_half
                      : Icons.star_border,
              size: size,
              color: Colors.amber,
            ),
          );
        }),
        if (showValue) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
