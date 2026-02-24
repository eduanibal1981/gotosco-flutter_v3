import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/contracts/booking_flow_contract.dart';
import '../../domain/models/booking_flow_child_model.dart';
import '../../domain/models/booking_flow_school_model.dart';
import '../../domain/models/booking_flow_user_location_model.dart';
import '../datasources/booking_flow_remote_datasource.dart';

part 'booking_flow_repository_impl.g.dart';

@riverpod
BookingFlowContract bookingFlowRepository(Ref ref) {
  return BookingFlowRepositoryImpl(
    BookingFlowRemoteDatasource(Supabase.instance.client),
  );
}

class BookingFlowRepositoryImpl implements BookingFlowContract {
  BookingFlowRepositoryImpl(this._remoteDatasource);

  final BookingFlowRemoteDatasource _remoteDatasource;

  @override
  Future<List<BookingFlowChildModel>> getMyChildren() async {
    try {
      return await _remoteDatasource.getMyChildren();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<BookingFlowUserLocationModel?> getCurrentUserLocation() async {
    try {
      return await _remoteDatasource.getCurrentUserLocation();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<BookingFlowSchoolModel>> getSchoolsByIds(
    List<String> schoolIds,
  ) async {
    try {
      return await _remoteDatasource.getSchoolsByIds(schoolIds);
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<BookingFlowSchoolModel>> searchSchools(
    String query, {
    String? cityId,
  }) async {
    try {
      return await _remoteDatasource.searchSchools(query, cityId: cityId);
    } catch (_) {
      return const [];
    }
  }
}
