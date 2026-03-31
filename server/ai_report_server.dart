import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final env = await _loadEnv();
  final apiKey = env['OPENAI_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    stderr.writeln('OPENAI_API_KEY가 설정되지 않았습니다.');
    exitCode = 64;
    return;
  }

  final port = int.tryParse(env['AI_REPORT_PORT'] ?? '') ?? 8787;
  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  stdout.writeln('AI report server listening on :$port');

  await for (final request in server) {
    request.response.headers
      ..set('Access-Control-Allow-Origin', '*')
      ..set('Access-Control-Allow-Headers', 'Content-Type, Authorization')
      ..set('Access-Control-Allow-Methods', 'POST, OPTIONS');

    if (request.method == 'OPTIONS') {
      request.response
        ..statusCode = HttpStatus.noContent
        ..close();
      continue;
    }

    if (request.method != 'POST' || request.uri.path != '/api/ai-report') {
      _writeJson(request.response, HttpStatus.notFound, <String, dynamic>{
        'error': 'Not found',
      });
      continue;
    }

    try {
      final payload = jsonDecode(await utf8.decoder.bind(request).join());
      if (payload is! Map<String, dynamic>) {
        throw const FormatException('Invalid payload');
      }
      final prompt = (payload['prompt'] as String?)?.trim();
      if (prompt == null || prompt.isEmpty) {
        _writeJson(request.response, HttpStatus.badRequest, <String, dynamic>{
          'error': 'prompt is required',
        });
        continue;
      }

      final model = env['OPENAI_MODEL']?.trim();
      final report = await _createOpenAiResponse(
        apiKey: apiKey,
        model: model == null || model.isEmpty ? 'gpt-5.2-mini' : model,
        prompt: prompt,
      );
      _writeJson(request.response, HttpStatus.ok, <String, dynamic>{
        'content': report,
      });
    } catch (error) {
      _writeJson(
        request.response,
        HttpStatus.internalServerError,
        <String, dynamic>{'error': error.toString()},
      );
    }
  }
}

Future<Map<String, String>> _loadEnv() async {
  final result = <String, String>{...Platform.environment};
  final candidates = <String>['server/.env', '.env'];
  for (final path in candidates) {
    final file = File(path);
    if (!await file.exists()) {
      continue;
    }
    final lines = await file.readAsLines();
    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty || line.startsWith('#') || !line.contains('=')) {
        continue;
      }
      final index = line.indexOf('=');
      final key = line.substring(0, index).trim();
      final value = line.substring(index + 1).trim();
      if (key.isNotEmpty) {
        result[key] = value;
      }
    }
  }
  return result;
}

Future<String> _createOpenAiResponse({
  required String apiKey,
  required String model,
  required String prompt,
}) async {
  final client = HttpClient();
  try {
    final request = await client.postUrl(
      Uri.parse('https://api.openai.com/v1/responses'),
    );
    request.headers
      ..set(HttpHeaders.authorizationHeader, 'Bearer $apiKey')
      ..set(HttpHeaders.contentTypeHeader, 'application/json');
    request.write(
      jsonEncode(<String, dynamic>{'model': model, 'input': prompt}),
    );

    final response = await request.close();
    final body = await utf8.decoder.bind(response).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('OpenAI error ${response.statusCode}: $body');
    }

    final json = jsonDecode(body);
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid OpenAI response');
    }
    final text = _extractOpenAiText(json);
    if (text == null || text.trim().isEmpty) {
      throw const FormatException('OpenAI response contained no text');
    }
    return text.trim();
  } finally {
    client.close(force: true);
  }
}

String? _extractOpenAiText(Map<String, dynamic> json) {
  final outputText = json['output_text'];
  if (outputText is String && outputText.trim().isNotEmpty) {
    return outputText;
  }

  final output = json['output'];
  if (output is List) {
    final parts = <String>[];
    for (final item in output) {
      if (item is! Map<String, dynamic>) {
        continue;
      }
      final content = item['content'];
      if (content is! List) {
        continue;
      }
      for (final block in content) {
        if (block is! Map<String, dynamic>) {
          continue;
        }
        final text = block['text'];
        if (text is String && text.trim().isNotEmpty) {
          parts.add(text.trim());
        }
      }
    }
    if (parts.isNotEmpty) {
      return parts.join('\n\n');
    }
  }

  return null;
}

void _writeJson(
  HttpResponse response,
  int statusCode,
  Map<String, dynamic> body,
) {
  response
    ..statusCode = statusCode
    ..headers.contentType = ContentType.json
    ..write(jsonEncode(body))
    ..close();
}
