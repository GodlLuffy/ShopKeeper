import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')).toList();

  int replacedCount = 0;

  for (final file in files) {
    String content = file.readAsStringSync();
    String original = content;

    content = content.replaceAll('AppTheme.primaryColor', 'AppTheme.primaryPurple');
    content = content.replaceAll('AppTheme.successColor', 'AppTheme.successGreen');
    content = content.replaceAll('AppTheme.errorColor', 'AppTheme.dangerRed');
    content = content.replaceAll('AppTheme.accentColor', 'AppTheme.warningAmber');
    content = content.replaceAll('AppTheme.backgroundColor', 'AppTheme.darkBackgroundMain');
    content = content.replaceAll('AppTheme.lightTheme', 'AppTheme.darkTheme');

    if (content != original) {
      file.writeAsStringSync(content);
      replacedCount++;
      // ignore: avoid_print
      print('Updated ${file.path}');
    }
  }

  // ignore: avoid_print
  print('Total files updated: $replacedCount');
}
