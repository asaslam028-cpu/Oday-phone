import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() { runApp(const OdayApp()); }

const String vodafoneNumber = '01015519180';
const String instapayNumber = '01069068091';

// ================= MODELS =================
class ServiceItem {
  String name; String desc; IconData icon; double price; String category; double rating; bool isFav;
  ServiceItem({required this.name, required this.desc, required this.icon, required this.price, required this.category, this.rating = 4.8, this.isFav = false});
  Map<String, dynamic> toJson() => {'name': name, 'desc': desc, 'price': price, 'category': category, 'rating': rating, 'isFav': isFav, 'icon': icon.codePoint};
  factory ServiceItem.fromJson(Map<String, dynamic> j) => ServiceItem(name: j['name'], desc: j['desc'], price: (j['price'] as num).toDouble(), category: j['category'], rating: (j['rating'] as num?)?.toDouble() ?? 4.8, isFav: j['isFav'] ?? false, icon: IconData(j['icon'] ?? Icons.build.codePoint, fontFamily: 'MaterialIcons'));
}
class Product {
  String name; String desc; double price; String? imagePath; String? imageUrl; IconData icon; String category; bool isOffer; double oldPrice; bool isFav;
  Product({required this.name, required this.desc, required this.price, this.imagePath, this.imageUrl, required this.icon, required this.category, this.isOffer = false, this.oldPrice = 0, this.isFav = false});
  Map<String, dynamic> toJson() => {'name': name, 'desc': desc, 'price': price, 'imagePath': imagePath, 'imageUrl': imageUrl, 'category': category, 'isOffer': isOffer, 'oldPrice': oldPrice, 'isFav': isFav, 'icon': icon.codePoint};
  factory Product.fromJson(Map<String, dynamic> j) => Product(name: j['name'], desc: j['desc'], price: (j['price'] as num).toDouble(), imagePath: j['imagePath'], imageUrl: j['imageUrl'], category: j['category'], isOffer: j['isOffer'] ?? false, oldPrice: (j['oldPrice'] as num?)?.toDouble() ?? 0, isFav: j['isFav'] ?? false, icon: IconData(j['icon'] ?? Icons.shopping_bag.codePoint, fontFamily: 'MaterialIcons'));
}
class OrderItem { String name; int qty; double price; OrderItem({required this.name, required this.qty, required this.price}); Map<String, dynamic> toJson() => {'name': name, 'qty': qty, 'price': price}; factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(name: j['name'], qty: j['qty'], price: (j['price'] as num).toDouble()); }
class AppOrder {
  String id; String customerName; String phone; String address; String paymentMethod; String status; List<OrderItem> items; double total; String? proofPath; String date;
  AppOrder({required this.id, required this.customerName, required this.phone, required this.address, required this.paymentMethod, required this.status, required this.items, required this.total, this.proofPath, required this.date});
  Map<String, dynamic> toJson() => {'id': id, 'customerName': customerName, 'phone': phone, 'address': address, 'paymentMethod': paymentMethod, 'status': status, 'items': items.map((e) => e.toJson()).toList(), 'total': total, 'proofPath': proofPath, 'date': date};
  factory AppOrder.fromJson(Map<String, dynamic> j) => AppOrder(id: j['id'], customerName: j['customerName'], phone: j['phone'], address: j['address'], paymentMethod: j['paymentMethod'], status: j['status'], items: (j['items'] as List).map((e) => OrderItem.fromJson(e)).toList(), total: (j['total'] as num).toDouble(), proofPath: j['proofPath'], date: j['date']);
}
// طلب صيانة من المنزل - جديد
class MaintenanceRequest {
  String id; String customerName; String phone; String address; String faultType; String problem; String date; String status;
  MaintenanceRequest({required this.id, required this.customerName, required this.phone, required this.address, required this.faultType, required this.problem, required this.date, this.status = 'جديد'});
  Map<String, dynamic> toJson() => {'id': id, 'customerName': customerName, 'phone': phone, 'address': address, 'faultType': faultType, 'problem': problem, 'date': date, 'status': status};
  factory MaintenanceRequest.fromJson(Map<String, dynamic> j) => MaintenanceRequest(id: j['id'], customerName: j['customerName'], phone: j['phone'], address: j['address'], faultType: j['faultType'], problem: j['problem'], date: j['date'], status: j['status'] ?? 'جديد');
}

