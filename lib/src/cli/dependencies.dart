import 'package:injectable/injectable.dart';

const gitHubAccessToken = Named('gitHubAccessToken');

@InjectableInit(
  preferRelativeImports: true,
  throwOnMissingDependencies: true,
)
// ignore: unused_element
void _() {}
