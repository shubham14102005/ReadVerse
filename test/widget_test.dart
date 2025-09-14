// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:readverse/models/book.dart';

void main() {
  testWidgets('Book model test', (WidgetTester tester) async {
    // Test the Book model
    final book = Book(
      id: '1',
      title: 'Test Book',
      author: 'Test Author',
      filePath: '/test/path',
      fileName: 'test.pdf',
      fileType: 'pdf',
      totalPages: 100,
      dateAdded: DateTime.now(),
    );
    
    expect(book.title, 'Test Book');
    expect(book.author, 'Test Author');
    expect(book.totalPages, 100);
    expect(book.currentPage, 0);
    expect(book.progress, 0.0);
  });
}
