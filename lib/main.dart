import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try { await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); } catch(e){}
  runApp(const MyApp());
}
class MyApp extends StatelessWidget { const MyApp({super.key}); @override Widget build(BuildContext context) { return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData(fontFamily: 'Cairo'), home: const HomePage()); } }

class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState() => _HomePageState(); }
class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  bool isAdmin = false; // للتحكم في البانر

  Future<void> checkAdmin() async {
    final c = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('كلمة سر الادمن'),
      content: TextField(controller: c, obscureText: true, decoration: const InputDecoration(hintText: 'اكتب الباسورد')),
      actions: [
        ElevatedButton(onPressed: (){
          if(c.text=='Oday123'){
            setState(()=>isAdmin=true);
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('انت دلوقتي ادمن ✅ دوس على البانر عشان تغيره')));
          }
        }, child: const Text('دخول'))
      ],
    ));
  }

  Future<void> uploadBanner(String name) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if(image == null) return; final bytes = await image.readAsBytes();
    await FirebaseFirestore.instance.collection('settings').doc('banners').set({name: base64Encode(bytes)}, SetOptions(merge: true));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم رفع البانر ✅')));
  }
  Future<void> showOrderDialog(String type) async {
    final n=TextEditingController(), p=TextEditingController(), a=TextEditingController(), d=TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(type), content: SingleChildScrollView(child: Column(children: [
        TextField(controller: n, decoration: const InputDecoration(labelText: 'الاسم')),
        TextField(controller: p, decoration: const InputDecoration(labelText: 'رقم التليفون'), keyboardType: TextInputType.phone),
        TextField(controller: a, decoration: const InputDecoration(labelText: 'العنوان')),
        TextField(controller: d, decoration: InputDecoration(labelText: type.contains('صيانة')?'نوع العطل':'عايز ايه من المندوب؟'), maxLines: 3),
      ])),
      actions: [ TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text('الغاء')),
        ElevatedButton(onPressed: () async {
          if(n.text.isEmpty||p.text.isEmpty) return;
          await FirebaseFirestore.instance.collection('orders').add({'type':type,'name':n.text,'phone':p.text,'address':a.text,'details':d.text,'time':DateTime.now(),'status':'قيد المراجعة'});
          Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم ارسال $type ✅')));
        }, child: const Text('ارسال'))],
    ));
  }
  Widget bannerWidget(String name, double h, String label) {
    return StreamBuilder<DocumentSnapshot>(stream: FirebaseFirestore.instance.collection('settings').doc('banners').snapshots(),
      builder: (context, snap) {
        String? b64; if(snap.hasData && snap.data!.data()!=null) b64 = (snap.data!.data() as Map<String,dynamic>)[name];
        return GestureDetector(
          onTap: (){
            if(isAdmin) uploadBanner(name);
          },
          onLongPress: (){
            if(!isAdmin) checkAdmin();
          },
          child: Container(height: h, width: double.infinity, margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue)),
            child: b64!=null ? ClipRRect(
              borderRadius: BorderRadius.circular(12), 
              child: Container(
                color: Colors.white,
                child: Image.memory(base64Decode(b64), fit: BoxFit.contain, width: double.infinity)
              )
            ) : Center(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          ),
        );
      });
  }
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oday Phone'), backgroundColor: Colors.blue, foregroundColor: Colors.white,
        actions: [StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('orders').snapshots(), builder: (context, snapshot) {
          int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
          return Stack(children: [ IconButton(icon: const Icon(Icons.notifications), onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const OrdersPage()))),
            if(count>0) Positioned(right: 8, top: 8, child: CircleAvatar(radius: 9, backgroundColor: Colors.red, child: Text('$count', style: const TextStyle(fontSize: 10, color: Colors.white)))),
          ]);
        })],
      ),
      body: SingleChildScrollView(child: Column(children: [
        bannerWidget('topImage', 180, 'دوس هنا لرفع البانر العلوي'),
        Padding(padding: const EdgeInsets.all(8), child: Row(children: [
          Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: const Size(0,60)), onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const StorePage())), child: const Text('متجر الإكسسوارات', style: TextStyle(color: Colors.white)))),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: const Size(0,60)), onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const UsedPhonesPage())), child: const Text('موبايلات مستعملة', style: TextStyle(color: Colors.white)))),
        ])),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Row(children: [
          Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(0,60)), onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const OffersPage())), child: const Text('عروض اليوم 🔥', style: TextStyle(color: Colors.white)))),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(0,60)), onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const TrackOrderPage())), child: const Text('تتبع طلبي', style: TextStyle(color: Colors.white)))),
        ])),
        Row(children: [
          Expanded(child: Padding(padding: const EdgeInsets.all(8), child: ElevatedButton(onPressed: ()=>showOrderDialog('طلب مندوب'), child: const Text('اطلب مندوب')))),
          Expanded(child: Padding(padding: const EdgeInsets.all(8), child: ElevatedButton(onPressed: ()=>showOrderDialog('صيانة من المنزل'), child: const Text('صيانة من المنزل')))),
        ]),
        bannerWidget('bottomImage', 190, 'دوس هنا لرفع البانر السفلي'),
        Padding(padding: const EdgeInsets.all(8), child: SizedBox(width: double.infinity, height: 55, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.black87), icon: const Icon(Icons.headset_mic, color: Colors.white), label: const Text('تواصل معنا بسرعة', style: TextStyle(color: Colors.white, fontSize: 18)), onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const ContactPage()))))),
        Container(width: double.infinity, color: Colors.black87, padding: const EdgeInsets.all(12), child: const Text('الإسماعيلية - Oday Phone - 01069068091', textAlign: TextAlign.center, style: TextStyle(color: Colors.white))),
      ])),
    );
  }
}

