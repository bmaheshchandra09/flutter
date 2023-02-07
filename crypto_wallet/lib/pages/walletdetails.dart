//import 'package:crypto_wallet/pages/walletdetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void addUserDetails(privatekey, publickey) async {
  var userInstance = FirebaseAuth.instance.currentUser;
  await FirebaseFirestore.instance
      .collection("users")
      .doc(userInstance?.uid)
      .set({
        'user_name': userInstance?.displayName,
        'privateKey': privatekey.toString(),
        'publicKey': publickey.toString(),
        'wallet_created': true
      })
      .whenComplete(() => {print("executed")})
      .catchError((error) {
        //print(error.toString());
      });
}

Future<dynamic> getUserDetails() async {
  dynamic data;
  var userInstance = FirebaseAuth.instance.currentUser;
  final DocumentReference document =
      FirebaseFirestore.instance.collection("users").doc(userInstance?.uid);
  await document.get().then<dynamic>((DocumentSnapshot snapshot) {
    data = snapshot.data();
  });
  return data;
}
