import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/utils/color.dart';
import 'package:flutter_chatapp_firebase/widgets/main_bottom_navbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badges/badges.dart' as badges;
import 'package:go_router/go_router.dart';

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
                          hintText: 'Search',
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
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: 20,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () => context.go('/chats/fdsfasdf'),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: primary,
                        image: DecorationImage(
                          image: NetworkImage("url"),
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
                              children: const [
                                Expanded(
                                  child: Text(
                                    "Viet Hung",
                                    overflow: TextOverflow.clip,
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(width: 5,),
                                Text("12:13 PM", style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey
                                ),)
                              ],
                            ),
                            const SizedBox(height: 3,),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    "Lorem ipsum dolor sit amet consectetur adipisicing elit. Quae magni fugiat, explicabo ad quos voluptatibus? Beatae qui, dolorem vel porro ut enim laborum magnam ipsam quidem dolores, repudiandae recusandae vitae!",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(color: Colors.grey, fontSize: 14),
                                  ),
                                ),
                                const SizedBox(width: 5,),
                                badges.Badge(
                                  badgeContent: Text(1.toString(), style: const TextStyle(color: Colors.grey),),
                                  badgeStyle: const badges.BadgeStyle(
                                    badgeColor: primary
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


