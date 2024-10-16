import 'dart:io' as io;

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';

import 'models/encrypted_secret.dart';
import 'models/public_key.dart';

part 'github_client.g.dart';

@RestApi(baseUrl: 'https://api.github.com/')
abstract class GitHubClient {
  static const _defaultHeaders = {
    io.HttpHeaders.acceptHeader: 'application/vnd.github+json',
    'X-GitHub-Api-Version': '2022-11-28',
  };

  Dio get _dio;

  factory GitHubClient({
    required String accessToken,
    BaseOptions? options,
  }) =>
      _GitHubClient(
        Dio(
          (options ?? BaseOptions())
            ..headers.addAll(_defaultHeaders)
            ..headers[io.HttpHeaders.authorizationHeader] =
                'Bearer $accessToken',
        ),
      );

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

extension GithubClientX on GitHubClient {
  void close({bool force = false}) => _dio.close(force: force);
}
