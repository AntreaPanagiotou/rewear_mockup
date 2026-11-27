// ReWear the Unexpected — V2 (HW2: Mockup V2)
// Run on Windows / VS Code (PowerShell), inside the folder that contains pubspec.yaml:
//    C:\src\flutter\bin\flutter.bat pub get
//    C:\src\flutter\bin\flutter.bat run -d edge
// Phone preview in Edge: F12, then Ctrl+Shift+M. While running: r = hot reload, R = hot restart.
//
// V2 changes (see REPORT.md in the repository root):
//  - object categories + 3-column grid (less scrolling)
//  - accent-insensitive search (Greek tonos), searches both languages
//  - step-by-step instructions with time estimate for every idea
//  - before → after illustrations for every idea
//  - suggested ideas on the home screen
//  - occasion/style options limited to what exists for the chosen object,
//    plus matching ideas from other objects in the results
//  - saved ideas persist between sessions, full Greek translation, fixed back navigation

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const ReWearApp());

const ink = Color(0xFF262127);
const muted = Color(0xFF786E77);
const plum = Color(0xFF6D3E59);
const line = Color(0xFFEDE3E6);
const blush = Color(0xFFFFE7E9);
const cream = Color(0xFFFFF9F4);
const lavender = Color(0xFFEAE4F4);

