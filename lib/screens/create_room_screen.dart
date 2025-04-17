import 'package:flutter/material.dart';
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

  // Methode zum Erstellen des Raums und Navigieren
  void _navigateToWaitingRoom() async { // Async wegen Firestore
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

      // --- Firestore Logik ---
      try {
        // Ladeindikator anzeigen
        showDialog(
           context: context,
           barrierDismissible: false,
           builder: (BuildContext context) {
             return const Center(child: CircularProgressIndicator(color: Colors.pinkAccent));
           },
        );

        // Referenz zur 'rooms' Collection
        CollectionReference roomsCollection = FirebaseFirestore.instance.collection('rooms');

        // Daten für das neue Raum-Dokument
        Map<String, dynamic> roomData = {
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

        // Dokument hinzufügen -> Firestore generiert die ID
        DocumentReference newRoomRef = await roomsCollection.add(roomData);
        String newRoomId = newRoomRef.id; // Die ECHTE Raum-ID
        String moderatorId = "MOD-$newRoomId"; // Abgeleitete Moderator-ID

        debugPrint('--- Raum erfolgreich in Firestore erstellt ---');
        debugPrint('Firestore Document ID (Raum-ID): $newRoomId');
        debugPrint('Zugehörige Moderator ID: $moderatorId');
        debugPrint('-----------------------------------------');

        // Ladeindikator schließen (wichtig: Prüfung ob Widget noch gemountet ist)
        if (mounted) Navigator.of(context).pop();

        // Zum Wartebereich navigieren und ECHTE IDs übergeben
        if (mounted) {
           Navigator.pushReplacement( // Ersetzt diesen Screen, kein Zurück möglich
             context,
             MaterialPageRoute(
               builder: (context) => WaitingRoomScreen(
                 userName: userName,
                 numberOfQuestions: numberOfQuestions,
                 hasModerator: moderatorEnabled, // Moderator-Status übergeben
                 roomId: newRoomId,             // Echte Raum-ID übergeben
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
      // Optional: Zusätzliche Snackbar hier, obwohl Validator schon Meldungen zeigt
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Bitte überprüfe deine Eingaben.'), backgroundColor: Colors.red),
      // );
    }
  }

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
                if (!_hasChallenges) const SizedBox(height: 40),
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}