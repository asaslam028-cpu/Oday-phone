import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'firebase_options.dart';
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
 // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
 // await FirebaseMessaging.instance.requestPermission();
 // await FirebaseMessaging.instance.subscribeToTopic('admin');
 // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
   // debugPrint('New admin notification: ${message.notification?.title}');
//  });
  runApp(const OdayApp());
}

const String vodafoneNumber = '01015519180';
const String instapayNumber = '01069068091';
const String adminPassword = '291191';
const Color navyBg = Color(0xFF0A1931);
const Color navyCard = Color(0xFF13294B);
const Color navyDark = Color(0xFF071224);
const Color accentOrange = Color(0xFFFF7A00);
const Color accentBlue = Color(0xFF38BDF6);
const Color accentGreen = Color(0xFF22C55E);
String normalizePhone(String p) {
  String s = p.trim();
  if (s.startsWith('+20')) s = s.substring(3);
  else if (s.startsWith('0020')) s = s.substring(4);
  else if (s.startsWith('20') && s.length == 12) s = s.substring(2);
  if (s.startsWith('0')) s = s.substring(1);
  return s;
}
Future<String?> uploadImageToStorage(File file, String folder) async {
  try {
    const String cloudName = 'eggmsevw';
    const String preset = 'oday_phone';
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    var request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = preset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));
    var response = await request.send();
    var res = await http.Response.fromStream(response);
    if (res.statusCode == 200) {
      var data = json.decode(res.body);
      return data['secure_url'];
    } else {
      debugPrint('Upload error: ${res.body}');
      return null;
    }
  } catch (e) {
    debugPrint('Upload error: $e');
    return null;
  }
}

// === الإضافة الجديدة - رفع الفيديو ===
Future<String?> uploadVideoToStorage(File file) async {
  try {
    const String cloudName = 'eggmsevw';
    const String preset = 'oday_phone';
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/video/upload');
    var request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = preset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));
    var response = await request.send();
    var res = await http.Response.fromStream(response);
    if (res.statusCode == 200) {
      var data = json.decode(res.body);
      return data['secure_url'];
    } else {
      debugPrint('Video upload error: ${res.body}');
      return null;
    }
  } catch (e) {
    debugPrint('Video upload error: $e');
    return null;
  }
}
// === نهاية الإضافة ===

Widget buildImageWidget(String? path, {double? height, double? width, BoxFit fit = BoxFit.cover}) {
  if (path == null || path.isEmpty) {
    return Container(color: Colors.white12, child: const Icon(Icons.image, color: Colors.white54));
  }
  if (path.startsWith('http')) {
    return Image.network(path, height: height, width: width, fit: fit, errorBuilder: (c, e, s) => Container(color: Colors.white12, child: const Icon(Icons.broken_image, color: Colors.white54)));
  }
  return Image.file(File(path), height: height, width: width, fit: fit, errorBuilder: (c, e, s) => Container(color: Colors.white12, child: const Icon(Icons.broken_image, color: Colors.white54)));
}

class Product {
  String? id; String name; String desc; double price; double oldPrice; String category; bool isOffer; bool isFav; String? imagePath; String? iconName;
Product({this.id, required this.name, required this.desc, required this.price, this.oldPrice = 0, required this.category, this.isOffer = false, this.isFav = false, this.imagePath, this.iconName});
Map<String, dynamic> toJson() => {"id": id, "name": name, "desc": desc, "price": price, "oldPrice": oldPrice, "category": category, "isOffer": isOffer, "isFav": isFav, "imagePath": imagePath, "iconName": iconName};
factory Product.fromJson(Map<String, dynamic> j) => Product(id: j['id'], name: j['name'] ?? '', desc: j['desc'] ?? '', price: (j['price'] as num? ?? 0).toDouble(), oldPrice: (j['oldPrice'] as num? ?? 0).toDouble(), category: j['category'] ?? '', isOffer: j['isOffer'] ?? false, isFav: j['isFav'] ?? false, imagePath: j['imagePath'], iconName: j['iconName'] ?? 'phone');
static IconData getProductIcon(String name) {
  if (name == 'charge') return Icons.charging_station;
  if (name == 'head') return Icons.headphones;
  if (name == 'cable') return Icons.cable;
  return Icons.phone_android;
}  

} 
IconData getProductIcon(String name) => Product.getProductIcon(name);

class OrderItem {
  String name; int qty; double price;
  OrderItem({required this.name, required this.qty, required this.price});
  Map<String, dynamic> toJson() => {'name': name, 'qty': qty, 'price': price};
  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(name: j['name'] ?? '', qty: j['qty'] ?? 1, price: (j['price'] as num? ?? 0).toDouble());
}