const uiLabels = <String, List<String>>{
  'ui.infoTitle': ["Τι είναι το ReWear;", "What is ReWear?"],
  'ui.infoIntro': ["Μεταμόρφωσε αντικείμενα που ήδη έχεις σε απρόσμενα αξεσουάρ. Διάλεξε αντικείμενο, περίσταση και στυλ και ανακάλυψε ιδέες!", "Turn objects you already own into unexpected accessories. Choose an object, occasion and style to discover new ideas."],
  'ui.infoDisclaimer': ["Αυτή είναι η δεύτερη έκδοση (V2) του διαδραστικού mockup. Οι προτάσεις προέρχονται από συνθετικό dataset και οι εικόνες είναι σχηματικές εικονογραφήσεις. Δεν υπάρχει ακόμη εκπαιδευμένο recommender ή αναγνώριση εικόνας.", "This is the second version (V2) of the interactive mockup. Suggestions come from a synthetic dataset and the pictures are schematic illustrations. No trained recommender or image recognition is implemented yet."],
  'ui.whatsNew': ["Νέο στο V2: κατηγορίες αντικειμένων, βήμα-βήμα οδηγίες, εικονογραφήσεις, προτεινόμενες ιδέες και αποθήκευση αγαπημένων.", "New in V2: object categories, step-by-step instructions, illustrations, suggested ideas and saved favourites that persist."],
  'ui.ok': ["Κατάλαβα!", "Got it"],
  'ui.savedTooltip': ["Αποθηκευμένα", "Saved"],
  'ui.infoTooltip': ["Πληροφορίες", "About"],
  'ui.heroTag': ["ΔΕΣ ΤΑ ΚΑΘΗΜΕΡΙΝΑ ΑΛΛΙΩΣ", "REIMAGINE THE EVERYDAY"],
  'ui.heroTitle': ["Καθημερινά πράγματα.\nΜια νέα ματιά.", "Ordinary things.\nA new point of view."],
  'ui.heroSub': ["Μικρές μεταμορφώσεις, μεγάλη φαντασία.\nΔες τα αντικείμενά σου αλλιώς.", "Small transformations, big imagination.\nSee your everyday objects differently."],
  'ui.before': ["ΠΡΙΝ", "BEFORE"],
  'ui.after': ["ΜΕΤΑ", "AFTER"],
  'ui.discover': ["Ανακάλυψε ιδέες", "Discover ideas"],
  'ui.random': ["Επίλεξε τυχαίο αντικείμενο", "Surprise me with an object"],
  'ui.suggested': ["Προτεινόμενες ιδέες", "Suggested ideas"],
  'ui.suggestedSub': ["Μια εύκολη ιδέα από κάθε κατηγορία — αλλάζουν κάθε μέρα.", "One easy idea from each category — refreshed daily."],
  'ui.step1': ["01  /  ΕΠΙΛΟΓΗ ΑΝΤΙΚΕΙΜΕΝΟΥ", "01  /  CHOOSE AN OBJECT"],
  'ui.pickTitle': ["Τι έχεις διαθέσιμο;", "What do you have?"],
  'ui.pickSub': ["Διάλεξε κατηγορία ή αναζήτησε ένα συνηθισμένο αντικείμενο.", "Pick a category or search for an ordinary object."],
  'ui.search': ["Αναζήτησε αντικείμενο…", "Search objects…"],
  'ui.noObject': ["Δεν βρέθηκε αντικείμενο.", "No objects found."],
  'ui.all': ["Όλα", "All"],
  'ui.step2': ["02  /  ΠΡΟΣΑΡΜΟΓΗ", "02  /  PERSONALIZE"],
  'ui.customTitle': ["Στα μέτρα σου.", "Make it yours."],
  'ui.customSub': ["Βλέπεις μόνο τις επιλογές που έχουν ιδέες για αυτό το αντικείμενο.", "You only see options that have ideas for this object."],
  'ui.yourObject': ["ΤΟ ΑΝΤΙΚΕΙΜΕΝΟ ΣΟΥ", "YOUR OBJECT"],
  'ui.change': ["Αλλαγή", "Change"],
  'ui.occasionQuestion': ["Ποια είναι η περίσταση;", "What’s the occasion?"],
  'ui.styleQuestion': ["Ποιο είναι το στυλ σου;", "What’s your style?"],
  'ui.showIdeas': ["Δείξε μου ιδέες", "Show ideas"],
  'ui.both': ["Ιδανικό για την περίσταση και το στυλ σου", "Matches your occasion and style"],
  'ui.occasionMatch': ["Ταιριάζει στην περίσταση", "Matches your occasion"],
  'ui.styleMatch': ["Ταιριάζει στο στυλ", "Matches your style"],
  'ui.alternative': ["Εναλλακτική ιδέα για σένα", "An alternative idea for you"],
  'ui.saveTooltip': ["Αποθήκευση", "Save idea"],
  'ui.idea': ["ΙΔΕΑ", "IDEA"],
  'ui.step3': ["03  /  ΟΙ ΠΡΟΤΑΣΕΙΣ ΣΟΥ", "03  /  YOUR IDEAS"],
  'ui.resultsTitle': ["Οι ιδέες σου.", "Your rewear edit."],
  'ui.resultsNote': ["Πρώτα εμφανίζονται οι ιδέες που ταιριάζουν στις επιλογές σου.", "Ideas that match your choices are shown first."],
  'ui.more': ["Περισσότερες ιδέες με άλλα αντικείμενα", "More ideas with other objects"],
  'ui.adjust': ["Άλλαξε περίσταση / στυλ", "Change occasion / style"],
  'ui.another': ["Δοκίμασε άλλο αντικείμενο", "Try another object"],
  'ui.collection': ["ΣΥΛΛΟΓΗ", "COLLECTION"],
  'ui.favorites': ["Οι αγαπημένες σου.", "Your favorites."],
  'ui.noSaved': ["Δεν έχεις αποθηκεύσει ιδέες ακόμη.", "You haven’t saved any ideas yet."],
  'ui.findIdeas': ["Βρες ιδέες", "Explore ideas"],
  'ui.from': ["Από:", "From:"],
  'ui.easy': ["Εύκολο", "Easy"],
  'ui.medium': ["Μέτριο", "Medium"],
  'ui.min': ["λεπτά", "min"],
  'ui.how': ["Πώς να το φτιάξεις", "How to make it"],
  'ui.extras': ["Μπορεί να χρειαστούν επιπλέον υλικά (κλωστή, ελαστικό, παραμάνα) για σταθερή εφαρμογή.", "Extra materials (thread, elastic, safety pin) may be needed to secure it."],
  'ui.safety': ["Σημείωση ασφαλείας", "Safety note"],
  'ui.saved': ["Αποθηκεύτηκε · Πάτα για αφαίρεση", "Saved · Tap to remove"],
  'ui.save': ["Αποθήκευσε την ιδέα", "Save this idea"],
  'ui.illustration': ["Σχηματική εικονογράφηση", "Schematic illustration"],
  'ui.dataError': ["Δεν βρέθηκαν δεδομένα. Έλεγξε το assets/data/recommendations.json.", "No data found. Check assets/data/recommendations.json."],
  'ui.anyOcc': ["Οποιαδήποτε", "Any occasion"],
  'ui.everyday': ["Καθημερινά", "Everyday"],
  'ui.outing': ["Βόλτα", "Going out"],
  'ui.party': ["Πάρτι", "Party"],
  'ui.festival': ["Φεστιβάλ", "Festival"],
  'ui.beach': ["Παραλία", "Beach"],
  'ui.summer': ["Καλοκαίρι", "Summer"],
  'ui.winter': ["Χειμώνας", "Winter"],
  'ui.travel': ["Ταξίδι", "Travel"],
  'ui.home': ["Σπίτι", "At home"],
  'ui.anyStyle': ["Έκπληξέ με", "Surprise me"],
  'ui.hair': ["Μαλλιά", "Hair"],
  'ui.hat': ["Καπέλο", "Hat"],
  'ui.bag': ["Τσάντα", "Bag"],
  'ui.wrist': ["Καρπός", "Wrist"],
  'ui.neck': ["Λαιμός", "Neck"],
  'ui.shoulders': ["Ώμοι", "Shoulders"],
  'ui.waist': ["Μέση", "Waist"],
  'cat.towels': ["Πετσέτες & πανιά", "Towels & cloths"],
  'cat.kitchen': ["Κουζίνα & τραπέζι", "Kitchen & table"],
  'cat.home': ["Σπίτι & λευκά είδη", "Home textiles"],
  'cat.clothes': ["Παλιά ρούχα", "Old clothes"],
  'cat.scraps': ["Ρετάλια υφασμάτων", "Fabric scraps"],
  'cat.cords': ["Κορδόνια & νήματα", "Cords & yarn"],
};

class Idea {
  final String id, objectId, objectName, material, size, transformation;
  final String location, occasion, style, difficulty, notes, category;
  final String objectNameEn, transformationEn, notesEn;
  final List<String> steps, stepsEn;
  final int minutes;
  final bool extras;
  const Idea({required this.id, required this.objectId, required this.objectName,
    required this.material, required this.size, required this.transformation,
    required this.location, required this.occasion, required this.style,
    required this.difficulty, required this.notes, required this.extras,
    required this.objectNameEn, required this.transformationEn, required this.notesEn,
    required this.category, required this.steps, required this.stepsEn, required this.minutes});

  static List<String> _list(dynamic v) => v is List ? v.map((e) => '$e').toList() : <String>[];

