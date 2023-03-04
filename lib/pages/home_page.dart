import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/models/chat_model.dart';
import 'package:flutter_chatapp_firebase/models/contact_model.dart';
import 'package:flutter_chatapp_firebase/providers/chat_provider.dart';
import 'package:flutter_chatapp_firebase/utils/color.dart';
import 'package:flutter_chatapp_firebase/widgets/main_bottom_navbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badges/badges.dart' as badges;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: const HomeAppBar(),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TabBar(
                    controller: tabController,
                    tabs: const [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text("Personal", style: TextStyle(fontWeight: FontWeight.w600),),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text("Group", style: TextStyle(fontWeight: FontWeight.w600),),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: tabController,
                    children: const [
                      BodyListContact(),
                      Center(child: Text("Group")),
                    ],
                  ),
                ),
                ],
            ),
            const Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: MainBottomNavBar(),
            )
          ],
        )
      ),
    );
  }
}


class HomeAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  final double height;
  const HomeAppBar({this.height = 60, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeAppBarState();
  
  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(height);
}

class _HomeAppBarState extends ConsumerState<HomeAppBar> {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(50)
                ),
                alignment: Alignment.center,
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded),
                    const SizedBox(width: 5,),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: 'Search chat or something here',
                          isDense: true,                      // Added this
                          contentPadding: EdgeInsets.all(0)
                        ),
                      ),
                    ),
                    const SizedBox(width: 5,),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10,),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                shape: BoxShape.circle
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.notifications)
            )
          ],
        ),
      ),
    );
  }
}


class BodyListContact extends ConsumerWidget {
  const BodyListContact({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: StreamBuilder<List<ChatModel>>(
          stream: ref.watch(chatControllerProvider).getContacts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 50),
                child: Center(child: CircularProgressIndicator())
              );
            }
            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: const Text("You don't have any friends 😢"),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var contact = snapshot.data![index];
                return Container(
                  margin: EdgeInsets.only(bottom: index == 20 - 1 ? 70 : 0),
                  child: InkWell(
                    onTap: () => context.go('/chats/${contact.contactId}'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: primary.withOpacity(0.7)),
                              image: DecorationImage(
                                image: NetworkImage(contact.profilePic),
                                fit: BoxFit.cover,
                              )
                            ),
                          ),
                          const SizedBox(width: 10,),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          contact.name,
                                          overflow: TextOverflow.clip,
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      const SizedBox(width: 5,),
                                      Text(DateFormat.Hm().format(contact.timeSent), style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey
                                      ),)
                                    ],
                                  ),
                                  const SizedBox(height: 5,),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          contact.lastMessage,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                                        ),
                                      ),
                                      const SizedBox(width: 5,),
                                      const Icon(Icons.done_all, size: 16,)
                                      // badges.Badge(
                                      //   badgeContent: Text(1.toString(), style: const TextStyle(color: Colors.grey),),
                                      //   badgeStyle: const badges.BadgeStyle(
                                      //     badgeColor: primary
                                      //   ),
                                      // )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        )
      ),
    );
  }
}


