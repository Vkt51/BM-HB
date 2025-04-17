import 'package:flutter/material.dart';
import 'dart:async';

// Import für Firestore
import 'package:cloud_firestore/cloud_firestore.dart';

// Import für QR Code Generierung
import 'package:qr_flutter/qr_flutter.dart';

// Importiere die nächsten Screens
import 'question_screen.dart';
import 'home_screen.dart'; // Für die Navigation zurück zum Start

class WaitingRoomScreen extends StatefulWidget {
  // Empfangene Daten vom CreateRoomScreen
  final String userName;
  final int numberOfQuestions;
  final bool hasModerator;
  final String roomId; // Kurze, eindeutige Raum-ID von Firestore
  final String moderatorRoomId; // Abgeleitete Moderator-ID

  const WaitingRoomScreen({
    super.key,
    required this.userName,
    required this.numberOfQuestions,
    required this.hasModerator,
    required this.roomId,
    required this.moderatorRoomId,
  });

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  // TODO: Ersetze dies durch einen Firestore StreamBuilder
  final List<String> participants = ['Jacqueline', 'Petra', 'Angelika Baerbock'];

  // Statusvariablen
  bool _showIntroText = false;
  bool _showParticipants = false;
  bool _showBottomButtons = false;
  bool _isStartingGame = false;
  bool _isDeletingRoom = false;

