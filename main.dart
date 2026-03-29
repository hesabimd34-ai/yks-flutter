import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const YKSApp());
}

// ═══════════════════════════════════════════
// RENKLER
// ═══════════════════════════════════════════
class C {
  static const bg       = Color(0xFF07080F);
  static const surface  = Color(0xFF0E0F1C);
  static const surface2 = Color(0xFF161728);
  static const border   = Color(0xFF1E2035);
  static const accent   = Color(0xFF4F7CFF);
  static const green    = Color(0xFF2ECC8F);
  static const orange   = Color(0xFFFF8C42);
  static const red      = Color(0xFFFF4F6B);
  static const purple   = Color(0xFFA259FF);
  static const text     = Color(0xFFE8E9F5);
  static const text2    = Color(0xFF6B6D8A);
}

// ═══════════════════════════════════════════
// VERİ
// ═══════════════════════════════════════════
const Map<String, List<String>> TOPICS = {
  "📐 Matematik TYT": ["Temel Kavramlar","Sayı Basamakları","Bölme-Bölünebilme","OBEB-OKEK","Üslü Sayılar","Köklü Sayılar","Çarpanlara Ayırma","1.Derece Denklemler","Eşitsizlikler","Mutlak Değer","Oran-Orantı","Yüzde-Faiz","Problemler","Kümeler","Mantık","Fonksiyonlar","Olasılık","İstatistik","Sayı Dizileri"],
  "📐 Matematik AYT": ["Polinomlar","2.Derece Denklemler","Trigonometri","Logaritma","Diziler","Limit","Türev","İntegral","Analitik Geometri","Karmaşık Sayılar","Matrisler"],
  "🔬 Fizik TYT": ["Fizik Bilimine Giriş","Madde & Özellikleri","Kuvvet & Hareket","Enerji","Isı & Sıcaklık","Elektrostatik","Elektrik Akımı","Dalgalar & Ses","Optik"],
  "🔬 Fizik AYT": ["Vektörler","Kinematik","Dinamik","İş-Güç-Enerji","Momentum","Basit Harmonik Hareket","Dalgalar","Geometrik Optik","Elektrik Alanı","Manyetizma","Elektromanyetik İndüksiyon","Modern Fizik"],
  "⚗️ Kimya TYT": ["Kimya Bilimine Giriş","Atom Yapısı","Periyodik Tablo","Kimyasal Bağlar","Kimyasal Tepkimeler","Maddenin Halleri","Karışımlar","Asit-Baz Temelleri"],
  "⚗️ Kimya AYT": ["Mol Kavramı","Gazlar","Çözeltiler","Kimyasal Denge","Asit-Baz Dengesi","Elektrokimya","Reaksiyon Hızı","Organik Kimya","Hidrokarbonlar"],
  "🧬 Biyoloji TYT": ["Canlıların Ortak Özellikleri","Hücre","Canlıların Çeşitliliği","Ekosistem"],
  "🧬 Biyoloji AYT": ["Hücre Biyolojisi","Mitoz-Mayoz","Kalıtım","DNA & Replikasyon","Protein Sentezi","Sinir Sistemi","Hormon Sistemi","Sindirim","Dolaşım & Bağışıklık","Solunum","Boşaltım","Üreme & Gelişme","Ekoloji","Evrim"],
  "📚 Türkçe": ["Ses Bilgisi","Yazım Kuralları","Noktalama","İsim","Sıfat","Zamir","Zarf","Fiil","Fiilimsiler","Sözcükte Anlam","Cümlede Anlam","Paragraf","Ana Düşünce","Sözel Akıl Yürütme"],
  "🏛️ Tarih": ["İlk Çağ","Orta Çağ","İslam Tarihi","Osmanlı Kuruluş","Osmanlı Yükselme","Osmanlı Gerileme","I.Dünya Savaşı","Kurtuluş Savaşı","Türk İnkılabı","Atatürk İlkeleri","Yakın Dönem"],
  "🌍 Coğrafya": ["Harita Bilgisi","İklim","Nüfus & Yerleşme","Türkiye Coğrafyası","Tarım","Enerji & Maden","Küresel Sorunlar"],
  "⚖️ Felsefe": ["Felsefeye Giriş","Epistemoloji","Ontoloji","Ahlak Felsefesi","Siyaset Felsefesi","Mantık"],
};

const List<Map<String, String>> MOTIVATIONS = [
  {"t": "Bugün ekmek yemek istiyorsan dün tohum ekmiş olman lazım.", "a": "Çin Atasözü"},
  {"t": "Başarı, her gün tekrarlanan küçük çabaların toplamıdır.", "a": "Robert Collier"},
  {"t": "Zorlu yollar güzel manzaralara çıkar.", "a": "—"},
  {"t": "Disiplin, motivasyon olmadığı zamanlarda devreye girer.", "a": "—"},
  {"t": "Yavaş bile olsa ilerlemek, durmaktan iyidir.", "a": "—"},
  {"t": "Bir yıl sonra keşke bugün başlasaydım diyeceksin.", "a": "—"},
  {"t": "Kendine inan, yeterince çalışırsan başaramaycağın şey yok.", "a": "—"},
  {"t": "YKS bir maraton, yarın için bugün çalış.", "a": "—"},
];

