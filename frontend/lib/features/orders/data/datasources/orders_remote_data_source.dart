import 'package:agro_bridge/core/constants/api_endpoints.dart';
import 'package:agro_bridge/core/network/api_client.dart';
import '../models/order_model.dart';

abstract class OrdersRemoteDataSource {
  Future<List<OrderModel>> getOrders({String? status});
  Future<Map<String, dynamic>> getOrderById(String id);
  Future<OrderModel> updateOrderStatus(String id, String nextStatus, {String? note});
  Future<OrderModel> confirmDelivery(String id);
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final ApiClient _client;

  OrdersRemoteDataSourceImpl(this._client);

  @override
  Future<List<OrderModel>> getOrders({String? status}) async {
    final query = <String, dynamic>{};
    if (status != null) query['status'] = status;
    final res = await _client.get(ApiEndpoints.orders, queryParameters: query);
    final list = res.data['orders'] as List;
    return list.map((o) => OrderModel.fromJson(o)).toList();
  }

  @override
  Future<Map<String, dynamic>> getOrderById(String id) async {
    final res = await _client.get(ApiEndpoints.orderDetail(id));
    return res.data;
  }

  @override
  Future<OrderModel> updateOrderStatus(String id, String nextStatus, {String? note}) async {
    final res = await _client.put(
      ApiEndpoints.updateOrderStatus(id),
      data: {'nextStatus': nextStatus, 'note': note},
    );
    return OrderModel.fromJson(res.data['order']);
  }

  @override
  Future<OrderModel> confirmDelivery(String id) async {
    final res = await _client.put(ApiEndpoints.confirmDelivery(id));
    return OrderModel.fromJson(res.data['order']);
  }
}

