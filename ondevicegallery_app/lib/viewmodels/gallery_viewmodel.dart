import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/image_model.dart';
import '../services/database_helper.dart';
import '../services/permission_service.dart';

class GalleryViewModel extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final PermissionService _permissionService = PermissionService();

  List<ImageModel> _images = [];
  List<ImageModel> _selectedImages = [];
  List<ImageModel> _searchResults = [];
  List<ImageModel> _filteredImages = [];
  bool _isSearching = false;
  bool _isLoading = false;
  bool _isSelectionMode = false;
  String _searchQuery = '';
  int _gridSize = 3;

  List<ImageModel> get images => _images;
  List<ImageModel> get selectedImages => _selectedImages;
  List<ImageModel> get searchResults => _searchResults;
  List<ImageModel> get filteredImages => _filteredImages;
  bool get isSearching => _isSearching;
  bool get isLoading => _isLoading;
  bool get isSelectionMode => _isSelectionMode;
  String get searchQuery => _searchQuery;
  int get gridSize => _gridSize;

  void setGridSize(int size) {
    _gridSize = size;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _filterImages();
    notifyListeners();
  }

  void _filterImages() {
    if (_searchQuery.isEmpty) {
      _filteredImages = _images;
      _searchResults = [];
      _isSearching = false;
    } else {
      _isSearching = true;
      _filteredImages = _images.where((image) {
        return image.path.toLowerCase().contains(_searchQuery);
      }).toList();
      _searchResults = _filteredImages;
    }
  }

  Future<void> initializeApp() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _dbHelper.clearAll();
    } catch (e) {
      print('Database clear error: \$e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchImages() async {
    _isLoading = true;
    notifyListeners();

    try {
      final hasPermission = await _permissionService.hasFilePermission();
      if (!hasPermission) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final directory = Directory('/storage/emulated/0/DCIM');
      if (!directory.existsSync()) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final entities = directory.listSync();
      final imagePaths = entities
          .where((entity) {
            final path = entity.path.toLowerCase();
            return path.endsWith('.jpg') ||
                path.endsWith('.jpeg') ||
                path.endsWith('.png') ||
                path.endsWith('.webp');
          })
          .map((entity) => entity.path)
          .toList()
        ..shuffle();

      if (imagePaths.isNotEmpty) {
        await _dbHelper.clearAll();
        final imageModels = imagePaths.map((path) {
          return ImageModel(
            id: path.hashCode.toString(),
            path: path,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            status: ImageStatus.pending,
          );
        }).toList();

        for (final imageModel in imageModels) {
          await _dbHelper.insertImage(imageModel);
        }
      }

      await _loadImages();
    } catch (e) {
      print('Error fetching images: \$e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadImages() async {
    final images = await _dbHelper.getAllImages();
    _images = images;
    notifyListeners();
  }

  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;
    if (!_isSelectionMode) {
      _selectedImages.clear();
    }
    notifyListeners();
  }

  void toggleImageSelection(ImageModel image) {
    final index = _selectedImages.indexOf(image);
    if (index >= 0) {
      _selectedImages.removeAt(index);
    } else {
      _selectedImages.add(image);
    }
    notifyListeners();
  }

  void deleteSelectedImages() async {
    if (_selectedImages.isEmpty) return;

    final ids = _selectedImages.map((img) => img.id).toList();
    await _dbHelper.deleteImages(ids);
    await _loadImages();
    _selectedImages.clear();
    _isSelectionMode = false;
    notifyListeners();
  }

  void shareSelectedImages(BuildContext context) async {
    if (_selectedImages.isEmpty) return;

    Share.shareXFiles(
      _selectedImages.map((img) => XFile(img.path)).toList(),
      text: 'Check out these images from OnDeviceGallery',
    );
  }

  void copySelectedText(BuildContext context) async {
    if (_selectedImages.isEmpty) return;

    final texts = _selectedImages.map((img) => img.ocrText).where((t) => t.isNotEmpty).join('\n\n');
    if (texts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No text to copy')),
      );
      return;
    }

    Clipboard.setData(ClipboardData(text: texts));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Text copied to clipboard')),
    );
  }

  void copySelectedTextToImage(BuildContext context) {
    if (_selectedImages.isEmpty) return;

    _textSelectionController.text = _selectedImages
        .map((img) => img.ocrText)
        .where((t) => t.isNotEmpty)
        .join('\n\n');
  }

  Future<void> processPendingImages() async {
    final pending = await _dbHelper.getImagesByStatus(ImageStatus.pending);

    if (pending.isEmpty) return;

    for (final image in pending) {
      try {
        final newImage = image.copyWith(status: ImageStatus.completed);
        await _dbHelper.updateImage(newImage);
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        print('Error processing image \${image.id}: \$e');
      }
    }

    await _loadImages();
  }
}
