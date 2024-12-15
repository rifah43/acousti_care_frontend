import 'dart:io';
import 'package:acousti_care_frontend/services/http_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class RecordVoice extends StatefulWidget {
  const RecordVoice({super.key});

  @override
  State<RecordVoice> createState() => _RecordVoiceState();
}

class _RecordVoiceState extends State<RecordVoice> {
  final Record _audioRecorder = Record();  // Changed from AudioRecorder to Record
  bool isRecording = false;
  String? recPath;
  final ApiProvider apiProvider = ApiProvider();

  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final Directory appDirectory = await getApplicationDocumentsDirectory();
      final now = DateTime.now();
      final timestamp =
          "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_"
          "${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";

      final String path = p.join(appDirectory.path, "recording_$timestamp.wav");

      await _audioRecorder.start(
          encoder: AudioEncoder.wav,  // Updated RecordConfig syntax
          path: path,
          samplingRate: 44100,        // Updated parameter name
          bitRate: 16,
          numChannels: 1);
      setState(() {
        isRecording = true;
        recPath = path;
      });
    }
  }

  Future<void> _stopRecording() async {
    if (isRecording) {
      String? filePath = await _audioRecorder.stop();
      setState(() {
        isRecording = false;
        recPath = filePath;
      });
    }
  }

  Future<void> _uploadAudio() async {
    if (recPath == null) return;

    File audioFile = File(recPath!);

    if (!await audioFile.exists() || audioFile.lengthSync() == 0) {
      return;
    }

    try {
      final response =
          await apiProvider.uploadAudioFile('extract-features', audioFile);

      if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Audio file is empty!"),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.orange,
          ),
        );
      } else if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Audio file uploaded!"),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to upload audio"),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
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
              onPressed: () async {
                if (isRecording) {
                  await _stopRecording();
                } else {
                  await _startRecording();
                }
              },
              child: FutureBuilder<bool>(
                future: _audioRecorder.isRecording(),
                builder: (context, snapshot) {
                  return Icon(
                      isRecording ? Icons.stop_circle : Icons.mic_sharp);
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _uploadAudio,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.upload_outlined),
                  SizedBox(width: 5),
                  Text("Submit audio"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}