  factory Idea.fromJson(Map<String, dynamic> j) => Idea(
    id: '${j['recommendation_id'] ?? ''}', objectId: '${j['object_id'] ?? ''}',
    objectName: '${j['object_name_el'] ?? ''}', material: '${j['object_material'] ?? ''}',
    size: '${j['object_size'] ?? ''}', transformation: '${j['transformation_el'] ?? ''}',
    location: '${j['wear_location'] ?? ''}', occasion: '${j['occasion'] ?? ''}',
    style: '${j['style'] ?? ''}', difficulty: '${j['difficulty'] ?? ''}',
    notes: '${j['safety_notes_el'] ?? ''}',
    objectNameEn: '${j['object_name_en'] ?? j['object_name_el'] ?? ''}',
    transformationEn: '${j['transformation_en'] ?? j['transformation_el'] ?? ''}',
    notesEn: '${j['safety_notes_en'] ?? j['safety_notes_el'] ?? ''}',
    extras: '${j['requires_extra_material'] ?? ''}'.toLowerCase() == 'yes',
    category: '${j['category'] ?? 'scraps'}',
    steps: _list(j['steps_el']), stepsEn: _list(j['steps_en']),
    minutes: j['time_minutes'] is int ? j['time_minutes'] as int : 5);
}

const occasionKeys = ['any', 'everyday', 'outing', 'party', 'festival', 'beach', 'summer', 'winter', 'travel', 'home'];
const styleKeys = ['any', 'boho', 'artsy', 'retro', 'cute', 'minimal', 'cozy', 'casual', 'streetwear',
  'elegant', 'quirky', 'relaxed', 'sporty', 'romantic', 'vintage', 'avant-garde'];
const stylesEl = <String, String>{
  'boho': 'Boho', 'artsy': 'Καλλιτεχνικό', 'retro': 'Ρετρό', 'cute': 'Χαριτωμένο', 'minimal': 'Μίνιμαλ',
  'cozy': 'Ζεστό & άνετο', 'casual': 'Casual', 'streetwear': 'Streetwear', 'elegant': 'Κομψό',
  'quirky': 'Ιδιόρρυθμο', 'relaxed': 'Χαλαρό', 'sporty': 'Σπορ', 'romantic': 'Ρομαντικό',
  'vintage': 'Vintage', 'avant-garde': 'Πρωτοποριακό',
};
const stylesEn = <String, String>{
  'boho': 'Boho', 'artsy': 'Artistic', 'retro': 'Retro', 'cute': 'Cute', 'minimal': 'Minimal',
  'cozy': 'Cozy', 'casual': 'Casual', 'streetwear': 'Streetwear', 'elegant': 'Elegant',
  'quirky': 'Quirky', 'relaxed': 'Relaxed', 'sporty': 'Sporty', 'romantic': 'Romantic',
  'vintage': 'Vintage', 'avant-garde': 'Avant-garde',
};
const categoryKeys = ['towels', 'kitchen', 'home', 'clothes', 'scraps', 'cords'];

IconData categoryIcon(String c) => switch (c) {
  'towels' => Icons.bathtub_outlined,
  'kitchen' => Icons.restaurant_outlined,
  'home' => Icons.bed_outlined,
  'clothes' => Icons.checkroom_outlined,
  'scraps' => Icons.content_cut_rounded,
  'cords' => Icons.gesture_rounded,
  _ => Icons.inventory_2_outlined,
};

/// Removes Greek accents and lower-cases, so "πετσετα" finds "Πετσέτα".
String normalize(String s) {
  const map = {'ά': 'α', 'έ': 'ε', 'ή': 'η', 'ί': 'ι', 'ϊ': 'ι', 'ΐ': 'ι', 'ό': 'ο',
    'ύ': 'υ', 'ϋ': 'υ', 'ΰ': 'υ', 'ώ': 'ω', 'ς': 'σ'};
  final b = StringBuffer();
  for (final ch in s.toLowerCase().split('')) {
    b.write(map[ch] ?? ch);
  }
  return b.toString().trim();
}

Color accentFor(String material) => switch (material) {
  'cotton' => const Color(0xFFD98BA0),
  'satin' => const Color(0xFFC46A8A),
  'wool' => const Color(0xFFB07AA1),
  'linen' => const Color(0xFFC9A27E),
  'jersey' => const Color(0xFF8FA6C9),
  'knit' => const Color(0xFFA77FB0),
  'denim' => const Color(0xFF5D7BA8),
  'mesh' => const Color(0xFF9C8FB8),
  'organza' => const Color(0xFFE3A6C0),
  'fleece' => const Color(0xFFB98FA6),
  'woven' => const Color(0xFFC7956D),
  'velvet' => const Color(0xFF7E3B5E),
  'canvas' => const Color(0xFFB9A788),
  'microfiber' => const Color(0xFF7FB3B0),
  'flannel' => const Color(0xFFB5655E),
  'lace' => const Color(0xFFD9C3B5),
  'felt' => const Color(0xFFD07B6B),
  _ => plum,
};

/// Schematic "after" illustration: a simple figure with the accessory
/// highlighted at the place where it is worn (hair, hat, neck, ...).
class WearPainter extends CustomPainter {
  final String location;
  final Color accent;
  const WearPainter(this.location, this.accent);

