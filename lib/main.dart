import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const OdayApp());
}

const String vodafoneNumber = '01015519180';
const String instapayNumber = '01069068091';
const Color navyBg = Color(0xFF0A1931);
const Color navyCard = Color(0xFF13294B);
const Color navyDark = Color(0xFF071224);
const Color accentOrange = Color(0xFFFF7A00);
const Color accentBlue = Color(0xFF38BDF6);
const Color accentGreen = Color(0xFF22C55E);

class Product {
  String name; String desc; double price; double oldPrice; String category; bool isOffer; bool isFav; String? imagePath; String iconName;
  Product({required this.name, required this.desc, required this.price, this.oldPrice = 0, required this.category, this.isOffer = false, this.isFav = false, this.imagePath, this.iconName = 'phone'});
  Map<String, dynamic> toJson() => {'name': name, 'desc': desc, 'price': price, 'oldPrice': oldPrice, 'category': category, 'isOffer': isOffer, 'isFav': isFav, 'imagePath': imagePath, 'iconName': iconName};
  factory Product.fromJson(Map<String, dynamic> j) => Product(name: j['name'], desc: j['desc'], price: (j['price'] as num).toDouble(), oldPrice: (j['oldPrice'] as num?)?.toDouble() ?? 0, category: j['category'], isOffer: j['isOffer'] ?? false, isFav: j['isFav'] ?? false, imagePath: j['imagePath'], iconName: j['iconName'] ?? 'phone');
}

IconData getProductIcon(String name) {
  if (name == 'charge') return Icons.charging_station;
  if (name == 'head') return Icons.headphones;
  if (name == 'cable') return Icons.cable;
  return Icons.phone_android;
}

class OrderItem {
  String name; int qty; double price;
  OrderItem({required this.name, required this.qty, required this.price});
  Map<String, dynamic> toJson() => {'name': name, 'qty': qty, 'price': price};
  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(name: j['name'], qty: j['qty'], price: (j['price'] as num).toDouble());
}

class AppOrder {
  String id; String customerName; String phone; String address; String paymentMethod; String status; List<OrderItem> items; double total; String? proofPath; String date;
  AppOrder({required this.id, required this.customerName, required this.phone, required this.address, required this.paymentMethod, required this.status, required this.items, required this.total, this.proofPath, required this.date});
  Map<String, dynamic> toJson() => {'id': id, 'customerName': customerName, 'phone': phone, 'address': address, 'paymentMethod': paymentMethod, 'status': status, 'items': items.map((e) => e.toJson()).toList(), 'total': total, 'proofPath': proofPath, 'date': date};
  factory AppOrder.fromJson(Map<String, dynamic> j) => AppOrder(id: j['id'], customerName: j['customerName'], phone: j['phone'], address: j['address'], paymentMethod: j['paymentMethod'], status: j['status'], items: (j['items'] as List).map((e) => OrderItem.fromJson(e)).toList(), total: (j['total'] as num).toDouble(), proofPath: j['proofPath'], date: j['date']);
}

class RepairRequest {
  String id; String customerName; String phone; String address; String phoneType; String problem; String kind; String date; String status;
  RepairRequest({required this.id, required this.customerName, required this.phone, required this.address, required this.phoneType, required this.problem, required this.kind, required this.date, this.status = 'جديد'});
  Map<String, dynamic> toJson() => {'id': id, 'customerName': customerName, 'phone': phone, 'address': address, 'phoneType': phoneType, 'problem': problem, 'kind': kind, 'date': date, 'status': status};
  factory RepairRequest.fromJson(Map<String, dynamic> j) => RepairRequest(id: j['id'], customerName: j['customerName'], phone: j['phone'], address: j['address'], phoneType: j['phoneType'] ?? '', problem: j['problem'], kind: j['kind'] ?? 'مندوب صيانة موبايل', date: j['date'], status: j['status'] ?? 'جديد');
}

class OdayApp extends StatefulWidget {
  const OdayApp({super.key});
  @override
  State<OdayApp> createState() => _OdayAppState();
}