// صفحة الطلبات للادمن
class OrdersPage extends StatelessWidget { const OrdersPage({super.key});
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('كل الطلبات')),
      body: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('orders').orderBy('time', descending: true).snapshots(),
        builder: (context, snap){ if(!snap.hasData) return const Center(child: CircularProgressIndicator());
          return ListView(children: snap.data!.docs.map((d){ final data = d.data() as Map<String,dynamic>;
            return Card(margin: const EdgeInsets.all(8), child: ListTile(
              title: Text('${data['type']} - ${data['name']} - ${data['status']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('📞 ${data['phone']}'), Text('📍 ${data['address']}'), Text('📝 ${data['details']}')]),
              trailing: PopupMenuButton(onSelected: (v){ d.reference.update({'status': v}); }, itemBuilder: (_)=>[const PopupMenuItem(value: 'قيد المراجعة', child: Text('قيد المراجعة')), const PopupMenuItem(value: 'جاري التوصيل', child: Text('جاري التوصيل')), const PopupMenuItem(value: 'تم التوصيل', child: Text('تم التوصيل')), const PopupMenuItem(value: 'تم الالغاء', child: Text('الغاء'))], child: const Icon(Icons.more_vert)),
              isThreeLine: true,
            ));
          }).toList());
        }));
  }
}

