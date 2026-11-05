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

// الوان الصور بالظبط
const Color tealC = Color(0xFF00B4A6);
const Color orangeC = Color(0xFFFF8A00);
const String adminPass = 'Oday123';
const String waNumber = '201069068091';
String userName = '';
List<Map<String,dynamic>> cart = [];

class MyApp extends StatelessWidget { const MyApp({super.key});
  @override Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData(fontFamily: 'Cairo', primaryColor: tealC, scaffoldBackgroundColor: Colors.white, appBarTheme: const AppBarTheme(backgroundColor: tealC, foregroundColor: Colors.white)),
      home: const MainShell());
  }
}

// ============ الشيل الرئيسي + Bottom Bar ============
class MainShell extends StatefulWidget { const MainShell({super.key}); @override State<MainShell> createState() => _MainShellState(); }
class _MainShellState extends State<MainShell> {
  int idx = 0;
  @override void initState(){ super.initState(); WidgetsBinding.instance.addPostFrameCallback((_)=> askName()); }
  Future<void> askName() async {
    if(userName.isNotEmpty) return;
    final c = TextEditingController();
    showDialog(barrierDismissible: false, context: context, builder: (ctx)=>AlertDialog(
      title: const Text('أهلاً بيك في Oday Phone'),
      content: TextField(controller: c, decoration: const InputDecoration(labelText: 'اسمك ايه؟', hintText: 'مثال: أحمد')),
      actions: [ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: orangeC), onPressed: (){ if(c.text.trim().isNotEmpty){ setState(()=> userName = c.text.trim()); Navigator.pop(ctx); } }, child: const Text('دخول', style: TextStyle(color: Colors.white)))],
    ));
  }
  @override Widget build(BuildContext context){
    final pages = [const NewHome(), const StorePage(), const CourierPage(), const CheckoutPage(), const ContactPage()];
    return Scaffold(
      body: pages[idx],
      bottomNavigationBar: BottomNavigationBar(currentIndex: idx, onTap: (v)=>setState(()=>idx=v), type: BottomNavigationBarType.fixed, selectedItemColor: tealC, unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'الخدمات'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'الطلبات'),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'المحفظة'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ]),
    );
  }
}

Future<void> showOrderDialog(BuildContext context, String type) async {
  final n=TextEditingController(text: userName), p=TextEditingController(), a=TextEditingController(), d=TextEditingController();
  showDialog(context: context, builder: (ctx) => AlertDialog(
    title: Text(type), content: SingleChildScrollView(child: Column(children: [
      TextField(controller: n, decoration: const InputDecoration(labelText: 'الاسم')),
      TextField(controller: p, decoration: const InputDecoration(labelText: 'رقم التليفون'), keyboardType: TextInputType.phone),
      TextField(controller: a, decoration: const InputDecoration(labelText: 'العنوان')),
      TextField(controller: d, decoration: InputDecoration(labelText: type.contains('صيانة')?'نوع العطل':'عايز ايه من المندوب؟'), maxLines: 3),
    ])),
    actions: [ TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text('الغاء')),
      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: orangeC), onPressed: () async {
        if(n.text.isEmpty||p.text.isEmpty) return;
        await FirebaseFirestore.instance.collection('orders').add({'type':type,'name':n.text,'phone':p.text,'address':a.text,'details':d.text,'time':DateTime.now(),'status':'قيد المراجعة'});
        Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم ارسال $type ✅')));
      }, child: const Text('ارسال', style: TextStyle(color: Colors.white)))],
  ));
}

Future<void> checkAdminOrders(BuildContext context) async {
  final c = TextEditingController();
  showDialog(context: context, builder: (ctx) => AlertDialog(
    title: const Text('دخول الادمن فقط'), content: TextField(controller: c, obscureText: true, decoration: const InputDecoration(hintText: 'الباسورد')),
    actions: [ElevatedButton(onPressed: (){
      if(c.text==adminPass){ Navigator.pop(ctx); Navigator.push(context, MaterialPageRoute(builder: (_)=>const OrdersPage())); }
      else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('باسورد غلط'))); }
    }, child: const Text('دخول'))],
  ));
}

