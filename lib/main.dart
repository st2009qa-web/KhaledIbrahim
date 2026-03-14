import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const JordanTourismApp());
}

class JordanTourismApp extends StatelessWidget {
  const JordanTourismApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'اكتشف الأردن الحديث',
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
        fontFamily: 'Roboto', // يمكن استبداله بخط عربي احترافي
      ),
      home: const MainScreen(),
    );
  }
}

// ================= الشاشة الرئيسية مع نظام التنقل المطور =================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex =
      0; // تحسين بناءً على ملاحظة ياسين: إضافة نظام التنقل الفعلي

  // دالة لتبديل الصفحات بناءً على شريط التنقل السفلي
  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return const HomeTab(); // الصفحة الرئيسية (فيديو + ملخص)
      case 1:
        return const LocationsTab(); // صفحة المعالم السياحية
      case 2:
        return const QuizScreen(); // شاشة الاختبار (ملاحظة أحمد: وصول سريع)
      default:
        return const HomeTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // تحسين بناءً على ملاحظة سلطان: استخدام تدرج لوني بدلاً من الأحمر القوي
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.redAccent, Colors.orangeAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'اكتشف الأردن',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _getBody(),

      // تحسين بناءً على ملاحظة ياسين وأحمد: شريط تنقل سفلي لسهولة الوصول
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'المعالم'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'الاختبار'),
        ],
      ),
    );
  }
}

// ================= قسم الصفحة الرئيسية (Home Tab) =================
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late VideoPlayerController _controller;
  int _userRating = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/videos/jordan.mp4")
      ..initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // عرض الفيديو التعريفي
          Container(
            height: 250,
            width: double.infinity,
            color: Colors.black,
            child: _controller.value.isInitialized
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                      IconButton(
                        icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause_circle
                              : Icons.play_circle,
                          color: Colors.white70,
                          size: 60,
                        ),
                        onPressed: () => setState(() {
                          _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play();
                        }),
                      ),
                    ],
                  )
                : const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
          ),

          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'مرحباً بك في أرض الحضارات',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          // تحسين بناءً على ملاحظة خالد: نظام تقييم بالنجوم عصري بدلاً من الأزرار القديمة
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  const Text(
                    'ما رأيك في تجربة التطبيق؟',
                    style: TextStyle(fontSize: 16),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _userRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 35,
                        ),
                        onPressed: () {
                          setState(() => _userRating = index + 1);
                          if (_userRating >= 4) {
                            _audioPlayer.play(AssetSource('sounds/clapp.mp3'));
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('شكراً لمساهمتك في تحسين التطبيق!'),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= قسم المعالم السياحية (Locations Tab) =================
class LocationsTab extends StatelessWidget {
  const LocationsTab({super.key});

  Widget _buildLocationCard(String title, String desc, String img) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: Column(
        children: [
          Image.asset(
            img,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          ListTile(
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(desc),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildLocationCard(
          'مدينة البتراء',
          'واحدة من عجائب الدنيا السبع وتسمى المدينة الوردية.',
          'assets/images/petra.webp',
        ),
        _buildLocationCard(
          'قلعة عجلون',
          'قلعة إسلامية بناها القائد عز الدين أسامة.',
          'assets/images/ajloun.jpg',
        ),
        _buildLocationCard(
          'مدينة جرش',
          'تعد من أكبر المواقع الرومانية المحفوظة في العالم.',
          'assets/images/jarash.jpg',
        ),

        _buildLocationCard(
          'أم قيس',
          'عُرفت أم قيس قديمًا باسم جدارا، وهي إحدى المدن اليونانية- الرومانية العشر (حلف المدن العشرة). وفي ‏الأزمنة القديمة، كانت جدارا تقع في موقع استراتيجي ويمر بها عدد من الطرق التجارية التي كانت تربط سوريا وفلسطين.',
          'assets/images/umqais.jfif',
        ),
        _buildLocationCard(
          'محمية ضانا',
          'تأسست محمية ضانا للمحيط الحيوي عام 1989، وتقع في محافظة الطفيلة جنوب الأردن، وتمتد على مساحة ‏تقارب 300 كم². تمتد المحمية من سفوح جبال القادسية التي ترتفع أكثر من 1500 متر عن سطح البحر إلى سهول ووديان وادي عربة، ‏وتتميز بتضاريسها المتنوعة من الجبال الشاهقة إلى الأودية العميقة والصحاري.',
          'assets/images/dana.jpg',
        ),
      ],
    );
  }
}

// ================= شاشة الاختبار المحدثة (Quiz Screen) =================
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIdx = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;
  final AudioPlayer _player = AudioPlayer();

  final List<Map<String, dynamic>> _questions = [
    {
      'q': 'في أي مدينة تقع البتراء؟',
      'opts': ['معان', 'عمان', 'إربد'],
      'ans': 0,
    },
    {
      'q': 'ما هو لون صخور البتراء الشهير؟',
      'opts': ['أبيض', 'أزرق', 'وردي'],
      'ans': 2,
    },
    {
      'q': 'من بنى قلعة عجلون؟',
      'opts': ['الرومان', 'عز الدين أسامة', 'الأنباط'],
      'ans': 1,
    },
  ];

  void _checkAnswer(int index) async {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
    });

    if (index == _questions[_currentIdx]['ans']) {
      _score++;
      await _player.play(AssetSource('sounds/success.mp3'));
    } else {
      await _player.play(AssetSource('sounds/wrong.mp3'));
    }

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      if (_currentIdx < _questions.length - 1) {
        _currentIdx++;
        _selectedAnswer = null;
        _answered = false;
      } else {
        _showFinalResult();
      }
    });
  }

  // تحسين بناءً على ملاحظة يوسف: ألوان واضحة للإجابات (أخضر للصح، أحمر للخطأ)
  Color _getBtnColor(int i) {
    if (!_answered) return Colors.blueGrey.shade100;
    if (i == _questions[_currentIdx]['ans']) return Colors.greenAccent.shade400;
    if (i == _selectedAnswer) return Colors.redAccent;
    return Colors.blueGrey.shade100;
  }

  void _showFinalResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('🎉 انتهى الاختبار'),
        content: Text('لقد حصلت على $_score من أصل ${_questions.length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _currentIdx = 0;
                _score = 0;
                _answered = false;
              });
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          LinearProgressIndicator(value: (_currentIdx + 1) / _questions.length),
          const SizedBox(height: 40),
          Text(
            _questions[_currentIdx]['q'],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          ...List.generate(
            3,
            (i) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 15),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getBtnColor(i),
                  padding: const EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => _checkAnswer(i),
                child: Text(
                  _questions[_currentIdx]['opts'][i],
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
