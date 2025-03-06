import 'dart:convert';
import 'dart:io';
import 'package:epub/models/book.dart';
import 'package:epub/models/book_config_data.dart';
import 'package:epub/utils/get_files_from_epub_spine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path/path.dart' as p;
import 'package:epub/epubz/epubz.dart';
import 'package:html/parser.dart';
import 'package:image/image.dart' as img;

class BookData {
  BookData({
    required this.directory,
    required this.data,
    required this.bookId,
    required this.dataFile,
    required this.coverFile,
    required this.epubFile,
  });

  Directory directory;
  BookConfigData data;
  String bookId;
  File dataFile;
  File coverFile;
  File epubFile;

  static Future<void> writeFromEpub({
    required Directory directory,
    required List<int> epubBytes,
    String? description,
  }) async {
    final epubBook = await EpubReader.readBook(epubBytes);

    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }

    await directory.create(recursive: true);
    final path = directory.path;
    final dataFile = File(p.join(path, 'data.json'));
    final coverFile = File(p.join(path, 'cover.png'));
    final epubFile = File(p.join(path, 'book.epub'));

    final wordsPerSpineItem = getFilesFromEpubSpine(epubBook).map((file) {
      if (file is EpubTextContentFile && file.Content != null) {
        return RegExp('[\\w-]+')
            .allMatches(parse(file.Content!).body!.text)
            .length;
      }
      return 0;
    }).toList();

    late final img.Image coverImageData;
    late final Size coverImageSize;

    if (epubBook.CoverImage == null) {
      final data = await rootBundle.load('assets/images/cover.jpg');

      coverImageData = img.decodeImage(data.buffer.asUint8List())!;
    } else {
      coverImageData = epubBook.CoverImage!;
    }

    coverImageSize = Size(
      coverImageData.width.toDouble(),
      coverImageData.height.toDouble(),
    );

    await coverFile.writeAsBytes(img.encodePng(coverImageData));

    var coverColor = const Color.fromARGB(
        255, 169, 169, 169); // Default color in case of failure
    try {
      // Use MemoryImage to pass decoded image data
      final palette = await PaletteGenerator.fromImageProvider(
        MemoryImage(img.encodePng(coverImageData)),
      );
      coverColor = palette.dominantColor?.color ?? coverColor;
    } catch (e) {
      print('Error generating dominant color: $e');
    }

    await epubFile.writeAsBytes(epubBytes);
    await dataFile.writeAsString(
      jsonEncode(
        BookConfigData(
          name: epubBook.Title ?? '',
          authors: [if (epubBook.Author != null) epubBook.Author!],
          wordsPerSpineItem: wordsPerSpineItem,
          chapters:
              epubBook.Chapters!.map((chapter) => chapter.Title!).toList(),
          description: description ?? '',
          coverSize: coverImageSize,
          coverColor: coverColor,
          progressSpine: 0,
          rating: null,
          characterMetadataName: null,
        ).toJson(),
      ),
    );
  }

  static Future<BookData> load(Directory directory) async {
    final path = directory.path;
    final dataFile = File(p.join(path, 'data.json'));
    final coverFile = File(p.join(path, 'cover.png'));
    final epubFile = File(p.join(path, 'book.epub'));

    if (!await dataFile.exists() ||
        !await epubFile.exists() ||
        !await coverFile.exists()) {
      throw Exception();
    }

    final data = BookConfigData.fromJson(
        await dataFile.readAsString().then((data) => json.decode(data)));

    return BookData(
      directory: directory,
      bookId: p.basename(path),
      data: data,
      dataFile: dataFile,
      coverFile: coverFile,
      epubFile: epubFile,
    );
  }

  Book toBook(double wordsPerPage) {
    return Book(
      name: data.name,
      authors: data.authors,
      description: data.description,
      pages: getPages(wordsPerPage),
      coverProvider: FileImage(coverFile),
      savedData: this,
      chapters: data.chapters,
    );
  }

  Future<void> saveData() async {
    await dataFile.writeAsString(
      jsonEncode(data.toJson()),
    );
  }

  int getPages(double wordsPerPage) =>
      (data.wordsPerSpineItem.reduce((value, element) => element + value) /
              wordsPerPage)
          .round();
}