// ═══════════════════════════════════════════
// VERİ YÖNETİCİSİ
// ═══════════════════════════════════════════
class DataManager extends ChangeNotifier {
  static final DataManager _i = DataManager._();
  factory DataManager() => _i;
  DataManager._();

  late SharedPreferences _prefs;
  Map<String, Map<String, bool>> progress = {};
  int totalPomodoros = 0;
  int totalBreakMin  = 0;
  int todayPomodoros = 0;
  int todayBreakMin  = 0;
  String todayDate   = '';
  List<Map<String, dynamic>> exams = [];
  Map<String, int> weekly = {};
  String tgToken  = '';
  String tgChatId = '';

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs.getString('yksData');
    if (raw != null) {
      try {
        final d = jsonDecode(raw) as Map<String, dynamic>;
        totalPomodoros = d['totalPomodoros'] ?? 0;
        totalBreakMin  = d['totalBreakMin']  ?? 0;
        todayPomodoros = d['todayPomodoros'] ?? 0;
        todayBreakMin  = d['todayBreakMin']  ?? 0;
        todayDate      = d['todayDate']      ?? '';
        tgToken        = d['tgToken']        ?? '';
        tgChatId       = d['tgChatId']       ?? '';
        exams = List<Map<String, dynamic>>.from(d['exams'] ?? []);
        weekly = Map<String, int>.from(d['weekly'] ?? {});
        final rawProg = d['progress'] as Map<String, dynamic>? ?? {};
        for (final s in TOPICS.keys) {
          progress[s] = {};
          final subj = rawProg[s] as Map<String, dynamic>? ?? {};
          for (final t in TOPICS[s]!) {
            progress[s]![t] = subj[t] as bool? ?? false;
          }
        }
      } catch (_) { _initProgress(); }
    } else { _initProgress(); }
    _resetDayIfNeeded();
  }

  void _initProgress() {
    for (final s in TOPICS.keys) {
      progress[s] = {for (final t in TOPICS[s]!) t: false};
    }
  }

  void _resetDayIfNeeded() {
    final today = _todayStr();
    if (todayDate != today) {
      todayPomodoros = 0;
      todayBreakMin  = 0;
      todayDate      = today;
      save();
    }
  }

  String _todayStr() => DateTime.now().toIso8601String().substring(0, 10);

  void save() {
    final d = {
      'totalPomodoros': totalPomodoros,
      'totalBreakMin':  totalBreakMin,
      'todayPomodoros': todayPomodoros,
      'todayBreakMin':  todayBreakMin,
      'todayDate':      todayDate,
      'tgToken':        tgToken,
      'tgChatId':       tgChatId,
      'exams':          exams,
      'weekly':         weekly,
      'progress':       progress.map((k, v) => MapEntry(k, v)),
    };
    _prefs.setString('yksData', jsonEncode(d));
    notifyListeners();
  }

  void toggleTopic(String subject, String topic) {
    progress[subject]![topic] = !(progress[subject]![topic] ?? false);
    save();
  }

  void addPomodoro() {
    totalPomodoros++;
    todayPomodoros++;
    final today = _todayStr();
    weekly[today] = (weekly[today] ?? 0) + 1;
    save();
  }

  void addBreak(int mins) {
    totalBreakMin += mins;
    todayBreakMin += mins;
    save();
  }

  void addExam(Map<String, dynamic> exam) {
    exams.add(exam);
    save();
  }

  (int, int) subjectProgress(String subject) {
    final topics = progress[subject] ?? {};
    final done = topics.values.where((v) => v).length;
    return (done, topics.length);
  }

  (int, int) overallProgress() {
    int done = 0, total = 0;
    for (final s in TOPICS.keys) {
      final (d, t) = subjectProgress(s);
      done += d; total += t;
    }
    return (done, total);
  }

  String buildReport(String type) {
    final now = DateTime.now();
    final nowStr = '${now.day}.${now.month}.${now.year} ${now.hour}:${now.minute.toString().padLeft(2,'0')}';
    final (done, total) = overallProgress();
    final pct = total > 0 ? (done / total * 100).round() : 0;
    final lines = <String>[
      '📊 YKS Raporu — Efe',
      '🕐 $nowStr',
      '',
    ];
    if (type == 'daily' || type == 'breaks') {
      lines.addAll([
        '🍅 Bugün: $todayPomodoros pomodoro',
        '☕ Bugün: $todayBreakMin dk mola',
        '🍅 Toplam: $totalPomodoros pomodoro',
        '☕ Toplam: $totalBreakMin dk mola',
      ]);
    }
    if (type == 'weekly') {
      lines.add('📅 Bu Hafta:');
      for (int i = 6; i >= 0; i--) {
        final d = DateTime.now().subtract(Duration(days: i));
        final key = d.toIso8601String().substring(0, 10);
        final cnt = weekly[key] ?? 0;
        lines.add('  ${key.substring(5)} → ${'🍅' * cnt.clamp(0, 10)} ($cnt)');
      }
    }
    lines.addAll(['', '📈 Genel: $done/$total (%$pct)', '']);
    for (final s in TOPICS.keys) {
      final (d, t) = subjectProgress(s);
      final p = t > 0 ? (d / t * 100).round() : 0;
      final bar = '█' * (p ~/ 10) + '░' * (10 - p ~/ 10);
      lines.add('$s\n  $bar %$p ($d/$t)');
    }
    if (exams.isNotEmpty) {
      final last = exams.last;
      lines.addAll(['', '📝 Son: ${last['name']} — TYT:${last['tyt']} AYT:${last['ayt']}']);
    }
    return lines.join('\n');
  }
}

