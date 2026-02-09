enum UserRole {
  systemManager('System Manager'),
  inventoryManager('Inventory Manager'),
  stockManager('Stock Manager'),
  posUser('POS User'),
  storeManager('Store Manager'),
  stockUser('Stock User'),
  salesManager('Sales Manager'),
  accountsManager('Accounts Manager'),
  purchaseManager('Purchase Manager'),
  accountUser('Account User'),
  branchAdmin('Branch Admin'),
  auditor('Auditor'),
  marketingManager('Marketing Manager'),
  posManager('POS Manager'),
  stockController('Stock Controller'),
  qualityManager('Quality Manager'),
  salesUser('Sales User'),
  salesPerson('Sales Person');

  final String name;
  const UserRole(this.name);

  static UserRole? fromString(String role) {
    try {
      return UserRole.values.firstWhere(
        (e) => e.name.toLowerCase() == role.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
  static bool hasRole(List<String> userRoles, UserRole requiredRole) {
    return userRoles.any(
      (r) => r.toLowerCase() == requiredRole.name.toLowerCase(),
    );
  }
}
