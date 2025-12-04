import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:ngibrit_in_cs/models/order_model.dart';
import 'package:ngibrit_in_cs/page/order_detail_page.dart';
import 'package:ngibrit_in_cs/source/order_source.dart';
import 'package:ngibrit_in_cs/widgets/cs_order_card.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  String _sortOrder = 'desc';
  bool _isOverdueFilter = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xffF8F8FA),
        // [FIX Poin 4] ResizeToAvoidBottomInset: false agar Bottom Nav tidak naik saat keyboard muncul
        resizeToAvoidBottomInset: false,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(20 + MediaQuery.of(context).padding.top),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/logo_text.png', height: 28),
                  GestureDetector(
                    onTap: _showFilterBottomSheet,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xffE5E7EB)),
                      ),
                      child: Image.asset(
                        'assets/ic_filter.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Gap(20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchText = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari user, no. pesanan, motor...',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xff838384),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xff838384),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Color(0xffE5E7EB)),
                  ),
                ),
              ),
            ),

            const Gap(16),

            Container(
              height: 45,
              margin: const EdgeInsets.only(left: 24),
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xff838384),
                indicator: BoxDecoration(
                  color: const Color(0xff4A1DFF),
                  borderRadius: BorderRadius.circular(25),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                dividerColor: Colors.transparent,
                tabs: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Tab(text: 'Semua'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Tab(text: 'Sedang Dikirim'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Tab(text: 'Berlangsung'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Tab(text: 'Selesai'),
                  ),
                ],
              ),
            ),

            const Gap(16),

            Expanded(
              child: TabBarView(
                children: [
                  _buildOrderList('Semua'),
                  _buildOrderList('Dikirim'),
                  _buildOrderList('Berlangsung'),
                  _buildOrderList('Selesai'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(String tabStatus) {
    return StreamBuilder<QuerySnapshot>(
      stream: OrderSource.getAllOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Belum ada data'));
        }

        final allDocs = snapshot.data!.docs;
        List<OrderModel> orders = allDocs.map((doc) {
          return OrderModel.fromJson(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }).toList();

        if (tabStatus != 'Semua') {
          orders = orders.where((o) => o.status == tabStatus).toList();
        }

        if (_searchText.isNotEmpty) {
          orders = orders.where((o) {
            final name = o.userName.toLowerCase();
            final id = o.id.toLowerCase();
            final motor = o.bikeSnapshot['name'].toString().toLowerCase();
            return name.contains(_searchText) ||
                id.contains(_searchText) ||
                motor.contains(_searchText);
          }).toList();
        }

        // [FIX Poin 2B & 2C] Logic Filter Overdue
        // Jika sedang di tab "Selesai", filter overdue diabaikan/dimatikan
        if (_isOverdueFilter && tabStatus != 'Selesai') {
          final now = DateTime.now();
          orders = orders.where((o) {
            // [FIX 2C] Di Tab "Semua", jika status Selesai, jangan dianggap overdue
            if (o.status == 'Selesai') return false;

            try {
              final end = DateFormat('dd MMM yyyy').parse(o.endDate);
              // Tambah 1 hari toleransi agar pas di hari H belum dianggap overdue, atau sesuaikan logic bisnis
              // Di sini kita anggap overdue jika HARI INI > TANGGAL AKHIR
              final endDay = DateTime(end.year, end.month, end.day);
              final today = DateTime(now.year, now.month, now.day);
              return today.isAfter(endDay);
            } catch (e) {
              return false;
            }
          }).toList();
        }

        // [FIX Poin 2A] Sort by Created At (Tanggal Pesanan)
        orders.sort((a, b) {
          if (_sortOrder == 'desc') {
            return b.createdAt.compareTo(a.createdAt);
          } else {
            return a.createdAt.compareTo(b.createdAt);
          }
        });

        if (orders.isEmpty) {
          return Center(child: Text('Tidak ada pesanan ditemukan'));
        }

        return ListView.separated(
          // [FIX Poin 1C] Padding bawah lebih besar (120) agar item terakhir tidak tertutup bottom nav
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
          itemCount: orders.length,
          separatorBuilder: (c, i) => const Gap(16),
          itemBuilder: (context, index) {
            final order = orders[index];
            return CSOrderCard(
              order: order,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => OrderDetailPage(orderModel: order),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Filter Pesanan",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const Gap(20),

                  const Text(
                    "Urutkan",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const Gap(10),
                  Row(
                    children: [
                      _filterChip("Terbaru", _sortOrder == 'desc', () {
                        setModalState(() => _sortOrder = 'desc');
                        setState(() {});
                      }),
                      const Gap(10),
                      _filterChip("Terlama", _sortOrder == 'asc', () {
                        setModalState(() => _sortOrder = 'asc');
                        setState(() {});
                      }),
                    ],
                  ),

                  const Gap(20),
                  // [FIX Poin 2B] Sembunyikan Opsi Overdue Filter Jika User sedang di Tab Selesai (Logic View Only)
                  // Namun karena BottomSheet ini global, kita biarkan saja toggle-nya, tapi logic di list builder sudah menghandle pengecualiannya.
                  const Text(
                    "Status Waktu",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const Gap(10),
                  _filterChip("Melewati Tanggal Akhir", _isOverdueFilter, () {
                    setModalState(() => _isOverdueFilter = !_isOverdueFilter);
                    setState(() {});
                  }),

                  const Gap(30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff4A1DFF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Terapkan Filter",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _filterChip(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xff4A1DFF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xff4A1DFF) : const Color(0xffE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : const Color(0xff838384),
          ),
        ),
      ),
    );
  }
}
