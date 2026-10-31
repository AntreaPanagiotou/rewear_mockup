# ReWear the Unexpected — Flutter / Dart Interactive Mockup

Διαδραστικό mobile mockup για το HW1 (Flutter + Dart, χωρίς backend και χωρίς εξωτερικά packages πέρα από το Flutter SDK).

## Οδηγίες εκτέλεσης σε Windows / VS Code

1. Άνοιξε PowerShell/Terminal μέσα στον φάκελο όπου θέλεις το project.
2. Δημιούργησε το κανονικό Flutter scaffold:
   ```powershell
   flutter create --project-name rewear_unexpected rewear_unexpected
   ```
3. Άνοιξε τον φάκελο `rewear_unexpected` στο VS Code.
4. Από το ZIP που σου έδωσα αντέγραψε **μέσα στον φάκελο `rewear_unexpected`** τα αρχεία/φακέλους `lib`, `assets` και `pubspec.yaml`, επιλέγοντας αντικατάσταση (replace) όταν ερωτηθείς.
5. Στο terminal του VS Code:
   ```powershell
   flutter pub get
   flutter run -d edge
   ```
   Εναλλακτικά `flutter run -d windows` για desktop αν είναι ενεργοποιημένο.
6. Για mobile προεπισκόπηση στον Edge, πάτα `F12`, έπειτα `Ctrl+Shift+M`, επίλεξε κινητό.

**Σημείωση:** Το ZIP περιέχει τον κώδικα της εφαρμογής και το dataset, όχι τους αυτόματα παραγόμενους platform-specific φακέλους Android/iOS/Windows/Web. Η `flutter create` τους δημιουργεί σωστά στη δική σου εγκατάσταση.

## Τι λειτουργεί

- Welcome με οδηγίες/Info modal.
- Αναζήτηση και επιλογή ενός από 40 αντικείμενα.
- Φίλτρα περίστασης και στυλ.
- Κατάταξη 3 προτάσεων ανά αντικείμενο από 120 εγγραφές συνθετικού dataset (ενδεικτικός κανόνας κατάταξης, όχι ML).
- Οθόνη λεπτομερειών με tags και σημειώσεις ασφαλείας.
- Αγαπημένα (προσωρινά στη μνήμη εφαρμογής, μη μόνιμη αποθήκευση).
- Τυχαία επιλογή αντικειμένου.

## Dataset

`assets/data/recommendations.json`: οι 120 συνθετικές προτάσεις που δημιουργήθηκαν για αυτό το project.

Το `mockup` **δεν** διαθέτει εκπαιδευμένο μοντέλο, πραγματική πρόβλεψη, δυναμική δημιουργία εικόνων ή backend. Τα emoji είναι προσωρινά εικαστικά στοιχεία. Δεν ισχυρίζεται ότι οι περιγραφές αποτελούν πλήρεις οδηγίες κατασκευής.

## GitHub

Δημιούργησε private repository, ανέβασε τον φάκελο του πλήρους Flutter project, πρόσθεσε collaborator `tedaueb` και υπέβαλε το repository link στο e-class.
