import 'package:flutter/material.dart';
import 'dart:async';
import 'package:qr_flutter/qr_flutter.dart'; // Import für QR Code Generierung

// Importiere den nächsten Screen
import 'question_screen.dart';

class WaitingRoomScreen extends StatefulWidget {
  // Empfangene Daten vom CreateRoomScreen
  final String userName;
  final int numberOfQuestions;
  final bool hasModerator;
  final String roomId; // Echte Raum-ID von Firestore
  final String moderatorRoomId; // Abgeleitete Moderator-ID

  const WaitingRoomScreen({
    super.key,
    required this.userName,
    required this.numberOfQuestions,
    required this.hasModerator,
    required this.roomId, // Muss übergeben werden
    required this.moderatorRoomId, // Muss übergeben werden
  });

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  // Keine ID-Generierung mehr hier!

  // Dummy Teilnehmerliste (wird später durch Firestore-Listener ersetzt)
  final List<String> participants = ['Jacqueline', 'Petra', 'Angelika Baerbock'];

  // Animations-Status
  bool _showIntroText = false;
  bool _showParticipants = false;
  bool _showBottomButtons = false;

  @override
  void initState() {
    super.initState();
    // Keine ID-Generierung hier
    _startAnimations();
    debugPrint("WaitingRoomScreen: Empfangene Raum-ID = ${widget.roomId}");
    debugPrint("WaitingRoomScreen: Empfangene Mod-ID = ${widget.moderatorRoomId}");
    debugPrint("WaitingRoomScreen: Moderator aktiv = ${widget.hasModerator}");
     // HIER SPÄTER: Firestore Listener für Teilnehmerliste starten
  }

  void _startAnimations() {
    // Startet die UI-Animationen nacheinander
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _showIntroText = true);
    });
    Future.delayed(const Duration(milliseconds: 1300), () {
      if (mounted) setState(() => _showParticipants = true);
    });
    Future.delayed(const Duration(milliseconds: 2100), () {
      if (mounted) setState(() => _showBottomButtons = true);
    });
  }

  // Zeigt den QR-Code für die Teilnehmer-ID
  void _showQrCodeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Abgerundete Ecken
          title: const Row(children: [Icon(Icons.qr_code_2, color: Colors.pinkAccent), SizedBox(width: 10), Text('Raum beitreten')]),
          content: SizedBox(
            width: 250, height: 250,
            child: Center(
              child: QrImageView(
                data: widget.roomId, // Echte Teilnehmer-ID
                version: QrVersions.auto,
                size: 220.0, // Größe angepasst
                gapless: false,
                embeddedImage: const AssetImage('assets/images/Icon.png'), // Dein App-Icon in der Mitte? (Optional)
                embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(40, 40)),
                errorStateBuilder: (cxt, err) {
                   return const Center(
                     child: Text('Fehler beim Erzeugen des QR-Codes.', textAlign: TextAlign.center),
                   );
                 },
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: const Text('Schließen', style: TextStyle(color: Colors.pinkAccent)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // Startet das Spiel und navigiert zum QuestionScreen
  void _startGame(BuildContext context) {
    debugPrint("Herzblatt-Event wird gestartet für ${widget.userName} mit Raum ${widget.roomId}");
    // SPÄTER: Status in Firestore auf 'playing' setzen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionScreen(
          userName: widget.userName,
          numberOfQuestions: widget.numberOfQuestions,
          participants: participants, // Vorerst noch Dummy-Teilnehmer
          currentQuestionIndex: 0,
          // Später ggf. auch roomId übergeben
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wartebereich für ${widget.userName}'),
        backgroundColor: Colors.pinkAccent,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 20.0), // Padding angepasst
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
             // --- Anzeige der Raum-IDs ---
             Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                   color: Colors.pink.shade50.withOpacity(0.8),
                   borderRadius: BorderRadius.circular(8),
                   border: Border.all(color: Colors.pink.shade100) // Leichter Rand
                ),
                child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      Text('Raum-ID (Teilnehmer):', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                      SelectableText(
                         widget.roomId, // Echte ID
                         style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                      ),
                      // Bedingte Anzeige Moderator-ID
                      if (widget.hasModerator) ...[
                        const SizedBox(height: 4),
                        Text('Raum-ID (Moderator):', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                        SelectableText(
                           widget.moderatorRoomId, // Echte Mod-ID
                           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                        ),
                      ]
                   ],
                ),
             ),
             const SizedBox(height: 20),

            // --- Animierter Intro-Text ---
            AnimatedOpacity(
              opacity: _showIntroText ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 600),
              child: Column( /* ... Text unverändert ... */
                children: [
                  Text('Lieber ${widget.userName},', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.pink), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('du scheinst heiß begehrt zu sein!\nIn deinem Warteraum befinden sich:', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
                ],
               ),
            ),
            const SizedBox(height: 20),

            // --- Animierte Teilnehmerliste ---
            Expanded( // Nimmt verfügbaren Platz
              child: AnimatedOpacity(
                opacity: _showParticipants ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 600),
                 // HIER SPÄTER: StreamBuilder für Firestore-Teilnehmerliste
                child: ListView.builder(
                  itemCount: participants.length,
                  itemBuilder: (context, index) {
                    final participantName = participants[index];
                    return Card( /* ... Teilnehmer-Card unverändert ... */
                      elevation: 3, margin: const EdgeInsets.symmetric(vertical: 6.0),
                      child: ListTile(
                        leading: CircleAvatar(backgroundColor: Colors.pink.shade100, child: Text(participantName.isNotEmpty ? participantName[0] : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        title: Text(participantName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                      ),
                    );
                  },
                ),
              ),
            ), // Ende Expanded

            const SizedBox(height: 15),

             // --- Animierte untere Buttons ---
             AnimatedOpacity(
               opacity: _showBottomButtons ? 1.0 : 0.0,
               duration: const Duration(milliseconds: 600),
               child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                      OutlinedButton.icon(
                         icon: const Icon(Icons.qr_code_2),
                         label: const Text('QR-Code für Beitritt anzeigen'),
                         onPressed: _showQrCodeDialog,
                         style: OutlinedButton.styleFrom(foregroundColor: Colors.pinkAccent, side: const BorderSide(color: Colors.pinkAccent), padding: const EdgeInsets.symmetric(vertical: 10), textStyle: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton.icon(
                         icon: const Icon(Icons.swipe_right_alt, size: 28),
                         label: const Text('Herzblatt-Event starten'),
                         onPressed: () => _startGame(context),
                         style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                  ],
               ),
             ),
             const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}