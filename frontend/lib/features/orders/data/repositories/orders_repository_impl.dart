import 'package:agro_bridge/features/orders/domain/entities/order_entity.dart';
import 'package:agro_bridge/features/orders/domain/repositories/orders_repository.dart';
import 'package:agro_bridge/features/orders/data/datasources/orders_remote_data_source.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource _remoteDataSource;

  OrdersRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<OrderEntity>> getOrders({String? status}) {
    return _remoteDataSource.getOrders(status: status);
  }

  @override
  Future<Map<String, dynamic>> getOrderById(String id) {
    return _remoteDataSource.getOrderById(id);
  }

  @override
  Future<OrderEntity> updateOrderStatus(String id, String nextStatus, {String? note}) {
    return _remoteDataSource.updateOrderStatus(id, nextStatus, note: note);
  }

  @override
  Future<OrderEntity> confirmDelivery(String id) {
    return _remoteDataSource.confirmDelivery(id);
  }
}
