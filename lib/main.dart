import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const JarvisApp());
}

class JarvisApp extends StatelessWidget {
  const JarvisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JARVIS',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF05070D),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          brightness: Brightness.dark,
        ),
      ),
      home: const JarvisHome(),
    );
  }
}

class JarvisHome extends StatefulWidget {
  const JarvisHome({super.key});

  @override
  State<JarvisHome> createState() => _JarvisHomeState();
}

class _JarvisHomeState extends State<JarvisHome> {
  static const MethodChannel _appLauncher = MethodChannel('jarvis/app_launcher');
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isListening = false;
  String _heardText = 'Tap the microphone and speak';
  String _status = 'JARVIS READY';

  @override
  void initState() {
    super.initState();
    _setupTts();
  }

  Future<void> _setupTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.48);
    await _tts.setPitch(0.9);
    await _tts.setVolume(1.0);
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _listen() async {
    if (_isListening) {
      await _speech.stop();
      setState(() {
        _isListening = false;
        _status = 'JARVIS READY';
      });
      return;
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) {
            setState(() {
              _isListening = false;
              _status = 'JARVIS READY';
            });
          }
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isListening = false;
            _status = 'VOICE ERROR';
          });
        }
      },
    );

    if (!available) {
      setState(() {
        _status = 'MIC NOT AVAILABLE';
      });
      await _speak('I cannot access the microphone.');
      return;
    }

    setState(() {
      _isListening = true;
      _status = 'LISTENING...';
      _heardText = 'Listening...';
    });

    await _speech.listen(
      localeId: 'en_US',
      onResult: (result) async {
        if (result.recognizedWords.isNotEmpty) {
          setState(() {
            _heardText = result.recognizedWords;
          });

          if (result.finalResult) {
            await _processCommand(result.recognizedWords);
          }
        }
      },
    );
  }

  Future<bool> _launchApp(String packageName) async {
    try {
      final result = await _appLauncher.invokeMethod('launchApp', {'packageName': packageName});
      return result == true;
    } on PlatformException {
      return false;
    }
  }

  Future<void> _processCommand(String command) async {
    final text = command.toLowerCase().trim();

    setState(() {
      _status = 'PROCESSING...';
      _isListening = false;
    });

    if (text.contains('open youtube') || text.contains('launch youtube')) {
      final opened = await _launchApp('com.google.android.youtube');
      await _speak(opened ? 'Opening YouTube.' : 'I could not open YouTube.');
    } else if (text.contains('hello') ||
        text.contains('hi jarvis') ||
        text == 'hi') {
      await _speak('Hello Samson. JARVIS is ready.');
    } else if (text.contains('your name')) {
      await _speak('I am JARVIS, your personal Android assistant.');
    } else if (text.contains('time')) {
      final now = DateTime.now();
      final hour = now.hour > 12 ? now.hour - 12 : now.hour;
      final minute = now.minute.toString().padLeft(2, '0');
      final period = now.hour >= 12 ? 'PM' : 'AM';

      await _speak('The time is $hour $minute $period.');
    } else if (text.contains('battery')) {
      await _speak(
        'Battery control will be connected in the next JARVIS module.',
      );
    } else if (text == 'stop' ||
        text == 'exit' ||
        text == 'quit') {
      await _speak('Goodbye.');
    } else {
      await _speak(
        'I heard $command. App control will be connected next.',
      );
    }

    if (mounted) {
      setState(() {
        _status = 'JARVIS READY';
      });
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'J A R V I S',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                    color: Colors.cyanAccent,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _status,
                  style: const TextStyle(
                    fontSize: 14,
                    letterSpacing: 3,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 45),
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isListening
                          ? Colors.cyanAccent
                          : Colors.cyan.withOpacity(0.5),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyan.withOpacity(0.2),
                        blurRadius: 35,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isListening
                        ? Icons.graphic_eq
                        : Icons.mic_none,
                    size: 90,
                    color: Colors.cyanAccent,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  _heardText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 35),
                ElevatedButton.icon(
                  onPressed: _listen,
                  icon: Icon(
                    _isListening ? Icons.stop : Icons.mic,
                  ),
                  label: Text(
                    _isListening ? 'STOP LISTENING' : 'TALK TO JARVIS',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
