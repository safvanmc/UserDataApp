import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class providerSorting extends ChangeNotifier {
  XFile? pickedFile;
  File? image;
  var imageUrl;
  var selecteditem;

  pickImage() async {
    final ImagePicker _picker = ImagePicker();
    try {
      pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        image = File(pickedFile!.path);

        // await uploadImage();
      }
    } catch (e) {
      print('Error picking image:${e}');
    }
    notifyListeners();
  }

  void clearImage() {
    image = null;
    notifyListeners();
  }

  String searchQuery = '';
  bool _isElderSelected = false;
  bool _isAllSelected = true;
  bool _isYoungerSelected = false;
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  ScrollController controller = ScrollController();
  List<DocumentSnapshot> data = [];
  late QuerySnapshot usersCollection;
  bool isLoading = false;
  bool isEmpty = false;

  void search() async {
    isEmpty = true;
    notifyListeners();
    data.clear();
    Query query = FirebaseFirestore.instance
        .collection('Users')
        .orderBy('name')
        .limit(12);

    if (_isAllSelected == false) {
      if (searchQuery.isEmpty) {
        if (_isElderSelected) {
          print('safwan');
          query = query.where('age', isGreaterThan: 60);
        } else if (_isYoungerSelected) {
          query = query.where('age', isLessThan: 60);
        }
        usersCollection = await query.get();
        print('elser');

        if (usersCollection.docs.isNotEmpty) {
          print('elder ok');
          data.addAll(usersCollection.docs);
        }
      } else {
        print("-------$searchQuery");
        query
            .where('name', isGreaterThanOrEqualTo: searchQuery)
            .where('name', isLessThan: searchQuery + 'z')
            .get()
            .then((querySnapshot) {
          print('-------all');
          querySnapshot.docs.isNotEmpty
              ? querySnapshot.docs.forEach((doc) {
                  print(doc.data());
                  data.add(doc);
                })
              : isEmpty = false;
          notifyListeners();
          ;
        });
      }
    }
    print('1all');
    if (_isAllSelected == true) {
      if (searchQuery.isNotEmpty) {
        print('2all');
        query
            .where('name', isGreaterThanOrEqualTo: searchQuery)
            .where('name', isLessThan: searchQuery + 'z')
            .get()
            .then((querySnapshot) {
          querySnapshot.docs.isNotEmpty
              ? querySnapshot.docs.forEach((doc) {
                  print('hhi');
                  data.add(doc);
                })
              : isEmpty = false;
          notifyListeners();
        });
      } else {
        usersCollection = await query.get();

        if (usersCollection.docs.isNotEmpty) {
          data.addAll(usersCollection.docs);
        }
      }
    }
    // isEmpty = false;
    notifyListeners();
  }

  void sort(context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          title: Text(
            'Sort',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
          ),
          titlePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10).w,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10).w,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          insetPadding: EdgeInsets.symmetric(horizontal: 50, vertical: 250).w,
          content: Column(
            children: [
              RadioListTile(
                title: Text(
                  "Age:All",
                  style: TextStyle(fontSize: 15.sp),
                ),
                value: true,
                groupValue: _isAllSelected,
                onChanged: (bool? value) {
                  _isAllSelected = value!;
                  _isElderSelected = false;
                  _isYoungerSelected = false;
                  search();
                  Navigator.pop(context);
                },
              ),
              RadioListTile(
                title: Text(
                  "Age:Elder",
                  style: TextStyle(fontSize: 15.sp),
                ),
                value: true,
                groupValue: _isElderSelected,
                onChanged: (bool? value) {
                  _isElderSelected = value!;
                  _isAllSelected = false;
                  _isYoungerSelected = false;
                  search();
                  Navigator.pop(context);
                },
              ),
              RadioListTile(
                title: Text(
                  "Age:Younger",
                  style: TextStyle(fontSize: 15.sp),
                ),
                value: true,
                groupValue: _isYoungerSelected,
                onChanged: (bool? value) {
                  _isYoungerSelected = value!;
                  _isAllSelected = false;
                  _isElderSelected = false;
                  search();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
    notifyListeners();
  }

  Future<void> loadNextData() async {
    print(isLoading);
    if (!isLoading) {
      isLoading = true;
      notifyListeners();
      Query usersQuery =
          FirebaseFirestore.instance.collection('Users').orderBy('name');
      if (_isAllSelected) {
        if (data.isNotEmpty) {
          usersQuery = usersQuery.startAfterDocument(data.last).limit(5);
          usersCollection = await usersQuery.get();
          await Future.delayed(Duration(seconds: 2));
          isLoading = false;

          if (usersCollection.docs.isNotEmpty) {
            data.addAll(usersCollection.docs);
          }
        } else {
          usersCollection = await usersQuery.get();
          isLoading = false;

          if (usersCollection.docs.isNotEmpty) {
            data.addAll(usersCollection.docs);
          }
        }
      }
      if (!_isAllSelected) {
        var elder;
        try {
          if (data.isNotEmpty) {
            if (_isElderSelected) {
              usersCollection =
                  await usersQuery.startAfterDocument(data.last).get();
              elder = usersCollection.docs.where((doc) => doc['age'] > 60);
            } else if (_isYoungerSelected) {
              usersCollection =
                  await usersQuery.startAfterDocument(data.last).get();
              elder = usersCollection.docs.where((doc) => doc['age'] < 60);
            }

            usersCollection = await usersQuery.get();

            await Future.delayed(Duration(seconds: 2));
            isLoading = false;

            if (usersCollection.docs.isNotEmpty) {
              data.addAll(elder);
            }
          }
        } catch (e) {
          print('error $e');
        }
      }
      notifyListeners();
    }
  }
}
