import 'package:d_session/d_session.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ngibrit_in_cs/page/list_chat_page.dart';
import 'package:ngibrit_in_cs/page/orders_page.dart';
import 'package:ngibrit_in_cs/page/kyc_list_page.dart'; // [BARU] Import halaman KYC

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // [BARU] Tambahkan KycListPage ke urutan index 2
  final List<Widget> _pages = [const ListChatPage(), const OrdersPage(), const KycListPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      body: _pages[_selectedIndex],

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xff070623),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              index: 0,
              label: 'Chats',
              iconAsset: 'assets/ic_chats.png',
              iconAssetOn: 'assets/ic_chats_on.png',
            ),
            _buildNavItem(
              index: 1,
              label: 'Orders',
              iconAsset: 'assets/ic_orders.png',
              iconAssetOn: 'assets/ic_orders_on.png',
            ),
            // [BARU] Tombol Navigasi KYC (menggunakan Icon bawaan Flutter)
            _buildNavItemIcon(
              index: 2,
              label: 'KYC',
              iconData: Icons.fact_check_outlined,
              iconDataOn: Icons.fact_check_rounded,
            ),
            GestureDetector(
              onTap: () {
                DSession.removeUser().then((removed) {
                  if (!removed) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/signin',
                    (route) => false,
                  );
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout, color: Colors.white, size: 24),
                  const Gap(4),
                  const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi original menggunakan Asset
  Widget _buildNavItem({
    required int index,
    required String label,
    required String iconAsset,
    required String iconAssetOn,
  }) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            isActive ? iconAssetOn : iconAsset,
            width: 24,
            height: 24,
          ),
          const Gap(4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? const Color(0xffFFBC1C) : Colors.white,
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 4,
              width: 4,
              decoration: const BoxDecoration(
                color: Color(0xffFF2055),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  // [BARU] Fungsi nav item khusus menggunakan Icon (karena Anda belum punya aset KYC)
  Widget _buildNavItemIcon({
    required int index,
    required String label,
    required IconData iconData,
    required IconData iconDataOn,
  }) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isActive ? iconDataOn : iconData,
            size: 24,
            color: isActive ? const Color(0xffFFBC1C) : Colors.white,
          ),
          const Gap(4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? const Color(0xffFFBC1C) : Colors.white,
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 4,
              width: 4,
              decoration: const BoxDecoration(
                color: Color(0xffFF2055),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}