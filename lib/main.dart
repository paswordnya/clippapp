// Author: Rakka Purnama

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:semarewards/app/app.dart';
import 'package:semarewards/features/video_clipping/data/datasources/file_storage_datasource.dart';
import 'package:semarewards/features/video_clipping/data/datasources/share_datasource.dart';
import 'package:semarewards/features/video_clipping/data/datasources/video_picker_datasource.dart';
import 'package:semarewards/features/video_clipping/data/datasources/video_processor_datasource.dart';
import 'package:semarewards/features/video_clipping/data/repositories/video_repository_impl.dart';
import 'package:semarewards/features/video_clipping/domain/repositories/video_repository.dart';
import 'package:semarewards/features/video_clipping/domain/usecases/cancel_processing.dart';
import 'package:semarewards/features/video_clipping/domain/usecases/pick_video.dart';
import 'package:semarewards/features/video_clipping/domain/usecases/process_video.dart';
import 'package:semarewards/features/video_clipping/domain/usecases/save_video.dart';
import 'package:semarewards/features/video_clipping/domain/usecases/share_video.dart';
import 'package:semarewards/features/video_clipping/presentation/viewmodels/video_clipping_viewmodel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final VideoRepository repository = VideoRepositoryImpl(
    picker: VideoPickerDataSourceImpl(),
    processor: VideoProcessorDataSourceImpl(),
    storage: FileStorageDataSourceImpl(),
    share: ShareDataSourceImpl(),
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => VideoClippingViewModel(
        pickVideo: PickVideoUseCase(repository),
        processVideo: ProcessVideoUseCase(repository),
        saveVideo: SaveVideoUseCase(repository),
        shareVideo: ShareVideoUseCase(repository),
        cancelProcessing: CancelProcessingUseCase(repository),
      ),
      child: const ClippApp(),
    ),
  );
}