// ================= APP =================
class OdayApp extends StatefulWidget { const OdayApp({super.key}); @override State<OdayApp> createState() => _OdayAppState(); }
class _OdayAppState extends State<OdayApp> {
  bool showStart = true;
  int currentIndex = 0;
  String searchText = '';
  String selectedCategory = 'الكل';
  String storeCategory = 'الكل';
  List<OrderItem> cart = [];
  List<AppOrder> orders = [];
  List<MaintenanceRequest> maintenanceRequests = [];

  List<ServiceItem> services = [
    ServiceItem(name: 'نجار', desc: 'تركيب وتصليح وفك وتركيب اثاث، غرف نوم، مطابخ، ابواب', icon: Icons.chair, price: 150, category: 'نجارة', rating: 4.9),
    ServiceItem(name: 'كهربائي', desc: 'تصليح كهرباء، تركيب اضاءة، برايز، مراوح', icon: Icons.electrical_services, price: 120, category: 'كهرباء', rating: 4.8),
  ];

  List<Product> products = [
    Product(name: 'شاحن سريع 25 وات', desc: 'شاحن اصلي سريع، كابل تايب سي', price: 350, oldPrice: 450, isOffer: true, icon: Icons.charging_station, category: 'شواحن'),
    Product(name: 'كابل تايب سي', desc: 'كابل شحن سريع 1 متر', price: 90, icon: Icons.cable, category: 'كابلات'),
    Product(name: 'جراب موبايل', desc: 'جراب حماية قوي ضد الصدمات', price: 120, icon: Icons.phone_android, category: 'اكسسوارات'),
    Product(name: 'سماعة بلوتوث', desc: 'سماعة صوت نقي وبطارية طويلة', price: 550, oldPrice: 700, isOffer: true, icon: Icons.headphones, category: 'سماعات'),
    Product(name: 'اسكرينة حماية', desc: 'اسكرينة زجاج ضد الكسر', price: 80, icon: Icons.shield, category: 'اكسسوارات'),
    Product(name: 'باور بانك 10000', desc: 'باور بانك سعة 10000 مللي امبير', price: 450, oldPrice: 550, isOffer: true, icon: Icons.battery_charging_full, category: 'شواحن'),
  ];

  @override void initState() { super.initState(); _loadAll(); }

