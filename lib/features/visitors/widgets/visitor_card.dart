import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/visitor.dart';

class VisitorCard extends StatelessWidget {
  final Visitor visitor;

  const VisitorCard({super.key, required this.visitor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 16),
            Expanded(child: _buildVisitorInfo()),
            _buildStatusBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.primary.withOpacity(0.1),
      child: Text(
        visitor.name.substring(0, 1).toUpperCase(),
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildVisitorInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          visitor.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Host: ${visitor.host}',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        Text(
          'Dept: ${visitor.department}',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        Text(
          visitor.purpose,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          _formatTime(visitor.visitTime),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;
    
    switch (visitor.status) {
      case VisitorStatus.pending:
        color = AppColors.pending;
        text = 'Pending';
        break;
      case VisitorStatus.approved:
        color = AppColors.approved;
        text = 'Approved';
        break;
      case VisitorStatus.checkedIn:
        color = AppColors.checkedIn;
        text = 'Checked-in';
        break;
      case VisitorStatus.overstay:
        color = AppColors.overstay;
        text = 'Overstay';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = time.difference(now);
    
    if (difference.isNegative) {
      final hours = (-difference.inHours);
      final minutes = (-difference.inMinutes) % 60;
      return '${hours}h ${minutes}m ago';
    } else {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      return 'in ${hours}h ${minutes}m';
    }
  }
}