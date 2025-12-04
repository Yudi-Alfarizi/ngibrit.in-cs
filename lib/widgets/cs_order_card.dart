import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:ngibrit_in_cs/models/order_model.dart';

class CSOrderCard extends StatelessWidget {
  const CSOrderCard({super.key, required this.order, required this.onTap});

  final OrderModel order;
  final VoidCallback onTap;

  // Helper untuk format tanggal pesanan dibuat (createdAt)
  String _formatCreatedDate(Timestamp timestamp) {
    try {
      DateTime date = timestamp.toDate();
      return DateFormat('d MMM yyyy').format(date);
    } catch (e) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.grey;
    Color statusBg = Colors.grey.withOpacity(0.1);

    if (order.status == 'Dikirim') {
      statusColor = const Color(0xffFFBC1C);
      statusBg = const Color(0xffFFF8E1);
    } else if (order.status == 'Berlangsung') {
      statusColor = const Color(0xff4A1DFF);
      statusBg = const Color(0xffEFEEF7);
    } else if (order.status == 'Selesai') {
      statusColor = const Color(0xff1AC75A);
      statusBg = const Color(0xffE8F9EE);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ExtendedImage.network(
                    order.bikeSnapshot['image'] ?? '',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                    cache: true,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.bikeSnapshot['name'] ?? 'Motor',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xff070623),
                        ),
                      ),
                      const Gap(4),
                      Text(
                        'Penyewa: ${order.userName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xff838384),
                        ),
                      ),
                      Text(
                        'No: ${order.id.substring(0, 8).toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xff838384),
                        ),
                      ),
                      // [FIX A] Menampilkan Tanggal Pesanan (Created At)
                      Text(
                        'Tanggal Pesanan: ${_formatCreatedDate(order.createdAt)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xff838384),
                        ),
                      ),
                      const Gap(4),
                      Text(
                        '${order.startDate} - ${order.endDate}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff070623),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(12),
            const Divider(color: Color(0xffF3F4F6), height: 1),
            const Gap(12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // [FIX B] Label Total Harga di atas nominal
                    const Text(
                      'Total Harga',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xff838384),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Gap(2),
                    Row(
                      children: [
                        const Icon(
                          Icons.wallet,
                          size: 16,
                          color: Color(0xff6B7280),
                        ),
                        const Gap(6),
                        Text(
                          NumberFormat.currency(
                            locale: 'id',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(order.totalPrice),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xff070623),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