// 1- صفحة العروض
class OffersPage extends StatefulWidget { const OffersPage({super.key}); @override State<OffersPage> createState() => _OffersPageState(); }
class _OffersPageState extends State<OffersPage> { bool isAdmin=false; Future<void> checkAdmin() async { final c=TextEditingController(); showDialog(context: context, builder: (ctx)=>AlertDialog(title: const Text('ادمن'), content: TextField(controller: c, obscureText: true), actions: [ElevatedButton(onPressed: (){ if(c.text=='Oday123'){ setState(()=>isAdmin=true); Navigator.pop(ctx);} }, child: const Text('دخول'))])); }
  Future<void> addOffer() async { final t=TextEditingController(), pr=TextEditingController(); String? img; final picker=ImagePicker();
    showDialog(context: context, builder: (ctx)=>StatefulBuilder(builder: (ctx2, setSt)=>AlertDialog(title: const Text('عرض جديد'), content: Column(mainAxisSize: MainAxisSize.min, children: [
      GestureDetector(onTap: () async { final x=await picker.pickImage(source: ImageSource.gallery, imageQuality: 50); if(x!=null){ final b=await x.readAsBytes(); setSt(()=>img=base64Encode(b)); } }, child: Container(height: 120, color: Colors.grey[300], child: img!=null?Image.memory(base64Decode(img!)):const Icon(Icons.add_a_photo))),
      TextField(controller: t, decoration: const InputDecoration(labelText: 'اسم العرض')), TextField(controller: pr, decoration: const InputDecoration(labelText: 'السعر بعد الخصم')),
    ]), actions: [ElevatedButton(onPressed: () async { await FirebaseFirestore.instance.collection('offers').add({'title':t.text,'price':pr.text,'image':img,'time':DateTime.now()}); Navigator.pop(ctx); }, child: const Text('حفظ'))])));
  }
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text('عروض اليوم 🔥'), actions: [if(!isAdmin) IconButton(icon: const Icon(Icons.lock), onPressed: checkAdmin), if(isAdmin) IconButton(icon: const Icon(Icons.add), onPressed: addOffer)]),
    body: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('offers').orderBy('time', descending: true).snapshots(), builder: (context, snap){ if(!snap.hasData) return const Center(child: CircularProgressIndicator());
      return ListView(children: snap.data!.docs.map((d){ final data=d.data() as Map<String,dynamic>; return Card(margin: const EdgeInsets.all(10), child: Column(children: [if(data['image']!=null) Image.memory(base64Decode(data['image']), height: 200, width: double.infinity, fit: BoxFit.cover), ListTile(title: Text(data['title']??''), subtitle: Text('${data['price']} جنيه', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), trailing: isAdmin?IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: ()=>d.reference.delete()):null)])); }).toList());
    })); }
}

// 2- موبايلات مستعملة
class UsedPhonesPage extends StatefulWidget { const UsedPhonesPage({super.key}); @override State<UsedPhonesPage> createState() => _UsedPhonesPageState(); }
class _UsedPhonesPageState extends State<UsedPhonesPage> { bool isAdmin=false; Future<void> checkAdmin() async { final c=TextEditingController(); showDialog(context: context, builder: (ctx)=>AlertDialog(title: const Text('ادمن'), content: TextField(controller: c, obscureText: true), actions: [ElevatedButton(onPressed: (){ if(c.text=='Oday123'){ setState(()=>isAdmin=true); Navigator.pop(ctx);} }, child: const Text('دخول'))])); }
  Future<void> addUsed() async { final n=TextEditingController(), pr=TextEditingController(), cond=TextEditingController(); String? img; final picker=ImagePicker();
    showDialog(context: context, builder: (ctx)=>StatefulBuilder(builder: (ctx2, setSt)=>AlertDialog(title: const Text('موبايل مستعمل'), content: Column(mainAxisSize: MainAxisSize.min, children: [
      GestureDetector(onTap: () async { final x=await picker.pickImage(source: ImageSource.gallery, imageQuality: 50); if(x!=null){ final b=await x.readAsBytes(); setSt(()=>img=base64Encode(b)); } }, child: Container(height: 120, color: Colors.grey[300], child: img!=null?Image.memory(base64Decode(img!)):const Icon(Icons.add_a_photo))),
      TextField(controller: n, decoration: const InputDecoration(labelText: 'نوع الموبايل - مثلا iPhone 12')), TextField(controller: pr, decoration: const InputDecoration(labelText: 'السعر')), TextField(controller: cond, decoration: const InputDecoration(labelText: 'الحالة - مثلا كسر زيرو بالعلبة')),
    ]), actions: [ElevatedButton(onPressed: () async { await FirebaseFirestore.instance.collection('used_phones').add({'name':n.text,'price':pr.text,'condition':cond.text,'image':img,'time':DateTime.now()}); Navigator.pop(ctx); }, child: const Text('حفظ'))])));
  }
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text('موبايلات مستعملة'), actions: [if(!isAdmin) IconButton(icon: const Icon(Icons.lock), onPressed: checkAdmin), if(isAdmin) IconButton(icon: const Icon(Icons.add), onPressed: addUsed)]),
    body: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('used_phones').orderBy('time', descending: true).snapshots(), builder: (context, snap){ if(!snap.hasData) return const Center(child: CircularProgressIndicator());
      return GridView.count(crossAxisCount: 2, childAspectRatio: 0.7, children: snap.data!.docs.map((d){ final data=d.data() as Map<String,dynamic>; return Card(child: Column(children: [Expanded(child: data['image']!=null?Image.memory(base64Decode(data['image']), fit: BoxFit.cover, width: double.infinity):const Icon(Icons.phone_android)), Padding(padding: const EdgeInsets.all(4), child: Text(data['name']??'', style: const TextStyle(fontWeight: FontWeight.bold))), Text('${data['price']} جنيه', style: const TextStyle(color: Colors.blue)), Padding(padding: const EdgeInsets.all(2), child: Text(data['condition']??'', style: const TextStyle(fontSize: 11), maxLines: 2)), if(isAdmin) IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: ()=>d.reference.delete())])); }).toList());
    })); }
}

