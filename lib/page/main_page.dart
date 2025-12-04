import 'package:d_session/d_session.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ngibrit_in_cs/page/list_chat_page.dart';
import 'package:ngibrit_in_cs/page/orders_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [const ListChatPage(), const OrdersPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // [FIX] Tambahkan ini agar Bottom Nav TETAP DI BAWAH saat keyboard muncul
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
}
