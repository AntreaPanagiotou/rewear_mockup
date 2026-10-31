import 'package:flutter/material.dart';

// PhishGuard GR - Flutter mockup (ένα αρχείο, χωρίς εξωτερικά packages).
// ΣΗΜΕΙΩΣΗ ΓΙΑ ΤΗΝ ΕΡΓΑΣΙΑ / ΠΑΡΟΥΣΙΑΣΗ:
// - Το "predictive model" είναι rule-based scoring (κανόνες με βάρη), όχι εκπαιδευμένο ML μοντέλο.
// - Τα στατιστικά του Dashboard είναι DEMO δεδομένα.
// - Ιστορικό, αναφορές και σύνολα κρατιούνται μόνο στη μνήμη (χάνονται όταν κλείσει η εφαρμογή).

void main() => runApp(const PhishGuardApp());

const kBg = Color(0xFF1E1E2E);
const kBar = Color(0xFF181825);
const kCard = Color(0xFF313244);
const kAccent = Color(0xFFCBA6F7);
const kGreen = Color(0xFFA6E3A1);
const kYellow = Color(0xFFF9E2AF);
const kRed = Color(0xFFF38BA8);

// ---------- Μοντέλα ----------
class Reason {
  final bool bad;
  final String text;
  const Reason(this.bad, this.text);
}

class ScanResult {
  final String text;
  final int score;
  final List<Reason> reasons;
  const ScanResult(this.text, this.score, this.reasons);
}

class Tier {
  final Color color;
  final String label;
  final List<String> advice;
  const Tier(this.color, this.label, this.advice);
}

// ---------- Scoring ----------
// Αφαίρεση τόνων/κεφαλαίων ώστε να ταιριάζουν και κείμενα με ΚΕΦΑΛΑΙΑ
String norm(String s) {
  const map = {
    'ά': 'α', 'έ': 'ε', 'ή': 'η', 'ί': 'ι', 'ό': 'ο', 'ύ': 'υ', 'ώ': 'ω',
    'ϊ': 'ι', 'ϋ': 'υ', 'ΐ': 'ι', 'ΰ': 'υ', 'ς': 'σ',
  };
  final buf = StringBuffer();
  for (final ch in s.toLowerCase().split('')) {
    buf.write(map[ch] ?? ch);
  }
  return buf.toString();
}

ScanResult computeScore(String original) {
  final t = norm(original);
  int score = 0;
  final reasons = <Reason>[];

  final urlMatch = RegExp(r'https?://[^\s]+|www\.[^\s]+').firstMatch(t);
  if (urlMatch != null) {
    score += 20;
    reasons.add(const Reason(true, 'Το μήνυμα περιέχει σύνδεσμο.'));

    const official = ['elta.gr', 'eurobank.gr', 'alpha.gr', 'piraeusbank.gr', 'nbg.gr', 'dei.gr'];
    final host = urlMatch
        .group(0)!
        .replaceFirst(RegExp(r'^https?://'), '')
        .split(RegExp(r'[/?#]'))
        .first;
    final isOfficial = official.any((d) => host == d || host.endsWith('.$d'));
    if (!isOfficial) {
      score += 30;
      reasons.add(Reason(true, 'Ύποπτο domain: $host (δεν ανήκει στον επίσημο φορέα).'));
    }
    if (RegExp(r'\.(xyz|top|net|info|click|online)$').hasMatch(host)) {
      score += 10;
      reasons.add(const Reason(true, 'Ασυνήθιστη κατάληξη domain.'));
    }
  }

  const urgent = [
    'ανασταλ', 'κλειδωθηκε', 'αμεσα', 'επειγον', 'σημερα',
    'τελευταια ειδοποιηση', 'δεν επιδοθηκε',
  ];
  final hits = urgent.where((w) => t.contains(w)).length;
  if (hits > 0) {
    score += (hits * 12).clamp(0, 25);
    reasons.add(Reason(true, 'Επείγουσα γλώσσα ($hits ενδείξεις).'));
  }

  if (RegExp(r'(κωδικ|στοιχεια|καρτα|πληρωμ|επιβεβαι|ενημερωστε|πατηστε|συνδεσμο)').hasMatch(t)) {
    score += 15;
    reasons.add(const Reason(true, 'Ζητά ενέργεια, προσωπικά στοιχεία ή πληρωμή.'));
  }

  score = score.clamp(0, 98);
  if (score < 15) {
    score = score < 3 ? 3 : score;
    reasons.add(const Reason(false, 'Δεν εντοπίστηκαν ύποπτα στοιχεία.'));
  }
  return ScanResult(original, score, reasons);
}

