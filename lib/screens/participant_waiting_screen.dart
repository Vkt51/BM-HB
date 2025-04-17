import 'package:flutter/material.dart';
import 'dart:async';

// Import für Firestore
import 'package:cloud_firestore/cloud_firestore.dart';

// Import für HomeScreen (für Navigation)
import 'home_screen.dart';

// Importiere den nächsten Screen für Teilnehmer (wenn das Spiel startet)
// import 'participant_question_screen.dart';

class ParticipantWaitingScreen extends StatefulWidget {
  final String roomId;
  final String participantName; // Der Name dieses Teilnehmers
  final String creatorName;     // Der Name des Raumerstellers

  const ParticipantWaitingScreen({
    super.key,
    required this.roomId,
    required this.participantName,
    required this.creatorName,
  });

  @override
  State<ParticipantWaitingScreen> createState() => _ParticipantWaitingScreenState();
}

class _ParticipantWaitingScreenState extends State<ParticipantWaitingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _roomSubscription; // Um Listener später zu schließen

  // --- NEU: Statusvariable für Verlassen-Aktion ---
  bool _isLeaving = false;
  // --------------------------------------------

  @override
  void initState() {
    super.initState();
    debugPrint("ParticipantWaitingScreen: Beigetreten zu Raum ${widget.roomId} als ${widget.participantName}");
    _listenForGameStart();
  }

  @override
  void dispose() {
    _roomSubscription?.cancel(); // Wichtig: Listener schließen!
    super.dispose();
  }

  // Listener, der auf Statusänderungen des Raums hört (unverändert)
  void _listenForGameStart() {
     _roomSubscription = _firestore
        .collection('rooms')
        .doc(widget.roomId)
        .snapshots()
        .listen((roomSnapshot) {
      // Verhindere State-Änderungen, wenn gerade verlassen wird
      if (!mounted || _isLeaving) return;

      if (roomSnapshot.exists) {
        Map<String, dynamic> roomData = roomSnapshot.data() as Map<String, dynamic>;
        String? roomStatus = roomData['status'] as String?;

        if (roomStatus == 'playing') {
          _roomSubscription?.cancel();
          // TODO: Navigation zum ParticipantQuestionScreen
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Das Spiel beginnt!'), backgroundColor: Colors.green)
          );
           // Beispiel-Navigation (ersetzen!)
           // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ParticipantQuestionScreen(...)));

        } else if (roomStatus != 'waiting') {
           _roomSubscription?.cancel();
           Navigator.of(context).pushAndRemoveUntil(
             MaterialPageRoute(builder: (context) => const HomeScreen()),
             (Route<dynamic> route) => false,
           );
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Der Raum ist nicht mehr verfügbar.'), backgroundColor: Colors.orange)
           );
        }
      } else {
         _roomSubscription?.cancel();
         Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (Route<dynamic> route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Der Raum wurde aufgelöst.'), backgroundColor: Colors.grey)
          );
      }
    }, onError: (error) {
       // print("Fehler beim Lauschen auf Raum-Updates: $error");
       _roomSubscription?.cancel();
       if(mounted && !_isLeaving) { // Nur navigieren, wenn nicht gerade verlassen wird
         Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (Route<dynamic> route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verbindung zum Raum verloren: $error'), backgroundColor: Colors.red)
          );
       }
    });
  }

  // --- NEU: Methode zum Raum verlassen und zurück navigieren ---
  Future<void> _leaveRoomAndGoBack() async {
    if (_isLeaving) return; // Verhindere doppeltes Verlassen

    setState(() { _isLeaving = true; });
    // Listener stoppen, um Konflikte zu vermeiden
    await _roomSubscription?.cancel();
    _roomSubscription = null; // Sicherstellen, dass er nicht neu startet

    debugPrint("Versuche als ${widget.participantName} Raum ${widget.roomId} zu verlassen...");

    try {
      // Namen aus der Teilnehmerliste entfernen
      await _firestore.collection('rooms').doc(widget.roomId).update({
        'participants': FieldValue.arrayRemove([widget.participantName])
      });

      debugPrint("${widget.participantName} erfolgreich aus Raum ${widget.roomId} entfernt.");

      // Prüfen ob mounted bevor Context genutzt wird
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Raum verlassen.'), backgroundColor: Colors.grey),
        );
        // Zurück zum HomeScreen navigieren und alle vorherigen Routes entfernen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      debugPrint("Fehler beim Verlassen des Raums ${widget.roomId} für ${widget.participantName}: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Verlassen des Raums: ${e.toString()}'), backgroundColor: Colors.red),
        );
        // Ladezustand auch im Fehlerfall zurücksetzen
        setState(() { _isLeaving = false; });
        // Listener neu starten, falls Fehler auftrat? Oder einfach raus? Aktuell: Bleibt aus.
        // _listenForGameStart();
      }
    }
    // Ladezustand wird durch die Navigation beendet, kein setState nötig bei Erfolg
  }
  // ---------------------------------------------------------

   // --- NEU: Bestätigungsdialog für Raum verlassen ---
  Future<bool> _showLeaveConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: !_isLeaving, // Verhindere Schließen während Verlassen-Vorgang
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Raum verlassen?'),
          content: const Text('Möchtest du wirklich den Warteraum verlassen? Du musst dann erneut beitreten.'),
          actions: <Widget>[
            TextButton(
              // Deaktiviere Button während Verlassen läuft
              onPressed: _isLeaving ? null : () => Navigator.of(context).pop(false), // Abbrechen
              child: const Text('Bleiben'),
            ),
            TextButton(
              // Deaktiviere Button während Verlassen läuft
              onPressed: _isLeaving ? null : () => Navigator.of(context).pop(true), // Bestätigen
              child: Text(_isLeaving ? 'Verlasse...' : 'Ja, verlassen', style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
    // Gibt true zurück, wenn bestätigt, sonst false oder null
    return result ?? false;
  }
  // ----------------------------------------------

  @override
  Widget build(BuildContext context) {
    // PopScope fängt den System-Zurück-Button/Geste ab
    return PopScope(
      canPop: false, // Verhindert Standard-Zurück-Navigation
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (!didPop) {
          // Nur Dialog anzeigen, wenn nicht schon eine Aktion läuft
          if (!_isLeaving) {
              bool shouldLeave = await _showLeaveConfirmationDialog();
              if (shouldLeave && mounted) {
                await _leaveRoomAndGoBack(); // Starte den Verlassen/Navigationsprozess
              }
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          // --- NEU: Leading Icon für expliziten Zurück/Verlassen-Button ---
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Warteraum verlassen',
            // Deaktiviere Button während Verlassen läuft
            onPressed: _isLeaving ? null : () async {
              if (!_isLeaving) {
                  bool shouldLeave = await _showLeaveConfirmationDialog();
                  if (shouldLeave && mounted) {
                    await _leaveRoomAndGoBack();
                  }
              }
            },
          ),
          // ----------------------------------------------------------
          title: const Text('Wartebereich'),
          backgroundColor: Colors.pinkAccent,
          automaticallyImplyLeading: false, // Standard-Zurück-Button wird nicht angezeigt
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
               // --- Anzeige der Raum-ID (unverändert) ---
               Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: BoxDecoration(
                     color: Colors.pink.shade50.withAlpha(204),
                     borderRadius: BorderRadius.circular(10),
                     border: Border.all(color: Colors.pink.shade100)
                  ),
                  child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                      Text('Raum-ID:', style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
                      SelectableText(
                         widget.roomId,
                         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.black87),
                      ),
                   ],
                  ),
               ),
               const SizedBox(height: 30),

              // --- Willkommenstext mit Fettung (unverändert) ---
              Card(
                elevation: 2,
                color: Colors.white.withAlpha(230),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text.rich(
                    TextSpan(
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.4, color: Colors.black87),
                      children: <TextSpan>[
                        TextSpan(text: 'Hallo ${widget.participantName},\ndu kämpfst jetzt gleich um das Herz von '),
                        TextSpan(
                          text: widget.creatorName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: '! ❤️\nWir wünschen dir ganz viel Erfolg!'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Text(
                 'Andere Anwärter im Raum:',
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),


              // --- Teilnehmerliste mit StreamBuilder (unverändert) ---
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: _firestore.collection('rooms').doc(widget.roomId).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.pinkAccent));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Fehler beim Laden der Teilnehmer: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      // Raum existiert nicht mehr - Listener sollte das eigentlich abfangen und navigieren
                      return const Center(child: Text('Warte auf Raum...'));
                    }

                    Map<String, dynamic> roomData = snapshot.data!.data() as Map<String, dynamic>;
                    List<dynamic> participantsDynamic = roomData['participants'] as List<dynamic>? ?? [];
                    List<String> participantsList = participantsDynamic.whereType<String>().toList();

                    return ListView.builder(
                      itemCount: participantsList.length,
                      itemBuilder: (context, index) {
                        final name = participantsList[index];
                        final bool isMe = (name == widget.participantName);

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 5.0),
                          color: isMe ? Colors.pink.shade50 : Colors.white,
                          shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(8),
                             side: isMe ? BorderSide(color: Colors.pinkAccent.shade100) : BorderSide.none
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.pink.shade100,
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                              )
                            ),
                            title: Text(
                               name,
                               style: TextStyle(fontSize: 17, fontWeight: isMe ? FontWeight.bold : FontWeight.normal)
                            ),
                            trailing: isMe ? const Text('(Du)', style: TextStyle(color: Colors.grey)) : null,
                          ),
                        );
                      },
                    );
                  },
                ),
              ), // Ende Expanded

              const SizedBox(height: 20),
              // Hinweis für den Teilnehmer (unverändert)
               Text(
                  'Bitte warte, bis ${widget.creatorName} das Spiel startet...',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                ),
               const SizedBox(height: 10),
               // KEINE Buttons am Ende für Teilnehmer
            ],
          ),
        ),
      ),
    );
  }
}