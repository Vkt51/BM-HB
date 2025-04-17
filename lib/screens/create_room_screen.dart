import 'package:flutter/material.dart';
import 'dart:async'; // Für Future
import 'dart:math'; // Import für Random (wird für ID-Generierung benötigt)

// Import für Firestore
import 'package:cloud_firestore/cloud_firestore.dart';

// Importiere den nächsten Screen (Wartebereich)
import 'waiting_room_screen.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  // Controller
  final _nameController = TextEditingController();

  // State Variablen
  int? _selectedNumberOfQuestions = 3;
  bool _hasModerator = false;
  bool _hasChallenges = false;
  int? _selectedNumberOfChallenges = 1;

  // Optionen Listen
  final List<int> _numberOfQuestionsOptions = [2, 3, 4, 5];
  final List<int> _numberOfChallengesOptions = [1, 2, 3];

  // Global Key für Formular Validierung
  final _formKey = GlobalKey<FormState>();

  // Variable um mehrfaches Senden zu verhindern
  bool _isCreatingRoom = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // --- Hilfsfunktion zum Generieren kurzer IDs ---
  String _generateShortId(int length) {
    const String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }
  // ----------------------------------------------------

  // --- Methode zum Erstellen des Raums und Navigieren ---
  void _navigateToWaitingRoom() async {
    // Verhindere doppeltes Ausführen
    if (_isCreatingRoom) return;

    // Prüfe Formular Gültigkeit
    if (_formKey.currentState!.validate()) {
      setState(() { _isCreatingRoom = true; }); // Markieren, dass Prozess läuft

      // Daten auslesen
      final String userName = _nameController.text.trim();
      final int numberOfQuestions = _selectedNumberOfQuestions!;
      final bool moderatorEnabled = _hasModerator;
      final bool challengesEnabled = _hasChallenges;
      final int? numberOfChallenges = challengesEnabled ? _selectedNumberOfChallenges : null;

      // --- Firestore Logik mit kurzer, eindeutiger ID ---
      try {
        // Ladeindikator anzeigen
        showDialog(
           context: context,
           barrierDismissible: false,
           builder: (BuildContext context) => const Center(child: CircularProgressIndicator(color: Colors.pinkAccent)),
        );

        CollectionReference roomsCollection = FirebaseFirestore.instance.collection('rooms');
        String uniqueRoomId;
        String moderatorId;
        int retries = 0;
        const int maxRetries = 10; // Sicherheitslimit für Generierungsversuche

        // Schleife zur Generierung und Überprüfung einer eindeutigen ID
        while (true) {
          if (retries >= maxRetries) {
             throw Exception("Konnte nach $maxRetries Versuchen keine eindeutige Raum-ID generieren.");
          }
          retries++;

          uniqueRoomId = _generateShortId(6); // Generiere 6-stellige ID
          moderatorId = "MOD-$uniqueRoomId"; // Leite Moderator-ID ab

          // Prüfe, ob die generierte Raum-ID bereits existiert (als Dokument-ID)
          final docSnapshot = await roomsCollection.doc(uniqueRoomId).get();

          if (!docSnapshot.exists) {
            // ID ist eindeutig, Schleife verlassen
            debugPrint('Eindeutige Raum-ID "$uniqueRoomId" nach $retries Versuch(en) gefunden.');
            break;
          } else {
             debugPrint('Kollision bei Raum-ID "$uniqueRoomId". Neuer Versuch...');
             await Future.delayed(const Duration(milliseconds: 50)); // Kurze Pause
          }
        }

        // Daten für das neue Raum-Dokument erstellen
        Map<String, dynamic> roomData = {
          // WICHTIG: Speichere die generierten IDs explizit als Felder im Dokument
          'roomId': uniqueRoomId,
          'moderatorId': moderatorId,
          // ---------------------------------------------------------------------
          'creatorName': userName,
          'creatorUserId': null, // Später Firebase Auth User ID
          'numberOfQuestions': numberOfQuestions,
          'hasModerator': moderatorEnabled,
          'hasChallenges': challengesEnabled,
          'numberOfChallenges': numberOfChallenges,
          'participants': [], // Leere Teilnehmerliste initial
          'status': 'waiting', // Status: Warten auf Teilnehmer
          'createdAt': Timestamp.now(), // Zeitstempel
        };

        // Dokument mit der generierten, eindeutigen `uniqueRoomId` als Dokument-ID erstellen
        // und die `roomData` (welche die IDs auch als Felder enthält) speichern.
        await roomsCollection.doc(uniqueRoomId).set(roomData);

        debugPrint('--- Raum erfolgreich in Firestore erstellt ---');
        debugPrint('Eindeutige Raum-ID (Dokument-ID): $uniqueRoomId');
        debugPrint('Zugehörige Moderator ID: $moderatorId');
        debugPrint('(IDs wurden auch als Felder im Dokument gespeichert)');
        debugPrint('-----------------------------------------');

        // Ladeindikator schließen (wichtig: Prüfung ob Widget noch gemountet ist)
        if (mounted) Navigator.of(context).pop();

        // Zum Wartebereich navigieren und die generierten IDs übergeben
        if (mounted) {
           Navigator.pushReplacement( // Ersetzt diesen Screen, kein Zurück möglich
             context,
             MaterialPageRoute(
               builder: (context) => WaitingRoomScreen(
                 userName: userName,
                 numberOfQuestions: numberOfQuestions,
                 hasModerator: moderatorEnabled, // Moderator-Status übergeben
                 roomId: uniqueRoomId,           // Kurze, eindeutige Raum-ID übergeben
                 moderatorRoomId: moderatorId, // Abgeleitete Moderator-ID übergeben
               ),
             ),
           );
        }

      } catch (e) {
         // Ladeindikator schließen im Fehlerfall
         if (mounted) Navigator.of(context).pop();

         debugPrint("Fehler beim Erstellen des Raums in Firestore: $e");
         if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('Fehler beim Erstellen des Raums: ${e.toString()}'), backgroundColor: Colors.red),
             );
         }
         // Zustand zurücksetzen, damit Nutzer es erneut versuchen kann
         setState(() { _isCreatingRoom = false; });
      }
      // --- Ende Firestore Logik ---

    } else {
      // Formular ist ungültig
      debugPrint("Formular ist ungültig.");
      setState(() { _isCreatingRoom = false; }); // Wichtig: Auch hier zurücksetzen
    }
  }
  // --------------------------------------------------------------


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Herzblatt-Raum erstellen'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView( // Wichtig für Tastatur
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text('Gib deine Daten ein:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Dein Name (als Herzblatt)', hintText: 'z.B. Sunny', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                  keyboardType: TextInputType.name,
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Bitte gib deinen Namen ein.' : null,
                ),
                const SizedBox(height: 30),
                DropdownButtonFormField<int>(
                  value: _selectedNumberOfQuestions,
                  items: _numberOfQuestionsOptions.map((v) => DropdownMenuItem<int>(value: v, child: Text('$v Fragen'))).toList(),
                  onChanged: (v) => setState(() => _selectedNumberOfQuestions = v),
                  decoration: const InputDecoration(labelText: 'Anzahl Fragen', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10)),
                  validator: (v) => (v == null) ? 'Bitte wähle die Anzahl der Fragen.' : null,
                ),
                const SizedBox(height: 30),
                SwitchListTile(
                  title: const Text('Moderator aktivieren?'),
                  subtitle: const Text('(Feature kommt später)'),
                  value: _hasModerator,
                  onChanged: (v) => setState(() => _hasModerator = v),
                  activeColor: Colors.pinkAccent,
                  secondary: const Icon(Icons.mic),
                ),
                const SizedBox(height: 15),
                SwitchListTile(
                  title: const Text('Challenges hinzufügen?'),
                  value: _hasChallenges,
                  onChanged: (v) => setState(() => _hasChallenges = v),
                  activeColor: Colors.pinkAccent,
                  secondary: const Icon(Icons.gamepad_outlined),
                ),
                const SizedBox(height: 15),
                Visibility(
                  visible: _hasChallenges,
                  child: Column(
                    children: [
                      DropdownButtonFormField<int>(
                        value: _selectedNumberOfChallenges,
                        items: _numberOfChallengesOptions.map((v) => DropdownMenuItem<int>(value: v, child: Text('$v Challenge${v > 1 ? 's' : ''}'))).toList(),
                        onChanged: (v) => setState(() => _selectedNumberOfChallenges = v),
                        decoration: const InputDecoration(labelText: 'Anzahl Challenges', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10)),
                        validator: (v) => (_hasChallenges && v == null) ? 'Bitte wähle die Anzahl der Challenges.' : null,
                      ),
                       const SizedBox(height: 40),
                    ],
                  ),
                ),
                if (!_hasChallenges) const SizedBox(height: 40), // Sicherstellen, dass der Button immer unten ist
                ElevatedButton(
                  // Deaktiviere Button während Erstellung läuft
                  onPressed: _isCreatingRoom ? null : _navigateToWaitingRoom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: _isCreatingRoom
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Text('Weiter zum Wartebereich'),
                ),
                const SizedBox(height: 20), // Platz am Ende
              ],
            ),
          ),
        ),
      ),
    );
  }
}