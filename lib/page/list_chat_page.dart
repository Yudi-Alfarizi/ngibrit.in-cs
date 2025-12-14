import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ngibrit_in_cs/source/chat_source.dart';

class ListChatPage extends StatefulWidget {
  const ListChatPage({super.key});

  @override
  State<ListChatPage> createState() => _ListChatPageState();
}

class _ListChatPageState extends State<ListChatPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  late final Stream<QuerySnapshot<Map<String, dynamic>>> streamChats;

  @override
  void initState() {
    streamChats = FirebaseFirestore.instance
        .collection('CS')
        .orderBy('lastTime', descending: true)
        .snapshots();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap(20 + MediaQuery.of(context).padding.top),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Messages',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: Color(0xff070623),
            ),
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
              hintText: 'Cari nama user...',
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xff838384),
              ),
              prefixIcon: const Icon(Icons.search, color: Color(0xff838384)),
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
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Color(0xff4A1DFF)),
              ),
            ),
          ),
        ),

        const Gap(20),

        Expanded(child: buildList()),
      ],
    );
  }

  Widget buildList() {
    return StreamBuilder<QuerySnapshot>(
      stream: streamChats,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Tidak ada pesan'));
        }

        final allDocs = snapshot.data!.docs;
        final filteredList = allDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;

          final name = (data['name'] ?? '').toString().toLowerCase();
          final email = (data['email'] ?? '').toString().toLowerCase();
          final phone = (data['phone'] ?? '').toString().toLowerCase();

          return name.contains(_searchText) ||
              email.contains(_searchText) ||
              phone.contains(_searchText);
        }).toList();

        if (filteredList.isEmpty) {
          return const Center(child: Text('Tidak ditemukan chat yang sesuai'));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            Map room = (filteredList[index].data() as Map<String, dynamic>);
            String uid = room['roomId'] ?? '';
            String userName = room['name'] ?? 'User';
            bool newFromUser = room.containsKey('newFromUser')
                ? room['newFromUser']
                : false;

            String lastMsg = room['lastMessage'] ?? '...';

            return GestureDetector(
              onTap: () {
                ChatSource.setRead(uid);
                ChatSource.openChatRoom(uid, userName).then((value) {
                  Navigator.pushNamed(
                    context,
                    '/chatting',
                    arguments: {'uid': uid, 'userName': userName},
                  );
                });
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(24, 0, 24, 18),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
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
                    Image.asset('assets/profile.png', height: 50, width: 50),
                    const Gap(14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Color(0xff070623),
                            ),
                          ),
                          const Gap(2),
                          Text(
                            lastMsg,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: newFromUser
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              fontSize: 14,
                              color: newFromUser
                                  ? const Color(0xff070623)
                                  : const Color(0xff838384),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (newFromUser)
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xffFF2055),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
