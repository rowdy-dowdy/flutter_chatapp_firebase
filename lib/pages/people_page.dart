import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/models/user_model.dart';
import 'package:flutter_chatapp_firebase/pages/home_page.dart';
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
              bottom: 15,
              left: 15,
              right: 15,
              child: MainBottomNavBar(),
            )
          ],
        )
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
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
              margin: const EdgeInsets.only(left: 5),
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


