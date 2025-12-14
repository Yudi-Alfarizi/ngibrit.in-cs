import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ngibrit_in_cs/models/chat.dart';
import 'package:ngibrit_in_cs/models/order_model.dart';
import 'package:ngibrit_in_cs/page/order_detail_page.dart';
import 'package:ngibrit_in_cs/source/chat_source.dart';

class ChattingPage extends StatefulWidget {
  const ChattingPage({super.key, required this.uid, required this.userName});
  final String uid;
  final String userName;

  @override
  State<ChattingPage> createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage> {
  final edtInput = TextEditingController();
  late final Stream<QuerySnapshot<Map<String, dynamic>>> streamChats;

  String formatTimestamp(Timestamp timestamp) {
    return DateFormat('HH:mm').format(timestamp.toDate());
  }

  String formatCurrency(num price) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(price);
  }

  @override
  void initState() {
    streamChats = FirebaseFirestore.instance
        .collection('CS')
        .doc(widget.uid)
        .collection('chats')
        .orderBy('timestamp', descending: true)
        .snapshots();
    super.initState();
  }

  void _navigateToDetail(String orderId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Orders')
          .doc(orderId)
          .get();
      if (doc.exists) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailPage(
              orderModel: OrderModel.fromJson(doc.data()!, doc.id),
            ),
          ),
        );
      }
    } catch (e) {
      print("Error nav: $e");
    }
  }

  Future<void> _launchMapsUrl(String url) async {
    final cleanUrl = url.trim();
    final Uri uri = Uri.parse(cleanUrl);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      print("Gagal membuka peta: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Gap(20 + MediaQuery.of(context).padding.top),
          buildHeader(),
          Expanded(child: buildChats()),
          buildInputChat(),
        ],
      ),
    );
  }

  Widget buildChats() {
    return StreamBuilder(
      stream: streamChats,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Tidak ada pesan'));
        }

        final list = snapshot.data!.docs;
        return ListView.builder(
          reverse: true,
          itemCount: list.length,
          padding: const EdgeInsets.only(top: 20),
          itemBuilder: (context, index) {
            Chat chat = Chat.fromJson(list[index].data());
            if (chat.senderId == 'cs') {
              return chatCS(chat);
            }
            return chatUser(chat);
          },
        );
      },
    );
  }

  Widget _buildLocationBubble(String message, bool isSender) {
    String textContent = "";
    String url = "";

    if (message.contains("http")) {
      int urlStartIndex = message.indexOf("http");

      if (urlStartIndex > 0) {
        textContent = message.substring(0, urlStartIndex).trim();
      }

      String rawUrlPart = message.substring(urlStartIndex);
      List<String> parts = rawUrlPart.split(
        RegExp(r'\s+'),
      );
      if (parts.isNotEmpty) {
        url = parts.first;
      }
    } else {
      textContent = message;
    }

    return Column(
      crossAxisAlignment: isSender
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (textContent.isNotEmpty)
          Container(
            margin: EdgeInsets.only(
              left: isSender ? 49 : 24,
              right: isSender ? 24 : 49,
              bottom: 8,
            ),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSender ? Colors.white : const Color(0xff070623),
              borderRadius: BorderRadius.circular(16),
              border: isSender
                  ? Border.all(color: const Color(0xffE5E7EB))
                  : null,
            ),
            child: Text(
              textContent,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: isSender ? const Color(0xff070623) : Colors.white,
              ),
            ),
          ),

        if (url.isNotEmpty)
          GestureDetector(
            onTap: () => _launchMapsUrl(url),
            child: Container(
              width: 240,
              margin: EdgeInsets.only(
                left: isSender ? 0 : 24,
                right: isSender ? 24 : 0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xffE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.network(
                          'https://maps.gstatic.com/mapfiles/api-3/images/map_error_1.png',
                          height: 130,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Container(
                            height: 130,
                            color: Colors.grey[300],
                            child: const Icon(Icons.map, color: Colors.grey),
                          ),
                        ),
                      ),
                      Container(
                        height: 130,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ),
                      const Icon(
                        Icons.location_on,
                        color: Color(0xffFF2055),
                        size: 48,
                      ),
                    ],
                  ),

                  Container(
                    padding: const EdgeInsets.all(12),
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Lokasi Terkini",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xff070623),
                          ),
                        ),
                        const Gap(4),
                        const Text(
                          "Ketuk untuk buka Google Maps",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xff838384),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget chatUser(Chat chat) {
    bool isLocation =
        chat.message.contains('maps.google.com') ||
        chat.message.contains('google.com/maps');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (chat.bikeDetail != null)
          Column(
            children: [
              const Gap(16),
              buildSnippetBike(chat.bikeDetail!),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: DottedLine(dashColor: Color(0xffCECED5)),
              ),
            ],
          ),

        if (isLocation)
          _buildLocationBubble(
            chat.message,
            false,
          )
        else
          Container(
            margin: const EdgeInsets.only(left: 24, right: 49),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(
                0xff070623,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat.message,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.8,
                  ),
                ),
                const Gap(4),
                if (chat.timestamp != null)
                  Text(
                    formatTimestamp(chat.timestamp!),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xffCECED5),
                    ),
                  ),
              ],
            ),
          ),

        const Gap(12),
        Row(
          children: [
            const Gap(24),
            Image.asset('assets/chat_profile.png', height: 40, width: 40),
            const Gap(8),
            Text(
              widget.userName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xff070623),
              ),
            ),
          ],
        ),
        const Gap(20),
      ],
    );
  }

  Widget chatCS(Chat chat) {
    bool hasOrderSnippet =
        chat.bikeDetail != null &&
        (chat.bikeDetail!['isOrderSnapshot'] ?? false);

    bool isLocation =
        chat.message.contains('maps.google.com') ||
        chat.message.contains('google.com/maps');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (chat.bikeDetail != null)
          Column(
            children: [
              const Gap(16),
              buildSnippetBike(chat.bikeDetail!),
              if (hasOrderSnippet)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: DottedLine(dashColor: Color(0xffCECED5)),
                ),
            ],
          ),

        if (isLocation)
          _buildLocationBubble(chat.message, true)
        else
          Container(
            margin: const EdgeInsets.only(left: 49, right: 24),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.message,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xff070623),
                    height: 1.8,
                  ),
                ),
                const Gap(4),
                if (chat.timestamp != null)
                  Text(
                    formatTimestamp(chat.timestamp!),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xff838384),
                    ),
                  ),
              ],
            ),
          ),

        const Gap(12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              'CS Ngibritin',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xff070623),
              ),
            ),
            const Gap(8),
            Container(
              height: 40,
              width: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: Image.asset('assets/logo-ngibritin.png'),
            ),
            const Gap(24),
          ],
        ),
        const Gap(20),
      ],
    );
  }

  Widget buildInputChat() {
    return Container(
      height: 52,
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 30),
      padding: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: edtInput,
              onChanged: (value) => setState(() {}),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xff070623),
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(0),
                isDense: true,
                border: InputBorder.none,
                hintText: 'Tulis pesan kamu disini...',
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Color(0xff070623),
                ),
              ),
            ),
          ),
          if (edtInput.text.trim().isNotEmpty)
            IconButton(
              onPressed: () {
                Chat chat = Chat(
                  roomId: widget.uid,
                  message: edtInput.text.trim(),
                  receiverId: widget.uid,
                  senderId: 'cs',
                  bikeDetail: null,
                );
                ChatSource.send(chat, widget.uid).then((value) {
                  edtInput.clear();
                  setState(() {});
                });
              },
              icon: Image.asset('assets/ic_send.png', height: 24, width: 24),
            ),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 46,
              width: 46,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              alignment: Alignment.center,
              child: Image.asset(
                'assets/ic_arrow_back.png',
                height: 24,
                width: 24,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Customer Service',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xff070623),
              ),
            ),
          ),
          Container(
            height: 46,
            width: 46,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            alignment: Alignment.center,
            child: Image.asset('assets/ic_more.png', height: 24, width: 24),
          ),
        ],
      ),
    );
  }

  Widget buildSnippetBike(Map bike) {
    bool isOrderSnapshot = bike['isOrderSnapshot'] ?? false;

    String title = isOrderSnapshot
        ? (bike['bikeName'] ?? 'Motor')
        : (bike['name'] ?? 'Motor');
    String imageUrl = isOrderSnapshot
        ? (bike['bikeImage'] ?? '')
        : (bike['image'] ?? '');
    String status = isOrderSnapshot
        ? (bike['status'] ?? '-')
        : (bike['category'] ?? '-');
    String orderId = isOrderSnapshot
        ? (bike['orderId'] ?? '')
        : (bike['id'] ?? '');
    num totalPrice = isOrderSnapshot ? (bike['totalPrice'] ?? 0) : 0;

    String safeOrderId = (orderId.length >= 5)
        ? orderId.substring(0, 5).toUpperCase()
        : orderId.toUpperCase();
    String dateRange = isOrderSnapshot
        ? '${bike['startDate']} - ${bike['endDate']}'
        : '';

    Color statusColor = const Color(0xff838384);
    Color statusBg = const Color(0xffF3F4F6);
    if (status == 'Dikirim') {
      statusColor = const Color(0xffFFBC1C);
      statusBg = const Color(0xffFFF8E1);
    } else if (status == 'Berlangsung') {
      statusColor = const Color(0xff4A1DFF);
      statusBg = const Color(0xffEFEEF7);
    } else if (status == 'Selesai') {
      statusColor = const Color(0xff1AC75A);
      statusBg = const Color(0xffE8F9EE);
    }

    return GestureDetector(
      onTap: () {
        if (orderId.isNotEmpty && isOrderSnapshot) {
          _navigateToDetail(orderId);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(color: const Color(0xffE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ExtendedImage.network(
                    imageUrl,
                    width: 70,
                    height: 60,
                    fit: BoxFit.contain,
                    cache: true,
                    loadStateChanged: (state) =>
                        state.extendedImageLoadState == LoadState.failed
                        ? const Icon(Icons.broken_image, color: Colors.grey)
                        : null,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff070623),
                        ),
                      ),
                      const Gap(4),
                      if (isOrderSnapshot) ...[
                        Text(
                          "ID: $safeOrderId",
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xff838384),
                          ),
                        ),
                        Text(
                          dateRange,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xff838384),
                          ),
                        ),
                      ] else
                        Text(
                          status,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xff838384),
                          ),
                        ),
                    ],
                  ),
                ),
                if (!isOrderSnapshot)
                  const Text(
                    "Detail",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff4A1DFF),
                      decoration: TextDecoration.underline,
                    ),
                  ),
              ],
            ),

            if (isOrderSnapshot) ...[
              const Gap(12),
              const Divider(height: 1, color: Color(0xffF3F4F6)),
              const Gap(8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total: ${formatCurrency(totalPrice)}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff070623),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
