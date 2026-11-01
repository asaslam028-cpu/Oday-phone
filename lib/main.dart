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
  } catch(e) { debugPrint("Firebase: $e"); }
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
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('البانر اترفع ✅')));
  }

  // دي الدالة الجديدة بتاعة طلب المندوب والصيانة ببيانات
  Future<void> showOrderDialog(String type) async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final problemCtrl = TextEditingController();
    
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(type),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'الاسم')),
        TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'رقم التليفون'), keyboardType: TextInputType.phone),
        TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'العنوان بالتفصيل')),
        if(type.contains('صيانة')) TextField(controller: problemCtrl, decoration: const InputDecoration(labelText: 'نوع العطل - مثلا شاشة مكسورة'), maxLines: 3),
        if(type.contains('مندوب')) TextField(controller: problemCtrl, decoration: const InputDecoration(labelText: 'عايز ايه من المندوب؟'), maxLines: 3),
      ])),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text('الغاء')),
        ElevatedButton(onPressed: () async {
          if(nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اكتب الاسم ورقم التليفون')));
            return;
          }
          await FirebaseFirestore.instance.collection('orders').add({
            'type': type,
            'name': nameCtrl.text,
            'phone': phoneCtrl.text,
            'address': addressCtrl.text,
            'details': problemCtrl.text,
            'time': DateTime.now(),
            'status': 'جديد'
          });
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم ارسال $type بنجاح ✅')));
        }, child: const Text('ارسال الطلب')),
      ],
    ));
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
          Expanded(child: Padding(padding: const EdgeInsets.all(8), child: ElevatedButton(onPressed: ()=>showOrderDialog('طلب مندوب'), child: const Text('اطلب مندوب')))),
          Expanded(child: Padding(padding: const EdgeInsets.all(8), child: ElevatedButton(onPressed: ()=>showOrderDialog('صيانة من المنزل'), child: const Text('صيانة من المنزل')))),
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
    return Scaffold(appBar: AppBar(title: const Text('الطلبات - فيها كل البيانات')), 
    body: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('orders').orderBy('time', descending: true).snapshots(), 
    builder: (context, snap){ 
      if(!snap.hasData) return const Center(child: CircularProgressIndicator()); 
      return ListView(children: snap.data!.docs.map((d){ 
        final data = d.data() as Map<String,dynamic>; 
        return Card(margin: const EdgeInsets.all(8), child: ListTile(
          title: Text('${data['type']} - ${data['name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('📞 ${data['phone']}'), Text('📍 ${data['address']}'), Text('📝 ${data['details']}'),
            Text('${(data['time'] as Timestamp?)?.toDate().toString().substring(0,16) ?? ''}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ]),
          trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: ()=>d.reference.delete()),
          isThreeLine: true,
        )); 
      }).toList()); 
    }));
  }
}

class StorePage extends StatefulWidget {
  const StorePage({super.key});
  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  bool isAdmin = false;
  
  Future<void> checkAdmin() async {
    final passCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('دخول الادمن'),
      content: TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة سر الادمن')),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text('الغاء')),
        ElevatedButton(onPressed: (){ if(passCtrl.text == 'Oday123'){ setState(()=>isAdmin=true); Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم دخول الادمن ✅')));} else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('كلمة السر غلط')));} }, child: const Text('دخول')),
      ],
    ));
  }

  Future<void> addProductDialog() async {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String? base64Image;
    final picker = ImagePicker();

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx2, setSt) => AlertDialog(
      title: const Text('اضافة منتج جديد'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(onTap: () async { final XFile? img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50); if(img!=null){ final bytes = await img.readAsBytes(); setSt(()=> base64Image = base64Encode(bytes)); } }, child: Container(height: 120, width: double.infinity, color: Colors.grey[300], child: base64Image!=null ? Image.memory(base64Decode(base64Image!), fit: BoxFit.cover) : const Icon(Icons.add_a_photo, size: 40))),
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم المنتج')),
        TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'السعر - مثلا 150'), keyboardType: TextInputType.number),
        TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'المواصفات'), maxLines: 3),
      ])),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text('الغاء')),
        ElevatedButton(onPressed: () async {
          if(nameCtrl.text.isEmpty || priceCtrl.text.isEmpty || base64Image==null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('كمل كل البيانات والصورة'))); return; }
          await FirebaseFirestore.instance.collection('products').add({'name': nameCtrl.text, 'price': priceCtrl.text, 'desc': descCtrl.text, 'imageBase64': base64Image, 'time': DateTime.now()});
          Navigator.pop(ctx);
        }, child: const Text('حفظ المنتج')),
      ],
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('متجر الإكسسوارات'), 
        actions: [
          if(!isAdmin) IconButton(icon: const Icon(Icons.lock), onPressed: checkAdmin),
          if(isAdmin) IconButton(icon: const Icon(Icons.add), onPressed: addProductDialog),
          if(isAdmin) IconButton(icon: const Icon(Icons.logout), onPressed: ()=>setState(()=>isAdmin=false)),
        ]
      ), 
      body: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('products').orderBy('time', descending: true).snapshots(), 
      builder: (context, snap){ 
        if(!snap.hasData) return const Center(child: CircularProgressIndicator()); 
        return GridView.count(crossAxisCount: 2, childAspectRatio: 0.75, children: snap.data!.docs.map((d){ 
          final data = d.data() as Map<String,dynamic>; 
          return Card(child: Column(children: [
            Expanded(child: data['imageBase64']!=null ? Image.memory(base64Decode(data['imageBase64']), fit: BoxFit.cover, width: double.infinity) : const Icon(Icons.image)),
            Padding(padding: const EdgeInsets.all(4), child: Text(data['name']??'', style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1)),
            Text('${data['price']??''} جنيه', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            Padding(padding: const EdgeInsets.all(2), child: Text(data['desc']??'', style: const TextStyle(fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis)),
            if(isAdmin) IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: ()=>d.reference.delete()),
          ])); 
        }).toList()); 
      })
    );
  }
}
