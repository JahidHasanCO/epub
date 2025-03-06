import 'package:epub/epubz/epubz.dart';
import 'package:epub/epubz/src/schema/opf/epub_manifest_item.dart';

List<EpubContentFile> getFilesFromEpubSpine(EpubBook epubBook) {
  return getSpineItemsFromEpub(epubBook)
      .map((chapter) {
        if (epubBook.Content?.AllFiles?.containsKey(chapter.Href!) != true) {
          return null;
        }

        return epubBook.Content!.AllFiles![chapter.Href]!;
      })
      .whereType<EpubTextContentFile>()
      .toList();
}

List<EpubManifestItem> getSpineItemsFromEpub(EpubBook epubBook) {
  return epubBook.Schema!.Package!.Spine!.Items!
      .map((item) => epubBook.Schema!.Package!.Manifest!.Items!
          .where((element) => element.Id == item.IdRef)
          .first)
      .toList();
}
