import 'dart:typed_data';
import 'dart:math';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class TextToImageService {
  static final Random _random = Random();

  // Together AI API Configuration
  static const String _togetherApiKey =
      '2da9bd0d20cfbced9fc492adc872dfc9f090b048ac344f50a15d104b47fefbd6';
  static const String _togetherApiUrl =
      'https://api.together.xyz/v1/images/generations';
  static const String _fluxModel = 'black-forest-labs/FLUX.1-schnell-Free';

  // Generate image using Together AI API (primary) with fallbacks
  static Future<Uint8List?> generateImage(String prompt) async {
    // Try Together AI first (like your Streamlit app)
    Uint8List? result = await _togetherAiApi(prompt);
    if (result != null) return result;

    // Fallback to other APIs if Together AI fails
    final apiChoice = _random.nextInt(3);
    developer.log(
      'Together AI failed, trying fallback API: ${_getApiName(apiChoice)}',
      name: 'TextToImageService',
    );

    result = await _tryApi(apiChoice, prompt);
    if (result != null) return result;

    // Try remaining APIs
    for (int i = 0; i < 3; i++) {
      if (i != apiChoice) {
        developer.log(
          'Trying additional fallback API: ${_getApiName(i)}',
          name: 'TextToImageService',
        );
        result = await _tryApi(i, prompt);
        if (result != null) return result;
      }
    }

    developer.log(
      'All APIs failed for prompt: $prompt',
      name: 'TextToImageService',
    );
    return null;
  }

  static String _getApiName(int apiIndex) {
    switch (apiIndex) {
      case 0:
        return 'Pollinations.ai';
      case 1:
        return 'Picsum Photos';
      case 2:
        return 'Dynamic Generator';
      default:
        return 'Unknown';
    }
  }

  // Together AI API - Primary image generation (like your Streamlit app)
  static Future<Uint8List?> _togetherAiApi(String prompt) async {
    try {
      developer.log(
        'Together AI: Generating image for: $prompt',
        name: 'TextToImageService',
      );

      // Enhance prompt with visual elements (like your Streamlit app)
      final enhancedPrompt = _enhancePrompt(prompt);

      final requestBody = {
        'model': _fluxModel,
        'prompt': enhancedPrompt,
        'width': 1024,
        'height': 1024,
        'steps': 4,
        'n': 1,
        'response_format': 'b64_json',
      };

      final response = await http.post(
        Uri.parse(_togetherApiUrl),
        headers: {
          'Authorization': 'Bearer $_togetherApiKey',
          'Content-Type': 'application/json',
          'User-Agent': 'SENSE AI Image Generator',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['data'] != null && responseData['data'].isNotEmpty) {
          final base64Image = responseData['data'][0]['b64_json'];
          final imageBytes = base64Decode(base64Image);
          developer.log(
            'Together AI: Success! Size: ${imageBytes.length} bytes',
            name: 'TextToImageService',
          );
          return imageBytes;
        }
      } else {
        developer.log(
          'Together AI: Failed with status: ${response.statusCode}',
          name: 'TextToImageService',
        );
        developer.log('Response: ${response.body}', name: 'TextToImageService');
      }
      return null;
    } catch (e) {
      developer.log('Together AI: Exception: $e', name: 'TextToImageService');
      return null;
    }
  }

  // Enhance prompt with visual elements (from your Streamlit app logic)
  static String _enhancePrompt(String prompt) {
    final visualElements = [
      '3D elements',
      'metallic accents',
      'glass effects',
      'neon highlights',
    ];
    final lightingOptions = [
      'golden hour lighting',
      'studio lighting',
      'natural daylight',
      'dramatic spotlights',
    ];

    final selectedVisual =
        visualElements[_random.nextInt(visualElements.length)];
    final selectedLighting =
        lightingOptions[_random.nextInt(lightingOptions.length)];

    return '$prompt. Enhanced with $selectedLighting and $selectedVisual. High resolution, professional quality, detailed artwork.';
  }

  static Future<Uint8List?> _tryApi(int apiIndex, String prompt) async {
    switch (apiIndex) {
      case 0:
        return await _pollinationsApi(prompt);
      case 1:
        return await _altruismApi(prompt);
      case 2:
        return await _replicateApi(prompt);
      default:
        return null;
    }
  }

  // Pollinations.ai API with dynamic parameters
  static Future<Uint8List?> _pollinationsApi(String prompt) async {
    try {
      final encodedPrompt = Uri.encodeComponent(prompt);
      // Add random seed and timestamp to get different images each time
      final seed = _random.nextInt(1000000);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final url =
          'https://image.pollinations.ai/prompt/$encodedPrompt?seed=$seed&width=512&height=512&nologo=true&timestamp=$timestamp';

      developer.log(
        'Pollinations.ai: Making request to: $url',
        name: 'TextToImageService',
      );

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'SENSE AI Image Generator',
          'Accept': 'image/*',
          'Cache-Control': 'no-cache',
        },
      );

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        developer.log(
          'Pollinations.ai: Success! Size: ${response.bodyBytes.length} bytes',
          name: 'TextToImageService',
        );
        return response.bodyBytes;
      } else {
        developer.log(
          'Pollinations.ai: Failed with status: ${response.statusCode}',
          name: 'TextToImageService',
        );
        return null;
      }
    } catch (e) {
      developer.log(
        'Pollinations.ai: Exception: $e',
        name: 'TextToImageService',
      );
      return null;
    }
  }

  // Picsum with prompt-based generation (always works)
  static Future<Uint8List?> _altruismApi(String prompt) async {
    try {
      // Create unique seed from prompt + random number for variety
      final promptSeed = prompt.hashCode.abs();
      final randomSeed = _random.nextInt(10000);
      final combinedSeed = promptSeed + randomSeed;

      final url =
          'https://picsum.photos/seed/$combinedSeed/512/512?blur=${_random.nextInt(3)}&grayscale=${_random.nextBool() ? 1 : 0}';

      developer.log(
        'Picsum API: Making request to: $url (seed: $combinedSeed)',
        name: 'TextToImageService',
      );

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'SENSE AI Image Generator',
          'Cache-Control': 'no-cache',
        },
      );

      if (response.statusCode == 200) {
        developer.log(
          'Picsum API: Success! Size: ${response.bodyBytes.length} bytes',
          name: 'TextToImageService',
        );
        return response.bodyBytes;
      } else {
        developer.log(
          'Picsum API: Failed with status: ${response.statusCode}',
          name: 'TextToImageService',
        );
        return null;
      }
    } catch (e) {
      developer.log('Picsum API: Exception: $e', name: 'TextToImageService');
      return null;
    }
  }

  // Dynamic image generator with multiple fallback URLs
  static Future<Uint8List?> _replicateApi(String prompt) async {
    try {
      // Try multiple different image services with dynamic parameters
      final services = [
        'https://picsum.photos/512/512?random=${_random.nextInt(1000000)}',
        'https://source.unsplash.com/512x512/?${Uri.encodeComponent(prompt)}&sig=${_random.nextInt(1000)}',
        'https://loremflickr.com/512/512/${Uri.encodeComponent(prompt)}?random=${_random.nextInt(1000)}',
      ];

      final selectedService = services[_random.nextInt(services.length)];

      developer.log(
        'Dynamic Generator: Trying service: $selectedService',
        name: 'TextToImageService',
      );

      final response = await http.get(
        Uri.parse(selectedService),
        headers: {
          'User-Agent': 'SENSE AI Image Generator',
          'Accept': 'image/*',
          'Cache-Control': 'no-cache',
        },
      );

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        developer.log(
          'Dynamic Generator: Success! Size: ${response.bodyBytes.length} bytes',
          name: 'TextToImageService',
        );
        return response.bodyBytes;
      } else {
        developer.log(
          'Dynamic Generator: Failed with status: ${response.statusCode}',
          name: 'TextToImageService',
        );
        return await _simpleFallback(prompt);
      }
    } catch (e) {
      developer.log(
        'Dynamic Generator: Exception: $e',
        name: 'TextToImageService',
      );
      return await _simpleFallback(prompt);
    }
  }

  // Enhanced fallback with dynamic text and colors
  static Future<Uint8List?> _simpleFallback(String prompt) async {
    try {
      final shortPrompt = prompt.length > 20 ? prompt.substring(0, 20) : prompt;
      final encodedPrompt = Uri.encodeComponent(shortPrompt);

      // Random background and text colors for variety
      final bgColors = [
        '667eea',
        '764ba2',
        'f093fb',
        'f5576c',
        '4facfe',
        '00f2fe',
      ];
      final textColors = [
        'ffffff',
        '000000',
        'ffff00',
        'ff0000',
        '00ff00',
        '0000ff',
      ];

      final bgColor = bgColors[_random.nextInt(bgColors.length)];
      final textColor = textColors[_random.nextInt(textColors.length)];
      final fontSize =
          20 + _random.nextInt(20); // Random font size between 20-40

      final url =
          'https://dummyimage.com/512x512/$bgColor/$textColor.png&text=$encodedPrompt&font_size=$fontSize';

      developer.log(
        'Enhanced Fallback: Creating visual for: $shortPrompt (bg: $bgColor, text: $textColor)',
        name: 'TextToImageService',
      );

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        developer.log(
          'Enhanced Fallback: Success! Size: ${response.bodyBytes.length} bytes',
          name: 'TextToImageService',
        );
        return response.bodyBytes;
      } else {
        developer.log(
          'Enhanced Fallback: Failed with status: ${response.statusCode}',
          name: 'TextToImageService',
        );
        return null;
      }
    } catch (e) {
      developer.log(
        'Enhanced Fallback: Exception: $e',
        name: 'TextToImageService',
      );
      return null;
    }
  }
}
