import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() { runApp(const OdayApp()); }

// ================= MODELS =================
class ServiceItem {
  String name; String desc; IconData icon; double price; String category; double rating; bool isFav;
  ServiceItem({required this.name, required this.desc, required this.icon, required this.price, required this.category, this.rating = 4.8, this.isFav = false});
}
class Product {
  String name; String desc; double price; String? imagePath; IconData icon; String category; bool isOffer; double oldPrice; bool isFav;
  Product({required this.name, required this.desc, required this.price, this.imagePath, required this.icon, required this.category, this.isOffer = false, this.oldPrice = 0, this.isFav = false});
}
class OrderItem { String name; int qty; double price; OrderItem({required this.name, required this.qty, required this.price}); }
class AppOrder {
  String id; String customerName; String phone; String address; String paymentMethod; String status; List<OrderItem> items; double total; String? proofPath; String date;
  AppOrder({required this.id, required this.customerName, required this.phone, required this.address, required this.paymentMethod, required this.status, required this.items, required this.total, this.proofPath, required this.date});
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
  List<String> categories = ['الكل', 'نجارة', 'كهرباء', 'موبايل'];
  void addToCart(String name, double price) {
    setState(() {
      var ex = cart.where((e) => e.name == name).toList();
      if (ex.isNotEmpty) { ex.first.qty++; } else { cart.add(OrderItem(name: name, qty: 1, price: price)); }
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت الاضافة للسلة')));
  }
  void toggleFavService(int idx) => setState(() => services[idx].isFav = !services[idx].isFav);
  void toggleFavProduct(int idx) => setState(() => products[idx].isFav = !products[idx].isFav);
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
      debugShowCheckedModeBanner: false,
      title: 'عدي فون',
      theme: ThemeData(primarySwatch: Colors.blue, scaffoldBackgroundColor: const Color(0xFFF6F8FB), useMaterial3: true),
      home: showStart ? StartPage(onStart: () => setState(() { showStart = false; currentIndex = 1; })) : MainScaffold(
        currentIndex: currentIndex, onNav: (i) => setState(() => currentIndex = i),
        services: filteredServices, allServices: services, products: filteredProducts, allProducts: products,
        cart: cart, orders: orders, searchText: searchText, selectedCategory: selectedCategory, categories: categories,
        onSearch: (v) => setState(() => searchText = v), onCategory: (c) => setState(() => selectedCategory = c),
        onAddToCart: addToCart, onAddProduct: (p) => setState(() => products.add(p)),
        onDeleteProduct: (p) => setState(() => products.remove(p)),
        onClearCart: () => setState(() => cart.clear()),
        onCreateOrder: (o) => setState(() { orders.add(o); cart.clear(); }),
        onToggleFavService: toggleFavService, onToggleFavProduct: toggleFavProduct,
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
        Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: const Text('توصيل سريع - دفع فودافون كاش - مندوب لحد البيت', style: TextStyle(color: Colors.white, fontSize: 12))),
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
  final List<OrderItem> cart; final List<AppOrder> orders; final String searchText; final String selectedCategory; final List<String> categories;
  final Function(String) onSearch; final Function(String) onCategory; final Function(String, double) onAddToCart; final Function(Product) onAddProduct; final Function(Product) onDeleteProduct; final VoidCallback onClearCart; final Function(AppOrder) onCreateOrder; final Function(int) onToggleFavService; final Function(int) onToggleFavProduct;
  const MainScaffold({super.key, required this.currentIndex, required this.onNav, required this.services, required this.allServices, required this.products, required this.allProducts, required this.cart, required this.orders, required this.searchText, required this.selectedCategory, required this.categories, required this.onSearch, required this.onCategory, required this.onAddToCart, required this.onAddProduct, required this.onDeleteProduct, required this.onClearCart, required this.onCreateOrder, required this.onToggleFavService, required this.onToggleFavProduct});
  @override Widget build(BuildContext context) {
    Widget body;
    if (currentIndex == 1) {
      body = HomePage(services: services, allServices: allServices, products: products, allProducts: allProducts, searchText: searchText, selectedCategory: selectedCategory, categories: categories, onSearch: onSearch, onCategory: onCategory, onAddToCart: onAddToCart, onAddProduct: onAddProduct, orders: orders, onToggleFavService: onToggleFavService, onToggleFavProduct: onToggleFavProduct, onGoCart: () => onNav(2));
    } else if (currentIndex == 2) { body = CartPage(cart: cart, onClear: onClearCart, onCheckout: () => onNav(3)); }
    else if (currentIndex == 3) { body = CheckoutPage(cart: cart, onCreateOrder: (o) { onCreateOrder(o); onNav(4); }); }
    else if (currentIndex == 4) { body = OrdersPage(orders: orders); }
    else if (currentIndex == 5) { body = MaintenancePage(allServices: allServices, onAddToCart: onAddToCart); }
    else if (currentIndex == 6) { body = FavoritesPage(services: allServices, products: allProducts, onAddToCart: onAddToCart); }
    else { body = AdminLoginPage(orders: orders, products: allProducts, onDeleteProduct: onDeleteProduct); }
    return Scaffold(body: body,
      bottomNavigationBar: BottomNavigationBar(currentIndex: currentIndex > 4 ? 0 : currentIndex, onTap: (i) { if (i==0) onNav(1); if (i==1) onNav(2); if (i==2) onNav(3); if (i==3) onNav(4); }, type: BottomNavigationBarType.fixed, selectedItemColor: Colors.blue, unselectedItemColor: Colors.grey, items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
        BottomNavigationBarItem(icon: Stack(children: [const Icon(Icons.shopping_cart), if (cart.isNotEmpty) Positioned(right: 0, top: 0, child: Container(padding: const EdgeInsets.all(3), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: Text('${cart.length}', style: const TextStyle(color: Colors.white, fontSize: 9))))]), label: 'السلة'),
        const BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'الدفع'),
        const BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'طلباتي'),
      ]),
    );
  }
}

