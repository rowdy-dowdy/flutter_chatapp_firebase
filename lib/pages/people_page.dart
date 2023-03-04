import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/models/user_model.dart';
import 'package:flutter_chatapp_firebase/providers/chat_provider.dart';
import 'package:flutter_chatapp_firebase/utils/color.dart';
import 'package:flutter_chatapp_firebase/widgets/main_bottom_navbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PeoplePage extends ConsumerWidget {
  const PeoplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: const HomeAppBar(),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: const [
            BodyListContact(),
            Positioned(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
              decoration: BoxDecoration(
                color: blue3,
                borderRadius: BorderRadius.circular(4)
              ),
              child: const Text("Anonymous", style: TextStyle(
                color: blue,
                fontSize: 10,
                fontWeight: FontWeight.w600
              ),),
            ),
            const SizedBox(height: 5,),
            StreamBuilder<List<UserModel>>(
              stream: ref.watch(chatControllerProvider).getUsers(),
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
                    child: const Text("There are no users using this app 😢"),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {

                    var user = snapshot.data![index];

                    return Container(
                      margin: EdgeInsets.only(bottom: index == 20 - 1 ? 70 : 0),
                      child: InkWell(
                        onTap: () => context.go('/chats/${user.uid}'),
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
                                  // color: primary,
                                  image: DecorationImage(
                                    image: NetworkImage(user.profilePic),
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
                                      Text(
                                        user.name,
                                        overflow: TextOverflow.clip,
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 5,),
                                      Text(
                                        user.isOnline ? "Online" : "Offline",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
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
            ),
          ],
        )
      ),
    );
  }
}


