import 'package:xml/src/xml/builder.dart' show XmlBuilder;
import '../schema/opf/epub_package.dart';
import '../schema/opf/epub_version.dart';
import 'epub_guide_writer.dart';
import 'epub_manifest_writer.dart';
import 'epub_metadata_writer.dart';
import 'epub_spine_writer.dart';

class EpubPackageWriter {
  static const String _namespace = 'http://www.idpf.org/2007/opf';

  static String writeContent(EpubPackage package) {
    var builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');

    builder.element('package', attributes: {
      'version': package.Version == EpubVersion.Epub2 ? '2.0' : '3.0',
      'unique-identifier': 'etextno',
    }, nest: () {
      builder.namespace(_namespace);

      EpubMetadataWriter.writeMetadata(builder, package.Metadata, package.Version);
      EpubManifestWriter.writeManifest(builder, package.Manifest);
      EpubSpineWriter.writeSpine(builder, package.Spine!);
      EpubGuideWriter.writeGuide(builder, package.Guide);
    });

    return builder.buildDocument().toXmlString(pretty: false);
  }
}
