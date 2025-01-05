import 'dart:convert';
import 'dart:io';
import 'package:acousti_care_frontend/models/user.dart';
import 'package:acousti_care_frontend/providers/user_provider.dart';
import 'package:acousti_care_frontend/services/http_provider.dart';
import 'package:acousti_care_frontend/views/styles.dart';
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

class _RecordVoiceState extends State<RecordVoice>
    with SingleTickerProviderStateMixin {
  final Record _audioRecorder = Record();
  bool isRecording = false;
  String? recPath;
  final ApiProvider apiProvider = ApiProvider();
  late final UserProvider userProvider;
  bool isUploading = false;
  double? predictionResult;
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
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

        await _audioRecorder.start(
            encoder: AudioEncoder.wav,
            path: path,
            samplingRate: 44100,
            bitRate: 16,
            numChannels: 1);

        setState(() {
          isRecording = true;
          recPath = path;
          predictionResult = null;
        });
      } else {
        _showSnackBar("Microphone permission denied", AppColors.error);
      }
    } catch (e) {
      _showSnackBar("Failed to start recording", AppColors.error);
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
      _showSnackBar("Failed to stop recording", AppColors.error);
    }
  }

  Future<void> _uploadAudio() async {
    if (recPath == null) {
      _showSnackBar("Please record your voice first", AppColors.alert);
      return;
    }

    File audioFile = File(recPath!);
    if (!await audioFile.exists() || audioFile.lengthSync() == 0) {
      _showSnackBar("Recording is empty, please try again", AppColors.alert);
      return;
    }

    setState(() {
      isUploading = true;
      predictionResult = null;
    });

    try {
      print(userProvider.currentUser); // Debug print
      if (userProvider.currentUser == null) {
        throw Exception('Please log in to continue');
      }

      if (!_validateUserData(userProvider.currentUser!)) {
        throw Exception('''Please ensure your profile information is complete:
    • Age must be between 1-120 years
    • Gender must be specified
    • BMI must be between 15-40''');
      }

      final response =
          await apiProvider.uploadAudioFile('predict', audioFile, userProvider);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          predictionResult = responseData['risk_probability'] * 100;
        });
      } else {
        throw Exception(responseData['error'] ?? 'Failed to process recording');
      }
    } catch (e) {
      _showSnackBar(e.toString(), AppColors.error);
    } finally {
      setState(() => isUploading = false);
    }
  }

  bool _validateUserData(User user) {
    // Check for required fields and valid ranges
    if (user.gender.isEmpty) {
      print("DEBUG: Validation failed - missing gender");
      return false;
    }

    if (user.age <= 0 || user.age > 120) {
      print("DEBUG: Validation failed - invalid age range");
      return false;
    }

    if (user.bmi < 15 || user.bmi > 40) {
      print("DEBUG: Validation failed - BMI out of range");
      return false;
    }

    print("DEBUG: Validation successful");
    return true;
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: normalTextStyle(context, AppColors.buttonText),
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: Text(
          'Voice Analysis',
          style: nameTitleStyle(context, AppColors.textPrimary),
        ),
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (predictionResult != null) ...[
              _buildPredictionDisplay(),
              const SizedBox(height: 40),
            ],
            Stack(
              alignment: Alignment.center,
              children: [
                if (isRecording) ...[
                  ..._buildRippleEffects(),
                ],
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isRecording
                                ? AppColors.error
                                : AppColors.buttonPrimary)
                            .withOpacity(0.3),
                        spreadRadius: 4,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: isUploading
                        ? null
                        : (isRecording ? _stopRecording : _startRecording),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRecording
                          ? AppColors.error
                          : AppColors.buttonPrimary,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(24),
                      elevation: 8,
                    ),
                    child: Icon(
                      isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                      size: 32,
                      color: AppColors.buttonText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            if (!isRecording && recPath != null) ...[
              ElevatedButton(
                onPressed: isUploading ? null : _uploadAudio,
                style: primaryButtonStyle(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isUploading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.buttonText),
                          ),
                        )
                      else
                        const Icon(Icons.upload_rounded),
                      const SizedBox(width: 8),
                      Text(
                        isUploading ? "Analyzing..." : "Analyze Recording",
                        style: boldTextStyle(context, AppColors.buttonText),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (!isRecording) ...[
              Text(
                'Tap the microphone to start recording',
                style: subtitleStyle(context, AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRippleEffects() {
    return List.generate(3, (index) {
      return AnimatedBuilder(
        animation: _rippleController,
        builder: (context, child) {
          return Container(
            width: 140 + (index * 40),
            height: 140 + (index * 40),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.error.withOpacity(
                  (1 - _rippleController.value - (index * 0.2)).clamp(0.0, 1.0),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildPredictionDisplay() {
    final riskLevel = predictionResult! > 70
        ? 'High'
        : predictionResult! > 30
            ? 'Medium'
            : 'Low';

    final riskColor = predictionResult! > 70
        ? AppColors.error
        : predictionResult! > 30
            ? AppColors.alert
            : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: riskColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: riskColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Risk Level: $riskLevel',
            style: nameTitleStyle(context, riskColor),
          ),
          const SizedBox(height: 8),
          Text(
            '${predictionResult!.toStringAsFixed(1)}%',
            style: titleStyle(context, riskColor),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }
}
