class Recording {
  static const tableName = 'recordings';
  static const columnName = 'name';
  static const columnTag = 'tag';
  static const columnPath = 'path';

  late String name;

  late String tag;

  late String path;

  Recording({required this.name, required this.tag, required this.path});
  // Recording.fromMap(Map<String, dynamic> map) {
  //   name:
  //   map[columnName];
  //   tag:
  //   map[columnTag];
  //   filePath:
  //   map[filePath];
  // }
  Recording.fromMap(Map<String, dynamic> map) {
    name = map[columnName];
    tag = map[columnTag];
    path = map[columnPath];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnName: name,
      columnTag: tag,
      columnPath: path,
    };
    return map;
  }
}