// 3- تتبع الطلب
class TrackOrderPage extends StatefulWidget { const TrackOrderPage({super.key}); @override State<TrackOrderPage> createState() => _TrackOrderPageState(); }
class _TrackOrderPageState extends State<TrackOrderPage> { final phoneCtrl=TextEditingController(); String searchPhone=''; @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: const Text('تتبع طلبي')), body: Column(children: [Padding(padding: const EdgeInsets.all(12), child: Row(children: [Expanded(child: TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'اكتب رقم تليفونك'), keyboardType: TextInputType.phone)), IconButton(icon: const Icon(Icons.search), onPressed: ()=>setState(()=>searchPhone=phoneCtrl.text))])), if(searchPhone.isNotEmpty) Expanded(child: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('orders').where('phone', isEqualTo: searchPhone).orderBy('time', descending: true).snapshots(), builder: (context, snap){ if(!snap.hasData) return const Center(child: CircularProgressIndicator()); if(snap.data!.docs.isEmpty) return const Center(child: Text('مفيش طلبات بالرقم ده')); return ListView(children: snap.data!.docs.map((d){ final data=d.data() as Map<String,dynamic>; Color c=Colors.orange; if(data['status']=='جاري التوصيل') c=Colors.blue; if(data['status']=='تم التوصيل') c=Colors.green; if(data['status']=='تم الالغاء') c=Colors.red; return Card(margin: const EdgeInsets.all(8), child: ListTile(title: Text(data['type']??''), subtitle: Text('الحالة: ${data['status']}'), trailing: CircleAvatar(backgroundColor: c, child: const Icon(Icons.local_shipping, color: Colors.white)))); }).toList()); })) ])); } }

