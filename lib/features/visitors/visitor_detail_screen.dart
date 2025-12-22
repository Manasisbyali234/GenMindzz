import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/visitor.dart';
import '../../core/constants/app_colors.dart';

class VisitorDetailScreen extends StatelessWidget {
  final Visitor visitor;

  const VisitorDetailScreen({super.key, required this.visitor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // Dark Gradient Header
              Container(
                height: 200,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0f172a), Color(0xFF0f172a)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Header Content
                        Row(
                          children: [
                            // Left side - User info
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: const Color(0xFF5B5AF7),
                                  child: const Icon(Icons.person, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 12),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Jane Doe',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'EMPLOYEE',
                                      style: TextStyle(
                                        color: Color(0xFF7F8AA3),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Right side - Icons
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.notifications_outlined, color: Color(0xFF7F8AA3)),
                            ),
                            IconButton(
                              onPressed: () => context.pop(),
                              icon: const Icon(Icons.close, color: Color(0xFF7F8AA3)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Title and Back Button
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Visitor Detail',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // White Content Area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Visitor Name & Status
                      Center(
                        child: Column(
                          children: [
                            Text(
                              visitor.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0f172a),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE9EDFF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'UPCOMING',
                                style: TextStyle(
                                  color: Color(0xFF4f46e5),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Section Label
                      const Text(
                        'VISITOR INFORMATION',
                        style: TextStyle(
                          color: Color(0xFF7F8AA3),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Information Cards
                      _buildInfoCard(Icons.person_outline, 'NAME', visitor.name),
                      const SizedBox(height: 12),
                      _buildInfoCard(Icons.email_outlined, 'EMAIL', visitor.email),
                      const SizedBox(height: 12),
                      _buildInfoCard(Icons.business_outlined, 'DEPARTMENT', visitor.department),
                      const SizedBox(height: 12),
                      _buildInfoCard(Icons.phone_outlined, 'PHONE', visitor.phone),
                      const SizedBox(height: 12),
                      _buildInfoCard(Icons.person_pin_outlined, 'HOST', visitor.host),
                      const SizedBox(height: 12),
                      
                      // Date & Time Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              Icons.calendar_today_outlined, 
                              'DATE', 
                              '${visitor.visitTime.day}/${visitor.visitTime.month}/${visitor.visitTime.year}'
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              Icons.access_time_outlined, 
                              'TIME', 
                              '${visitor.visitTime.hour.toString().padLeft(2, '0')}:${visitor.visitTime.minute.toString().padLeft(2, '0')}'
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Purpose of Visit Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFEEF2F7)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PURPOSE OF VISIT',
                              style: TextStyle(
                                color: Color(0xFF7F8AA3),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '"${visitor.purpose}"',
                              style: const TextStyle(
                                color: Color(0xFF0f172a),
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Overlapping Profile Image
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 32,
                          color: Color(0xFFC7CEDB),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'NO PHOTO',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFFC7CEDB),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4f46e5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEF2F7)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: const Color(0xFF7F8AA3),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF7F8AA3),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF0f172a),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}