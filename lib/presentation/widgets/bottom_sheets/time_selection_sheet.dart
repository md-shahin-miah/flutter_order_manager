import 'package:flutter/material.dart';
import 'base_bottom_sheet.dart';

class TimeSelectionSheet extends StatelessWidget {
  const TimeSelectionSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseBottomSheet(
      heightFactor: 0.6,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildTimeOption('60', 'secs', Colors.white),
                  _buildTimeOption('2', 'mins', Colors.white),
                  _buildTimeOption('3', 'mins', Colors.white),
                  _buildTimeOption('5', 'mins', Colors.white),
                  _buildTimeOption('7', 'mins', const Color(0xFFE6F9EF)),
                  _buildTimeOption('10', 'mins', const Color(0xFFE6F9EF)),
                  _buildTimeOption('15', 'mins', const Color(0xFFE6F9EF)),
                  _buildTimeOption('20', 'mins', const Color(0xFFFEEADD)),
                  _buildTimeOption('30', 'mins', const Color(0xFFFEEADD)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEEADD),
                  foregroundColor: Colors.deepOrange,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Custom',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeOption(String time, String unit, Color backgroundColor) {
    final bool isGreen = backgroundColor == const Color(0xFFE6F9EF);
    final bool isOrange = backgroundColor == const Color(0xFFFEEADD);
    
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: backgroundColor == Colors.white
            ? Border.all(color: Colors.grey.shade200)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isGreen 
                  ? Colors.green 
                  : isOrange 
                      ? Colors.deepOrange 
                      : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unit,
            style: TextStyle(
              fontSize: 14,
              color: isGreen 
                  ? Colors.green 
                  : isOrange 
                      ? Colors.deepOrange 
                      : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