// ═══════════════════════════════════════════
// APP
// ═══════════════════════════════════════════
class YKSApp extends StatelessWidget {
  const YKSApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YKS Efe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: C.bg,
        colorScheme: const ColorScheme.dark(primary: C.accent, background: C.bg),
        textTheme: GoogleFonts.syneTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

// ═══════════════════════════════════════════
// ANA EKRAN
// ═══════════════════════════════════════════
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _tab = 0;
  bool _loaded = false;
  final dm = DataManager();

  final _tabs = const [
    {'icon': Icons.home_rounded,      'label': 'Ana'},
    {'icon': Icons.timer_rounded,     'label': 'Pomodoro'},
    {'icon': Icons.book_rounded,      'label': 'Konular'},
    {'icon': Icons.calendar_month,    'label': 'Program'},
    {'icon': Icons.edit_note_rounded, 'label': 'Deneme'},
    {'icon': Icons.bar_chart_rounded, 'label': 'Grafik'},
    {'icon': Icons.send_rounded,      'label': 'Rapor'},
  ];

  @override
  void initState() {
    super.initState();
    dm.load().then((_) => setState(() => _loaded = true));
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        backgroundColor: C.bg,
        body: Center(child: CircularProgressIndicator(color: C.accent)),
      );
    }
    final pages = [
      DashboardPage(dm: dm),
      PomodoroPage(dm: dm),
      TopicsPage(dm: dm),
      WeeklyPage(dm: dm),
      DenemePage(dm: dm),
      StatsPage(dm: dm),
      TelegramPage(dm: dm),
    ];
    return Scaffold(
      backgroundColor: C.bg,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: KeyedSubtree(key: ValueKey(_tab), child: pages[_tab]),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0A0B17),
          border: Border(top: BorderSide(color: C.border)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 58,
            child: Row(
              children: List.generate(_tabs.length, (i) => Expanded(
                child: InkWell(
                  onTap: () => setState(() => _tab = i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_tabs[i]['icon'] as IconData,
                        size: 22,
                        color: _tab == i ? C.accent : C.text2),
                      const SizedBox(height: 2),
                      Text(_tabs[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: _tab == i ? C.accent : C.text2,
                        )),
                    ],
                  ),
                ),
              )),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// YARDIMCI WİDGET'LAR
// ═══════════════════════════════════════════
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const AppCard({super.key, required this.child, this.padding});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: padding ?? const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: C.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: C.border),
    ),
    child: child,
  );
}

class CardTitle extends StatelessWidget {
  final String text;
  const CardTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(text.toUpperCase(),
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
        letterSpacing: 1.5, color: C.text2)),
  );
}

class ProgBar extends StatelessWidget {
  final double value; // 0..1
  final Color color;
  const ProgBar({super.key, required this.value, this.color = C.accent});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(99),
    child: LinearProgressIndicator(
      value: value,
      backgroundColor: C.surface2,
      valueColor: AlwaysStoppedAnimation(color),
      minHeight: 7,
    ),
  );
}

class AppHeader extends StatelessWidget {
  final String title;
  const AppHeader(this.title, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.only(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16, right: 16, bottom: 12,
    ),
    decoration: const BoxDecoration(
      color: C.surface,
      border: Border(bottom: BorderSide(color: C.border)),
    ),
    child: Text(title, style: GoogleFonts.syne(
      fontSize: 20, fontWeight: FontWeight.w800, color: C.text)),
  );
}

