import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:resume_labs/core/errors/app_exception.dart';
import 'package:resume_labs/data/datasources/remote/openai_datasource_impl.dart';

class _MockHttpClient extends Mock implements http.Client {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  setUp(() {
    dotenv.testLoad(fileInput: 'OPENAI_API_KEY=test-key');
  });

  group('OpenAiDataSourceImpl', () {
    test('throws ValidationException when OPENAI_API_KEY is missing', () async {
      dotenv.testLoad(fileInput: '');
      final client = _MockHttpClient();
      final dataSource = OpenAiDataSourceImpl(client);

      expect(
        () => dataSource.generateSummary(
          jobTitle: 'Developer',
          skills: const ['Dart'],
          workHighlights: const ['Did X'],
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('generateSummary returns trimmed output_text', () async {
      final client = _MockHttpClient();
      when(
        () => client.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response('{"output_text":"  Hello  "}', 200),
      );

      final dataSource = OpenAiDataSourceImpl(client);
      final result = await dataSource.generateSummary(
        jobTitle: 'Developer',
        skills: const ['Dart'],
        workHighlights: const ['Did X'],
      );

      expect(result, 'Hello');
    });

    test('improveBullet falls back to output[].content[].text', () async {
      final client = _MockHttpClient();
      when(
        () => client.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '{"output":[{"content":[{"text":"Improved bullet"}]}]}',
          200,
        ),
      );

      final dataSource = OpenAiDataSourceImpl(client);
      final result = await dataSource.improveBullet(
        bullet: 'Built app',
        jobTitle: 'Flutter Dev',
      );

      expect(result, 'Improved bullet');
    });

    test('suggestSkills parses JSON skills list', () async {
      final client = _MockHttpClient();
      when(
        () => client.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async =>
            http.Response('{"output_text":"{\\"skills\\":[\\"Dart\\"]}"}', 200),
      );

      final dataSource = OpenAiDataSourceImpl(client);
      final result = await dataSource.suggestSkills(
        jobTitle: 'Developer',
        existingSkills: const ['Flutter'],
        personalSummary: 'Summary',
      );

      expect(result, ['Dart']);
    });

    test('suggestSkills throws parse failure when JSON invalid', () async {
      final client = _MockHttpClient();
      when(
        () => client.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response('{"output_text":"not json"}', 200),
      );

      final dataSource = OpenAiDataSourceImpl(client);

      expect(
        () => dataSource.suggestSkills(
          jobTitle: 'Developer',
          existingSkills: const [],
          personalSummary: null,
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.code,
            'code',
            'openai-parse-skills-failed',
          ),
        ),
      );
    });

    test('maps 401 to AuthException (uses body error message)', () async {
      final client = _MockHttpClient();
      when(
        () => client.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response('{"error":{"message":"Bad key"}}', 401),
      );

      final dataSource = OpenAiDataSourceImpl(client);

      expect(
        () => dataSource.generateSummary(
          jobTitle: 'Developer',
          skills: const [],
          workHighlights: const [],
        ),
        throwsA(
          isA<AuthException>()
              .having((e) => e.code, 'code', '401')
              .having((e) => e.message, 'message', 'Bad key'),
        ),
      );
    });

    test('maps 429 to NetworkException', () async {
      final client = _MockHttpClient();
      when(
        () => client.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response('{"error":{"message":"Too many"}}', 429),
      );

      final dataSource = OpenAiDataSourceImpl(client);

      expect(
        () => dataSource.improveBullet(bullet: 'x'),
        throwsA(isA<NetworkException>().having((e) => e.code, 'code', '429')),
      );
    });
  });
}
