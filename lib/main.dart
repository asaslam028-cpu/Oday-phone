import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try { await Firebase.initializeApp(); } catch(e){ debugPrint("Firebase Error: $e"); }
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: HomePage()));
}

class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState() => _HomePageState(); }

class _HomePageState extends State<HomePage> {
  bool isAdmin = false;
  final ImagePicker _picker = ImagePicker();

  void checkAdmin(){
    final c = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('دخول الأدمن'),
      content: TextField(controller: c, obscureText: true, decoration: const InputDecoration(hintText: 'oday123')),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('إلغاء')),
        ElevatedButton(onPressed: (){ if(c.text.trim()=='oday123'){ setState(()=> isAdmin=true); Navigator.pop(context); } }, child: const Text('دخول'))
      ],
    ));
  }

  Future<void> changeBanner(String type) async {
    try {
      final XFile? img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 40);
      if(img==null) return;
      final bytes = await img.readAsBytes();
      await FirebaseFirestore.instance.collection('settings').doc('banners').set({type: base64Encode(bytes)}, SetOptions(merge: true));
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث البانر ✅')));
    } catch(e){
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    }
  }

  Widget bannerWidget(String type, double height, String hintText, Color bgColor) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('settings').doc('banners').snapshots(),
      builder: (context, snap) {
        Uint8List? bBytes;
        try {
          final data = snap.data?.data() as Map<String,dynamic>?;
          if(data?[type]!=null) bBytes = base64Decode(data![type]);
        } catch(_){}
        return InkWell(
          onTap: () => changeBanner(type),
          child: Container(
            height: height,
            width: double.infinity,
            color: bBytes==null ? bgColor : null,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if(bBytes!=null) Image.memory(bBytes, fit: BoxFit.cover) else Center(child: Text(hintText, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                if(isAdmin) Positioned(right: 8, top: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)), child: const Text('غير الصورة', style: TextStyle(color: Colors.white)))),
                // للعميل العادي برضه يقدر يدوس
                Positioned(left: 8, bottom: 8, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle), child: const Icon(Icons.camera_alt, color: Colors.white, size: 18))),
              ],
            ),
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
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('orders').snapshots(),
            builder: (context, snap){
              int count = snap.data?.docs.length ?? 0;
              return Stack(clipBehavior: Clip.none, children: [
                IconButton(icon: const Icon(Icons.notifications), onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> const OrdersPage()))),
                if(count>0) Positioned(right: 6, top: 6, child: Container(padding: const EdgeInsets.all(5), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 11)))),
              ]);
            }
          ),
          IconButton(icon: Icon(isAdmin?Icons.lock_open:Icons.lock), onPressed: checkAdmin),
        ],
      ),
      body: ListView(
        children: [
          // البانر العلوي - فاضي وتقدر تدوس عليه
          bannerWidget('topImage', 220, 'دوس هنا لرفع البانر العلوي 📸', Colors.blueGrey),

          Padding(padding: const EdgeInsets.all(12), child: SizedBox(height: 60, width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white), icon: const Icon(Icons.store), label: const Text('متجر الإكسسوارات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> const StorePage()))))),

          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [
            Expanded(child: Card(child: InkWell(onTap: () async { await FirebaseFirestore.instance.collection('orders').add({'type':'طلب مندوب','time':FieldValue.serverTimestamp()}); if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم طلب المندوب'))); }, child: const Padding(padding: EdgeInsets.all(20), child: Column(children: [Icon(Icons.delivery_dining, size: 40, color: Colors.orange), Text('اطلب مندوب')]))))),
            const SizedBox(width: 10),
            Expanded(child: Card(child: InkWell(onTap: () async { await FirebaseFirestore.instance.collection('orders').add({'type':'صيانة من المنزل','time':FieldValue.serverTimestamp()}); if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم طلب الصيانة'))); }, child: const Padding(padding: EdgeInsets.all(20), child: Column(children: [Icon(Icons.build, size: 40, color: Colors.green), Text('صيانة من المنزل')]))))),
          ])),

          const SizedBox(height: 12),

          // البانر السفلي - فاضي وتقدر تدوس عليه
          bannerWidget('bottomImage', 300, 'دوس هنا لرفع البانر السفلي 📸', Colors.black12),

          Container(width: double.infinity, color: Colors.black, padding: const EdgeInsets.all(12), child: const Text('الإسماعيلية - Oday Phone', textAlign: TextAlign.center, style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}

class OrdersPage extends StatelessWidget { const OrdersPage({super.key}); @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: const Text('الطلبات - الجرس')), body: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('orders').orderBy('time', descending: true).snapshots(), builder: (context, snap){ if(!snap.hasData) return const Center(child: CircularProgressIndicator()); if(snap.data!.docs.isEmpty) return const Center(child: Text('مفيش طلبات')); return ListView.builder(itemCount: snap.data!.docs.length, itemBuilder: (_, i){ final d = snap.data!.docs[i]; final data = d.data() as Map; return ListTile(title: Text(data['type']??''), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: ()=> d.reference.delete())); }); })); } }
class StorePage extends StatefulWidget { const StorePage({super.key}); @override State<StorePage> createState() => _StorePageState(); }
class _StorePageState extends State<StorePage> {
  final ref = FirebaseFirestore.instance.collection('products');
  final ImagePicker _picker = ImagePicker();
  Future<void> addProd() async {
    final nameC = TextEditingController(); final priceC = TextEditingController(); String? b64; Uint8List? prev;
    await showDialog(context: context, builder: (c)=> StatefulBuilder(builder: (c,setD)=> AlertDialog(title: const Text('منتج جديد'), content: Column(mainAxisSize: MainAxisSize.min, children: [GestureDetector(onTap: () async { final XFile? im = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 40); if(im!=null){ final b = await im.readAsBytes(); setD((){ prev=b; b64=base64Encode(b); }); } }, child: Container(height: 100, width: 100, color: Colors.grey[200], child: prev!=null?Image.memory(prev!):const Icon(Icons.add_a_photo))), TextField(controller: nameC, decoration: const InputDecoration(labelText: 'الاسم')), TextField(controller: priceC, decoration: const InputDecoration(labelText: 'السعر'))]), actions: [ElevatedButton(onPressed: () async { if(b64!=null&&nameC.text.isNotEmpty){ Navigator.pop(context); await ref.add({'name': nameC.text, 'price': priceC.text, 'imageBase64': b64}); } }, child: const Text('حفظ'))])));
  }
  @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: const Text('المتجر'), actions: [IconButton(icon: const Icon(Icons.add), onPressed: addProd)]), body: StreamBuilder<QuerySnapshot>(stream: ref.snapshots(), builder: (c,s){ if(!s.hasData) return const Center(child: CircularProgressIndicator()); final docs=s.data!.docs; return GridView.builder(padding: const EdgeInsets.all(10), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: docs.length, itemBuilder: (_,i){ final data=docs[i].data() as Map<String,dynamic>; Uint8List? ib; try{if(data['imageBase64']!=null) ib=base64Decode(data['imageBase64']);}catch(_){} return Card(child: Column(children: [Expanded(child: ib!=null?Image.memory(ib, fit: BoxFit.cover, width: double.infinity):Container(color: Colors.grey)), Padding(padding: const EdgeInsets.all(4), child: Text(data['name']??'')), Text('${data['price']??''} جنيه', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))])) ;});})); }
}
