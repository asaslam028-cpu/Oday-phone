import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch(e) {
    debugPrint("Firebase: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  Future<void> uploadBanner(String name) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if(image == null) return;
    final bytes = await image.readAsBytes();
    final b64 = base64Encode(bytes);
    await FirebaseFirestore.instance.collection('settings').doc('banners').set({name: b64}, SetOptions(merge: true));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اترفع ✅')));
  }
  Widget bannerWidget(String name, double h, String label) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('settings').doc('banners').snapshots(),
      builder: (context, snap) {
        String? b64;
        if(snap.hasData && snap.data!.data()!=null) b64 = (snap.data!.data() as Map<String,dynamic>)[name];
        return GestureDetector(
          onTap: ()=>uploadBanner(name),
          child: Container(height: h, width: double.infinity, margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.blueGrey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue)),
            child: b64!=null ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(base64Decode(b64), fit: BoxFit.cover)) : Center(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oday Phone'), backgroundColor: Colors.blue, foregroundColor: Colors.white,
        actions: [
          StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('orders').snapshots(),
            builder: (context, snapshot) {
              int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
              return Stack(children: [
                IconButton(icon: const Icon(Icons.notifications), onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const OrdersPage()))),
                if(count>0) Positioned(right: 8, top: 8, child: CircleAvatar(radius: 9, backgroundColor: Colors.red, child: Text('$count', style: const TextStyle(fontSize: 10, color: Colors.white)))),
              ]);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(child: Column(children: [
        bannerWidget('topImage', 180, 'دوس هنا لرفع البانر العلوي'),
        Padding(padding: const EdgeInsets.all(12), child: ElevatedButton(style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.blue), onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const StorePage())), child: const Text('متجر الإكسسوارات', style: TextStyle(color: Colors.white, fontSize: 18)))),
        Row(children: [
          Expanded(child: Padding(padding: const EdgeInsets.all(8), child: ElevatedButton(onPressed: (){FirebaseFirestore.instance.collection('orders').add({'type': 'طلب مندوب', 'time': DateTime.now()}); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم')));}, child: const Text('اطلب مندوب')))),
          Expanded(child: Padding(padding: const EdgeInsets.all(8), child: ElevatedButton(onPressed: (){FirebaseFirestore.instance.collection('orders').add({'type': 'صيانة من المنزل', 'time': DateTime.now()}); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم')));}, child: const Text('صيانة من المنزل')))),
        ]),
        bannerWidget('bottomImage', 300, 'دوس هنا لرفع البانر السفلي'),
        Container(width: double.infinity, color: Colors.black87, padding: const EdgeInsets.all(12), child: const Text('الإسماعيلية - Oday Phone', textAlign: TextAlign.center, style: TextStyle(color: Colors.white))),
      ])),
    );
  }
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('الطلبات')), body: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('orders').orderBy('time', descending: true).snapshots(), builder: (context, snap){ if(!snap.hasData) return const Center(child: CircularProgressIndicator()); return ListView(children: snap.data!.docs.map((d){ final data = d.data() as Map<String,dynamic>; return ListTile(title: Text(data['type']??''), subtitle: Text((data['time'] as Timestamp?)?.toDate().toString()??''), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: ()=>d.reference.delete()));}).toList());}));
  }
}

class StorePage extends StatelessWidget {
  const StorePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('متجر الإكسسوارات'), actions: [IconButton(icon: const Icon(Icons.add), onPressed: () async { final picker = ImagePicker(); final XFile? img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50); if(img==null) return; final bytes = await img.readAsBytes(); final b64 = base64Encode(bytes); FirebaseFirestore.instance.collection('products').add({'name': 'اكسسوار', 'price': '100', 'imageBase64': b64});})]), body: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('products').snapshots(), builder: (context, snap){ if(!snap.hasData) return const Center(child: CircularProgressIndicator()); return GridView.count(crossAxisCount: 2, children: snap.data!.docs.map((d){ final data = d.data() as Map<String,dynamic>; return Card(child: Column(children: [Expanded(child: data['imageBase64']!=null ? Image.memory(base64Decode(data['imageBase64']), fit: BoxFit.cover) : const Icon(Icons.image)), Text(data['name']??''), Text('${data['price']??''} جنيه')]));}).toList());}));
  }
}
