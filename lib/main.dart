import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try { await Firebase.initializeApp(); } catch(e) { print(e); }
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: HomePage()));
}

class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState() => _HomePageState(); }
class _HomePageState extends State<HomePage> {
  bool isAdmin = false;
  void checkAdmin(){
    final c = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('دخول الأدمن'),
      content: TextField(controller: c, obscureText: true),
      actions: [ElevatedButton(onPressed: (){ if(c.text=='oday123'){ setState(()=> isAdmin=true); Navigator.pop(context);} }, child: const Text('دخول'))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oday Phone'), backgroundColor: Colors.blue, foregroundColor: Colors.white,
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('orders').snapshots(),
            builder: (context, snap){
              int count = snap.data?.docs.length ?? 0;
              return Stack(children: [
                IconButton(icon: const Icon(Icons.notifications), onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> const OrdersPage()))),
                if(count>0) Positioned(right: 5, top: 5, child: Container(padding: const EdgeInsets.all(5), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 10)))),
              ]);
            }
          ),
          IconButton(icon: Icon(isAdmin?Icons.lock_open:Icons.lock), onPressed: checkAdmin),
        ],
      ),
      body: ListView(
        children: [
          Container(height: 200, color: Colors.blueGrey, child: const Center(child: Text('بانر Oday Phone العلوي', style: TextStyle(color: Colors.white, fontSize: 20)))),
          Padding(padding: const EdgeInsets.all(12), child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 60)), onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> const StorePage())), icon: const Icon(Icons.store), label: const Text('متجر الإكسسوارات', style: TextStyle(fontSize: 18)))),
          Padding(padding: const EdgeInsets.all(12), child: Row(children: [
            Expanded(child: Card(child: InkWell(onTap: () async { await FirebaseFirestore.instance.collection('orders').add({'type':'طلب مندوب','time':FieldValue.serverTimestamp()}); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم طلب المندوب'))); }, child: const Padding(padding: EdgeInsets.all(20), child: Column(children: [Icon(Icons.delivery_dining, size: 40, color: Colors.orange), Text('اطلب مندوب')]))))),
            const SizedBox(width: 10),
            Expanded(child: Card(child: InkWell(onTap: () async { await FirebaseFirestore.instance.collection('orders').add({'type':'صيانة من المنزل','time':FieldValue.serverTimestamp()}); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم طلب الصيانة'))); }, child: const Padding(padding: EdgeInsets.all(20), child: Column(children: [Icon(Icons.build, size: 40, color: Colors.green), Text('صيانة من المنزل')]))))),
          ])),
          Container(height: 250, color: Colors.black12, child: const Center(child: Text('بانر سفلي - مكان الصور'))),
          Container(color: Colors.black, padding: const EdgeInsets.all(10), child: const Text('الإسماعيلية - Oday Phone', textAlign: TextAlign.center, style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}

class OrdersPage extends StatelessWidget { const OrdersPage({super.key}); @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: const Text('الطلبات')), body: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('orders').snapshots(), builder: (context, snap){ if(!snap.hasData) return const Center(child: CircularProgressIndicator()); if(snap.data!.docs.isEmpty) return const Center(child: Text('مفيش طلبات')); return ListView.builder(itemCount: snap.data!.docs.length, itemBuilder: (_, i){ final d = snap.data!.docs[i]; final data = d.data() as Map; return ListTile(title: Text(data['type']??''), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: ()=> d.reference.delete())); }); })); } }
class StorePage extends StatelessWidget { const StorePage({super.key}); @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: const Text('المتجر')), body: const Center(child: Text('المتجر هيظهر هنا بعد ما التطبيق يفتح'))); } }