// ============ 1 - الرئيسية زي الصورة 1 ============
class NewHome extends StatelessWidget { const NewHome({super.key});
  @override Widget build(BuildContext context){
    return SafeArea(child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        const CircleAvatar(radius: 26, backgroundColor: tealC, child: Icon(Icons.person, color: Colors.white)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('أهلاً بيك يا ${userName.isEmpty ? 'عدي' : userName}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text('كيف نقدر نساعدك اليوم؟', style: TextStyle(color: Colors.grey)),
        ])),
        IconButton(icon: const Icon(Icons.notifications, color: tealC), onPressed: ()=>checkAdminOrders(context)),
      ])),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: TextField(decoration: InputDecoration(hintText: 'ابحث عن خدمة صيانة...', prefixIcon: const Icon(Icons.search, color: tealC), suffixIcon: const Icon(Icons.tune), filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))),
      const SizedBox(height: 16),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
        Expanded(child: _box(Icons.home_repair_service, 'صيانة من المنزل', tealC, ()=>showOrderDialog(context, 'صيانة من المنزل'))),
        const SizedBox(width: 8),
        Expanded(child: _box(Icons.shopping_bag, 'متجر اكسسوارات', orangeC, ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const StorePage())))),
        const SizedBox(width: 8),
        Expanded(child: _box(Icons.delivery_dining, 'اطلب مندوب', tealC, ()=>showOrderDialog(context, 'طلب مندوب'))),
        const SizedBox(width: 8),
        Expanded(child: _box(Icons.payment, 'الدفع', orangeC, ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const CheckoutPage())))),
      ])),
      const SizedBox(height: 20),
      const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('خدمات سريعة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      const SizedBox(height: 10),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
        Expanded(child: _quick(Icons.plumbing, 'سباك', ()=>showOrderDialog(context, 'سباك'))),
        const SizedBox(width: 8),
        Expanded(child: _quick(Icons.electrical_services, 'كهربائي', ()=>showOrderDialog(context, 'كهربائي'))),
        const SizedBox(width: 8),
        Expanded(child: _quick(Icons.ac_unit, 'صيانة مكيفات', ()=>showOrderDialog(context, 'صيانة مكيفات'))),
      ])),
      const SizedBox(height: 20),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('عروض اليوم 🔥', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextButton(onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const OffersPage())), child: const Text('عرض الكل')),
      ])),
      SizedBox(height: 140, child: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('offers').orderBy('time', descending: true).limit(5).snapshots(), builder: (context, snap){
        if(!snap.hasData || snap.data!.docs.isEmpty) return const Center(child: Text('لا يوجد عروض حالياً'));
        return ListView(scrollDirection: Axis.horizontal, children: snap.data!.docs.map((d){ final data=d.data() as Map<String,dynamic>; return GestureDetector(onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const OffersPage())), child: Container(width: 200, margin: const EdgeInsets.only(left: 12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[100]), child: Column(children: [Expanded(child: data['image']!=null ? ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), child: Image.memory(base64Decode(data['image']), fit: BoxFit.cover, width: double.infinity)) : const Icon(Icons.local_offer)), Padding(padding: const EdgeInsets.all(8), child: Text('${data['title']} - ${data['price']} ج', style: const TextStyle(fontWeight: FontWeight.bold)))]))); }).toList());
      })),
      Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: orangeC, minimumSize: const Size(0,55)), onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const UsedPhonesPage())), child: const Text('موبايلات مستعملة', style: TextStyle(color: Colors.white)))),
        const SizedBox(width: 8),
        Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: tealC, minimumSize: const Size(0,55)), onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const TrackOrderPage())), child: const Text('تتبع طلبي', style: TextStyle(color: Colors.white)))),
      ])),
      Container(width: double.infinity, color: Colors.black87, padding: const EdgeInsets.all(12), child: const Text('الإسماعيلية - Oday Phone - 01069068091', textAlign: TextAlign.center, style: TextStyle(color: Colors.white))),
    ])));
  }
  Widget _box(IconData icon, String title, Color c, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Container(height: 92, decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: c, size: 30), const SizedBox(height: 6), Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))])));
  Widget _quick(IconData icon, String title, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)), child: Column(children: [Icon(icon, color: tealC), const SizedBox(height: 6), Text(title, style: const TextStyle(fontWeight: FontWeight.bold))])));

}

