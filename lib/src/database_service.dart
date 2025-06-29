import 'database/database.dart';

class DatabaseService {
  final database = AppDatabase();

  Future<void> saveUser(
    String name,
    String balanceUSD,
    String portfolio,
  ) async {
    await database
        .into(database.users)
        .insert(
          UsersCompanion.insert(
            name: name,
            balanceUSD: balanceUSD,
            portfolio: portfolio,
          ),
        );
  }

  Future<void> updateUser(User editedUser) async {
    final id = editedUser.id;
    var obj = await database.managers.users.filter((u) => u.id(id)).getSingle();
    obj = obj.copyWith(
      name: editedUser.name,
      balanceUSD: editedUser.balanceUSD,
      portfolio: editedUser.portfolio,
    );
    await database.managers.users.replace(obj);
  }

  Future<List<User>> getAllUsers() async {
    return await database.select(database.users).get();
  }

  Future<User> findUserById(int id) async {
    var managers = database.managers;
    return managers.users.filter((u) => u.id(id)).getSingle();
  }

  Future<int> countUsers() async {
    final count = await database.managers.users.count();
    return count;
  }
}