Widget statBox(String icon, String val, String lbl, Color color) => Expanded(
  child: Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      color: C.surface2,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: C.border),
    ),
    child: Column(children: [
      Text(icon, style: const TextStyle(fontSize: 18)),
      const SizedBox(height: 3),
      Text(val, style: GoogleFonts.jetBrainsMono(
        fontSize: 20, fontWeight: FontWeight.w800, color: color)),
      const SizedBox(height: 1),
      Text(lbl, style: const TextStyle(fontSize: 9, color: C.text2)),
    ]),
  ),
);

// ═══════════════════════════════════════════
// DASHBOARD
// ═══════════════════════════════════════════
class DashboardPage extends StatefulWidget {
  final DataManager dm;
  const DashboardPage({super.key, required this.dm});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _motIdx = 0;
  Timer? _motTimer;

  @override
  void initState() {
    super.initState();
    _motTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      setState(() => _motIdx = (_motIdx + 1) % MOTIVATIONS.length);
    });
  }

  @override
  void dispose() { _motTimer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final dm = widget.dm;
    final yksDate = DateTime(2025, 6, 14);
    final daysLeft = yksDate.difference(DateTime.now()).inDays;
    final (done, total) = dm.overallProgress();
    final pct = total > 0 ? done / total : 0.0;
    final mot = MOTIVATIONS[_motIdx];

    return Column(children: [
      // Header
      Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16, right: 16, bottom: 12,
        ),
        decoration: const BoxDecoration(
          color: C.surface,
          border: Border(bottom: BorderSide(color: C.border)),
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [Colors.white, C.accent]).createShader(b),
              child: Text('YKS Paneli', style: GoogleFonts.syne(
                fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
            Text('Efe · ${DateTime.now().day} ${['Oca','Şub','Mar','Nis','May','Haz','Tem','Ağu','Eyl','Eki','Kas','Ara'][DateTime.now().month-1]} ${DateTime.now().year}',
              style: const TextStyle(fontSize: 10, color: C.text2)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: C.surface2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: C.border),
            ),
            child: Column(children: [
              Text('$daysLeft', style: GoogleFonts.jetBrainsMono(
                fontSize: 22, fontWeight: FontWeight.w800, color: C.orange)),
              const Text('GÜN KALDI', style: TextStyle(fontSize: 8, color: C.text2, letterSpacing: 1)),
            ]),
          ),
        ]),
      ),
      // Content
      Expanded(child: ListView(padding: const EdgeInsets.all(12), children: [
        // Motivasyon
        GestureDetector(
          onTap: () => setState(() => _motIdx = (_motIdx + 1) % MOTIVATIONS.length),
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [C.accent.withOpacity(.12), C.purple.withOpacity(.08)]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: C.accent.withOpacity(.25)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(mot['t']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.6)),
              const SizedBox(height: 6),
              Text('— ${mot['a']}', style: const TextStyle(fontSize: 11, color: C.text2, fontStyle: FontStyle.italic)),
            ]),
          ),
        ),
        // Stats
        Row(children: [
          statBox('🍅', '${dm.totalPomodoros}', 'Pomodoro', C.accent),
          const SizedBox(width: 8),
          statBox('☕', '${dm.totalBreakMin}', 'Mola dk', C.green),
          const SizedBox(width: 8),
          statBox('📅', '${dm.todayPomodoros}', 'Bugün', C.orange),
        ]),
        const SizedBox(height: 10),
        // Genel ilerleme
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CardTitle('Genel İlerleme'),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('$done/$total konu', style: const TextStyle(fontSize: 12)),
            Text('%${(pct * 100).round()}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: C.accent)),
          ]),
          const SizedBox(height: 6),
          ProgBar(value: pct),
        ])),
        // Ders ilerlemeleri
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CardTitle('Dersler'),
          ...TOPICS.keys.map((s) {
            final (d, t) = dm.subjectProgress(s);
            final p = t > 0 ? d / t : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(s, style: const TextStyle(fontSize: 11)),
                  Text('$d/$t', style: const TextStyle(fontSize: 10, color: C.text2)),
                ]),
                const SizedBox(height: 4),
                ProgBar(value: p),
              ]),
            );
          }),
        ])),
        // Son deneme
        if (dm.exams.isNotEmpty)
          AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const CardTitle('Son Deneme'),
            Text(dm.exams.last['name'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('TYT: ${dm.exams.last['tyt']}  ·  AYT: ${dm.exams.last['ayt']}',
              style: GoogleFonts.jetBrainsMono(fontSize: 18, color: C.accent, fontWeight: FontWeight.w700)),
            Text(dm.exams.last['date'] ?? '', style: const TextStyle(fontSize: 10, color: C.text2)),
          ])),
      ])),
    ]);
  }
}

