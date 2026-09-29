import 'package:gal/gal.dart';
import 'package:semarewards/core/error/app_exception.dart';

abstract interface class FileStorageDataSource {
  Future<void> saveToGallery(String path);
}

class FileStorageDataSourceImpl implements FileStorageDataSource {
  @override
  Future<void> saveToGallery(String path) async {
    try {
      await Gal.putVideo(path);
    } on GalException catch (e) {
      throw StorageException(e.type.message);
    } catch (e) {
      throw StorageException('Could not save video: $e');
    }
  }
}