  // Firestore Instanz
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _startAnimations();
    debugPrint("WaitingRoomScreen: Empfangene Raum-ID = ${widget.roomId}");
    debugPrint("WaitingRoomScreen: Empfangene Mod-ID = ${widget.moderatorRoomId}");
    debugPrint("WaitingRoomScreen: Moderator aktiv = ${widget.hasModerator}");
    // TODO: Firestore Listener für Teilnehmerliste starten (z.B. mit widget.roomId)
  }

  void _startAnimations() {
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

  // --- Methode zum Raum löschen und zurück navigieren (unverändert) ---
  Future<void> _deleteRoomAndGoBack() async {
    if (_isDeletingRoom) return;
    setState(() { _isDeletingRoom = true; });
    debugPrint("Versuche Raum ${widget.roomId} zu löschen...");
    try {
      await _firestore.collection('rooms').doc(widget.roomId).delete();
      debugPrint("Raum ${widget.roomId} erfolgreich gelöscht.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Raum wurde aufgelöst.'), backgroundColor: Colors.grey),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      debugPrint("Fehler beim Löschen des Raums ${widget.roomId}: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Löschen des Raums: ${e.toString()}'), backgroundColor: Colors.red),
        );
        setState(() { _isDeletingRoom = false; });
      }
    }
  }

  // --- Bestätigungsdialog für Raum löschen (unverändert) ---
  Future<bool> _showDeleteConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: !_isDeletingRoom,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Raum auflösen?'),
          content: const Text('Möchtest du wirklich zurückgehen? Der Raum und alle Daten werden unwiderruflich gelöscht.'),
          actions: <Widget>[
            TextButton(
              onPressed: _isDeletingRoom ? null : () => Navigator.of(context).pop(false),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: _isDeletingRoom ? null : () => Navigator.of(context).pop(true),
              child: Text(_isDeletingRoom ? 'Lösche...' : 'Ja, auflösen', style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  // --- Zeigt den QR-Code (unverändert) ---
  void _showQrCodeDialog() {
    if (_isStartingGame || _isDeletingRoom) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Row(children: [Icon(Icons.qr_code_2, color: Colors.pinkAccent), SizedBox(width: 10), Text('Raum beitreten')]),
          content: SizedBox(
            width: 250, height: 250,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SelectableText(
                  widget.roomId,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                QrImageView(
                  data: widget.roomId,
                  version: QrVersions.auto,
                  size: 200.0,
                  gapless: false,
                  embeddedImage: const AssetImage('assets/images/Icon.png'),
                  embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(35, 35)),
                  errorStateBuilder: (cxt, err) {
                     return const Center(
                       child: Text('Fehler beim Erzeugen des QR-Codes.', textAlign: TextAlign.center),
                     );
                   },
                ),
              ],
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

  // --- Startet das Spiel (unverändert) ---
  Future<void> _startGame() async {
    if (_isStartingGame || _isDeletingRoom) return;
    // TODO: Optional: Prüfen, ob genügend Teilnehmer vorhanden sind
    setState(() { _isStartingGame = true; });
    debugPrint("Starte Herzblatt-Event für Raum ${widget.roomId}...");
    try {
      await _firestore.collection('rooms').doc(widget.roomId).update({'status': 'playing'});
      debugPrint("Status für Raum ${widget.roomId} auf 'playing' gesetzt.");
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuestionScreen(
              userName: widget.userName,
              numberOfQuestions: widget.numberOfQuestions,
              participants: participants,
              currentQuestionIndex: 0,
              roomId: widget.roomId,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Fehler beim Starten des Spiels für Raum ${widget.roomId}: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Starten des Spiels: ${e.toString()}'), backgroundColor: Colors.red),
        );
        setState(() { _isStartingGame = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- KORRIGIERT: PopScope mit onPopInvokedWithResult ---
    return PopScope( // Deprecation Warnung 6 behoben
      canPop: false,
      // Neuer Parametername und Signatur (result wird hier ignoriert)
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (!didPop) {
          if (!_isStartingGame && !_isDeletingRoom) {
              bool shouldDelete = await _showDeleteConfirmationDialog();
              if (shouldDelete && mounted) {
                await _deleteRoomAndGoBack();
              }
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Zurück (Raum auflösen)',
            onPressed: (_isStartingGame || _isDeletingRoom) ? null : () async {
              if (!_isStartingGame && !_isDeletingRoom) {
                  bool shouldDelete = await _showDeleteConfirmationDialog();
                  if (shouldDelete && mounted) {
                    await _deleteRoomAndGoBack();
                  }
              }
            },
          ),
          title: Text('Wartebereich für ${widget.userName}'),
          backgroundColor: Colors.pinkAccent,
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
               // --- Anzeige der Raum-IDs ---
               Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: BoxDecoration(
                     // --- KORRIGIERT: withOpacity durch withAlpha ersetzt ---
                     color: Colors.pink.shade50.withAlpha(204), // Deprecation Warnung 7 behoben (0.8 * 255 = 204)
                     borderRadius: BorderRadius.circular(10),
                     border: Border.all(color: Colors.pink.shade100)
                  ),
                  child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                        // --- KORRIGIERT: const aus TextStyle entfernt ---
                        Text('Raum-ID (Für Teilnehmer):', style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500)), // Fehler 1 behoben
                        Row(
                          children: [
                            Expanded(
                              child: SelectableText(
                                 widget.roomId,
                                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                        if (widget.hasModerator) ...[
                          const SizedBox(height: 8),
                           // --- KORRIGIERT: const aus TextStyle entfernt ---
                          Text('Moderator-ID:', style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500)), // Fehler 2 behoben
                          Row(
                            children: [
                              Expanded(
                                child: SelectableText(
                                   widget.moderatorRoomId,
                                   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ]
                     ],
                  ),
               ),
               const SizedBox(height: 25),

              // --- Animierter Intro-Text ---
              AnimatedOpacity(
                opacity: _showIntroText ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 600),
                child: Column(
                  children: [
                    Text('Lieber ${widget.userName},', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.pink), textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text('du scheinst heiß begehrt zu sein!\nIn deinem Warteraum befinden sich:', style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.3), textAlign: TextAlign.center),
                  ],
                 ),
              ),
              const SizedBox(height: 20),

              // --- Animierte Teilnehmerliste ---
              Expanded(
                child: AnimatedOpacity(
                  opacity: _showParticipants ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 600),
                  // TODO: Ersetze ListView.builder durch einen StreamBuilder
                  child: ListView.builder(
                    itemCount: participants.length,
                    itemBuilder: (context, index) {
                      final participantName = participants[index];
                      return Card(
                        elevation: 3, margin: const EdgeInsets.symmetric(vertical: 6.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.pink.shade100,
                            child: Text(
                              participantName.isNotEmpty ? participantName[0].toUpperCase() : '?',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                            )
                          ),
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
                           icon: const Icon(Icons.qr_code_scanner_outlined),
                           label: const Text('QR-Code für Beitritt anzeigen'),
                           onPressed: (_isStartingGame || _isDeletingRoom) ? null : _showQrCodeDialog,
                           style: OutlinedButton.styleFrom(
                             foregroundColor: Colors.pinkAccent,
                             side: BorderSide(color: (_isStartingGame || _isDeletingRoom) ? Colors.grey : Colors.pinkAccent, width: 1.5),
                             padding: const EdgeInsets.symmetric(vertical: 12),
                             textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                            ),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton.icon(
                           icon: _isStartingGame
                               ? const SizedBox(
                                   width: 20,
                                   height: 20,
                                   child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                                 )
                               : const Icon(Icons.celebration_outlined, size: 28),
                           label: Text(_isStartingGame ? 'Starte...' : 'Herzblatt-Event starten'),
                           onPressed: (_isStartingGame || _isDeletingRoom) ? null : _startGame,
                           style: ElevatedButton.styleFrom(
                             backgroundColor: (_isStartingGame || _isDeletingRoom) ? Colors.grey : Colors.green.shade600,
                             foregroundColor: Colors.white,
                             padding: const EdgeInsets.symmetric(vertical: 14),
                             textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                            ),
                        ),
                    ],
                 ),
               ),
               const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
    // -----------------------------------------------------
  }
}