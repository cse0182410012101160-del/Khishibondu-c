import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agro_bridge/features/marketplace/domain/entities/crop_entity.dart';
import '../../domain/repositories/marketplace_repository.dart';

// Events
abstract class MarketplaceEvent extends Equatable {
  const MarketplaceEvent();
  @override
  List<Object?> get props => [];
}

class FetchCropsEvent extends MarketplaceEvent {
  final String? category;
  final String? division;
  final String? search;
  final String? farmerId;

  const FetchCropsEvent({this.category, this.division, this.search, this.farmerId});

  @override
  List<Object?> get props => [category, division, search, farmerId];
}

class CreateCropEvent extends MarketplaceEvent {
  final Map<String, dynamic> data;
  const CreateCropEvent(this.data);
  @override
  List<Object?> get props => [data];
}

class SubmitBidEvent extends MarketplaceEvent {
  final String cropId;
  final Map<String, dynamic> data;
  const SubmitBidEvent(this.cropId, this.data);
  @override
  List<Object?> get props => [cropId, data];
}

class UpdateBidStatusEvent extends MarketplaceEvent {
  final String bidId;
  final String status;
  const UpdateBidStatusEvent(this.bidId, this.status);
  @override
  List<Object?> get props => [bidId, status];
}

// States
abstract class MarketplaceState extends Equatable {
  const MarketplaceState();
  @override
  List<Object?> get props => [];
}

class MarketplaceInitial extends MarketplaceState {}

class MarketplaceLoading extends MarketplaceState {}

class CropsLoadedState extends MarketplaceState {
  final List<CropEntity> crops;
  const CropsLoadedState(this.crops);
  @override
  List<Object?> get props => [crops];
}

class CropCreatedSuccessState extends MarketplaceState {
  final CropEntity crop;
  const CropCreatedSuccessState(this.crop);
  @override
  List<Object?> get props => [crop];
}

class BidSubmittedSuccessState extends MarketplaceState {
  final BidEntity bid;
  const BidSubmittedSuccessState(this.bid);
  @override
  List<Object?> get props => [bid];
}

class BidStatusUpdatedSuccessState extends MarketplaceState {
  final Map<String, dynamic> result;
  const BidStatusUpdatedSuccessState(this.result);
  @override
  List<Object?> get props => [result];
}

class MarketplaceErrorState extends MarketplaceState {
  final String message;
  const MarketplaceErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class MarketplaceBloc extends Bloc<MarketplaceEvent, MarketplaceState> {
  final MarketplaceRepository _repository;

  MarketplaceBloc(this._repository) : super(MarketplaceInitial()) {
    on<FetchCropsEvent>(_onFetchCrops);
    on<CreateCropEvent>(_onCreateCrop);
    on<SubmitBidEvent>(_onSubmitBid);
    on<UpdateBidStatusEvent>(_onUpdateBidStatus);
  }

  Future<void> _onFetchCrops(FetchCropsEvent event, Emitter<MarketplaceState> emit) async {
    emit(MarketplaceLoading());
    try {
      final crops = await _repository.getCrops(
        category: event.category,
        division: event.division,
        search: event.search,
        farmerId: event.farmerId,
      );
      emit(CropsLoadedState(crops));
    } catch (e) {
      emit(MarketplaceErrorState(e.toString()));
    }
  }

  Future<void> _onCreateCrop(CreateCropEvent event, Emitter<MarketplaceState> emit) async {
    emit(MarketplaceLoading());
    try {
      final crop = await _repository.createCrop(event.data);
      emit(CropCreatedSuccessState(crop));
      add(const FetchCropsEvent()); // Refresh listings
    } catch (e) {
      emit(MarketplaceErrorState(e.toString()));
    }
  }

  Future<void> _onSubmitBid(SubmitBidEvent event, Emitter<MarketplaceState> emit) async {
    emit(MarketplaceLoading());
    try {
      final bid = await _repository.submitBid(event.cropId, event.data);
      emit(BidSubmittedSuccessState(bid));
      add(const FetchCropsEvent());
    } catch (e) {
      emit(MarketplaceErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateBidStatus(UpdateBidStatusEvent event, Emitter<MarketplaceState> emit) async {
    emit(MarketplaceLoading());
    try {
      final res = await _repository.updateBidStatus(event.bidId, event.status);
      emit(BidStatusUpdatedSuccessState(res));
      add(const FetchCropsEvent());
    } catch (e) {
      emit(MarketplaceErrorState(e.toString()));
    }
  }
}

