import 'package:xml/src/xml/builder.dart' show XmlBuilder;

import '../schema/opf/epub_guide.dart';

class EpubGuideWriter {
  static void writeGuide(XmlBuilder builder, EpubGuide? guide) {
    builder.element('guide', nest: () {
      for (var guideItem in guide!.Items!) {
        builder.element('reference', attributes: {'type': guideItem.Type!, 'title': guideItem.Title!, 'href': guideItem.Href!});
      }
    });
  }
}
