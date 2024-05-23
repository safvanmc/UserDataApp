import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:userapp/Widgets/TextField.dart';
import 'package:userapp/provider/provider.dart';

class FloatingActionBtn extends StatelessWidget {
  const FloatingActionBtn({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      shape: CircleBorder(),
      backgroundColor: Color.fromARGB(255, 30, 29, 29),
      child: Icon(
        Icons.add,
        color: Colors.white,
      ),
      onPressed: () {
        add(context);
      },
    );
  }

  add(
    BuildContext context,
  ) {
    TextEditingController name = TextEditingController();
    TextEditingController age = TextEditingController();
    final formkey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => Consumer<providerSorting>(
        builder: (context, pro, child) => AlertDialog(
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              'Add A New User',
              style: TextStyle(fontSize: 20.sp),
            ),
          ),
          content: Form(
            key: formkey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      pro.image == null
                          ? Image.asset(
                              'assets/image.png',
                              scale: 10,
                            )
                          : CircleAvatar(
                              radius: 40.r,
                              backgroundImage: FileImage(
                                pro.image!,
                              ),
                            ),
                      IconButton(
                          onPressed: () {
                            pro.pickImage();
                          },
                          icon: const Icon(
                            Icons.camera_alt_outlined,
                            size: 10,
                          ))
                    ],
                  ),
                  CustomTextField(
                      controller: name,
                      text: 'Name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'empty field';
                        }
                      },
                      keyboardType: TextInputType.text),
                  SizedBox(
                    height: 10.h,
                  ),
                  CustomTextField(
                      controller: age,
                      text: 'Age',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          print('saf');
                          return 'empty field';
                        }
                      },
                      keyboardType: TextInputType.number),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
          actions: [
            MaterialButton(
              color: Colors.grey,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.w)),
              onPressed: () {
                Navigator.pop(context);
                pro.clearImage();
              },
              child: Text('cancel',
                  style: TextStyle(fontSize: 15.sp, color: Colors.black)),
            ),
            MaterialButton(
              color: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.w)),
              onPressed: () async {
                if (formkey.currentState!.validate()) {
                  if (pro.image != null) {
                    String _name = pro.pickedFile!.path;
                    Reference storageReference =
                        FirebaseStorage.instance.ref().child('profile/$_name');
                    await storageReference.putFile(File(pro.image!.path));

                    // get the dowloadnurl  //
                    pro.imageUrl = await storageReference.getDownloadURL();
                  } else {
                    pro.imageUrl = 'null';
                  }
                  await FirebaseFirestore.instance
                      .collection('Users')
                      .add({
                        'name': name.text,
                        'age': int.parse(age.text),
                        'url': pro.imageUrl
                      })
                      .then((value) => Navigator.pop(context))
                      .then((value) => pro.search())
                      .then((value) => pro.clearImage());

                  print(age.text);
                }
                ;
              },
              child: Text('Save',
                  style: TextStyle(fontSize: 15.sp, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
