import 'package:injectable/injectable.dart';

const accessToken = Named('accessToken');
const projectDir = Named('projectDir');
const gitHubTarget = Named('gitHubTarget');

@InjectableInit(
  preferRelativeImports: true,
  throwOnMissingDependencies: true,
)
// ignore: unused_element
void _() {}