class _OdayAppState extends State<OdayApp> {
  bool showStart = true;
  int currentIndex = 0;
  int adminTapCount = 0;
  int lastAdminTapTime = 0;
  String searchText = '';
  String storeCategory = 'الكل';
  List<OrderItem> cart = [];
  List<AppOrder> orders = [];
  List<RepairRequest> repairs = [];
  List<Product> products = [
    Product(name: 'جراب موبايل', desc: 'جراب حماية خامة نضيفة', price: 150, oldPrice: 200, category: 'جرابات', isOffer: true, iconName: 'phone'),
    Product(name: 'شاحن سريع', desc: 'شاحن سريع اصلي', price: 350, oldPrice: 450, category: 'شواحن', isOffer: true, iconName: 'charge'),
    Product(name: 'سماعة بلوتوث', desc: 'سماعة صوت نقي', price: 600, category: 'سماعات', iconName: 'head'),
    Product(name: 'سكرينة حماية', desc: 'سكرينة ضد الكسر', price: 100, category: 'سكرينات', iconName: 'phone'),
    Product(name: 'وصلة شاحن', desc: 'وصلة شحن سريع', price: 120, category: 'شواحن', iconName: 'cable'),
    Product(name: 'حامل موبايل', desc: 'حامل للعربية والمكتب', price: 200, category: 'اكسسوارات', iconName: 'phone'),
  ];
  List<String> storeCategories = ['الكل', 'جرابات', 'شواحن', 'سماعات', 'سكرينات', 'اكسسوارات'];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final pStr = prefs.getString('products');
      if (pStr != null) {
        products = (jsonDecode(pStr) as List).map((e) => Product.fromJson(e)).toList();
      }
      final oStr = prefs.getString('orders');
      if (oStr != null) {
        orders = (jsonDecode(oStr) as List).map((e) => AppOrder.fromJson(e)).toList();
      }
      final rStr = prefs.getString('repairs');
      if (rStr != null) {
        repairs = (jsonDecode(rStr) as List).map((e) => RepairRequest.fromJson(e)).toList();
      }
      final cStr = prefs.getString('cart');
      if (cStr != null) {
        cart = (jsonDecode(cStr) as List).map((e) => OrderItem.fromJson(e)).toList();
      }
    });
  }

  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('products', jsonEncode(products.map((e) => e.toJson()).toList()));
    await prefs.setString('orders', jsonEncode(orders.map((e) => e.toJson()).toList()));
    await prefs.setString('repairs', jsonEncode(repairs.map((e) => e.toJson()).toList()));
    await prefs.setString('cart', jsonEncode(cart.map((e) => e.toJson()).toList()));
  }

  Future<void> _saveOrderToFirebase(AppOrder o) async {
    try {
      await FirebaseFirestore.instance.collection('orders').add(o.toJson());
    } catch (e) {
      debugPrint('Firebase order error: $e');
    }
  }

  Future<void> _saveRepairToFirebase(RepairRequest r) async {
    try {
      await FirebaseFirestore.instance.collection('repairs').add(r.toJson());
    } catch (e) {
      debugPrint('Firebase repair error: $e');
    }
  }

  double get cartTotal => cart.fold(0, (sum, e) => sum + e.price * e.qty);
  List<Product> get filteredStore {
    return products.where((p) {
      final matchSearch = searchText.isEmpty || p.name.contains(searchText) || p.desc.contains(searchText);
      final matchCat = storeCategory == 'الكل' || p.category == storeCategory;
      return matchSearch && matchCat;
    }).toList();
  }
  List<Product> get offers => products.where((p) => p.isOffer).toList();

  void _addToCart(Product p) {
    final idx = cart.indexWhere((e) => e.name == p.name);
    setState(() {
      if (idx >= 0) {
        cart[idx].qty = cart[idx].qty + 1;
      } else {
        cart.add(OrderItem(name: p.name, qty: 1, price: p.price));
      }
    });
    _saveAll();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم اضافته الى السلة - ${p.name}'), backgroundColor: accentGreen, duration: const Duration(seconds: 1)),
    );
  }

  void _onTitleTap() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastAdminTapTime > 3000) {
      adminTapCount = 0;
    }
    lastAdminTapTime = now;
    adminTapCount = adminTapCount + 1;
    if (adminTapCount >= 3) {
      adminTapCount = 0;
      _askAdminPassword();
    }
  }

  void _askAdminPassword() {
    final passC = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: navyCard,
          title: const Text('دخول الادمن', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: passC,
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'اكتب الباسورد', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('الغاء', style: TextStyle(color: Colors.white))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: accentOrange),
              onPressed: () {
                if (passC.text.trim() == '123+') {
                  Navigator.pop(ctx);
                  _openAdmin();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الباسورد غلط')));
                }
              },
              child: const Text('دخول', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (showStart) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: navyBg,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onLongPress: _askAdminPassword,
                    onTap: () => setState(() => showStart = false),
                    child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: accentOrange, borderRadius: BorderRadius.circular(30)), child: const Icon(Icons.phone_android, size: 70, color: Colors.white)),
                  ),
                  const SizedBox(height: 20),
                  const Text('عدي فون', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text('مرحبا بكم في عدي فون', style: TextStyle(color: Colors.white, fontSize: 20)),
                  const SizedBox(height: 10),
                  const Text('صيانة موبايلات ومتجر اكسسوارات', style: TextStyle(color: Colors.white70, fontSize: 16), textAlign: TextAlign.center),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: accentOrange, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      onPressed: () => setState(() => showStart = false),
                      child: const Text('ابدأ', style: TextStyle(fontSize: 20, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: navyBg,
        appBarTheme: const AppBarTheme(backgroundColor: navyDark, foregroundColor: Colors.white),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: navyDark, selectedItemColor: accentOrange, unselectedItemColor: Colors.grey),
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white), bodyLarge: TextStyle(color: Colors.white), titleMedium: TextStyle(color: Colors.white)),
        inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: navyCard, labelStyle: const TextStyle(color: Colors.white70), hintStyle: const TextStyle(color: Colors.white54), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white24))),
      ),
      home: Scaffold(
        backgroundColor: navyBg,
        appBar: AppBar(
          backgroundColor: navyDark,
          title: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _onTitleTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: const Text('عدي فون', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.settings, color: Colors.white), tooltip: 'الادمن', onPressed: _askAdminPassword),
            Stack(
              children: [
                IconButton(icon: const Icon(Icons.shopping_cart, color: Colors.white), onPressed: () => setState(() => currentIndex = 2)),
                if (cart.isNotEmpty)
                  Positioned(right: 6, top: 6, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: accentOrange, shape: BoxShape.circle), child: Text('${cart.length}', style: const TextStyle(color: Colors.white, fontSize: 12)))),
              ],
            ),
          ],
        ),
        body: _buildBody(),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: navyDark,
          currentIndex: currentIndex,
          selectedItemColor: accentOrange,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: (i) => setState(() => currentIndex = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.store), label: 'المتجر'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'السلة'),
            BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'طلباتي'),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (currentIndex == 1) return _buildStore();
    if (currentIndex == 2) return _buildCart();
    if (currentIndex == 3) return _buildMyOrders();
    return _buildHome();
  }

  Widget _buildHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('مرحبا بكم في عدي فون', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          TextField(onChanged: (v) => setState(() => searchText = v), style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'دور على جراب، شاحن، سماعة، سكرينة...', prefixIcon: const Icon(Icons.search, color: Colors.white70), filled: true, fillColor: navyCard, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setState(() => currentIndex = 1),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: navyCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: accentOrange)),
                child: Row(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: accentOrange, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.store, color: Colors.white, size: 30)), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('المتجر', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)), Text('جرابات وشواحن وسماعات وسكرينات', style: TextStyle(color: Colors.white70))])), const Icon(Icons.arrow_forward_ios, size: 17, color: Colors.white70)]),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1E3A5F), accentOrange]), borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.delivery_dining, color: Colors.white, size: 30)), const SizedBox(width: 10), const Expanded(child: Text('اطلب مندوب لصيانة تليفونك', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)))]),
                const SizedBox(height: 10),
                const Text('هنبعتلك مندوب ياخد التليفون من عندك، نصلحه، ونرجعهولك تاني لحد البيت', style: TextStyle(color: Colors.white, fontSize: 15)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    onPressed: () => _openRepairForm('مندوب صيانة موبايل'),
                    child: const Text('اطلب المندوب دلوقتي - دوس هنا', style: TextStyle(fontWeight: FontWeight.bold, color: accentOrange, fontSize: 17)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('عروض المتجر', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),
          if (offers.isEmpty) const Text('مفيش عروض دلوقتي', style: TextStyle(color: Colors.white70)),
          ...offers.map((p) => _productCard(p)).toList(),
          const SizedBox(height: 20),
          const Text('خدمات أخرى', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),
          Row(children: [Expanded(child: _otherServiceCard('نجارة', Icons.handyman, 'نجارة')), const SizedBox(width: 12), Expanded(child: _otherServiceCard('كهربائي', Icons.electrical_services, 'كهربائي'))]),
          const SizedBox(height: 10),
          const Text('مفيش اي خدمات تانية غير دول', style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), padding: const EdgeInsets.symmetric(vertical: 12)),
              onPressed: _askAdminPassword,
              icon: const Icon(Icons.settings, color: Colors.white70),
              label: const Text('دخول الادمن', style: TextStyle(color: Colors.white70)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _otherServiceCard(String title, IconData icon, String kind) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: navyCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white24)),
      child: Column(children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: accentBlue.withOpacity(0.2), shape: BoxShape.circle), child: Icon(icon, size: 32, color: accentBlue)),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: accentOrange, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () => _openRepairForm(kind),
            child: const Text('اطلب دلوقتي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }

  Widget _buildStore() {
    return Column(
      children: [
        Padding(padding: const EdgeInsets.all(16), child: TextField(onChanged: (v) => setState(() => searchText = v), style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'دور في المتجر...', prefixIcon: const Icon(Icons.search, color: Colors.white70), filled: true, fillColor: navyCard, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)))),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: storeCategories.map((c) {
              final sel = c == storeCategory;
              return Padding(padding: const EdgeInsets.only(left: 10), child: ChoiceChip(label: Text(c), selected: sel, selectedColor: accentOrange, backgroundColor: navyCard, labelStyle: TextStyle(color: sel ? Colors.white : Colors.white70), onSelected: (_) => setState(() => storeCategory = c)));
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(child: GridView.builder(padding: const EdgeInsets.all(16), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.72), itemCount: filteredStore.length, itemBuilder: (ctx, i) => _productCard(filteredStore[i]))),
      ],
    );
  }

  Widget _productCard(Product p) {
    return Card(
      color: navyCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white12, borderRadius: const BorderRadius.vertical(top: Radius.circular(14))),
            child: p.imagePath != null
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    child: p.imagePath!.startsWith('http')
                        ? Image.network(p.imagePath!, fit: BoxFit.cover)
                        : Image.file(File(p.imagePath!), fit: BoxFit.cover),
                  )
                : Icon(getProductIcon(p.iconName), size: 50, color: accentBlue),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(p.desc, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Row(children: [Text('${p.price} ج', style: const TextStyle(fontWeight: FontWeight.bold, color: accentOrange)), if (p.isOffer) Text(' ${p.oldPrice} ج', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.white54, fontSize: 12))]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(children: [Expanded(child: SizedBox(height: 44, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: accentOrange, padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: () => _addToCart(p), child: const Text('اضافة +', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold))))), IconButton(onPressed: () { setState(() { p.isFav = !p.isFav; _saveAll(); }); }, icon: Icon(p.isFav ? Icons.favorite : Icons.favorite_border, color: Colors.red))]),
          ),
        ],
      ),
    );
  }

  Widget _buildCart() {
    if (cart.isEmpty) {
      return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.shopping_cart_outlined, size: 70, color: Colors.white54), SizedBox(height: 10), Text('السلة فاضية', style: TextStyle(color: Colors.white))]));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ...cart.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return Card(color: navyCard, child: ListTile(title: Text(item.name, style: const TextStyle(color: Colors.white)), subtitle: Text('${item.price} ج', style: const TextStyle(color: Colors.white70)), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.remove, color: Colors.white), onPressed: () { setState(() { if (item.qty > 1) { item.qty = item.qty - 1; } else { cart.removeAt(idx); } _saveAll(); }); }), Text('${item.qty}', style: const TextStyle(color: Colors.white)), IconButton(icon: const Icon(Icons.add, color: Colors.white), onPressed: () { setState(() { item.qty = item.qty + 1; _saveAll(); }); }), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () { setState(() { cart.removeAt(idx); _saveAll(); }); })])));
          }).toList(),
          const SizedBox(height: 10),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: navyCard, borderRadius: BorderRadius.circular(14)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('الاجمالي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)), Text('$cartTotal ج', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: accentOrange))])),
          const SizedBox(height: 16),
          _checkoutForm(),
        ],
      ),
    );
  }

  Widget _checkoutForm() {
    final nameC = TextEditingController();
    final phoneC = TextEditingController();
    final addrC = TextEditingController();
    String method = 'كاش عند الاستلام';
    String? proofPath;
    return StatefulBuilder(
      builder: (ctx, setLocal) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: navyCard, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('بيانات التوصيل والدفع', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              TextField(controller: nameC, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'اسم العميل', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: phoneC, keyboardType: TextInputType.phone, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'رقم التليفون', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: addrC, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'العنوان', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              const Text('طريقة الدفع', style: TextStyle(color: Colors.white)),
              RadioListTile(value: 'كاش عند الاستلام', groupValue: method, activeColor: accentOrange, title: const Text('كاش عند الاستلام', style: TextStyle(color: Colors.white)), onChanged: (v) => setLocal(() => method = v.toString())),
              RadioListTile(value: 'فودافون كاش', groupValue: method, activeColor: accentOrange, title: const Text('فودافون كاش', style: TextStyle(color: Colors.white)), onChanged: (v) => setLocal(() => method = v.toString())),
              RadioListTile(value: 'انستا باي', groupValue: method, activeColor: accentOrange, title: const Text('انستا باي', style: TextStyle(color: Colors.white)), onChanged: (v) => setLocal(() => method = v.toString())),
              if (method != 'كاش عند الاستلام') ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: accentOrange.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                  child: Column(children: [Row(children: [Expanded(child: Text('حول على: ${method == 'فودافون كاش' ? vodafoneNumber : instapayNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white))), IconButton(icon: const Icon(Icons.copy, color: Colors.white), onPressed: () { Clipboard.setData(ClipboardData(text: method == 'فودافون كاش' ? vodafoneNumber : instapayNumber)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ الرقم'))); })]), const SizedBox(height: 10), ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: accentOrange), onPressed: () async { final picker = ImagePicker(); final x = await picker.pickImage(source: ImageSource.gallery); if (x != null) { setLocal(() => proofPath = x.path); } }, icon: const Icon(Icons.upload, color: Colors.white), label: Text(proofPath == null ? 'ارفع صورة التحويل' : 'تم رفع الصورة', style: const TextStyle(color: Colors.white))), if (proofPath != null) Padding(padding: const EdgeInsets.only(top: 10), child: Image.file(File(proofPath!), height: 120))]),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: accentOrange, padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () async {
                    if (nameC.text.isEmpty || phoneC.text.isEmpty || addrC.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('كمل بياناتك الاول')));
                      return;
                    }
                    final newOrder = AppOrder(id: DateTime.now().millisecondsSinceEpoch.toString(), customerName: nameC.text, phone: phoneC.text, address: addrC.text, paymentMethod: method, status: 'جديد', items: List.from(cart), total: cartTotal, proofPath: proofPath, date: DateTime.now().toString().substring(0, 10));
                    setState(() {
                      orders.add(newOrder);
                      cart.clear();
                      _saveAll();
                      currentIndex = 3;
                    });
                    await _saveOrderToFirebase(newOrder);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم استلام طلبك وهنكلمك')));
                  },
                  child: const Text('تأكيد الطلب', style: TextStyle(color: Colors.white, fontSize: 17)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyOrders() {
    if (orders.isEmpty && repairs.isEmpty) {
      return const Center(child: Text('لسه مفيش طلبات', style: TextStyle(color: Colors.white)));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('طلبات المتجر', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 10),
        ...orders.map((o) => Card(color: navyCard, child: ListTile(title: Text('طلب رقم ${o.id.substring(o.id.length - 4)}', style: const TextStyle(color: Colors.white)), subtitle: Text('${o.customerName}\n${o.total} ج - ${o.status} - ${o.date}\n${o.items.map((e) => '${e.name} x${e.qty}').join(', ')}', style: const TextStyle(color: Colors.white70)), trailing: Text(o.paymentMethod, style: const TextStyle(color: Colors.white))))).toList(),
        const SizedBox(height: 20),
        const Text('طلبات المندوب والخدمات', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 10),
        ...repairs.map((r) => Card(color: navyCard, child: ListTile(title: Text('${r.kind} - ${r.customerName}', style: const TextStyle(color: Colors.white)), subtitle: Text('${r.problem} - ${r.status}', style: const TextStyle(color: Colors.white70)), trailing: Text(r.date, style: const TextStyle(color: Colors.white))))).toList(),
      ],
    );
  }

  void _openRepairForm(String kind) {
    final nameC = TextEditingController();
    final phoneC = TextEditingController();
    final addrC = TextEditingController();
    final typeC = TextEditingController();
    final probC = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: navyCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kind == 'مندوب صيانة موبايل' ? 'اطلب مندوب لصيانة تليفونك' : 'طلب $kind', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 6),
                if (kind == 'مندوب صيانة موبايل') const Text('هنبعتلك مندوب ياخد التليفون من عندك، نصلحه، ونرجعهولك تاني لحد البيت', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                TextField(controller: nameC, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'اسم العميل', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: phoneC, keyboardType: TextInputType.phone, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'رقم التليفون', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: addrC, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'العنوان', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                if (kind == 'مندوب صيانة موبايل') ...[TextField(controller: typeC, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'نوع التليفون - مثال: سامسونج، ايفون', border: OutlineInputBorder())), const SizedBox(height: 10)],
                TextField(controller: probC, maxLines: 3, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: kind == 'مندوب صيانة موبايل' ? 'ايه المشكلة في التليفون؟' : 'ايه الشغل المطلوب؟', border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: accentOrange, padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: () async {
                      if (nameC.text.isEmpty || phoneC.text.isEmpty || addrC.text.isEmpty || probC.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('كمل بياناتك الاول')));
                        return;
                      }
                      final newRepair = RepairRequest(id: DateTime.now().millisecondsSinceEpoch.toString(), customerName: nameC.text, phone: phoneC.text, address: addrC.text, phoneType: typeC.text, problem: probC.text, kind: kind, date: DateTime.now().toString().substring(0, 10));
                      setState(() {
                        repairs.add(newRepair);
                        _saveAll();
                      });
                      await _saveRepairToFirebase(newRepair);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم استلام طلبك وهنكلمك نحدد معاد المندوب')));
                    },
                    child: const Text('ارسال الطلب', style: TextStyle(color: Colors.white, fontSize: 17)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openAdmin() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: navyCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setLocal) {
            return DefaultTabController(
              length: 3,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.9,
                child: Column(
                  children: [
                    const TabBar(labelColor: Colors.white, tabs: [Tab(text: 'طلبات المتجر'), Tab(text: 'طلبات المندوب'), Tab(text: 'المنتجات')]),
                    Expanded(
                      child: TabBarView(
                        children: [
                          ListView(
                            padding: const EdgeInsets.all(12),
                            children: orders.map((o) => Card(color: navyBg, child: ListTile(title: Text('${o.customerName} - ${o.total} ج', style: const TextStyle(color: Colors.white)), subtitle: Text('${o.phone}\n${o.address}\n${o.paymentMethod}\n${o.items.map((e) => '${e.name} x${e.qty}').join(', ')}', style: const TextStyle(color: Colors.white70)), trailing: Row(mainAxisSize: MainAxisSize.min, children: [DropdownButton<String>(dropdownColor: navyCard, value: o.status, style: const TextStyle(color: Colors.white), items: ['جديد', 'قيد التنفيذ', 'تم'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) { setState(() { o.status = v!; _saveAll(); }); setLocal(() {}); }), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () { setState(() { orders.remove(o); _saveAll(); }); setLocal(() {}); })])))).toList(),
                          ),
                          ListView(
                            padding: const EdgeInsets.all(12),
                            children: repairs.map((r) => Card(color: navyBg, child: ListTile(title: Text('${r.kind} - ${r.customerName}', style: const TextStyle(color: Colors.white)), subtitle: Text('${r.phone}\n${r.address}\n${r.phoneType}\n${r.problem}', style: const TextStyle(color: Colors.white70)), trailing: Row(mainAxisSize: MainAxisSize.min, children: [DropdownButton<String>(dropdownColor: navyCard, value: r.status, style: const TextStyle(color: Colors.white), items: ['جديد', 'تم استلام التليفون', 'جاري الصيانة', 'تم التسليم', 'تم التواصل', 'تم التنفيذ'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) { setState(() { r.status = v!; _saveAll(); }); setLocal(() {}); }), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () { setState(() { repairs.remove(r); _saveAll(); }); setLocal(() {}); })])))).toList(),
                          ),
                          ListView(
                            padding: const EdgeInsets.all(12),
                            children: [
                              ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: accentOrange), onPressed: () => _addProductDialog(setLocal, null), child: const Text('اضافة منتج جديد', style: TextStyle(color: Colors.white))),
                              const SizedBox(height: 10),
                              ...products.map((p) => Card(color: navyBg, child: ListTile(title: Text(p.name, style: const TextStyle(color: Colors.white)), subtitle: Text('${p.price} ج - ${p.category}', style: const TextStyle(color: Colors.white70)), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, color: accentBlue), onPressed: () => _addProductDialog(setLocal, p)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () { setState(() { products.remove(p); _saveAll(); }); setLocal(() {}); })])))).toList(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _addProductDialog(Function setLocalAdmin, Product? editP) {
    final nameC = TextEditingController(text: editP?.name ?? '');
    final descC = TextEditingController(text: editP?.desc ?? '');
    final priceC = TextEditingController(text: editP != null ? '${editP.price}' : '');
    final oldC = TextEditingController(text: editP != null ? '${editP.oldPrice}' : '');
    String cat = editP?.category ?? 'جرابات';
    bool isOffer = editP?.isOffer ?? false;
    String? imgPath = editP?.imagePath;
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setD) {
            return AlertDialog(
              backgroundColor: navyCard,
              title: Text(editP == null ? 'اضافة منتج جديد' : 'تعديل منتج', style: const TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(controller: nameC, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'اسم المنتج')),
                    TextField(controller: descC, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'الوصف')),
                    TextField(controller: priceC, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'السعر')),
                    TextField(controller: oldC, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'السعر القديم لو عليه خصم')),
                    DropdownButton<String>(dropdownColor: navyCard, value: cat, isExpanded: true, style: const TextStyle(color: Colors.white), items: storeCategories.where((e) => e != 'الكل').map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setD(() => cat = v!)),
                    CheckboxListTile(value: isOffer, activeColor: accentOrange, title: const Text('عليه خصم؟', style: TextStyle(color: Colors.white)), onChanged: (v) => setD(() => isOffer = v!)),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: accentOrange),
                      onPressed: () async {
                        final picker = ImagePicker();
                        final x = await picker.pickImage(source: ImageSource.gallery);
                        if (x != null) {
                          final file = File(x.path);
                          final ref = FirebaseStorage.instance.ref().child('products/${DateTime.now().millisecondsSinceEpoch}.jpg');
                          await ref.putFile(file);
                          final url = await ref.getDownloadURL();
                          setD(() => imgPath = url);
                        }
                      },
                      icon: const Icon(Icons.image, color: Colors.white),
                      label: Text(imgPath == null ? 'اختر صورة' : 'تم اختيار الصورة', style: const TextStyle(color: Colors.white)),
                    ),
                    if (imgPath != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: imgPath!.startsWith('http')
                            ? Image.network(imgPath!, height: 120)
                            : Image.file(File(imgPath!), height: 120),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('الغاء', style: TextStyle(color: Colors.white))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: accentGreen),
                  onPressed: () {
                    if (nameC.text.isEmpty || priceC.text.isEmpty) return;
                    setState(() {
                      if (editP == null) {
                        products.add(Product(name: nameC.text, desc: descC.text, price: double.tryParse(priceC.text) ?? 0, oldPrice: double.tryParse(oldC.text) ?? 0, category: cat, isOffer: isOffer, imagePath: imgPath, iconName: 'phone'));
                      } else {
                        editP.name = nameC.text;
                        editP.desc = descC.text;
                        editP.price = double.tryParse(priceC.text) ?? 0;
                        editP.oldPrice = double.tryParse(oldC.text) ?? 0;
                        editP.category = cat;
                        editP.isOffer = isOffer;
                        editP.imagePath = imgPath;
                      }
                      _saveAll();
                    });
                    Navigator.pop(ctx);
                    setLocalAdmin(() {});
                  },
                  child: Text(editP == null ? 'اضافة' : 'حفظ التعديل', style: const TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
