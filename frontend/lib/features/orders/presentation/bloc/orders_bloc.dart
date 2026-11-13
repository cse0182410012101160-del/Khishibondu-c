import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agro_bridge/features/orders/domain/entities/order_entity.dart';
import 'package:agro_bridge/features/orders/domain/repositories/orders_repository.dart';

// Events
abstract class OrdersEvent extends Equatable {
  const OrdersEvent();
  @override
  List<Object?> get props => [];
}

class FetchOrdersEvent extends OrdersEvent {
  final String? status;
  const FetchOrdersEvent({this.status});
  @override
  List<Object?> get props => [status];
}

class UpdateOrderStatusEvent extends OrdersEvent {
  final String orderId;
  final String nextStatus;
  final String? note;
  const UpdateOrderStatusEvent(this.orderId, this.nextStatus, {this.note});
  @override
  List<Object?> get props => [orderId, nextStatus, note];
}

class ConfirmDeliveryEvent extends OrdersEvent {
  final String orderId;
  const ConfirmDeliveryEvent(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

// States
abstract class OrdersState extends Equatable {
  const OrdersState();
  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoadedState extends OrdersState {
  final List<OrderEntity> orders;
  const OrdersLoadedState(this.orders);
  @override
  List<Object?> get props => [orders];
}

class OrderUpdatedSuccessState extends OrdersState {
  final OrderEntity order;
  const OrderUpdatedSuccessState(this.order);
  @override
  List<Object?> get props => [order];
}

class OrdersErrorState extends OrdersState {
  final String message;
  const OrdersErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrdersRepository _repository;

  OrdersBloc(this._repository) : super(OrdersInitial()) {
    on<FetchOrdersEvent>(_onFetchOrders);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
    on<ConfirmDeliveryEvent>(_onConfirmDelivery);
  }

  Future<void> _onFetchOrders(FetchOrdersEvent event, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    try {
      final orders = await _repository.getOrders(status: event.status);
      emit(OrdersLoadedState(orders));
    } catch (e) {
      emit(OrdersErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateOrderStatus(UpdateOrderStatusEvent event, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    try {
      final order = await _repository.updateOrderStatus(event.orderId, event.nextStatus, note: event.note);
      emit(OrderUpdatedSuccessState(order));
      add(const FetchOrdersEvent());
    } catch (e) {
      emit(OrdersErrorState(e.toString()));
    }
  }

  Future<void> _onConfirmDelivery(ConfirmDeliveryEvent event, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    try {
      final order = await _repository.confirmDelivery(event.orderId);
      emit(OrderUpdatedSuccessState(order));
      add(const FetchOrdersEvent());
    } catch (e) {
      emit(OrdersErrorState(e.toString()));
    }
  }
}
