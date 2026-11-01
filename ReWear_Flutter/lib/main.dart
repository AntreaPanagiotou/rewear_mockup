// ReWear the Unexpected — run on Windows / VS Code (PowerShell):
// 1. Open the FULL Flutter project folder (the one containing pubspec.yaml).
// 2. Run these commands in its Terminal:
//    C:\src\flutter\bin\flutter.bat pub get
//    C:\src\flutter\bin\flutter.bat run -d edge
// 3. For phone preview in Edge: F12, then Ctrl+Shift+M.
// 4. While running: press r for hot reload, R for hot restart.
// Note: Plain `flutter` isn't recognized on this computer (PATH issue).
// If your Flutter SDK is installed elsewhere, replace C:\src\flutter accordingly.

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  'ui.infoDisclaimer': ["Αυτή είναι μια διαδραστική προεπισκόπηση (HW1). Οι προτάσεις προέρχονται από συνθετικό dataset. Δεν υπάρχει ακόμη εκπαιδευμένο recommender ή αυτόματη αναγνώριση εικόνας.", "This is an interactive HW1 mockup. Suggestions come from a synthetic dataset; no trained recommendation model or image recognition is implemented."],
  'ui.ok': ["Κατάλαβα!", "Got it"],
  'ui.savedTooltip': ["Αποθηκευμένα", "Saved"],
  'ui.infoTooltip': ["Πληροφορίες", "About"],
  'ui.heroTag': ["REIMAGINE THE EVERYDAY", "REIMAGINE THE EVERYDAY"],
  'ui.heroTitle': ["Ordinary things.\nA new point of view.", "Ordinary things.\nA new point of view."],
  'ui.heroSub': ["Μικρές μεταμορφώσεις, μεγάλη φαντασία.\nΔες τα αντικείμενά σου αλλιώς.", "Small transformations, big imagination.\nSee your everyday objects differently."],
  'ui.discover': ["Ανακάλυψε ιδέες", "Discover ideas"],
  'ui.random': ["Επίλεξε τυχαίο αντικείμενο", "Surprise me with an object"],
  'ui.step1': ["01  /  ΕΠΙΛΟΓΗ ΑΝΤΙΚΕΙΜΕΝΟΥ", "01  /  CHOOSE AN OBJECT"],
  'ui.pickTitle': ["Τι έχεις διαθέσιμο;", "What do you have?"],
  'ui.pickSub': ["Διάλεξε ένα συνηθισμένο αντικείμενο για μια ασυνήθιστη ιδέα.", "Choose an ordinary object for an unexpected look."],
  'ui.search': ["Αναζήτησε αντικείμενο…", "Search objects…"],
  'ui.noObject': ["Δεν βρέθηκε αντικείμενο.", "No objects found."],
  'ui.step2': ["02  /  ΠΡΟΣΑΡΜΟΓΗ", "02  /  PERSONALIZE"],
  'ui.customTitle': ["Στα μέτρα σου.", "Make it yours."],
  'ui.customSub': ["Επίλεξε πού θα πας και τι διάθεση έχεις σήμερα.", "Pick your occasion and mood for today."],
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
  'ui.resultsTitle': ["Your rewear edit.", "Your rewear edit."],
  'ui.resultsNote': ["Οι προτάσεις κατατάσσονται ενδεικτικά βάσει των επιλογών σου.", "Ideas are ranked using simple preference matching."],
  'ui.adjust': ["Άλλαξε περίσταση / στυλ", "Change occasion / style"],
  'ui.another': ["Δοκίμασε άλλο αντικείμενο", "Try another object"],
  'ui.collection': ["ΣΥΛΛΟΓΗ", "COLLECTION"],
  'ui.favorites': ["Οι αγαπημένες σου.", "Your favorites."],
  'ui.noSaved': ["Δεν έχεις αποθηκεύσει ιδέες ακόμη.", "You haven’t saved any ideas yet."],
  'ui.findIdeas': ["Βρες ιδέες", "Explore ideas"],
  'ui.from': ["Από:", "From:"],
  'ui.easy': ["Εύκολο", "Easy"],
  'ui.medium': ["Μέτριο", "Medium"],
  'ui.how': ["Πώς να το φορέσεις", "How to style it"],
  'ui.extras': ["Μπορεί να χρειαστούν επιπλέον υλικά για σταθερή εφαρμογή.", "Extra materials may be needed to secure it."],
  'ui.safety': ["Σημείωση ασφαλείας", "Safety note"],
  'ui.saved': ["Αποθηκεύτηκε · Πάτα για αφαίρεση", "Saved · Tap to remove"],
  'ui.save': ["Αποθήκευσε την ιδέα", "Save this idea"],
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
  'ui.hat': ["Κεφάλι", "Hat"],
  'ui.bag': ["Τσάντα", "Bag"],
  'ui.wrist': ["Καρπός", "Wrist"],
  'ui.neck': ["Λαιμός", "Neck"],
  'ui.shoulders': ["Ώμοι", "Shoulders"],
  'ui.waist': ["Μέση", "Waist"],
};

