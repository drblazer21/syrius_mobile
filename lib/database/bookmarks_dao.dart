import 'package:drift/drift.dart';
import 'package:syrius_mobile/database/database.dart';
import 'package:syrius_mobile/database/tables.dart';

part 'bookmarks_dao.g.dart';

@DriftAccessor(tables: [Bookmarks])
class BookmarksDao extends DatabaseAccessor<Database> with _$BookmarksDaoMixin {
  BookmarksDao(super.db);

  Future<int> insert(BookmarksCompanion bookmark) async {
    return into(bookmarks).insert(bookmark);
  }

  Future<void> insertMultiple(List<BookmarksCompanion> rows) async {
    return batch(
      (batch) {
        batch.insertAll(bookmarks, rows);
      },
    );
  }

  Future<int> deleteById(int id) async {
    return (delete(bookmarks)..where((f) => f.id.equals(id))).go();
  }
}
