import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:provider/provider.dart';
import '../models/image_model.dart';
import '../viewmodels/gallery_viewmodel.dart';
import '../services/database_helper.dart';
import 'dart:io';

class FullScreenImageScreen extends StatelessWidget {
  final ImageModel image;

  const FullScreenImageScreen({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Details'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_enhance),
            onPressed: () {
              _processWithGoogleLens(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.grey.shade300,
                child: image.path.isNotEmpty
                    ? Image.file(
                        File(image.path),
                        fit: BoxFit.contain,
                      )
                    : const Center(
                        child: Icon(Icons.photo, size: 100, color: Colors.grey),
                      ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  _buildDetailRow('ID', image.id),
                  _buildDetailRow('Path', image.path),
                  _buildDetailRow('Status', image.status.name),
                  if (image.ocrText.isNotEmpty) _buildDetailRow('OCR Text', image.ocrText),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processWithGoogleLens(BuildContext context) async {
    final file = File(image.path);
    if (!file.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image file not found')),
      );
      return;
    }

    try {
      final inputImage = InputImage.fromFilePath(file.path);
      final textRecognizer = TextRecognizer();
      try {
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
        final extractedText = recognizedText.text;
        
        if (extractedText.isNotEmpty) {
          final updatedImage = image.copyWith(ocrText: extractedText);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Text extracted successfully')),
          );
          
          // Save OCR text back to database
          final dbHelper = DatabaseHelper.instance;
          await dbHelper.updateImage(updatedImage);
          
          // Refresh the images in the view model
          final viewModel = Provider.of<GalleryViewModel>(context, listen: false);
          await viewModel.refreshImages();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No text found in image')),
          );
        }
      } finally {
        await textRecognizer.close();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error extracting text: \${e.toString()}')),
      );
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}