import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// هنشيل firebase_options مؤقتا عشان نفتح التطبيق
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool firebaseOk = true;
  try {
    await Firebase.initializeApp();
  } catch(e) {
    firebaseOk = false;
    debugPrint("Firebase فشل: $e");
  }
  runApp(MyApp(firebaseOk: firebaseOk));
}

class MyApp extends StatelessWidget {
  final bool firebaseOk;
  const MyApp({super.key, required this.firebaseOk});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(firebaseOk: firebaseOk),
    );
  }
}

class HomePage extends StatelessWidget {
  final bool firebaseOk;
  const HomePage({super.key, required this.firebaseOk});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oday Phone'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(firebaseOk ? Icons.check_circle : Icons.warning, size: 80, color: firebaseOk ? Colors.green : Colors.orange),
            const SizedBox(height: 20),
            Text(firebaseOk ? 'Oday Phone اشتغل ✅' : 'التطبيق فتح بس Firebase مش شغال', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: (){}, child: const Text('متجر الإكسسوارات')),
            const SizedBox(height: 10),
            if(!firebaseOk) const Padding(padding: EdgeInsets.all(20), child: Text('هبعتلك ملف firebase_options.dart الصح بعد ما ده يفتح', textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}
