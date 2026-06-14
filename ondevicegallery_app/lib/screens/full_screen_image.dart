import 'package:flutter/material.dart';
import 'dart:io';
import '../models/image_model.dart';

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