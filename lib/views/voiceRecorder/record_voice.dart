import 'dart:convert';
import 'dart:io';
import 'package:acousti_care_frontend/models/user.dart';
import 'package:acousti_care_frontend/providers/user_provider.dart';
import 'package:acousti_care_frontend/services/http_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

class RecordVoice extends StatefulWidget {
  const RecordVoice({super.key});

  @override
  State<RecordVoice> createState() => _RecordVoiceState();
}

class _RecordVoiceState extends State<RecordVoice> {
  final Record _audioRecorder = Record();
  bool isRecording = false;
  String? recPath;
  final ApiProvider apiProvider = ApiProvider();
  late final UserProvider userProvider;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final Directory appDirectory = await getApplicationDocumentsDirectory();
        final now = DateTime.now();
        final timestamp =
            "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_"
            "${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";

        final String path =
            p.join(appDirectory.path, "recording_$timestamp.wav");

        // Configure recording parameters to match backend expectations
        await _audioRecorder.start(
            encoder: AudioEncoder.wav,
            path: path,
            samplingRate: 44100, // Must match Praat's expectations
            bitRate: 16, // Standard WAV bit depth
            numChannels: 1 // Mono recording for voice analysis
            );

        setState(() {
          isRecording = true;
          recPath = path;
        });
      } else {
        _showSnackBar("Microphone permission denied", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Failed to start recording: $e", Colors.red);
    }
  }

  Future<void> _stopRecording() async {
    try {
      if (isRecording) {
        String? filePath = await _audioRecorder.stop();
        setState(() {
          isRecording = false;
          recPath = filePath;
        });
      }
    } catch (e) {
      _showSnackBar("Failed to stop recording: $e", Colors.red);
    }
  }

  Future<void> _uploadAudio() async {
    if (recPath == null) {
      _showSnackBar("No recording available", Colors.orange);
      return;
    }

    File audioFile = File(recPath!);
    if (!await audioFile.exists() || audioFile.lengthSync() == 0) {
      _showSnackBar("Audio file is empty or missing", Colors.orange);
      return;
    }

    setState(() => isUploading = true);

    try {
      // Validate user data before upload
      if (userProvider.currentUser == null) {
        throw Exception('User profile not found');
      }

      if (!_validateUserData(userProvider.currentUser!)) {
        throw Exception(
            'Incomplete user profile. Please update your profile information.');
      }

      final response =
          await apiProvider.uploadAudioFile('predict', audioFile, userProvider);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar(
            "Prediction: ${(responseData['risk_probability'] * 100).toStringAsFixed(2)}% risk",
            Colors.green);
      } else {
        throw Exception(responseData['error'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      _showSnackBar(e.toString(), Colors.red);
    } finally {
      setState(() => isUploading = false);
    }
  }

  bool _validateUserData(User user) {
    return user.id!.isNotEmpty &&
        user.gender.isNotEmpty &&
        user.age > 0 &&
        user.age <= 120 &&
        user.bmi > 0 &&
        user.bmi <= 100;
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Voice'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: isUploading
                  ? null
                  : (isRecording ? _stopRecording : _startRecording),
              child: Icon(isRecording ? Icons.stop_circle : Icons.mic_sharp),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isUploading || isRecording ? null : _uploadAudio,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isUploading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    const Icon(Icons.upload_outlined),
                  const SizedBox(width: 5),
                  Text(isUploading ? "Uploading..." : "Submit audio"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }
}
