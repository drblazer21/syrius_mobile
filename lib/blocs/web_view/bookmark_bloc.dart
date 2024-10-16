import 'package:drift/drift.dart';
import 'package:syrius_mobile/blocs/base_bloc.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/ui/notification_utils.dart';
import 'package:web3_provider/web3_provider.dart';

sealed class BookmarkState {}

class InitialBookmarkState extends BookmarkState {}

class CanBookmarkState extends BookmarkState {
  final String url;

  CanBookmarkState(this.url);
}

class FoundBookmarkState extends BookmarkState {
  final Bookmark bookmark;

  FoundBookmarkState(this.bookmark);
}

class BookmarkBloc extends BaseBloc<BookmarkState> {
  Future<void> _find({required String url}) async {
    try {
      final Bookmark? bookmark = await db.managers.bookmarks
          .filter((f) => f.url(url))
          .getSingleOrNull();
      if (bookmark != null) {
        addEvent(FoundBookmarkState(bookmark));
      } else {
        addEvent(CanBookmarkState(url));
      }
    } catch (e) {
      sendNotificationError(
        'Something went wrong while trying to find a bookmark',
        e,
      );
    }
  }

  void update({required String url}) {
    if (url.isNotEmpty && Uri.tryParse(url) != null) {
      addEvent(CanBookmarkState(url));
      _find(url: url);
    }
  }

  Future<void> save({
    required InAppWebViewController controller,
    required String url,
  }) async {
    try {
      Future.wait([
        controller.getTitle(),
        controller.getFavicons(),
      ]).then(
        (value) async {
          Favicon? finalFavicon;
          for (final favicon in value[1]! as List<Favicon>) {
            if (favicon.url.toString().contains('.png')) {
              finalFavicon = favicon;
              if (favicon.rel?.contains('icon') ?? false) {
                finalFavicon = favicon;
              }
            }
          }

          final BookmarksCompanion bookmark = BookmarksCompanion.insert(
            faviconUrl: Value(finalFavicon?.url.toString()),
            title: value.first as String? ?? 'No title available',
            url: url,
          );

          await db.bookmarksDao.insert(bookmark);

          _find(url: url);
        },
      );
    } catch (e) {
      sendNotificationError('Error saving bookmark', e);
    }
  }

  Future<void> delete({
    required Bookmark bookmark,
  }) async {
    final int deletedRows = await db.bookmarksDao.deleteById(bookmark.id);

    final bool didDelete = deletedRows == 1;

    if (didDelete) {
      _find(url: bookmark.url);
    } else {
      sendNotificationError(
        'Delete failed',
        'Deletion of ${bookmark.title} bookmark failed',
      );
    }
  }
}
