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
      backgroundColor: const Color(0xFFE8F0FE), // لون سماوي فاتح شيك بتاع عدي فون
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
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(children: [
          const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.phone_iphone, color: Color(0xFF1976D2)), SizedBox(width: 6), Text("كل حاجة لموبايلك في مكان واحد", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.phone_android, color: Color(0xFF1976D2), size: 30)),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.headset, color: Color(0xFF8E24AA), size: 30)),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.charging_station, color: Color(0xFF2E7D32), size: 30)),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.watch, color: Colors.orange, size: 30)),
          ]),
        ])),
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
      SizedBox(width: double.infinity, height: 55, child: ElevatedButton.icon(onPressed: () { if(nameC.text.isEmpty || phoneC.text.isEmpty || deviceC.text.isEmpty || faultC.text.isEmpty){ ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("كمل بياناتك"))); return; } final msg = "طلب جديد - صيانة من المنزل\n\nالاسم: ${nameC.text}\nتليفونه: ${phoneC.text}\nالعنوان: ${addressC.text}\nالجهاز: ${deviceC.text}\nالعطل: ${faultC.text}"; openWhatsApp(msg); }, icon: const Icon(Icons.send, color: Colors.white), label: const Text("اطلب مندوب - واتساب", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)))),
    ])));
  }
}

class StorePage extends StatefulWidget { const StorePage({super.key}); @override State<StorePage> createState() => _StorePageState(); }
class _StorePageState extends State<StorePage> {
  List<Map> products = [];
  final ImagePicker _picker = ImagePicker();
  bool isAdmin = false;
  @override void initState() { super.initState(); load(); }
  Future<void> load() async { final p = await SharedPreferences.getInstance(); final d = p.getString('prods_v2'); if(d!=null) setState(()=> products = List<Map>.from(jsonDecode(d))); }
  Future<void> save() async { final p = await SharedPreferences.getInstance(); await p.setString('prods_v2', jsonEncode(products)); }
  void askAdminPassword() {
    String pass = "";
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text("دخول الأدمن"),
      content: TextField(obscureText: true, decoration: const InputDecoration(labelText: "الباسورد", border: OutlineInputBorder()), onChanged: (v)=> pass=v),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(context), child: const Text("الغاء")),
        ElevatedButton(onPressed: (){ if(pass=="oday123"){ setState(()=> isAdmin = true); Navigator.pop(context); } else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("باسورد غلط"))); } }, child: const Text("دخول"))
      ],
    ));
  }
  void addProduct() {
    String n="", pr="", desc="", color="", cap=""; String img1="", img2="";
    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (ctx, setD) => AlertDialog(
      title: const Text("اضافة منتج - صورتين"),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Expanded(child: InkWell(onTap: () async { final XFile? x = await _picker.pickImage(source: ImageSource.gallery); if(x!=null){ setD(()=> img1 = x.path); } }, child: Container(height: 90, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)), child: img1.isEmpty ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo), Text("صورة 1", style: TextStyle(fontSize: 10))]) : Image.file(File(img1), fit: BoxFit.cover, width: double.infinity, height: 90)))),
          const SizedBox(width: 8),
          Expanded(child: InkWell(onTap: () async { final XFile? x = await _picker.pickImage(source: ImageSource.gallery); if(x!=null){ setD(()=> img2 = x.path); } }, child: Container(height: 90, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)), child: img2.isEmpty ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo), Text("صورة 2", style: TextStyle(fontSize: 10))]) : Image.file(File(img2), fit: BoxFit.cover, width: double.infinity, height: 90)))),
        ]),
        const SizedBox(height: 10),
        TextField(decoration: const InputDecoration(labelText: "اسم المنتج", border: OutlineInputBorder()), onChanged: (v)=> n=v),
        const SizedBox(height: 8),
        TextField(decoration: const InputDecoration(labelText: "السعر", border: OutlineInputBorder()), keyboardType: TextInputType.number, onChanged: (v)=> pr=v),
        const SizedBox(height: 8),
        TextField(decoration: const InputDecoration(labelText: "اللون", border: OutlineInputBorder()), onChanged: (v)=> color=v),
        const SizedBox(height: 8),
        TextField(decoration: const InputDecoration(labelText: "الامكانيات", border: OutlineInputBorder()), onChanged: (v)=> cap=v),
        const SizedBox(height: 8),
        TextField(decoration: const InputDecoration(labelText: "الوصف", border: OutlineInputBorder()), maxLines: 2, onChanged: (v)=> desc=v),
      ])),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(ctx), child: const Text("الغاء")),
        ElevatedButton(onPressed: (){ if(n.isNotEmpty && pr.isNotEmpty){ List<String> imgs = []; if(img1.isNotEmpty) imgs.add(img1); if(img2.isNotEmpty) imgs.add(img2); setState(()=> products.add({"name":n,"price":pr,"images":imgs, "image": imgs.isNotEmpty ? imgs[0] : "", "description":desc, "color":color, "capabilities":cap})); save(); Navigator.pop(ctx);} }, child: const Text("حفظ"))
      ],
    )));
  }
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text("متجر الاكسسوارات"), backgroundColor: const Color(0xFF8E24AA), actions: [IconButton(onPressed: (){ if(isAdmin) setState(()=> isAdmin=false); else askAdminPassword(); }, icon: Icon(isAdmin ? Icons.lock_open : Icons.lock, color: Colors.white))]),
      floatingActionButton: isAdmin ? FloatingActionButton(onPressed: addProduct, backgroundColor: const Color(0xFF8E24AA), child: const Icon(Icons.add_a_photo, color: Colors.white)) : null,
      body: products.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.store, size: 60, color: Colors.grey), const Text("مفيش منتجات"), if(!isAdmin) ElevatedButton(onPressed: askAdminPassword, child: const Text("دخول الأدمن"))])) : GridView.builder(padding: const EdgeInsets.all(10), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.68, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: products.length, itemBuilder: (_, i){
        final it=products[i];
        List imgs = it['images'] ?? (it['image']!=null && it['image'].toString().isNotEmpty ? [it['image']] : []);
        String firstImg = imgs.isNotEmpty ? imgs[0].toString() : "";
        bool hasImg = firstImg.isNotEmpty && File(firstImg).existsSync();
        return InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: it, onDelete: (){ setState(()=> products.removeAt(i)); save(); }, isAdmin: isAdmin))),
          child: Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), child: hasImg ? Image.file(File(firstImg), height: 140, width: double.infinity, fit: BoxFit.cover) : Container(height: 140, width: double.infinity, color: const Color(0xFFF3E5F5), child: const Icon(Icons.headset, size: 60, color: Color(0xFF8E24AA)))),
            Padding(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(it['name'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text("${it['price']} جنيه", style: const TextStyle(color: Color(0xFF8E24AA), fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              SizedBox(width: double.infinity, height: 32, child: ElevatedButton(onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: it, onDelete: (){ setState(()=> products.removeAt(i)); save(); }, isAdmin: isAdmin))); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)), child: const Text("عرض", style: TextStyle(color: Colors.white, fontSize: 11)))),
            ]))
          ])),
        );
      }),
    );
  }
}

