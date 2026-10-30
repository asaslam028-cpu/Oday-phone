import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
      appBar: AppBar(backgroundColor: Colors.blue[700], centerTitle: true, title: const Text("Oday Phone - داخل الإسماعيلية فقط", style: TextStyle(color: Colors.white, fontSize: 16))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // هنا شيلت الرقم وحطيت عدي فون ولوجو
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(children: [
          Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.blue[700], borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.phone_android, size: 45, color: Colors.white)),
          const SizedBox(height: 10),
          const Text("عدي فون", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
          const Text("صيانة من المنزل - نبعت مندوب ياخد الجهاز ويرجعه", style: TextStyle(fontSize: 13)),
        ])),
        const SizedBox(height: 20),
        ListTile(tileColor: Colors.purple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), leading: const Icon(Icons.store, color: Colors.white), title: const Text("متجر الاكسسوارات", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), subtitle: const Text("دوس هنا - اطلب اكسسوار موبايل", style: TextStyle(color: Colors.white70)), trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StorePage()))),
        const SizedBox(height: 10),
        ListTile(tileColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), leading: const Icon(Icons.delivery_dining, color: Colors.blue), title: const Text("صيانة من المنزل - نبعت مندوب ياخد الجهاز ويرجعه"), subtitle: const Text("دوس هنا واكتب بيانات جهازك"), trailing: const Icon(Icons.arrow_forward_ios, size: 14), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeServiceFormPage()))),
        const SizedBox(height: 20),
        SizedBox(height: 55, width: double.infinity, child: ElevatedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeServiceFormPage())), style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))), icon: const Icon(Icons.delivery_dining, color: Colors.white), label: const Text("اطلب مندوب", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)))),
      ]),
    );
  }
}

class HomeServiceFormPage extends StatefulWidget { const HomeServiceFormPage({super.key}); @override State<HomeServiceFormPage> createState() => _HomeServiceFormPageState(); }
class _HomeServiceFormPageState extends State<HomeServiceFormPage> {
  final nameC = TextEditingController(); final phoneC = TextEditingController(); final addressC = TextEditingController(); final deviceC = TextEditingController(); final faultC = TextEditingController();
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("صيانة من المنزل"), backgroundColor: Colors.blue[700]), body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
      const Icon(Icons.delivery_dining, size: 70, color: Colors.blue), const Text("اكتب بياناتك وهنبعتلك مندوب", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 20),
      TextField(controller: nameC, decoration: const InputDecoration(labelText: "اسمك", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))), const SizedBox(height: 10),
      TextField(controller: phoneC, decoration: const InputDecoration(labelText: "رقم تليفونك", border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)), keyboardType: TextInputType.phone), const SizedBox(height: 10),
      TextField(controller: addressC, decoration: const InputDecoration(labelText: "عنوانك داخل الاسماعيلية", border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on))), const SizedBox(height: 10),
      TextField(controller: deviceC, decoration: const InputDecoration(labelText: "نوع الجهاز", border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone_android))), const SizedBox(height: 10),
      TextField(controller: faultC, maxLines: 3, decoration: const InputDecoration(labelText: "نوع العطل", border: OutlineInputBorder(), prefixIcon: Icon(Icons.build))), const SizedBox(height: 25),
      SizedBox(width: double.infinity, height: 55, child: ElevatedButton.icon(onPressed: () { if(nameC.text.isEmpty || phoneC.text.isEmpty || deviceC.text.isEmpty || faultC.text.isEmpty){ ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("كمل بياناتك"))); return; } final msg = "طلب جديد - صيانة من المنزل 🔧\n\n👤 الاسم: ${nameC.text}\n📞 تليفونه: ${phoneC.text}\n📍 العنوان: ${addressC.text}\n📱 الجهاز: ${deviceC.text}\n⚠️ العطل: ${faultC.text}"; openWhatsApp(msg); }, icon: const Icon(Icons.send, color: Colors.white), label: const Text("اطلب مندوب - واتساب", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600]))),
    ])));
  }
}

class StorePage extends StatefulWidget { const StorePage({super.key}); @override State<StorePage> createState() => _StorePageState(); }
class _StorePageState extends State<StorePage> {
  List<Map> products = [];
  @override void initState() { super.initState(); load(); }
  Future<void> load() async { final p = await SharedPreferences.getInstance(); final d = p.getString('prods'); if(d!=null) setState(()=> products = List<Map>.from(jsonDecode(d))); else setState(()=> products = [{"name":"جراب شفاف","price":"50"},{"name":"اسكرينة زجاج","price":"30"},{"name":"شاحن سريع","price":"150"}]); }
  Future<void> save() async { final p = await SharedPreferences.getInstance(); await p.setString('prods', jsonEncode(products)); }
  void add() { String n="", pr=""; showDialog(context: context, builder: (_) => AlertDialog(title: const Text("اضافة اكسسوار جديد"), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(decoration: const InputDecoration(labelText: "اسم المنتج"), onChanged: (v)=> n=v), TextField(decoration: const InputDecoration(labelText: "السعر"), keyboardType: TextInputType.number, onChanged: (v)=> pr=v)]), actions: [TextButton(onPressed: ()=> Navigator.pop(context), child: const Text("الغاء")), ElevatedButton(onPressed: (){ if(n.isNotEmpty && pr.isNotEmpty){ setState(()=> products.add({"name":n,"price":pr})); save(); Navigator.pop(context);} }, child: const Text("حفظ"))])); }
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("متجر الاكسسوارات"), backgroundColor: Colors.purple), floatingActionButton: FloatingActionButton(onPressed: add, backgroundColor: Colors.purple, child: const Icon(Icons.add, color: Colors.white)), body: GridView.builder(padding: const EdgeInsets.all(10), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.8, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: products.length, itemBuilder: (_, i){ final it=products[i]; return Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [const Icon(Icons.headset, size: 50, color: Colors.purple), const SizedBox(height: 8), Text(it['name'], style: const TextStyle(fontWeight: FontWeight.bold)), Text("${it['price']} جنيه", style: const TextStyle(color: Colors.purple)), const Spacer(), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { final msg = "طلب اكسسوار جديد 🎧\n\n📦 المنتج: ${it['name']}\n💰 السعر: ${it['price']} جنيه"; openWhatsApp(msg); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text("اطلب اكسسوار", style: TextStyle(color: Colors.white, fontSize: 12)))) , InkWell(onTap: (){ setState(()=> products.removeAt(i)); save(); }, child: const Text("حذف", style: TextStyle(color: Colors.red, fontSize: 11))) ]))); }));
  }
}