// 4- تواصل سريع - برقمك الجديد
class ContactPage extends StatelessWidget { const ContactPage({super.key});
  Future<void> openWhatsApp() async { final uri=Uri.parse('https://wa.me/201069068091'); if(await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication); }
  Future<void> callPhone() async { final uri=Uri.parse('tel:+201069068091'); if(await canLaunchUrl(uri)) await launchUrl(uri); }
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text('تواصل معنا')), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
    const Icon(Icons.store, size: 80, color: Colors.blue), const SizedBox(height: 10), const Text('Oday Phone - الإسماعيلية', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    const SizedBox(height: 30),
    SizedBox(width: double.infinity, height: 55, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), icon: const Icon(Icons.chat, color: Colors.white), label: const Text('واتساب 01069068091', style: TextStyle(color: Colors.white, fontSize: 18)), onPressed: openWhatsApp)),
    const SizedBox(height: 12),
    SizedBox(width: double.infinity, height: 55, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), icon: const Icon(Icons.call, color: Colors.white), label: const Text('اتصال مباشر 01069068091', style: TextStyle(color: Colors.white, fontSize: 18)), onPressed: callPhone)),
    const SizedBox(height: 12),
    const Card(child: ListTile(leading: Icon(Icons.location_on), title: Text('العنوان'), subtitle: Text('الإسماعيلية - Oday Phone - 01069068091'))),
  ]))); }
}

// متجر الاكسسوارات
class StorePage extends StatefulWidget { const StorePage({super.key}); @override State<StorePage> createState() => _StorePageState(); }
class _StorePageState extends State<StorePage> { bool isAdmin=false; Future<void> checkAdmin() async { final c=TextEditingController(); showDialog(context: context, builder: (ctx)=>AlertDialog(title: const Text('ادمن'), content: TextField(controller: c, obscureText: true), actions: [ElevatedButton(onPressed: (){ if(c.text=='Oday123'){ setState(()=>isAdmin=true); Navigator.pop(ctx);} }, child: const Text('دخول'))])); }
  Future<void> addProduct() async { final n=TextEditingController(), pr=TextEditingController(), d=TextEditingController(); String? img; final picker=ImagePicker();
    showDialog(context: context, builder: (ctx)=>StatefulBuilder(builder: (ctx2, setSt)=>AlertDialog(title: const Text('منتج جديد'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      GestureDetector(onTap: () async { final x=await picker.pickImage(source: ImageSource.gallery, imageQuality: 50); if(x!=null){ final b=await x.readAsBytes(); setSt(()=>img=base64Encode(b)); } }, child: Container(height: 120, color: Colors.grey[300], child: img!=null?Image.memory(base64Decode(img!)):const Icon(Icons.add_a_photo))),
      TextField(controller: n, decoration: const InputDecoration(labelText: 'اسم المنتج')), TextField(controller: pr, decoration: const InputDecoration(labelText: 'السعر')), TextField(controller: d, decoration: const InputDecoration(labelText: 'المواصفات'), maxLines: 2),
    ])), actions: [ElevatedButton(onPressed: () async { if(n.text.isEmpty||img==null) return; await FirebaseFirestore.instance.collection('products').add({'name':n.text,'price':pr.text,'desc':d.text,'imageBase64':img,'time':DateTime.now()}); Navigator.pop(ctx); }, child: const Text('حفظ'))])));
  }
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text('متجر الإكسسوارات'), actions: [if(!isAdmin) IconButton(icon: const Icon(Icons.lock), onPressed: checkAdmin), if(isAdmin) IconButton(icon: const Icon(Icons.add), onPressed: addProduct)]),
    body: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('products').orderBy('time', descending: true).snapshots(), builder: (context, snap){ if(!snap.hasData) return const Center(child: CircularProgressIndicator());
      return GridView.count(crossAxisCount: 2, childAspectRatio: 0.75, children: snap.data!.docs.map((d){ final data=d.data() as Map<String,dynamic>; return Card(child: Column(children: [Expanded(child: data['imageBase64']!=null?Image.memory(base64Decode(data['imageBase64']), fit: BoxFit.cover, width: double.infinity):const Icon(Icons.image)), Text(data['name']??'', style: const TextStyle(fontWeight: FontWeight.bold)), Text('${data['price']} جنيه', style: const TextStyle(color: Colors.blue)), if(isAdmin) IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: ()=>d.reference.delete())])); }).toList());
    })); }
}