// ================= HOME - مفصولة بزرارين - انا اللي فصلتها =================
class HomePage extends StatefulWidget {
  final List<ServiceItem> services; final List<ServiceItem> allServices; final List<Product> products; final List<Product> allProducts; final String searchText; final String selectedCategory; final List<String> categories; final Function(String) onSearch; final Function(String) onCategory; final Function(String, double) onAddToCart; final Function(Product) onAddProduct; final List<AppOrder> orders; final Function(int) onToggleFavService; final Function(int) onToggleFavProduct; final VoidCallback onGoCart;
  const HomePage({super.key, required this.services, required this.allServices, required this.products, required this.allProducts, required this.searchText, required this.selectedCategory, required this.categories, required this.onSearch, required this.onCategory, required this.onAddToCart, required this.onAddProduct, required this.orders, required this.onToggleFavService, required this.onToggleFavProduct, required this.onGoCart});
  @override State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  // 0 = عدي فون , 1 = خدمات اخري
  int tab = 0;
  @override Widget build(BuildContext context) {
    var odayServices = widget.services.where((s) => s.category == 'موبايل').toList();
    var otherServices = widget.services.where((s) => s.category != 'موبايل').toList();
    return SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 16, child: Column(children: [
        Row(children: [
          const Expanded(child: Text('اهلا بيك في عدي فون', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          IconButton(icon: const Icon(Icons.shopping_cart, color: Colors.blue), onPressed: widget.onGoCart),
          IconButton(icon: const Icon(Icons.favorite, color: Colors.red), onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => FavoritesPage(services: widget.allServices, products: widget.allProducts, onAddToCart: widget.onAddToCart))); }),
          IconButton(icon: const Icon(Icons.admin_panel_settings, color: Colors.blue), onPressed: () { Navigator.push(context, MaterialPageRoute(builder: () => AdminLoginPage(orders: widget.orders, products: widget.allProducts, onDeleteProduct: () {}))); }),
        ]),
        const SizedBox(height: 10),
        TextField(onChanged: widget.onSearch, decoration: InputDecoration(hintText: 'ابحث عن خدمة أو منتج...', prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
        const SizedBox(height: 12),
        // ===== زرار الفصل - انا اللي عملته =====
        Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(30)), child: Row(children: [
          Expanded(child: GestureDetector(onTap: () => setState(() => tab = 0), child: Container(padding: const EdgeInsets.symmetric(vertical: 11), decoration: BoxDecoration(color: tab == 0 ? Colors.blue : Colors.transparent, borderRadius: BorderRadius.circular(25)), child: Text('عدي فون', textAlign: TextAlign.center, style: TextStyle(color: tab == 0 ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 15))))),
          Expanded(child: GestureDetector(onTap: () => setState(() => tab = 1), child: Container(padding: const EdgeInsets.symmetric(vertical: 11), decoration: BoxDecoration(color: tab == 1 ? Colors.orange : Colors.transparent, borderRadius: BorderRadius.circular(25)), child: Text('خدمات اخري', textAlign: TextAlign.center, style: TextStyle(color: tab == 1 ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 15))))),
        ])),
        const SizedBox(height: 10),
        SizedBox(height: 38, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: widget.categories.length, separatorBuilder: (, _) => const SizedBox(width: 😎, itemBuilder: (c, i) { bool sel = widget.categories[i] == widget.selectedCategory; return GestureDetector(onTap: () => widget.onCategory(widget.categories[i]), child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 😎, decoration: BoxDecoration(color: sel ? Colors.blue : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? Colors.blue : Colors.grey.shade300)), child: Text(widget.categories[i], style: TextStyle(color: sel ? Colors.white : Colors.black, fontWeight: FontWeight.bold)))); })),
      ])),
      Expanded(child: tab == 0 ? _OdayPhoneSection(odayServices: odayServices, allServices: widget.allServices, products: widget.products, allProducts: widget.allProducts, onAddToCart: widget.onAddToCart, onAddProduct: widget.onAddProduct, onToggleFavService: widget.onToggleFavService, onToggleFavProduct: widget.onToggleFavProduct) : _OtherServicesSection(otherServices: otherServices, onAddToCart: widget.onAddToCart)),
    ]));
  }
}

