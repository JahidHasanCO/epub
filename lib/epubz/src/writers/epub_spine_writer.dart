import 'package:xml/src/xml/builder.dart' show XmlBuilder;

import '../schema/opf/epub_spine.dart';

class EpubSpineWriter {
  static void writeSpine(XmlBuilder builder, EpubSpine spine) {
    builder.element('spine', attributes: {'toc': spine.TableOfContents!}, nest: () {
      spine.Items!
          .forEach((spineitem) => builder.element('itemref', attributes: {'idref': spineitem.IdRef!, 'linear': spineitem.IsLinear! ? 'no' : 'yes'}));
    });
  }
}
