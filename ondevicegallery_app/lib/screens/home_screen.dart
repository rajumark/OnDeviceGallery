import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/gallery_viewmodel.dart';
import '../models/image_model.dart';
import '../screens/full_screen_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedGridSize = 3;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    Provider.of<GalleryViewModel>(context, listen: false)
        .setSearchQuery(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<GalleryViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.search, size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search images...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<int>(
            onSelected: (value) {
              setState(() {
                _selectedGridSize = value;
              });
              viewModel.setGridSize(_selectedGridSize);
            },
            itemBuilder: (context) => [
              const PopupMenuItem<int>(
                value: 3,
                child: Row(
                  children: [
                    Icon(Icons.grid_view, size: 20, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text('3x3'),
                  ],
                ),
              ),
              const PopupMenuItem<int>(
                value: 4,
                child: Row(
                  children: [
                    Icon(Icons.grid_view, size: 20, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text('4x4'),
                  ],
                ),
              ),
              const PopupMenuItem<int>(
                value: 5,
                child: Row(
                  children: [
                    Icon(Icons.grid_view, size: 20, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text('5x5'),
                  ],
                ),
              ),
              const PopupMenuItem<int>(
                value: 6,
                child: Row(
                  children: [
                    Icon(Icons.grid_view, size: 20, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text('6x6'),
                  ],
                ),
              ),
            ],
          ),
        ],
        backgroundColor: Colors.blue.shade700,
      ),
      body: _buildBody(context, viewModel),
    );
  }

  Widget _buildBody(BuildContext context, GalleryViewModel viewModel) {
    return Column(
      children: [
        _buildStatusBar(context, viewModel),
        Expanded(
          child: viewModel.isSearching
              ? _buildSearchResults(context, viewModel)
              : _buildGalleryGrid(context, viewModel),
        ),
      ],
    );
  }

  Widget _buildStatusBar(BuildContext context, GalleryViewModel viewModel) {
    if (viewModel.images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Row(
        children: [
          const Icon(Icons.photo_library, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${viewModel.images.length} images loaded',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryGrid(BuildContext context, GalleryViewModel viewModel) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _selectedGridSize,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: viewModel.images.length,
      itemBuilder: (context, index) {
        final image = viewModel.images[index];
        final isSelected = viewModel.selectedImages.contains(image);
        return _buildImageCard(context, image, viewModel, isSelected);
      },
    );
  }

  Widget _buildSearchResults(BuildContext context, GalleryViewModel viewModel) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _selectedGridSize,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: viewModel.searchResults.length,
      itemBuilder: (context, index) {
        final image = viewModel.searchResults[index];
        final isSelected = viewModel.selectedImages.contains(image);
        return _buildImageCard(context, image, viewModel, isSelected);
      },
    );
  }

  Widget _buildImageCard(BuildContext context, ImageModel image, 
      GalleryViewModel viewModel, bool isSelected) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenImageScreen(
              image: image,
            ),
          ),
        );
      },
      onLongPress: () {
        viewModel.toggleImageSelection(image);
        setState(() {});
      },
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: Colors.grey.shade300,
              child: const Center(
                child: Icon(Icons.photo, size: 40, color: Colors.grey),
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
            if (image.status == ImageStatus.pending)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            if (image.status == ImageStatus.completed && image.ocrText.isEmpty)
              const Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Icon(Icons.text_fields, color: Colors.white, size: 24),
              ),
            if (image.status == ImageStatus.completed && image.ocrText.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    image.ocrText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
