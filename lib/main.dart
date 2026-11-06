import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() { runApp(const OdayApp()); }

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

// ================= APP STATE =================
class OdayApp extends StatefulWidget { const OdayApp({super.key}); @override State<OdayApp> createState() => _OdayAppState(); }
class _OdayAppState extends State<OdayApp> {
  bool showStart = true;
  int currentIndex = 1;
  String searchText = '';
  String selectedCategory = 'الكل';
  List<ServiceItem> services = [
    ServiceItem(name: 'نجار', desc: 'تركيب وتصليح وفك وتركيب اثاث، غرف نوم، مطابخ، ابواب', icon: Icons.chair, price: 150, category: 'نجارة', rating: 4.9),
    ServiceItem(name: 'كهربائي', desc: 'تصليح كهرباء، تركيب اضاءة، برايز، مراوح', icon: Icons.electrical_services, price: 120, category: 'كهرباء', rating: 4.😎,
    ServiceItem(name: 'صيانة موبايل', desc: 'تغيير شاشة، بطارية، سوكت شحن، صيانة شاملة', icon: Icons.phone_android, price: 100, category: 'موبايل', rating: 5.0),
  ];
  List<Product> products = [
    Product(name: 'شاحن سريع 25 وات', desc: 'شاحن اصلي سريع، كابل تايب سي', price: 350, oldPrice: 450, isOffer: true, icon: Icons.charging_station, category: 'شواحن'),
    Product(name: 'جراب موبايل', desc: 'جراب حماية قوي ضد الصدمات', price: 120, icon: Icons.phone_android, category: 'اكسسوارات'),
    Product(name: 'سماعة بلوتوث', desc: 'سماعة صوت نقي وبطارية طويلة', price: 550, oldPrice: 700, isOffer: true, icon: Icons.headphones, category: 'سماعات'),
    Product(name: 'اسكرينة حماية', desc: 'اسكرينة زجاج ضد الكسر', price: 80, icon: Icons.shield, category: 'اكسسوارات'),
    Product(name: 'باور بانك 10000', desc: 'باور بانك سريع الشحن', price: 650, icon: Icons.battery_charging_full, category: 'شواحن'),
    Product(name: 'كابل تايب سي', desc: 'كابل اصلي 1 متر', price: 90, icon: Icons.cable, category: 'شواحن'),
    Product(name: 'حامل موبايل للعربية', desc: 'حامل مغناطيسي قوي', price: 180, icon: Icons.car_crash, category: 'اكسسوارات'),
    Product(name: 'سماعة سلكية', desc: 'سماعة صوت واضح ومايك', price: 150, icon: Icons.headset, category: 'سماعات'),
  ];
  List<AppOrder> orders = [];
  List<OrderItem> cart = [];
  List<String> notifications = [];
  List<String> categories = ['الكل', 'نجارة', 'كهرباء', 'موبايل'];

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      var p = prefs.getString('products'); if (p != null) products = (jsonDecode(p) as List).map((e) => Product.fromJson(e)).toList();
      var o = prefs.getString('orders'); if (o != null) orders = (jsonDecode(o) as List).map((e) => AppOrder.fromJson(e)).toList();
      var c = prefs.getString('cart'); if (c != null) cart = (jsonDecode(c) as List).map((e) => OrderItem.fromJson(e)).toList();
      var n = prefs.getStringList('notifications'); if (n != null) notifications = n;
    });
  }
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('products', jsonEncode(products.map((e) => e.toJson()).toList()));
    await prefs.setString('orders', jsonEncode(orders.map((e) => e.toJson()).toList()));
    await prefs.setString('cart', jsonEncode(cart.map((e) => e.toJson()).toList()));
    await prefs.setStringList('notifications', notifications);
  }

  void addToCart(String name, double price) {
    setState(() {
      var ex = cart.where((e) => e.name == name).toList();
      if (ex.isNotEmpty) { ex.first.qty++; } else { cart.add(OrderItem(name: name, qty: 1, price: price)); }
    });
    _save();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت الاضافة للسلة')));
  }
  void incQty(String name) { setState(() { cart.firstWhere((e) => e.name == name).qty++; }); _save(); }
  void decQty(String name) { setState(() { var it = cart.firstWhere((e) => e.name == name); if (it.qty > 1) { it.qty--; } else { cart.remove(it); } }); _save(); }
  void removeItem(String name) { setState(() { cart.removeWhere((e) => e.name == name); }); _save(); }
  void toggleFavService(int idx) => setState(() => services[idx].isFav = !services[idx].isFav);
  void toggleFavProduct(int idx) { setState(() => products[idx].isFav = !products[idx].isFav); _save(); }

  void updateOrderStatus(String id, String newStatus) {
    setState(() {
      var o = orders.firstWhere((e) => e.id == id);
      o.status = newStatus;
      String msg = newStatus == 'المندوب في الطريق' ? 'المندوب في الطريق لك - طلب #${id.substring(id.length - 4)}' : newStatus == 'تم التوصيل' ? 'تم توصيل طلبك بنجاح' : newStatus == 'تم التجهيز' ? 'تم تجهيز طلبك' : 'حالة طلبك اتغيرت: $newStatus';
      notifications.insert(0, msg);
    });
    _save();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم تحديث الحالة + اشعار وصل للعميل')));
  }

  @override Widget build(BuildContext context) {
    List<ServiceItem> filteredServices = services.where((s) {
      bool matchSearch = searchText.trim().isEmpty || s.name.contains(searchText) || s.desc.contains(searchText) || s.category.contains(searchText);
      bool matchCat = selectedCategory == 'الكل' || s.category == selectedCategory;
      return matchSearch && matchCat;
    }).toList();
    List<Product> filteredProducts = products.where((p) {
      if (searchText.trim().isEmpty) return true;
      return p.name.contains(searchText) || p.desc.contains(searchText) || p.category.contains(searchText);
    }).toList();
    return MaterialApp(
      debugShowCheckedModeBanner: false, title: 'عدي فون',
      theme: ThemeData(primarySwatch: Colors.blue, scaffoldBackgroundColor: const Color(0xFFF6F8FB), useMaterial3: true),
      home: showStart ? StartPage(onStart: () => setState(() { showStart = false; currentIndex = 1; })) : MainScaffold(
        currentIndex: currentIndex, onNav: (i) => setState(() => currentIndex = i),
        services: filteredServices, allServices: services, products: filteredProducts, allProducts: products,
        cart: cart, orders: orders, notifications: notifications, searchText: searchText, selectedCategory: selectedCategory, categories: categories,
        onSearch: (v) => setState(() => searchText = v), onCategory: (c) => setState(() => selectedCategory = c),
        onAddToCart: addToCart, onAddProduct: (p) { setState(() => products.add(p)); _save(); },
        onDeleteProduct: (p) { setState(() => products.remove(p)); _save(); },
        onEditProduct: (oldP, newP) { setState(() { int i = products.indexOf(oldP); if (i != -1) products[i] = newP; }); _save(); },
        onClearCart: () { setState(() => cart.clear()); _save(); },
        onCreateOrder: (o) { setState(() { orders.add(o); cart.clear(); notifications.insert(0, 'تم استلام طلبك #${o.id.substring(o.id.length - 4)}'); }); _save(); },
        onToggleFavService: toggleFavService, onToggleFavProduct: toggleFavProduct,
        onInc: incQty, onDec: decQty, onRemoveItem: removeItem,
        onUpdateOrderStatus: updateOrderStatus, onDeleteOrder: (id) { setState(() => orders.removeWhere((e) => e.id == id)); _save(); },
      ),
    );
  }
}