class AppOrder {
  String id; String customerName; String phone; String address; String paymentMethod; String status; List<OrderItem> items; double total; String? proofPath; String date;
  AppOrder({required this.id, required this.customerName, required this.phone, required this.address, required this.paymentMethod, required this.status, required this.items, required this.total, this.proofPath, required this.date});
  Map<String, dynamic> toJson() => {'id': id, 'customerName': customerName, 'phone': phone, 'address': address, 'paymentMethod': paymentMethod, 'status': status, 'items': items.map((e) => e.toJson()).toList(), 'total': total, 'proofPath': proofPath, 'date': date};
  factory AppOrder.fromJson(Map<String, dynamic> j) => AppOrder(
    id: j['id'] ?? '',
    customerName: j['customerName'] ?? '',
    phone: j['phone'] ?? '',
    address: j['address'] ?? '',
    paymentMethod: j['paymentMethod'] ?? '',
    status: j['status'] ?? 'جديد',
    items: (j['items'] as List? ?? []).map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e))).toList(),
    total: (j['total'] as num? ?? 0).toDouble(),
    proofPath: j['proofPath'],
    date: j['date'] ?? '',
  );
}

class RepairRequest {
  String id; String customerName; String phone; String address; String phoneType; String problem; String kind; String date; String status;
  RepairRequest({required this.id, required this.customerName, required this.phone, required this.address, required this.phoneType, required this.problem, required this.kind, required this.date, this.status = 'جديد'});
  Map<String, dynamic> toJson() => {'id': id, 'customerName': customerName, 'phone': phone, 'address': address, 'phoneType': phoneType, 'problem': problem, 'kind': kind, 'date': date, 'status': status};
  factory RepairRequest.fromJson(Map<String, dynamic> j) => RepairRequest(
    id: j['id'] ?? '',
    customerName: j['customerName'] ?? '',
    phone: j['phone'] ?? '',
    address: j['address'] ?? '',
    phoneType: j['phoneType'] ?? '',
    problem: j['problem'] ?? '',
    kind: j['kind'] ?? 'مندوب صيانة موبايل',
    date: j['date'] ?? '',
    status: j['status'] ?? 'جديد',
  );
}

class OdayApp extends StatelessWidget {
  const OdayApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: navyBg,
        appBarTheme: const AppBarTheme(backgroundColor: navyDark, foregroundColor: Colors.white),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: navyDark, selectedItemColor: accentOrange, unselectedItemColor: Colors.grey),
        inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: navyCard, labelStyle: const TextStyle(color: Colors.white70), hintStyle: const TextStyle(color: Colors.white54), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white24))),
      ),
      home: const OdayHome(),
    );
  }
}

class OdayHome extends StatefulWidget {
  const OdayHome({super.key});
  @override
  State<OdayHome> createState() => _OdayHomeState();
}

