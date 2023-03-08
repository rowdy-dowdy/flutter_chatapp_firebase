import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/models/call_model.dart';
import 'package:flutter_chatapp_firebase/models/chat_model.dart';
import 'package:flutter_chatapp_firebase/pages/home_page.dart';
import 'package:flutter_chatapp_firebase/providers/call_provider.dart';
import 'package:flutter_chatapp_firebase/providers/chat_provider.dart';
import 'package:flutter_chatapp_firebase/utils/color.dart';
import 'package:flutter_chatapp_firebase/widgets/main_bottom_navbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CallPage extends ConsumerStatefulWidget {
  const CallPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CallPageState();
}

class _CallPageState extends ConsumerState<CallPage> with TickerProviderStateMixin {
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
      appBar: const HomeAppBar(),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: TabBar(
                    controller: tabController,
                    tabs: const [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text("All Call", style: TextStyle(fontWeight: FontWeight.w600),),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text("Missed Call", style: TextStyle(fontWeight: FontWeight.w600),),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: tabController,
                    children: const [
                      BodyListCall(),
                      Center(child: Text("Missed Call")),
                    ],
                  ),
                ),
              ],
            ),
            const Positioned(
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

class BodyListCall extends ConsumerWidget {
  const BodyListCall({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
        child: StreamBuilder<List<CallModel>>(
          stream: ref.watch(callControllerProvider).getCalls(),
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
                var call = snapshot.data![index];

                return Container(
                  margin: EdgeInsets.only(bottom: index == 20 - 1 ? 70 : 0),
                  child: InkWell(
                    onTap: () => context.go('/calls/${call.callId}'),
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
                                image: NetworkImage(call.callerPic),
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
                                          call.callerName,
                                          overflow: TextOverflow.clip,
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      const SizedBox(width: 5,),
                                      Text(DateFormat.MMMEd().format(DateTime.now()), style: const TextStyle(
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
                                          call.callerName,
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