// ============ 2 - المتجر زي الصورة 3 ============
class StorePage extends StatefulWidget { const StorePage({super.key}); @override State<StorePage> createState() => _StorePageState(); }
class _StorePageState extends State<StorePage> {
  bool isAdmin=false; String search=''; String filter='الكل';
  Future<void> checkAdmin() async { final c=TextEditingController(); showDialog(context: context, builder: (ctx)=>AlertDialog(title: const Text('ادمن'), content: TextField(controller: c, obscureText: true), actions: [ElevatedButton(onPressed: (){ if(c.text==adminPass){ setState(()=>isAdmin=true); Navigator.pop(ctx);} }, child: const Text('دخول'))])); }
  Future<void> showProductDetail(Map<String,dynamic> data) async {
    final nameCtrl=TextEditingController(text: userName); final phoneCtrl=TextEditingController(); final addressCtrl=TextEditingController();
    showDialog(context: context, builder: (ctx)=>AlertDialog(contentPadding: EdgeInsets.zero, content: SingleChildScrollView(child: Column(children: [
      if(data['imageBase64']!=null) Image.memory(base64Decode(data['imageBase64']), height: 250, width: double.infinity, fit: BoxFit.fill),
      Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(data['name']??'', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text('${data['price']} جنيه', style: const TextStyle(fontSize: 18, color: tealC, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8), const Text('المواصفات:', style: TextStyle(fontWeight: FontWeight.bold)), Text(data['desc']??'لا يوجد وصف'),
        const Divider(), TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسمك')), TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'رقمك'), keyboardType: TextInputType.phone), TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'عنوانك')),
      ])),
    ])), actions: [TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text('الغاء')), ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), icon: const Icon(Icons.chat, color: Colors.white), label: const Text('شراء الآن واتساب', style: TextStyle(color: Colors.white)), onPressed: () async {
      if(nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) return;
      await FirebaseFirestore.instance.collection('orders').add({'type':'شراء منتج - ${data['name']}','name':nameCtrl.text,'phone':phoneCtrl.text,'address':addressCtrl.text,'details':'المنتج: ${data['name']} - السعر: ${data['price']} - ${data['desc']}','time':DateTime.now(),'status':'قيد المراجعة'});
      Navigator.pop(ctx);
      String msg = "سلام عليكم Oday Phone%0Aعايز اشتري:%0A📱 *${data['name']}*%0A💰 ${data['price']} جنيه%0A👤 ${nameCtrl.text}%0A📞 ${phoneCtrl.text}%0A📍 ${addressCtrl.text}";
      final uri = Uri.parse('https://wa.me/$waNumber?text=$msg');
      if(await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
    })]));
  }
  Future<void> addProduct() async { final n=TextEditingController(), pr=TextEditingController(), d=TextEditingController(), cat=TextEditingController(text: 'سماعات'); String? img; final picker=ImagePicker();
    showDialog(context: context, builder: (ctx)=>StatefulBuilder(builder: (ctx2, setSt)=>AlertDialog(title: const Text('منتج جديد'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      GestureDetector(onTap: () async { final x=await picker.pickImage(source: ImageSource.gallery, imageQuality: 50); if(x!=null){ final b=await x.readAsBytes(); setSt(()=>img=base64Encode(b)); } }, child: Container(height: 120, color: Colors.grey[300], child: img!=null?Image.memory(base64Decode(img!)):const Icon(Icons.add_a_photo))),
      TextField(controller: n, decoration: const InputDecoration(labelText: 'اسم المنتج')), TextField(controller: pr, decoration: const InputDecoration(labelText: 'السعر')), TextField(controller: cat, decoration: const InputDecoration(labelText: 'التصنيف: سماعات / شواحن / كفرات / كابلات')), TextField(controller: d, decoration: const InputDecoration(labelText: 'المواصفات'), maxLines: 3),
    ])), actions: [ElevatedButton(onPressed: () async { if(n.text.isEmpty||img==null) return; await FirebaseFirestore.instance.collection('products').add({'name':n.text,'price':pr.text,'desc':d.text,'category':cat.text,'imageBase64':img,'time':DateTime.now()}); Navigator.pop(ctx); }, child: const Text('حفظ'))])));
  }
  @override Widget build(BuildContext context) {
    final filters = ['الكل','سماعات','شواحن','كفرات','كابلات'];
    return Scaffold(appBar: AppBar(title: const Text('متجر الإكسسوارات'), actions: [Stack(children: [IconButton(icon: const Icon(Icons.shopping_cart), onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const CheckoutPage()))), if(cart.isNotEmpty) Positioned(right: 6, top: 6, child: CircleAvatar(radius: 9, backgroundColor: orangeC, child: Text('${cart.length}', style: const TextStyle(fontSize: 10, color: Colors.white))))]), if(!isAdmin) IconButton(icon: const Icon(Icons.lock), onPressed: checkAdmin), if(isAdmin) IconButton(icon: const Icon(Icons.add), onPressed: addProduct)]),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: TextField(onChanged: (v)=>setState(()=>search=v), decoration: InputDecoration(hintText: 'ابحث عن منتج...', prefixIcon: const Icon(Icons.search, color: tealC), filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))),
        SizedBox(height: 40, child: ListView(scrollDirection: Axis.horizontal, children: filters.map((f)=>Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: ChoiceChip(label: Text(f), selected: filter==f, selectedColor: tealC, labelStyle: TextStyle(color: filter==f?Colors.white:Colors.black), onSelected: (_)=>setState(()=>filter=f)))).toList())),
        Expanded(child: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('products').orderBy('time', descending: true).snapshots(), builder: (context, snap){ if(!snap.hasData) return const Center(child: CircularProgressIndicator());
          var docs = snap.data!.docs.where((d){ final data=d.data() as Map<String,dynamic>; final name=(data['name']??'').toString(); final cat=(data['category']??'سماعات').toString(); if(search.isNotEmpty && !name.contains(search)) return false; if(filter!='الكل' && cat!=filter) return false; return true; }).toList();
          if(docs.isEmpty) return const Center(child: Text('لا يوجد منتجات في التصنيف ده'));
          return GridView.count(crossAxisCount: 2, childAspectRatio: 0.72, children: docs.map((d){ final data=d.data() as Map<String,dynamic>; return GestureDetector(onTap: ()=>showProductDetail(data), child: Card(child: Column(children: [
            Expanded(child: data['imageBase64']!=null?Image.memory(base64Decode(data['imageBase64']), fit: BoxFit.cover, width: double.infinity):const Icon(Icons.image)),
            Padding(padding: const EdgeInsets.all(4), child: Text(data['name']??'', style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1)),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.star, color: Colors.amber, size: 14), const Text('4.8', style: TextStyle(fontSize: 12))]),
            Text('${data['price']} جنيه', style: const TextStyle(color: tealC, fontWeight: FontWeight.bold)),
            Padding(padding: const EdgeInsets.all(6), child: SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: orangeC), onPressed: (){ setState(()=>cart.add(data)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت الإضافة للسلة ✅'))); }, child: const Text('إضافة للسلة', style: TextStyle(color: Colors.white, fontSize: 12))))),
            if(isAdmin) IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: ()=>d.reference.delete())
          ]))); }).toList());
        })),
      ]));
  }
}

