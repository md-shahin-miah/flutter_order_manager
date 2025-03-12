class RouteNames {
  // Private constructor to prevent instantiation
  RouteNames._();
  
  // Root routes
  static const String home = '/';
  static const String addOrder = '/add-order';
  
  // Order routes
  static const String orderDetails = '/order/:id';
  static const String editOrder = '/edit-order/:id';
  
  // Helper methods to get actual paths
  static String getOrderDetailsPath(int id) => '/order/$id';
  static String getEditOrderPath(int id) => '/edit-order/$id';
}