  Future<void> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    String? pStr = prefs.getString('products');
    String? oStr = prefs.getString('orders');
    String? mStr = prefs.getString('maintenance');
    if (pStr != null) { try { List d = jsonDecode(pStr); setState(() { products = d.map((e) => Product.fromJson(e)).toList(); }); } catch (_) {} }
    if (oStr != null) { try { List d = jsonDecode(oStr); setState(() { orders = d.map((e) => AppOrder.fromJson(e)).toList(); }); } catch (_) {} }
    if (mStr != null) { try { List d = jsonDecode(mStr); setState(() { maintenanceRequests = d.map((e) => MaintenanceRequest.fromJson(e)).toList(); }); } catch (_) {} }
  }
  Future<void> _saveProducts() async { final p = await SharedPreferences.getInstance(); await p.setString('products', jsonEncode(products.map((e) => e.toJson()).toList())); }
  Future<void> _saveOrders() async { final p = await SharedPreferences.getInstance(); await p.setString('orders', jsonEncode(orders.map((e) => e.toJson()).toList())); }
  Future<void> _saveMaintenance() async { final p = await SharedPreferences.getInstance(); await p.setString('maintenance', jsonEncode(maintenanceRequests.map((e) => e.toJson()).toList())); }

  void addProduct(Product p) { setState(() { products.add(p); }); _saveProducts(); }
  void deleteProduct(int i) { setState(() { products.removeAt(i); }); _saveProducts(); }
  void addToCart(String name, double price) {
    setState(() {
      int i = cart.indexWhere((e) => e.name == name);
      if (i >= 0) { cart[i].qty++; } else { cart.add(OrderItem(name: name, qty: 1, price: price)); }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم اضافة $name للسلة')));
  }
  void onCheckout(String name, String phone, String address, String pay, String? proof) {
    if (cart.isEmpty) return;
    double total = cart.fold(0, (s, e) => s + e.price * e.qty);
    setState(() {
      orders.add(AppOrder(id: DateTime.now().millisecondsSinceEpoch.toString(), customerName: name, phone: phone, address: address, paymentMethod: pay, status: 'جديد', items: List.from(cart), total: total, proofPath: proof, date: DateTime.now().toString().substring(0, 16)));
      cart.clear(); currentIndex = 0;
    });
    _saveOrders();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم استلام طلبك بنجاح، هنتواصل معاك')));
  }
  void onAddMaintenance(MaintenanceRequest r) {
    setState(() { maintenanceRequests.add(r); });
    _saveMaintenance();
  }
  void openAdmin() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPage(products: products, orders: orders, maintenanceRequests: maintenanceRequests, onAddProduct: addProduct, onDeleteProduct: deleteProduct)));
  }
  void openMaintenance() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => MaintenancePage(onSubmit: (r) { onAddMaintenance(r); Navigator.pop(context); })));
  }

  @override Widget build(BuildContext context) {
    if (showStart) {
     if (showStart) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.phone_android, size: 90, color: Colors.white),
            const SizedBox(height: 16),
            const Text("اهلا بك في", textAlign: TextAlign.center, style: TextStyle(fontSize: 22, color: Colors.white)),
            const Text("ابليكيشن عدي فون", textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            const Text("خدمات صيانة ومنتجات موبايل في مكان واحد", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => setState(() => showStart = false),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.orange, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14)),
              child: const Text("تسجيل الان", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    ),
  );
}
    }
    List<Product> homeFiltered = products.where((p) => searchText.isEmpty || p.name.contains(searchText) || p.desc.contains(searchText)).toList();
    List<Product> storeFiltered = products.where((p) => (storeCategory == 'الكل' || p.category == storeCategory) && (searchText.isEmpty || p.name.contains(searchText))).toList();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(backgroundColor: Colors.orange, foregroundColor: Colors.white, title: GestureDetector(onDoubleTap: openAdmin, child: const Text('عدي فون - Oday Phone')), actions: [IconButton(icon: Badge(label: Text('${cart.length}'), child: const Icon(Icons.shopping_cart)), onPressed: () => setState(() => currentIndex = 2))]),
        body: currentIndex == 0 ? HomePage(searchText: searchText, onSearch: (v) => setState(() => searchText = v), products: homeFiltered, services: services, onAddToCart: addToCart, onGoStore: () => setState(() => currentIndex = 1), onGoMaintenance: openMaintenance) : currentIndex == 1 ? StorePage(products: storeFiltered, searchText: searchText, onSearch: (v) => setState(() => searchText = v), category: storeCategory, onCategory: (v) => setState(() => storeCategory = v), onAddToCart: addToCart, onBuyNow: (p) { addToCart(p.name, p.price); setState(() => currentIndex = 2); }) : CartPage(cart: cart, onRemove: (i) => setState(() => cart.removeAt(i)), onInc: (i) => setState(() => cart[i].qty++), onDec: (i) => setState(() { if (cart[i].qty > 1) cart[i].qty--; }), onCheckout: onCheckout),
        bottomNavigationBar: BottomNavigationBar(currentIndex: currentIndex, selectedItemColor: Colors.orange, onTap: (i) => setState(() => currentIndex = i), items: const [BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'), BottomNavigationBarItem(icon: Icon(Icons.store), label: 'المتجر'), BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'السلة')]),
      ),
    );
  }
}