// ============ 3 - المندوب زي الصورة 2 ============
class CourierPage extends StatelessWidget { const CourierPage({super.key});
  @override Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(title: const Text('اطلب مندوب')), body: ListView(padding: const EdgeInsets.all(16), children: [
      Container(height: 200, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)), child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.map, size: 60, color: tealC), Text('الخريطة - الإسماعيلية', style: TextStyle(fontWeight: FontWeight.bold)), Text('المندوب في الطريق إليك 🚴')])),
      const SizedBox(height: 16),
      const Card(child: ListTile(leading: CircleAvatar(backgroundColor: tealC, child: Icon(Icons.delivery_dining, color: Colors.white)), title: Text('المندوب في الطريق إليك'), subtitle: Text('أحمد - مندوب Oday Phone - 5 دقائق'))),
      const SizedBox(height: 12),
      const Text('نقطة الاستلام', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 6),
      const TextField(decoration: InputDecoration(hintText: 'عنوانك - منين نستلم؟', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      const Text('نقطة التسليم', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 6),
      const TextField(decoration: InputDecoration(hintText: 'هنوصله فين؟', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      const TextField(decoration: InputDecoration(labelText: 'ملاحظات للمندوب'), maxLines: 2),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, height: 55, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: orangeC), onPressed: ()=>showOrderDialog(context, 'طلب مندوب'), child: const Text('اطلب مندوب الآن', style: TextStyle(color: Colors.white, fontSize: 18)))),
      const SizedBox(height: 10),
      SizedBox(width: double.infinity, height: 55, child: OutlinedButton(onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const TrackOrderPage())), child: const Text('تتبع الطلب'))),
    ]));
  }
}

