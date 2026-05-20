import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ngibrit_in_cs/models/account.dart';
import 'package:ngibrit_in_cs/page/kyc_detail_page.dart';

class KycListPage extends StatelessWidget {
  const KycListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xffFBFBFB),
        appBar: AppBar(
          title: const Text(
            'Data & Verifikasi KYC',
            style: TextStyle(
              color: Color(0xff070623),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Color(0xff4A1DFF),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xff4A1DFF),
            indicatorWeight: 3,
            tabs: [
              Tab(text: "Menunggu"),
              Tab(text: "Semua User"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: Hanya yang PENDING
            _buildUserList(statusFilter: 'PENDING'),

            // TAB 2: SEMUA User
            _buildUserList(statusFilter: null),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList({String? statusFilter}) {
    Query query = FirebaseFirestore.instance.collection('User');
    if (statusFilter != null) {
      query = query.where('kycStatus', isEqualTo: statusFilter);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(statusFilter);
        }

        final users = snapshot.data!.docs;

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: users.length,
          separatorBuilder: (context, index) => const Gap(16),
          itemBuilder: (context, index) {
            final data = users[index].data() as Map<String, dynamic>;
            data['uid'] = users[index].id;
            final account = Account.fromJson(data);
            return _buildKycCard(context, account);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String? filter) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_user_outlined, size: 80, color: Colors.grey[300]),
          const Gap(16),
          Text(
            filter == 'PENDING'
                ? 'Tidak ada antrean KYC.'
                : 'Belum ada data user.',
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildKycCard(BuildContext context, Account account) {
    // Menyesuaikan ikon & warna berdasarkan status
    Color bgColor = const Color(0xffFFF4E5);
    Color iconColor = const Color(0xffFF9F00);
    IconData icon = Icons.pending_actions;
    String statusText = "Menunggu";

    if (account.kycStatus == 'VERIFIED') {
      bgColor = const Color(0xffE8F9EE);
      iconColor = const Color(0xff1AC75A);
      icon = Icons.check_circle;
      statusText = "Terverifikasi";
    } else if (account.kycStatus == 'REJECTED') {
      bgColor = const Color(0xffFFF1F3);
      iconColor = const Color(0xffFF2055);
      icon = Icons.cancel;
      statusText = "Ditolak";
    } else if (account.kycStatus == 'UNVERIFIED') {
      bgColor = const Color(0xffF3F4F6);
      iconColor = Colors.grey;
      icon = Icons.account_circle;
      statusText = "Belum Verifikasi";
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => KycDetailPage(account: account),
          ),
        );
      },
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
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xff070623),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(4),
                  Text(
                    account.email,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
                const Gap(8),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
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
