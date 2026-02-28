import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  static final _picker = ImagePicker();
  static final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Pick image from camera or gallery and extract text
  static Future<String?> scanPrescription({bool fromCamera = true}) async {
    final XFile? image = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 90,
    );

    if (image == null) return null;

    final inputImage = InputImage.fromFile(File(image.path));
    final recognized = await _recognizer.processImage(inputImage);
    return recognized.text;
  }

  /// Parse raw OCR text into structured medicine data
  static List<ParsedMedicine> parsePrescriptionText(String text) {
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    final medicines = <ParsedMedicine>[];

    // Common time patterns
    final timePatterns = [
      RegExp(r'\b(\d{1,2}):(\d{2})\s*(AM|PM|am|pm)?\b'),
      RegExp(r'\b(\d{1,2})\s*(AM|PM|am|pm)\b'),
      RegExp(r'\b(morning|afternoon|evening|night|noon|bedtime|breakfast|lunch|dinner)\b', caseSensitive: false),
    ];

    // Dosage patterns
    final dosagePattern = RegExp(
      r'\b(\d+\.?\d*\s*(mg|mcg|ml|g|tablet|tab|cap|capsule|drop|unit|iu|puff)s?)\b',
      caseSensitive: false,
    );

    // Frequency patterns
    final freqPattern = RegExp(
      r'\b(once|twice|thrice|(\d+)\s*times?)\s*(a\s*)?(day|daily|daily)\b',
      caseSensitive: false,
    );

    // Medicine name patterns (Title Case words that aren't common words)
    final medicineNamePattern = RegExp(r'\b[A-Z][a-z]{2,}(?:\s+[A-Z][a-z]+)?\b');
    final ignoreWords = {
      'Take', 'After', 'Before', 'With', 'Tablet', 'Cap', 'Times', 'Once',
      'Twice', 'Daily', 'Doctor', 'Patient', 'Prescription', 'Date', 'Name',
      'Age', 'Dose', 'Sig', 'Refill', 'For', 'The', 'And', 'Qty'
    };

    String? currentMedicine;
    String? currentDosage;
    List<String> currentTimes = [];
    String currentInstructions = '';

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Check if this looks like a medicine name (usually first word on a line, possibly followed by dosage)
      final dosageMatch = dosagePattern.firstMatch(line);
      final nameMatches = medicineNamePattern.allMatches(line)
          .map((m) => m.group(0)!)
          .where((w) => !ignoreWords.contains(w))
          .toList();

      if (nameMatches.isNotEmpty && dosageMatch != null) {
        // Save previous medicine
        if (currentMedicine != null && currentTimes.isNotEmpty) {
          medicines.add(ParsedMedicine(
            name: currentMedicine,
            dosage: currentDosage ?? '1 Tablet',
            times: currentTimes,
            instructions: currentInstructions,
          ));
        }

        currentMedicine = nameMatches.first;
        currentDosage = dosageMatch.group(0);
        currentTimes = [];
        currentInstructions = '';
      }

      // Extract times from line
      final extractedTimes = _extractTimesFromLine(line);
      if (extractedTimes.isNotEmpty) {
        currentTimes.addAll(extractedTimes);
      }

      // Extract frequency and convert to times
      final freqMatch = freqPattern.firstMatch(line);
      if (freqMatch != null && currentTimes.isEmpty) {
        final freqText = freqMatch.group(0)!.toLowerCase();
        if (freqText.contains('once')) {
          currentTimes = ['08:00'];
        } else if (freqText.contains('twice')) {
          currentTimes = ['08:00', '20:00'];
        } else if (freqText.contains('thrice') || freqText.contains('3 time')) {
          currentTimes = ['08:00', '14:00', '20:00'];
        } else {
          final numMatch = RegExp(r'(\d+)').firstMatch(freqText);
          if (numMatch != null) {
            final count = int.tryParse(numMatch.group(1)!) ?? 1;
            currentTimes = _generateEvenlySpacedTimes(count);
          }
        }
      }

      // Instructions
      if (line.toLowerCase().contains('after meal') ||
          line.toLowerCase().contains('before meal') ||
          line.toLowerCase().contains('with food') ||
          line.toLowerCase().contains('with water') ||
          line.toLowerCase().contains('empty stomach')) {
        currentInstructions = line;
      }
    }

    // Don't forget last medicine
    if (currentMedicine != null && currentTimes.isNotEmpty) {
      medicines.add(ParsedMedicine(
        name: currentMedicine,
        dosage: currentDosage ?? '1 Tablet',
        times: currentTimes,
        instructions: currentInstructions,
      ));
    }

    return medicines;
  }

  static List<String> _extractTimesFromLine(String line) {
    final times = <String>[];

    // Match "8:00 AM", "20:00", "8 AM"
    final pattern = RegExp(
      r'\b(\d{1,2})(?::(\d{2}))?\s*(AM|PM|am|pm)\b|\b([01]?\d|2[0-3]):([0-5]\d)\b',
    );

    for (final match in pattern.allMatches(line)) {
      int hour;
      int minute = 0;

      if (match.group(4) != null) {
        // 24-hour format
        hour = int.parse(match.group(4)!);
        minute = int.parse(match.group(5)!);
      } else {
        hour = int.parse(match.group(1)!);
        minute = int.tryParse(match.group(2) ?? '0') ?? 0;
        final ampm = (match.group(3) ?? '').toLowerCase();
        if (ampm == 'pm' && hour != 12) hour += 12;
        if (ampm == 'am' && hour == 12) hour = 0;
      }

      times.add('${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
    }

    // Word-based times
    final wordTimes = {
      'morning': '08:00',
      'breakfast': '08:00',
      'noon': '12:00',
      'lunch': '13:00',
      'afternoon': '14:00',
      'evening': '18:00',
      'dinner': '19:00',
      'night': '21:00',
      'bedtime': '22:00',
    };

    final lower = line.toLowerCase();
    for (final entry in wordTimes.entries) {
      if (lower.contains(entry.key)) {
        times.add(entry.value);
      }
    }

    return times.toSet().toList()..sort();
  }

  static List<String> _generateEvenlySpacedTimes(int count) {
    if (count <= 0) return ['08:00'];
    final startHour = 8;
    final endHour = 22;
    final interval = (endHour - startHour) ~/ count;
    return List.generate(count, (i) {
      final hour = startHour + (i * interval);
      return '${hour.toString().padLeft(2, '0')}:00';
    });
  }

  static void dispose() {
    _recognizer.close();
  }
}

class ParsedMedicine {
  final String name;
  final String dosage;
  final List<String> times;
  final String instructions;

  ParsedMedicine({
    required this.name,
    required this.dosage,
    required this.times,
    this.instructions = '',
  });
}