// ═══════════════════════════════════════════
// POMODORO
// ═══════════════════════════════════════════
class PomodoroPage extends StatefulWidget {
  final DataManager dm;
  const PomodoroPage({super.key, required this.dm});
  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> with SingleTickerProviderStateMixin {
  int _rem = 25 * 60, _total = 25 * 60;
  bool _running = false, _isBreak = false;
  Timer? _timer;
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() { _timer?.cancel(); _animCtrl.dispose(); super.dispose(); }

  void _setMode(bool isBreak, int mins) {
    _pause();
    setState(() {
      _isBreak = isBreak;
      _rem = mins * 60;
      _total = mins * 60;
    });
  }

  void _toggle() { _running ? _pause() : _start(); }

  void _start() {
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_rem <= 0) { _timer?.cancel(); _done(); return; }
      setState(() => _rem--);
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _running = false);
  }

  void _reset() {
    _pause();
    setState(() => _rem = _total);
  }

  void _done() {
    if (!_isBreak) {
      widget.dm.addPomodoro();
      _setMode(true, 5);
    } else {
      widget.dm.addBreak(_total ~/ 60);
      _setMode(false, 25);
    }
    setState(() => _running = false);
  }

  String get _timeStr {
    final m = _rem ~/ 60, s = _rem % 60;
    return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _rem / _total;
    final color = _isBreak ? C.green : C.accent;
    return Column(children: [
      AppHeader(_isBreak ? '☕ Mola' : '🍅 Pomodoro'),
      Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
        AppCard(child: Column(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(_isBreak ? 'MOLA' : 'ÇALIŞMA',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color, letterSpacing: 1)),
          ),
          const SizedBox(height: 20),
          // Ring timer
          SizedBox(width: 200, height: 200, child: Stack(alignment: Alignment.center, children: [
            SizedBox(width: 200, height: 200,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 10,
                backgroundColor: C.surface2,
                valueColor: AlwaysStoppedAnimation(color),
                strokeCap: StrokeCap.round,
              )),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text(_timeStr, style: GoogleFonts.jetBrainsMono(
                fontSize: 38, fontWeight: FontWeight.w700, color: C.text)),
              Text(_isBreak ? 'dinlen' : 'odaklan',
                style: const TextStyle(fontSize: 11, color: C.text2)),
            ]),
          ])),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: ElevatedButton.icon(
              onPressed: _toggle,
              icon: Icon(_running ? Icons.pause_rounded : Icons.play_arrow_rounded),
              label: Text(_running ? 'Durdur' : (_rem < _total ? 'Devam' : 'Başlat')),
              style: ElevatedButton.styleFrom(
                backgroundColor: _running ? C.orange : C.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Sıfırla'),
              style: ElevatedButton.styleFrom(
                backgroundColor: C.surface2,
                foregroundColor: C.text,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _quickBtn('25 dk', () => _setMode(false, 25)),
            const SizedBox(width: 8),
            _quickBtn('50 dk', () => _setMode(false, 50)),
            const SizedBox(width: 8),
            _quickBtn('5 dk ☕', () => _setMode(true, 5)),
          ]),
        ])),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CardTitle('Bugünkü Seanslar'),
          if (widget.dm.todayPomodoros == 0)
            const Text('Henüz seans yok.', style: TextStyle(fontSize: 12, color: C.text2))
          else
            Wrap(spacing: 8, children: List.generate(widget.dm.todayPomodoros,
              (i) => Text('🍅', style: const TextStyle(fontSize: 22)))),
        ])),
      ])),
    ]);
  }

  Widget _quickBtn(String label, VoidCallback onTap) => Expanded(
    child: OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: C.text2,
        side: const BorderSide(color: C.border),
        backgroundColor: C.surface2,
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    ),
  );
}

// ═══════════════════════════════════════════
// TOPICS
// ═══════════════════════════════════════════
class TopicsPage extends StatefulWidget {
  final DataManager dm;
  const TopicsPage({super.key, required this.dm});
  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> {
  final Set<String> _open = {};

  @override
  Widget build(BuildContext context) {
    final dm = widget.dm;
    final (done, total) = dm.overallProgress();
    final pct = total > 0 ? done / total : 0.0;
    return Column(children: [
      AppHeader('📚 Konular'),
      Expanded(child: ListView(padding: const EdgeInsets.all(12), children: [
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CardTitle('Toplam İlerleme'),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('$done/$total', style: const TextStyle(fontSize: 12)),
            Text('%${(pct * 100).round()}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: C.green)),
          ]),
          const SizedBox(height: 6),
          ProgBar(value: pct, color: C.green),
        ])),
        ...TOPICS.keys.map((subject) {
          final (d, t) = dm.subjectProgress(subject);
          final p = t > 0 ? d / t : 0.0;
          final isOpen = _open.contains(subject);
          return Column(children: [
            GestureDetector(
              onTap: () => setState(() => isOpen ? _open.remove(subject) : _open.add(subject)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                margin: const EdgeInsets.only(bottom: 5),
                decoration: BoxDecoration(
                  color: C.surface2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isOpen ? C.accent : C.border),
                ),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(subject, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    ProgBar(value: p),
                  ])),
                  const SizedBox(width: 10),
                  Text('$d/$t', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: C.accent)),
                  const SizedBox(width: 6),
                  Icon(isOpen ? Icons.expand_less : Icons.expand_more, color: C.text2, size: 18),
                ]),
              ),
            ),
            if (isOpen)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: C.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: C.border),
                ),
                child: Column(
                  children: TOPICS[subject]!.map((topic) {
                    final isDone = dm.progress[subject]?[topic] ?? false;
                    return InkWell(
                      onTap: () { dm.toggleTopic(subject, topic); setState(() {}); },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                        child: Row(children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 18, height: 18,
                            decoration: BoxDecoration(
                              color: isDone ? C.green : Colors.transparent,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: isDone ? C.green : C.border, width: 2),
                            ),
                            child: isDone ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(topic,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDone ? C.text2 : C.text,
                              decoration: isDone ? TextDecoration.lineThrough : null,
                            ))),
                        ]),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ]);
        }),
      ])),
    ]);
  }
}