// ============ 4 - الدفع زي الصورة 4 ============
class CheckoutPage extends StatefulWidget { const CheckoutPage({super.key}); @override State<CheckoutPage> createState() => _CheckoutPageState(); }
class _CheckoutPageState extends State<CheckoutPage> {
  String pay='فودافون كاش'; final codeCtrl=TextEditingController();
  @override Widget build(BuildContext context){
    double total = 0; for(var c in cart){ total += double.tryParse('${c['price']}') ?? 0; }
    double discount = codeCtrl.text=='ODAY10' ? total*0.1 : 0;
    return Scaffold(appBar: AppBar(title: const Text('الدفع والخروج')), body: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('طرق الدفع', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
      ...['فودافون كاش','فوري','بطاقة فيزا','الدفع عند الاستلام'].map((m)=>Card(child: RadioListTile(value: m, groupValue: pay, onChanged: (v)=>setState(()=>pay=v!), title: Text(m), subtitle: Text(m=='فودافون كاش'?'محفظة فودافون كاش - *9#': m=='فوري'?'الدفع عبر فوري': m=='بطاقة فيزا'?'Visa **** 4532':'رسوم إضافية 20 ج عند التسليم')))),
      const SizedBox(height: 16), const Text('ملخص الطلب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ...cart.map((c)=>ListTile(title: Text(c['name']??''), trailing: Text('${c['price']} ج'))),
      if(cart.isEmpty) const Text('السلة فاضية - اضف من المتجر'),
      const SizedBox(height: 10),
      Row(children: [Expanded(child: TextField(controller: codeCtrl, decoration: const InputDecoration(hintText: 'كود خصم - جرب ODAY10'))), const SizedBox(width: 8), ElevatedButton(onPressed: ()=>setState((){}), child: const Text('تطبيق'))]),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('الإجمالي'), Text('${total - discount} ج', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, height: 55, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: orangeC), onPressed: () async {
        await FirebaseFirestore.instance.collection('orders').add({'type':'طلب دفع - $pay','name':userName,'phone':'','address':'','details':'السلة: ${cart.map((e)=>e['name']).join(', ')} - الاجمالي: ${total-discount} - الدفع: $pay','time':DateTime.now(),'status':'قيد المراجعة'});
        String msg = "طلب دفع%0A💳 $pay%0A💰 ${total-discount} ج%0A👤 $userName";
        final uri = Uri.parse('https://wa.me/$waNumber?text=$msg'); if(await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم ارسال الطلب ✅')));
      }, child: const Text('ادفع الآن', style: TextStyle(color: Colors.white, fontSize: 18)))),
    ]));
  }
}

// ============ الصفحات القديمة المحفوظة ============
class OrdersPage extends StatelessWidget { const OrdersPage({super.key});
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text('كل الطلبات')), body: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('orders').orderBy('time', descending: true).snapshots(), builder: (context, snap){ if(!snap.hasData) return const Center(child: CircularProgressIndicator()); return ListView(children: snap.data!.docs.map((d){ final data = d.data() as Map<String,dynamic>; return Card(margin: const EdgeInsets.all(8), child: ListTile(title: Text('${data['type']} - ${data['name']} - ${data['status']}', style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('📞 ${data['phone']}'), Text('📍 ${data['address']}'), Text('📝 ${data['details']}')]), trailing: PopupMenuButton(onSelected: (v){ d.reference.update({'status': v}); }, itemBuilder: (_)=>[const PopupMenuItem(value: 'قيد المراجعة', child: Text('قيد المراجعة')), const PopupMenuItem(value: 'جاري التوصيل', child: Text('جاري التوصيل')), const PopupMenuItem(value: 'تم التوصيل', child: Text('تم التوصيل')), const PopupMenuItem(value: 'تم الالغاء', child: Text('الغاء'))], child: const Icon(Icons.more_vert)), isThreeLine: true)); }).toList()); })); }
}

