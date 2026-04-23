import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../models/visitor.dart';
import '../auth/auth_provider.dart';
import '../visitors/visitors_provider.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final _scanController = TextEditingController();
  bool isFlashOn = false;
  bool _isScanning = false;
  bool _isConfirming = false;
  ScanResult? _scanResult;
  Visitor? _scannedVisitor;

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('QR Scanner', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => setState(() => isFlashOn = !isFlashOn),
            icon: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildCameraPreview(),
          _buildScanFrame(),
          _buildInstructions(),
          _buildManualScanPanel(authUser?.name ?? 'Security'),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[900],
      child: const Center(
        child: Text(
          'Camera Preview Placeholder',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildScanFrame() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 3),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return const Positioned(
      top: 110,
      left: 0,
      right: 0,
      child: Text(
        'Scan with the camera later, or submit a QR/manual ID below.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildManualScanPanel(String performer) {
    final action = _scanResult?.action?.toUpperCase();
    final canCheckIn = action == 'ENTRY' || action == 'VALIDATE';
    final canCheckOut = action == 'EXIT';

    return Positioned(
      left: 16,
      right: 16,
      bottom: 24,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF101827),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manual Scan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Performer: $performer',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _scanController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter QR token or manual visitor ID',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isScanning ? null : _handleScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isScanning
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit Scan'),
              ),
            ),
            if (_scannedVisitor != null) ...[
              const SizedBox(height: 16),
              _buildVisitorResult(_scannedVisitor!),
              const SizedBox(height: 12),
              if (canCheckIn)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isConfirming ? null : () => _confirmStatus(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.approved,
                    ),
                    child: _isConfirming
                        ? const Text('Processing...')
                        : const Text('Confirm Check In'),
                  ),
                ),
              if (canCheckOut)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isConfirming ? null : () => _confirmStatus(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.overstay,
                    ),
                    child: _isConfirming
                        ? const Text('Processing...')
                        : const Text('Confirm Check Out'),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVisitorResult(Visitor visitor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            visitor.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text('Host: ${visitor.host}', style: const TextStyle(color: Colors.white70)),
          Text(
            'Department: ${visitor.department}',
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            'Purpose: ${visitor.purpose}',
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            'Status: ${visitor.status.label}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Future<void> _handleScan() async {
    final user = ref.read(authProvider).user;
    final code = _scanController.text.trim();

    if (user == null || user.token == null || user.token!.isEmpty) {
      _showMessage('You need to sign in before scanning.');
      return;
    }

    if (code.isEmpty) {
      _showMessage('Enter a QR token or manual visitor ID first.');
      return;
    }

    setState(() {
      _isScanning = true;
    });

    try {
      final result = await ApiService.scanQr(
        token: user.token!,
        qrCode: code,
        performer: user.name,
      );

      final record = result.record;
      final visitor = record == null ? null : Visitor.fromJson(record);

      setState(() {
        _scanResult = result;
        _scannedVisitor = visitor;
      });

      if (visitor == null) {
        _showMessage('Scan completed, but the API did not return visitor details.');
      }
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _confirmStatus(bool isCheckIn) async {
    final visitor = _scannedVisitor;
    if (visitor == null) {
      _showMessage('Scan a visitor before confirming status.');
      return;
    }

    setState(() {
      _isConfirming = true;
    });

    try {
      if (isCheckIn) {
        await ref.read(visitorsStateProvider.notifier).confirmCheckIn(visitor.id);
      } else {
        await ref.read(visitorsStateProvider.notifier).confirmCheckOut(visitor.id);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _scannedVisitor = visitor.copyWith(
          status: isCheckIn ? VisitorStatus.checkedIn : VisitorStatus.checkedOut,
        );
      });

      _showMessage(
        isCheckIn
            ? '${visitor.name} checked in successfully.'
            : '${visitor.name} checked out successfully.',
      );
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isConfirming = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }
}
