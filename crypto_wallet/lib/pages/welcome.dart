import 'dart:math';
import 'package:crypto_wallet/pages/walletdetails.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto_wallet/pages/createwallet.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:flutter/services.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Client httpClient;
  late Web3Client ethClient;
  String privadd = "";
  EthereumAddress targetAddress = EthereumAddress.fromHex("");

  bool? created;
  var balance;
  var credentials;
  int myamount = 5;
  var pro_pic;
  var u_name;

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(
        "https://goerli.infura.io/v3/63d033148cca4f898a50d87bd6266a34",
        httpClient);
    details();
  }

  details() async {
    dynamic data = await getUserDetails();
    data != null
        ? setState(() {
            {
              privadd = data['privateKey'];
              var publicaddress = data['publicKey'];
              var temp = EthPrivateKey.fromHex(privadd);

              credentials = temp.address;

              created = data["wallet_created"];
              balance = getBalance(credentials);
            }
          })
        : const Center(
            child: Text("Data is null"),
          );
  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString("../assets/abi.json");
    //String contractAddress = "0xe61ed4a039f0d427A9E5C7BEa3064E09536aff8f";
    final contract = DeployedContract(ContractAbi.fromJson(abi, 'Gold'),
        EthereumAddress.fromHex("0xe61ed4a039f0d427A9E5C7BEa3064E09536aff8f"));
    return contract;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.call(
        contract: contract, function: ethFunction, params: args);
    return result;
  }

  Future<void> getBalance(EtherAmount credentialaddress) async {
    List<dynamic> result = await query("balanceOf", [credentialaddress]);
    var data = result[0];
    setState(() {
      balance = data;
    });
  }

  Future<String> sendCoin() async {
    var bigAmount = BigInt.from(myamount);
    var response = await submit("transfer", [targetAddress, bigAmount]);
    return response;
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(functionName);
    EthPrivateKey key = EthPrivateKey.fromHex(privadd);
    // await ethClient.sendTransaction(
    //   credentials,
    //   Transaction(
    //     to: EthereumAddress.fromHex(args[targetAddress]),
    //     gasPrice: EtherAmount.inWei(BigInt.one),
    //     maxGas: 100000,
    //     value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 1),
    //   ),
    // );
    Transaction transaction = await Transaction.callContract(
        contract: contract,
        function: ethFunction,
        parameters: args,
        maxGas: 100000);
    print(transaction.nonce);
    final result =
        await ethClient.sendTransaction(key, transaction, chainId: 4);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.photoURL == null) {
      pro_pic = "";
    } else {
      if (user != null) pro_pic = user.photoURL;
    }
    if (user?.displayName == null) {
      if (user != null) u_name = "User Name";
    } else {
      if (user != null) u_name = user.displayName;
    }
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        children: [
          Container(
            color: Colors.blue[500],
            height: 150,
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  image: DecorationImage(
                      image: NetworkImage(pro_pic), scale: 0.1)),
            ),
          ),
          Container(
              margin: const EdgeInsets.all(20),
              child: Text(
                u_name,
                style: const TextStyle(fontSize: 20, color: Colors.blueAccent),
              )),
          Container(
              margin: const EdgeInsets.all(5),
              alignment: Alignment.center,
              height: 100,
              width: 75,
              child: const Text("Balance",
                  style: TextStyle(fontSize: 50, color: Colors.black))),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(5),
            width: 75,
            child: Text(
              balance == null ? "0 GLD" : "${balance} GLD",
              style: const TextStyle(fontSize: 50, color: Colors.blueAccent),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(20),
            child: ElevatedButton(
                onPressed: () async {
                  var response = await sendCoin();
                  print(response);
                },
                child: const Text("Send Money"),
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green))),
          ),
          Container(
              margin: const EdgeInsets.all(10),
              child: ElevatedButton(
                  onPressed: () {
                    if (credentials != null) {
                      getBalance(credentials);
                    } else {
                      print("credentials null");
                    }
                  },
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.yellow)),
                  child: const Text("Get Balance"))),
          Container(
              margin: const EdgeInsets.only(top: 30, right: 40),
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                  onPressed: () {
                    if (mounted) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => const createwallet())));
                    }
                  },
                  child: const Icon(Icons.add)))
        ],
      ),
    );
  }
}
