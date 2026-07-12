// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() async {
  print('=== Fetching Figma File Structure (depth=2) ===');
  
  String? token = Platform.environment['FIGMA_PERSONAL_ACCESS_TOKEN'];
  final envFile = File('.env');
  if (envFile.existsSync()) {
    for (var line in envFile.readAsLinesSync()) {
      line = line.trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      final index = line.indexOf('=');
      if (index != -1) {
        final key = line.substring(0, index).trim();
        var value = line.substring(index + 1).trim();
        if ((value.startsWith("'") && value.endsWith("'")) ||
            (value.startsWith('"') && value.endsWith('"'))) {
          value = value.substring(1, value.length - 1);
        }
        if (key == 'FIGMA_PERSONAL_ACCESS_TOKEN') {
          token = value;
          break;
        }
      }
    }
  }

  if (token == null || token.isEmpty) {
    print('Error: Figma Personal Access Token not found in environment or .env');
    exit(1);
  }

  final client = HttpClient();
  try {
    final uri = Uri.parse('https://api.figma.com/v1/files/SHRjwSUXjwrpETqwoyXc8F?depth=2');
    final request = await client.getUrl(uri);
    request.headers.add('X-Figma-Token', token);
    final response = await request.close();
    
    if (response.statusCode != 200) {
      final body = await response.transform(utf8.decoder).join();
      print('Error: HTTP ${response.statusCode}');
      print('Response: $body');
      exit(1);
    }

    final body = await response.transform(utf8.decoder).join();
    final data = jsonDecode(body) as Map<String, dynamic>;
    final document = data['document'] as Map<String, dynamic>?;
    if (document == null) {
      print('No document found in response.');
      exit(1);
    }

    final children = document['children'] as List<dynamic>?;
    if (children == null) {
      print('No pages found.');
      exit(1);
    }

    for (final page in children) {
      print('\nPage: ${page['name']} (ID: ${page['id']})');
      final pageChildren = page['children'] as List<dynamic>?;
      if (pageChildren == null) continue;
      for (final frame in pageChildren) {
        print('  - Frame: "${frame['name']}" (ID: ${frame['id']}) [Type: ${frame['type']}]');
      }
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
