enum ImageStatus { pending, completed, failed }

class ImageModel {
  final String id;
  final String path;
  final int createdAt;
  final ImageStatus status;
  final String ocrText;
  final int? processingTime;
  final String? errorMessage;

  ImageModel({
    required this.id,
    required this.path,
    required this.createdAt,
    required this.status,
    this.ocrText = '',
    this.processingTime,
    this.errorMessage,
  });

  factory ImageModel.fromMap(Map<String, dynamic> map) {
    return ImageModel(
      id: map['id'] as String,
      path: map['path'] as String,
      createdAt: map['createdAt'] as int,
      status: ImageStatus.values[map['status'] as int],
      ocrText: map['ocrText'] as String? ?? '',
      processingTime: map['processingTime'] as int?,
      errorMessage: map['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
      'createdAt': createdAt,
      'status': status.index,
      'ocrText': ocrText,
      'processingTime': processingTime,
      'errorMessage': errorMessage,
    };
  }

  ImageModel copyWith({
    ImageStatus? status,
    String? ocrText,
    int? processingTime,
    String? errorMessage,
  }) {
    return ImageModel(
      id: id,
      path: path,
      createdAt: createdAt,
      status: status ?? this.status,
      ocrText: ocrText ?? this.ocrText,
      processingTime: processingTime ?? this.processingTime,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
