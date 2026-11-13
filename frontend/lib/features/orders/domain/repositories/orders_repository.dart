import 'package:agro_bridge/features/orders/domain/entities/order_entity.dart';

abstract class OrdersRepository {
  Future<List<OrderEntity>> getOrders({String? status});
  Future<Map<String, dynamic>> getOrderById(String id);
  Future<OrderEntity> updateOrderStatus(String id, String nextStatus, {String? note});
  Future<OrderEntity> confirmDelivery(String id);
}

