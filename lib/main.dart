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
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(backgroundColor: const Color(0xFF1976D2), centerTitle: true, title: const Text("Oday Phone - داخل الإسماعيلية فقط", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Column(children: [
            Container(width: 95, height: 95, decoration: BoxDecoration(color: const Color(0xFF1976D2), borderRadius: BorderRadius.circular(24)), child: const Icon(Icons.phone_android_rounded, size: 55, color: Colors.white)),
            const SizedBox(height: 12),
            const Text("عدي فون", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0D47A1))),
            const Text("Oday Phone", style: TextStyle(letterSpacing: 1.5, color: Colors.grey)),
            const SizedBox(height: 6),
            const Text("خدمة من المنزل • مندوب لحد بابك", style: TextStyle(fontSize: 13)),
          ]),
        ),
        const SizedBox(height: 18),
        InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StorePage())), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF7B1FA2), borderRadius: BorderRadius.circular(16)), child: const Row(children: [Icon(Icons.shopping_bag_rounded, color: Colors.white), SizedBox(width: 10), Text("متجر الاكسسوارات - اطلب اكسسوار", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Spacer(), Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14)]))),
        const SizedBox(height: 12),
        InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeServiceFormPage())), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: const Row(children: [Icon(Icons.motorcycle_rounded, color: Color(0xFF1976D2)), SizedBox(width: 10), Expanded(child: Text("صيانة من المنزل - نبعت مندوب ياخد الجهاز ويرجعه", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))), Icon(Icons.arrow_forward_ios, size: 14)]))),
        const SizedBox(height: 20),
        SizedBox(height: 56, child: ElevatedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeServiceFormPage())), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B8C3E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))), icon: const Icon(Icons.delivery_dining, color: Colors.white), label: const Text("اطلب مندوب", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)))),
        const SizedBox(height: 24),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Column(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.phone_iphone, color: Color(0xFF1976D2))), const SizedBox(height: 4), const Text("ايفون", style: TextStyle(fontSize: 10))]),
          Column(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.headset, color: Color(0xFF7B1FA2))), const SizedBox(height: 4), const Text("اكسسوارات", style: TextStyle(fontSize: 10))]),
          Column(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.battery_charging_full, color: Color(0xFF2E7D32))), const SizedBox(height: 4), const Text("شواحن", style: TextStyle(fontSize: 10))]),
          Column(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.watch, color: Colors.orange))), const SizedBox(height: 4), const Text("ساعات", style: TextStyle(fontSize: 10))]),
        ])),
      ]),
    );
  }
}

class HomeServiceFormPage extends StatefulWidget { const HomeServiceFormPage({super.key}); @override State<HomeServiceFormPage> createState() => _HomeServiceFormPageState(); }
class _HomeServiceFormPageState extends State<HomeServiceFormPage> {
  final n=TextEditingController(), ph=TextEditingController(), ad=TextEditingController(), dev=TextEditingController(), fault=TextEditingController();
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text("صيانة من المنزل"), backgroundColor: const Color(0xFF1976D2)), body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [const Icon(Icons.delivery_dining, size: 70, color: Color(0xFF1976D2)), const Text("اكتب بياناتك وهنبعتلك مندوب", style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 16), TextField(controller: n, decoration: const InputDecoration(labelText: "اسمك", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))), const SizedBox(height: 10), TextField(controller: ph, decoration: const InputDecoration(labelText: "رقم تليفونك", border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)), keyboardType: TextInputType.phone), const SizedBox(height: 10), TextField(controller: ad, decoration: const InputDecoration(labelText: "عنوانك", border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on))), const SizedBox(height: 10), TextField(controller: dev, decoration: const InputDecoration(labelText: "نوع الجهاز", border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone_android))), const SizedBox(height: 10), TextField(controller: fault, maxLines: 3, decoration: const InputDecoration(labelText: "نوع العطل", border: OutlineInputBorder(), prefixIcon: Icon(Icons.build))), const SizedBox(height: 20), SizedBox(width: double.infinity, height: 55, child: ElevatedButton.icon(onPressed: (){ if(n.text.isEmpty||ph.text.isEmpty||dev.text.isEmpty||fault.text.isEmpty){ ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("كمل بياناتك"))); return; } final msg="طلب جديد - صيانة من المنزل 🔧\n\n👤 الاسم: ${n.text}\n📞 تليفونه: ${ph.text}\n📍 العنوان: ${ad.text}\n📱 الجهاز: ${dev.text}\n⚠️ العطل: ${fault.text}"; openWhatsApp(msg); }, icon: const Icon(Icons.send, color: Colors.white), label: const Text("اطلب مندوب - واتساب", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32))))]))); }
}

class StorePage extends StatefulWidget { const StorePage({super.key}); @override State<StorePage> createState() => _StorePageState(); }
class _StorePageState extends State<StorePage> {
  List<Map> products=[]; @override void initState(){ super.initState(); load(); }
  Future<void> load() async { final p=await SharedPreferences.getInstance(); final d=p.getString('prods'); if(d!=null) setState(()=> products=List<Map>.from(jsonDecode(d))); else setState(()=> products=[{"name":"جراب شفاف","price":"50"},{"name":"اسكرينة","price":"30"},{"name":"شاحن سريع","price":"150"}]); }
  Future<void> save() async { final p=await SharedPreferences.getInstance(); await p.setString('prods', jsonEncode(products)); }
  void add(){ String a="", b=""; showDialog(context: context, builder: (_)=> AlertDialog(title: const Text("اضافة اكسسوار"), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(decoration: const InputDecoration(labelText: "اسم المنتج"), onChanged: (v)=> a=v), TextField(decoration: const InputDecoration(labelText: "السعر"), keyboardType: TextInputType.number, onChanged: (v)=> b=v)]), actions: [TextButton(onPressed: ()=> Navigator.pop(context), child: const Text("الغاء")), ElevatedButton(onPressed: (){ if(a.isNotEmpty&&b.isNotEmpty){ setState(()=> products.add({"name":a,"price":b})); save(); Navigator.pop(context);} }, child: const Text("حفظ"))])); }
  @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: const Text("متجر الاكسسوارات"), backgroundColor: const Color(0xFF7B1FA2)), floatingActionButton: FloatingActionButton(onPressed: add, backgroundColor: const Color(0xFF7B1FA2), child: const Icon(Icons.add, color: Colors.white)), body: GridView.builder(padding: const EdgeInsets.all(10), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.8, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: products.length, itemBuilder: (_, i){ final it=products[i]; return Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [const Icon(Icons.headset, size: 50, color: Color(0xFF7B1FA2)), const SizedBox(height: 8), Text(it['name'], style: const TextStyle(fontWeight: FontWeight.bold)), Text("${it['price']} جنيه", style: const TextStyle(color: Color(0xFF7B1FA2))), const Spacer(), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: (){ final msg="طلب اكسسوار 🎧\n\n📦 ${it['name']}\n💰 ${it['price']} جنيه"; openWhatsApp(msg); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)), child: const Text("اطلب اكسسوار", style: TextStyle(color: Colors.white, fontSize: 12)))) , InkWell(onTap: (){ setState(()=> products.removeAt(i)); save(); }, child: const Text("حذف", style: TextStyle(color: Colors.red, fontSize: 11))) ]))); })); }
}
