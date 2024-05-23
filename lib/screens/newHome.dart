import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';
import 'package:userapp/Widgets/FloatingActionbtn.dart';
import 'package:userapp/Widgets/TextField.dart';
import 'package:userapp/provider/provider.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<providerSorting>(context, listen: false);
    provider.controller.addListener(() {
      if (provider.controller.offset >=
              provider.controller.position.maxScrollExtent &&
          !provider.controller.position.outOfRange &&
          !provider.isLoading) {
        print('bottom');
        provider.loadNextData();
      }
    });

    provider.search();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      floatingActionButton: FloatingActionBtn(
        context: context,
      ),
      body: Body(),
    );
  }
}

class Body extends StatelessWidget {
  const Body({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<providerSorting>(
        builder: (context, pro, child) => Column(
          children: [
            Container(
              color: Colors.grey.shade300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: CupertinoSearchTextField(
                              backgroundColor: Colors.white,
                              onChanged: (value) {
                                pro.searchQuery = value.toLowerCase();
                                pro.search();
                              },
                              controller: pro.searchController),
                        ),
                        Expanded(
                            child: IconButton(
                                onPressed: () {
                                  pro.sort(context);
                                },
                                icon: Icon(Icons.filter_list)))
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Text(
                      'Users List',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (pro.data.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  controller: pro.controller,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  itemCount:
                      pro.isLoading ? pro.data.length + 1 : pro.data.length,
                  itemBuilder: (context, index) {
                    if (pro.data.length == index) {
                      print('correct');
                      return Center(
                          child: JumpingDotsProgressIndicator(
                        fontSize: 40.sp,
                      ));
                    }
                    return Column(
                      children: [
                        ListTile(
                          leading: pro.data[index]['url'] == 'null'
                              ? CircleAvatar(
                                  radius: 30.r,
                                  backgroundImage:
                                      AssetImage('assets/image.png'),
                                  backgroundColor: Colors.grey,
                                )
                              : CircleAvatar(
                                  radius: 30.r,
                                  backgroundImage:
                                      NetworkImage(pro.data[index]['url']),
                                  backgroundColor: Colors.grey,
                                ),
                          title: Text(pro.data[index]['name']),
                          subtitle: Text('Age:${pro.data[index]['age']}'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          tileColor: Colors.white,
                        ),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    );
                  },
                ),
              )
            else if (pro.isEmpty)
              LinearProgressIndicator(
                color: Colors.black,
              )
            else
              Text('No Users'),
          ],
        ),
      ),
    );
  }
}