// ===== صفحة عدي فون لوحدها =====
class _OdayPhoneSection extends StatelessWidget {
  final List<ServiceItem> odayServices; final List<ServiceItem> allServices; final List<Product> products; final List<Product> allProducts; final Function(String, double) onAddToCart; final Function(Product) onAddProduct; final Function(int) onToggleFavService; final Function(int) onToggleFavProduct;
  const _OdayPhoneSection({required this.odayServices, required this.allServices, required this.products, required this.allProducts, required this.onAddToCart, required this.onAddProduct, required this.onToggleFavService, required this.onToggleFavProduct});
  @override Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFFF5722)]), borderRadius: BorderRadius.circular(16)), child: Row(children: [const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('عروض اليوم', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('خصم 20% على اول خدمة', style: TextStyle(color: Colors.white)), Text('استخدم كود: AADI20', style: TextStyle(color: Colors.white, fontSize: 12))])), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: const Text('اطلب الآن', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)))])),
      const SizedBox(height: 16),
      const Text('خدمات عدي فون', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      const Text('صيانة موبايل ومنتجات عدي فون بس', style: TextStyle(color: Colors.grey)),
      const SizedBox(height: 12),
      ...odayServices.map((s) {
        int idx = allServices.indexOf(s);
        return Card(margin: const EdgeInsets.only(bottom: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), child: ListTile(leading: CircleAvatar(backgroundColor: Colors.blue.shade50, radius: 26, child: Icon(s.icon, color: Colors.blue, size: 26)), title: Row(children: [Expanded(child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold))), IconButton(icon: Icon(s.isFav ? Icons.favorite : Icons.favorite_border, color: Colors.red, size: 20), onPressed: () => onToggleFavService(idx))]), subtitle: Text('${s.desc}\nيبدأ من ${s.price.toStringAsFixed(0)} ج'), isThreeLine: true, trailing: ElevatedButton(onPressed: () => onAddToCart(s.name, s.price), child: const Text('اطلب الآن'))));
      }).toList(),
      if (odayServices.isEmpty) const Padding(padding: EdgeInsets.all(12), child: Text('مفيش خدمة عدي فون مطابقة لبحثك', style: TextStyle(color: Colors.grey))),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('منتجات عدي فون', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddProductPage(onAdd: onAddProduct))), child: const Text('اضافة منتج +'))]),
      ...products.map((p) {
        int idx = allProducts.indexOf(p);
        return Card(margin: const EdgeInsets.only(bottom: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), child: ListTile(leading: Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)), child: p.imagePath != null ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(File(p.imagePath!), fit: BoxFit.cover)) : Stack(children: [Center(child: Icon(p.icon, size: 30, color: Colors.blue)), if (p.isOffer) Positioned(top: 2, right: 2, child: Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)), child: const Text('عرض', style: TextStyle(color: Colors.white, fontSize: 9))))])), title: Row(children: [Expanded(child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold))), IconButton(icon: Icon(p.isFav ? Icons.favorite : Icons.favorite_border, color: Colors.red, size: 20), onPressed: () => onToggleFavProduct(idx))]), subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.desc), const SizedBox(height: 3), Row(children: [Text('${p.price.toStringAsFixed(0)} ج', style: const TextStyle(fontWeight: FontWeight.bold)), if (p.isOffer) Text('  ${p.oldPrice.toStringAsFixed(0)} ج', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12))])]), trailing: ElevatedButton(onPressed: () => onAddToCart(p.name, p.price), child: const Text('اضف'))));
      }).toList(),
    ]));
  }
}