class Idea {
  final String id, objectId, objectName, material, size, transformation;
  final String location, occasion, style, difficulty, notes;
  final String objectNameEn, transformationEn, notesEn;
  final bool extras;
  const Idea({required this.id, required this.objectId, required this.objectName,
    required this.material, required this.size, required this.transformation,
    required this.location, required this.occasion, required this.style,
    required this.difficulty, required this.notes, required this.extras,
    required this.objectNameEn, required this.transformationEn, required this.notesEn});
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
    extras: '${j['requires_extra_material'] ?? ''}'.toLowerCase() == 'yes');
}

const occasions = <String, String>{
  'any': 'Οποιαδήποτε', 'everyday': 'Καθημερινά', 'outing': 'Βόλτα',
  'party': 'Πάρτι', 'festival': 'Φεστιβάλ', 'beach': 'Παραλία',
  'summer': 'Καλοκαίρι', 'winter': 'Χειμώνας', 'travel': 'Ταξίδι', 'home': 'Σπίτι',
};
const styles = <String, String>{
  'any': 'Έκπληξέ με', 'boho': 'Boho', 'artsy': 'Artistic',
  'retro': 'Retro', 'cute': 'Cute', 'minimal': 'Minimal', 'cozy': 'Cozy',
  'casual': 'Casual', 'streetwear': 'Streetwear', 'elegant': 'Elegant',
  'quirky': 'Quirky', 'relaxed': 'Relaxed', 'sporty': 'Sporty',
  'romantic': 'Romantic', 'vintage': 'Vintage', 'avant-garde': 'Avant-garde',
};
const locations = <String, String>{
  'hair': 'Μαλλιά', 'hat': 'Κεφάλι', 'bag': 'Τσάντα', 'wrist': 'Καρπός',
  'neck': 'Λαιμός', 'shoulders': 'Ώμοι', 'waist': 'Μέση',
};

