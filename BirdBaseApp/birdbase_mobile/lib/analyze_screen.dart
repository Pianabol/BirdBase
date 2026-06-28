import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'api_service.dart';
import 'tflite_service.dart';
import 'theme/brand_colors.dart';

class AnalyzeScreen extends StatefulWidget {
  final Function(String)? onAskScientist;

  const AnalyzeScreen({super.key, this.onAskScientist});

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  File? _selectedImage;
  bool isLoading = false;
  bool isOfflineMode = true;

  String? prediction;
  String? resultMessage;
  Map<String, dynamic>? birdInfo;

  Map<String, dynamic> offlineBirdDatabase = {};

  @override
  void initState() {
    super.initState();
    TFLiteService.initialize();
    _loadOfflineDatabase();
  }

  Future<void> _loadOfflineDatabase() async {
    try {
      String jsonString =
          await rootBundle.loadString('assets/data/BirdInfo.json');

      setState(() {
        offlineBirdDatabase = jsonDecode(jsonString);
      });

      print("🚀 Offline Database Loaded Successfully!");
    } catch (e) {
      print("❌ Failed to load offline database: $e");
    }
  }

  void _showOfflineBirdInfo(String birdName) {
    String safeKey = birdName.split('(')[0].trim().toLowerCase();

    var info = offlineBirdDatabase[safeKey];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.82,
            ),
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
              bottom: 30,
            ),
            decoration: const BoxDecoration(
              color: BrandColors.bgCream,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  if (info != null) ...[
                    Text(
                      info["name"] ?? birdName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: BrandColors.forestGreen,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.park,
                          color: BrandColors.sageGreen,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Habitat: ${info["habitat"] ?? "-"}",
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: const TextStyle(
                              color: BrandColors.textDark,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: BrandColors.sageGreen,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Lifespan: ${info["lifespan"] ?? "-"}",
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: const TextStyle(
                              color: BrandColors.textDark,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: BrandColors.sageGreen),
                    ),

                    const Text(
                      "About",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: BrandColors.forestGreen,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      info["description"] ?? "",
                      softWrap: true,
                      style: const TextStyle(
                        color: BrandColors.textDark,
                        height: 1.5,
                        fontSize: 15,
                      ),
                    ),
                  ] else ...[
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          "This bird is not yet in our offline guide.\n\nPlease switch to Cloud Mode for detailed info.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: BrandColors.textDark,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BrandColors.forestGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "Close",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        prediction = null;
        resultMessage = null;
        birdInfo = null;
      });
    }
  }

  void resetState() {
    setState(() {
      _selectedImage = null;
      prediction = null;
      resultMessage = null;
      birdInfo = null;
      isLoading = false;
    });
  }

  Future<void> analyzeImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a photo."),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (isOfflineMode) {
        List<Map<String, dynamic>> results =
            await TFLiteService.analyzeImage(_selectedImage!);

        if (!mounted) return;

        setState(() {
          if (results.isNotEmpty) {
            prediction = results.first["tag"];
            resultMessage =
                "This is the bird species you are looking for:\n\n• $prediction";
          } else {
            prediction = null;
            resultMessage = "No birds were detected in the image.";
          }

          birdInfo = null;
        });
      } else {
        final response = await ApiService.uploadImage(_selectedImage!);

        if (!mounted) return;

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          setState(() {
            prediction =
                (data["detections"] != null && data["detections"].isNotEmpty)
                    ? data["detections"][0]["class"]
                    : null;

            resultMessage =
                data["message"] ?? "No birds were detected in the image.";

            birdInfo = data["bird_info"];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("API Error: ${response.statusCode}"),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Connection/Analysis Error: $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.bgCream,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: BrandColors.bgCream,
              padding: const EdgeInsets.only(top: 10, bottom: 15),
              child: Column(
                children: [
                  const Text(
                    "AI Analysis",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: BrandColors.forestGreen,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Cloud (API)",
                          style: TextStyle(
                            color: isOfflineMode
                                ? Colors.grey
                                : BrandColors.forestGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Switch(
                          value: isOfflineMode,
                          activeColor: BrandColors.forestGreen,
                          inactiveThumbColor: BrandColors.sageGreen,
                          inactiveTrackColor:
                              BrandColors.sageGreen.withValues(alpha: 0.3),
                          onChanged: (value) {
                            setState(() {
                              isOfflineMode = value;
                            });
                          },
                        ),

                        Text(
                          "Offline",
                          style: TextStyle(
                            color: isOfflineMode
                                ? BrandColors.forestGreen
                                : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: BrandColors.sageGreen.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: _selectedImage == null
                          ? const Center(
                              child: Text(
                                "No photo selected",
                                style: TextStyle(
                                  color: BrandColors.forestGreen,
                                ),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),

                    const SizedBox(height: 24),

                    if (resultMessage != null) ...[
                      Text(
                        resultMessage!,
                        textAlign: prediction == null
                            ? TextAlign.center
                            : TextAlign.left,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: prediction == null
                              ? Colors.red
                              : BrandColors.textDark,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      if (birdInfo != null && !isOfflineMode) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                birdInfo!['name'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: BrandColors.forestGreen,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                "Habitat: ${birdInfo!['habitat'] ?? '-'}",
                                softWrap: true,
                              ),

                              Text(
                                "Lifespan: ${birdInfo!['lifespan'] ?? '-'}",
                                softWrap: true,
                              ),

                              const SizedBox(height: 8),

                              Text(
                                birdInfo!['description'] ?? '',
                                softWrap: true,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ],

                    if (resultMessage == null) ...[
                      ElevatedButton(
                        onPressed: pickImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BrandColors.sageGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Add Photo",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      ElevatedButton(
                        onPressed: isLoading ? null : analyzeImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isLoading ? Colors.grey : BrandColors.forestGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Analyze",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ] else ...[
                      if (prediction != null) ...[
                        ElevatedButton(
                          onPressed: () {
                            if (isOfflineMode) {
                              _showOfflineBirdInfo(prediction!);
                            } else {
                              String safePromptName =
                                  prediction!.split('(')[0].trim();

                              String prompt =
                                  "Could you give me detailed information about $safePromptName?";

                              if (widget.onAskScientist != null) {
                                widget.onAskScientist!(prompt);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BrandColors.forestGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            isOfflineMode
                                ? "View Saved Info"
                                : "Ask Avian Expert",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],

                      ElevatedButton(
                        onPressed: resetState,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BrandColors.sageGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Analyze New Photo",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}