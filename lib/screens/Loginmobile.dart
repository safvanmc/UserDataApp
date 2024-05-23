import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:userapp/screens/Otp.dart';

class SignMobile extends StatefulWidget {
  const SignMobile({super.key});

  @override
  State<SignMobile> createState() => _SignMobileState();
}

class _SignMobileState extends State<SignMobile> {
  //
  Future<void> getData() async {
    SharedPreferences spref = await SharedPreferences.getInstance();
    String mobile = '';
    mobile = phoneController.text;
    setState(() {
      spref.setString("num", mobile as String);
      print("mobile............$mobile");
    });
    print("Saf Updated");
  }

  //
  final TextEditingController phoneController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  void initState() {
    super.initState();
    _listenSmsCode();
  }

  _listenSmsCode() async {
    await SmsAutoFill().listenForCode();
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  String formatPhoneNumber(String phoneNumber, String countryCode) {
    String digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    return '+$countryCode$digits';
  }

  Future<void> otpNumber() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        showNoInternetNotification();
        return;
      }

      String phoneNumber = phoneController.text;
      String formattedPhoneNumber = formatPhoneNumber(phoneNumber, '91');

      print('Formatted Phone Number: $formattedPhoneNumber');

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            if (kDebugMode) {
              print('The provided phone number is not valid.');
            }
          } else {
            print('Verification failed: $e');
          }
        },
        codeSent: (String verificationId, int? resendToken) async {
          print('Verification code sent! Verification ID: $verificationId');
          Fluttertoast.showToast(
            msg: "Verification code sent!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OtpScreen(
                      verificationId: verificationId,
                    )),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('Auto retrieval timeout. Verification ID: $verificationId');
        },
      );
    } catch (e) {
      print("Error sending verification code: $e");
      Fluttertoast.showToast(
        msg: "Error sending verification code: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void showNoInternetNotification() {
    Fluttertoast.showToast(
      msg: "Please check your internet connection.",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Padding(
            padding: EdgeInsets.only(top: 50.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 250.h,
                  width: 250.w,
                  decoration: BoxDecoration(
                      image:
                          DecorationImage(image: AssetImage("assets/Mob.png"))),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Enter your Mobile Number",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 25),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "We Will send you a Confirmation Code",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w300, fontSize: 15),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 50.h, left: 50.w, right: 50.w),
            child: IntlPhoneField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              initialCountryCode: 'IN',
              onChanged: (phone) {
                if (kDebugMode) {
                  print(phone.completeNumber);
                }
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 100.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    getData();
                    otpNumber();
                  },
                  child: Container(
                    height: 50.h,
                    width: 250.w,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5.0,
                              offset: const Offset(0.0, 3.0)),
                        ]),
                    child: Center(
                        child: Text(
                      "Sent code",
                      style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    )),
                  ),
                )
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