// ===== صفحة الخدمات الاخري لوحدها =====
class _OtherServicesSection extends StatelessWidget {
  final List<ServiceItem> otherServices; final Function(String, double) onAddToCart;
  const _OtherServicesSection({required this.otherServices, required this.onAddToCart});
  @override Widget build(BuildContext context) {
    return Container(color: const Color(0xFFEDEFF2), child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('خدمات اخري', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      const Text('خدمات منفصلة تماما عن عدي فون', style: TextStyle(color: Colors.grey)),
      const SizedBox(height: 12),
      ...otherServices.map((s) {
        return Card(margin: const EdgeInsets.only(bottom: 10), color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), child: ListTile(leading: CircleAvatar(backgroundColor: Colors.orange.shade50, radius: 26, child: Icon(s.icon, color: Colors.orange, size: 26)), title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('${s.desc}\nيبدأ من ${s.price.toStringAsFixed(0)} ج'), isThreeLine: true, trailing: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), onPressed: () => onAddToCart(s.name, s.price), child: const Text('اطلب الآن'))));
      }).toList(),
      if (otherServices.isEmpty) const Padding(padding: EdgeInsets.all(12), child: Text('مفيش خدمات اخري مطابقة لبحثك')),
      const SizedBox(height: 20),
    ])));
  }
}

// ================= ADD PRODUCT =================
class AddProductPage extends StatefulWidget { final Function(Product) onAdd; const AddProductPage({super.key, required this.onAdd}); @override State<AddProductPage> createState() => _AddProductPageState(); }
class _AddProductPageState extends State<AddProductPage> {
  final nameC = TextEditingController(); final descC = TextEditingController(); final priceC = TextEditingController(); String? imagePath; String category = 'اكسسوارات';
  Future<void> pickImage() async { final XFile? f = await ImagePicker().pickImage(source: ImageSource.gallery); if (f != null) setState(() => imagePath = f.path); }
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('اضافة منتج')), body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
      GestureDetector(onTap: pickImage, child: Container(width: double.infinity, height: 200, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade300)), child: imagePath != null ? ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.file(File(imagePath!), fit: BoxFit.cover)) : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 44, color: Colors.blue), SizedBox(height: 😎, Text('اختر صورة من الهاتف', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), SizedBox(height: 4), Text('اضغط هنا واختار من الاستوديو', style: TextStyle(color: Colors.grey))]))),
      const SizedBox(height: 10),
      if (imagePath != null) TextButton(onPressed: pickImage, child: const Text('تغيير الصورة')),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(value: category, decoration: const InputDecoration(labelText: 'القسم', border: OutlineInputBorder()), items: ['اكسسوارات','شواحن','سماعات','جرابات','اخرى'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => category = v!)),
      const SizedBox(height: 10),
      TextField(controller: nameC, decoration: const InputDecoration(labelText: 'اسم المنتج *', border: OutlineInputBorder())),
      const SizedBox(height: 10),
      TextField(controller: descC, maxLines: 2, decoration: const InputDecoration(labelText: 'وصف المنتج', border: OutlineInputBorder())),
      const SizedBox(height: 10),
      TextField(controller: priceC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر *', border: OutlineInputBorder())),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: () { if (nameC.text.isEmpty || priceC.text.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اكمل اسم المنتج والسعر'))); return; } widget.onAdd(Product(name: nameC.text, desc: descC.text, price: double.tryParse(priceC.text) ?? 0, imagePath: imagePath, icon: Icons.shopping_bag, category: category)); Navigator.pop(context); }, child: const Text('حفظ المنتج'))),
    ])));
  }
}

// ================= MAINTENANCE =================
class MaintenancePage extends StatelessWidget { final List<ServiceItem> allServices; final Function(String, double) onAddToCart; const MaintenancePage({super.key, required this.allServices, required this.onAddToCart});
  @override Widget build(BuildContext context) {
    return SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('صيانة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      const Text('املا البيانات والمندوب يكون تحت البيت', style: TextStyle(color: Colors.grey, fontSize: 15)),
      const SizedBox(height: 14),
      ...allServices.map((s) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(leading: CircleAvatar(backgroundColor: Colors.blue.shade50, child: Icon(s.icon, color: Colors.blue)), title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('${s.desc}\n${s.price} ج'), isThreeLine: true, trailing: ElevatedButton(onPressed: () => onAddToCart(s.name, s.price), child: const Text('اطلب'))))).toList(),
    ])));
  }
}

