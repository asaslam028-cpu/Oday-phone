import 'package:flutter/material.dart';

void main() {
  runApp(const OdayApp());
}

class Store extends ChangeNotifier {
  static final Store i = Store._();
  Store._();
  List<Map> orders = [];
  List<Map> cart = [];

  List<Map> products = [
    {'name': 'سماعات لاسلكية برو', 'price': 899, 'rate': '4.8', 'cat': 'سماعات', 'tag': 'الافضل مبيعا', 'color': 0xFFD6EAF0, 'desc': 'سماعة بلوتوث بعزل ضوضاء وبطارية 30 ساعة', 'img': ''},
    {'name': 'شاحن سريع 25W', 'price': 349, 'rate': '4.6', 'cat': 'شواحن', 'tag': 'خصم 20', 'color': 0xFFF0F0F0, 'desc': 'شاحن سريع يشحن 50 في المية في 30 دقيقة', 'img': ''},
    {'name': 'كفر حماية ايفون 15', 'price': 199, 'rate': '4.7', 'cat': 'كفرات', 'tag': '', 'color': 0xFFF5F5F5, 'desc': 'كفر ضد الصدمات والخدش', 'img': ''},
    {'name': 'كابل USB-C مضفور 1M', 'price': 129, 'rate': '4.5', 'cat': 'كابلات', 'tag': '', 'color': 0xFFF5F5F5, 'desc': 'كابل مضفور سريع الشحن ونقل البيانات', 'img': ''},
    {'name': 'سماعة بلوتوث', 'price': 450, 'rate': '4.8', 'cat': 'سماعات', 'tag': '', 'color': 0xFFD6EAF0, 'desc': 'صوت نقي وباس قوي', 'img': ''},
    {'name': 'صيانة شاشة', 'price': 500, 'rate': '4.9', 'cat': 'صيانة', 'tag': '', 'color': 0xFFD6EAF0, 'desc': 'تغيير شاشة اصلية بضمان 6 شهور', 'img': ''},
    {'name': 'جراب ايفون', 'price': 150, 'rate': '4.7', 'cat': 'كفرات', 'tag': '', 'color': 0xFFF5F5F5, 'desc': 'جراب شيك وخفيف', 'img': ''},
    {'name': 'سكرينة حماية', 'price': 80.0, 'rate': '4.6', 'cat': 'كفرات', 'tag': '', 'color': 0xFFF5F5F5, 'desc': 'سكرينة زجاج ضد الكسر', 'img': ''},
    {'name': 'باور بنك', 'price': 900, 'rate': '4.8', 'cat': 'شواحن', 'tag': '', 'color': 0xFFF0F0F0, 'desc': 'باور بنك 20000 ملي امبير', 'img': ''},
    {'name': 'كابل تايب سي', 'price': 120, 'rate': '4.5', 'cat': 'كابلات', 'tag': '', 'color': 0xFFF5F5F5, 'desc': 'كابل تايب سي اصلي', 'img': ''},
  ];

  void addProduct(Map m) {
    products.insert(0, m);
    notifyListeners();
  }

  void addCart(Map m) {
    cart.add(m);
    notifyListeners();
  }

  void addOrder(Map o) {
    orders.insert(0, o);
    cart.clear();
    notifyListeners();
  }

  void setStatus(int idx, String s) {
    orders[idx]['status'] = s;
    notifyListeners();
  }
}

class OdayApp extends StatelessWidget {
  const OdayApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Store.i,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Oday Phone',
          theme: ThemeData(
            primaryColor: const Color(0xFF00B4A6),
            scaffoldBackgroundColor: Colors.white,
          ),
          home: const Splash(),
        );
      },
    );
  }
}

