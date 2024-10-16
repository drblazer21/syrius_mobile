import 'package:drift/drift.dart';
import 'package:syrius_mobile/database/database.dart';
import 'package:syrius_mobile/database/tables.dart';

part 'wallet_notifications_dao.g.dart';

@DriftAccessor(tables: [WalletNotifications])
class WalletNotificationsDao extends DatabaseAccessor<Database>
    with _$WalletNotificationsDaoMixin {
  WalletNotificationsDao(super.db);

  Future<int> deleteAll() => delete(walletNotifications).go();

  Future<int> deleteById(int id) =>
      (delete(walletNotifications)..where((f) => f.id.equals(id))).go();

  Future<int> deleteOldest() async {
    final WalletNotification walletNotification =
        await (select(walletNotifications)
              ..orderBy([(t) => OrderingTerm(expression: t.createdAt)])
              ..limit(1))
            .getSingle();

    return deleteById(walletNotification.id);
  }

  Future<int> insert(WalletNotificationsCompanion notification) async {
    return into(walletNotifications).insert(notification);
  }

  Stream<List<WalletNotification>> listen() =>
      select(walletNotifications).watch();

  Future<int> markAllAsRead() async {
    return update(walletNotifications).write(
      const WalletNotificationsCompanion(
        isRead: Value(true),
      ),
    );
  }
}