IconData iconFor(String location) => switch (location) {
  'hair' => Icons.auto_awesome_outlined,
  'hat' => Icons.checkroom_outlined,
  'bag' => Icons.shopping_bag_outlined,
  'wrist' => Icons.watch_outlined,
  'neck' => Icons.dry_cleaning_outlined,
  'shoulders' => Icons.checkroom_outlined,
  'waist' => Icons.style_outlined,
  _ => Icons.auto_awesome_outlined,
};


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
  String tr(String key) => appLanguage == 'en' ? (uiLabels[key]?[1] ?? key) : (uiLabels[key]?[0] ?? key);
  String objectLabel(Idea i) => appLanguage == 'en' ? i.objectNameEn : i.objectName;
  String ideaLabel(Idea i) => appLanguage == 'en' ? i.transformationEn : i.transformation;
  String safetyLabel(Idea i) => appLanguage == 'en' ? i.notesEn : i.notes;
  String occasionLabel(String k) => tr('ui.${k == 'any' ? 'anyOcc' : k}');
  String styleLabel(String k) => k == 'any' ? tr('ui.anyStyle') : (styles[k] ?? k);
  String locationLabel(String k) => tr('ui.$k');
  List<Idea> ideas = [];
  bool loading = true;
  int page = 0; // 0 welcome, 1 object, 2 preferences, 3 results, 4 saved
  String? chosenObject;
  String occasion = 'any', style = 'any';
  String search = '';
  final saved = <String>{};
  final rand = Random();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final raw = await rootBundle.loadString('assets/data/recommendations.json');
      final decoded = jsonDecode(raw);
      if (decoded is! List) throw const FormatException('Expected a JSON list');
      if (!mounted) return;
      setState(() { ideas = decoded.map((e) => Idea.fromJson(Map<String, dynamic>.from(e as Map))).toList(); loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLanguage == 'en' ? 'Could not load ideas: $e' : 'Δεν φορτώθηκαν οι προτάσεις: $e')));
    }
  }

  Map<String, String> get objects => {
    for (final i in ideas) i.objectId: objectLabel(i),
  };

  List<Idea> get ranked {
    final candidates = ideas.where((i) => i.objectId == chosenObject).toList();
    int score(Idea i) => (occasion != 'any' && i.occasion == occasion ? 4 : 0) +
      (style != 'any' && i.style == style ? 3 : 0) + (i.difficulty == 'easy' ? 1 : 0);
    candidates.sort((a, b) => score(b).compareTo(score(a)));
    return candidates;
  }

  void _randomObject() {
    final keys = objects.keys.toList();
    if (keys.isEmpty) return;
    setState(() { chosenObject = keys[rand.nextInt(keys.length)]; page = 2; });
  }

  void _info() => showModalBottomSheet<void>(
    context: context, isScrollControlled: true, showDragHandle: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (ctx) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(26, 12, 26, 32),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tr('ui.infoTitle'), style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        Text(tr('ui.infoIntro')),
        const SizedBox(height: 12),
        Text(tr('ui.infoDisclaimer'), style: TextStyle(color: muted)),
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
        onTap: () => setState(() => appLanguage = language),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(color: active ? blush : Colors.transparent, borderRadius: BorderRadius.circular(15)),
          child: Text(language.toUpperCase(), style: TextStyle(fontSize: 11, color: active ? plum : muted, fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
        ),
      );
    }).toList()),
  );

  Widget _topBar({bool back = false}) => Padding(
    padding: const EdgeInsets.fromLTRB(22, 14, 22, 12),
    child: Row(children: [
      if (back) IconButton(onPressed: () => setState(() => page = page == 4 ? 0 : page - 1), icon: const Icon(Icons.arrow_back_ios_new_rounded))
      else const Icon(Icons.auto_awesome_rounded, size: 25, color: plum),
      const SizedBox(width: 7),
      const Expanded(child: Text('rewear.', style: TextStyle(fontSize: 24, letterSpacing: -1, fontWeight: FontWeight.w700, color: ink))),
      _languageSwitch(),
      const SizedBox(width: 3),
      IconButton(tooltip: tr('ui.savedTooltip'), onPressed: () => setState(() => page = 4), icon: Icon(saved.isNotEmpty ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 23)),
      IconButton(tooltip: tr('ui.infoTooltip'), onPressed: _info, icon: const Icon(Icons.info_outline_rounded)),
    ]),
  );

  Widget _tag(String text, {Color color = lavender}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24)),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: ink)),
  );

  Widget _welcome() => ListView(padding: const EdgeInsets.fromLTRB(26, 12, 26, 32), children: [
    const SizedBox(height: 24),
    Align(alignment: Alignment.centerLeft, child: _tag('REIMAGINE THE EVERYDAY', color: blush)),
    const SizedBox(height: 22),
    Text(tr('ui.heroTitle'), style: TextStyle(
      fontSize: 39, height: 1.12, letterSpacing: -1.4, fontWeight: FontWeight.w700, color: ink)),
    const SizedBox(height: 18),
    Text(tr('ui.heroSub'),
      style: TextStyle(fontSize: 15, color: muted, height: 1.65)),
    const SizedBox(height: 30),
    Container(height: 244, decoration: BoxDecoration(
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFFFFECEC), Color(0xFFEAE4F4)]),
      borderRadius: BorderRadius.circular(30)),
      child: Stack(children: [
        Positioned(top: 23, left: 22, child: Text('THE REWEAR EDIT',
          style: TextStyle(fontSize: 11, letterSpacing: 2, color: Color(0xBF6D3E59), fontWeight: FontWeight.w700))),
        Positioned(left: 28, bottom: 35, child: Transform.rotate(angle: -0.12,
          child: Container(width: 119, height: 126, decoration: BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(23), boxShadow: const [BoxShadow(color: Color(0x126D3E59), blurRadius: 15)]),
            child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.dry_cleaning_outlined, color: plum, size: 51), SizedBox(height: 9),
              Text('BEFORE', style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: muted))])))),
        const Center(child: Icon(Icons.arrow_forward_rounded, color: plum, size: 31)),
        Positioned(right: 24, top: 65, child: Transform.rotate(angle: 0.10,
          child: Container(width: 119, height: 126, decoration: BoxDecoration(color: plum,
            borderRadius: BorderRadius.circular(23), boxShadow: const [BoxShadow(color: Color(0x186D3E59), blurRadius: 15)]),
            child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.auto_awesome_outlined, color: Colors.white, size: 51), SizedBox(height: 9),
              Text('AFTER', style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: Colors.white))])))),
        const Positioned(right: 24, bottom: 15, child: Text('made to be remade',
          style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: plum))),
      ])),
    const SizedBox(height: 32),
    SizedBox(width: double.infinity, child: FilledButton.icon(
      onPressed: () => setState(() => page = 1), icon: const Icon(Icons.arrow_forward_rounded),
      label: Text(tr('ui.discover')))),
    const SizedBox(height: 8),
    Center(child: TextButton.icon(onPressed: _randomObject,
      icon: const Icon(Icons.shuffle_rounded, size: 18), label: Text(tr('ui.random')))),
    const SizedBox(height: 14),
    
  ]);

  Widget _objectPage() {
    final filtered = objects.entries.where((e) => e.value.toLowerCase().contains(search.trim().toLowerCase())).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(24, 16, 24, 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tr('ui.step1'), style: TextStyle(color: plum, fontWeight: FontWeight.w700, letterSpacing: 1.5, fontSize: 12)),
        SizedBox(height: 9), Text(tr('ui.pickTitle'), style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: ink)),
        SizedBox(height: 8), Text(tr('ui.pickSub'), style: TextStyle(color: muted)),
      ])),
      Padding(padding: const EdgeInsets.fromLTRB(24, 15, 24, 10), child: TextField(
        onChanged: (v) => setState(() => search = v),
        decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: tr('ui.search')),
      )),
      Expanded(child: filtered.isEmpty ? Center(child: Text(tr('ui.noObject'))) :
        GridView.builder(padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.04, crossAxisSpacing: 13, mainAxisSpacing: 13),
          itemCount: filtered.length, itemBuilder: (ctx, index) {
            final e = filtered[index];
            final sample = ideas.firstWhere((i) => i.objectId == e.key);
            return InkWell(borderRadius: BorderRadius.circular(24),
              onTap: () => setState(() { chosenObject = e.key; page = 2; }),
              child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(
                color: index.isEven ? blush : lavender, borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white, width: 1.5)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Icon(iconFor(sample.location), color: plum, size: 35),
                  Text(e.value, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: ink)),
                  const Align(alignment: Alignment.centerRight, child: Icon(Icons.arrow_outward_rounded, color: plum, size: 19)),
                ])),
            );
          })),
    ]);
  }

  Widget _choiceGroup(String heading, Map<String, String> options, String selected, ValueChanged<String> change) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(heading, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      const SizedBox(height: 13),
      Wrap(spacing: 9, runSpacing: 9, children: options.entries.map((e) => ChoiceChip(
        label: Text(identical(options, occasions) ? occasionLabel(e.key) : styleLabel(e.key)), selected: selected == e.key, onSelected: (_) => change(e.key),
        selectedColor: blush, backgroundColor: Colors.white,
        side: BorderSide(color: selected == e.key ? plum : const Color(0xFFEFE8E8)),
        labelStyle: TextStyle(color: selected == e.key ? plum : ink, fontWeight: FontWeight.w700),
      )).toList()),
    ]);

  Widget _preferences() => ListView(padding: const EdgeInsets.fromLTRB(24, 16, 24, 30), children: [
    Text(tr('ui.step2'), style: TextStyle(color: plum, fontWeight: FontWeight.w700, letterSpacing: 1.5, fontSize: 12)),
    const SizedBox(height: 9),
    Text(tr('ui.customTitle'), style: TextStyle(fontSize: 29, fontWeight: FontWeight.w700, color: ink)),
    const SizedBox(height: 8),
    Text(tr('ui.customSub'), style: TextStyle(color: muted)),
    const SizedBox(height: 23),
    Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: lavender, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [const Icon(Icons.inventory_2_outlined, size: 30, color: plum), const SizedBox(width: 15),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tr('ui.yourObject'), style: TextStyle(fontSize: 10, color: muted, fontWeight: FontWeight.bold)),
          Text(objects[chosenObject] ?? '', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))])),
        TextButton(onPressed: () => setState(() => page = 1), child: Text(tr('ui.change')))])),
    const SizedBox(height: 28),
    _choiceGroup(tr('ui.occasionQuestion'), occasions, occasion, (v) => setState(() => occasion = v)),
    const SizedBox(height: 27),
    _choiceGroup(tr('ui.styleQuestion'), styles, style, (v) => setState(() => style = v)),
    const SizedBox(height: 30),
    FilledButton.icon(onPressed: () => setState(() => page = 3),
      icon: const Icon(Icons.auto_awesome_rounded), label: Text(tr('ui.showIdeas'))),
  ]);

  Widget _ideaCard(Idea idea, int rank) {
    final exactOccasion = occasion != 'any' && occasion == idea.occasion;
    final exactStyle = style != 'any' && style == idea.style;
    final match = exactOccasion && exactStyle ? tr('ui.both') :
      exactOccasion ? tr('ui.occasionMatch') : exactStyle ? tr('ui.styleMatch') : tr('ui.alternative');
    return Container(margin: const EdgeInsets.only(bottom: 14), decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(23), color: Colors.white, border: Border.all(color: line),
      boxShadow: const [BoxShadow(color: Color(0x086D3E59), blurRadius: 10, offset: Offset(0, 3))]),
      child: InkWell(borderRadius: BorderRadius.circular(23), onTap: () => _details(idea),
        child: Padding(padding: const EdgeInsets.all(16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 81, height: 103, alignment: Alignment.center,
            decoration: BoxDecoration(color: rank.isEven ? blush : lavender, borderRadius: BorderRadius.circular(18)),
            child: Icon(iconFor(idea.location), color: plum, size: 37)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${tr('ui.idea')} #${rank + 1}', style: const TextStyle(fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w700, color: plum)),
            const SizedBox(height: 5),
            Text(ideaLabel(idea), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ink)),
            const SizedBox(height: 8),
            Text(match, style: const TextStyle(fontSize: 12, color: muted)),
            const SizedBox(height: 7),
            Text('${locationLabel(idea.location)} · ${styleLabel(idea.style)}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: plum)),
          ])),
          IconButton(tooltip: tr('ui.saveTooltip'), constraints: const BoxConstraints(), padding: EdgeInsets.zero,
            onPressed: () => setState(() { if (!saved.add(idea.id)) saved.remove(idea.id); }),
            icon: Icon(saved.contains(idea.id) ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: saved.contains(idea.id) ? plum : muted)),
        ]))),
    );
  }

  Widget _results() {
    final results = ranked;
    return ListView(padding: const EdgeInsets.fromLTRB(24, 16, 24, 28), children: [
      Text(tr('ui.step3'), style: TextStyle(color: plum, fontWeight: FontWeight.w700, letterSpacing: 1.5, fontSize: 12)),
      const SizedBox(height: 9),
      Text(tr('ui.resultsTitle'), style: TextStyle(fontSize: 29, fontWeight: FontWeight.w700, color: ink)),
      const SizedBox(height: 8),
      Text(appLanguage == 'en' ? 'Found ${results.length} ideas for: ${objects[chosenObject] ?? ''}' : 'Βρήκαμε ${results.length} ιδέες για: ${objects[chosenObject] ?? ''}', style: const TextStyle(color: muted)),
      const SizedBox(height: 13),
      Text(tr('ui.resultsNote'),
        style: TextStyle(color: muted, fontSize: 12)),
      const SizedBox(height: 20),
      ...results.asMap().entries.map((e) => _ideaCard(e.value, e.key)),
      const SizedBox(height: 12),
      OutlinedButton.icon(onPressed: () => setState(() => page = 2),
        icon: const Icon(Icons.tune_rounded), label: Text(tr('ui.adjust'))),
      TextButton(onPressed: () => setState(() { page = 1; search = ''; }), child: Text(tr('ui.another'))),
    ]);
  }

  Widget _savedPage() {
    final list = ideas.where((e) => saved.contains(e.id)).toList();
    return ListView(padding: const EdgeInsets.fromLTRB(24, 16, 24, 28), children: [
      Text(tr('ui.collection'), style: TextStyle(color: plum, fontWeight: FontWeight.w700, letterSpacing: 1.5, fontSize: 12)),
      const SizedBox(height: 9),
      Text(tr('ui.favorites'), style: TextStyle(fontSize: 29, fontWeight: FontWeight.w700, color: ink)),
      const SizedBox(height: 15),
      if (list.isEmpty) ...[
        const SizedBox(height: 80),
        Center(child: Container(width: 84, height: 84, decoration: const BoxDecoration(color: blush, shape: BoxShape.circle), child: const Icon(Icons.favorite_border_rounded, size: 34, color: plum))),
        const SizedBox(height: 18), Center(child: Text(tr('ui.noSaved'), textAlign: TextAlign.center, style: const TextStyle(color: muted))),
        const SizedBox(height: 20), FilledButton(onPressed: () => setState(() => page = 1), child: Text(tr('ui.findIdeas'))),
      ] else ...list.asMap().entries.map((e) => _ideaCard(e.value, e.key)),
    ]);
  }

  void _details(Idea idea) => showModalBottomSheet<void>(context: context,
    isScrollControlled: true, showDragHandle: true, backgroundColor: cream,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
    builder: (ctx) => StatefulBuilder(builder: (ctx, localSetState) => SafeArea(
      child: Padding(padding: EdgeInsets.fromLTRB(24, 8, 24, 20 + MediaQuery.viewInsetsOf(ctx).bottom),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(height: 160, width: double.infinity, alignment: Alignment.center,
              decoration: BoxDecoration(color: blush, borderRadius: BorderRadius.circular(24)),
              child: Icon(iconFor(idea.location), color: plum, size: 76)),
            const SizedBox(height: 20),
            Text(ideaLabel(idea), style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6), Text('${tr('ui.from')} ${objectLabel(idea)}', style: const TextStyle(color: muted)),
            const SizedBox(height: 16),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _tag(styleLabel(idea.style)), _tag(occasionLabel(idea.occasion), color: blush),
              _tag(idea.difficulty == 'easy' ? tr('ui.easy') : tr('ui.medium')),
            ]),
            const SizedBox(height: 21),
            Text(tr('ui.how'), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 7),
            Text(appLanguage == 'en' ? 'Style your object as “${ideaLabel(idea)}” to give your look a fresh twist.' : 'Χρησιμοποίησε το αντικείμενο ως «${ideaLabel(idea).toLowerCase()}» για να δώσεις μια απρόσμενη πινελιά στο look σου.'),
            const SizedBox(height: 15),
            if (idea.extras) Text(tr('ui.extras'), style: TextStyle(color: muted)),
            const SizedBox(height: 14),
            Text(tr('ui.safety'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 7), Text(safetyLabel(idea), style: const TextStyle(color: muted)),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: FilledButton.icon(
              onPressed: () { setState(() { if (!saved.add(idea.id)) saved.remove(idea.id); }); localSetState(() {}); },
              icon: Icon(saved.contains(idea.id) ? Icons.favorite_rounded : Icons.favorite_border_rounded),
              label: Text(saved.contains(idea.id) ? tr('ui.saved') : tr('ui.save')))),
          ]))))));

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520),
      child: Column(children: [
        _topBar(back: page != 0),
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