class Splash extends StatelessWidget {
  const Splash({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1A3A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 55,
                backgroundColor: Color(0xFFFF7A00),
                child: Icon(Icons.phone_android, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text('Oday Phone', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
              const Text('اوداي فون', style: TextStyle(fontSize: 22, color: Color(0xFFFF7A00), fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('اهلا بيك في اوداي فون', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
              const Text('خدماتك المنزلية في الاسماعيلية', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A00), padding: const EdgeInsets.all(15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Home())),
                  child: const Text('ابدأ الآن', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(15), side: const BorderSide(color: Colors.white54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Home())),
                  child: const Text('عندي حساب', style: TextStyle(color: Colors.white, fontSize: 17)),
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, color: Color(0xFF00B4A6), size: 18.0),
                  SizedBox(width: 6),
                  Expanded(child: Text('الاسماعيلية - ابو عطوة - الشارع التجاري - امام ماركت التوحيد', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 12))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  int idx = 0;
  int adminTaps = 0;
  final teal = const Color(0xFF00B4A6);
  final orange = const Color(0xFFFF7A00);

  void openAdminGate() {
    adminTaps++;
    if (adminTaps >= 5) {
      adminTaps = 0;
      showDialog(
        context: context,
        builder: (_) {
          final pinC = TextEditingController();
          return AlertDialog(
            title: const Text('دخول الادمن'),
            content: TextField(
              controller: pinC,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'اكتب الرقم السري', border: OutlineInputBorder()),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('الغاء')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A00)),
                onPressed: () {
                  if (pinC.text == '1234') {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPage()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرقم غلط')));
                  }
                },
                child: const Text('دخول', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      homeBody(),
      const Shop(),
      const MaintenancePage(),
      const Courier(),
      const Checkout(),
      const MyOrders(),
    ];
    return Scaffold(
      body: pages[idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        selectedItemColor: teal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (v) => setState(() => idx = v),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'المتجر'),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'صيانة'),
          BottomNavigationBarItem(icon: Icon(Icons.delivery_dining), label: 'المندوب'),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'الدفع'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'طلباتي'),
        ],
      ),
    );
  }

  Widget homeBody() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('اهلا بيك يا عدي', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                      Text('كيف نقدر نساعدك اليوم؟', style: TextStyle(color: Colors.grey, fontSize: 15)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: openAdminGate,
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: teal.withOpacity(0.15),
                    child: Icon(Icons.person, color: teal, size: 30),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.search, color: teal, size: 26),
                  const SizedBox(width: 10),
                  const Expanded(child: Text('ابحث عن خدمة صيانة', style: TextStyle(color: Colors.grey))),
                  Icon(Icons.tune, color: orange),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الخدمات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                Text('عرض الكل', style: TextStyle(color: orange, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                serviceBox(teal, Icons.build, 'صيانة من المنزل', () => setState(() => idx = 2)),
                serviceBox(orange, Icons.shopping_bag, 'متجر اكسسوارات', () => setState(() => idx = 1)),
                serviceBox(teal, Icons.delivery_dining, 'اطلب مندوب', () => setState(() => idx = 3)),
                serviceBox(orange, Icons.credit_card, 'الدفع', () => setState(() => idx = 4)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('خدمات سريعة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                Text('المزيد', style: TextStyle(color: orange, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            quickCard(Icons.build, 'سباك', 'تسريب - تركيب - صيانة - يبدأ من 50 جنيه', teal),
            quickCard(Icons.electrical_services, 'كهربائي', 'اعمال - تركيب - فحص - يبدأ من 70 جنيه', orange),
            quickCard(Icons.ac_unit, 'صيانة مكيفات', 'تنظيف - تعبئة غاز - اصلاح - يبدأ من 120 جنيه', teal),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF6F8F8), borderRadius: BorderRadius.circular(14)),
              child: const Row(
                children: [
                  Icon(Icons.location_on, color: Color(0xFF00B4A6)),
                  SizedBox(width: 10),
                  Expanded(child: Text('الاسماعيلية - ابو عطوة - الشارع التجاري - امام ماركت التوحيد', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget serviceBox(Color c, IconData ic, String t, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(14)),
              child: Icon(ic, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 6),
            Text(t, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget quickCard(IconData ic, String t, String sub, Color c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 28.0, backgroundColor: c.withOpacity(0.15), child: Icon(ic, color: c, size: 28.0)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w900)),
                Text(sub, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: orange, size: 18.0),
        ],
      ),
    );
  }
}

class MaintenancePage extends StatefulWidget {
  const MaintenancePage({super.key});
  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> {
  String phoneType = 'ايفون';
  String fault = 'شاشة';
  final nameC = TextEditingController();
  final phoneC = TextEditingController();
  final addressC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('صيانة هواتف من المنزل', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const Text('املأ البيانات والفني هيجيلك لحد البيت', style: TextStyle(color: Color(0xFFFF7A00), fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('نوع الموبايل', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8.0,
              children: ['ايفون', 'سامسونج', 'شاومي'].map((e) {
                bool sel = phoneType == e;
                return ChoiceChip(label: Text(e), selected: sel, selectedColor: const Color(0xFFFF7A00), labelStyle: TextStyle(color: sel ? Colors.white : Colors.black), onSelected: (_) => setState(() => phoneType = e));
              }).toList(),
            ),
            const SizedBox(height: 14),
            const Text('العطل ايه؟', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8.0,
              children: ['شاشة', 'بطارية', 'سوفت وير', 'سماعة'].map((e) {
                bool sel = fault == e;
                return ChoiceChip(label: Text(e), selected: sel, selectedColor: const Color(0xFF00B4A6), labelStyle: TextStyle(color: sel ? Colors.white : Colors.black), onSelected: (_) => setState(() => fault = e));
              }).toList(),
            ),
            const SizedBox(height: 14),
            TextField(controller: nameC, decoration: const InputDecoration(labelText: 'الاسم بالكامل', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: phoneC, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'رقم التليفون 01XXXXXXXXX', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: addressC, decoration: const InputDecoration(labelText: 'العنوان - المنطقة - الشارع - رقم المبنى', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            const Row(children: [Icon(Icons.info, color: Color(0xFFFF7A00), size: 18.0), SizedBox(width: 6), Text('الفني هيجيلك لحد البيت خلال 60 دقيقة', style: TextStyle(color: Color(0xFFFF7A00)))]),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A00), padding: const EdgeInsets.all(15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: () {
                  if (nameC.text.isEmpty || phoneC.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اكتب الاسم ورقم التليفون الاول')));
                    return;
                  }
                  Store.i.addOrder({'id': 1000 + Store.i.orders.length + 1, 'items': 'صيانة $phoneType - $fault', 'total': 0, 'name': nameC.text, 'phone': phoneC.text, 'address': addressC.text, 'pay': 'عند الاستلام', 'status': 'طلب جديد'});
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم استلام طلب الصيانة - الفني في الطريق')));
                  nameC.clear(); phoneC.clear(); addressC.clear();
                },
                child: const Text('اطلب الصيانة', style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Shop extends StatefulWidget {
  const Shop({super.key});
  @override
  State<Shop> createState() => _Shop();
}

class _Shop extends State<Shop> {
  String f = 'الكل';
  List get items => Store.i.products;

  @override
  Widget build(BuildContext context) {
    List shown = f == 'الكل' ? items : items.where((e) => e['cat'] == f).toList();
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: const Color(0xFF00B4A6).withOpacity(0.15), child: const Icon(Icons.person, color: Color(0xFF00B4A6))),
                const SizedBox(width: 10),
                const Expanded(child: Text('متجر الاكسسوارات', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 10),
                  const Expanded(child: Text('ابحث عن سماعات, شواحن, كفرات', style: TextStyle(color: Colors.grey))),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: const Color(0xFFFF7A00), borderRadius: BorderRadius.circular(8.0)),
                    child: const Icon(Icons.tune, color: Colors.white, size: 18.0),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['الكل', 'سماعات', 'شواحن', 'كفرات', 'كابلات', 'صيانة'].map((c) {
                bool a = f == c;
                return Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: a,
                    selectedColor: const Color(0xFF0B7A70),
                    labelStyle: TextStyle(color: a ? Colors.white : Colors.black),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade300)),
                    onSelected: (_) => setState(() => f = c),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('المنتجات', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                const Row(
                  children: [
                    Text('الاكثر مبيعا', style: TextStyle(color: Color(0xFF00B4A6), fontWeight: FontWeight.bold)),
                    Icon(Icons.keyboard_arrow_down, color: Color(0xFF00B4A6)),
                  ],
                ),
                Text('${shown.length} منتج', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.72),
              itemCount: shown.length,
              itemBuilder: (c, i) {
                var p = shown[i];
                IconData iconData = Icons.headphones;
                if (p['cat'] == 'شواحن') iconData = Icons.power;
                if (p['cat'] == 'كفرات') iconData = Icons.phone_android;
                if (p['cat'] == 'كابلات') iconData = Icons.usb;
                if (p['cat'] == 'صيانة') iconData = Icons.build;
                String img = (p['img'] ?? '').toString();
                return InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(p['name']),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (img.isNotEmpty) ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(img, height: 180, width: double.infinity, fit: BoxFit.cover)),
                            const SizedBox(height: 10),
                            Text(p['desc'] ?? ''),
                            const SizedBox(height: 8.0),
                            Text('${p['price']} جنيه', style: const TextStyle(color: Color(0xFF00B4A6), fontWeight: FontWeight.w900, fontSize: 18.0)),
                          ],
                        ),
                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('اغلاق'))],
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 130,
                              width: double.infinity,
                              decoration: BoxDecoration(color: Color(p['color'] as int), borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
                              child: img.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                      child: Image.network(img, fit: BoxFit.cover, errorBuilder: (, _, _) => Icon(iconData, size: 70, color: const Color(0xFF0B1A3A))),
                                    )
                                  : Icon(iconData, size: 70, color: const Color(0xFF0B1A3A)),
                            ),
                            if ((p['tag'] as String).isNotEmpty)
                              Positioned(
                                top: 8.0,
                                left: 8.0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                                  decoration: BoxDecoration(color: const Color(0xFFFF7A00), borderRadius: BorderRadius.circular(6)),
                                  child: Text(p['tag'], style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Text(p['name'], textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14), maxLines: 2),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 14),
                                  const Icon(Icons.star, color: Colors.amber, size: 14),
                                  const Icon(Icons.star, color: Colors.amber, size: 14),
                                  const Icon(Icons.star, color: Colors.amber, size: 14),
                                  const Icon(Icons.star_half, color: Colors.amber, size: 14),
                                  Text(' (${p['rate']})', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('${p['price']} جنيه', style: const TextStyle(color: Color(0xFF00B4A6), fontWeight: FontWeight.w900, fontSize: 17)),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A00), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                  onPressed: () {
                                    Store.i.addCart(p);
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت الاضافة للسلة')));
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.shopping_cart, size: 16, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text('اضافة للسلة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Courier extends StatefulWidget {
  const Courier({super.key});
  @override
  State<Courier> createState() => _Courier();
}

class _Courier extends State<Courier> {
  double progress = 0.35;
  int minutes = 8;
  double km = 1.8;
  String status = 'المندوب في الطريق اليك';
  bool started = false;

  void startTrip() {
    setState(() {
      started = true;
    });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return false;
      if (progress >= 0.95) {
        setState(() {
          status = 'المندوب وصل - انزل استلم طلبك';
          minutes = 0;
          km = 0;
        });
        return false;
      }
      setState(() {
        progress += 0.08;
        if (minutes > 0) minutes -= 1;
        if (km > 0) km -= 0.2;
        if (progress > 0.6) status = 'المندوب قرب منك';
      });
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.arrow_back, color: Color(0xFF00B4A6)),
                SizedBox(width: 10),
                Text('طلب مندوب', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  color: const Color(0xFFDDE8E5),
                  child: Stack(
                    children: [
                      Positioned(left: 30, top: 80.0, right: 30, child: Container(height: 3, color: Colors.white)),
                      Positioned(left: 30, top: 200, right: 30, child: Container(height: 3, color: Colors.white)),
                      Positioned(left: 100, top: 20, bottom: 20, child: Container(width: 3, color: Colors.white)),
                      Positioned(left: 250, top: 20, bottom: 20, child: Container(width: 3, color: Colors.white)),
                      Positioned(
                        left: 40,
                        top: 50,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFFF7A00), borderRadius: BorderRadius.circular(20)),
                          child: const Row(
                            children: [
                              Icon(Icons.delivery_dining, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text('المندوب الان', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 40,
                        top: 120,
                        right: 60,
                        child: SizedBox(height: 2, child: CustomPaint(painter: DashedLine())),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(seconds: 2),
                        left: 40 + (progress * 220),
                        top: 110,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(color: Color(0xFF0B1A3A), shape: BoxShape.circle),
                          child: const Icon(Icons.delivery_dining, color: Colors.white, size: 22),
                        ),
                      ),
                      const Positioned(
                        right: 20,
                        bottom: 160,
                        child: Column(
                          children: [
                            Icon(Icons.home, color: Color(0xFFFF7A00), size: 34),
                            Text('بيتك'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 20,
                  child: Column(
                    children: [
                      FloatingActionButton.small(heroTag: 'btn1', backgroundColor: Colors.white, onPressed: () {}, child: const Icon(Icons.remove)),
                      const SizedBox(height: 10),
                      FloatingActionButton.small(heroTag: 'btn2', backgroundColor: Colors.white, onPressed: () {}, child: const Icon(Icons.add)),
                      FloatingActionButton.small(heroTag: 'btn3', backgroundColor: const Color(0xFF00B4A6), onPressed: () {}, child: const Icon(Icons.remove, color: Colors.white)),
                    ],
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: const Color(0xFFFF7A00).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.delivery_dining, color: Color(0xFFFF7A00), size: 32),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(status, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w900)),
                                  Text('علي بعد ${km.toStringAsFixed(1)} كم - يصل خلال $minutes دقائق تقريبا', style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Text('تفاصيل الطلب', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 10),
                        detail(Icons.location_on, Colors.teal, 'نقطة الاستلام', 'الاسماعيلية - ابو عطوة - الشارع التجاري'),
                        detail(Icons.location_on, Colors.orange, 'نقطة التسليم', 'الاسماعيلية - ابو عطوة - امام ماركت التوحيد'),
                        detail(Icons.edit, Colors.teal, 'ملاحظات', 'يرجي الاتصال قبل الوصول - الطرد قابل للكسر'),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A00), padding: const EdgeInsets.all(14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                            onPressed: started ? null : startTrip,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_on, color: Colors.white),
                                const SizedBox(width: 6),
                                Text(started ? 'جاري التتبع - فاضل $minutes د' : 'تتبع الطلب', style: const TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Center(child: Text('الغاء الطلب', style: TextStyle(color: Color(0xFF00B4A6), fontWeight: FontWeight.bold))),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget detail(IconData ic, Color c, String t, String s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(ic, color: c),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(s, style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashedLine extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var p = Paint()
      ..color = const Color(0xFF00B4A6)
      ..strokeWidth = 2;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + 8.0, 0), p);
      x += 14;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class Checkout extends StatefulWidget {
  const Checkout({super.key});
  @override
  State<Checkout> createState() => _Checkout();
}

class _Checkout extends State<Checkout> {
  String pay = 'فودافون كاش - 01015519180';
  final code = TextEditingController();
  int discount = 0;

  @override
  Widget build(BuildContext context) {
    var cart = Store.i.cart;
    int sub = 0;
    for (var e in cart) {
      sub += (e['price'] as int);
    }
    int service = 15;
    int total = sub + service - discount;
    if (total < 0) total = 0;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.arrow_back),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الدفع والخروج', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                    Text('مراجعة الطلب واتمام عملية الدفع', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('طرق الدفع', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            payCard('فودافون كاش - 01015519180', 'حول على 01015519180 وابعت سكرين شوت واتساب', 'V', const Color(0xFFE60000)),
            payCard('انستا باي - 01069068091', 'تحويل انستا باي على 01069068091', 'IP', const Color(0xFF6C2BD9)),
            payCard('فوري', 'الدفع عبر كود فوري او منفذ فوري', 'F', const Color(0xFFFF7A00)),
            payCard('بطاقة فيزا', '12/27 تنتهي - 4532', 'VISA', const Color(0xFF1A4FA0)),
            payCard('الدفع عند الاستلام', 'رسوم اضافية 20 جنيه عند التسليم', 'D', const Color(0xFF00B4A6)),
            const SizedBox(height: 16),
            const Text('ملخص الطلب', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFFF7A00).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.shopping_bag, color: Color(0xFFFF7A00)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cart.isEmpty ? 'اشتراك برو شهري' : '${cart.length} منتج من المتجر', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Text('المدة: شهر واحد - تجديد تلقائي', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text('$sub جنيه', style: const TextStyle(fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('رسوم الخدمة', style: TextStyle(color: Colors.grey)),
                      Text('$service جنيه', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextField(
                            controller: code,
                            decoration: const InputDecoration(border: InputBorder.none, hintText: 'اضف كود الخصم', icon: Icon(Icons.local_offer_outlined, color: Color(0xFFFF7A00))),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A00)),
                        onPressed: () {
                          setState(() {
                            discount = code.text.isNotEmpty ? 30 : 0;
                          });
                        },
                        child: const Text('تطبيق', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_user, color: Color(0xFF00B4A6), size: 16),
                      SizedBox(width: 4),
                      Text('دفع امن ومشفر - محمي بواسطة SSL 256-bit', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('المبلغ الاجمالي', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                Text('$total جنيه', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFFFF7A00))),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B4A6), padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: () {
                  if (cart.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('السلة فاضية - اختار من المتجر الاول')));
                    return;
                  }
                  Store.i.addOrder({'id': 1000 + Store.i.orders.length + 1, 'items': cart.map((e) => e['name']).join(' - '), 'total': total, 'name': 'عدي', 'phone': '01000000000', 'address': 'ابو عطوة', 'pay': pay, 'status': 'طلب جديد'});
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('تم استلام طلبك'),
                      content: Text('تم الدفع بـ $pay - الاجمالي $total جنيه'),
                      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('تمام'))],
                    ),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, color: Colors.white),
                    SizedBox(width: 6),
                    Text('ادفع الان', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const Center(child: Text('بالضغط على ادفع الان انت توافق على الشروط والاحكام', style: TextStyle(color: Colors.grey, fontSize: 12))),
          ],
        ),
      ),
    );
  }

  Widget payCard(String t, String s, String logo, Color c) {
    bool sel = pay == t;
    return InkWell(
      onTap: () => setState(() => pay = t),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: sel ? const Color(0xFF00B4A6) : Colors.grey.shade300, width: sel ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(logo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t, style: const TextStyle(fontWeight: FontWeight.w900)),
                  Text(s, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Icon(sel ? Icons.radio_button_checked : Icons.radio_button_off, color: sel ? const Color(0xFF00B4A6) : Colors.grey),
          ],
        ),
      ),
    );
  }
}

class MyOrders extends StatelessWidget {
  const MyOrders({super.key});
  @override
  Widget build(BuildContext context) {
    var o = Store.i.orders;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('طلباتي', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            if (o.isEmpty)
              const Expanded(child: Center(child: Text('لسه معملتش اي طلب')))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: o.length,
                  itemBuilder: (c, i) {
                    var x = o[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('طلب #${x['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Spacer(),
                              Text(x['status'], style: const TextStyle(color: Color(0xFFFF7A00), fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Text('المنتجات: ${x['items']}'),
                          Text('الاجمالي: ${x['total']} جنيه - ${x['pay']}'),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});
  @override
  Widget build(BuildContext context) {
    var o = Store.i.orders;
    return Scaffold(
      appBar: AppBar(title: const Text('لوحة تحكم الادمن'), backgroundColor: const Color(0xFF00B4A6)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A00), padding: const EdgeInsets.all(14)),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductPage()));
                  },
                  child: const Text('اضافة منتج جديد +', style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              Text('طلبات اليوم ${o.length}', style: const TextStyle(color: Color(0xFFFF7A00), fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (o.isEmpty)
                const Expanded(child: Center(child: Text('مفيش طلبات النهاردة')))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: o.length,
                    itemBuilder: (c, i) {
                      var x = o[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [Text('طلب #${x['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFFF7A00), borderRadius: BorderRadius.circular(20)), child: Text(x['status'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))]),
                            const SizedBox(height: 6),
                            Text('${x['items']}'),
                            Text('الاسم: ${x['name']} - ${x['phone']}'),
                            Text('العنوان: ${x['address']} - ${x['pay']}'),
                            const SizedBox(height: 8.0),
                            Row(children: [
                              Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B4A6)), onPressed: () => Store.i.setStatus(i, 'تم'), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check, color: Colors.white, size: 18.0), SizedBox(width: 4), Text('تم', style: TextStyle(color: Colors.white))]))),
                              const SizedBox(width: 8.0),
                              Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A00)), onPressed: () => Store.i.setStatus(i, 'جاري الصيانة'), child: const Text('جاري الصيانة', style: TextStyle(color: Colors.white)))),
                            ]),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});
  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final nameC = TextEditingController();
  final priceC = TextEditingController();
  final descC = TextEditingController();
  final imgC = TextEditingController();
  String cat = 'سماعات';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اضافة منتج'), backgroundColor: const Color(0xFF00B4A6)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('اسم المنتج', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: nameC, decoration: const InputDecoration(hintText: 'مثال: سماعة ايربودز', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            const Text('السعر', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: priceC, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'مثال: 899', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            const Text('التصنيف', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8.0,
              children: ['سماعات', 'شواحن', 'كفرات', 'كابلات', 'صيانة'].map((e) {
                bool sel = cat == e;
                return ChoiceChip(label: Text(e), selected: sel, selectedColor: const Color(0xFF00B4A6), labelStyle: TextStyle(color: sel ? Colors.white : Colors.black), onSelected: (_) => setState(() => cat = e));
              }).toList(),
            ),
            const SizedBox(height: 12),
            const Text('وصف المنتج بالتفاصيل', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: descC, maxLines: 3, decoration: const InputDecoration(hintText: 'اكتب مواصفات المنتج هنا', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            const Text('لينك صورة المنتج', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: imgC, decoration: const InputDecoration(hintText: 'انسخ لينك الصورة من جوجل وحطه هنا', border: OutlineInputBorder())),
            const SizedBox(height: 8.0),
            const Text('لو مش عندك لينك، سيبه فاضي وهيظهر ايقونة مكان الصورة', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A00), padding: const EdgeInsets.all(15)),
                onPressed: () {
                  if (nameC.text.isEmpty || priceC.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اكتب الاسم والسعر الاول')));
                    return;
                  }
                  Store.i.addProduct({
                    'name': nameC.text,
                    'price': int.tryParse(priceC.text) ?? 0,
                    'rate': '5.0',
                    'cat': cat,
                    'tag': 'جديد',
                    'color': 0xFFD6EAF0,
                    'desc': descC.text,
                    'img': imgC.text,
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم اضافة المنتج في المتجر')));
                },
                child: const Text('حفظ المنتج', style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
