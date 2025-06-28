import 'dart:typed_data';
import 'package:http/http.dart' as http;

class TextToImageService {
  // Generate image using Pollinations.ai API (free, no API key required)
  static Future<Uint8List?> generateImage(String prompt) async {
    try {
      print('Generating image for prompt: $prompt');

      // Encode the prompt for URL
      final encodedPrompt = Uri.encodeComponent(prompt);

      // Use Pollinations.ai free text-to-image API
      final url = 'https://image.pollinations.ai/prompt/$encodedPrompt';

      print('Making request to: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'Flutter Image Generator App'},
      );

      if (response.statusCode == 200) {
        print(
          'Successfully generated image! Size: ${response.bodyBytes.length} bytes',
        );
        return response.bodyBytes;
      } else {
        print('Failed to generate image. Status: ${response.statusCode}');
        return await _fallbackToAltruism(prompt);
      }
    } catch (e) {
      print('Exception generating image: $e');
      return await _fallbackToAltruism(prompt);
    }
  }

  // Fallback to Altruism AI API if Pollinations fails
  static Future<Uint8List?> _fallbackToAltruism(String prompt) async {
    try {
      print('Trying fallback API for prompt: $prompt');

      final encodedPrompt = Uri.encodeComponent(prompt);
      final url =
          'https://api.altruism.ai/generate?prompt=$encodedPrompt&size=512x512';

      print('Making fallback request to: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'Flutter Image Generator App'},
      );

      if (response.statusCode == 200) {
        print(
          'Fallback API successful! Size: ${response.bodyBytes.length} bytes',
        );
        return response.bodyBytes;
      } else {
        print('Fallback API failed. Status: ${response.statusCode}');
        return await _fallbackToPlaceholder(prompt);
      }
    } catch (e) {
      print('Fallback API exception: $e');
      return await _fallbackToPlaceholder(prompt);
    }
  }

  // Final fallback to a generated placeholder image
  static Future<Uint8List?> _fallbackToPlaceholder(String prompt) async {
    try {
      print('Using placeholder service for prompt: $prompt');

      // Use Lorem Picsum with a generated seed based on prompt
      final seed = prompt.hashCode.abs();
      final url = 'https://picsum.photos/seed/$seed/512/512';

      print('Making placeholder request to: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print(
          'Placeholder image loaded! Size: ${response.bodyBytes.length} bytes',
        );
        return response.bodyBytes;
      } else {
        print('All image generation methods failed');
        return null;
      }
    } catch (e) {
      print('Placeholder generation failed: $e');
      return null;
    }
  }
}