  @override
  void paint(Canvas canvas, Size size) {
    final s = min(size.width / 100, size.height / 120);
    canvas.save();
    canvas.translate((size.width - 100 * s) / 2, (size.height - 120 * s) / 2);
    canvas.scale(s);

    final body = Paint()..color = const Color(0xFFE6D6DE);
    final skin = Paint()..color = const Color(0xFFF4E4DA);
    final fill = Paint()..color = accent;
    final stroke = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final dark = Paint()..color = plum;

    // arms, torso, neck, head
    canvas.drawRRect(RRect.fromLTRBR(13, 62, 24, 112, const Radius.circular(6)), body);
    canvas.drawRRect(RRect.fromLTRBR(76, 62, 87, 112, const Radius.circular(6)), body);
    canvas.drawRRect(RRect.fromLTRBAndCorners(22, 54, 78, 122,
      topLeft: const Radius.circular(20), topRight: const Radius.circular(20)), body);
    canvas.drawRect(const Rect.fromLTRB(45, 42, 55, 56), skin);
    canvas.drawCircle(const Offset(50, 30), 14, skin);

    switch (location) {
      case 'hair':
        canvas.drawArc(Rect.fromCircle(center: const Offset(50, 30), radius: 15), pi * 1.05, pi * 0.9, false, stroke);
        final bow = Path()
          ..moveTo(62, 18)..lineTo(72, 12)..lineTo(72, 24)..close()
          ..moveTo(62, 18)..lineTo(54, 10)..lineTo(54, 22)..close();
        canvas.drawPath(bow, fill);
        canvas.drawCircle(const Offset(62, 18), 2.5, dark);
      case 'hat':
        canvas.drawOval(const Rect.fromLTRB(24, 16, 76, 26), Paint()..color = const Color(0xFFCDB9A6));
        canvas.drawRRect(RRect.fromLTRBR(35, 2, 65, 21, const Radius.circular(6)), Paint()..color = const Color(0xFFD8C6B4));
        canvas.drawRect(const Rect.fromLTRB(35, 14, 65, 20), fill);
        canvas.drawCircle(const Offset(64, 17), 3.5, dark);
      case 'neck':
        final scarf = Path()..moveTo(36, 47)..lineTo(64, 47)..lineTo(50, 68)..close();
        canvas.drawPath(scarf, fill);
        canvas.drawCircle(const Offset(58, 50), 3.5, dark);
      case 'shoulders':
        final shawl = Path()
          ..moveTo(14, 66)..quadraticBezierTo(50, 44, 86, 66)
          ..lineTo(86, 84)..quadraticBezierTo(50, 70, 14, 84)..close();
        canvas.drawPath(shawl, fill);
      case 'waist':
        canvas.drawRect(const Rect.fromLTRB(22, 88, 78, 96), fill);
        final bow = Path()
          ..moveTo(62, 92)..lineTo(70, 86)..lineTo(70, 98)..close()
          ..moveTo(62, 92)..lineTo(54, 86)..lineTo(54, 98)..close();
        canvas.drawPath(bow, dark);
      case 'wrist':
        canvas.drawRRect(RRect.fromLTRBR(11, 96, 26, 104, const Radius.circular(3)), fill);
        canvas.drawRRect(RRect.fromLTRBR(74, 96, 89, 104, const Radius.circular(3)), fill);
      case 'bag':
        canvas.drawLine(const Offset(72, 58), const Offset(88, 94),
          Paint()..color = const Color(0xFFB8A2AE)..strokeWidth = 2.5);
        canvas.drawRRect(RRect.fromLTRBR(78, 92, 99, 114, const Radius.circular(4)), Paint()..color = const Color(0xFFD8C6B4));
        canvas.drawCircle(const Offset(88, 103), 5, fill);
        canvas.drawLine(const Offset(80, 94), const Offset(76, 108), stroke..strokeWidth = 3);
      default:
        canvas.drawCircle(const Offset(50, 80), 8, fill);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant WearPainter old) => old.location != location || old.accent != accent;
}

class ReWearApp extends StatelessWidget {
  const ReWearApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'ReWear the Unexpected', debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true, scaffoldBackgroundColor: cream,
      colorScheme: ColorScheme.fromSeed(seedColor: plum, primary: plum, surface: cream),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.8, color: ink),
        headlineMedium: TextStyle(fontWeight: FontWeight.w700, color: ink),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, color: ink),
        titleMedium: TextStyle(fontWeight: FontWeight.w700, color: ink),
        bodyMedium: TextStyle(color: ink, height: 1.45),
      ),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
        backgroundColor: plum, foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)))),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    ), home: const ReWearHome(),
  );
}

class ReWearHome extends StatefulWidget {
  const ReWearHome({super.key});
  @override
  State<ReWearHome> createState() => _ReWearHomeState();
}

class _ReWearHomeState extends State<ReWearHome> {
  String appLanguage = 'el';
  bool get en => appLanguage == 'en';
  String tr(String key) => en ? (uiLabels[key]?[1] ?? key) : (uiLabels[key]?[0] ?? key);
  String objectLabel(Idea i) => en ? i.objectNameEn : i.objectName;
  String ideaLabel(Idea i) => en ? i.transformationEn : i.transformation;
  String safetyLabel(Idea i) => en ? i.notesEn : i.notes;
  String occasionLabel(String k) => tr('ui.${k == 'any' ? 'anyOcc' : k}');
  String styleLabel(String k) => k == 'any' ? tr('ui.anyStyle') : ((en ? stylesEn[k] : stylesEl[k]) ?? k);
  String locationLabel(String k) => tr('ui.$k');
  String categoryLabel(String k) => tr('cat.$k');