// ================= START PAGE =================
class StartPage extends StatelessWidget {
  final VoidCallback onStart; const StartPage({super.key, required this.onStart});
  @override Widget build(BuildContext context) {
    return Scaffold(body: Container(width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0B3D91), Color(0xFF1565C0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(100)), child: const Icon(Icons.phone_android, size: 80, color: Colors.white)),
        const SizedBox(height: 20),
        const Text('اهلا بيك في عدي فون', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 10),
        const Text('كل خدمات الصيانة والمنتجات في مكان واحد\nنجار، كهربائي، صيانة موبايل', style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: const Text('توصيل سريع - دفع فودافون كاش - مندوب لحد البيت', style: TextStyle(color: Colors.white, fontSize: 12))),
        const SizedBox(height: 40),
        SizedBox(width: double.infinity, height: 54, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), onPressed: onStart, child: const Text('ابدأ الآن', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)))),
        const SizedBox(height: 14),
        const Text('بدون حساب - ادخل على طول', style: TextStyle(color: Colors.white60, fontSize: 13)),
      ]),
    ));
  }
}

// ================= MAIN SCAFFOLD =================
class MainScaffold extends StatelessWidget {
  final int currentIndex; final Function(int) onNav;
  final List<ServiceItem> services; final List<ServiceItem> allServices; final List<Product> products; final List<Product> allProducts;
  final List<OrderItem> cart; final List<AppOrder> orders; final List<String> notifications; final String searchText; final String selectedCategory; final List<String> categories;
  final Function(String) onSearch; final Function(String) onCategory; final Function(String, double) onAddToCart; final Function(Product) onAddProduct; final Function(Product) onDeleteProduct; final Function(Product, Product) onEditProduct; final VoidCallback onClearCart; final Function(AppOrder) onCreateOrder; final Function(int) onToggleFavService; final Function(int) onToggleFavProduct;
  final Function(String) onInc; final Function(String) onDec; final Function(String) onRemoveItem; final Function(String, String) onUpdateOrderStatus; final Function(String) onDeleteOrder;
  const MainScaffold({super.key, required this.currentIndex, required this.onNav, required this.services, required this.allServices, required this.products, required this.allProducts, required this.cart, required this.orders, required this.notifications, required this.searchText, required this.selectedCategory, required this.categories, required this.onSearch, required this.onCategory, required this.onAddToCart, required this.onAddProduct, required this.onDeleteProduct, required this.onEditProduct, required this.onClearCart, required this.onCreateOrder, required this.onToggleFavService, required this.onToggleFavProduct, required this.onInc, required this.onDec, required this.onRemoveItem, required this.onUpdateOrderStatus, required this.onDeleteOrder});
  @override Widget build(BuildContext context) {
    Widget body;
    if (currentIndex == 1) {
      body = HomePage(services: services, allServices: allServices, products: products, allProducts: allProducts, searchText: searchText, selectedCategory: selectedCategory, categories: categories, onSearch: onSearch, onCategory: onCategory, onAddToCart: onAddToCart, orders: orders, notifications: notifications, onToggleFavService: onToggleFavService, onToggleFavProduct: onToggleFavProduct, onGoCart: () => onNav(2));
    } else if (currentIndex == 2) { body = CartPage(cart: cart, onClear: onClearCart, onCheckout: () => onNav(3), onInc: onInc, onDec: onDec, onRemoveItem: onRemoveItem); }
    else if (currentIndex == 3) { body = CheckoutPage(cart: cart, onCreateOrder: (o) { onCreateOrder(o); onNav(4); }); }
    else if (currentIndex == 4) { body = OrdersPage(orders: orders, notifications: notifications); }
    else if (currentIndex == 5) { body = MaintenancePage(allServices: allServices, onAddToCart: onAddToCart); }
    else if (currentIndex == 6) { body = FavoritesPage(services: allServices, products: allProducts, onAddToCart: onAddToCart); }
    else { body = AdminLoginPage(orders: orders, products: allProducts, onDeleteProduct: onDeleteProduct, onEditProduct: onEditProduct, onAddProduct: onAddProduct, onUpdateOrderStatus: onUpdateOrderStatus, onDeleteOrder: onDeleteOrder); }
    return Scaffold(body: body,
      bottomNavigationBar: BottomNavigationBar(currentIndex: currentIndex > 4 ? 0 : currentIndex, onTap: (i) { if (i==0) onNav(1); if (i==1) onNav(2); if (i==2) onNav(3); if (i==3) onNav(4); }, type: BottomNavigationBarType.fixed, selectedItemColor: Colors.blue, unselectedItemColor: Colors.grey, items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
        BottomNavigationBarItem(icon: Stack(children: [const Icon(Icons.shopping_cart), if (cart.isNotEmpty) Positioned(right: 0, top: 0, child: Container(padding: const EdgeInsets.all(3), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: Text('${cart.length}', style: const TextStyle(color: Colors.white, fontSize: 9))))]), label: 'السلة'),
        const BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'الدفع'),
        BottomNavigationBarItem(icon: Stack(children: [const Icon(Icons.list_alt), if (notifications.isNotEmpty) Positioned(right: 0, top: 0, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)))]), label: 'طلباتي'),
      ]),
    );
  }
}