// ═══════════════════════════════════════════
// WEEKLY PROGRAM
// ═══════════════════════════════════════════
const List<String> DAYS = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
const Map<String, Color> BLOCK_COLORS = {
  '📐 Mat': C.accent,
  '🔬 Fiz': C.green,
  '⚗️ Kim': C.orange,
  '🧬 Bio': C.purple,
  '📚 Türkçe': C.red,
  '🏛️ Tarih': Color(0xFFF1C40F),
  '🌍 Coğ': Color(0xFF1ABC9C),
  '😴 Mola': C.text2,
};

class WeeklyPage extends StatefulWidget {
  final DataManager dm;
  const WeeklyPage({super.key, required this.dm});
  @override
  State<WeeklyPage> createState() => _WeeklyPageState();
}

class _WeeklyPageState extends State<WeeklyPage> {
  // weeklyPlan[day] = list of block names
  Map<int, List<String>> _plan = {};
  int? _draggingDay;
  String? _draggingBlock;
  int? _draggingIdx;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  void _loadPlan() {
    try {
      final raw = widget.dm._prefs.getString('weeklyPlan');
      if (raw != null) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _plan = decoded.map((k, v) => MapEntry(int.parse(k), List<String>.from(v)));
      }
    } catch (_) {}
  }

  void _savePlan() {
    final encoded = jsonEncode(_plan.map((k, v) => MapEntry('$k', v)));
    widget.dm._prefs.setString('weeklyPlan', encoded);
  }

  void _addBlock(int day, String block) {
    setState(() {
      _plan[day] = [...(_plan[day] ?? []), block];
    });
    _savePlan();
  }

  void _removeBlock(int day, int idx) {
    setState(() {
      final list = List<String>.from(_plan[day] ?? []);
      list.removeAt(idx);
      _plan[day] = list;
    });
    _savePlan();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      AppHeader('📅 Haftalık Program'),
      // Palet
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: C.border))),
        child: Wrap(
          spacing: 6, runSpacing: 6,
          children: BLOCK_COLORS.entries.map((e) => Draggable<String>(
            data: e.key,
            feedback: Material(color: Colors.transparent,
              child: _blockChip(e.key, e.value, small: false)),
            childWhenDragging: Opacity(opacity: .3, child: _blockChip(e.key, e.value)),
            child: _blockChip(e.key, e.value),
          )).toList(),
        ),
      ),
      // Grid
      Expanded(child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(7, (day) {
              final blocks = _plan[day] ?? [];
              return DragTarget<String>(
                onAcceptWithDetails: (d) => _addBlock(day, d.data),
                builder: (ctx, candidates, _) => AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 90,
                  margin: const EdgeInsets.only(right: 6),
                  constraints: const BoxConstraints(minHeight: 300),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: candidates.isNotEmpty
                      ? C.accent.withOpacity(.08) : C.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: candidates.isNotEmpty ? C.accent : C.border),
                  ),
                  child: Column(children: [
                    Text(DAYS[day], style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700,
                      color: C.text2, letterSpacing: .5)),
                    const SizedBox(height: 6),
                    ...blocks.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: GestureDetector(
                        onLongPress: () => _removeBlock(day, e.key),
                        child: _blockChip(e.value,
                          BLOCK_COLORS[e.value] ?? C.accent, small: true),
                      ),
                    )),
                  ]),
                ),
              );
            }),
          ),
        ),
      )),
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Row(children: [
          const Icon(Icons.info_outline, size: 12, color: C.text2),
          const SizedBox(width: 6),
          const Expanded(child: Text('Bloğu sürükle → güne bırak. Kaldırmak için uzun bas.',
            style: TextStyle(fontSize: 10, color: C.text2))),
          TextButton(
            onPressed: () { setState(() => _plan.clear()); _savePlan(); },
            child: const Text('Temizle', style: TextStyle(fontSize: 11, color: C.red)),
          ),
        ]),
      ),
    ]);
  }

  Widget _blockChip(String name, Color color, {bool small = false}) => Container(
    padding: EdgeInsets.symmetric(horizontal: small ? 6 : 10, vertical: small ? 5 : 7),
    decoration: BoxDecoration(
      color: color.withOpacity(.2),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(.5)),
    ),
    child: Text(name, style: TextStyle(
      fontSize: small ? 9 : 11, fontWeight: FontWeight.w700, color: color)),
  );
}

