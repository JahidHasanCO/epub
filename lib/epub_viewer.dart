import 'dart:io';

import 'package:epub/models/book.dart';
import 'package:epub/models/book_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class EpubViewer extends StatefulWidget {
  const EpubViewer({super.key});

  @override
  State<EpubViewer> createState() => _EpubViewerState();
}

class _EpubViewerState extends State<EpubViewer> {
  @override
  initState() {
    super.initState();
  }

  Future<Book> loadBooks() async {
    final directory = await getTemporaryDirectory();

    // Rest of the code continues
    final List<int> epubBytes =
        (await rootBundle.load('assets/sample.epub')).buffer.asInt8List();

    await BookData.writeFromEpub(
      epubBytes: epubBytes,
      description: 'Sample description',
      directory: Directory(p.join(directory.path, 'sample_book')),
    );

    return await BookData.load(Directory(p.join(directory.path, 'sample_book')))
        .then((value) => value.toBook(100));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadBooks(),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? Scaffold(
                  appBar: AppBar(title: Text(snapshot.data!.name)),
                  body: _body(snapshot.data!),
                  drawer: _drawer(snapshot.data!),
                )
              : const Center(child: CircularProgressIndicator());
        });
  }

  _body(Book book) {
    return Text(
      book.chapters.join('\n'),
      style: const TextStyle(fontSize: 20),
    );
  }

  _drawer(Book book) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
              child: Container(
            height: book.savedData?.data.coverSize.height ?? 200,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: book.coverProvider!,
                fit: BoxFit.cover,
              ),
            ),
          )),
          Expanded(
            child: ListView.builder(
              itemCount: book.chapters.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(book.chapters[index]),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
