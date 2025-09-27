class Constants {

  static const String SERVER_DOMAIN ="http://192.168.1.98:8000";

  static const String BASE_URL = SERVER_DOMAIN + "/api";

  static const String CATEGORY_ROUTE ="/categories";

  static const String BRAND_ROUTE ="/brands";

  static const String Product_ROUTE ="/products";

  static const String PRODUCT_FILTER_BY_CATEGORY_ROUTE = "/products?category_id=";

  static const String PRODUCT_FILTER_BY_BRAND_ROUTE = "/products?brand_id=";

  static const String LOGIN_ROUTE = "/login";

  static const String LOGOUT_ROUTE = "/logout";

  static const String USER_ROUTE = "/user";

  static const String REGISTER_ROUTE = "/register";

  static const String CART_ROUTE = "/carts";

  static const String ADD_TO_CART_ROUTE = "/add-to-cart";

  static const String REMOVE_FROM_CART_ROUTE = "/remove-from-cart";

  static const String CLEAR_CART_ROUTE = "/clear-cart";

  static const String INCREASE_CART_QTY_ROUTE = "/increase-quantity";

  static const String DECREASE_CART_QTY_ROUTE = "/decrease-quantity";

  static const String ORDER_CONFIRM = "/order/confirm";

  static const String ORDER_ROUTE = "/orders";

  static const String ORDER_DELETE_ROUTE = "/orders";

  static const String PRINT_RECEIPT_ROUTE = "/bluetooth/receipt/";

  static const String HOME_SLIDER_ROUTE = "/home-slider";
}