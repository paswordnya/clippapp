import 'package:semarewards/core/error/app_exception.dart';
import 'package:share_plus/share_plus.dart';

abstract interface class ShareDataSource {
  Future<void> share(String path);
}

class ShareDataSourceImpl implements ShareDataSource {
  @override
  Future<void> share(String path) async {
    try {
      final result = await SharePlus.instance.share(
        ShareParams(files: [XFile(path)]),
      );
      if (result.status == ShareResultStatus.dismissed) {
        return;
      }
    } catch (e) {
      throw ShareException('Could not share video: $e');
    }
  }
}
