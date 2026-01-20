import 'package:flutter/material.dart';

class AppointmentDateSelector extends StatefulWidget {
  final Function(DateTime)? onDateSelected;
  
  const AppointmentDateSelector({
    super.key,
    this.onDateSelected,
  });

  @override
  State<AppointmentDateSelector> createState() => _AppointmentDateSelectorState();
}

class _AppointmentDateSelectorState extends State<AppointmentDateSelector> {
  int selectedDateIndex = 3; // Default to today (index 3)

  @override
  Widget build(BuildContext context) {
    return _buildHorizontalDateSelector();
  }

  Widget _buildHorizontalDateSelector() {
    final today = DateTime.now();
    final dates = List.generate(7, (index) {
      return today.add(Duration(days: index - 3));
    });

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = index == selectedDateIndex;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDateIndex = index;
              });
              widget.onDateSelected?.call(date);
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getMonthAbbreviation(date.month),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getDayAbbreviation(date.weekday),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    return months[month - 1];
  }

  String _getDayAbbreviation(int weekday) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[weekday - 1];
  }
}