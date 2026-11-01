import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase Error: $e");
  }
  runApp(const OdayPhoneApp());
}

class OdayPhoneApp extends StatelessWidget {
  const OdayPhoneApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Oday Phone',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isAdmin = false;
  final ImagePicker _picker = ImagePicker();

  void checkAdmin() {
    final c = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('دخول الأدمن'),
      content: TextField(controller: c, obscureText: true, decoration: const InputDecoration(hintText: 'oday123')),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('إلغاء')),
        ElevatedButton(onPressed: (){ if(c.text.trim()=='oday123'){ setState(()=> isAdmin=true); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تفعيل وضع الأدمن')));} }, child: const Text('دخول'))
      ],
    ));
  }

  Future<void> changeBanner(String type) async {
    try {
      final XFile? img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 30);
      if(img==null) return;
      final bytes = await img.readAsBytes();
      await FirebaseFirestore.instance.collection('settings').doc('banners').set({type: base64Encode(bytes)}, SetOptions(merge: true));
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث البانر ✅')));
    } catch(e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blue, foregroundColor: Colors.white, title: const Text('Oday Phone'),
        actions: [
          // الجرس الجديد بعدد الطلبات
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('orders').snapshots(),
            builder: (context, snap) {
              int count = snap.data?.docs.length ?? 0;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(icon: const Icon(Icons.notifications), onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> const OrdersPage()))),
                  if(count>0) Positioned(right: 6, top: 6, child: Container(padding: const EdgeInsets.all(5), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: Text('$count', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)))),
                ],
              );
            },
          ),
          IconButton(icon: Icon(isAdmin?Icons.lock_open:Icons.lock), onPressed: checkAdmin)
        ]),
      body: ListView(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('settings').doc('banners').snapshots(),
            builder: (context, snap) {
              Uint8List? topBytes;
              try { final data = snap.data?.data() as Map<String,dynamic>?; if(data?['topImage']!=null) topBytes=base64Decode(data!['topImage']); }catch(_){}
              return SizedBox(height: 220, child: Stack(children: [
                Positioned.fill(child: topBytes!=null ? Image.memory(topBytes, fit: BoxFit.cover) : Image.asset('assets/images/IMG-20261031-WA9506.jpg', fit: BoxFit.cover, errorBuilder: (c,e,s)=> Image.asset('IMG-20261031-WA9506.jpg', fit: BoxFit.cover, errorBuilder: (_,__,___)=> Container(color: Colors.blueGrey, child: const Center(child: Text('Oday Phone - البانر العلوي', style: TextStyle(color: Colors.white, fontSize: 18))))))),
                if(isAdmin) Positioned(right: 8, top: 8, child: ElevatedButton(onPressed: ()=> changeBanner('topImage'), child: const Text('غير فوق'))),
              ]));
            },
          ),
          Padding(padding: const EdgeInsets.all(12), child: SizedBox(height: 60, width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), icon: const Icon(Icons.store), label: const Text('متجر الإكسسوارات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> const StorePage()))))),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [
            Expanded(child: Card(child: InkWell(onTap: () async { try { await FirebaseFirestore.instance.collection('orders').add({'type': 'طلب مندوب', 'customer': 'عميل', 'time': FieldValue.serverTimestamp()}); if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم طلب المندوب ✅')));} catch(e){} }, child: const Padding(padding: EdgeInsets.all(15), child: Column(children: [Icon(Icons.delivery_dining, color: Colors.orange, size: 32), SizedBox(height: 5), Text('اطلب مندوب', style: TextStyle(fontWeight: FontWeight.bold))]))))),
            const SizedBox(width: 10),
            Expanded(child: Card(child: InkWell(onTap: () async { try { await FirebaseFirestore.instance.collection('orders').add({'type': 'صيانة من المنزل', 'customer': 'عميل', 'time': FieldValue.serverTimestamp()}); if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم طلب الصيانة ✅')));} catch(e){} }, child: const Padding(padding: EdgeInsets.all(15), child: Column(children: [Icon(Icons.build, color: Colors.green, size: 32), SizedBox(height: 5), Text('صيانة من المنزل', style: TextStyle(fontWeight: FontWeight.bold))]))))),
          ])),
          const SizedBox(height: 12),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('settings').doc('banners').snapshots(),
            builder: (context, snap) {
              Uint8List? bBytes;
              try { final data = snap.data?.data() as Map<String,dynamic>?; if(data?['bottomImage']!=null) bBytes=base64Decode(data!['bottomImage']); }catch(_){}
              return SizedBox(height: 300, child: Stack(children: [
                Positioned.fill(child: bBytes!=null ? Image.memory(bBytes, fit: BoxFit.cover) : Image.asset('assets/images/IMG-20261031-WA4508.jpg', fit: BoxFit.cover, errorBuilder: (c,e,s)=> Image.asset('IMG-20261031-WA4508.jpg', fit: BoxFit.cover, errorBuilder: (_,__,___)=> Container(color: Colors.black12, child: const Center(child: Text('البانر السفلي')))))),
                if(isAdmin) Positioned(right: 8, top: 8, child: ElevatedButton(onPressed: ()=> changeBanner('bottomImage'), child: const Text('غير تحت'))),
              ]));
            },
          ),
          Container(width: double.infinity, color: Colors.black, padding: const EdgeInsets.all(12), child: const Text('الإسماعيلية - Oday Phone - 01223456789', textAlign: TextAlign.center, style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('الطلبات - الجرس'), backgroundColor: Colors.blue, foregroundColor: Colors.white), body: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('orders').orderBy('time', descending: true).snapshots(), builder: (context, snap) {
      if(snap.hasError) return Center(child: Text('خطأ: ${snap.error}'));
      if(!snap.hasData) return const Center(child: CircularProgressIndicator());
      if(snap.data!.docs.isEmpty) return const Center(child: Text('مفيش طلبات حاليا - الجرس فاضي'));
      return ListView.builder(itemCount: snap.data!.docs.length, itemBuilder: (_, i){ final d = snap.data!.docs[i]; final data = d.data() as Map; return Card(margin: const EdgeInsets.all(8), child: ListTile(leading: const Icon(Icons.notifications_active, color: Colors.blue), title: Text(data['type']??'طلب'), subtitle: Text(data['customer']??''), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: ()=> d.reference.delete()))); });
    }));
  }
}

class StorePage extends StatefulWidget {
  const StorePage({super.key});
  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final ref = FirebaseFirestore.instance.collection('products');
  final ImagePicker _picker = ImagePicker();
  Future<void> addProd() async {
    final nameC = TextEditingController(); final priceC = TextEditingController(); String? b64; Uint8List? prev;
    await showDialog(context: context, builder: (c)=> StatefulBuilder(builder: (c,setD)=> AlertDialog(title: const Text('منتج جديد'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [GestureDetector(onTap: () async { final XFile? im = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 40); if(im!=null){ final b = await im.readAsBytes(); setD((){ prev=b; b64=base64Encode(b); }); } }, child: Container(height: 120, width: 120, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)), child: prev!=null?ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.memory(prev!, fit: BoxFit.cover)):const Icon(Icons.add_a_photo, size: 40))), const SizedBox(height: 10), TextField(controller: nameC, decoration: const InputDecoration(labelText: 'اسم المنتج', border: OutlineInputBorder())), const SizedBox(height: 8), TextField(controller: priceC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر جنيه', border: OutlineInputBorder()))])), actions: [TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('إلغاء')), ElevatedButton(onPressed: () async { if(b64!=null&&nameC.text.isNotEmpty){ Navigator.pop(context); await ref.add({'name': nameC.text, 'price': priceC.text, 'imageBase64': b64, 'createdAt': FieldValue.serverTimestamp()}); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت الإضافة ✅'))); } }, child: const Text('حفظ'))])));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('متجر الإكسسوارات'), backgroundColor: Colors.blue, foregroundColor: Colors.white, actions: [IconButton(icon: const Icon(Icons.add), onPressed: addProd)]), body: StreamBuilder<QuerySnapshot>(stream: ref.orderBy('createdAt', descending: true).snapshots(), builder: (c,s){ if(!s.hasData) return const Center(child: CircularProgressIndicator()); final docs=s.data!.docs; if(docs.isEmpty) return const Center(child: Text('المتجر فاضي - دوس + عشان تضيف')); return GridView.builder(padding: const EdgeInsets.all(10), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: docs.length, itemBuilder: (_,i){ final data=docs[i].data() as Map<String,dynamic>; Uint8List? ib; try{if(data['imageBase64']!=null) ib=base64Decode(data['imageBase64']);}catch(_){} return Card(elevation: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(10)), child: ib!=null?Image.memory(ib, fit: BoxFit.cover, width: double.infinity):Container(color: Colors.grey[300], child: const Icon(Icons.image)))), Padding(padding: const EdgeInsets.all(6), child: Column(children: [Text(data['name']??'', style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis), const SizedBox(height: 2), Text('${data['price']??''} جنيه', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: ()=> docs[i].reference.delete())]))]));});}));
  }
}
