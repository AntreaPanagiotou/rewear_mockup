import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const ReWearApp());

const ink = Color(0xFF262127);
const muted = Color(0xFF786E77);
const plum = Color(0xFF6D3E59);
const blush = Color(0xFFFFE7E9);
const cream = Color(0xFFFFF9F4);
const lavender = Color(0xFFEAE4F4);

class Idea {
  final String id, objectId, objectName, material, size, transformation;
  final String location, occasion, style, difficulty, notes;
  final bool extras;
  const Idea({required this.id, required this.objectId, required this.objectName,
    required this.material, required this.size, required this.transformation,
    required this.location, required this.occasion, required this.style,
    required this.difficulty, required this.notes, required this.extras});
  factory Idea.fromJson(Map<String, dynamic> j) => Idea(
    id: '${j['recommendation_id'] ?? ''}', objectId: '${j['object_id'] ?? ''}',
    objectName: '${j['object_name_el'] ?? ''}', material: '${j['object_material'] ?? ''}',
    size: '${j['object_size'] ?? ''}', transformation: '${j['transformation_el'] ?? ''}',
    location: '${j['wear_location'] ?? ''}', occasion: '${j['occasion'] ?? ''}',
    style: '${j['style'] ?? ''}', difficulty: '${j['difficulty'] ?? ''}',
    notes: '${j['safety_notes_el'] ?? ''}',
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

String emojiFor(String location) => switch (location) {
  'hair' => '🎀', 'hat' => '👒', 'bag' => '👜', 'wrist' => '🪡',
  'neck' => '🧣', 'shoulders' => '🧥', 'waist' => '✨', _ => '🌷',
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
        headlineLarge: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -1.3, color: ink),
        headlineMedium: TextStyle(fontWeight: FontWeight.w800, color: ink),
        titleLarge: TextStyle(fontWeight: FontWeight.w800, color: ink),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Δεν φορτώθηκαν οι προτάσεις: $e')));
    }
  }

  Map<String, String> get objects => {
    for (final i in ideas) i.objectId: i.objectName,
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
        const Text('🌸  Τι είναι το ReWear;', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
        const SizedBox(height: 14),
        const Text('Μεταμόρφωσε αντικείμενα που ήδη έχεις σε απρόσμενα αξεσουάρ. Διάλεξε αντικείμενο, περίσταση και στυλ και ανακάλυψε ιδέες!'),
        const SizedBox(height: 12),
        const Text('Αυτή είναι μια διαδραστική προεπισκόπηση (HW1). Οι προτάσεις προέρχονται από συνθετικό dataset. Δεν υπάρχει ακόμη εκπαιδευμένο recommender ή αυτόματη αναγνώριση εικόνας.', style: TextStyle(color: muted)),
        const SizedBox(height: 18),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Κατάλαβα!'))),
      ]))),
  );

  Widget _topBar({bool back = false}) => Padding(
    padding: const EdgeInsets.fromLTRB(22, 14, 22, 12),
    child: Row(children: [
      if (back) IconButton(onPressed: () => setState(() => page = page == 4 ? 0 : page - 1), icon: const Icon(Icons.arrow_back_ios_new_rounded))
      else const Text('✳', style: TextStyle(fontSize: 28, color: plum)),
      const SizedBox(width: 7),
      const Expanded(child: Text('rewear.', style: TextStyle(fontSize: 24, letterSpacing: -1, fontWeight: FontWeight.w900, color: ink))),
      IconButton(tooltip: 'Αποθηκευμένα', onPressed: () => setState(() => page = 4), icon: Badge(
        isLabelVisible: saved.isNotEmpty, label: Text('${saved.length}'), child: const Icon(Icons.favorite_border_rounded))),
      IconButton(tooltip: 'Πληροφορίες', onPressed: _info, icon: const Icon(Icons.info_outline_rounded)),
    ]),
  );

  Widget _tag(String text, {Color color = lavender}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24)),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: ink)),
  );

  Widget _welcome() => ListView(padding: const EdgeInsets.fromLTRB(24, 18, 24, 28), children: [
    const SizedBox(height: 30),
    _tag('STYLE WHAT YOU ALREADY OWN', color: blush),
    const SizedBox(height: 22),
    const Text('Ordinary objects.\nExtraordinary style.', style: TextStyle(
      fontSize: 43, height: 1.07, letterSpacing: -2, fontWeight: FontWeight.w900, color: ink)),
    const SizedBox(height: 15),
    const Text('Δώσε μια δεύτερη ζωή σε καθημερινά αντικείμενα.\nΗ πιο δημιουργική ντουλάπα είναι ήδη γύρω σου.',
      style: TextStyle(fontSize: 15, color: muted, height: 1.6)),
    const SizedBox(height: 32),
    Container(height: 230, decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFFF9D6D8), Color(0xFFE7DCF1)]),
      borderRadius: BorderRadius.circular(32)),
      child: const Stack(alignment: Alignment.center, children: [
        Positioned(left: 18, top: 24, child: Text('✿', style: TextStyle(fontSize: 60, color: Colors.white))),
        Text('🧣  ➜  🎀', style: TextStyle(fontSize: 56)),
        Positioned(right: 17, bottom: 22, child: Text('make it yours ↗', style: TextStyle(fontWeight: FontWeight.w700, color: plum))),
      ])),
    const SizedBox(height: 28),
    SizedBox(width: double.infinity, child: FilledButton.icon(
      onPressed: () => setState(() => page = 1), icon: const Icon(Icons.auto_awesome_rounded), label: const Text('Βρες την επόμενη ιδέα σου'))),
    const SizedBox(height: 10),
    Center(child: TextButton.icon(onPressed: _randomObject, icon: const Icon(Icons.shuffle_rounded), label: const Text('Έκπληξέ με με ένα αντικείμενο'))),
    const SizedBox(height: 14),
    Text('${objects.length} αντικείμενα  ·  ${ideas.length} δημιουργικές ιδέες',
      textAlign: TextAlign.center, style: const TextStyle(color: muted, fontSize: 12)),
  ]);

  Widget _objectPage() {
    final filtered = objects.entries.where((e) => e.value.toLowerCase().contains(search.trim().toLowerCase())).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(padding: EdgeInsets.fromLTRB(24, 16, 24, 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('ΒΗΜΑ 01 / 03', style: TextStyle(color: plum, fontWeight: FontWeight.w800, letterSpacing: 1.5, fontSize: 12)),
        SizedBox(height: 9), Text('Τι έχεις διαθέσιμο;', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: ink)),
        SizedBox(height: 8), Text('Διάλεξε ένα συνηθισμένο αντικείμενο για μια ασυνήθιστη ιδέα.', style: TextStyle(color: muted)),
      ])),
      Padding(padding: const EdgeInsets.fromLTRB(24, 15, 24, 10), child: TextField(
        onChanged: (v) => setState(() => search = v),
        decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Αναζήτησε αντικείμενο…'),
      )),
      Expanded(child: filtered.isEmpty ? const Center(child: Text('Δεν βρέθηκε αντικείμενο.')) :
        GridView.builder(padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.04, crossAxisSpacing: 13, mainAxisSpacing: 13),
          itemCount: filtered.length, itemBuilder: (ctx, index) {
            final e = filtered[index];
            final sample = ideas.firstWhere((i) => i.objectId == e.key);
            return InkWell(borderRadius: BorderRadius.circular(24),
              onTap: () => setState(() { chosenObject = e.key; page = 2; }),
              child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(
                color: index.isEven ? blush : lavender, borderRadius: BorderRadius.circular(24)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(emojiFor(sample.location), style: const TextStyle(fontSize: 39)),
                  Text(e.value, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: ink)),
                  const Align(alignment: Alignment.centerRight, child: Icon(Icons.arrow_outward_rounded, color: plum, size: 19)),
                ])),
            );
          })),
    ]);
  }

  Widget _choiceGroup(String heading, Map<String, String> options, String selected, ValueChanged<String> change) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(heading, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      const SizedBox(height: 13),
      Wrap(spacing: 9, runSpacing: 9, children: options.entries.map((e) => ChoiceChip(
        label: Text(e.value), selected: selected == e.key, onSelected: (_) => change(e.key),
        selectedColor: blush, backgroundColor: Colors.white,
        side: BorderSide(color: selected == e.key ? plum : const Color(0xFFEFE8E8)),
        labelStyle: TextStyle(color: selected == e.key ? plum : ink, fontWeight: FontWeight.w700),
      )).toList()),
    ]);

  Widget _preferences() => ListView(padding: const EdgeInsets.fromLTRB(24, 16, 24, 30), children: [
    const Text('ΒΗΜΑ 02 / 03', style: TextStyle(color: plum, fontWeight: FontWeight.w800, letterSpacing: 1.5, fontSize: 12)),
    const SizedBox(height: 9),
    const Text('Κάν’ το δικό σου.', style: TextStyle(fontSize: 31, fontWeight: FontWeight.w900, color: ink)),
    const SizedBox(height: 8),
    const Text('Επίλεξε πού θα πας και τι διάθεση έχεις σήμερα.', style: TextStyle(color: muted)),
    const SizedBox(height: 23),
    Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: lavender, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [const Text('🎁', style: TextStyle(fontSize: 32)), const SizedBox(width: 15),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('ΤΟ ΑΝΤΙΚΕΙΜΕΝΟ ΣΟΥ', style: TextStyle(fontSize: 10, color: muted, fontWeight: FontWeight.bold)),
          Text(objects[chosenObject] ?? '', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))])),
        TextButton(onPressed: () => setState(() => page = 1), child: const Text('Αλλαγή'))])),
    const SizedBox(height: 28),
    _choiceGroup('Ποια είναι η περίσταση;', occasions, occasion, (v) => setState(() => occasion = v)),
    const SizedBox(height: 27),
    _choiceGroup('Ποιο είναι το στυλ σου;', styles, style, (v) => setState(() => style = v)),
    const SizedBox(height: 30),
    FilledButton.icon(onPressed: () => setState(() => page = 3),
      icon: const Icon(Icons.auto_awesome_rounded), label: const Text('Δείξε μου ιδέες')),
  ]);

  Widget _ideaCard(Idea idea, int rank) {
    final exactOccasion = occasion != 'any' && occasion == idea.occasion;
    final exactStyle = style != 'any' && style == idea.style;
    final match = exactOccasion && exactStyle ? 'Ταιριάζει σε περίσταση & στυλ' :
      exactOccasion ? 'Ταιριάζει στην περίσταση' : exactStyle ? 'Ταιριάζει στο στυλ' : 'Εναλλακτική ιδέα για σένα';
    return Container(margin: const EdgeInsets.only(bottom: 14), decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(26), color: Colors.white,
      boxShadow: const [BoxShadow(color: Color(0x0D6D3E59), blurRadius: 14, offset: Offset(0, 5))]),
      child: InkWell(borderRadius: BorderRadius.circular(26), onTap: () => _details(idea),
        child: Padding(padding: const EdgeInsets.all(16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 81, height: 103, alignment: Alignment.center,
            decoration: BoxDecoration(color: rank.isEven ? blush : lavender, borderRadius: BorderRadius.circular(18)),
            child: Text(emojiFor(idea.location), style: const TextStyle(fontSize: 38))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('IDEA #${rank + 1}', style: const TextStyle(fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w900, color: plum)),
            const SizedBox(height: 5),
            Text(idea.transformation, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: ink)),
            const SizedBox(height: 8),
            Text(match, style: const TextStyle(fontSize: 12, color: muted)),
            const SizedBox(height: 7),
            Text('${locations[idea.location] ?? idea.location} · ${styles[idea.style] ?? idea.style}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: plum)),
          ])),
          IconButton(tooltip: 'Αποθήκευση', constraints: const BoxConstraints(), padding: EdgeInsets.zero,
            onPressed: () => setState(() { if (!saved.add(idea.id)) saved.remove(idea.id); }),
            icon: Icon(saved.contains(idea.id) ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: saved.contains(idea.id) ? plum : muted)),
        ]))),
    );
  }

  Widget _results() {
    final results = ranked;
    return ListView(padding: const EdgeInsets.fromLTRB(24, 16, 24, 28), children: [
      const Text('ΒΗΜΑ 03 / 03', style: TextStyle(color: plum, fontWeight: FontWeight.w800, letterSpacing: 1.5, fontSize: 12)),
      const SizedBox(height: 9),
      const Text('Your rewear edit ✨', style: TextStyle(fontSize: 31, fontWeight: FontWeight.w900, color: ink)),
      const SizedBox(height: 8),
      Text('Βρήκαμε ${results.length} ιδέες για: ${objects[chosenObject] ?? ''}', style: const TextStyle(color: muted)),
      const SizedBox(height: 13),
      const Text('Οι προτάσεις κατατάσσονται ενδεικτικά βάσει των επιλογών σου.',
        style: TextStyle(color: muted, fontSize: 12)),
      const SizedBox(height: 20),
      ...results.asMap().entries.map((e) => _ideaCard(e.value, e.key)),
      const SizedBox(height: 12),
      OutlinedButton.icon(onPressed: () => setState(() => page = 2),
        icon: const Icon(Icons.tune_rounded), label: const Text('Άλλαξε περίσταση / στυλ')),
      TextButton(onPressed: () => setState(() { page = 1; search = ''; }), child: const Text('Δοκίμασε άλλο αντικείμενο')),
    ]);
  }

  Widget _savedPage() {
    final list = ideas.where((e) => saved.contains(e.id)).toList();
    return ListView(padding: const EdgeInsets.fromLTRB(24, 16, 24, 28), children: [
      const Text('ΣΥΛΛΟΓΗ', style: TextStyle(color: plum, fontWeight: FontWeight.w800, letterSpacing: 1.5, fontSize: 12)),
      const SizedBox(height: 9),
      const Text('Οι αγαπημένες σου ♡', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900, color: ink)),
      const SizedBox(height: 15),
      if (list.isEmpty) ...[
        const SizedBox(height: 80), const Center(child: Text('💗', style: TextStyle(fontSize: 54))),
        const SizedBox(height: 12), const Center(child: Text('Δεν έχεις αποθηκεύσει ιδέες ακόμη.', style: TextStyle(color: muted))),
        const SizedBox(height: 20), FilledButton(onPressed: () => setState(() => page = 1), child: const Text('Βρες ιδέες')),
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
              child: Text(emojiFor(idea.location), style: const TextStyle(fontSize: 78))),
            const SizedBox(height: 20),
            Text(idea.transformation, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6), Text('Από: ${idea.objectName}', style: const TextStyle(color: muted)),
            const SizedBox(height: 16),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _tag(styles[idea.style] ?? idea.style), _tag(occasions[idea.occasion] ?? idea.occasion, color: blush),
              _tag(idea.difficulty == 'easy' ? 'Εύκολο' : 'Μέτριο'),
            ]),
            const SizedBox(height: 21),
            const Text('Η ιδέα', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 7),
            Text('Χρησιμοποίησε το αντικείμενο ως «${idea.transformation.toLowerCase()}» για να δώσεις μια απρόσμενη πινελιά στο look σου.'),
            const SizedBox(height: 15),
            if (idea.extras) const Text('Μπορεί να χρειαστούν επιπλέον υλικά για σταθερή εφαρμογή.', style: TextStyle(color: muted)),
            const SizedBox(height: 14),
            const Text('Σημείωση ασφαλείας', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 7), Text(idea.notes, style: const TextStyle(color: muted)),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: FilledButton.icon(
              onPressed: () { setState(() { if (!saved.add(idea.id)) saved.remove(idea.id); }); localSetState(() {}); },
              icon: Icon(saved.contains(idea.id) ? Icons.favorite_rounded : Icons.favorite_border_rounded),
              label: Text(saved.contains(idea.id) ? 'Αποθηκεύτηκε · Πάτα για αφαίρεση' : 'Αποθήκευσε την ιδέα'))),
          ]))))));

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520),
      child: Column(children: [
        _topBar(back: page != 0),
        Expanded(child: loading ? const Center(child: CircularProgressIndicator()) :
          ideas.isEmpty ? const Center(child: Text('Δεν βρέθηκαν δεδομένα. Έλεγξε το assets/data/recommendations.json.')) :
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
