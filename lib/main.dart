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
      title: 'اكتشف الأردن',
      theme: ThemeData(primarySwatch: Colors.red, useMaterial3: true),
      home: const MainScreen(),
    );
  }
}

// ================= الصفحة الرئيسية =================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _rating = 0;
  late VideoPlayerController _controller;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // تأكد من مطابقة هذا المسار لملف pubspec.yaml
    _controller = VideoPlayerController.asset("assets/videos/jordan.mp4")
      ..initialize()
          .then((_) {
            setState(() {});
          })
          .catchError((error) {
            print("خطأ في تشغيل الفيديو: $error");
          });
  }

  void _playClappingSound() async {
    await _audioPlayer.play(AssetSource('sounds/clapp.mp3'));
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'اكتشف الأردن',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ===== قسم الفيديو =====
            Container(
              color: Colors.black,
              width: double.infinity,
              child: Column(
                children: [
                  _controller.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        )
                      : const SizedBox(
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(color: Colors.red),
                          ),
                        ),
                  VideoProgressIndicator(_controller, allowScrubbing: true),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause_circle
                              : Icons.play_circle,
                          color: Colors.white,
                          size: 40,
                        ),
                        onPressed: () {
                          setState(() {
                            _controller.value.isPlaying
                                ? _controller.pause()
                                : _controller.play();
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Text(
                'أهم المواقع السياحية والأثرية',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            // ===== بطاقات المواقع مع الصور =====
            _buildInfoCard(
              'مدينة البتراء الوردية',
              'إحدى عجائب الدنيا السبع، مدينة كاملة منحوتة في الصخر الوردي من قبل الأنباط.',
              'assets/images/petra.webp',
            ),

            _buildInfoCard(
              'قلعة عجلون',
              'قلعة إسلامية تاريخية بناها القائد عز الدين أسامة، أحد قادة صلاح الدين الأيوبي.',
              'assets/images/ajloun.jpg',
            ),

            _buildInfoCard(
              'مدينة جرش الأثرية',
              'تعتبر من أفضل المدن الرومانية المحفوظة في العالم، وتشتهر بمهرجانها السنوي.',
              'assets/images/jarash.jpg',
            ),

            const SizedBox(height: 20),

            // ===== زر الاختبار =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QuizScreen()),
                  ),
                  icon: const Icon(Icons.quiz),
                  label: const Text(
                    'ابدأ اختبار المعلومات',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            const Divider(height: 50, thickness: 1),

            // ===== قسم التقييم =====
            const Text('ما هو تقييمك للتطبيق؟', style: TextStyle(fontSize: 16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(index < _rating ? Icons.star : Icons.star_border, color: Colors.amber),
                  onPressed: () {
                    setState(() => _rating = index + 1);
                    // إذا كان التقييم مرتفع (4 أو 5)، شغل صوت التصفيق 
                    if (_rating >= 4) {
                      _playClappingSound();
                    }
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('شكراً لتقييمك!')));
                  },
                );
              }),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // دالة بناء بطاقة الموقع مع الصورة
  Widget _buildInfoCard(String title, String description, String imagePath) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            imagePath,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: Colors.grey[300],
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                    Text('الصورة غير موجودة'),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= صفحة الاختبار =================
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
      'q': 'أين يقع البحر الميت؟',
      'opts': ['الشمال', 'الغرب', 'الشرق'],
      'ans': 1,
    },
    {
      'q': 'ما هو لون صخور البتراء؟',
      'opts': ['أبيض', 'أسود', 'وردي'],
      'ans': 2,
    },
    {
      'q': 'عاصمة الأردن هي:',
      'opts': ['السلط', 'عمان', 'العقبة'],
      'ans': 1,
    },
    {
      'q': 'تشتهر جرش بآثارها:',
      'opts': ['الرومانية', 'الفرعونية', 'الفارسية'],
      'ans': 0,
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
      _currentIdx++;
      _selectedAnswer = null;
      _answered = false;
    });
  }

  Color _getColor(int i) {

    if (!_answered) return Colors.blue;

    if (i == _questions[_currentIdx]['ans']) {
      return Colors.green;
    } else if (i == _selectedAnswer) {
      return Colors.red;
    }

    return Colors.grey;
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    double progress = (_currentIdx) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار المعلومات'),
        centerTitle: true,
      ),

      body: _currentIdx < _questions.length
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                  ),

                  const SizedBox(height: 30),

                  Text(
                    _questions[_currentIdx]['q'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  ...List.generate(
                    3,
                    (i) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 15),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getColor(i),
                          padding: const EdgeInsets.all(15),
                        ),
                        onPressed: () => _checkAnswer(i),
                        child: Text(
                          _questions[_currentIdx]['opts'][i],
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )

          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '🎉 انتهى الاختبار',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'نتيجتك: $_score من ${_questions.length}',
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentIdx = 0;
                        _score = 0;
                      });
                    },
                    child: const Text('إعادة الاختبار'),
                  )
                ],
              ),
            ),
    );
  }
}