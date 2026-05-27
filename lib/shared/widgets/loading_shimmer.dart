import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingShimmer extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const LoadingShimmer({
    super.key,
    this.height = 80,
    this.width,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF2B2D31),
      highlightColor: const Color(0xFF383A40),
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF2B2D31),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class NoteCardShimmer extends StatelessWidget {
  const NoteCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF2B2D31),
      highlightColor: const Color(0xFF383A40),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFF2B2D31),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                height: 16,
                width: 160,
                color: const Color(0xFF383A40)),
            const SizedBox(height: 10),
            Container(
                height: 12,
                width: double.infinity,
                color: const Color(0xFF383A40)),
            const SizedBox(height: 6),
            Container(
                height: 12,
                width: 220,
                color: const Color(0xFF383A40)),
          ],
        ),
      ),
    );
  }
}

class FileItemShimmer extends StatelessWidget {
  const FileItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF2B2D31),
      highlightColor: const Color(0xFF383A40),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF2B2D31),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF383A40),
                  borderRadius: BorderRadius.circular(8),
                )),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 14,
                      width: 140,
                      color: const Color(0xFF383A40)),
                  const SizedBox(height: 6),
                  Container(
                      height: 10,
                      width: 80,
                      color: const Color(0xFF383A40)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