class ProductDetailPage extends StatefulWidget {
  final Map product;
  final VoidCallback onDelete;
  final bool isAdmin;
  const ProductDetailPage({super.key, required this.product, required this.onDelete, required this.isAdmin});
  @override State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int currentPage = 0;
  @override Widget build(BuildContext context) {
    List imgs = widget.product['images'] ?? [];
    if(imgs.isEmpty && widget.product['image']!=null && widget.product['image'].toString().isNotEmpty){ imgs = [widget.product['image']]; }
    return Scaffold(
      appBar: AppBar(title: Text(widget.product['name'] ?? ""), backgroundColor: const Color(0xFF8E24AA), actions: [if(widget.isAdmin) IconButton(onPressed: (){ widget.onDelete(); Navigator.pop(context); }, icon: const Icon(Icons.delete))]),
      body: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: 350,
          width: double.infinity,
          child: imgs.isEmpty ? Container(color: const Color(0xFFF3E5F5), child: const Icon(Icons.headset, size: 100, color: Color(0xFF8E24AA))) : Stack(
            children: [
              PageView.builder(
                itemCount: imgs.length,
                onPageChanged: (i)=> setState(()=> currentPage=i),
                itemBuilder: (_, idx){
                  String p = imgs[idx].toString();
                  bool ok = File(p).existsSync();
                  return ok ? Image.file(File(p), fit: BoxFit.contain, width: double.infinity) : Container(color: Colors.grey[200], child: const Icon(Icons.broken_image));
                },
              ),
              if(imgs.length>1)
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(imgs.length, (i){
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: currentPage==i ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: currentPage==i ? const Color(0xFF8E24AA) : Colors.grey,
                          borderRadius: BorderRadius.circular(4)
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
        Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.product['name'] ?? "", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text("${widget.product['price']} جنيه", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF8E24AA))),
          const Divider(height: 30),
          if((widget.product['color']??"").toString().isNotEmpty)
            Container(width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(10)), child: Text("اللون: ${widget.product['color']}")),
          if((widget.product['capabilities']??"").toString().isNotEmpty)
            Container(width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(10)), child: Text("الامكانيات: ${widget.product['capabilities']}")),
          if((widget.product['description']??"").toString().isNotEmpty)
            Container(width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(10)), child: Text("الوصف: ${widget.product['description']}")),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 55, child: ElevatedButton.icon(onPressed: (){ final msg = "طلب اكسسوار\nالمنتج: ${widget.product['name']}\nالسعر: ${widget.product['price']} جنيه\nاللون: ${widget.product['color'] ?? ''}"; openWhatsApp(msg); }, icon: const Icon(Icons.shopping_cart, color: Colors.white), label: const Text("اطلب المنتج - واتساب", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))))),
        ]))
      ])),
    );
  }
}
