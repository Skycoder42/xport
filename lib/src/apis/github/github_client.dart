import 'dart:io' as io;

import 'package:dio/dio.dart' hide Headers;
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../cli/dependencies.dart';
import '../../logging/logging_parser_error_logger.dart';
import 'models/encrypted_secret.dart';
import 'models/public_key.dart';

part 'github_client.g.dart';

@singleton
class GithubClient extends __GitHubClientBase {
  static const _defaultHeaders = {
    io.HttpHeaders.acceptHeader: 'application/vnd.github+json',
    'X-GitHub-Api-Version': '2022-11-28',
  };

  factory GithubClient({
    @accessToken required String accessToken,
  }) =>
      GithubClient.withOptions(
        BaseOptions(),
        accessToken: accessToken,
        errorLogger: LoggingParserErrorLogger('GithubClient'),
      );

  GithubClient.withOptions(
    BaseOptions options, {
    required String accessToken,
    ParseErrorLogger? errorLogger,
  }) : super(
          Dio(
            options
              ..headers.addAll(_defaultHeaders)
              ..headers[io.HttpHeaders.authorizationHeader] =
                  'Bearer $accessToken',
          ),
          errorLogger: errorLogger,
        );

  @disposeMethod
  void close({bool force = false}) => _dio.close();
}

@RestApi(baseUrl: 'https://api.github.com/')
abstract class _GitHubClientBase {
  @GET('/orgs/{org}/actions/secrets/public-key')
  Future<PublicKey> getOrganisationPublicKey(
    @Path() String org,
  );

  @PUT('/orgs/{org}/actions/secrets/{secretName}')
  Future<void> putOrganisationSecret(
    @Path() String org,
    @Path() String secretName,
    @Body() EncryptedSecret secret,
  );

  @GET('/repos/{owner}/{repo}/actions/secrets/public-key')
  Future<PublicKey> getRepositoryPublicKey(
    @Path() String owner,
    @Path() String repo,
  );

  @PUT('/repos/{owner}/{repo}/actions/secrets/{secretName}')
  Future<void> putRepositorySecret(
    @Path() String owner,
    @Path() String repo,
    @Path() String secretName,
    @Body() EncryptedSecret secret,
  );

  @GET(
    '/repos/{owner}/{repo}/environments/{environmentName}/secrets/public-key',
  )
  Future<PublicKey> getEnvironmentPublicKey(
    @Path() String owner,
    @Path() String repo,
    @Path() String environmentName,
  );

  @PUT(
    '/repos/{owner}/{repo}/environments/{environmentName}/secrets/{secretName}',
  )
  Future<void> putEnvironmentSecret(
    @Path() String owner,
    @Path() String repo,
    @Path() String environmentName,
    @Path() String secretName,
    @Body() EncryptedSecret secret,
  );
}
