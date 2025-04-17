import 'package:flutter/material.dart';
import 'dart:async'; // Für Future

// Import für Firestore
import 'package:cloud_firestore/cloud_firestore.dart';

// Importiere den QR-Scanner Screen
import 'qr_scanner_screen.dart'; // Stelle sicher, dass dieser Import korrekt ist

// Importiere den neuen Screen für Teilnehmer
import 'participant_waiting_screen.dart'; // NEUER IMPORT

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _roomIdController = TextEditingController();
  final _nameController = TextEditingController(); // NEU: Controller für Namen
  final _formKey = GlobalKey<FormState>();
  bool _isJoining = false; // Statusvariable für Ladeanzeige

  @override
  void dispose() {
    _roomIdController.dispose();
    _nameController.dispose(); // NEU: Controller disposen
    super.dispose();
  }

  // Funktion zum Scannen des QR Codes (unverändert)
  Future<void> _scanQrCode() async {
    if (_isJoining) return;
    try {
      final String? scannedId = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (context) => const QrScannerScreen()),
      );
      if (scannedId != null && scannedId.isNotEmpty && mounted) {
        print("QR-Code gescannt: $scannedId");
        setState(() {
          _roomIdController.text = scannedId.toUpperCase();
        });
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Raum-ID ${_roomIdController.text} aus QR-Code übernommen.')),
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

  // --- ANGEPASSTE Funktion zum Beitreten mit Namen und Firestore Update ---
  Future<void> _joinRoom() async {
    FocusScope.of(context).unfocus();
    if (_isJoining) return;

    // Validieren des Formulars (jetzt inkl. Name)
    if (_formKey.currentState!.validate()) {
      setState(() { _isJoining = true; });

      final String roomId = _roomIdController.text.trim().toUpperCase();
      final String participantName = _nameController.text.trim(); // NEU: Namen holen
      print("Versuche Raum $roomId beizutreten als '$participantName'");

      try {
        DocumentReference roomDocRef = FirebaseFirestore.instance.collection('rooms').doc(roomId);
        DocumentSnapshot roomSnapshot = await roomDocRef.get();

        if (!mounted) return; // Prüfen vor Context-Nutzung

        if (roomSnapshot.exists) {
          Map<String, dynamic> roomData = roomSnapshot.data() as Map<String, dynamic>;
          String? roomStatus = roomData['status'] as String?;
          String creatorName = roomData['creatorName'] ?? 'Unbekannt'; // Holen des Erstellernamens

          print("Raum $roomId gefunden! Status: $roomStatus, Ersteller: $creatorName");

          if (roomStatus == 'waiting') {
            print("Raum $roomId ist offen für Beitritt.");

            // --- NEU: Teilnehmer zu Firestore hinzufügen ---
            try {
              // Füge den Namen zur participants-Liste hinzu (verhindert Duplikate)
              await roomDocRef.update({
                'participants': FieldValue.arrayUnion([participantName])
              });
              print("Teilnehmer '$participantName' erfolgreich zu Raum $roomId hinzugefügt.");

              // Erfolgsmeldung für den User
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erfolgreich Raum "$roomId" beigetreten!'),
                  backgroundColor: Colors.green,
                ),
              );

              // --- NEU: Navigation zum ParticipantWaitingScreen ---
              // Ersetze den aktuellen Screen, damit man nicht hierher zurück kann
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ParticipantWaitingScreen(
                    roomId: roomId,
                    participantName: participantName,
                    creatorName: creatorName, // Erstellername übergeben
                  ),
                ),
              );
              // Der Ladezustand wird durch die Navigation beendet

            } catch (updateError) {
               print("Fehler beim Hinzufügen des Teilnehmers: $updateError");
               if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                     content: Text('Fehler beim Beitreten: ${updateError.toString()}'),
                     backgroundColor: Colors.red,
                   ),
                 );
               }
               // Ladezustand bei Fehler zurücksetzen
                setState(() { _isJoining = false; });
            }
            // -----------------------------------------

          } else {
            // Raum existiert, aber Status ist nicht 'waiting' (Logik unverändert)
            print("Raum $roomId kann nicht beigetreten werden (Status: $roomStatus).");
            String message;
            if (roomStatus == 'playing') {
               message = 'Beitritt nicht möglich. Der Raum hat bereits begonnen.';
            } else if (roomStatus == 'finished') {
               message = 'Beitritt nicht möglich. Der Raum ist bereits beendet.';
            } else {
               message = 'Beitritt nicht möglich. Der Raum ist derzeit nicht verfügbar (Status: $roomStatus).';
            }
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.orange,
              ),
            );
             // Ladezustand zurücksetzen
            setState(() { _isJoining = false; });
          }

        } else {
          // Raum existiert nicht! (Logik unverändert)
          print("Raum $roomId nicht gefunden!");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dieser Raum existiert nicht. Bitte überprüfe die ID.'),
              backgroundColor: Colors.red,
            ),
          );
           // Ladezustand zurücksetzen
          setState(() { _isJoining = false; });
        }

      } catch (e) {
        print("Fehler beim Prüfen des Raums: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fehler bei der Raum-Abfrage: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
         // Ladezustand zurücksetzen
        setState(() { _isJoining = false; });
      }
      // Der `finally`-Block ist nicht mehr nötig, da der Ladezustand in jedem Pfad explizit beendet wird (oder durch Navigation)
    } else {
       print("Formular ungültig.");
       // Sicherstellen, dass Ladezustand aus ist, falls Validierung fehlschlägt
       if (_isJoining) {
         setState(() { _isJoining = false; });
       }
    }
  }
  // -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Herzblatt-Raum beitreten'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Gib deinen Namen und die Raum-ID ein:', // Text angepasst
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // --- NEU: Eingabefeld für Namen ---
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Dein Name',
                    hintText: 'Wie sollen dich die anderen nennen?',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words, // Erster Buchstabe groß
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Bitte gib deinen Namen ein.';
                    }
                    if (value.trim().length < 2) {
                       return 'Name sollte mindestens 2 Zeichen haben.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // ---------------------------------

                // --- Eingabefeld für Raum-ID (Validierung leicht angepasst) ---
                TextFormField(
                  controller: _roomIdController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'Raum-ID',
                    hintText: 'ABC123',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.meeting_room),
                  ),
                  maxLength: 6,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Bitte gib die Raum-ID ein.';
                    }
                    final cleanValue = value.trim().toUpperCase();
                    if (cleanValue.length != 6) {
                      return 'Die Raum-ID muss genau 6 Zeichen lang sein.';
                    }
                    if (!RegExp(r'^[A-Z0-9]{6}$').hasMatch(cleanValue)) {
                      return 'Nur Großbuchstaben und Zahlen erlaubt.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                 // --- Button zum Absenden der ID ---
                 ElevatedButton.icon(
                  icon: _isJoining
                      ? const SizedBox( // Ladeindikator
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                             color: Colors.white,
                             strokeWidth: 3,
                           ),
                        )
                      : const Icon(Icons.login),
                  label: Text(_isJoining ? 'Trete bei...' : 'Raum beitreten'), // Text angepasst
                  onPressed: _isJoining ? null : _joinRoom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 40),

                 // --- Trennlinie oder Text (unverändert) ---
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

                // --- Button für QR-Code Scan (unverändert) ---
                 OutlinedButton.icon(
                  icon: const Icon(Icons.qr_code_scanner, size: 28),
                  label: const Text('QR-Code scannen'),
                  onPressed: _isJoining ? null : _scanQrCode,
                   style: OutlinedButton.styleFrom(
                     foregroundColor: Colors.pinkAccent,
                     side: BorderSide(color: _isJoining ? Colors.grey : Colors.pinkAccent),
                     padding: const EdgeInsets.symmetric(vertical: 12),
                     textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                   ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}