// ================= HOME =================
class HomePage extends StatelessWidget {
  final String searchText; final Function(String) onSearch; final List<Product> products; final List<ServiceItem> services; final Function(String, double) onAddToCart; final VoidCallback onGoStore; final VoidCallback onGoMaintenance;
  const HomePage({super.key, required this.searchText, required this.onSearch, required this.products, required this.services, required this.onAddToCart, required this.onGoStore, required this.onGoMaintenance});
  @override Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('مرحبا بكم في عدي فون', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4), const Text('كل اللي محتاجه لموبايلك في مكان واحد', style: TextStyle(color: Colors.grey)),
      const SizedBox(height: 12),
      TextField(decoration: const InputDecoration(hintText: 'ابحث عن منتج او خدمة...', prefixIcon: Icon(Icons.search), border: OutlineInputBorder(), filled: true, fillColor: Colors.white), onChanged: onSearch),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: InkWell(onTap: onGoStore, child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.orange)), child: Column(children: [const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.store, color: Colors.white)), const SizedBox(height: 10), const Text('المتجر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const Text('شواحن - اكسسوارات', style: TextStyle(fontSize: 11, color: Colors.grey))])))),
        const SizedBox(width: 10),
        Expanded(child: InkWell(onTap: onGoMaintenance, child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.blue)), child: Column(children: [const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.build, color: Colors.white)), const SizedBox(height: 10), const Text('اطلب صيانة من المنزل', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)), const Text('مندوب ياخد الجهاز ويرجعه', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey))])))),
      ]),
      const SizedBox(height: 12),
      Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFFF5722)]), borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('خصومات تصل الي 30%', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('على الشواحن والسماعات والاسكرينات', style: TextStyle(color: Colors.white)), SizedBox(height: 10), Text('اطلب الان من المتجر', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))])),
      const SizedBox(height: 16),
      const Text('خدمات اخرى من عدي فون', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Row(children: services.map((s) => Expanded(child: Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), child: InkWell(onTap: () => onAddToCart(s.name, s.price), child: Padding(padding: const EdgeInsets.all(14), child: Column(children: [CircleAvatar(backgroundColor: Colors.blue.shade50, radius: 30, child: Icon(s.icon, color: Colors.blue, size: 30)), const SizedBox(height: 8, Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 4), Text('من ${s.price.toStringAsFixed(0)} ج', style: const TextStyle(color: Colors.grey)), const SizedBox(height: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)), child: const Text('اطلب الان', style: TextStyle(color: Colors.white))) ])))))).toList()),
      const SizedBox(height: 16),
      const Text('منتجات مميزة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      ...products.take(4).map((p) => Card(child: ListTile(leading: p.imageUrl != null && p.imageUrl!.isNotEmpty ? ClipRRect(borderRadius: BorderRadius.circular(8, child: Image.network(p.imageUrl!, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (, _, _) => Icon(p.icon))) : p.imagePath != null ? ClipRRect(borderRadius: BorderRadius.circular(8, child: Image.file(File(p.imagePath!), width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (, _, _) => Icon(p.icon))) : Icon(p.icon, color: Colors.orange), title: Text(p.name), subtitle: Text('${p.price} ج'), trailing: ElevatedButton(onPressed: () => onAddToCart(p.name, p.price), child: const Text('اضف'))))).toList(),
    ]));
  }
}