class OffersPage extends StatefulWidget { const OffersPage({super.key}); @override State<OffersPage> createState() => _OffersPageState(); }
class _OffersPageState extends State<OffersPage> {
  bool isAdmin=false;
  Future<void> checkAdmin() async { final c=TextEditingController(); showDialog(context: context, builder: (ctx)=>AlertDialog(title: const Text('ادمن'), content: TextField(controller: c, obscureText: true), actions: [ElevatedButton(onPressed: (){ if(c.text==adminPass){ setState(()=>isAdmin=true); Navigator.pop(ctx);} }, child: const Text('دخول'))])); }
  Future<void> showDetailAndBuy(Map<String,dynamic> data) async { final n=TextEditingController(text: userName), p=TextEditingController(), a=TextEditingController(); showDialog(context: context, builder: (ctx)=>AlertDialog(contentPadding: EdgeInsets.zero, content: SingleChildScrollView(child: Column(children: [if(data['image']!=null) Image.memory(base64Decode(data['image']), height: 250, width: double.infinity, fit: BoxFit.fill), Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(data['title']??'', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text('${data['price']} جنيه', style: const TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold)), const Divider(), TextField(controller: n, decoration: const InputDecoration(labelText: 'اسمك')), TextField(controller: p, decoration: const InputDecoration(labelText: 'رقمك'), keyboardType: TextInputType.phone), TextField(controller: a, decoration: const InputDecoration(labelText: 'عنوانك'))]))])), actions: [TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text('الغاء')), ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), icon: const Icon(Icons.chat, color: Colors.white), label: const Text('شراء واتساب', style: TextStyle(color: Colors.white)), onPressed: () async { if(n.text.isEmpty||p.text.isEmpty) return; await FirebaseFirestore.instance.collection('orders').add({'type':'عرض - ${data['title']}', 'name':n.text, 'phone':p.text, 'address':a.text, 'details':'العرض: ${data['title']} - ${data['price']}', 'time':DateTime.now(), 'status':'قيد المراجعة'}); Navigator.pop(ctx); String msg = "عايز العرض ده%0A📱 *${data['title']}*%0A💰 ${data['price']} جنيه%0A👤 ${n.text}%0A📞 ${p.text}%0A📍 ${a.text}"; final uri=Uri.parse('https://wa.me/$waNumber?text=$msg'); if(await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication); })])); }
  Future<void> addOffer() async { final t=TextEditingController(), pr=TextEditingController(); String? img; final picker=ImagePicker(); showDialog(context: context, builder: (ctx)=>StatefulBuilder(builder: (ctx2, setSt)=>AlertDialog(title: const Text('عرض جديد'), content: Column(mainAxisSize: MainAxisSize.min, children: [GestureDetector(onTap: () async { final x=await picker.pickImage(source: ImageSource.gallery, imageQuality: 50); if(x!=null){ final b=await x.readAsBytes(); setSt(()=>img=base64Encode(b)); } }, child: Container(height: 120, color: Colors.grey[300], child: img!=null?Image.memory(base64Decode(img!)):const Icon(Icons.add_a_photo))), TextField(controller: t, decoration: const InputDecoration(labelText: 'اسم العرض')), TextField(controller: pr, decoration: const InputDecoration(labelText: 'السعر بعد الخصم'))]), actions: [ElevatedButton(onPressed: () async { await FirebaseFirestore.instance.collection('offers').add({'title':t.text,'price':pr.text,'image':img,'time':DateTime.now()}); Navigator.pop(ctx); }, child: const Text('حفظ'))]))); }
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text('عروض اليوم 🔥'), actions: [if(!isAdmin) IconButton(icon: const Icon(Icons.lock), onPressed: checkAdmin), if(isAdmin) IconButton(icon: const Icon(Icons.add), onPressed: addOffer)]), body: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('offers').orderBy('time', descending: true).snapshots(), builder: (context, snap){ if(!snap.hasData) return const Center(child: CircularProgressIndicator()); return ListView(children: snap.data!.docs.map((d){ final data=d.data() as Map<String,dynamic>; return GestureDetector(onTap: ()=>showDetailAndBuy(data), child: Card(margin: const EdgeInsets.all(10), child: Column(children: [if(data['image']!=null) Image.memory(base64Decode(data['image']), height: 200, width: double.infinity, fit: BoxFit.cover), ListTile(title: Text(data['title']??''), subtitle: Text('${data['price']} جنيه', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), trailing: isAdmin?IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: ()=>d.reference.delete()):const Icon(Icons.shopping_cart, color: Colors.green))]))) ; }).toList()); })); }
}