  List<Idea> ideas = [];
  bool loading = true;
  int page = 0; // 0 welcome, 1 object, 2 preferences, 3 results, 4 saved
  int pageBeforeSaved = 0;
  String? chosenObject;
  String occasion = 'any', style = 'any';
  String search = '';
  String category = 'all';
  final searchController = TextEditingController();
  final saved = <String>{};
  final rand = Random();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final raw = await rootBundle.loadString('assets/data/recommendations.json');
      final decoded = jsonDecode(raw);
      if (decoded is! List) throw const FormatException('Expected a JSON list');
      final loaded = decoded.map((e) => Idea.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      List<String> savedIds = [];
      String lang = 'el';
      try {
        final prefs = await SharedPreferences.getInstance();
        savedIds = prefs.getStringList('saved') ?? [];
        lang = prefs.getString('lang') ?? 'el';
      } catch (_) {/* storage unavailable: start empty */}
      if (!mounted) return;
      setState(() {
        ideas = loaded;
        saved.addAll(savedIds);
        appLanguage = lang;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(en ? 'Could not load ideas: $e' : 'Δεν φορτώθηκαν οι προτάσεις: $e')));
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('saved', saved.toList());
      await prefs.setString('lang', appLanguage);
    } catch (_) {}
  }

  void _toggleSave(String id) {
    setState(() { if (!saved.add(id)) saved.remove(id); });
    _persist();
  }

  // object id -> first idea (for name, category)
  Map<String, Idea> get objectSamples {
    final m = <String, Idea>{};
    for (final i in ideas) {
      m.putIfAbsent(i.objectId, () => i);
    }
    return m;
  }

  String objectName(String? id) {
    final sample = objectSamples[id];
    return sample == null ? '' : objectLabel(sample);
  }

  List<Idea> get objectIdeas => ideas.where((i) => i.objectId == chosenObject).toList();

  int _score(Idea i) => (occasion != 'any' && i.occasion == occasion ? 4 : 0) +
    (style != 'any' && i.style == style ? 3 : 0) + (i.difficulty == 'easy' ? 1 : 0);

  List<Idea> get ranked {
    final candidates = objectIdeas;
    candidates.sort((a, b) => _score(b).compareTo(_score(a)));
    return candidates;
  }

  /// Ideas from other objects that match the chosen occasion and/or style.
  List<Idea> get moreIdeas {
    if (occasion == 'any' && style == 'any') return [];
    bool matches(Idea i) {
      final o = occasion == 'any' || i.occasion == occasion;
      final s = style == 'any' || i.style == style;
      return o && s;
    }
    final list = ideas.where((i) => i.objectId != chosenObject && matches(i)).toList();
    list.sort((a, b) => _score(b).compareTo(_score(a)));
    return list.take(6).toList();
  }

  /// One easy idea per category, rotating daily.
  List<Idea> get suggestions {
    final day = DateTime.now().difference(DateTime(2026, 1, 1)).inDays;
    final out = <Idea>[];
    for (var c = 0; c < categoryKeys.length; c++) {
      final pool = ideas.where((i) => i.category == categoryKeys[c] && i.difficulty == 'easy').toList();
      if (pool.isNotEmpty) out.add(pool[(day + c * 7) % pool.length]);
    }
    return out;
  }

  void _chooseObject(String id) => setState(() {
    chosenObject = id; occasion = 'any'; style = 'any'; page = 2;
  });

  void _randomObject() {
    final keys = objectSamples.keys.toList();
    if (keys.isEmpty) return;
    _chooseObject(keys[rand.nextInt(keys.length)]);
  }

  void _goBack() => setState(() {
    if (page == 4) {
      page = pageBeforeSaved;
    } else {
      page = max(0, page - 1);
    }
  });

  void _openSaved() => setState(() {
    if (page != 4) pageBeforeSaved = page;
    page = 4;
  });

  void _info() => showModalBottomSheet<void>(
    context: context, isScrollControlled: true, showDragHandle: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (ctx) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(26, 12, 26, 32),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tr('ui.infoTitle'), style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        Text(tr('ui.infoIntro')),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: blush, borderRadius: BorderRadius.circular(14)),
          child: Text(tr('ui.whatsNew'), style: const TextStyle(color: plum, fontWeight: FontWeight.w600))),
        const SizedBox(height: 12),
        Text(tr('ui.infoDisclaimer'), style: const TextStyle(color: muted)),
        const SizedBox(height: 18),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('ui.ok')))),
      ]))),
  );

  Widget _languageSwitch() => Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(19), border: Border.all(color: line)),
    child: Row(mainAxisSize: MainAxisSize.min, children: ['el', 'en'].map((language) {
      final active = appLanguage == language;
      return InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () { setState(() => appLanguage = language); _persist(); },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(color: active ? blush : Colors.transparent, borderRadius: BorderRadius.circular(15)),
          child: Text(language.toUpperCase(), style: TextStyle(fontSize: 11, color: active ? plum : muted, fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
        ),
      );
    }).toList()),
  );

  Widget _topBar() => Padding(
    padding: const EdgeInsets.fromLTRB(22, 14, 22, 12),
    child: Row(children: [
      if (page != 0) IconButton(onPressed: _goBack, icon: const Icon(Icons.arrow_back_ios_new_rounded))
      else const Icon(Icons.auto_awesome_rounded, size: 25, color: plum),
      const SizedBox(width: 7),
      Expanded(child: InkWell(onTap: () => setState(() => page = 0),
        child: const Text('rewear.', style: TextStyle(fontSize: 24, letterSpacing: -1, fontWeight: FontWeight.w700, color: ink)))),
      _languageSwitch(),
      const SizedBox(width: 3),
      IconButton(tooltip: tr('ui.savedTooltip'), onPressed: _openSaved,
        icon: Badge(isLabelVisible: saved.isNotEmpty, label: Text('${saved.length}'), backgroundColor: plum,
          child: Icon(saved.isNotEmpty ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 23))),
      IconButton(tooltip: tr('ui.infoTooltip'), onPressed: _info, icon: const Icon(Icons.info_outline_rounded)),
    ]),
  );

  Widget _tag(String text, {Color color = lavender, IconData? icon}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[Icon(icon, size: 14, color: ink), const SizedBox(width: 5)],
      Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: ink)),
    ]),
  );

  Widget _illustration(Idea idea, double width) => CustomPaint(
    size: Size(width, width * 1.2), painter: WearPainter(idea.location, accentFor(idea.material)));

  Widget _welcome() => ListView(padding: const EdgeInsets.fromLTRB(26, 8, 26, 32), children: [
    const SizedBox(height: 12),
    Align(alignment: Alignment.centerLeft, child: _tag(tr('ui.heroTag'), color: blush)),
    const SizedBox(height: 18),
    Text(tr('ui.heroTitle'), style: const TextStyle(
      fontSize: 36, height: 1.12, letterSpacing: -1.2, fontWeight: FontWeight.w700, color: ink)),
    const SizedBox(height: 14),
    Text(tr('ui.heroSub'), style: const TextStyle(fontSize: 15, color: muted, height: 1.6)),
    const SizedBox(height: 24),
    SizedBox(width: double.infinity, child: FilledButton.icon(
      onPressed: () => setState(() => page = 1), icon: const Icon(Icons.arrow_forward_rounded),
      label: Text(tr('ui.discover')))),
    const SizedBox(height: 4),
    Center(child: TextButton.icon(onPressed: _randomObject,
      icon: const Icon(Icons.shuffle_rounded, size: 18), label: Text(tr('ui.random')))),
    const SizedBox(height: 18),
    Text(tr('ui.suggested'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
    const SizedBox(height: 4),
    Text(tr('ui.suggestedSub'), style: const TextStyle(color: muted, fontSize: 12)),
    const SizedBox(height: 12),
    SizedBox(height: 206, child: ListView.separated(
      scrollDirection: Axis.horizontal, itemCount: suggestions.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (ctx, i) {
        final idea = suggestions[i];
        return InkWell(borderRadius: BorderRadius.circular(20), onTap: () => _details(idea),
          child: Container(width: 140, padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: line)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(height: 96, width: double.infinity, alignment: Alignment.center,
                decoration: BoxDecoration(color: i.isEven ? blush : lavender, borderRadius: BorderRadius.circular(14)),
                child: _illustration(idea, 66)),
              const SizedBox(height: 8),
              Text(ideaLabel(idea), maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, height: 1.25)),
              const Spacer(),
              Text(objectLabel(idea), maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: muted, fontSize: 11)),
            ])));
      })),
  ]);

  Widget _objectTile(String id, Idea sample, int index) => InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: () => _chooseObject(id),
    child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(
      color: index.isEven ? blush : lavender, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white, width: 1.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Icon(categoryIcon(sample.category), color: plum, size: 24),
        Text(objectLabel(sample), maxLines: 3, overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, height: 1.2, color: ink)),
      ])),
  );

  Widget _grid(List<MapEntry<String, Idea>> items) => GridView.builder(
    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: EdgeInsets.zero,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.92, crossAxisSpacing: 9, mainAxisSpacing: 9),
    itemCount: items.length, itemBuilder: (ctx, i) => _objectTile(items[i].key, items[i].value, i));

  Widget _objectPage() {
    final q = normalize(search);
    final all = objectSamples.entries.toList();
    final searching = q.isNotEmpty;
    final filtered = all.where((e) {
      if (searching) {
        final hay = normalize('${e.value.objectName} ${e.value.objectNameEn} ${tr('cat.${e.value.category}')}');
        return hay.contains(q);
      }
      return category == 'all' || e.value.category == category;
    }).toList();

    final sections = <Widget>[];
    if (filtered.isEmpty) {
      sections.add(Padding(padding: const EdgeInsets.only(top: 40), child: Center(child: Text(tr('ui.noObject')))));
    } else if (!searching && category == 'all') {
      for (final c in categoryKeys) {
        final items = filtered.where((e) => e.value.category == c).toList();
        if (items.isEmpty) continue;
        sections.add(Padding(padding: const EdgeInsets.fromLTRB(0, 14, 0, 9), child: Row(children: [
          Icon(categoryIcon(c), size: 18, color: plum), const SizedBox(width: 7),
          Text(categoryLabel(c), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(width: 6), Text('${items.length}', style: const TextStyle(color: muted, fontSize: 12)),
        ])));
        sections.add(_grid(items));
      }
    } else {
      sections.add(const SizedBox(height: 10));
      sections.add(_grid(filtered));
    }

    return ListView(padding: const EdgeInsets.fromLTRB(24, 12, 24, 24), children: [
      Text(tr('ui.step1'), style: const TextStyle(color: plum, fontWeight: FontWeight.w700, letterSpacing: 1.5, fontSize: 12)),
      const SizedBox(height: 9), Text(tr('ui.pickTitle'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: ink)),
      const SizedBox(height: 6), Text(tr('ui.pickSub'), style: const TextStyle(color: muted)),
      const SizedBox(height: 14),
      TextField(
        controller: searchController,
        onChanged: (v) => setState(() => search = v),
        decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: tr('ui.search'),
          suffixIcon: search.isEmpty ? null : IconButton(icon: const Icon(Icons.close_rounded),
            onPressed: () => setState(() { search = ''; searchController.clear(); }))),
      ),
      const SizedBox(height: 10),
      if (!searching) SizedBox(height: 40, child: ListView(scrollDirection: Axis.horizontal, children: [
        for (final c in ['all', ...categoryKeys]) Padding(padding: const EdgeInsets.only(right: 7), child: ChoiceChip(
          label: Text(c == 'all' ? tr('ui.all') : categoryLabel(c)),
          selected: category == c, onSelected: (_) => setState(() => category = c),
          selectedColor: blush, backgroundColor: Colors.white, showCheckmark: false,
          side: BorderSide(color: category == c ? plum : const Color(0xFFEFE8E8)),
          labelStyle: TextStyle(color: category == c ? plum : ink, fontWeight: FontWeight.w700, fontSize: 12.5),
        )),
      ])),
      ...sections,
    ]);
  }

  Widget _choiceGroup(String heading, List<String> options, String selected, String Function(String) label, ValueChanged<String> change) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(heading, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      const SizedBox(height: 13),
      Wrap(spacing: 9, runSpacing: 9, children: options.map((k) => ChoiceChip(
        label: Text(label(k)), selected: selected == k, onSelected: (_) => change(k),
        selectedColor: blush, backgroundColor: Colors.white,
        side: BorderSide(color: selected == k ? plum : const Color(0xFFEFE8E8)),
        labelStyle: TextStyle(color: selected == k ? plum : ink, fontWeight: FontWeight.w700),
      )).toList()),
    ]);

  Widget _preferences() {
    final available = objectIdeas;
    final occ = occasionKeys.where((k) => k == 'any' || available.any((i) => i.occasion == k)).toList();
    final sty = styleKeys.where((k) => k == 'any' || available.any((i) => i.style == k)).toList();
    final sample = objectSamples[chosenObject];
    return ListView(padding: const EdgeInsets.fromLTRB(24, 16, 24, 30), children: [
      Text(tr('ui.step2'), style: const TextStyle(color: plum, fontWeight: FontWeight.w700, letterSpacing: 1.5, fontSize: 12)),
      const SizedBox(height: 9),
      Text(tr('ui.customTitle'), style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w700, color: ink)),
      const SizedBox(height: 8),
      Text(tr('ui.customSub'), style: const TextStyle(color: muted)),
      const SizedBox(height: 23),
      Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: lavender, borderRadius: BorderRadius.circular(20)),
        child: Row(children: [Icon(categoryIcon(sample?.category ?? ''), size: 30, color: plum), const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr('ui.yourObject'), style: const TextStyle(fontSize: 10, color: muted, fontWeight: FontWeight.bold)),
            Text(objectName(chosenObject), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))])),
          TextButton(onPressed: () => setState(() => page = 1), child: Text(tr('ui.change')))])),
      const SizedBox(height: 28),
      _choiceGroup(tr('ui.occasionQuestion'), occ, occasion, occasionLabel, (v) => setState(() => occasion = v)),
      const SizedBox(height: 27),
      _choiceGroup(tr('ui.styleQuestion'), sty, style, styleLabel, (v) => setState(() => style = v)),
      const SizedBox(height: 30),
      FilledButton.icon(onPressed: () => setState(() => page = 3),
        icon: const Icon(Icons.auto_awesome_rounded), label: Text(tr('ui.showIdeas'))),
    ]);
  }

  Widget _ideaCard(Idea idea, int rank, {bool showObject = false, bool showRank = true}) {
    final exactOccasion = occasion != 'any' && occasion == idea.occasion;
    final exactStyle = style != 'any' && style == idea.style;
    final match = exactOccasion && exactStyle ? tr('ui.both') :
      exactOccasion ? tr('ui.occasionMatch') : exactStyle ? tr('ui.styleMatch') : tr('ui.alternative');
    final isSaved = saved.contains(idea.id);
    return Container(margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20), color: Colors.white, border: Border.all(color: line),
      boxShadow: const [BoxShadow(color: Color(0x086D3E59), blurRadius: 10, offset: Offset(0, 3))]),
      child: InkWell(borderRadius: BorderRadius.circular(20), onTap: () => _details(idea),
        child: Padding(padding: const EdgeInsets.all(11), child: Row(children: [
          Container(width: 64, height: 72, alignment: Alignment.center,
            decoration: BoxDecoration(color: rank.isEven ? blush : lavender, borderRadius: BorderRadius.circular(14)),
            child: _illustration(idea, 50)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (showRank) Text('${tr('ui.idea')} #${rank + 1}', style: const TextStyle(fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w700, color: plum)),
            Text(ideaLabel(idea), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: ink, height: 1.25)),
            const SizedBox(height: 3),
            Text(showObject ? '${tr('ui.from')} ${objectLabel(idea)}' : match, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: muted)),
            const SizedBox(height: 3),
            Text('${locationLabel(idea.location)} · ${styleLabel(idea.style)} · ${idea.minutes}′',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: plum)),
          ])),
          IconButton(tooltip: tr('ui.saveTooltip'),
            onPressed: () => _toggleSave(idea.id),
            icon: Icon(isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: isSaved ? plum : muted)),
        ]))),
    );
  }

  Widget _results() {
    final results = ranked;
    final more = moreIdeas;
    final filterText = [if (occasion != 'any') occasionLabel(occasion), if (style != 'any') styleLabel(style)].join(' · ');
    return ListView(padding: const EdgeInsets.fromLTRB(24, 16, 24, 28), children: [
      Text(tr('ui.step3'), style: const TextStyle(color: plum, fontWeight: FontWeight.w700, letterSpacing: 1.5, fontSize: 12)),
      const SizedBox(height: 9),
      Text(tr('ui.resultsTitle'), style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w700, color: ink)),
      const SizedBox(height: 8),
      Text(en ? 'Found ${results.length} ideas for: ${objectName(chosenObject)}' : 'Βρήκαμε ${results.length} ιδέες για: ${objectName(chosenObject)}', style: const TextStyle(color: muted)),
      const SizedBox(height: 6),
      Text(tr('ui.resultsNote'), style: const TextStyle(color: muted, fontSize: 12)),
      const SizedBox(height: 16),
      ...results.asMap().entries.map((e) => _ideaCard(e.value, e.key)),
      if (more.isNotEmpty) ...[
        const SizedBox(height: 18),
        Text(tr('ui.more'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 3),
        Text(filterText, style: const TextStyle(color: plum, fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        ...more.asMap().entries.map((e) => _ideaCard(e.value, e.key + 1, showObject: true, showRank: false)),
      ],
      const SizedBox(height: 12),
      OutlinedButton.icon(onPressed: () => setState(() => page = 2),
        icon: const Icon(Icons.tune_rounded), label: Text(tr('ui.adjust'))),
      TextButton(onPressed: () => setState(() { page = 1; search = ''; searchController.clear(); }), child: Text(tr('ui.another'))),
    ]);
  }

  Widget _savedPage() {
    final list = ideas.where((e) => saved.contains(e.id)).toList();
    return ListView(padding: const EdgeInsets.fromLTRB(24, 16, 24, 28), children: [
      Text(tr('ui.collection'), style: const TextStyle(color: plum, fontWeight: FontWeight.w700, letterSpacing: 1.5, fontSize: 12)),
      const SizedBox(height: 9),
      Text(tr('ui.favorites'), style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w700, color: ink)),
      const SizedBox(height: 15),
      if (list.isEmpty) ...[
        const SizedBox(height: 80),
        Center(child: Container(width: 84, height: 84, decoration: const BoxDecoration(color: blush, shape: BoxShape.circle), child: const Icon(Icons.favorite_border_rounded, size: 34, color: plum))),
        const SizedBox(height: 18), Center(child: Text(tr('ui.noSaved'), textAlign: TextAlign.center, style: const TextStyle(color: muted))),
        const SizedBox(height: 20), FilledButton(onPressed: () => setState(() => page = 1), child: Text(tr('ui.findIdeas'))),
      ] else ...list.asMap().entries.map((e) => _ideaCard(e.value, e.key, showObject: true, showRank: false)),
    ]);
  }

  void _details(Idea idea) => showModalBottomSheet<void>(context: context,
    isScrollControlled: true, showDragHandle: true, backgroundColor: cream,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
    builder: (ctx) => StatefulBuilder(builder: (ctx, localSetState) {
      final steps = en ? idea.stepsEn : idea.steps;
      final isSaved = saved.contains(idea.id);
      return SafeArea(child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.88),
        child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(height: 170, width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(color: blush, borderRadius: BorderRadius.circular(24)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(width: 74, height: 74, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(categoryIcon(idea.category), color: plum, size: 36)),
                  const SizedBox(height: 8),
                  Text(tr('ui.before'), style: const TextStyle(fontSize: 10, letterSpacing: 1.5, color: muted)),
                ]),
                const Icon(Icons.arrow_forward_rounded, color: plum, size: 28),
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _illustration(idea, 92),
                  const SizedBox(height: 4),
                  Text(tr('ui.after'), style: const TextStyle(fontSize: 10, letterSpacing: 1.5, color: plum, fontWeight: FontWeight.w700)),
                ]),
              ])),
            const SizedBox(height: 4),
            Text(tr('ui.illustration'), style: const TextStyle(fontSize: 10, color: muted)),
            const SizedBox(height: 14),
            Text(ideaLabel(idea), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, height: 1.15)),
            const SizedBox(height: 6), Text('${tr('ui.from')} ${objectLabel(idea)}', style: const TextStyle(color: muted)),
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _tag(locationLabel(idea.location), color: Colors.white),
              _tag(styleLabel(idea.style)), _tag(occasionLabel(idea.occasion), color: blush),
              _tag(idea.difficulty == 'easy' ? tr('ui.easy') : tr('ui.medium')),
              _tag('${idea.minutes} ${tr('ui.min')}', color: blush, icon: Icons.schedule_rounded),
            ]),
            const SizedBox(height: 20),
            Text(tr('ui.how'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            for (var n = 0; n < steps.length; n++) Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 24, height: 24, alignment: Alignment.center,
                  decoration: const BoxDecoration(color: plum, shape: BoxShape.circle),
                  child: Text('${n + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
                const SizedBox(width: 11),
                Expanded(child: Padding(padding: const EdgeInsets.only(top: 2), child: Text(steps[n]))),
              ])),
            if (idea.extras) Padding(padding: const EdgeInsets.only(top: 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.add_circle_outline_rounded, size: 18, color: muted), const SizedBox(width: 8),
              Expanded(child: Text(tr('ui.extras'), style: const TextStyle(color: muted))),
            ])),
            const SizedBox(height: 16),
            Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: line)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [const Icon(Icons.health_and_safety_outlined, size: 18, color: plum), const SizedBox(width: 7),
                  Text(tr('ui.safety'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))]),
                const SizedBox(height: 6), Text(safetyLabel(idea), style: const TextStyle(color: muted)),
              ])),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: FilledButton.icon(
              onPressed: () { _toggleSave(idea.id); localSetState(() {}); },
              icon: Icon(isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded),
              label: Text(isSaved ? tr('ui.saved') : tr('ui.save')))),
          ]))));
    }));

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520),
      child: Column(children: [
        _topBar(),
        Expanded(child: loading ? const Center(child: CircularProgressIndicator()) :
          ideas.isEmpty ? Center(child: Text(tr('ui.dataError'))) :
          switch (page) {
            0 => _welcome(), 1 => _objectPage(), 2 => _preferences(),
            3 => _results(), 4 => _savedPage(), _ => _welcome(),
          }),
      ])))),
    bottomNavigationBar: page == 0 || page == 4 ? null : SafeArea(
      top: false, child: Padding(padding: const EdgeInsets.fromLTRB(24, 5, 24, 9),
        child: Row(children: List.generate(3, (i) => Expanded(child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3), height: 5,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6),
            color: i <= page - 1 ? plum : const Color(0xFFE8DAE3))))))),
    ),
  );
}
