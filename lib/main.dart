import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(const OdayApp());
class OdayApp extends StatelessWidget { const OdayApp({super.key}); @override Widget build(BuildContext context) { return MaterialApp(debugShowCheckedModeBanner: false, home: const HomePage()); } }

Future<void> openWhatsApp(String message) async {
  const phone = "201069068091";
  final url = Uri.parse("https://wa.me/$phone?text=${Uri.encodeComponent(message)}");
  await launchUrl(url, mode: LaunchMode.externalApplication);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(backgroundColor: const Color(0xFF1976D2), centerTitle: true, title: const Text("Oday Phone - داخل الإسماعيلية فقط", style: TextStyle(color: Colors.white, fontSize: 16))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(children: [
          Container(width: 80, height: 80, decoration: BoxDecoration(color: const Color(0xFF1976D2), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.phone_android_rounded, size: 45, color: Colors.white)),
          const SizedBox(height: 10),
          const Text("عدي فون", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
          const Text("صيانة من المنزل - نبعت مندوب ياخد الجهاز ويرجعه", style: TextStyle(fontSize: 13)),
        ])),
        const SizedBox(height: 16),
        InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StorePage())), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF8E24AA), borderRadius: BorderRadius.circular(12)), child: const Row(children: [Icon(Icons.store_rounded, color: Colors.white), SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("متجر الاكسسوارات", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text("دوس هنا - اطلب اكسسوار موبايل", style: TextStyle(color: Colors.white70, fontSize: 12))])), Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16)]))),
        const SizedBox(height: 10),
        InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeServiceFormPage())), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: const Row(children: [Icon(Icons.delivery_dining, color: Color(0xFF1976D2)), SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("صيانة من المنزل - نبعت مندوب ياخد الجهاز ويرجعه", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Text("دوس هنا واكتب بيانات جهازك", style: TextStyle(fontSize: 12, color: Colors.grey))])), Icon(Icons.arrow_forward_ios, size: 14)]))),
        const SizedBox(height: 20),
        SizedBox(height: 56, width: double.infinity, child: ElevatedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeServiceFormPage())), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))), icon: const Icon(Icons.delivery_dining, color: Colors.white), label: const Text("اطلب مندوب", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)))),
        const SizedBox(height: 20),
        // الرسمة اللي بتملا الفراغ الابيض
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)]),
          child: Column(children: [
            const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.phone_iphone, color: Color(0xFF1976D2)), SizedBox(width: 6), Text("كل حاجة لموبايلك في مكان واحد", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))]),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.phone_android, color: Color(0xFF1976D2), size: 30)),
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.headset, color: Color(0xFF8E24AA), size: 30)),
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.charging_station, color: Color(0xFF2E7D32), size: 30)),
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.watch, color: Colors.orange, size: 30)),
            ]),
            const SizedBox(height: 8),
            const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Chip(label: Text("شحن سريع", style: TextStyle(fontSize: 10)), visualDensity: VisualDensity.compact),
              SizedBox(width: 6),
              Chip(label: Text("منتجات اصلية", style: TextStyle(fontSize: 10)), visualDensity: VisualDensity.compact),
              SizedBox(width: 6),
              Chip(label: Text("ضمان", style: TextStyle(fontSize: 10)), visualDensity: VisualDensity.compact),
            ])
          ]),
        )
      ]),
    );
  }
}

class HomeServiceFormPage extends StatefulWidget { const HomeServiceFormPage({super.key}); @override State<HomeServiceFormPage> createState() => _HomeServiceFormPageState(); }
class _HomeServiceFormPageState extends State<HomeServiceFormPage> {
  final nameC = TextEditingController(); final phoneC = TextEditingController(); final addressC = TextEditingController(); final deviceC = TextEditingController(); final faultC = TextEditingController();
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("صيانة من المنزل"), backgroundColor: const Color(0xFF1976D2)), body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
      const Icon(Icons.delivery_dining, size: 70, color: Color(0xFF1976D2)), const Text("اكتب بياناتك وهنبعتلك مندوب", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 20),
      TextField(controller: nameC, decoration: const InputDecoration(labelText: "اسمك", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))), const SizedBox(height: 10),
      TextField(controller: phoneC, decoration: const InputDecoration(labelText: "رقم تليفونك", border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)), keyboardType: TextInputType.phone), const SizedBox(height: 10),
      TextField(controller: addressC, decoration: const InputDecoration(labelText: "عنوانك داخل الاسماعيلية", border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on))), const SizedBox(height: 10),
      TextField(controller: deviceC, decoration: const InputDecoration(labelText: "نوع الجهاز", border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone_android))), const SizedBox(height: 10),
      TextField(controller: faultC, maxLines: 3, decoration: const InputDecoration(labelText: "نوع العطل", border: OutlineInputBorder(), prefixIcon: Icon(Icons.build))), const SizedBox(height: 25),
      SizedBox(width: double.infinity, height: 55, child: ElevatedButton.icon(onPressed: () { if(nameC.text.isEmpty || phoneC.text.isEmpty || deviceC.text.isEmpty || faultC.text.isEmpty){ ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("كمل بياناتك"))); return; } final msg = "طلب جديد - صيانة من المنزل 🔧\n\n👤 الاسم: ${nameC.text}\n📞 تليفونه: ${phoneC.text}\n📍 العنوان: ${addressC.text}\n📱 الجهاز: ${deviceC.text}\n⚠️ العطل: ${faultC.text}"; openWhatsApp(msg); }, icon: const Icon(Icons.send, color: Colors.white), label: const Text("اطلب مندوب - واتساب", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)))),
    ])));
  }
}

