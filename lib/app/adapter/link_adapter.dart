
import 'package:hive/hive.dart';

class Link extends HiveObject {
  @HiveField(0)
  String url;

  @HiveField(1)
  String title;

  Link({required this.url, required this.title});
}

class LinkAdapter extends TypeAdapter<Link> {
  @override
  final int typeId = 0;

  @override
  Link read(BinaryReader reader) {
    return Link(
      url: reader.readString(),
      title: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Link obj) {
    writer.writeString(obj.url);
    writer.writeString(obj.title);
  }
}