// ═══════════════════════════════════════════
// DENEME
// ═══════════════════════════════════════════
class DenemePage extends StatefulWidget {
  final DataManager dm;
  const DenemePage({super.key, required this.dm});
  @override
  State<DenemePage> createState() => _DenemePageState();
}

class _DenemePageState extends State<DenemePage> {
  final _name = TextEditingController();
  final _tyt  = TextEditingController();
  final _ayt  = TextEditingController();
  final _note = TextEditingController();
  String _date = DateTime.now().toIso8601String().substring(0, 10);

  void _add() {
    widget.dm.addExam({
      'name': _name.text.isEmpty ? 'Deneme' : _name.text,
      'tyt':  double.tryParse(_tyt.text) ?? 0,
      'ayt':  double.tryParse(_ayt.text) ?? 0,
      'date': _date,
      'note': _note.text,
    });
    _name.clear(); _tyt.clear(); _ayt.clear(); _note.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      AppHeader('📝 Deneme Sınavı'),
      Expanded(child: ListView(padding: const EdgeInsets.all(12), children: [
        AppCard(child: Column(children: [
          const CardTitle('Yeni Deneme Ekle'),
          _field('Sınav Adı', _name, 'TYT Deneme #1'),
          Row(children: [
            Expanded(child: _field('TYT Net', _tyt, '0', num: true)),
            const SizedBox(width: 8),
            Expanded(child: _field('AYT Net', _ayt, '0', num: true)),
          ]),
          _field('Not', _note, 'Opsiyonel...'),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _add,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Ekle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: C.accent, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )),
        ])),
        if (widget.dm.exams.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(20),
            child: Text('Henüz deneme eklenmedi.', style: TextStyle(color: C.text2))))
        else
          ...widget.dm.exams.reversed.map((e) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: C.surface2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: C.border),
            ),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${e['name']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                Text('${e['date']}${e['note'] != '' ? ' · ${e['note']}' : ''}',
                  style: const TextStyle(fontSize: 10, color: C.text2)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('TYT: ${e['tyt']}', style: GoogleFonts.jetBrainsMono(
                  fontSize: 15, fontWeight: FontWeight.w700, color: C.accent)),
                Text('AYT: ${e['ayt']}', style: GoogleFonts.jetBrainsMono(
                  fontSize: 13, color: C.purple)),
              ]),
            ]),
          )),
      ])),
    ]);
  }

  Widget _field(String label, TextEditingController ctrl, String hint, {bool num = false}) =>
    Padding(padding: const EdgeInsets.only(bottom: 8), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 9, color: C.text2, letterSpacing: 1)),
        const SizedBox(height: 3),
        TextField(
          controller: ctrl,
          keyboardType: num ? TextInputType.number : TextInputType.text,
          style: const TextStyle(fontSize: 13, color: C.text),
          decoration: InputDecoration(
            hintText: hint, hintStyle: const TextStyle(color: C.text2),
            filled: true, fillColor: C.surface2,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: C.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: C.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: C.accent)),
          ),
        ),
      ],
    ));
}

// ═══════════════════════════════════════════
// STATS
// ═══════════════════════════════════════════
class StatsPage extends StatelessWidget {
  final DataManager dm;
  const StatsPage({super.key, required this.dm});

  @override
  Widget build(BuildContext context) {
    final days = <String>[], counts = <double>[];
    for (int i = 6; i >= 0; i--) {
      final d = DateTime.now().subtract(Duration(days: i));
      final key = d.toIso8601String().substring(0, 10);
      days.add(['Pzt','Sal','Çar','Per','Cum','Cmt','Paz'][d.weekday - 1]);
      counts.add((dm.weekly[key] ?? 0).toDouble());
    }
    final (done, total) = dm.overallProgress();
    return Column(children: [
      AppHeader('📊 İstatistik'),
      Expanded(child: ListView(padding: const EdgeInsets.all(12), children: [
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CardTitle('Haftalık Pomodoro'),
          SizedBox(height: 160, child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final max = counts.reduce((a, b) => a > b ? a : b);
              final h = max > 0 ? counts[i] / max : 0.0;
              return Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  if (counts[i] > 0)
                    Text('${counts[i].round()}',
                      style: const TextStyle(fontSize: 9, color: C.accent)),
                  const SizedBox(height: 2),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height: 120 * h,
                    decoration: BoxDecoration(
                      color: C.accent.withOpacity(.7),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(days[i], style: const TextStyle(fontSize: 9, color: C.text2)),
                ]),
              ));
            }),
          )),
        ])),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CardTitle('Genel Özet'),
          _row('🍅 Toplam Pomodoro', '${dm.totalPomodoros}'),
          _row('☕ Toplam Mola', '${dm.totalBreakMin} dk'),
          _row('📅 Bugünkü Pomodoro', '${dm.todayPomodoros}'),
          _row('📝 Deneme Sayısı', '${dm.exams.length}'),
          _row('📚 Tamamlanan', '$done/$total konu'),
          _row('🎯 Genel İlerleme', '%${total > 0 ? (done / total * 100).round() : 0}'),
        ])),
      ])),
    ]);
  }

  Widget _row(String label, String val) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: C.text2)),
      Text(val, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w700, color: C.text)),
    ]),
  );
}

