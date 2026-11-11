import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CarPhotoStorageService {
  final Future<Directory> Function()? baseDirectoryProvider;

  CarPhotoStorageService({
    this.baseDirectoryProvider,
  });

  Future<String> get _photoDirectoryPath async {
    final baseDir = baseDirectoryProvider != null
        ? await baseDirectoryProvider!()
        : await getApplicationDocumentsDirectory();

    final photosDir = Directory(p.join(baseDir.path, 'car_photos'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    return photosDir.path;
  }

  /// Copies a temporary photo file to permanent app storage.
  /// Generates a unique filename using carId and microsecond timestamp.
  Future<String> savePhoto({
    required String sourcePath,
    required int carId,
  }) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw FileSystemException('Source file not found', sourcePath);
    }

    final dirPath = await _photoDirectoryPath;
    final extension = p.extension(sourcePath).isNotEmpty
        ? p.extension(sourcePath)
        : '.jpg';
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final uniqueSuffix = DateTime.now().hashCode.abs();
    final fileName = 'car_${carId}_${timestamp}_$uniqueSuffix$extension';
    final destinationPath = p.join(dirPath, fileName);

    final copiedFile = await sourceFile.copy(destinationPath);
    return copiedFile.path;
  }

  /// Saves multiple photos permanently.
  /// If any copy operation fails, cleans up all files copied in this batch.
  Future<List<String>> savePhotos({
    required List<String> sourcePaths,
    required int carId,
  }) async {
    final savedPaths = <String>[];
    try {
      for (final src in sourcePaths) {
        final saved = await savePhoto(sourcePath: src, carId: carId);
        savedPaths.add(saved);
      }
      return savedPaths;
    } catch (e) {
      // Clean up newly copied files to avoid orphaned files
      await deleteMultipleFiles(savedPaths);
      rethrow;
    }
  }

  /// Deletes a single physical photo file if it exists.
  Future<bool> deletePhotoFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (_) {
      // Ignored: file might already be removed or inaccessible
    }
    return false;
  }

  /// Deletes multiple physical files from storage.
  Future<void> deleteMultipleFiles(List<String> filePaths) async {
    for (final path in filePaths) {
      await deletePhotoFile(path);
    }
  }
}
