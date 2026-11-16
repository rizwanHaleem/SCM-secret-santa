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


  Future<void> _loadParticipants() async {
  try {
    final response =
        await Supabase.instance.client.rpc(
      'get_available_participants',
      params: {
        'p_token': widget.token,
      },
    );

    if (!mounted) return;

    setState(() {
      participants =
          List<Map<String, dynamic>>.from(response);

      loading = false;
    });
  } catch (error) {
    if (!mounted) return;

    setState(() {
      loading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          'Unable to refresh Secret Santa availability. Please try again.',
        ),
      ),
    );
  }
}


 String _alertMessage() {
  final count = participants.length;

  if (count == 0) {
    return '🎄 All available Secret Santa selections have now been taken.';
  }

  if (count == 1) {
    return '🚨 Last call, Santa! Only 1 person is available for you. Make your choice now!';
  }

  if (count == 2) {
    return '🚨 Christmas Alert! Only 2 people are still available. Make your choice now!';
  }

  if (count <= 5) {
    return '⚡ Hurry, Santa! Only $count people are still available. Choose your person before someone else does!';
  }

  if (count <= 10) {
    return '🎁 Things are moving fast! Only $count people are still available. Make your choice soon!';
  }

  return '🎄 Secret Santa selection is open! Don\'t wait too long. Someone else may choose your preferred person first!';
}

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF7F3E8),

      appBar: AppBar(
  title: const Text(
    'Choose Someone',
  ),

  backgroundColor:
      const Color(0xFF124734),

  foregroundColor:
      Colors.white,

  actions: [
    IconButton(
      tooltip: 'Refresh availability',
      onPressed: loading
          ? null
          : () {
              setState(() {
                loading = true;
              });

              _loadParticipants();
            },
      icon: const Icon(
        Icons.refresh,
      ),
    ),
  ],
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

                        if (participants.isEmpty)

  Container(
    padding: const EdgeInsets.all(25),

    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),

    child: const Column(
      children: [

        Text(
          '🎅',
          style: TextStyle(
            fontSize: 55,
          ),
        ),

        SizedBox(height: 15),

        Text(
          'No selections are currently available',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF124734),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 12),

        Text(
          'Please contact the Secret Santa event coordinator for assistance.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF666666),
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ],
    ),
  ),

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

                               Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ReasonsScreen(
        token: widget.token,
        recipient: person,
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
// ============================================================
// REASONS SCREEN
// ============================================================

class ReasonsScreen extends StatefulWidget {

  final String token;

  final Map<String, dynamic> recipient;

  const ReasonsScreen({
    super.key,
    required this.token,
    required this.recipient,
  });

  @override
  State<ReasonsScreen> createState() => _ReasonsScreenState();
}


class _ReasonsScreenState extends State<ReasonsScreen> {

  final reason1Controller = TextEditingController();
  final reason2Controller = TextEditingController();

  @override
  void dispose() {
    reason1Controller.dispose();
    reason2Controller.dispose();
    super.dispose();
  }


  void _continueToReview() {

    final reason1 =
        reason1Controller.text.trim();

    final reason2 =
        reason2Controller.text.trim();


    if (reason1.length < 10) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '🎅 Please enter a little more detail for Reason 1.',
          ),
        ),
      );

      return;
    }


    if (reason2.length < 10) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '🎅 Please enter a little more detail for Reason 2.',
          ),
        ),
      );

      return;
    }


    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmationScreen(
          token: widget.token,
          recipient: widget.recipient,
          reason1: reason1,
          reason2: reason2,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    final recipientName =
        widget.recipient['full_name'].toString();

    return Scaffold(

      backgroundColor:
          const Color(0xFFF7F3E8),

      appBar: AppBar(
        title: const Text(
          'Why This Person?',
        ),
        backgroundColor:
            const Color(0xFF124734),
        foregroundColor:
            Colors.white,
      ),

      body: Center(
        child: SingleChildScrollView(

          padding:
              const EdgeInsets.all(22),

          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 550,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,

              children: [

                const Text(
                  '❤️',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontSize: 55,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'You selected $recipientName',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color:
                        Color(0xFF124734),
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Tell us why this person is special to you.',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color:
                        Color(0xFF666666),
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  '1. Why did you choose this person?',
                  style: TextStyle(
                    color:
                        Color(0xFF124734),
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller:
                      reason1Controller,
                  maxLength: 250,
                  maxLines: 4,
                  decoration:
                      InputDecoration(
                    hintText:
                        'Example: You were always there to support me during the year...',
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

                const SizedBox(height: 20),

                const Text(
                  '2. What do you appreciate about this person?',
                  style: TextStyle(
                    color:
                        Color(0xFF124734),
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller:
                      reason2Controller,
                  maxLength: 250,
                  maxLines: 4,
                  decoration:
                      InputDecoration(
                    hintText:
                        'Example: Your positive attitude makes working together enjoyable...',
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

                const SizedBox(height: 16),

                Container(
                  padding:
                      const EdgeInsets.all(
                          16),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                            0xFFFFF0D8),
                    borderRadius:
                        BorderRadius.circular(
                            14),
                  ),
                  child:
                      const Text(
                    '✨ These messages may become part of the Christmas reveal, so make them meaningful and positive.',
                    textAlign:
                        TextAlign.center,
                    style:
                        TextStyle(
                      color:
                          Color(0xFF6D4C00),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  height: 58,
                  child:
                      ElevatedButton(
                    onPressed:
                        _continueToReview,
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(
                              0xFFB51F2E),
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
                        const Text(
                      'REVIEW MY CHOICE  🎁',
                      style:
                          TextStyle(
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
// FINAL CONFIRMATION SCREEN
// ============================================================

class ConfirmationScreen extends StatefulWidget {

  final String token;

  final Map<String, dynamic> recipient;

  final String reason1;

  final String reason2;

  const ConfirmationScreen({
    super.key,
    required this.token,
    required this.recipient,
    required this.reason1,
    required this.reason2,
  });

  @override
  State<ConfirmationScreen> createState() =>
      _ConfirmationScreenState();
}


class _ConfirmationScreenState
    extends State<ConfirmationScreen> {

  bool confirming = false;


  Future<void> _confirmSelection() async {

    if (confirming) return;

    setState(() {
      confirming = true;
    });


    try {

      final response =
          await Supabase.instance.client.rpc(
        'confirm_gift_selection',

        params: {
          'p_token':
              widget.token,

          'p_recipient_id':
              widget.recipient['id'],

          'p_reason_1':
              widget.reason1,

          'p_reason_2':
              widget.reason2,
        },
      );


      if (!mounted) return;


      if (response == 'SUCCESS') {

        Navigator.pushAndRemoveUntil(
          context,

          MaterialPageRoute(
            builder:
                (context) =>
                    SuccessScreen(
              recipientName:
                  widget.recipient[
                          'full_name']
                      .toString(),
            ),
          ),

          (route) => false,
        );
      }


    } catch (error) {

      if (!mounted) return;

      setState(() {
        confirming = false;
      });


      final text =
          error.toString();


      if (text.contains(
              'RECIPIENT_ALREADY_SELECTED') ||
          text.contains(
              'SELECTION_CONFLICT')) {

        _showUnavailableMessage();

        return;
      }


      if (text.contains(
          'ALREADY_SELECTED')) {

        _showAlreadySelectedMessage();

        return;
      }


      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          backgroundColor:
              Colors.red,
          content: Text(
            'Something went wrong. Please try again.',
          ),
        ),
      );
    }
  }


 void _showUnavailableMessage() {
  showDialog(
    context: context,
    barrierDismissible: false,

    builder: (dialogContext) {
      return AlertDialog(

        title: const Text(
          '🎅 Someone was quicker!',
        ),

        content: Text(
          '${widget.recipient['full_name']} has just been selected by another Secret Santa.\n\nDon\'t worry. There are still other people waiting for some Christmas magic! 🎁',
        ),

        actions: [
          ElevatedButton(

            onPressed: () {
              Navigator.pop(dialogContext);

              Navigator.pop(context);
              Navigator.pop(context);
            },

            child: const Text(
              'SEE WHO\'S AVAILABLE 🎁',
            ),
          ),
        ],
      );
    },
  );
}

  void _showAlreadySelectedMessage() {

    showDialog(
      context: context,

      barrierDismissible: false,

      builder: (context) {

        return AlertDialog(

          title:
              const Text(
            '🎁 Selection Already Confirmed',
          ),

          content:
              const Text(
            'Your Secret Santa selection has already been locked and cannot be changed.',
          ),

          actions: [

            ElevatedButton(
              onPressed: () {

                Navigator.pop(context);

                Navigator.popUntil(
                  context,
                  (route) =>
                      route.isFirst,
                );

              },

              child:
                  const Text(
                'OK',
              ),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {

    final recipientName =
        widget.recipient['full_name']
            .toString();

    return Scaffold(

      backgroundColor:
          const Color(0xFFF7F3E8),

      appBar: AppBar(
        title:
            const Text(
          'Final Confirmation',
        ),
        backgroundColor:
            const Color(0xFF124734),
        foregroundColor:
            Colors.white,
      ),

      body: Center(
        child: SingleChildScrollView(

          padding:
              const EdgeInsets.all(22),

          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 550,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,

              children: [

                const Text(
                  '🎁',
                  textAlign:
                      TextAlign.center,
                  style:
                      TextStyle(
                    fontSize: 60,
                  ),
                ),

                const SizedBox(
                    height: 12),

                const Text(
                  'Ready to lock your choice?',
                  textAlign:
                      TextAlign.center,
                  style:
                      TextStyle(
                    color:
                        Color(0xFF124734),
                    fontSize: 25,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                    height: 25),

                _reviewCard(
                  'Your Secret Santa Person',
                  recipientName,
                ),

                const SizedBox(
                    height: 14),

                _reviewCard(
                  'Why you chose them',
                  widget.reason1,
                ),

                const SizedBox(
                    height: 14),

                _reviewCard(
                  'What you appreciate about them',
                  widget.reason2,
                ),

                const SizedBox(
                    height: 22),

                Container(
                  padding:
                      const EdgeInsets.all(
                          18),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                            0xFFFFE0E0),
                    borderRadius:
                        BorderRadius.circular(
                            16),
                    border:
                        Border.all(
                      color:
                          const Color(
                              0xFFB51F2E),
                    ),
                  ),
                  child:
                      const Text(
                    '🔒 IMPORTANT\n\nOnce you press Confirm My Choice, your selection and remarks are final and cannot be changed.',
                    textAlign:
                        TextAlign.center,
                    style:
                        TextStyle(
                      color:
                          Color(0xFF8B1E2D),
                      fontSize: 15,
                      fontWeight:
                          FontWeight.bold,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(
                    height: 24),

                if (!confirming)

                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child:
                        const Text(
                      '← GO BACK AND REVIEW',
                    ),
                  ),

                const SizedBox(
                    height: 10),

                SizedBox(
                  height: 58,
                  child:
                      ElevatedButton(
                    onPressed:
                        confirming
                            ? null
                            : _confirmSelection,

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(
                              0xFFB51F2E),
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
                        confirming

                            ? const SizedBox(
                                width: 25,
                                height: 25,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      3,
                                  color:
                                      Colors.white,
                                ),
                              )

                            : const Text(
                                '🔒 CONFIRM MY CHOICE',
                                style:
                                    TextStyle(
                                  fontSize:
                                      16,
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


  Widget _reviewCard(
      String title,
      String text) {

    return Container(
      padding:
          const EdgeInsets.all(18),

      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
      ),

      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(
            title,
            style:
                const TextStyle(
              color:
                  Color(0xFF124734),
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            text,
            style:
                const TextStyle(
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SUCCESS SCREEN
// ============================================================

class SuccessScreen extends StatelessWidget {

  final String recipientName;

  const SuccessScreen({
    super.key,
    required this.recipientName,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFF124734),

      body: SafeArea(
        child: Center(

          child:
              SingleChildScrollView(

            padding:
                const EdgeInsets.all(30),

            child:
                ConstrainedBox(

              constraints:
                  const BoxConstraints(
                maxWidth: 500,
              ),

              child:
                  Column(
                children: [

                  const Text(
                    '🎉🎄🎁',
                    style:
                        TextStyle(
                      fontSize: 55,
                    ),
                  ),

                  const SizedBox(
                      height: 25),

                  const Text(
                    'IT\'S OFFICIAL!',
                    textAlign:
                        TextAlign.center,
                    style:
                        TextStyle(
                      color:
                          Colors.white,
                      fontSize: 32,
                      fontWeight:
                          FontWeight.w900,
                      letterSpacing:
                          1.5,
                    ),
                  ),

                  const SizedBox(
                      height: 18),

                  const Text(
                    'Your Christmas mission has been locked.',
                    textAlign:
                        TextAlign.center,
                    style:
                        TextStyle(
                      color:
                          Colors.white70,
                      fontSize: 17,
                    ),
                  ),

                  const SizedBox(
                      height: 32),

                  Container(
                    width:
                        double.infinity,
                    padding:
                        const EdgeInsets.all(
                            28),

                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                              24),
                    ),

                    child:
                        Column(
                      children: [

                        const Text(
                          '🎅',
                          style:
                              TextStyle(
                            fontSize: 60,
                          ),
                        ),

                        const SizedBox(
                            height: 15),

                        const Text(
                          'You are Secret Santa for',
                          style:
                              TextStyle(
                            color:
                                Color(
                                    0xFF666666),
                            fontSize:
                                16,
                          ),
                        ),

                        const SizedBox(
                            height: 8),

                        Text(
                          recipientName,
                          textAlign:
                              TextAlign.center,
                          style:
                              const TextStyle(
                            color:
                                Color(
                                    0xFF124734),
                            fontSize:
                                27,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                            height: 24),

                        const Divider(),

                        const SizedBox(
                            height: 20),

                        const Text(
                          '🤫',
                          style:
                              TextStyle(
                            fontSize:
                                42,
                          ),
                        ),

                        const SizedBox(
                            height: 10),

                        const Text(
                          'Now comes the difficult part...',
                          textAlign:
                              TextAlign.center,
                          style:
                              TextStyle(
                            color:
                                Color(
                                    0xFF666666),
                            fontSize:
                                15,
                          ),
                        ),

                        const SizedBox(
                            height: 8),

                        const Text(
                          'KEEP IT SECRET!',
                          textAlign:
                              TextAlign.center,
                          style:
                              TextStyle(
                            color:
                                Color(
                                    0xFFB51F2E),
                            fontSize:
                                21,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height: 30),

                  const Text(
                    'See you at the Christmas celebration! 🎄',
                    textAlign:
                        TextAlign.center,
                    style:
                        TextStyle(
                      color:
                          Colors.white,
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w600,
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