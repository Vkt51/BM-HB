import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Importiere den Scanner

// Importiere den (noch zu erstellenden) QR-Scanner Screen
import 'qr_scanner_screen.dart';

// Platzhalter für den Screen, zu dem nach erfolgreichem Beitritt navigiert wird
// z.B. WaitingRoomScreen oder direkt GameScreen für Teilnehmer
// import 'participant_waiting_screen.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _roomIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }

  // Funktion zum Scannen des QR Codes
  Future<void> _scanQrCode() async {
    try {
      // Navigiere zum Scanner Screen und warte auf das Ergebnis (die ID)
      final String? scannedId = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (context) => const QrScannerScreen()),
      );

      // Wenn ein Code gescannt und zurückgegeben wurde
      if (scannedId != null && scannedId.isNotEmpty && mounted) {
        print("QR-Code gescannt: $scannedId");
        // Setze die ID im Textfeld
        setState(() {
          _roomIdController.text = scannedId;
        });
        // Optional: Direkt versuchen beizutreten
        // _joinRoom();
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Raum-ID $scannedId aus QR-Code übernommen.')),
         );
      } else if (scannedId == null && mounted) {
         print("QR-Scan abgebrochen.");
      }
    } catch (e) {
      print("Fehler beim QR-Scan: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Starten des Scanners: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Funktion zum Beitreten mit der eingegebenen ID
  void _joinRoom() {
    // Tastatur ausblenden
    FocusScope.of(context).unfocus();

    // Validieren des Formulars
    if (_formKey.currentState!.validate()) {
      final String roomId = _roomIdController.text.trim();
      print("Versuche Raum beizutreten mit ID: $roomId");

      // --- HIER KOMMT DIE EIGENTLICHE BEITRITTSLOGIK ---
      // z.B. API-Aufruf, um zu prüfen, ob der Raum existiert
      // und um sich als Teilnehmer anzumelden.
      // Danach Navigation zum entsprechenden Screen (z.B. Wartebereich für Teilnehmer)

      // Nur als Platzhalter: Zeige eine Snackbar und bleibe auf dem Screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sende Beitrittsanfrage für Raum $roomId... (Funktion noch nicht implementiert)')),
      );

      // Beispiel für spätere Navigation:
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ParticipantWaitingScreen(roomId: roomId)));
    } else {
       print("Formular ungültig (Keine ID eingegeben).");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Herzblatt-Raum beitreten'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: GestureDetector( // Zum Schließen der Tastatur bei Klick daneben
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView( // Verhindert Overflow bei kleineren Screens/Tastatur
          padding: const EdgeInsets.all(25.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Gib die Raum-ID ein:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // --- Eingabefeld für Raum-ID ---
                TextFormField(
                  controller: _roomIdController,
                  decoration: const InputDecoration(
                    labelText: 'Raum-ID',
                    hintText: 'z.B. PARTY123',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.meeting_room),
                  ),
                  keyboardType: TextInputType.text,
                  // Optional: Automatische Großschreibung
                  // textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Bitte gib die Raum-ID ein.';
                    }
                    // Optional: Weitere Prüfungen (Länge, Zeichen etc.)
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // --- Button zum Absenden der ID ---
                 ElevatedButton.icon(
                  icon: const Icon(Icons.login),
                  label: const Text('Mit ID beitreten'),
                  onPressed: _joinRoom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 40),

                 // --- Trennlinie oder Text ---
                Row(
                   children: <Widget>[
                     const Expanded(child: Divider(thickness: 1)),
                     Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 15.0),
                       child: Text(
                         'ODER',
                         style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                       ),
                     ),
                     const Expanded(child: Divider(thickness: 1)),
                   ],
                 ),
                const SizedBox(height: 40),

                // --- Button für QR-Code Scan ---
                 OutlinedButton.icon(
                  icon: const Icon(Icons.qr_code_scanner, size: 28),
                  label: const Text('QR-Code scannen'),
                  onPressed: _scanQrCode,
                   style: OutlinedButton.styleFrom(
                     foregroundColor: Colors.pinkAccent, // Text/Icon Farbe
                     side: const BorderSide(color: Colors.pinkAccent), // Randfarbe
                     padding: const EdgeInsets.symmetric(vertical: 12),
                     textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                   ),
                ),
                const SizedBox(height: 30), // Platz am Ende
              ],
            ),
          ),
        ),
      ),
    );
  }
}