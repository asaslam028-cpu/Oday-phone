import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(const OdayApp());

class OdayApp extends StatelessWidget {
  const OdayApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: const HomePage(), theme: ThemeData(useMaterial3: true));
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  final String phone = "01069068091";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(backgroundColor: Colors.blue[700], centerTitle: true, title: const Column(children: [Text("Oday Phone", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), Text("داخل الإسماعيلية فقط", style: TextStyle(fontSize: 12, color: Colors.white)) ])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              const Icon(Icons.phone_android, size: 60, color: Colors.blue),
              const Text("Oday Phone", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(phone, style: const TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)), child: const Text("صيانة من المنزل - نبعت مندوب ياخد الجهاز ويرجعه", textAlign: TextAlign.center)),
            ]),
          ),
          const SizedBox(height: 20),
          InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccessoriesStorePage())), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(16)), child: const Row(children: [Icon(Icons.store, color: Colors.white, size: 35), SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("متجر الاكسسوارات", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)), Text("دوس هنا - اطلب اكسسوار موبايل", style: TextStyle(color: Colors.white70))]), Spacer(), Icon(Icons.arrow_forward_ios, color: Colors.white)]))),
          const SizedBox(height: 12),
          card(context, "صيانة موبايلات", Icons.build, Colors.orange),
          card(context, "صيانة من المنزل", Icons.delivery_dining, Colors.blue, isHome: true),
          card(context, "سوفت وير", Icons.memory, Colors.red),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 60, child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.delivery_dining, color: Colors.white), label: Text("اطلب مندوب - $phone", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600]))),
        ]),
      ),
    );
  }

  Widget card(BuildContext context, String title, IconData icon, Color color, {bool isHome = false}) {
    return Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: ListTile(leading: Icon(icon, color: color), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), trailing: const Icon(Icons.arrow_forward_ios, size: 14), onTap: () { if(title.contains("اكسسوار") || title.contains("متجر")) Navigator.push(context, MaterialPageRoute(builder: (_) => const AccessoriesStorePage())); }));
  }
}

// صفحة المتجر
class AccessoriesStorePage extends StatefulWidget {
  const AccessoriesStorePage({super.key});
  @override
  State<AccessoriesStorePage> createState() => _AccessoriesStorePageState();
}

class _AccessoriesStorePageState extends State<AccessoriesStorePage> {
  List<Map<String, dynamic>> products = [];
  final String phone = "01069068091";

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('my_products');
    if (data != null) {
      setState(() => products = List<Map<String, dynamic>>.from(jsonDecode(data)));
    } else {
      // منتجات افتراضية اول مرة
      setState(() => products = [
        {"name": "جراب شفاف", "price": "50", "image": null},
        {"name": "اسكرينة زجاج", "price": "30", "image": null},
        {"name": "شاحن سريع", "price": "150", "image": null},
      ]);
    }
  }

  Future<void> saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('my_products', jsonEncode(products));
  }

  Future<void> addProductDialog() async {
    String name = "";
    String price = "";
    String? base64Image;
    final picker = ImagePicker();

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text("اضافة منتج جديد"),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              InkWell(
                onTap: () async {
                  final XFile? img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
                  if (img != null) {
                    final bytes = await File(img.path).readAsBytes();
                    setDialogState(() => base64Image = base64Encode(bytes));
                  }
                },
                child: Container(height: 120, width: double.infinity, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey)), child: base64Image == null ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 40), Text("دوس لاختيار صورة")]) : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(base64Decode(base64Image!), fit: BoxFit.cover))),
              ),
              const SizedBox(height: 12),
              TextField(decoration: const InputDecoration(labelText: "اسم المنتج - مثال: جراب ايفون 13", border: OutlineInputBorder()), onChanged: (v) => name = v),
              const SizedBox(height: 8),
              TextField(decoration: const InputDecoration(labelText: "السعر - مثال: 75 جنيه", border: OutlineInputBorder()), keyboardType: TextInputType.number, onChanged: (v) => price = v),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("الغاء")),
            ElevatedButton(onPressed: () {
              if (name.isNotEmpty && price.isNotEmpty) {
                setState(() => products.add({"name": name, "price": price, "image": base64Image}));
                saveProducts();
                Navigator.pop(context);
              }
            }, child: const Text("حفظ المنتج")),
          ],
        );
      }),
    );
  }

  void deleteProduct(int index) {
    setState(() => products.removeAt(index));
    saveProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("متجر الاكسسوارات - اطلب اكسسوار"), backgroundColor: Colors.purple, actions: [IconButton(onPressed: addProductDialog, icon: const Icon(Icons.add, size: 30))]),
      floatingActionButton: FloatingActionButton.extended(onPressed: addProductDialog, backgroundColor: Colors.purple, label: const Text("اضافة منتج", style: TextStyle(color: Colors.white)), icon: const Icon(Icons.add_a_photo, color: Colors.white)),
      body: products.isEmpty ? const Center(child: Text("مفيش منتجات - دوس + عشان تضيف")) : GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: products.length,
        itemBuilder: (_, i) {
          final p = products[i];
          return Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), child: p['image'] == null ? Container(color: Colors.grey[200], child: const Icon(Icons.headset, size: 50, color: Colors.purple)) : Image.memory(base64Decode(p['image']), fit: BoxFit.cover))),
            Padding(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p['name'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("${p['price']} جنيه", style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("تم طلب ${p['name']} - اتصل على $phone لتأكيد الطلب"))); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 4)), child: const Text("اطلب اكسسوار", style: TextStyle(fontSize: 12, color: Colors.white)))),
              InkWell(onTap: () => deleteProduct(i), child: const Center(child: Text("حذف", style: TextStyle(fontSize: 11, color: Colors.red)))),
            ])),
          ]));
        },
      ),
    );
  }
}
