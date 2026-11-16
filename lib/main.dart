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
      home: const InviteGateway(),
    );
  }
}


// ============================================================
// INVITATION / TOKEN CHECK
// ============================================================

class InviteGateway extends StatefulWidget {
  const InviteGateway({super.key});

  @override
  State<InviteGateway> createState() => _InviteGatewayState();
}

class _InviteGatewayState extends State<InviteGateway> {

  bool loading = true;

  String? errorMessage;

  Map<String, dynamic>? participant;

  String? token;

  @override
  void initState() {
    super.initState();
    _loadInvitation();
  }

  Future<void> _loadInvitation() async {

    final uri = Uri.base;

    final inviteToken = uri.queryParameters['invite'];

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

    return WelcomeScreen(
      participant: participant!,
      token: token!,
    );
  }
}


// ============================================================
// LOADING SCREEN
// ============================================================

class LoadingScreen extends StatelessWidget {

  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return const Scaffold(
      backgroundColor: Color(0xFFF7F3E8),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Text(
              '🎅',
              style: TextStyle(
                fontSize: 65,
              ),
            ),

            SizedBox(height: 20),

            CircularProgressIndicator(
              color: Color(0xFF124734),
            ),

            SizedBox(height: 20),

            Text(
              'Checking your Christmas invitation...',
              style: TextStyle(
                color: Color(0xFF124734),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// INVALID INVITATION
// ============================================================

class InvalidInvitationScreen extends StatelessWidget {

  final String message;

  const InvalidInvitationScreen({
    super.key,
    required this.message,
  });

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
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ============================================================
// PERSONAL WELCOME SCREEN
// ============================================================

class WelcomeScreen extends StatelessWidget {

  final Map<String, dynamic> participant;

  final String token;

  const WelcomeScreen({
    super.key,
    required this.participant,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {

    final name =
        participant['full_name'].toString();

    final hasSelected =
        participant['has_selected'] == true;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(

            padding:
                const EdgeInsets.all(24),

            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                    maxWidth: 500,
                  ),

              child: Column(
                children: [

                  Container(
                    width: 115,
                    height: 115,

                    decoration:
                        const BoxDecoration(
                      color:
                          Color(0xFF124734),
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
                    style: TextStyle(
                      color:
                          Color(0xFF124734),
                      fontSize: 34,
                      fontWeight:
                          FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Christmas 2026',
                    style: TextStyle(
                      color:
                          Color(0xFFB28B33),
                      fontSize: 20,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    '🎄 Welcome, $name!',
                    textAlign:
                        TextAlign.center,

                    style:
                        const TextStyle(
                      color:
                          Color(0xFF124734),
                      fontSize: 25,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Ready to make someone\'s Christmas a little more special?',
                    textAlign:
                        TextAlign.center,

                    style:
                        TextStyle(
                      color:
                          Color(0xFF555555),
                      fontSize: 17,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 28),

                  if (!hasSelected)

                    SizedBox(
                      width:
                          double.infinity,
                      height: 58,

                      child:
                          ElevatedButton(

                        onPressed: () {

                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      AvailablePeopleScreen(
                                token:
                                    token,
                                participant:
                                    participant,
                              ),
                            ),
                          );

                        },

                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              const Color(
                                  0xFFB51F2E),
                          foregroundColor:
                              Colors.white,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        16),
                          ),
                        ),

                        child:
                            const Text(
                          'CHOOSE SOMEONE  🎁',

                          style:
                              TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                    ),

                  if (hasSelected)

                    Container(
                      width:
                          double.infinity,

                      padding:
                          const EdgeInsets
                              .all(20),

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                                0xFFE5F3EB),

                        borderRadius:
                            BorderRadius
                                .circular(
                                    16),
                      ),

                      child:
                          const Text(
                        '🎁 Your Secret Santa selection has already been confirmed.\n\n🤫 Keep it secret!',
                        textAlign:
                            TextAlign.center,

                        style:
                            TextStyle(
                          color:
                              Color(
                                  0xFF124734),
                          fontSize: 16,
                          fontWeight:
                              FontWeight
                                  .bold,
                          height: 1.5,
                        ),
                      ),
                    ),

                  const SizedBox(
                      height: 28),

                  const Text(
                    'A little appreciation • A little surprise • A lot of Christmas spirit',
                    textAlign:
                        TextAlign.center,

                    style:
                        TextStyle(
                      color:
                          Color(0xFF777777),
                      fontSize: 12,
                      fontStyle:
                          FontStyle.italic,
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
// AVAILABLE PEOPLE
// ============================================================

class AvailablePeopleScreen
    extends StatefulWidget {

  final String token;

  final Map<String, dynamic>
      participant;

  const AvailablePeopleScreen({
    super.key,
    required this.token,
    required this.participant,
  });

  @override
  State<AvailablePeopleScreen>
      createState() =>
          _AvailablePeopleScreenState();
}


class _AvailablePeopleScreenState
    extends State<AvailablePeopleScreen> {

  bool loading = true;

  List<Map<String, dynamic>>
      participants = [];

  @override
  void initState() {
    super.initState();

    _loadParticipants();
  }


  Future<void>
      _loadParticipants() async {

    try {

      final response =
          await Supabase
              .instance.client
              .rpc(
        'get_available_participants',
        params: {
          'p_token':
              widget.token,
        },
      );

      setState(() {

        participants =
            List<Map<String, dynamic>>
                .from(response);

        loading = false;

      });

    } catch (error) {

      setState(() {
        loading = false;
      });

    }
  }


  String _alertMessage() {

    final count =
        participants.length;

    if (count <= 2) {
      return '🚨 Last call, Santa! Only $count people remain. Make your choice now!';
    }

    if (count <= 5) {
      return '⚡ Hurry, Santa! Only $count people are still available.';
    }

    if (count <= 10) {
      return '🎁 Things are moving fast! Only $count people are still available.';
    }

    return '🎄 Don\'t wait too long! Your favourite person might be selected by someone else.';
  }


  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF7F3E8),

      appBar: AppBar(
        title:
            const Text(
          'Choose Someone',
        ),

        backgroundColor:
            const Color(0xFF124734),

        foregroundColor:
            Colors.white,
      ),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : Center(
              child:
                  ConstrainedBox(

                constraints:
                    const BoxConstraints(
                  maxWidth: 600,
                ),

                child: ListView(

                  padding:
                      const EdgeInsets
                          .all(20),

                  children: [

                    Container(
                      padding:
                          const EdgeInsets
                              .all(18),

                      decoration:
                          BoxDecoration(

                        color:
                            const Color(
                                0xFFFFE8B6),

                        borderRadius:
                            BorderRadius
                                .circular(
                                    16),
                      ),

                      child:
                          Text(
                        _alertMessage(),

                        textAlign:
                            TextAlign.center,

                        style:
                            const TextStyle(
                          color:
                              Color(
                                  0xFF6D4C00),
                          fontSize: 16,
                          fontWeight:
                              FontWeight
                                  .bold,
                          height: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(
                        height: 25),

                    const Text(
                      '🎁 Who would you like to surprise?',
                      textAlign:
                          TextAlign.center,

                      style:
                          TextStyle(
                        color:
                            Color(
                                0xFF124734),
                        fontSize: 23,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                        height: 8),

                    const Text(
                      'Choose carefully. Once confirmed, your selection cannot be changed.',
                      textAlign:
                          TextAlign.center,

                      style:
                          TextStyle(
                        color:
                            Colors.grey,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(
                        height: 22),

                    ...participants.map(
                      (person) {

                        return Card(

                          margin:
                              const EdgeInsets
                                  .only(
                            bottom: 12,
                          ),

                          child:
                              ListTile(

                            contentPadding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),

                            leading:
                                CircleAvatar(
                              backgroundColor:
                                  const Color(
                                      0xFF124734),

                              child:
                                  Text(
                                person['full_name']
                                    .toString()
                                    .substring(
                                        0, 1)
                                    .toUpperCase(),

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
                              person['full_name']
                                  .toString(),

                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),

                            trailing:
                                const Text(
                              '🎁',
                              style:
                                  TextStyle(
                                fontSize:
                                    22,
                              ),
                            ),

                            onTap: () {

                              ScaffoldMessenger
                                  .of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content:
                                      Text(
                                    '🎅 You selected ${person['full_name']}. Reasons screen comes next!',
                                  ),
                                ),
                              );

                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}