// ================= FAVORITES =================
class FavoritesPage extends StatelessWidget { final List<ServiceItem> services; final List<Product> products; final Function(String, double) onAddToCart; const FavoritesPage({super.key, required this.services, required this.products, required this.onAddToCart});
  @override Widget build(BuildContext context) {
    var favS = services.where((e) => e.isFav).toList(); var favP = products.where((e) => e.isFav).toList();
    return Scaffold(appBar: AppBar(title: const Text('المفضلة')), body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (favS.isEmpty && favP.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('لسه مفيش مفضلة، اضغط على القلب'))),
      if (favS.isNotEmpty) const Text('خدمات مفضلة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ...favS.map((s) => Card(child: ListTile(leading: Icon(s.icon, color: Colors.blue), title: Text(s.name), subtitle: Text(s.desc), trailing: ElevatedButton(onPressed: () => onAddToCart(s.name, s.price), child: const Text('اطلب'))))).toList(),
      if (favP.isNotEmpty) const Padding(padding: EdgeInsets.only(top: 12), child: Text('منتجات مفضلة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
      ...favP.map((p) => Card(child: ListTile(leading: Icon(p.icon, color: Colors.blue), title: Text(p.name), subtitle: Text(p.desc), trailing: ElevatedButton(onPressed: () => onAddToCart(p.name, p.price), child: const Text('اضف'))))).toList(),
    ])));
  }
}

// ================= CART =================
class CartPage extends StatelessWidget { final List<OrderItem> cart; final VoidCallback onClear; final VoidCallback onCheckout; const CartPage({super.key, required this.cart, required this.onClear, required this.onCheckout});
  @override Widget build(BuildContext context) {
    double total = cart.fold(0, (a, e) => a + e.price * e.qty);
    double delivery = cart.isEmpty ? 0 : 30; double grand = total + delivery;
    return SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('السلة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      if (cart.isEmpty) const Expanded(child: Center(child: Text('السلة فاضية، اختار خدمة او منتج'))),
      if (cart.isNotEmpty) Expanded(child: ListView(children: cart.map((e) => Card(child: ListTile(title: Text(e.name), subtitle: Text('${e.qty} × ${e.price} ج'), trailing: Text('${(e.price * e.qty).toStringAsFixed(0)} ج', style: const TextStyle(fontWeight: FontWeight.bold))))).toList())),
      if (cart.isNotEmpty) Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('المجموع'), Text('$total ج')]),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('التوصيل'), Text('$delivery ج')]),
        const Divider(),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('الاجمالي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text('$grand ج', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: onCheckout, child: const Text('اكمل الدفع'))),
        TextButton(onPressed: onClear, child: const Text('مسح السلة')),
      ])),
    ])));
  }
}

// ================= CHECKOUT =================
class CheckoutPage extends StatefulWidget { final List<OrderItem> cart; final Function(AppOrder) onCreateOrder; const CheckoutPage({super.key, required this.cart, required this.onCreateOrder}); @override State<CheckoutPage> createState() => _CheckoutPageState(); }
class _CheckoutPageState extends State<CheckoutPage> {
  final nameC = TextEditingController(); final phoneC = TextEditingController(); final addressC = TextEditingController(); final notesC = TextEditingController();
  String payment = 'فودافون كاش';
  @override Widget build(BuildContext context) {
    double sub = widget.cart.fold(0, (a, e) => a + e.price * e.qty); double total = sub + (widget.cart.isEmpty ? 0 : 30);
    return SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('بيانات العميل والدفع', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      const Text('اكتب بياناتك صح عشان المندوب يوصلك', style: TextStyle(color: Colors.grey)),
      const SizedBox(height: 14),
      TextField(controller: nameC, decoration: const InputDecoration(labelText: 'اسم العميل *', prefixIcon: Icon(Icons.person), border: OutlineInputBorder())),
      const SizedBox(height: 10),
      TextField(controller: phoneC, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'رقم التليفون *', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder())),
      const SizedBox(height: 10),
      TextField(controller: addressC, maxLines: 2, decoration: const InputDecoration(labelText: 'العنوان بالتفصيل *', prefixIcon: Icon(Icons.location_on), border: OutlineInputBorder())),
      const SizedBox(height: 10),
      TextField(controller: notesC, decoration: const InputDecoration(labelText: 'ملاحظات للمندوب (اختياري)', border: OutlineInputBorder())),
      const SizedBox(height: 16),
      const Text('طريقة الدفع', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 10),
      ...['فودافون كاش', 'انستا باي', 'فوري', 'كاش عند الاستلام'].map((m) => Card(child: RadioListTile<String>(title: Text(m), subtitle: Text(m == 'كاش عند الاستلام' ? 'تدفع للمندوب لما يوصلك' : 'هتتحول لصفحة ترفع فيها سكرين التحويل'), value: m, groupValue: payment, onChanged: (v) => setState(() => payment = v!)))).toList(),
      const SizedBox(height: 12),
      Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('المجموع'), Text('$sub ج')]), const SizedBox(height: 4), const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('التوصيل'), Text('30 ج')]), const Divider(), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('الاجمالي', style: TextStyle(fontWeight: FontWeight.bold)), Text('$total ج', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))])])),
      const SizedBox(height: 16),
      SizedBox(width: double.infinity, height: 54, child: ElevatedButton(onPressed: () {
        if (nameC.text.isEmpty || phoneC.text.isEmpty || addressC.text.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اكمل بيانات العميل: الاسم ورقم التليفون والعنوان'))); return; }
        if (widget.cart.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('السلة فاضية'))); return; }
        if (payment == 'كاش عند الاستلام') {
          widget.onCreateOrder(AppOrder(id: DateTime.now().millisecondsSinceEpoch.toString(), customerName: nameC.text, phone: phoneC.text, address: addressC.text, paymentMethod: payment, status: 'تم الاستلام - كاش', items: List.from(widget.cart), total: total, date: DateTime.now().toString().substring(0, 16)));
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CourierPage()));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentProofPage(method: payment, total: total, onConfirm: (proof) {
            widget.onCreateOrder(AppOrder(id: DateTime.now().millisecondsSinceEpoch.toString(), customerName: nameC.text, phone: phoneC.text, address: addressC.text, paymentMethod: payment, status: 'في انتظار تأكيد التحويل', items: List.from(widget.cart), total: total, proofPath: proof, date: DateTime.now().toString().substring(0, 16)));
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CourierPage()));
          })));
        }
      }, child: const Text('تأكيد الطلب', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)))),
      const SizedBox(height: 20),
    ])));
  }
}