// ================= MAINTENANCE REQUEST PAGE =================
class MaintenancePage extends StatefulWidget {
  final Function(MaintenanceRequest) onSubmit;
  const MaintenancePage({super.key, required this.onSubmit});
  @override State<MaintenancePage> createState() => _MaintenancePageState();
}
class _MaintenancePageState extends State<MaintenancePage> {
  TextEditingController nameC = TextEditingController(); TextEditingController phoneC = TextEditingController(); TextEditingController addressC = TextEditingController(); TextEditingController problemC = TextEditingController();
  String faultType = 'صيانة موبايل';
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اطلب صيانة من المنزل'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('هنبعتلك مندوب ياخد الجهاز', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('املا بياناتك، وهنكلمك ونبعت مندوب ياخد الجهاز نصلحه ونرجعهولك تاني.')])),
        const SizedBox(height: 16),
        const Text('نوع العطل', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        DropdownButtonFormField(value: faultType, items: ['صيانة موبايل', 'تغيير شاشة', 'تغيير بطارية', 'سوكت شحن', 'نجارة', 'كهرباء', 'عطل اخر'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => faultType = v.toString()), decoration: const InputDecoration(border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: problemC, decoration: const InputDecoration(labelText: 'ايه المشكلة اللي عندك؟ اشرحها بالتفصيل', border: OutlineInputBorder(), hintText: 'مثال: الشاشة مكسورة والموبايل مش بيفتح'), maxLines: 3),
        const SizedBox(height: 12),
        TextField(controller: nameC, decoration: const InputDecoration(labelText: 'الاسم بالكامل', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: phoneC, decoration: const InputDecoration(labelText: 'رقم التليفون', border: OutlineInputBorder()), keyboardType: TextInputType.phone),
        const SizedBox(height: 12),
        TextField(controller: addressC, decoration: const InputDecoration(labelText: 'العنوان بالتفصيل - المندوب هيجيلك عليه', border: OutlineInputBorder()), maxLines: 2),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.all(14)), onPressed: () {
          if (nameC.text.isEmpty || phoneC.text.isEmpty || addressC.text.isEmpty || problemC.text.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اكمل كل البيانات الاول'))); return; }
          widget.onSubmit(MaintenanceRequest(id: DateTime.now().millisecondsSinceEpoch.toString(), customerName: nameC.text, phone: phoneC.text, address: addressC.text, faultType: faultType, problem: problemC.text, date: DateTime.now().toString().substring(0, 16)));
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم استلام طلب الصيانة، هنكلمك ونبعتلك المندوب')));
        }, child: const Text('اطلب مندوب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
      ])),
    );
  }
}

// ================= STORE =================
class StorePage extends StatelessWidget {
  final List<Product> products; final String searchText; final Function(String) onSearch; final String category; final Function(String) onCategory; final Function(String, double) onAddToCart; final Function(Product) onBuyNow;
  const StorePage({super.key, required this.products, required this.searchText, required this.onSearch, required this.category, required this.onCategory, required this.onAddToCart, required this.onBuyNow});
  @override Widget build(BuildContext context) {
    List<String> cats = ['الكل', 'شواحن', 'كابلات', 'اكسسوارات', 'سماعات'];
    List<IconData> catIcons = [Icons.apps, Icons.charging_station, Icons.cable, Icons.phone_android, Icons.headphones];
    return Column(children: [
      Padding(padding: const EdgeInsets.all(12), child: TextField(decoration: const InputDecoration(hintText: 'ابحث في المتجر...', prefixIcon: Icon(Icons.search), border: OutlineInputBorder(), filled: true, fillColor: Colors.white), onChanged: onSearch)),
      SizedBox(height: 100, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: cats.length, itemBuilder: (c, i) => Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: InkWell(onTap: () => onCategory(cats[i]), child: Container(width: 80, padding: const EdgeInsets.all(8, decoration: BoxDecoration(color: category == cats[i] ? Colors.orange : Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.orange)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(catIcons[i], color: category == cats[i] ? Colors.white : Colors.orange), const SizedBox(height: 4), Text(cats[i], style: TextStyle(color: category == cats[i] ? Colors.white : Colors.black, fontWeight: FontWeight.bold))])))))),
      Expanded(child: products.isEmpty ? const Center(child: Text('لا توجد منتجات في هذه الفئة')) : GridView.builder(padding: const EdgeInsets.all(12), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: products.length, itemBuilder: (context, i) {
        Product p = products[i];
        return Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Container(width: double.infinity, decoration: const BoxDecoration(color: Color(0xFFFFF3E0), borderRadius: BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14))), child: p.imageUrl != null && p.imageUrl!.isNotEmpty ? ClipRRect(borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)), child: Image.network(p.imageUrl!, fit: BoxFit.cover, width: double.infinity, errorBuilder: (, _, _) => Icon(p.icon, size: 50, color: Colors.orange))) : p.imagePath != null ? ClipRRect(borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)), child: Image.file(File(p.imagePath!), fit: BoxFit.cover, width: double.infinity, errorBuilder: (, _, _) => Icon(p.icon, size: 50, color: Colors.orange))) : Icon(p.icon, size: 50, color: Colors.orange))),
          Padding(padding: const EdgeInsets.all(8, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis), Text(p.desc, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 12)), const SizedBox(height: 4), Row(children: [Text('${p.price} ج', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)), if (p.isOffer) Text(' ${p.oldPrice} ج', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12))]), const SizedBox(height: 6), Row(children: [Expanded(child: ElevatedButton(onPressed: () => onAddToCart(p.name, p.price), style: ElevatedButton.styleFrom(padding: EdgeInsets.zero), child: const Text('اضف'))), const SizedBox(width: 4), Expanded(child: ElevatedButton(onPressed: () => onBuyNow(p), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: EdgeInsets.zero), child: const Text('اشتري الان')))]),
        ]));
      })),
    ]);
  }
}

