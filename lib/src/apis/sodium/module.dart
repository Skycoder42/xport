import 'package:injectable/injectable.dart';
import 'package:sodium/sodium.dart';

@module
abstract class SodiumModule {
  @singleton
  @preResolve
  Future<Sodium> get sodium async => await SodiumInit.init();
}