// ================= PAYMENT PROOF =================
class PaymentProofPage extends StatefulWidget { final String method; final double total; final Function(String?) onConfirm; const PaymentProofPage({super.key, required this.method, required this.total, required this.onConfirm}); @override State<PaymentProofPage> createState() => _PaymentProofPageState(); }
class _PaymentProofPageState extends State<PaymentProofPage> {
  String? proofPath;
  String get number => '01015519180';
  String get instructions => widget.method == 'فودافون كاش' ? 'افتح فودافون كاش > تحويل اموال > اكتب الرقم والمبلغ' : widget.method == 'انستا باي' ? 'افتح انستا باي > ارسال اموال > اكتب الرقم والمبلغ' : 'افتح فوري > تحويل > اكتب الرقم والمبلغ';
  Future<void> pickProof() async { final XFile? f = await ImagePicker().pickImage(source: ImageSource.gallery); if (f != null) setState(() => proofPath = f.path); }
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('ادفع بـ ${widget.method}')), body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('ادفع بـ ${widget.method}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 10),
        const Text('حول على الرقم ده:'),
        const SizedBox(height: 4),
        Text(number, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 10),
        Text('المبلغ المطلوب: ${widget.total.toStringAsFixed(0)} ج', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(instructions, style: const TextStyle(color: Colors.grey)),
      ])),
      const SizedBox(height: 16),
      const Text('بعد التحويل ارفع سكرين شوت', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      GestureDetector(onTap: pickProof, child: Container(width: double.infinity, height: 220, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade300)), child: proofPath != null ? ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.file(File(proofPath!), fit: BoxFit.cover)) : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.upload, size: 44, color: Colors.blue), SizedBox(height: 😎, Text('ارفع سكرين شوت للتحويل من الهاتف', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), SizedBox(height: 4), Text('اضغط هنا واختار السكرين من الاستوديو', style: TextStyle(color: Colors.grey))]))),
      const SizedBox(height: 10),
      if (proofPath != null) TextButton(onPressed: pickProof, child: const Text('تغيير السكرين')),
      const SizedBox(height: 10),
      SizedBox(width: double.infinity, height: 54, child: ElevatedButton(onPressed: () { if (proofPath == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ارفع سكرين التحويل الاول'))); return; } widget.onConfirm(proofPath); }, child: const Text('تأكيد اني حولت'))),
    ])));
  }
}

