import 'package:flutter/material.dart';
import 'package:miserend/near_churches_page.dart';

const List<Tab> tabs = <Tab>[
  Tab(text: 'Közeli'),
  Tab(text: 'Kedvencek'),
];

class ChurchesPage extends StatelessWidget {
  const ChurchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      // The Builder widget is used to have a different BuildContext to access
      // closest DefaultTabController.
      child: Builder(builder: (BuildContext context) {
        final TabController tabController = DefaultTabController.of(context)!;
        tabController.addListener(() {
          if (!tabController.indexIsChanging) {
            // Your code goes here.
            // To get index of current tab use tabController.index
          }
        });
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Material(
              elevation: 4,
              child: Container(
                color: Theme.of(context).primaryColor,
                child: TabBar(
                  tabs: tabs,
                  indicatorColor: Colors.white,
                ),
              ),
            ),
          ),
          body: const TabBarView(
            children: [
              NearChurchesPage(),
              NearChurchesPage(),
            ],
          ),
        );
      }),
    );
  }
}
