import 'dart:ffi';

import 'package:injectable/injectable.dart';

import 'security_framework.dart';

@module
abstract class SecurityModule {
  @singleton
  SecurityFramework get securityService =>
      SecurityFramework(DynamicLibrary.process());
}