class _OdayHomeState extends State<OdayHome> {
  bool showStart = true;
  int currentIndex = 0;
  String searchText = '';
  String storeCategory = 'الكل';
  int logoTaps = 0;
  // === الإضافة الجديدة - البانر 5 صور + الشريط + الفيديو ===
  String? myPhone;
  int heroIndex = 0;
  PageController _heroController = PageController();
  Timer? _heroTimer;
  String tickerText = 'التوصيل مجاني النهارده في الإسماعيلية • صيانة من البيت • كاش باك 10%';
  List<String> heroImages = [
    'https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?w=800',
    'https://images.unsplash.com/photo-1585060544812-6b45742d762f?w=800',
    'https://images.unsplash.com/photo-1600490722773-35753aea6332?w=800',
    'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=800',
    'https://images.unsplash.com/photo-1601524909162-ae8725290836?w=800',
  ];
  String heroVideoUrl = '';
  VideoPlayerController? _videoController;
  // === نهاية الإضافة ===
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
    _loadProductsFromFirebase();
    _listenSettings();
    // === الإضافة الجديدة - تشغيل التقليب التلقائي كل ثانيتين ===
    _heroTimer = Timer.periodic(
      const Duration(seconds: 2),
      (t) {
        if (!mounted || heroImages.isEmpty) return;
        if (showStart || currentIndex != 0) return;
        if (heroVideoUrl.isNotEmpty) return;
        heroIndex = (heroIndex + 1) % heroImages.length;
        if (_heroController.hasClients) {
          _heroController.animateToPage(
            heroIndex,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
        setState(() {});
      },
    );
    // === نهاية الإضافة ===
  }

  // === الإضافة الجديدة - قفل التايمر والفيديو ===
  @override
  void dispose() {
    _heroTimer?.cancel();
    _heroController.dispose();
    _videoController?.dispose();
    super.dispose();
  }
  // === نهاية الإضافة ===

  // === الإضافة الجديدة - تشغيل الفيديو ===
  Future<void> _initVideo(String url) async {
    if (url.isEmpty) return;
    await _videoController?.dispose();
    final c = VideoPlayerController.networkUrl(Uri.parse(url));
    _videoController = c;
    try {
      await c.initialize();
      await c.setVolume(0);
      await c.setLooping(true);
      await c.play();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Video error: $e');
    }
  }
  // === نهاية الإضافة ===

  Future<void> _loadProductsFromFirebase() async {
  FirebaseFirestore.instance.collection('products').snapshots().listen((snap) {
    if (!mounted) return;
    setState(() {
      products = snap.docs.map((d) => Product.fromJson(d.data())).toList();
    });
  }, onError: (e) {
    debugPrint('Products error: $e');
  });
}
void _listenSettings() {
  FirebaseFirestore.instance
      .collection('settings')
      .doc('home')
      .snapshots()
      .listen((doc) {
    if (!doc.exists) return;
    if (!mounted) return;
    final data = doc.data() as Map<String, dynamic>;
    setState(() {
      if (data['heroImages'] != null) {
        heroImages = List<String>.from(data['heroImages']);
      }
      if (data['tickerText'] != null) {
        tickerText = data['tickerText'].toString();
      }
      if (data['heroVideoUrl'] != null) {
        final newVideo = data['heroVideoUrl'].toString();
        if (newVideo != heroVideoUrl) {
          heroVideoUrl = newVideo;
          if (newVideo.isNotEmpty) _initVideo(newVideo);
        }
      }
    });
  });
}
  Future<void> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final pStr = prefs.getString('products');
      if (pStr != null) {
        products = (jsonDecode(pStr) as List).map((e) => Product.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      final oStr = prefs.getString('orders');
      if (oStr != null) {
        orders = (jsonDecode(oStr) as List).map((e) => AppOrder.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      final rStr = prefs.getString('repairs');
      if (rStr != null) {
        repairs = (jsonDecode(rStr) as List).map((e) => RepairRequest.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      final cStr = prefs.getString('cart');
      if (cStr != null) {
        cart = (jsonDecode(cStr) as List).map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      // === الإضافة الجديدة - تحميل صور البانر وكلام الشريط والفيديو ==
        myPhone = prefs.getString('myPhone');
    });
    // === الإضافة الجديدة - لو فيه فيديو محفوظ شغله ===
    if (heroVideoUrl.isNotEmpty) {
      _initVideo(heroVideoUrl);
    }
    // === نهاية الإضافة ===
  }

  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cart', jsonEncode(cart.map((e) => e.toJson()).toList()));
    // === الإضافة الجديدة - حفظ صور البانر وكلام الشريط والفيديو ===
    await prefs.setString('myPhone', myPhone ?? '');
    // === نهاية الإضافة ===
  }

Future<void> _saveOrderToFirebase(AppOrder o) async {
  try {
    final data = o.toJson();
    data['phoneNorm'] = normalizePhone(o.phone);
    data['time'] = FieldValue.serverTimestamp();
    await FirebaseFirestore.instance.collection('orders').add(data);
  } catch (e) {
    debugPrint('Order firebase error: $e');
  }
}

  Future<void> _saveRepairToFirebase(RepairRequest r) async {
    try {
      final data = r.toJson();
data['time'] = FieldValue.serverTimestamp();
data['phoneNorm'] = normalizePhone(r.phone);
await FirebaseFirestore.instance.collection('repairs').add(data);
    } catch (e) {
      debugPrint('Repair firebase error: $e');
    }
  }

  Future<void> _saveProductToFirebase(Product p) async {
    try {
      await FirebaseFirestore.instance.collection('products').add(p.toJson());
    } catch (e) {
      debugPrint('Product firebase error: $e');
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

  void _openRepairPage(String kind) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => RepairPage(
          kind: kind,
          onSubmit: (r) async {
            setState(() {
              repairs.add(r);
              _saveAll();
            });
            await _saveRepairToFirebase(r);
          },
        ),
      ),
    );
  }

  void _onLogoTap() {
    logoTaps = logoTaps + 1;
    if (logoTaps >= 5) {
      logoTaps = 0;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => AdminLoginPage(
            onSuccess: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx2) => AdminDashboard(
                    products: products,
                    orders: orders,
                    repairs: repairs,
                    heroImages: heroImages,
                    tickerText: tickerText,
                    heroVideoUrl: heroVideoUrl,
                    onUpdateHeroImages: (imgs) {
                      setState(() {
                        heroImages = imgs;
                        _saveAll();
                      });
                      FirebaseFirestore.instance.collection('settings').doc('home').set(
                        {'heroImages': imgs},
                        SetOptions(merge: true),
                      );
                    },
                    onUpdateTicker: (t) {
                      setState(() {
                        tickerText = t;
                        _saveAll();
                      });
                      FirebaseFirestore.instance.collection('settings').doc('home').set(
                        {'tickerText': t},
                        SetOptions(merge: true),
                      );
                    },
                    onUpdateHeroVideo: (v) {
                      setState(() {
                        heroVideoUrl = v;
                        _saveAll();
                      });
                      FirebaseFirestore.instance.collection('settings').doc('home').set(
                        {'heroVideoUrl': v},
                        SetOptions(merge: true),
                      );
                    },
                    onAddProduct: (p) async {
                      await FirebaseFirestore.instance.collection('products').add(p.toJson());
                    },
                    onUpdateProduct: (i, p) async {
                      await FirebaseFirestore.instance.collection('products').doc(p.id).update(p.toJson());
                    },
                    onDeleteProduct: (id) async {
                      await FirebaseFirestore.instance.collection('products').doc(id.toString()).delete();
                    },
                    onUpdateOrderStatus: (i, s) {
                      setState(() {
                        orders[i].status = s;
                        _saveAll();
                      });
                    },
                    onDeleteOrder: (i) {
                      setState(() {
                        orders.removeAt(i);
                        _saveAll();
                      });
                    },
                    onUpdateRepairStatus: (i, s) {
                      setState(() {
                        repairs[i].status = s;
                        _saveAll();
                      });
                    },
                    onDeleteRepair: (i) {
                      setState(() {
                        repairs.removeAt(i);
                        _saveAll();
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (showStart) return _buildStartPage();
    return _buildMainPage();
  }

  Widget _buildStartPage() {
    return Scaffold(
      backgroundColor: navyBg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _onLogoTap,
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
    );
  }

  Widget _buildMainPage() {
    return Scaffold(
      backgroundColor: navyBg,
      appBar: AppBar(
        backgroundColor: navyDark,
        title: const Text('عدي فون', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
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
    );
  }

  Widget _buildBody() {
    if (currentIndex == 1) return _buildStore();
    if (currentIndex == 2) return _buildCart();
    if (currentIndex == 3) return _buildMyOrders();
    return _buildHome();
  }

  // === الإضافة الجديدة - البانر بقى فيديو أو 5 صور ===
  Widget _buildHeroBanner() {
    // لو فيه فيديو، شغل الفيديو
    if (heroVideoUrl.isNotEmpty) {
      return Column(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  if (_videoController != null && _videoController!.value.isInitialized)
                    SizedBox(
                      width: double.infinity,
                      height: 180,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _videoController!.value.size.width,
                          height: _videoController!.value.size.height,
                          child: VideoPlayer(_videoController!),
                        ),
                      ),
                    )
                  else
                    Container(
                      color: navyCard,
                      child: const Center(child: CircularProgressIndicator(color: accentOrange)),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'عروض عدي فون 🔥',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: accentOrange),
                          onPressed: () => setState(() => currentIndex = 1),
                          child: const Text('اطلب دلوقتي', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    // لو مفيش فيديو، شغل الـ 5 صور زي ما كان
    if (heroImages.isEmpty) {
      return const SizedBox();
    }
    return Column(
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: PageView.builder(
              controller: _heroController,
              itemCount: heroImages.length,
              onPageChanged: (i) => setState(() => heroIndex = i),
              itemBuilder: (ctx, i) {
                return Stack(
                  children: [
                    Image.network(
                      heroImages[i],
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: navyCard,
                        child: const Icon(Icons.image, color: Colors.white54),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'عروض عدي فون 🔥',
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: accentOrange),
                            onPressed: () => setState(() => currentIndex = 1),
                            child: const Text('اطلب دلوقتي', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(heroImages.length, (i) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: heroIndex == i ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(color: heroIndex == i ? accentOrange : Colors.white30, borderRadius: BorderRadius.circular(10)),
          )),
        ),
      ],
    );
  }

  Widget _buildTicker() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(color: accentOrange.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: accentOrange.withOpacity(0.4))),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department, color: accentOrange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tickerText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
  // === نهاية الإضافة ===

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
          // === الإضافة هنا بس ===
          _buildHeroBanner(),
          const SizedBox(height: 12),
          _buildTicker(),
          // === نهاية الإضافة ===
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: navyCard, padding: const EdgeInsets.all(20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: accentOrange))),
              onPressed: () => setState(() => currentIndex = 1),
              child: Row(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: accentOrange, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.store, color: Colors.white, size: 30)), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('المتجر', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)), Text('جرابات وشواحن وسماعات وسكرينات', style: TextStyle(color: Colors.white70))])), const Icon(Icons.arrow_forward_ios, size: 17, color: Colors.white70)]),
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
                    onPressed: () => _openRepairPage('مندوب صيانة موبايل'),
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
            onPressed: () => _openRepairPage(kind),
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
                    child: buildImageWidget(p.imagePath, height: 140, width: double.infinity),
                  )
                : Icon(getProductIcon(p.iconName ?? "phone"), size: 50, color: accentBlue),
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
    bool isUploading = false;
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
                  child: Column(children: [Row(children: [Expanded(child: Text('حول على: ${method == 'فودافون كاش' ? vodafoneNumber : instapayNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white))), IconButton(icon: const Icon(Icons.copy, color: Colors.white), onPressed: () { Clipboard.setData(ClipboardData(text: method == 'فودافون كاش' ? vodafoneNumber : instapayNumber)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ الرقم'))); })]), const SizedBox(height: 10), ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: accentOrange), onPressed: () async { final picker = ImagePicker(); final x = await picker.pickImage(source: ImageSource.gallery); if (x != null) { setLocal(() => proofPath = x.path); } }, icon: const Icon(Icons.upload, color: Colors.white), label: Text(proofPath == null ? 'ارفع صورة التحويل' : 'تم رفع الصورة', style: const TextStyle(color: Colors.white))), if (proofPath != null) Padding(padding: const EdgeInsets.only(top: 10), child: buildImageWidget(proofPath, height: 120))]),
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
                    setLocal(() => isUploading = true);
                    String? finalProof = proofPath;
                    if (proofPath != null && !proofPath!.startsWith('http')) {
                      final url = await uploadImageToStorage(File(proofPath!), 'proofs');
                      if (url != null) finalProof = url;
                    }
                    setLocal(() => isUploading = false);
                    final newOrder = AppOrder(id: DateTime.now().millisecondsSinceEpoch.toString(), customerName: nameC.text, phone: phoneC.text, address: addrC.text, paymentMethod: method, status: 'جديد', items: List.from(cart), total: cartTotal, proofPath: finalProof, date: DateTime.now().toString().substring(0, 10));
            myPhone = phoneC.text.trim();
            setState(() {
             orders.add(newOrder);
             cart.clear();
             _saveAll();
             currentIndex = 3;
});
await _saveOrderToFirebase(newOrder);
                    },
                  child: isUploading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white)) : const Text('تأكيد الطلب', style: TextStyle(color: Colors.white, fontSize: 17)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyOrders() {
  if (myPhone == null || myPhone!.isEmpty) {
    final c = TextEditingController();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('اكتب رقمك عشان تشوف طلباتك', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: c, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'رقم الموبايل')),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: accentOrange), onPressed: () async { if (c.text.trim().isEmpty) return; myPhone = c.text.trim(); await _saveAll(); setState(() {}); }, child: const Text('عرض طلباتي', style: TextStyle(color: Colors.white)))),
          ],
        ),
      ),
    );
  }
  final myNorm = normalizePhone(myPhone!);
  return Column(
    children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: Row(children: [Expanded(child: Text('طلباتي - $myPhone', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), TextButton(onPressed: () async { myPhone = null; await _saveAll(); setState(() {}); }, child: const Text('تغيير الرقم', style: TextStyle(color: accentOrange)))])),
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('orders').orderBy('time', descending: true).snapshots(),
          builder: (context, snap) {
            if (snap.hasError) return Center(child: Text('خطأ: ${snap.error}', style: const TextStyle(color: Colors.white)));
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final docs = snap.data!.docs.where((d) { final data = d.data() as Map<String, dynamic>; final pn = (data['phoneNorm'] ?? normalizePhone('${data['phone'] ?? ''}')).toString(); return pn == myNorm; }).toList();
            if (docs.isEmpty) return const Center(child: Text('لا يوجد طلبات بعد', style: const TextStyle(color: Colors.white)));
            return ListView(padding: const EdgeInsets.all(16), children: docs.map((d) { final data = d.data() as Map<String, dynamic>; final items = (data['items'] as List? ?? []).map((e) => '${e['name'] ?? ''} x${e['qty'] ?? ''}').join(', '); return Card(color: navyCard, child: ListTile(title: Text('${data['customerName'] ?? ''} - ${data['phone'] ?? ''}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), subtitle: Text('📍 ${data['address'] ?? ''}\n🛒 $items\nالاجمالي: ${data['total'] ?? ''} ج - ${data['paymentMethod'] ?? ''}\nالحالة: ${data['status'] ?? 'جديد'}', style: const TextStyle(color: Colors.white70)), isThreeLine: true)); }).toList());
          },
        ),
      ),
    ],
  );
}
}
class RepairPage extends StatefulWidget {
  final String kind;
  final Function(RepairRequest) onSubmit;
  const RepairPage({super.key, required this.kind, required this.onSubmit});
  @override
  State<RepairPage> createState() => _RepairPageState();
}

class _RepairPageState extends State<RepairPage> {
  final nameC = TextEditingController();
  final phoneC = TextEditingController();
  final addrC = TextEditingController();
  final typeC = TextEditingController();
  final probC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isPhone = widget.kind == 'مندوب صيانة موبايل';
    return Scaffold(
      backgroundColor: navyBg,
      appBar: AppBar(backgroundColor: navyDark, title: Text(isPhone ? 'اطلب مندوب لصيانة تليفونك' : 'طلب ${widget.kind}', style: const TextStyle(color: Colors.white))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPhone) const Text('هنبعتلك مندوب ياخد التليفون من عندك، نصلحه، ونرجعهولك تاني لحد البيت', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            TextField(controller: nameC, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'اسم العميل', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: phoneC, keyboardType: TextInputType.phone, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'رقم التليفون', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: addrC, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'العنوان', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            if (isPhone) ...[TextField(controller: typeC, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'نوع التليفون - مثال: سامسونج، ايفون', border: OutlineInputBorder())), const SizedBox(height: 10)],
            TextField(controller: probC, maxLines: 3, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: isPhone ? 'ايه المشكلة في التليفون؟' : 'ايه الشغل المطلوب؟', border: const OutlineInputBorder())),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: accentOrange, padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () {
                  if (nameC.text.isEmpty || phoneC.text.isEmpty || addrC.text.isEmpty || probC.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('كمل بياناتك الاول')));
                    return;
                  }
                  final r = RepairRequest(id: DateTime.now().millisecondsSinceEpoch.toString(), customerName: nameC.text, phone: phoneC.text, address: addrC.text, phoneType: typeC.text, problem: probC.text, kind: widget.kind, date: DateTime.now().toString().substring(0, 10));
                  widget.onSubmit(r);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم استلام طلبك وهنكلمك نحدد معاد المندوب')));
                },
                child: const Text('ارسال الطلب', style: TextStyle(color: Colors.white, fontSize: 17)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminLoginPage extends StatefulWidget {
  final VoidCallback onSuccess;
  const AdminLoginPage({super.key, required this.onSuccess});
  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final passC = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navyBg,
      appBar: AppBar(backgroundColor: navyDark, title: const Text('دخول الادمن', style: TextStyle(color: Colors.white))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.lock, size: 70, color: accentOrange),
            const SizedBox(height: 20),
            TextField(controller: passC, keyboardType: TextInputType.number, obscureText: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'كلمة السر', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: accentOrange, padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () {
                  if (passC.text.trim() == adminPassword) {
                    widget.onSuccess();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('كلمة السر غلط')));
                  }
                },
                child: const Text('دخول', style: TextStyle(color: Colors.white, fontSize: 17)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  final List<Product> products;
  final List<AppOrder> orders;
  final List<RepairRequest> repairs;
  // === الإضافة الجديدة ===
  final List<String> heroImages;
  final String tickerText;
  final String heroVideoUrl;
  final Function(List<String>) onUpdateHeroImages;
  final Function(String) onUpdateTicker;
  final Function(String) onUpdateHeroVideo;
  // === نهاية الإضافة ===
  final Function(Product) onAddProduct;
  final Function(int, Product) onUpdateProduct;
  final Function(int) onDeleteProduct;
  final Function(int, String) onUpdateOrderStatus;
  final Function(int) onDeleteOrder;
  final Function(int, String) onUpdateRepairStatus;
  final Function(int) onDeleteRepair;
  const AdminDashboard({super.key, required this.products, required this.orders, required this.repairs, required this.heroImages, required this.tickerText, required this.heroVideoUrl, required this.onUpdateHeroImages, required this.onUpdateTicker, required this.onUpdateHeroVideo, required this.onAddProduct, required this.onUpdateProduct, required this.onDeleteProduct, required this.onUpdateOrderStatus, required this.onDeleteOrder, required this.onUpdateRepairStatus, required this.onDeleteRepair});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int tab = 0;
  // === الإضافة الجديدة ===
  late TextEditingController tickerC;
  bool isUploadingHero = false;
  bool isUploadingVideo = false;
  @override
  void initState() {
    super.initState();
    tickerC = TextEditingController(text: widget.tickerText);
  }
  // === نهاية الإضافة ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navyBg,
      appBar: AppBar(backgroundColor: navyDark, title: const Text('لوحة تحكم الادمن', style: TextStyle(color: Colors.white))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: _adminStat('منتجات', '${widget.products.length}')),
                const SizedBox(width: 10),
                Expanded(child: _adminStat('طلبات', '${widget.orders.length}')),
                const SizedBox(width: 10),
                Expanded(child: _adminStat('خدمات', '${widget.repairs.length}')),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(child: _adminTabButton('المنتجات', 0)),
              Expanded(child: _adminTabButton('الطلبات', 1)),
              Expanded(child: _adminTabButton('الخدمات', 2)),
              // === الإضافة الجديدة - زرار التاب الرابع ===
              Expanded(child: _adminTabButton('البانر والشريط', 3)),
              // === نهاية الإضافة ===
            ],
          ),
          const SizedBox(height: 10),
          Expanded(child: tab == 0 ? _productsTab() : tab == 1 ? _ordersTab() : tab == 2 ? _repairsTab() : _bannerTab()),
        ],
      ),
      floatingActionButton: tab == 0
          ? FloatingActionButton(
              backgroundColor: accentOrange,
              onPressed: () async {
                final p = await Navigator.of(context).push<Product>(MaterialPageRoute(builder: (ctx) => const AdminProductForm()));
                if (p != null) {
                  widget.onAddProduct(p);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم اضافة المنتج')));
                }
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _adminStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: navyCard, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(color: Colors.white70))]),
    );
  }

  Widget _adminTabButton(String label, int index) {
    final sel = tab == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: sel ? accentOrange : navyCard),
        onPressed: () => setState(() => tab = index),
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  // === الإضافة الجديدة - تاب البانر والشريط كله + زرار الفيديو ===
  Widget _bannerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- قسم الفيديو ---
          const Text(
            'فيديو البانر',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            widget.heroVideoUrl.isEmpty ? 'مفيش فيديو دلوقتي - شغال بالصور' : 'فيه فيديو شغال دلوقتي',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: accentBlue, padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () async {
                final picker = ImagePicker();
                final x = await picker.pickVideo(source: ImageSource.gallery);
                if (x == null) return;
                setState(() => isUploadingVideo = true);
                final url = await uploadVideoToStorage(File(x.path));
                setState(() => isUploadingVideo = false);
                if (url != null) {
                  await widget.onUpdateHeroVideo(url);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم اضافة فيديو البانر')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('فشل رفع الفيديو - جرب تاني')),
                  );
                }
              },
              icon: const Icon(Icons.video_library, color: Colors.white),
              label: isUploadingVideo
                  ? const Text('جاري رفع الفيديو... استنى شوية', style: TextStyle(color: Colors.white))
                  : const Text('اختار فيديو جديد', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 10),
          if (widget.heroVideoUrl.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 12)),
                onPressed: () async {
                  await widget.onUpdateHeroVideo('');
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم مسح الفيديو ورجعنا للصور')),
                  );
                },
                icon: const Icon(Icons.delete, color: Colors.white),
                label: const Text('امسح الفيديو وارجع للصور', style: TextStyle(color: Colors.white)),
              ),
            ),
          const SizedBox(height: 24),
          // --- قسم الشريط ---
          const Text(
            'كلام الشريط الرفيع',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: tickerC,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'اكتب العرض بتاع النهارده...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: accentOrange, padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () {
                widget.onUpdateTicker(tickerC.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حفظ كلام الشريط')),
                );
              },
              child: const Text('حفظ كلام الشريط', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'صور البانر المتحرك - 5 صور',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'الصور دي بتشتغل بس لو مفيش فيديو.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 10),
          ...widget.heroImages.asMap().entries.map((e) {
            final idx = e.key;
            final img = e.value;
            return Card(
              color: navyCard,
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: buildImageWidget(img, width: 60, height: 60),
                ),
                title: Text('صورة رقم ${idx + 1}', style: const TextStyle(color: Colors.white)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    final list = List<String>.from(widget.heroImages);
                    list.removeAt(idx);
                    widget.onUpdateHeroImages(list);
                    setState(() {});
                  },
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: accentGreen, padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () async {
                final picker = ImagePicker();
                final x = await picker.pickImage(source: ImageSource.gallery);
                if (x == null) return;
                setState(() => isUploadingHero = true);
                final url = await uploadImageToStorage(File(x.path), 'hero');
                setState(() => isUploadingHero = false);
                if (url != null) {
                  final list = List<String>.from(widget.heroImages);
                  if (list.length >= 5) {
                    list.removeAt(0);
                  }
                  list.add(url);
                  widget.onUpdateHeroImages(list);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم اضافة الصورة للبانر')),
                  );
                }
              },
              icon: const Icon(Icons.add_a_photo, color: Colors.white),
              label: isUploadingHero
                  ? const Text('جاري الرفع...', style: TextStyle(color: Colors.white))
                  : const Text('اضف صورة جديدة للبانر', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'لو عندك 5 صور وضفت واحدة جديدة، أول صورة قديمة هتتمسح لوحدها.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
  // === نهاية الإضافة ===

 Widget _productsTab() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('products').snapshots(),
    builder: (context, snap) {
      if (snap.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (!snap.hasData || snap.data!.docs.isEmpty) {
        return const Center(
          child: Text('مفيش منتجات',
              style: TextStyle(color: Colors.white)),
        );
      }
      final docs = snap.data!.docs;
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: docs.length,
        itemBuilder: (ctx, i) {
          final doc = docs[i];
          final data = doc.data() as Map<String, dynamic>;
          final p = Product.fromJson(Map<String, dynamic>.from(data));
          return Card(
            color: navyCard,
            child: ListTile(
              leading: p.imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: buildImageWidget(p.imagePath,
                          width: 50, height: 50))
                  : Container(
                      width: 50,
                      height: 50, 
                      decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(10)),
                      child: Icon(getProductIcon(p.iconName ?? "phone")),
                          color: accentBlue)),
              title: Text(p.name,
                  style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                  '${p.price} ج - ${p.category} - ${p.isOffer ? 'عرض' : 'عادي'}',
                  style: const TextStyle(color: Colors.white70)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () async {
                      final updated = await Navigator.of(context).push<Product>(
                          MaterialPageRoute(
                              builder: (ctx2) =>
                                  AdminProductForm(existing: p)));
                      if (updated != null) {
                        await FirebaseFirestore.instance
                            .collection('products')
                            .doc(doc.id)
                            .update(updated.toJson());
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('products')
                          .doc(doc.id)
                          .delete();
                    },
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

  Widget _ordersTab() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('orders').orderBy('time', descending: true).snapshots(),
    builder: (context, snap) {
      if (snap.hasError) return Center(child: Text('خطأ: ${snap.error}', style: const TextStyle(color: Colors.white)));
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      if (snap.data!.docs.isEmpty) return const Center(child: Text('مفيش طلبات', style: const TextStyle(color: Colors.white)));
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: snap.data!.docs.length,
        itemBuilder: (ctx, i) {
          final doc = snap.data!.docs[i];
          final data = doc.data() as Map<String, dynamic>;
          final o = AppOrder.fromJson(Map<String, dynamic>.from(data));
          final status = (data['status'] ?? o.status).toString();
          return Card(
            color: navyCard,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${o.customerName} - ${o.phone}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('${o.address} - ${o.date}', style: const TextStyle(color: Colors.white70)),
                  Text(o.items.map((e) => '${e.name} x${e.qty}').join(', '), style: const TextStyle(color: Colors.white70)),
                  Text('الاجمالي: ${o.total} ج - ${o.paymentMethod}', style: const TextStyle(color: accentOrange)),
                  if (o.proofPath != null) Padding(padding: const EdgeInsets.only(top: 10), child: buildImageWidget(o.proofPath, height: 120)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          value: ['جديد', 'قيد التنفيذ', 'تم التوصيل', 'ملغي'].contains(status) ? status : 'جديد',
                          dropdownColor: navyCard,
                          style: const TextStyle(color: Colors.white),
                          isExpanded: true,
                          items: ['جديد', 'قيد التنفيذ', 'تم التوصيل', 'ملغي'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (v) async { if (v != null) { await doc.reference.update({'status': v}); } },
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async { await doc.reference.delete(); }),
                    ],
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

  Widget _repairsTab() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('repairs')
        .orderBy('time', descending: true)
        .snapshots(),
    builder: (context, snap) {
      if (snap.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (!snap.hasData || snap.data!.docs.isEmpty) {
        return const Center(
          child: Text('لا توجد طلبات خدمات حالياً',
              style: TextStyle(color: Colors.white70)),
        );
      }
      final docs = snap.data!.docs;
      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: docs.length,
        itemBuilder: (context, i) {
          final doc = docs[i];
          final data = doc.data() as Map<String, dynamic>;
          final r = RepairRequest.fromJson(data);
          return Card(
            color: navyCard,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${r.kind} - ${r.customerName}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text('📞 ${r.phone}',
                      style: const TextStyle(color: Colors.white70)),
                  Text('📍 ${r.address}',
                      style: const TextStyle(color: Colors.white70)),
                  Text('📱 ${r.phoneType}',
                      style: const TextStyle(color: Colors.white70)),
                  Text('🛠 ${r.problem}',
                      style: const TextStyle(color: Colors.white70)),
                  Text('📅 ${r.date}',
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      DropdownButton<String>(
                        value: r.status,
                        dropdownColor: navyCard,
                        style: const TextStyle(color: Colors.white),
                        items: const [
                          DropdownMenuItem(value: 'جديد', child: Text('جديد')),
                          DropdownMenuItem(value: 'قيد التنفيذ', child: Text('قيد التنفيذ')),
                          DropdownMenuItem(value: 'تم', child: Text('تم')),
                          DropdownMenuItem(value: 'ملغي', child: Text('ملغي')),
                        ],
                        onChanged: (v) async {
                          if (v == null) return;
                          await FirebaseFirestore.instance
                              .collection('repairs')
                              .doc(doc.id)
                              .update({'status': v});
                        },
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('repairs')
                              .doc(doc.id)
                              .delete();
                        },
                      ),
                    ],
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
                  }
                  
class AdminProductForm extends StatefulWidget {
  final Product? existing;
  const AdminProductForm({super.key, this.existing});
  @override
  State<AdminProductForm> createState() => _AdminProductFormState();
}

class _AdminProductFormState extends State<AdminProductForm> {
  late TextEditingController nameC;
  late TextEditingController descC;
  late TextEditingController priceC;
  late TextEditingController oldPriceC;
  String category = 'جرابات';
  bool isOffer = false;
  String? imagePath;
  bool isSaving = false;
  final cats = ['جرابات', 'شواحن', 'سماعات', 'سكرينات', 'اكسسوارات'];

  @override
  void initState() {
    super.initState();
    nameC = TextEditingController(text: widget.existing?.name ?? '');
    descC = TextEditingController(text: widget.existing?.desc ?? '');
    priceC = TextEditingController(text: widget.existing != null ? '${widget.existing!.price}' : '');
    oldPriceC = TextEditingController(text: widget.existing != null ? '${widget.existing!.oldPrice}' : '');
    category = widget.existing?.category ?? 'جرابات';
    isOffer = widget.existing?.isOffer ?? false;
    imagePath = widget.existing?.imagePath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navyBg,
      appBar: AppBar(backgroundColor: navyDark, title: Text(widget.existing == null ? 'اضافة منتج جديد' : 'تعديل منتج', style: const TextStyle(color: Colors.white))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                final picker = ImagePicker();
                final x = await picker.pickImage(source: ImageSource.gallery);
                if (x != null) setState(() => imagePath = x.path);
              },
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(color: navyCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white24)),
                child: imagePath != null
                    ? ClipRRect(borderRadius: BorderRadius.circular(16), child: buildImageWidget(imagePath, height: 180, width: double.infinity))
                    : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 50, color: Colors.white70), SizedBox(height: 10), Text('دوس هنا واختار صورة المنتج', style: TextStyle(color: Colors.white))]),
              ),
            ),
            const SizedBox(height: 16),
            TextField(controller: nameC, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'اسم المنتج', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: descC, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'وصف المنتج', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: priceC, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'السعر', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: oldPriceC, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'السعر القديم قبل العرض', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: category,
              dropdownColor: navyCard,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'القسم', border: OutlineInputBorder()),
              items: cats.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(color: Colors.white)))).toList(),
              onChanged: (v) => setState(() => category = v ?? 'جرابات'),
            ),
            SwitchListTile(value: isOffer, activeColor: accentOrange, title: const Text('منتج عرض؟', style: TextStyle(color: Colors.white)), onChanged: (v) => setState(() => isOffer = v)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: accentOrange, padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () async {
                  if (nameC.text.isEmpty || priceC.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اكتب الاسم والسعر الاول')));
                    return;
                  }
                  setState(() => isSaving = true);
                  String? finalImage = imagePath;
                  if (imagePath != null && !imagePath!.startsWith('http')) {
                    final url = await uploadImageToStorage(File(imagePath!), 'products');
                    if (url != null) finalImage = url;
                  }
                  setState(() => isSaving = false);
                  final p = Product(
                    name: nameC.text,
                    desc: descC.text,
                    price: double.tryParse(priceC.text) ?? 0,
                    oldPrice: double.tryParse(oldPriceC.text) ?? 0,
                    category: category,
                    isOffer: isOffer,
                    isFav: widget.existing?.isFav ?? false,
                    imagePath: finalImage,
                    iconName: widget.existing?.iconName ?? 'phone',
                  );
                  Navigator.of(context).pop(p);
                },
                child: isSaving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white)) : const Text('حفظ المنتج', style: TextStyle(color: Colors.white, fontSize: 17)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