// ================= CART + PAYMENT =================
class CartPage extends StatefulWidget {
  final List<OrderItem> cart; final Function(int) onRemove; final Function(int) onInc; final Function(int) onDec; final Function(String, String, String, String, String?) onCheckout;
  const CartPage({super.key, required this.cart, required this.onRemove, required this.onInc, required this.onDec, required this.onCheckout});
  @override State<CartPage> createState() => _CartPageState();
}
class _CartPageState extends State<CartPage> {
  TextEditingController nameC = TextEditingController(); TextEditingController phoneC = TextEditingController(); TextEditingController addressC = TextEditingController();
  String pay = 'الدفع عند الاستلام'; String? proofPath;
  Future<void> pickProof() async { final XFile? f = await ImagePicker().pickImage(source: ImageSource.gallery); if (f != null) setState(() => proofPath = f.path); }
  @override Widget build(BuildContext context) {
    double total = widget.cart.fold(0, (s, e) => s + e.price * e.qty);
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('سلة الطلبات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      if (widget.cart.isEmpty) const Text('السلة فارغة، اختار من المتجر'),
      ...widget.cart.asMap().entries.map((e) => Card(child: ListTile(title: Text(e.value.name), subtitle: Text('${e.value.price} ج'), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.remove), onPressed: () => widget.onDec(e.key)), Text('${e.value.qty}'), IconButton(icon: const Icon(Icons.add), onPressed: () => widget.onInc(e.key)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => widget.onRemove(e.key))])))).toList(),
      const SizedBox(height: 12),
      Text('الاجمالي: $total ج', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      const Text('بيانات العميل', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      const SizedBox(height:8),
      TextField(controller: nameC, decoration: const InputDecoration(labelText: 'الاسم بالكامل', border: OutlineInputBorder())),
      const SizedBox(height: 8),
      TextField(controller: phoneC, decoration: const InputDecoration(labelText: 'رقم الموبايل', border: OutlineInputBorder()), keyboardType: TextInputType.phone),
      const SizedBox(height: 8),
      TextField(controller: addressC, decoration: const InputDecoration(labelText: 'العنوان بالتفصيل', border: OutlineInputBorder())),
      const SizedBox(height: 16),
      const Text('طريقة الدفع', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      RadioListTile(value: 'فودافون كاش', groupValue: pay, onChanged: (v) => setState(() => pay = v.toString()), title: const Text('فودافون كاش')),
      RadioListTile(value: 'انستا باي', groupValue: pay, onChanged: (v) => setState(() => pay = v.toString()), title: const Text('انستا باي')),
      RadioListTile(value: 'الدفع عند الاستلام', groupValue: pay, onChanged: (v) => setState(() => pay = v.toString()), title: const Text('الدفع عند الاستلام')),
      if (pay == 'فودافون كاش') Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('حول على رقم فودافون كاش:', style: TextStyle(fontWeight: FontWeight.bold)), Text(vodafoneNumber, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)), const SizedBox(height: 4), const Text('بعد التحويل، ارفع سكرين شوت التحويل هنا'), const SizedBox(height: 8, ElevatedButton(onPressed: pickProof, child: Text(proofPath == null ? 'ارفع سكرين شوت التحويل' : 'تم رفع السكرين - اضغط لتغييره')), if (proofPath != null) Padding(padding: const EdgeInsets.only(top: 8, child: Image.file(File(proofPath!), height: 120)) ])),
      if (pay == 'انستا باي') Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('حول على رقم انستا باي:', style: TextStyle(fontWeight: FontWeight.bold)), Text(instapayNumber, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple)), const SizedBox(height: 4), const Text('بعد التحويل، ارفع سكرين شوت التحويل هنا'), const SizedBox(height: 8, ElevatedButton(onPressed: pickProof, child: Text(proofPath == null ? 'ارفع سكرين شوت التحويل' : 'تم رفع السكرين - اضغط لتغييره')), if (proofPath != null) Padding(padding: const EdgeInsets.only(top: 8, child: Image.file(File(proofPath!), height: 120)) ])),
      const SizedBox(height: 16),
      SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.all(14)), onPressed: () {
        if (nameC.text.isEmpty || phoneC.text.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اكتب الاسم والموبايل الاول'))); return; }
        if ((pay == 'فودافون كاش' || pay == 'انستا باي') && proofPath == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ارفع سكرين شوت التحويل الاول'))); return; }
        widget.onCheckout(nameC.text, phoneC.text, addressC.text, pay, proofPath);
      }, child: const Text('تأكيد الطلب'))),
      const SizedBox(height: 20),
    ]));
  }
}