class UsedPhonesPage extends StatefulWidget { const UsedPhonesPage({super.key}); @override State<UsedPhonesPage> createState() => _UsedPhonesPageState(); }
class _UsedPhonesPageState extends State<UsedPhonesPage> {
  bool isAdmin=false;
  Future<void> checkAdmin() async { final c=TextEditingController(); showDialog(context: context, builder: (ctx)=>AlertDialog(title: const Text('ادمن'), content: TextField(controller: c, obscureText: true), actions: [ElevatedButton(onPressed: (){ if(c.text==adminPass){ setState(()=>isAdmin=true); Navigator.pop(ctx);} }, child: const Text('دخول'))])); }
  Future<void> showDetailAndBuy(Map<String,dynamic> data) async { final n=TextEditingController(text: userName), p=TextEditingController(), a=TextEditingController(); showDialog(context: context, builder: (ctx)=>AlertDialog(contentPadding: EdgeInsets.zero, content: SingleChildScrollView(child: Column(children: [if(data['image']!=null) Image.memory(base64Decode(data['image']), height: 300, width: double.infinity, fit: BoxFit.fill), Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(data['name']??'', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text('${data['price']} جنيه', style: const TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold)), Text('الحالة: ${data['condition']??''}'), const Divider(), TextField(controller: n, decoration: const InputDecoration(labelText: 'اسمك')), TextField(controller: p, decoration: const InputDecoration(labelText: 'رقمك'), keyboardType: TextInputType.phone), TextField(controller: a, decoration: const InputDecoration(labelText: 'عنوانك'))]))])), actions: [TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text('الغاء')), ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), icon: const Icon(Icons.chat, color: Colors.white), label: const Text('شراء واتساب', style: TextStyle(color: Colors.white)), onPressed: () async { if(n.text.isEmpty||p.text.isEmpty) return; await FirebaseFirestore.instance.collection('orders').add({'type':'مستعمل - ${data['name']}', 'name':n.text, 'phone':p.text, 'address':a.text, 'details':'الموبايل: ${data['name']} - ${data['price']} - ${data['condition']}', 'time':DateTime.now(), 'status':'قيد المراجعة'}); Navigator.pop(ctx); String msg = "عايز الموبايل المستعمل ده%0A*${data['name']}*%0A💰 ${data['price']} جنيه%0A👤 ${n.text}%0A📞 ${p.text}%0A📍 ${a.text}"; final uri=Uri.parse('https://wa.me/$waNumber?text=$msg'); if(await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication); })])); }
  Future<void> addUsed() async { final n=TextEditingController(), pr=TextEditingController(), cond=TextEditingController(); String? img; final picker=ImagePicker(); showDialog(context: context, builder: (ctx)=>StatefulBuilder(builder: (ctx2, setSt)=>AlertDialog(title: const Text('موبايل مستعمل'), content: Column(mainAxisSize: MainAxisSize.min, children: [GestureDetector(onTap: () async { final x=await picker.pickImage(source: ImageSource.gallery, imageQuality: 50); if(x!=null){ final b=await x.readAsBytes(); setSt(()=>img=base64Encode(b)); } }, child: Container(height: 120, color: Colors.grey[300], child: img!=null?Image.memory(base64Decode(img!)):const Icon(Icons.add_a_photo))), TextField(controller: n, decoration: const InputDecoration(labelText: 'نوع الموبايل')), TextField(controller: pr, decoration: const InputDecoration(labelText: 'السعر')), TextField(controller: cond, decoration: const InputDecoration(labelText: 'الحالة'))]), actions: [ElevatedButton(onPressed: () async { await FirebaseFirestore.instance.collection('used_phones').add({'name':n.text,'price':pr.text,'condition':cond.text,'image':img,'time':DateTime.now()}); Navigator.pop(ctx); }, child: const Text('حفظ'))]))); }
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text('موبايلات مستعملة'), actions: [if(!isAdmin) IconButton(icon: const Icon(Icons.lock), onPressed: checkAdmin), if(isAdmin) IconButton(icon: const Icon(Icons.add), onPressed: addUsed)]), body: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('used_phones').orderBy('time', descending: true).snapshots(), builder: (context, snap){ if(!snap.hasData) return const Center(child: CircularProgressIndicator()); return GridView.count(crossAxisCount: 2, childAspectRatio: 0.7, children: snap.data!.docs.map((d){ final data=d.data() as Map<String,dynamic>; return GestureDetector(onTap: ()=>showDetailAndBuy(data), child: Card(child: Column(children: [Expanded(child: data['image']!=null?Image.memory(base64Decode(data['image']), fit: BoxFit.cover, width: double.infinity):const Icon(Icons.phone_android)), Padding(padding: const EdgeInsets.all(4), child: Text(data['name']??'', style: const TextStyle(fontWeight: FontWeight.bold))), Text('${data['price']} جنيه'), Padding(padding: const EdgeInsets.all(2), child: Text(data['condition']??'', style: const TextStyle(fontSize: 11), maxLines: 2)), Container(margin: const EdgeInsets.all(2), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)), child: const Text('شراء', style: TextStyle(color: Colors.white, fontSize: 10))), if(isAdmin) IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: ()=>d.reference.delete())]))); }).toList()); })); }
}

