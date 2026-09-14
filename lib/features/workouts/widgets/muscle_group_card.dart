import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/workout_models.dart';

class MuscleGroupCard extends StatelessWidget {
  final MuscleGroupItem item;
  final VoidCallback? onTap;

  const MuscleGroupCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const borderRadius = 16.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 145,
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFA3D223),
              Color(0x00A3D223),
            ],
          ),
        ),
        padding: const EdgeInsets.all(1.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1B1B1D),
            borderRadius: BorderRadius.circular(borderRadius - 1.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Muscle Photo on right with smooth blend
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 70,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      item.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFF1B1B1D),
                            Colors.transparent,
                          ],
                          stops: [0.0, 0.50],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Left Text Details
              Padding(
                padding: const EdgeInsets.only(left: 14.0, top: 14.0, bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      item.workoutCount,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
