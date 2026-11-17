import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vfmqphjsfbvsnkgrxjyk.supabase.co',
    publishableKey: 'sb_publishable_x8mn78FlA4xUiOaWype6UQ_I5OCoCvh',
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
      home: const InviteGateway(),
    );
  }
}

class AppBranding extends StatelessWidget {
  const AppBranding({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Dialog SCM - Secret Santa 2026',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF124734),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.4,
          ),
        ),
        SizedBox(height: 3),
        Text(
          'Developed by Rizwan Haleem',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF888888),
            fontSize: 10,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// INVITATION GATEWAY
// ============================================================

class InviteGateway extends StatefulWidget {
  const InviteGateway({super.key});

  @override
  State<InviteGateway> createState() => _InviteGatewayState();
}

class _InviteGatewayState extends State<InviteGateway> {
  bool loading = true;
  String? errorMessage;

  String? token;
  Map<String, dynamic>? participant;

  @override
  void initState() {
    super.initState();
    _loadInvitation();
  }

  Future<void> _loadInvitation() async {
    final inviteToken = Uri.base.queryParameters['invite'];

    if (inviteToken == null || inviteToken.isEmpty) {
      setState(() {
        loading = false;
        errorMessage =
            'This Secret Santa invitation link is incomplete.';
      });
      return;
    }

    try {
      final response = await Supabase.instance.client.rpc(
        'get_participant_by_token',
        params: {
          'p_token': inviteToken,
        },
      );

      final rows =
          List<Map<String, dynamic>>.from(response);

      if (rows.isEmpty) {
        setState(() {
          loading = false;
          errorMessage =
              'This Secret Santa invitation is not valid.';
        });
        return;
      }

      setState(() {
        token = inviteToken;
        participant = rows.first;
        loading = false;
      });
    } catch (error) {
      setState(() {
        loading = false;
        errorMessage =
            'Unable to open your Secret Santa invitation.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const LoadingScreen();
    }

    if (errorMessage != null) {
      return InvalidInvitationScreen(
        message: errorMessage!,
      );
    }

    final hasSelected =
        participant!['has_selected'] == true;

    final messagesCompleted =
        participant!['messages_completed'] == true;

    if (hasSelected) {
      return ExistingAssignmentLoader(
        token: token!,
        participant: participant!,
        messagesCompleted: messagesCompleted,
      );
    }

    return WelcomeScreen(
      token: token!,
      participant: participant!,
    );
  }
}

// ============================================================
// LOADING SCREEN
// ============================================================

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({
    super.key,
    this.message = 'Checking your Christmas invitation...',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🎅',
                style: TextStyle(fontSize: 70),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(
                color: Color(0xFF124734),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF124734),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// INVALID INVITATION
// ============================================================

class InvalidInvitationScreen extends StatelessWidget {
  const InvalidInvitationScreen({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 450,
          ),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🎄',
                  style: TextStyle(
                    fontSize: 65,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Oops!',
                  style: TextStyle(
                    color: Color(0xFF124734),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Please use the personal QR invitation sent to you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
const SizedBox(height: 30),

OutlinedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const AdminLoginScreen(),
      ),
    );
  },
  icon: const Icon(Icons.admin_panel_settings),
  label: const Text(
    'ADMIN LOGIN',
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

// ============================================================
// WELCOME SCREEN
// ============================================================

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    required this.token,
    required this.participant,
  });

  final String token;
  final Map<String, dynamic> participant;

  @override
  State<WelcomeScreen> createState() =>
      _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool drawing = false;

  Future<void> _drawSecretSanta() async {
    if (drawing) return;

    setState(() {
      drawing = true;
    });

    try {
      final response =
          await Supabase.instance.client.rpc(
        'draw_secret_santa',
        params: {
          'p_token': widget.token,
        },
      );

      final rows =
          List<Map<String, dynamic>>.from(response);

      if (rows.isEmpty) {
        throw Exception('NO_ASSIGNMENT_RETURNED');
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RevealScreen(
            token: widget.token,
            recipient: rows.first,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        drawing = false;
      });

      final errorText = error.toString();

      if (errorText.contains(
          'NO_RECIPIENT_AVAILABLE')) {
        _showError(
          'There are no eligible Secret Santa recipients available. Please contact the event administrator.',
        );
        return;
      }

      if (errorText.contains('DRAW_CONFLICT')) {
        _showError(
          'Christmas got a little busy! Please tap the button once more.',
        );
        return;
      }

      _showError(
        'Unable to draw your Secret Santa person. Please try again.',
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name =
        widget.participant['full_name'].toString();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              child: Column(
                children: [
                  const AppBranding(),

                  const SizedBox(height: 28),
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
                        style: TextStyle(
                          fontSize: 64,
                        ),
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
                          color: Colors.black.withValues(
                            alpha: 0.08,
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '🎄 Welcome, $name!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF124734),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'Your Secret Santa mission is waiting...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF555555),
                            fontSize: 17,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Ready to discover who you will be surprising this Christmas?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF555555),
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 22),

                        const Divider(),

                        const SizedBox(height: 18),

                        const Text(
                          '🎁 Your Secret Santa person will be selected randomly and can only be drawn once.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF8B1E2D),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed:
                          drawing ? null : _drawSecretSanta,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFB51F2E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                      ),
                      child: drawing
                          ? const SizedBox(
                              width: 25,
                              height: 25,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              '🎁 CHOOSE MY SECRET SANTA PERSON',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'A little appreciation • A little surprise • A lot of Christmas spirit',
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

// ============================================================
// REVEAL SCREEN
// ============================================================

class RevealScreen extends StatelessWidget {
  const RevealScreen({
    super.key,
    required this.token,
    required this.recipient,
  });

  final String token;
  final Map<String, dynamic> recipient;

  @override
  Widget build(BuildContext context) {
    final recipientName =
        recipient['recipient_name'].toString();

    return Scaffold(
      backgroundColor: const Color(0xFF124734),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              child: Column(
                children: [
                  const Text(
                    '🎉🎄🎁',
                    style: TextStyle(
                      fontSize: 50,
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'Christmas has made the choice!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 28),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '🎅',
                          style: TextStyle(
                            fontSize: 65,
                          ),
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          'Your Secret Santa Person is...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 17,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          recipientName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF124734),
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          '🎁',
                          style: TextStyle(
                            fontSize: 38,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'This assignment is now locked. Your Christmas mission has officially begun! 🤫',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MessagesScreen(
                              token: token,
                              recipientName:
                                  recipientName,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFB51F2E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'CONTINUE  ❤️',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

// ============================================================
// LOAD EXISTING ASSIGNMENT
// ============================================================

class ExistingAssignmentLoader
    extends StatefulWidget {
  const ExistingAssignmentLoader({
    super.key,
    required this.token,
    required this.participant,
    required this.messagesCompleted,
  });

  final String token;
  final Map<String, dynamic> participant;
  final bool messagesCompleted;

  @override
  State<ExistingAssignmentLoader> createState() =>
      _ExistingAssignmentLoaderState();
}

class _ExistingAssignmentLoaderState
    extends State<ExistingAssignmentLoader> {
  bool loading = true;
  String? recipientName;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadExistingAssignment();
  }

  Future<void> _loadExistingAssignment() async {
    try {
      final response =
          await Supabase.instance.client.rpc(
        'draw_secret_santa',
        params: {
          'p_token': widget.token,
        },
      );

      final rows =
          List<Map<String, dynamic>>.from(response);

      if (rows.isEmpty) {
        throw Exception('Assignment not found');
      }

      setState(() {
        recipientName =
            rows.first['recipient_name'].toString();
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error =
            'Unable to retrieve your Secret Santa assignment.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const LoadingScreen(
        message:
            'Getting your Secret Santa mission...',
      );
    }

    if (error != null) {
      return InvalidInvitationScreen(
        message: error!,
      );
    }

    if (widget.messagesCompleted) {
      return CompletedScreen(
        recipientName: recipientName!,
      );
    }

    return WelcomeBackScreen(
      token: widget.token,
      recipientName: recipientName!,
    );
  }
}

// ============================================================
// WELCOME BACK - ASSIGNMENT EXISTS / MESSAGES PENDING
// ============================================================

class WelcomeBackScreen extends StatelessWidget {
  const WelcomeBackScreen({
    super.key,
    required this.token,
    required this.recipientName,
  });

  final String token;
  final String recipientName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              child: Column(
                children: [
                  const Text(
                    '🎅',
                    style: TextStyle(
                      fontSize: 65,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      color: Color(0xFF124734),
                      fontSize: 29,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 25),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Your Secret Santa person is',
                          style: TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          recipientName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF124734),
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          '❤️ You still need to complete your two Christmas messages.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF8B1E2D),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MessagesScreen(
                              token: token,
                              recipientName:
                                  recipientName,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFB51F2E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'CONTINUE MY MISSION  🎁',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

// ============================================================
// TWO CHRISTMAS MESSAGES
// ============================================================

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({
    super.key,
    required this.token,
    required this.recipientName,
  });

  final String token;
  final String recipientName;

  @override
  State<MessagesScreen> createState() =>
      _MessagesScreenState();
}

class _MessagesScreenState
    extends State<MessagesScreen> {
  final appreciationController =
      TextEditingController();

  final christmasController =
      TextEditingController();

  bool submitting = false;

  @override
  void dispose() {
    appreciationController.dispose();
    christmasController.dispose();
    super.dispose();
  }

  Future<void> _saveMessages() async {
    final appreciation =
        appreciationController.text.trim();

    final christmas =
        christmasController.text.trim();

    if (appreciation.length < 10) {
      _showMessage(
        'Please tell us a little more about what you appreciate.',
      );
      return;
    }

    if (christmas.length < 10) {
      _showMessage(
        'Please add a slightly longer Christmas message.',
      );
      return;
    }

    setState(() {
      submitting = true;
    });

    try {
      final response =
          await Supabase.instance.client.rpc(
        'save_secret_santa_messages',
        params: {
          'p_token': widget.token,
          'p_reason_1': appreciation,
          'p_reason_2': christmas,
        },
      );

      if (!mounted) return;

      if (response == 'SUCCESS') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CompletedScreen(
              recipientName:
                  widget.recipientName,
            ),
          ),
          (route) => false,
        );
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        submitting = false;
      });

      final text = error.toString();

      if (text.contains(
          'MESSAGES_ALREADY_COMPLETED')) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CompletedScreen(
              recipientName:
                  widget.recipientName,
            ),
          ),
          (route) => false,
        );

        return;
      }

      _showMessage(
        'Unable to save your Christmas messages. Please try again.',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
      appBar: AppBar(
        title: const Text(
          'Your Christmas Messages',
        ),
        backgroundColor: const Color(0xFF124734),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 550,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '❤️',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 55,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'A little something for ${widget.recipientName}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF124734),
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  '1. What do you appreciate about ${widget.recipientName}?',
                  style: const TextStyle(
                    color: Color(0xFF124734),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller:
                      appreciationController,
                  maxLength: 250,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText:
                        'Share something positive and meaningful...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  '2. What Christmas message would you like to share with ${widget.recipientName}?',
                  style: const TextStyle(
                    color: Color(0xFF124734),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller:
                      christmasController,
                  maxLength: 250,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText:
                        'Wish them something special this Christmas...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0D8),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: const Text(
                    '✨ Make it positive and meaningful. These messages may become part of the Christmas event reveal.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF6D4C00),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                SizedBox(
                  height: 58,
                  child: ElevatedButton(
                    onPressed:
                        submitting ? null : _saveMessages,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFB51F2E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),
                    child: submitting
                        ? const SizedBox(
                            width: 25,
                            height: 25,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            '🎄 SAVE MY CHRISTMAS MESSAGES',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
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

// ============================================================
// COMPLETED SCREEN
// ============================================================

class CompletedScreen extends StatelessWidget {
  const CompletedScreen({
    super.key,
    required this.recipientName,
  });

  final String recipientName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF124734),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              child: Column(
                children: [
                  const Text(
                    '🎉🎄🎁',
                    style: TextStyle(
                      fontSize: 55,
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'MISSION ACCOMPLISHED!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 29,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 28),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '🎅',
                          style: TextStyle(
                            fontSize: 60,
                          ),
                        ),

                        const SizedBox(height: 15),

                        const Text(
                          'You are Secret Santa for',
                          style: TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          recipientName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF124734),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Divider(),

                        const SizedBox(height: 20),

                        const Text(
                          '✅ Your Christmas messages have been safely saved.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF124734),
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          '🤫',
                          style: TextStyle(
                            fontSize: 42,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'KEEP IT SECRET!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFB51F2E),
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),


                  const Text(
                    'See you at the Christmas celebration! 🎄',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

// ============================================================
// ADMIN LOGIN
// ============================================================

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() =>
      _AdminLoginScreenState();
}

class _AdminLoginScreenState
    extends State<AdminLoginScreen> {

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  bool loggingIn = false;
  bool hidePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {

    final email =
        emailController.text.trim();

    final password =
        passwordController.text;

    if (email.isEmpty ||
        password.isEmpty) {

      _showMessage(
        'Please enter your admin email and password.',
      );

      return;
    }

    setState(() {
      loggingIn = true;
    });

    try {

      await Supabase.instance.client.auth
          .signInWithPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const AdminDashboardScreen(),
        ),
      );

    } catch (error) {

      if (!mounted) return;

      setState(() {
        loggingIn = false;
      });

      _showMessage(
        'Admin login failed. Please check your email and password',
      );
    }
  }

  void _showMessage(String message) {

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F3E8),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF124734),
        foregroundColor:
            Colors.white,
        title:
            const Text('Admin Login'),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),

          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 450,
            ),

            child: Column(
              children: [

                const Text(
                  '🎅',
                  style: TextStyle(
                    fontSize: 65,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  'Secret Santa Admin',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color:
                        Color(0xFF124734),
                    fontSize: 27,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Management Dashboard',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 30),

                TextField(
                  controller:
                      emailController,
                  keyboardType:
                      TextInputType
                          .emailAddress,
                  decoration:
                      InputDecoration(
                    labelText:
                        'Admin Email',
                    prefixIcon:
                        const Icon(
                      Icons.email_outlined,
                    ),
                    filled: true,
                    fillColor:
                        Colors.white,
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                              16),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                TextField(
                  controller:
                      passwordController,
                  obscureText:
                      hidePassword,
                  onSubmitted: (_) {
                    if (!loggingIn) {
                      _login();
                    }
                  },
                  decoration:
                      InputDecoration(
                    labelText:
                        'Password',

                    prefixIcon:
                        const Icon(
                      Icons.lock_outline,
                    ),

                    suffixIcon:
                        IconButton(
                      onPressed: () {
                        setState(() {
                          hidePassword =
                              !hidePassword;
                        });
                      },

                      icon: Icon(
                        hidePassword
                            ? Icons
                                .visibility
                            : Icons
                                .visibility_off,
                      ),
                    ),

                    filled: true,
                    fillColor:
                        Colors.white,

                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                              16),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width:
                      double.infinity,
                  height: 56,

                  child:
                      ElevatedButton(
                    onPressed:
                        loggingIn
                            ? null
                            : _login,

                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          const Color(
                              0xFF124734),
                      foregroundColor:
                          Colors.white,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                16),
                      ),
                    ),

                    child:
                        loggingIn

                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(
                                  color:
                                      Colors.white,
                                  strokeWidth:
                                      3,
                                ),
                              )

                            : const Text(
                                'SIGN IN TO DASHBOARD',
                                style:
                                    TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
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

// ============================================================
// ADMIN DASHBOARD
// ============================================================

class AdminDashboardScreen
    extends StatefulWidget {

  const AdminDashboardScreen({
    super.key,
  });

  @override
  State<AdminDashboardScreen>
      createState() =>
          _AdminDashboardScreenState();
}


class _AdminDashboardScreenState
    extends State<AdminDashboardScreen> {

  bool loading = true;

  String? errorMessage;

  Map<String, dynamic> summary = {};

  List<Map<String, dynamic>>
      report = [];


  @override
  void initState() {
    super.initState();

    _loadDashboard();
  }


  Future<void> _loadDashboard() async {

    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {

      final summaryResponse =
          await Supabase
              .instance.client
              .rpc(
        'admin_secret_santa_summary',
      );


      final reportResponse =
          await Supabase
              .instance.client
              .rpc(
        'admin_secret_santa_report',
      );


      if (!mounted) return;


      final summaryRows =
          List<Map<String, dynamic>>
              .from(summaryResponse);


      final reportRows =
          List<Map<String, dynamic>>
              .from(reportResponse);


      setState(() {

        summary =
            summaryRows.isNotEmpty
                ? summaryRows.first
                : {};

        report = reportRows;

        loading = false;

      });

    } catch (error) {

      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage =
            'Unable to load the admin dashboard.';
      });
    }
  }


  Future<void> _logout() async {

    await Supabase.instance.client.auth
        .signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,

      MaterialPageRoute(
        builder: (context) =>
            const InviteGateway(),
      ),

      (route) => false,
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF7F3E8),

      appBar: AppBar(

        backgroundColor:
            const Color(0xFF124734),

        foregroundColor:
            Colors.white,

        title:
            const Text(
          'Secret Santa Admin',
        ),

        actions: [

          IconButton(
            tooltip:
                'Refresh dashboard',
            onPressed:
                loading
                    ? null
                    : _loadDashboard,

            icon:
                const Icon(
              Icons.refresh,
            ),
          ),

          IconButton(
            tooltip: 'Sign out',
            onPressed: _logout,

            icon:
                const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),

      body: loading

          ? const Center(
              child:
                  CircularProgressIndicator(
                color:
                    Color(
                        0xFF124734),
              ),
            )

          : errorMessage != null

              ? _buildError()

              : _buildDashboard(),
    );
  }


  Widget _buildError() {

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [

            const Text(
              '⚠️',
              style:
                  TextStyle(
                fontSize: 50,
              ),
            ),

            const SizedBox(
                height: 15),

            Text(
              errorMessage!,
              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                fontSize: 17,
              ),
            ),

            const SizedBox(
                height: 20),

            ElevatedButton.icon(
              onPressed:
                  _loadDashboard,

              icon:
                  const Icon(
                Icons.refresh,
              ),

              label:
                  const Text(
                'TRY AGAIN',
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDashboard() {

    final total =
        summary['total_participants'] ??
            0;

    final assigned =
        summary['assigned_count'] ??
            0;

    final completed =
        summary['completed_count'] ??
            0;

    final pendingDraw =
        summary[
                'pending_draw_count'] ??
            0;

    final pendingMessages =
        summary[
                'pending_messages_count'] ??
            0;


    return RefreshIndicator(

      onRefresh: _loadDashboard,

      child: ListView(

        padding:
            const EdgeInsets.all(20),

        children: [

          const Text(
            '🎄 Secret Santa Progress',
            style:
                TextStyle(
              color:
                  Color(
                      0xFF124734),
              fontSize: 26,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Live event status and participant submissions',
            style:
                TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 22),

          Wrap(
            spacing: 12,
            runSpacing: 12,

            children: [

              _summaryCard(
                'Participants',
                total,
                '👥',
              ),

              _summaryCard(
                'Assigned',
                assigned,
                '🎁',
              ),

              _summaryCard(
                'Completed',
                completed,
                '✅',
              ),

              _summaryCard(
                'Yet to Draw',
                pendingDraw,
                '🎲',
              ),

              _summaryCard(
                'Messages Pending',
                pendingMessages,
                '❤️',
              ),
            ],
          ),

          const SizedBox(height: 30),

          Row(
            children: [

              const Expanded(
                child: Text(
                  'Assignments & Messages',
                  style:
                      TextStyle(
                    color:
                        Color(
                            0xFF124734),
                    fontSize:
                        21,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              Text(
                '${report.length} records',
                style:
                    const TextStyle(
                  color:
                      Colors.grey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          if (report.isEmpty)

            Container(
              padding:
                  const EdgeInsets.all(
                      25),

              decoration:
                  BoxDecoration(
                color:
                    Colors.white,
                borderRadius:
                    BorderRadius.circular(
                        18),
              ),

              child:
                  const Column(
                children: [

                  Text(
                    '🎅',
                    style:
                        TextStyle(
                      fontSize:
                          45,
                    ),
                  ),

                  SizedBox(
                      height: 10),

                  Text(
                    'No Secret Santa assignments yet.',
                    textAlign:
                        TextAlign.center,
                  ),
                ],
              ),
            ),

          ...report.map(
            (item) =>
                _assignmentCard(
              item,
            ),
          ),
        ],
      ),
    );
  }


  Widget _summaryCard(
    String title,
    dynamic value,
    String icon,
  ) {

    return Container(

      width: 165,

      padding:
          const EdgeInsets.all(18),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(18),

        boxShadow: [

          BoxShadow(
            color: Colors.black
                .withValues(
              alpha: 0.05,
            ),

            blurRadius: 10,

            offset:
                const Offset(
              0,
              4,
            ),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(
            icon,
            style:
                const TextStyle(
              fontSize: 28,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            value.toString(),

            style:
                const TextStyle(
              color:
                  Color(
                      0xFF124734),
              fontSize: 28,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            title,
            style:
                const TextStyle(
              color:
                  Color(
                      0xFF666666),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }


  Widget _assignmentCard(
      Map<String, dynamic> item) {

    final completed =
        item['messages_completed'] ==
            true;

    final appreciation =
        item[
            'appreciation_message'];

    final christmas =
        item[
            'christmas_message'];


    return Card(

      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),

      color: Colors.white,

      child:
          ExpansionTile(

        leading:
            CircleAvatar(
          backgroundColor:
              completed
                  ? const Color(
                      0xFF124734)
                  : const Color(
                      0xFFD19A20),

          child:
              Text(
            completed
                ? '✓'
                : '…',

            style:
                const TextStyle(
              color:
                  Colors.white,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),

        title:
            Text(
          item['giver_name']
                  ?.toString() ??
              '-',

          style:
              const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        subtitle:
            Text(
          '🎁 ${item['recipient_name'] ?? '-'}',
        ),

        trailing:
            Text(
          completed
              ? 'Complete'
              : 'Pending',

          style:
              TextStyle(
            color:
                completed
                    ? const Color(
                        0xFF124734)
                    : const Color(
                        0xFFB26A00),

            fontWeight:
                FontWeight.bold,
          ),
        ),

        childrenPadding:
            const EdgeInsets.fromLTRB(
          20,
          5,
          20,
          22,
        ),

        children: [

          const Divider(),

          const SizedBox(height: 12),

          _detailSection(
            '❤️ Appreciation',
            appreciation
                    ?.toString() ??
                'Not submitted yet',
          ),

          const SizedBox(height: 18),

          _detailSection(
            '🎄 Christmas Message',
            christmas
                    ?.toString() ??
                'Not submitted yet',
          ),

          const SizedBox(height: 18),

          _dateSection(
            'Assignment Date',
            item[
                'assignment_date'],
          ),

          if (completed) ...[

            const SizedBox(
                height: 8),

            _dateSection(
              'Messages Completed',
              item[
                  'messages_completed_at'],
            ),
          ],
        ],
      ),
    );
  }


  Widget _detailSection(
    String title,
    String value,
  ) {

    return Align(
      alignment:
          Alignment.centerLeft,

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(
            title,

            style:
                const TextStyle(
              color:
                  Color(
                      0xFF124734),
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            value,

            style:
                const TextStyle(
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }


  Widget _dateSection(
    String title,
    dynamic value,
  ) {

    String displayValue =
        'Not available';

    if (value != null) {

      final parsed =
          DateTime.tryParse(
        value.toString(),
      );

      if (parsed != null) {

        final local =
            parsed.toLocal();

        displayValue =
            '${local.day.toString().padLeft(2, '0')}/'
            '${local.month.toString().padLeft(2, '0')}/'
            '${local.year} '
            '${local.hour.toString().padLeft(2, '0')}:'
            '${local.minute.toString().padLeft(2, '0')}';
      }
    }


    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Expanded(
          child:
              Text(
            title,

            style:
                const TextStyle(
              color:
                  Colors.grey,
              fontSize: 13,
            ),
          ),
        ),

        Text(
          displayValue,

          style:
              const TextStyle(
            fontSize: 13,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