// Τρεις βαθμίδες: <30 ασφαλές, 30-60 ύποπτο, >60 κίνδυνος
Tier tierOf(int score) {
  if (score < 30) {
    return const Tier(kGreen, 'ΧΑΜΗΛΟΣ ΚΙΝΔΥΝΟΣ (Ασφαλές)', [
      'Το μήνυμα φαίνεται ασφαλές.',
      'Αν έχετε αμφιβολία, επικοινωνήστε με τον φορέα από το επίσημο site του.',
    ]);
  }
  if (score <= 60) {
    return const Tier(kYellow, 'ΥΠΟΠΤΟ (Προσοχή)', [
      'Μην πατήσετε συνδέσμους χωρίς έλεγχο.',
      'Επικοινωνήστε με τον φορέα από το επίσημο site ή τηλέφωνο.',
      'Αν δεν είστε σίγουροι, αγνοήστε το μήνυμα.',
    ]);
  }
  return const Tier(kRed, 'ΥΨΗΛΟΣ ΚΙΝΔΥΝΟΣ (Phishing)', [
    'ΜΗΝ πατήσετε το σύνδεσμο.',
    'ΜΗΝ δώσετε κωδικούς ή στοιχεία κάρτας.',
    'Διαγράψτε το μήνυμα και αναφέρετέ το στην κοινότητα.',
  ]);
}

// ---------- App ----------
class PhishGuardApp extends StatelessWidget {
  const PhishGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PhishGuard GR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: kBg,
        colorScheme: const ColorScheme.dark(primary: kAccent, surface: kCard),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final _inputController = TextEditingController();
  final _reportController = TextEditingController();

  final List<ScanResult> _history = [];
  int _totalChecks = 12450; // demo βάση
  int _totalScams = 8910; // demo βάση

  static const _samples = {
    'elta':
        'ΕΛΤΑ: Το δέμα σας GR9823120 δεν επιδόθηκε λόγω λάθος διεύθυνσης. Παρακαλώ ενημερώστε τα στοιχεία σας εδώ: http://elta-post-verify.com/pay',
    'bank':
        'ΕΥΡΩΒΑΝΚ: Ο λογαριασμός σας έχει ανασταλεί προσωρινά. Πατήστε στον σύνδεσμο για ενεργοποίηση: https://eurobank-secure-login.net',
    'safe': 'Το ραντεβού σας με τον γιατρό είναι προγραμματισμένο για αύριο στις 10:00 πμ.',
  };

  // Demo δεδομένα Dashboard
  static const _targets = [
    ('ΕΛΤΑ / Courier', 42),
    ('Τράπεζες', 27),
    ('ΔΕΗ / ΕΥΔΑΠ', 14),
    ('Viva / Wolt / efood', 9),
    ('Άλλα', 8),
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _reportController.dispose();
    super.dispose();
  }

