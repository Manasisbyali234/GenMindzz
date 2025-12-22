import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/visitor.dart';

class VisitorDetailsModal extends StatelessWidget {
  final Visitor visitor;

  const VisitorDetailsModal({super.key, required this.visitor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildVisitorInfo(),
                        const SizedBox(height: 32),
                        _buildActionButtons(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Visitor Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisitorInfo() {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage(
            'https://picsum.photos/seed/${visitor.name.hashCode.abs()}/200/200',
          ),
          backgroundColor: AppColors.primary.withOpacity(0.1),
        ),
        const SizedBox(height: 16),
        Text(
          visitor.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        _buildStatusBadge(),
        const SizedBox(height: 24),
        _buildInfoCard(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;
    
    switch (visitor.status) {
      case VisitorStatus.pending:
        color = AppColors.pending;
        text = 'Expected';
        break;
      case VisitorStatus.approved:
        color = AppColors.approved;
        text = 'Approved';
        break;
      case VisitorStatus.checkedIn:
        color = AppColors.approved;
        text = 'Checked In';
        break;
      case VisitorStatus.overstay:
        color = AppColors.overstay;
        text = 'Overstay';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(Icons.email, 'Email', visitor.email),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.phone, 'Phone', visitor.phone),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.business, 'Department', visitor.department),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.person, 'Host', visitor.host),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.description, 'Purpose', visitor.purpose),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.schedule, 'Visit Time', 
            '${visitor.visitTime.day}/${visitor.visitTime.month}/${visitor.visitTime.year} at ${visitor.visitTime.hour}:${visitor.visitTime.minute.toString().padLeft(2, '0')}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (visitor.status == VisitorStatus.checkedIn) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _handleCheckOut(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.overstay,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            'Check Out',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      );
    } else if (visitor.status == VisitorStatus.approved || visitor.status == VisitorStatus.pending) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _handleCheckIn(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.approved,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            'Check In',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  void _handleCheckIn(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${visitor.name} checked in successfully'),
        backgroundColor: AppColors.approved,
      ),
    );
  }

  void _handleCheckOut(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${visitor.name} checked out successfully'),
        backgroundColor: AppColors.overstay,
      ),
    );
  }
}