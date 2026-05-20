import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ngibrit_in_cs/models/account.dart';

class KycDetailPage extends StatefulWidget {
  final Account account;
  const KycDetailPage({super.key, required this.account});

  @override
  State<KycDetailPage> createState() => _KycDetailPageState();
}

class _KycDetailPageState extends State<KycDetailPage> {
  bool isLoading = false;

  Future<void> _updateStatus(String status, {String? rejectReason}) async {
    setState(() => isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('User')
          .doc(widget.account.uid)
          .update({'kycStatus': status, 'rejectReason': rejectReason});
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'VERIFIED' ? 'Akun Berhasil Disetujui' : 'Akun Ditolak',
            ),
            backgroundColor: status == 'VERIFIED' ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showRejectDialog() {
    TextEditingController reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alasan Penolakan'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(
            hintText: 'Masukkan alasan...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (reasonCtrl.text.isNotEmpty) {
                Navigator.pop(context);
                _updateStatus('REJECTED', rejectReason: reasonCtrl.text);
              }
            },
            child: const Text(
              'Tolak KTP',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFBFBFB),
      appBar: AppBar(
        title: const Text(
          'Detail Data User',
          style: TextStyle(
            color: Color(0xff070623),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // DATA PROFIL
                const Text(
                  'Informasi Pengguna',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff070623),
                  ),
                ),
                const Gap(16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('Nama Lengkap', widget.account.name),
                      const Divider(color: Color(0xffF3F4F6), height: 24),
                      _buildInfoRow('Email', widget.account.email),
                      const Divider(color: Color(0xffF3F4F6), height: 24),
                      _buildInfoRow(
                        'No. Handphone',
                        widget.account.phoneNumber.isEmpty
                            ? 'Belum Diisi'
                            : widget.account.phoneNumber,
                      ),
                      const Divider(color: Color(0xffF3F4F6), height: 24),
                      _buildInfoRow(
                        'Status Saat Ini',
                        widget.account.kycStatus,
                      ),
                    ],
                  ),
                ),
                const Gap(30),

                // FOTO PROFIL (Jika Ada)
                if (widget.account.profileUrl != null &&
                    widget.account.profileUrl!.isNotEmpty) ...[
                  const Text(
                    'Foto Profil',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff070623),
                    ),
                  ),
                  const Gap(12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: _buildImageFrame(widget.account.profileUrl),
                      ),
                    ),
                  ),
                  const Gap(30),
                ],

                // DOKUMEN KTP
                const Text(
                  'Dokumen KTP',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff070623),
                  ),
                ),
                const Gap(12),
                _buildImageFrame(widget.account.ktpUrl),
                const Gap(30),

                // DOKUMEN SELFIE
                const Text(
                  'Selfie dengan KTP',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff070623),
                  ),
                ),
                const Gap(12),
                _buildImageFrame(widget.account.selfieUrl),
                const Gap(40),

                // TOMBOL AKSI HANYA MUNCUL JIKA STATUS 'PENDING'
                if (widget.account.kycStatus == 'PENDING')
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          onPressed: _showRejectDialog,
                          child: const Text(
                            'Tolak',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff1AC75A),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          onPressed: () => _updateStatus('VERIFIED'),
                          child: const Text(
                            'Setujui',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                const Gap(40),
              ],
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xff070623),
          ),
        ),
      ],
    );
  }

  Widget _buildImageFrame(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
            Gap(8),
            Text("Foto tidak tersedia", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ExtendedImage.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        mode: ExtendedImageMode.gesture,
        initGestureConfigHandler: (state) {
          return GestureConfig(
            minScale: 0.9,
            animationMinScale: 0.7,
            maxScale: 3.0,
            animationMaxScale: 3.5,
            speed: 1.0,
            inertialSpeed: 100.0,
            initialScale: 1.0,
            inPageView: false,
          );
        },
      ),
    );
  }
}
