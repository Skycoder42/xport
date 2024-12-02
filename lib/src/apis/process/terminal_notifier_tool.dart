import 'dart:io';

import 'package:injectable/injectable.dart';

import 'process_runner.dart';

@injectable
class TerminalNotifierTool {
  final ProcessRunner _processRunner;

  TerminalNotifierTool(this._processRunner);

  Future<void> notify({
    String? title,
    String? subTitle,
    required String message,
    Uri? contentImage,
    FileSystemEntity? onOpen,
  }) =>
      _processRunner.run(
        'terminal-notifier',
        [
          if (title != null) ...['-title', title],
          if (subTitle != null) ...['-subtitle', subTitle],
          '-message',
          message,
          if (contentImage != null) ...[
            '-contentImage',
            contentImage.toString(),
          ],
          '-sound',
          'default',
          if (onOpen != null) ...['-open', onOpen.uri.toString()],
        ],
      );
}