// ================= COURIER =================
class CourierPage extends StatefulWidget { const CourierPage({super.key}); @override State<CourierPage> createState() => _CourierPageState(); }
class _CourierPageState extends State<CourierPage> {
  double progress = 0.1; int minutes = 15; double distance = 4.5; Timer? timer; bool cancelled = false; String statusText = 'المندوب اتحرك';
  @override void initState() { super.initState(); timer = Timer.periodic(const Duration(seconds: 2), (t) { if (!mounted) return; setState(() { if (progress < 1 && !cancelled) { progress = (progress + 0.08).clamp(0, 1); minutes = (minutes - 1).clamp(1, 15); distance = (distance - 0.35).clamp(0.2, 4.5); if (progress > 0.5) statusText = 'المندوب قرب'; if (progress >= 1) { statusText = 'المندوب وصل'; timer?.cancel(); } } }); }); }
  @override void dispose() { timer?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('تتبع المندوب')), body: Column(children: [
      Expanded(child: Container(width: double.infinity, color: Colors.blue.shade50, padding: const EdgeInsets.all(20), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Stack(alignment: Alignment.center, children: [Container(width: 140, height: 140, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]), child: const Icon(Icons.delivery_dining, size: 70, color: Colors.blue)), Positioned(bottom: 0, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)), child: Text('${(progress * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))]),
        const SizedBox(height: 16),
        Text(cancelled ? 'تم الغاء الطلب' : progress >= 1 ? 'المندوب وصل' : statusText, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(cancelled ? 'لو حابب تطلب تاني ارجع للرئيسية' : 'فاضل $minutes د - المسافة ${distance.toStringAsFixed(1)} كم', style: const TextStyle(color: Colors.grey, fontSize: 16)),
        const SizedBox(height: 16),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: LinearProgressIndicator(value: progress, minHeight: 10, borderRadius: BorderRadius.circular(10), backgroundColor: Colors.grey.shade300)),
      ]))),
      Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(22)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -2))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const CircleAvatar(radius: 24, child: Icon(Icons.person)), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('مندوب عدي فون', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), SizedBox(height: 2), Text('موتوسيكل - تقييم 4.9', style: TextStyle(color: Colors.grey, fontSize: 12))])), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: cancelled ? Colors.red.shade50 : Colors.green.shade50, borderRadius: BorderRadius.circular(20)), child: Text(cancelled ? 'ملغي' : progress >= 1 ? 'وصل' : 'جاري التتبع - فاضل $minutes د', style: TextStyle(color: cancelled ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 12)))]),
        const SizedBox(height: 14),
        const Row(children: [Icon(Icons.location_on, color: Colors.blue, size: 18), SizedBox(width: 6), Expanded(child: Text('نقطة الاستلام: فرع عدي فون'))]),
        const SizedBox(height: 6),
        const Row(children: [Icon(Icons.home, color: Colors.green, size: 18), SizedBox(width: 6), Expanded(child: Text('نقطة التسليم: عنوان العميل المسجل في الطلب'))]),
        const SizedBox(height: 16),
        Row(children: [Expanded(child: SizedBox(height: 48, child: ElevatedButton(onPressed: () { setState(() { if (!cancelled && progress < 1) { progress = (progress + 0.1).clamp(0, 1); minutes = (minutes - 2).clamp(1, 15); } }); }, child: const Text('تحديث التتبع')))), const SizedBox(width: 10), Expanded(child: SizedBox(height: 48, child: OutlinedButton(style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)), onPressed: () { setState(() { cancelled = true; timer?.cancel(); }); }, child: const Text('الغاء الطلب'))))]),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('رجوع للرئيسية'))),
      ])),
    ]));
  }
}

// ================= ORDERS =================
class OrdersPage extends StatelessWidget { final List<AppOrder> orders; const OrdersPage({super.key, required this.orders});
  @override Widget build(BuildContext context) {
    return SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Expanded(child: Text('طلباتي', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20)), child: Text('${orders.length} طلب', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)))]),
      const SizedBox(height: 12),
      if (orders.isEmpty) const Expanded(child: Center(child: Text('مفيش طلبات لسه'))),
      if (orders.isNotEmpty) Expanded(child: ListView.builder(itemCount: orders.length, itemBuilder: (c, i) {
        final o = orders[i];
        return Card(margin: const EdgeInsets.only(bottom: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('طلب #${o.id.length > 4 ? o.id.substring(o.id.length - 4) : o.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20)), child: Text(o.status, style: const TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold)))]),
          const SizedBox(height: 4),
          Text(o.date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 12),
          Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [Icon(Icons.person, size: 16, color: Colors.blue), SizedBox(width: 6), Text('بيانات العميل', style: TextStyle(fontWeight: FontWeight.bold))]),
            const SizedBox(height: 10),
            Text('الاسم: ${o.customerName}'),
            const SizedBox(height: 3),
            Text('رقم التليفون: ${o.phone}'),
            const SizedBox(height: 3),
            Text('العنوان: ${o.address}'),
            const SizedBox(height: 3),
            const Text('انت هتبعتله برا التطبيق', style: TextStyle(color: Colors.grey, fontSize: 11)),
          ])),
          const SizedBox(height: 10),
          const Text('تفاصيل الطلب:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          ...o.items.map((e) => Padding(padding: const EdgeInsets.only(bottom: 2), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(e.name)), Text('${e.qty} × ${e.price} ج')]))).toList(),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('الدفع: ${o.paymentMethod}'), Text('الاجمالي: ${o.total.toStringAsFixed(0)} ج', style: const TextStyle(fontWeight: FontWeight.bold))]),
          if (o.proofPath != null) Padding(padding: const EdgeInsets.only(top: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('سكرين التحويل:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), const SizedBox(height: 6), ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(File(o.proofPath!), height: 140, width: double.infinity, fit: BoxFit.cover))])),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const CourierPage())); }, child: const Text('تتبع المندوب'))),
        ]))),
      })),
    ])));
  }
}

