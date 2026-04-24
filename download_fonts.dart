import 'dart:io';

void main() async {
  final baseUrl = 'https://raw.githubusercontent.com/google/fonts/main/ofl/cairo/';
  final fonts = ['Cairo-Regular.ttf', 'Cairo-Medium.ttf', 'Cairo-SemiBold.ttf', 'Cairo-Bold.ttf'];
  
  for (final font in fonts) {
    final url = '$baseUrl$font';
    final request = await HttpClient().getUrl(Uri.parse(url));
    final response = await request.close();
    final bytes = await consolidateHttpClientResponseBytes(response);
    await File('assets/fonts/Cairo/$font').writeAsBytes(bytes);
    print('Downloaded $font');
  }
}

Future<List<int>> consolidateHttpClientResponseBytes(HttpClientResponse response) async {
  final bytes = <int>[];
  await for (final chunk in response) {
    bytes.addAll(chunk);
  }
  return bytes;
}
