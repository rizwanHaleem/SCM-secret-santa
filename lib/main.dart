import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vfmqphjsfbvsnkgrxjyk.supabase.co',
    anonKey: 'sb_publishable_x8mn78FlA4xUiOaWype6UQ_I5OCoCvh',
  );

  runApp(const SecretSantaApp());
}

class SecretSantaApp extends StatelessWidget {
  const SecretSantaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Secret Santa',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF124734),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _loading = false;

  Future<void> _testSupabaseConnection() async {
    setState(() {
      _loading = true;
    });

    try {
      final data = await Supabase.instance.client
          .from('participants')
          .select('id, full_name')
          .eq('is_active', true)
          .order('full_name');

      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ParticipantTestScreen(
            participants: List<Map<String, dynamic>>.from(data),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to connect to Secret Santa database: $error',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  Container(
                    width: 115,
                    height: 115,
                    decoration: const BoxDecoration(
                      color: Color(0xFF124734),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '🎅',
                        style: TextStyle(fontSize: 64),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'SECRET SANTA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF124734),
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Christmas 2026',
                    style: TextStyle(
                      color: Color(0xFFB28B33),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 35),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Column(
                      children: [
                        Text(
                          '🎄',
                          style: TextStyle(fontSize: 40),
                        ),

                        SizedBox(height: 15),

                        Text(
                          'Something festive is waiting for you...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF124734),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 18),

                        Text(
                          'This Christmas, choose someone special from '
                          'the team and make their celebration a little '
                          'more meaningful.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF555555),
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),

                        SizedBox(height: 22),

                        Divider(),

                        SizedBox(height: 18),

                        Text(
                          'Choose carefully. Once your selection is '
                          'confirmed, it cannot be changed. 🤫',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF8B1E2D),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed:
                          _loading ? null : _testSupabaseConnection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB51F2E),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            const Color(0xFFB51F2E).withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 25,
                              height: 25,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'LET\'S BEGIN  🎁',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'A little appreciation • A little surprise • '
                    'A lot of Christmas spirit',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF777777),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ParticipantTestScreen extends StatelessWidget {
  final List<Map<String, dynamic>> participants;

  const ParticipantTestScreen({
    super.key,
    required this.participants,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF124734),
        foregroundColor: Colors.white,
        title: const Text('Secret Santa'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                '🎅 Connection Successful!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF124734),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                '${participants.length} active participants found',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25),

              ...participants.map(
                (participant) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF124734),
                      child: Text(
                        participant['full_name']
                            .toString()
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      participant['full_name'].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: const Text(
                      '🎁',
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}