// ================= ADMIN =================
class AdminLoginPage extends StatefulWidget { final List<AppOrder> orders; final List<Product> products; final Function(Product) onDeleteProduct; const AdminLoginPage({super.key, required this.orders, required this.products, required this.onDeleteProduct}); @override State<AdminLoginPage> createState() => _AdminLoginPageState(); }
class _AdminLoginPageState extends State<AdminLoginPage> {
  final passC = TextEditingController(); bool isAdmin = false; String adminPassword = '1234';
  @override Widget build(BuildContext context) {
    if (!isAdmin) {
      return Scaffold(appBar: AppBar(title: const Text('دخول الادمن')), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle), child: const Icon(Icons.admin_panel_settings, size: 60, color: Colors.blue)),
        const SizedBox(height: 16),
        const Text('دخول الادمن - عدي فون', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('الباسورد الحالي: 1234', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        TextField(controller: passC, obscureText: true, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الباسورد', prefixIcon: Icon(Icons.lock), border: OutlineInputBorder())),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: () { if (passC.text == adminPassword) { setState(() => isAdmin = true); } else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الباسورد غلط'))); } }, child: const Text('دخول'))),
      ])));
    }
    double totalSales = widget.orders.fold(0, (a, e) => a + e.total);
    return Scaffold(appBar: AppBar(title: const Text('لوحة الادمن - عدي فون'), actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => setState(() => isAdmin = false))]), body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)), child: Column(children: [Text('${widget.orders.length}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const Text('عدد الطلبات')]))), const SizedBox(width: 10), Expanded(child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)), child: Column(children: [Text('${totalSales.toStringAsFixed(0)} ج', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const Text('اجمالي المبيعات')]))), const SizedBox(width: 10), Expanded(child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)), child: Column(children: [Text('${widget.products.length}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const Text('منتج')])))]),
      const SizedBox(height: 18),
      const Text('كل الطلبات ببيانات العميل كاملة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 10),
      if (widget.orders.isEmpty) const Text('مفيش طلبات لسه'),
      ...widget.orders.map((o) => Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${o.customerName} - ${o.total} ج', style: const TextStyle(fontWeight: FontWeight.bold)), Text(o.status, style: const TextStyle(color: Colors.blue))]),
        const SizedBox(height: 6),
        Text('تليفون: ${o.phone}'),
        Text('عنوان: ${o.address}'),
        Text('دفع: ${o.paymentMethod} - تاريخ: ${o.date}'),
        Text('الطلبات: ${o.items.map((e) => '${e.name} (${e.qty})').join(', ')}'),
        if (o.proofPath != null) Padding(padding: const EdgeInsets.only(top: 16, child: ClipRRect(borderRadius: BorderRadius.circular(😎, child: Image.file(File(o.proofPath!), height: 100, width: double.infinity, fit: BoxFit.cover))),
      ])))).toList(),
      const SizedBox(height: 16),
      const Text('المنتجات - تقدر تمسح:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 16),
      ...widget.products.map((p) => Card(child: ListTile(leading: p.imagePath != null ? ClipRRect(borderRadius: BorderRadius.circular(😎, child: Image.file(File(p.imagePath!), width: 50, height: 50, fit: BoxFit.cover)) : Icon(p.icon, color: Colors.blue), title: Text(p.name), subtitle: Text('${p.price} ج - ${p.category}'), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => widget.onDeleteProduct(p))))).toList(),
    ])));
  }
}
