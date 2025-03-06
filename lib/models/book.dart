import 'package:epub/models/book_data.dart';
import 'package:flutter/material.dart';

class Book {
  Book({
    required this.name,
    this.pages,
    this.savedData,
    BookIdentifier? bookIdentifier,
    List<String>? authors,
    List<String>? tags,
    List<String>? chapters,
    this.description,
    this.coverProvider,
  })  : tags = tags ?? [],
        authors = authors ?? [],
        chapters = chapters ?? [],
        bookIdentifier = bookIdentifier ?? BookIdentifier();

  String name;
  BookIdentifier bookIdentifier;
  int? pages;
  List<String> authors;
  List<String> tags;
  String? description;
  ImageProvider? coverProvider;
  BookData? savedData;
  List<String> chapters;

  String getAuthors() => authors.join(', ');
}

class BookIdentifier {
  BookIdentifier({
    this.isbn13,
    this.isbn10,
    Map<String, String?>? other,
  }) : other = other ?? {};

  String? isbn13;
  String? isbn10;
  Map<String, String?> other;

  String? getAnyIsbn() => isbn13 ?? isbn10;
}

enum BookStatus { planToRead, reading, completed }

class BookThemeData {
  BookThemeData({
    required this.backgroundColor,
    required this.textColor,
    this.lineHeightMultiplier = 1,
    this.textSizeMultiplier = 1,
    this.textAlignment,
    this.textFont,
  });

  Color textColor;
  Color backgroundColor;
  double lineHeightMultiplier;
  double textSizeMultiplier;
  TextAlign? textAlignment;
  String? textFont;
}

class BookOptions {
  BookOptions(this.bookThemeData);
  BookThemeData bookThemeData;
}

class BookPage {
  BookPage(this.content);
  String content;
}
