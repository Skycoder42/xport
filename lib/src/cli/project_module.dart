import 'dart:io';

import 'package:injectable/injectable.dart';

import 'dependencies.dart';

void setProjectDir(Directory directory) =>
    ProjectModule._projectDir = directory;

@module
abstract class ProjectModule {
  static late Directory _projectDir;

  @injectable
  @projectDirRef
  Directory get projectDir => _projectDir;
}
