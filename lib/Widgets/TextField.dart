import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.text,
    required this.validator,
    required this.keyboardType,
  });

  final TextEditingController controller;
  final String text;
  final String? Function(String? p1)? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text),
        SizedBox(
          height: 10,
        ),
        TextFormField(
            keyboardType: keyboardType,
            validator: validator,
            controller: controller,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              isDense: true,
              focusedBorder:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10.w)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.w),
              ),
            )),
      ],
    );
  }
}
