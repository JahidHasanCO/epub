import 'dart:io';

import 'package:epub/epubz/epubz.dart' as epubz;
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
  int currentChapter = 0;

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

  readBook(File book) async {
    return await epubz.EpubReader.readBook(await book.readAsBytes());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadBooks(),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? Scaffold(
                  appBar: AppBar(title: Text(snapshot.data!.name)),
                  body: _body(snapshot.data!.savedData!.epubFile),
                  drawer: _drawer(snapshot.data!),
                )
              : const Center(child: CircularProgressIndicator());
        });
  }

  _body(File book) {
    return FutureBuilder(
        future: readBook(book),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data is epubz.EpubBook) {
            final eBook = snapshot.data as epubz.EpubBook;
            final currentPage = eBook.Chapters?.elementAt(currentChapter).HtmlContent;
            return SingleChildScrollView(
              child: Column(
                children: [

                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentChapter++;
                      });
                    },
                    child: const Text('Next Chapter'),
                  )
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        });
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