// ═══════════════════════════════════════════
// TELEGRAM
// ═══════════════════════════════════════════
class TelegramPage extends StatefulWidget {
  final DataManager dm;
  const TelegramPage({super.key, required this.dm});
  @override
  State<TelegramPage> createState() => _TelegramPageState();
}

class _TelegramPageState extends State<TelegramPage> {
  late TextEditingController _token;
  late TextEditingController _chatId;
  String _status = '';
  bool _ok = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _token  = TextEditingController(text: widget.dm.tgToken);
    _chatId = TextEditingController(text: widget.dm.tgChatId);
  }

  void _save() {
    widget.dm.tgToken  = _token.text.trim();
    widget.dm.tgChatId = _chatId.text.trim();
    widget.dm.save();
    setState(() { _status = '✅ Kaydedildi!'; _ok = true; });
  }

  Future<void> _send(String type) async {
    final token  = _token.text.trim();
    final chatId = _chatId.text.trim();
    if (token.isEmpty || chatId.isEmpty) {
      setState(() { _status = '❌ Token veya Chat ID eksik!'; _ok = false; }); return;
    }
    setState(() { _sending = true; _status = '⏳ Gönderiliyor...'; _ok = true; });
    try {
      final res = await http.post(
        Uri.parse('https://api.telegram.org/bot$token/sendMessage'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'chat_id': chatId, 'text': widget.dm.buildReport(type)}),
      );
      final j = jsonDecode(res.body);
      setState(() {
        _ok = j['ok'] == true;
        _status = _ok ? '✅ Rapor gönderildi!' : '❌ ${j['description']}';
      });
    } catch (e) {
      setState(() { _ok = false; _status = '❌ Bağlantı hatası'; });
    }
    setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      AppHeader('📤 Telegram Raporu'),
      Expanded(child: ListView(padding: const EdgeInsets.all(12), children: [
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CardTitle('Telegram Ayarları'),
          _tgField('Bot Token', _token, '123456:ABC...'),
          _tgField('Chat ID', _chatId, '-100xxxxxxxxx'),
          const SizedBox(height: 4),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: C.surface2, foregroundColor: C.text,
              side: const BorderSide(color: C.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
            ),
            child: const Text('💾 Kaydet'),
          )),
        ])),
        AppCard(child: Column(children: [
          const CardTitle('Rapor Gönder'),
          _sendBtn('📤 Günlük Rapor', 'daily', const Color(0xFF229ED9)),
          const SizedBox(height: 8),
          _sendBtn('📊 Haftalık Özet', 'weekly', const Color(0xFF1A7FC1)),
          const SizedBox(height: 8),
          _sendBtn('☕ Mola Raporu', 'breaks', C.green),
          if (_status.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (_ok ? C.green : C.red).withOpacity(.15),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(_status, textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: _ok ? C.green : C.red)),
            ),
          ],
        ])),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CardTitle('Rapor Önizleme'),
          Text(widget.dm.buildReport('daily'),
            style: GoogleFonts.jetBrainsMono(fontSize: 10, color: C.text2, height: 1.7)),
        ])),
      ])),
    ]);
  }

  Widget _tgField(String label, TextEditingController ctrl, String hint) =>
    Padding(padding: const EdgeInsets.only(bottom: 8), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 9, color: C.text2, letterSpacing: 1)),
        const SizedBox(height: 3),
        TextField(
          controller: ctrl,
          style: GoogleFonts.jetBrainsMono(fontSize: 12, color: C.text),
          decoration: InputDecoration(
            hintText: hint, hintStyle: const TextStyle(color: C.text2),
            filled: true, fillColor: C.surface2,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: C.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: C.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: Color(0xFF229ED9))),
          ),
        ),
      ],
    ));

  Widget _sendBtn(String label, String type, Color color) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _sending ? null : () => _send(type),
      style: ElevatedButton.styleFrom(
        backgroundColor: color, foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    ),
  );
}