// ================= ADMIN =================
class AdminPage extends StatefulWidget {
  final List<Product> products; final List<AppOrder> orders; final List<MaintenanceRequest> maintenanceRequests; final Function(Product) onAddProduct; final Function(int) onDeleteProduct;
  const AdminPage({super.key, required this.products, required this.orders, required this.maintenanceRequests, required this.onAddProduct, required this.onDeleteProduct});
  @override State<AdminPage> createState() => _AdminPageState();
}
class _AdminPageState extends State<AdminPage> with SingleTickerProviderStateMixin {
  late TabController tabC;
  TextEditingController nameC = TextEditingController(); TextEditingController descC = TextEditingController(); TextEditingController priceC = TextEditingController(); TextEditingController oldC = TextEditingController(); TextEditingController linkC = TextEditingController();
  String cat = 'شواحن'; String? pickedPath;
  @override void initState() { super.initState(); tabC = TabController(length: 4, vsync: this); }
  Future<void> pickFromPhone() async { final XFile? f = await ImagePicker().pickImage(source: ImageSource.gallery); if (f != null) setState(() { pickedPath = f.path; linkC.clear(); }); }
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('لوحة الادمن - عدي فون'), backgroundColor: Colors.black, foregroundColor: Colors.white, bottom: TabBar(controller: tabC, isScrollable: true, tabs: const [Tab(text: 'اضافة منتج'), Tab(text: 'المنتجات'), Tab(text: 'الطلبات'), Tab(text: 'طلبات الصيانة')])),
      body: TabBarView(controller: tabC, children: [
        SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
          const Text('انزل منتج جديد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(controller: nameC, decoration: const InputDecoration(labelText: 'اسم المنتج', border: OutlineInputBorder())),
          const SizedBox(height: 8),
          TextField(controller: descC, decoration: const InputDecoration(labelText: 'المواصفات / الوصف', border: OutlineInputBorder()), maxLines: 2),
          const SizedBox(height: 8),
          Row(children: [Expanded(child: TextField(controller: priceC, decoration: const InputDecoration(labelText: 'السعر', border: OutlineInputBorder()), keyboardType: TextInputType.number)), const SizedBox(width: 8, Expanded(child: TextField(controller: oldC, decoration: const InputDecoration(labelText: 'السعر القديم (اختياري)', border: OutlineInputBorder()), keyboardType: TextInputType.number))]),
          const SizedBox(height: 8),
          DropdownButtonFormField(value: cat, items: ['شواحن', 'كابلات', 'اكسسوارات', 'سماعات'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => cat = v.toString()), decoration: const InputDecoration(labelText: 'الفئة', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          const Text('صورة المنتج - اختار طريقة واحدة:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [Expanded(child: ElevatedButton(onPressed: pickFromPhone, child: const Text('صورة من التليفون'))), const SizedBox(width: 8, Expanded(child: ElevatedButton(onPressed: () { if (linkC.text.isNotEmpty) setState(() => pickedPath = null); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), child: const Text('استخدم اللينك')))]),
          const SizedBox(height: 8),
          if (pickedPath != null) ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(pickedPath!), height: 140)),
          TextField(controller: linkC, decoration: const InputDecoration(labelText: 'او الصق لينك الصورة هنا', border: OutlineInputBorder(), hintText: 'https://...')),
          if (linkC.text.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8, child: Image.network(linkC.text, height: 140, errorBuilder: (, _, _) => const Text('اللينك مش شغال'))),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.all(14)), onPressed: () {
            if (nameC.text.isEmpty || priceC.text.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اكتب الاسم والسعر'))); return; }
            IconData ic = cat == 'شواحن' ? Icons.charging_station : cat == 'كابلات' ? Icons.cable : cat == 'سماعات' ? Icons.headphones : Icons.phone_android;
            widget.onAddProduct(Product(name: nameC.text, desc: descC.text, price: double.tryParse(priceC.text) ?? 0, oldPrice: double.tryParse(oldC.text) ?? 0, isOffer: oldC.text.isNotEmpty, icon: ic, category: cat, imagePath: pickedPath, imageUrl: linkC.text.isEmpty ? null : linkC.text));
            nameC.clear(); descC.clear(); priceC.clear(); oldC.clear(); linkC.clear(); setState(() => pickedPath = null);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ المنتج وهيظهر للعملاء')));
          }, child: const Text('حفظ المنتج'))),
        ])),
        ListView.builder(itemCount: widget.products.length, itemBuilder: (c, i) { Product p = widget.products[i]; return Card(child: ListTile(title: Text(p.name), subtitle: Text('${p.price} ج - ${p.category}'), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => widget.onDeleteProduct(i)))); }),
        widget.orders.isEmpty ? const Center(child: Text('لسه مفيش طلبات')) : ListView.builder(itemCount: widget.orders.length, itemBuilder: (c, i) { AppOrder o = widget.orders[i]; return Card(margin: const EdgeInsets.all(8, child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${o.customerName} - ${o.phone}', style: const TextStyle(fontWeight: FontWeight.bold)), Text('العنوان: ${o.address}'), Text('الدفع: ${o.paymentMethod} - الاجمالي: ${o.total} ج'), Text('المنتجات: ${o.items.map((e) => '${e.name} x${e.qty}').join(' , ')}'), if (o.proofPath != null) Padding(padding: const EdgeInsets.only(top: 8, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('سكرين شوت التحويل:'), const SizedBox(height: 4), Image.file(File(o.proofPath!), height: 180)])) ]))); }),
        widget.maintenanceRequests.isEmpty ? const Center(child: Text('لسه مفيش طلبات صيانة')) : ListView.builder(itemCount: widget.maintenanceRequests.length, itemBuilder: (c, i) { MaintenanceRequest r = widget.maintenanceRequests[i]; return Card(margin: const EdgeInsets.all(8, color: Colors.blue.shade50, child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.build, color: Colors.blue), const SizedBox(width: 6), Expanded(child: Text('${r.customerName} - ${r.phone}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))]), const SizedBox(height: 6), Text('نوع العطل: ${r.faultType}'), Text('المشكلة: ${r.problem}'), Text('العنوان: ${r.address}'), Text('التاريخ: ${r.date}'), const SizedBox(height: 8, Container(padding: const EdgeInsets.all(8, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: const Text('كلم العميل وقوله: هبعتلك مندوب ياخد الجهاز نصلحه ونرجعه تاني', style: TextStyle(color: Colors.blue))) ]))); }),
      ]));
  }
}