// ================= HOME =================
class HomePage extends StatelessWidget {
  final List<ServiceItem> services; final List<ServiceItem> allServices; final List<Product> products; final List<Product> allProducts; final String searchText; final String selectedCategory; final List<String> categories; final Function(String) onSearch; final Function(String) onCategory; final Function(String, double) onAddToCart; final List<AppOrder> orders; final List<String> notifications; final Function(int) onToggleFavService; final Function(int) onToggleFavProduct; final VoidCallback onGoCart;
  const HomePage({super.key, required this.services, required this.allServices, required this.products, required this.allProducts, required this.searchText, required this.selectedCategory, required this.categories, required this.onSearch, required this.onCategory, required this.onAddToCart, required this.orders, required this.notifications, required this.onToggleFavService, required this.onToggleFavProduct, required this.onGoCart});
  @override Widget build(BuildContext context) {
    var odayServices = services.where((s) => s.category == 'موبايل').toList();
    var otherServices = services.where((s) => s.category != 'موبايل').toList();
    return SafeArea(child: SingleChildScrollView(child: Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        Row(children: [
          Expanded(child: GestureDetector(onDoubleTap: () { Navigator.push(context, MaterialPageRoute(builder: () => AdminLoginPage(orders: orders, products: allProducts, onDeleteProduct: () {}, onEditProduct: (, _) {}, onAddProduct: () {}, onUpdateOrderStatus: (, _) {}, onDeleteOrder: () {}))); }, child: const Text('اهلا بيك في عدي فون', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)))),
          IconButton(icon: const Icon(Icons.shopping_cart, color: Colors.blue), onPressed: onGoCart),
          IconButton(icon: const Icon(Icons.favorite, color: Colors.red), onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => FavoritesPage(services: allServices, products: allProducts, onAddToCart: onAddToCart))); }),
        ]),
        const SizedBox(height: 10),
        TextField(onChanged: onSearch, decoration: InputDecoration(hintText: 'ابحث عن خدمة أو منتج...', prefixIcon: const Icon(Icons.search), suffixIcon: searchText.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () => onSearch('')) : null, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
      ])),
      Container(width: double.infinity, color: Colors.white, padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFFF5722)]), borderRadius: BorderRadius.circular(16)), child: Row(children: [const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('عروض اليوم', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('خصم 20% على اول خدمة', style: TextStyle(color: Colors.white)), Text('استخدم كود: AADI20', style: TextStyle(color: Colors.white, fontSize: 12))])), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: const Text('اطلب الآن', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)))])),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, height: 54, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => StorePage(products: allProducts, onAddToCart: onAddToCart))); }, icon: const Icon(Icons.store, color: Colors.white), label: const Text('ادخل المتجر - شواحن / كابل / جراب / سماعات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)))),
        const SizedBox(height: 16),
        const Text('خدمات عدي فون', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('صيانة من المنزل اطلب مندوب', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 12),
        ...odayServices.map((s) {
          int idx = allServices.indexOf(s);
          return Card(margin: const EdgeInsets.only(bottom: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), child: ListTile(leading: CircleAvatar(backgroundColor: Colors.blue.shade50, radius: 26, child: Icon(s.icon, color: Colors.blue, size: 26)), title: Row(children: [Expanded(child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold))), IconButton(icon: Icon(s.isFav ? Icons.favorite : Icons.favorite_border, color: Colors.red, size: 20), onPressed: () => onToggleFavService(idx))]), subtitle: Text('${s.desc}\nيبدأ من ${s.price.toStringAsFixed(0)} ج'), isThreeLine: true, trailing: ElevatedButton(onPressed: () => onAddToCart(s.name, s.price), child: const Text('اطلب الآن'))));
        }).toList(),
        if (odayServices.isEmpty) const Padding(padding: EdgeInsets.all(12), child: Text('مفيش خدمة عدي فون مطابقة لبحثك')),
        const SizedBox(height: 12),
        const Text('منتجات عدي فون', style