class StorePage extends StatefulWidget { const StorePage({super.key}); @override State<StorePage> createState() => _StorePageState(); }
class _StorePageState extends State<StorePage> {
  List<Map> products = [];
  final ImagePicker _picker = ImagePicker();
  @override void initState() { super.initState(); load(); }
  Future<void> load() async { final p = await SharedPreferences.getInstance(); final d = p.getString('prods_v2'); if(d!=null) setState(()=> products = List<Map>.from(jsonDecode(d))); else setState(()=> products = [{"name":"جراب شفاف","price":"50","image":""},{"name":"اسكرينة زجاج","price":"30","image":""},{"name":"شاحن سريع","price":"150","image":""}]); }
  Future<void> save() async { final p = await SharedPreferences.getInstance(); await p.setString('prods_v2', jsonEncode(products)); }

  void addProduct() {
    String n="", pr=""; String imgPath="";
    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (ctx, setD) => AlertDialog(
      title: const Text("اضافة اكسسوار بصورة"),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        InkWell(onTap: () async { final XFile? x = await _picker.pickImage(source: ImageSource.gallery); if(x!=null){ setD(()=> imgPath = x.path); } }, child: Container(height: 100, width: double.infinity, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey)), child: imgPath.isEmpty ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 30), Text("دوس لاختيار صورة", style: TextStyle(fontSize: 11))]) : ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(File(imgPath), fit: BoxFit.cover)))),
        const SizedBox(height: 10),
        TextField(decoration: const InputDecoration(labelText: "اسم المنتج", border: OutlineInputBorder()), onChanged: (v)=> n=v),
        const SizedBox(height: 8),
        TextField(decoration: const InputDecoration(labelText: "السعر", border: OutlineInputBorder()), keyboardType: TextInputType.number, onChanged: (v)=> pr=v),
      ])),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(ctx), child: const Text("الغاء")),
        ElevatedButton(onPressed: (){ if(n.isNotEmpty && pr.isNotEmpty){ setState(()=> products.add({"name":n,"price":pr,"image":imgPath})); save(); Navigator.pop(ctx);} }, child: const Text("حفظ"))
      ],
    )));
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("متجر الاكسسوارات"), backgroundColor: const Color(0xFF8E24AA)),
      floatingActionButton: FloatingActionButton(onPressed: addProduct, backgroundColor: const Color(0xFF8E24AA), child: const Icon(Icons.add_a_photo, color: Colors.white)),
      body: GridView.builder(padding: const EdgeInsets.all(10), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: products.length, itemBuilder: (_, i){
        final it=products[i];
        final hasImg = it['image']!=null && it['image'].toString().isNotEmpty && File(it['image']).existsSync();
        return Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Padding(padding: const EdgeInsets.all(10), child: Column(children: [
          hasImg ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(it['image']), height: 70, width: double.infinity, fit: BoxFit.cover)) : const Icon(Icons.headset, size: 50, color: Color(0xFF8E24AA)),
          const SizedBox(height: 6),
          Text(it['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text("${it['price']} جنيه", style: const TextStyle(color: Color(0xFF8E24AA), fontSize: 12)),
          const Spacer(),
          SizedBox(width: double.infinity, height: 32, child: ElevatedButton(onPressed: () { final msg = "طلب اكسسوار 🎧\n\n📦 المنتج: ${it['name']}\n💰 السعر: ${it['price']} جنيه"; openWhatsApp(msg); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)), child: const Text("اطلب", style: TextStyle(color: Colors.white, fontSize: 12)))),
          InkWell(onTap: (){ setState(()=> products.removeAt(i)); save(); }, child: const Padding(padding: EdgeInsets.only(top: 4), child: Text("حذف", style: TextStyle(color: Colors.red, fontSize: 10))))
        ])));
      }),
    );
  }
}
