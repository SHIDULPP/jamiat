// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';


const String defaultFileKey = 'SHRjwSUXjwrpETqwoyXc8F';
const String defaultNodeId = '239:370';

void main(List<String> args) async {
  print('=== Figma Sync Utility ===');

  // 1. Resolve arguments or use defaults
  final fileKey = args.isNotEmpty ? args[0] : defaultFileKey;
  final nodeId = args.length > 1 ? args[1] : defaultNodeId;
  final sanitizedNodeId = nodeId.replaceAll('-', ':');

  print('Target File Key: $fileKey');
  print('Target Node ID: $sanitizedNodeId');

  // 2. Load Figma Personal Access Token
  String? token = Platform.environment['FIGMA_PERSONAL_ACCESS_TOKEN'];
  
  final envFile = File('.env');
  if (envFile.existsSync()) {
    print('Reading token from .env file...');
    try {
      final lines = envFile.readAsLinesSync();
      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty || line.startsWith('#')) continue;
        final index = line.indexOf('=');
        if (index != -1) {
          final key = line.substring(0, index).trim();
          var value = line.substring(index + 1).trim();
          // Strip surrounding quotes if present
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
    } catch (e) {
      print('Warning: Failed to read .env file: $e');
    }
  }

  if (token == null || token.isEmpty) {
    print('\nError: Figma Personal Access Token not found!');
    print('Please perform one of the following:');
    print('1. Create a `.env` file at the root of the project with:');
    print('   FIGMA_PERSONAL_ACCESS_TOKEN=your_token_here');
    print('2. Set the environment variable: export FIGMA_PERSONAL_ACCESS_TOKEN=your_token_here\n');
    exit(1);
  }

  // 3. Ensure destination directory exists
  final outputDir = Directory('tool/figma');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  final client = HttpClient();

  try {
    // 4. Fetch JSON metadata of the node
    print('Fetching node JSON structure from Figma REST API...');
    final nodeUri = Uri.parse(
        'https://api.figma.com/v1/files/$fileKey/nodes?ids=$sanitizedNodeId');
    final nodeRequest = await client.getUrl(nodeUri);
    nodeRequest.headers.add('X-Figma-Token', token);
    
    final nodeResponse = await nodeRequest.close();
    if (nodeResponse.statusCode != 200) {
      final body = await nodeResponse.transform(utf8.decoder).join();
      print('Error fetching node structure: HTTP ${nodeResponse.statusCode}');
      print('Response: $body');
      client.close();
      exit(1);
    }

    final nodeBody = await nodeResponse.transform(utf8.decoder).join();
    final jsonFile = File('tool/figma/node_${sanitizedNodeId.replaceAll(':', '_')}.json');
    jsonFile.writeAsStringSync(nodeBody);
    print('Successfully saved JSON node data to: ${jsonFile.path}');

    // 5. Fetch rendered PNG layout of the node
    print('Requesting rendered image URL from Figma REST API...');
    final imageUri = Uri.parse(
        'https://api.figma.com/v1/images/$fileKey?ids=$sanitizedNodeId&format=png&scale=2');
    final imageRequest = await client.getUrl(imageUri);
    imageRequest.headers.add('X-Figma-Token', token);

    final imageResponse = await imageRequest.close();
    if (imageResponse.statusCode != 200) {
      final body = await imageResponse.transform(utf8.decoder).join();
      print('Warning: Error requesting image url: HTTP ${imageResponse.statusCode}');
      print('Response: $body');
    } else {
      final imageBody = await imageResponse.transform(utf8.decoder).join();
      final imageJson = jsonDecode(imageBody) as Map<String, dynamic>;
      final imageUrlMap = imageJson['images'] as Map<String, dynamic>?;
      final imageUrl = imageUrlMap?[sanitizedNodeId] as String?;

      if (imageUrl == null || imageUrl.isEmpty) {
        print('Warning: No image URL returned for node $sanitizedNodeId.');
      } else {
        print('Downloading image from: $imageUrl');
        final downloadUri = Uri.parse(imageUrl);
        final downloadRequest = await client.getUrl(downloadUri);
        final downloadResponse = await downloadRequest.close();

        if (downloadResponse.statusCode != 200) {
          print('Warning: Failed to download image: HTTP ${downloadResponse.statusCode}');
        } else {
          final pngFile = File('tool/figma/node_${sanitizedNodeId.replaceAll(':', '_')}.png');
          final bytesBuilder = BytesBuilder();
          await for (var chunk in downloadResponse) {
            bytesBuilder.add(chunk);
          }
          pngFile.writeAsBytesSync(bytesBuilder.takeBytes());
          print('Successfully saved PNG image to: ${pngFile.path}');
        }
      }
    }
  } catch (e) {
    print('An error occurred during Figma sync: $e');
  } finally {
    client.close();
  }

  print('=== Sync Completed ===');
}
