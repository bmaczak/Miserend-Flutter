import 'package:flutter/material.dart';
import 'package:miserend/database/church_with_masses.dart';
import 'package:miserend/database/miserend_database.dart';
import 'package:miserend/home/churches/church_list_item.dart';

class SearchParams {
  String? city;
  String? searchTerm;

  static SearchParams fromCity(String city)
  {
    var param = SearchParams();
    param.city = city;
    return param;
  }

  static SearchParams fromSearchTerm(String searchTerm)
  {
    var param = SearchParams();
    param.searchTerm = searchTerm;
    return param;
  }

  @override
  String toString() {
    return city != null ? city! : searchTerm!;
  }
}

class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({super.key, required this.searchParams});

  final SearchParams searchParams;

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage>  with
    AutomaticKeepAliveClientMixin<SearchResultsPage>{

  List<ChurchWithMasses> churches = <ChurchWithMasses>[];

  @override
  void initState() {
    super.initState();
    loadChurches();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.searchParams.toString()),
        ),
      body: Container(
        color: Colors.black12,
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: churches.length,
          itemBuilder: (BuildContext context, int index) {
            return ChurchListItem(
                churchWithMasses: churches[index]
            );
          },
        ),
      ),
    );
  }

  Future<void> loadChurches() async {
    MiserendDatabase db = await MiserendDatabase.create();
    List<ChurchWithMasses> list;
    if (widget.searchParams.city != null) {
      list = await db.getChurchesWithMassesForCity(widget.searchParams.city!);
    }
    else {
      list = await db.getChurchesWithMassesForSearchTerm(widget.searchParams.searchTerm!);
    }
    setState(() {
      churches = list;
    });
  }

  @override
  bool get wantKeepAlive => true;
}