class TrackOrderPage extends StatefulWidget { const TrackOrderPage({super.key}); @override State<TrackOrderPage> createState() => _TrackOrderPageState(); }
class _TrackOrderPageState extends State<TrackOrderPage> { final phoneCtrl=TextEditingController(); String searchPhone=''; @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: const Text('تتبع طلبي')), body: Column(children: [Padding(padding: const EdgeInsets.all(12), child: Row(children: [Expanded(child: TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'اكتب رقم تليفونك'), keyboardType: TextInputType.phone)), IconButton(icon: const Icon(Icons.search), onPressed: ()=>setState(()=>searchPhone=phoneCtrl.text))])), if(searchPhone.isNotEmpty) Expanded(child: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('orders').where('phone', isEqualTo: searchPhone).orderBy('time', descending: true).snapshots(), builder: (context, snap){ if(!snap.hasData) return const Center(child: CircularProgressIndicator()); if(snap.data!.docs.isEmpty) return const Center(child: Text('مفيش طلبات بالرقم ده')); return ListView(children: snap.data!.docs.map((d){ final data=d.data() as Map<String,dynamic>; Color c=Colors.orange; if(data['status']=='جاري التوصيل') c=Colors.blue; if(data['status']=='تم التوصيل') c=Colors.green; if(data['status']=='تم الالغاء') c=Colors.red; return Card(margin: const EdgeInsets.all(8), child: ListTile(title: Text(data['type']??''), subtitle: Text('الحالة: ${data['status']}'), trailing: CircleAvatar(backgroundColor: c, child: const Icon(Icons.local_shipping, color: Colors.white)))); }).toList()); })) ])); } }

class ContactPage extends StatelessWidget { const ContactPage({super.key});
  Future<void> openWhatsApp() async { final uri=Uri.parse('https://wa.me/$waNumber'); if(await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication); }
  Future<void> callPhone() async { final uri=Uri.parse('tel:+201069068091'); if(await canLaunchUrl(uri)) await launchUrl(uri); }
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text('تواصل معنا / حسابي')), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
    const Icon(Icons.store, size: 80, color: tealC), const SizedBox(height: 10), Text('أهلاً بيك يا ${userName.isEmpty ? 'عدي' : userName}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const Text('Oday Phone - الإسماعيلية'),
    const SizedBox(height: 30),
    SizedBox(width: double.infinity, height: 55, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), icon: const Icon(Icons.chat, color: Colors.white), label: const Text('واتساب 01069068091', style: TextStyle(color: Colors.white, fontSize: 18)), onPressed: openWhatsApp)),
    const SizedBox(height: 12),
    SizedBox(width: double.infinity, height: 55, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: tealC), icon: const Icon(Icons.call, color: Colors.white), label: const Text('اتصال مباشر', style: TextStyle(color: Colors.white, fontSize: 18)), onPressed: callPhone)),
    const SizedBox(height: 12),
    const Card(child: ListTile(leading: Icon(Icons.location_on), title: Text('العنوان'), subtitle: Text('الإسماعيلية - Oday Phone - 01069068091'))),
  ]))); }
}