  void _toast(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        backgroundColor: error ? kRed : const Color(0xFFCDD6F4),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ));
  }

  void _analyzeText() {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      _toast('Εισάγετε κείμενο ή σύνδεσμο για έλεγχο.', error: true);
      return;
    }
    final res = computeScore(text);
    setState(() {
      _history.insert(0, res);
      if (_history.length > 3) _history.removeLast();
      _totalChecks++;
      if (res.score >= 30) _totalScams++;
    });
    _showResult(res);
  }

  void _submitReport() {
    if (_reportController.text.trim().isEmpty) {
      _toast('Γράψτε ή επικολλήστε το ύποπτο μήνυμα πρώτα.', error: true);
      return;
    }
    _reportController.clear();
    FocusScope.of(context).unfocus();
    setState(() => _currentIndex = 0);
    _toast('Η αναφορά στάλθηκε. Ευχαριστούμε!');
  }

  void _showResult(ScanResult r) {
    final tier = tierOf(r.score);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: tier.color.withAlpha(35),
                  border: Border.all(color: tier.color),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text('ΠΙΘΑΝΟΤΗΤΑ ΑΠΑΤΗΣ',
                        style: TextStyle(color: tier.color, fontSize: 12, letterSpacing: 1)),
                    Text('${r.score}%',
                        style: TextStyle(color: tier.color, fontSize: 38, fontWeight: FontWeight.w800)),
                    Text(tier.label,
                        style: TextStyle(color: tier.color, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: r.score / 100,
                        minHeight: 6,
                        color: tier.color,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('🤖 Αιτιολογία Predictive Model',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              for (final reason in r.reasons)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reason.bad ? '🚩 ' : '✅ '),
                      Expanded(
                        child: Text(reason.text, style: const TextStyle(color: Colors.white70)),
                      ),
                    ],
                  ),
                ),
              const Text('Rule-based scoring: κάθε κανόνας προσθέτει βάρος στο σκορ (0-98%).',
                  style: TextStyle(color: Colors.white38, fontSize: 11, fontStyle: FontStyle.italic)),
              const SizedBox(height: 16),
              const Text('💡 Συνιστώμενες Ενέργειες', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              for (int i = 0; i < tier.advice.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('${i + 1}. ${tier.advice[i]}',
                      style: const TextStyle(color: Colors.white70)),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(backgroundColor: kAccent),
                  child: const Text('Κλείσιμο', style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- UI helpers ----------
  Widget _card(String title, Widget child) {
    return Card(
      color: kCard,
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  Widget _note(String text) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(text,
            style: const TextStyle(color: Colors.white38, fontSize: 11, fontStyle: FontStyle.italic)),
      );

  String _fmt(int n) => n
      .toString()
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  // ---------- Οθόνες ----------
  Widget _buildCheck() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _card(
          '🔍 Έλεγχος Μηνύματος / Link',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _inputController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Επικολλήστε εδώ ύποπτο SMS, Email ή URL...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    label: const Text('⚠️ SMS ΕΛΤΑ'),
                    onPressed: () => _inputController.text = _samples['elta']!,
                  ),
                  ActionChip(
                    label: const Text('⚠️ SMS Τράπεζας'),
                    onPressed: () => _inputController.text = _samples['bank']!,
                  ),
                  ActionChip(
                    label: const Text('✅ Ασφαλές'),
                    onPressed: () => _inputController.text = _samples['safe']!,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _analyzeText,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Ανάλυση Επικινδυνότητας',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        _card(
          '🕘 Ιστορικό Ελέγχων',
          _history.isEmpty
              ? const Text('Δεν υπάρχουν έλεγχοι ακόμα. Δοκιμάστε ένα δείγμα παραπάνω.',
                  style: TextStyle(color: Colors.white70))
              : Column(
                  children: [
                    for (final h in _history)
                      InkWell(
                        onTap: () => _showResult(h),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: tierOf(h.score).color.withAlpha(40),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                alignment: Alignment.center,
                                child: Text('${h.score}%',
                                    style: TextStyle(
                                        color: tierOf(h.score).color, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(h.text,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
        _card(
          '📢 Τελευταίες Απάτες στην Ελλάδα',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '• Fake SMS από "ELTA Post" για εκκρεμές δέμα.\n• Ψεύτικη ειδοποίηση "Eurobank: Κλειδώθηκε ο λογαριασμός".',
                style: TextStyle(color: Colors.white70, height: 1.5),
              ),
              _note('Παραδείγματα για επίδειξη (demo δεδομένα).'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReport() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _card(
          '📣 Αναφορά Νέας Απάτης',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Βοηθήστε την κοινότητα αναφέροντας νέες τακτικές απάτης.',
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 10),
              TextField(
                controller: _reportController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Επικολλήστε το ύποπτο κείμενο ή τον αριθμό αποστολέα...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Υποβολή Αναφοράς',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
              _note(
                  'Στην πλήρη εφαρμογή οι αναφορές θα ελέγχονται και θα τροφοδοτούν τη λίστα γνωστών απατών. Στο mockup δεν αποθηκεύονται πουθενά.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: kBar, borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(color: kAccent, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _card(
          '📊 Στατιστικά Κοινότητας',
          Row(
            children: [
              _stat(_fmt(_totalChecks), 'Συνολικοί έλεγχοι'),
              const SizedBox(width: 10),
              _stat(_fmt(_totalScams), 'Αναγνωρισμένες απάτες'),
            ],
          ),
        ),
        _card(
          '🎯 Πιο Συχνοί Στόχοι Απάτης',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final t in _targets)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(t.$1, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          Text('${t.$2}%',
                              style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Stack(
                          children: [
                            Container(height: 10, color: kBar),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: t.$2 / 42),
                              duration: const Duration(milliseconds: 700),
                              builder: (context, v, _) => FractionallySizedBox(
                                widthFactor: v,
                                child: Container(height: 10, color: kAccent),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              _note(
                  'Τα στατιστικά είναι demo δεδομένα και δεν προέρχονται από πραγματική έρευνα. Οι έλεγχοι που κάνετε εδώ προστίθενται στα σύνολα.'),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛡️ PhishGuard GR'),
        centerTitle: true,
        backgroundColor: kBar,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [_buildCheck(), _buildReport(), _buildStats()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: kBar,
        selectedItemColor: kAccent,
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Έλεγχος'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: 'Αναφορά'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
        ],
      ),
    );
  }
}
