// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() async {
  print('=== Searching for node 2087:601 and Onboarding sections ===');
  
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
    print('Error: Figma Token not found');
    exit(1);
  }

  final client = HttpClient();
  try {
    // We fetch N-Onboarding (1080:28710) and Onboarding (527:260) sections
    final uri = Uri.parse('https://api.figma.com/v1/files/SHRjwSUXjwrpETqwoyXc8F/nodes?ids=1080:28710,527:260');
    final request = await client.getUrl(uri);
    request.headers.add('X-Figma-Token', token);
    final response = await request.close();
    
    if (response.statusCode != 200) {
      print('Error status: ${response.statusCode}');
      exit(1);
    }

    final body = await response.transform(utf8.decoder).join();
    final data = jsonDecode(body) as Map<String, dynamic>;
    final nodes = data['nodes'] as Map<String, dynamic>?;
    if (nodes == null) {
      print('No nodes found.');
      exit(1);
    }

    for (final entry in nodes.entries) {
      print('\nSection: ${entry.key}');
      final document = entry.value['document'] as Map<String, dynamic>?;
      if (document == null) continue;
      _printChildren(document, 1, '2087:601');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}

void _printChildren(Map<String, dynamic> node, int depth, String targetId) {
  final children = node['children'] as List<dynamic>?;
  if (children == null) return;

  final indent = '  ' * depth;
  for (final child in children) {
    final String id = child['id'] ?? '';
    final String name = child['name'] ?? '';
    final String type = child['type'] ?? '';

    // Check if this child or any of its descendants contain the targetId
    final bool containsTarget = _containsNode(child, targetId);
    final highlight = containsTarget ? ' [CONTAINS $targetId!]' : '';

    print('$indent- Node: "$name" (ID: $id) [Type: $type]$highlight');
    
    if (depth < 4) {
      _printChildren(child, depth + 1, targetId);
    }
  }
}

bool _containsNode(Map<String, dynamic> node, String targetId) {
  if (node['id'] == targetId) return true;
  final children = node['children'] as List<dynamic>?;
  if (children == null) return false;
  for (final child in children) {
    if (_containsNode(child, targetId)) return true;
  }
  return false;
}
