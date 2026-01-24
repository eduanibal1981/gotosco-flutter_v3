import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/transport_requests_repository.dart';

part 'transport_request_controller.g.dart';

@riverpod
class TransportRequestController extends _$TransportRequestController {
  @override
  FutureOr<void> build() {}

  Future<bool> submitRequest({
    required String childName,
    // required int childAge, // Removed
    required String schoolName,
    required String bookingType,
    required String homeLocation,
    required double homeLat,
    required double homeLng,
    required String schoolLocation,
    required double schoolLat,
    required double schoolLng,
    String? childId,
    String? childGender,
    String? childGrade,
    String? notes,
    double? proposalPrice,
    String? scheduleType,
    String? startDate,
    String? endDate,
    String? pickupTime,
    String? daysOfWeek,
  }) async {
    if (childName.trim().isEmpty) {
      throw Exception('Please enter the child name');
    }
    // Age check removed
    if (schoolName.trim().isEmpty) {
      throw Exception('Please enter the school name');
    }
    if (homeLocation.trim().isEmpty) {
      throw Exception('Please set the home location');
    }
    if (schoolLocation.trim().isEmpty) {
      throw Exception('Please set the school location');
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref
          .read(transportRequestsRepositoryProvider)
          .createTransportRequest(
            childName: childName,
            schoolName: schoolName,
            bookingType: bookingType,
            homeLocation: homeLocation,
            homeLat: homeLat,
            homeLng: homeLng,
            schoolLocation: schoolLocation,
            schoolLat: schoolLat,
            schoolLng: schoolLng,
            childId: childId,
            childGender: childGender,
            childGrade: childGrade,
            notes: notes,
            proposalPrice: proposalPrice,
            scheduleType: scheduleType,
            startDate: startDate,
            endDate: endDate,
            pickupTime: pickupTime,
            daysOfWeek: daysOfWeek,
          );
    });

    return !state.hasError;
  }
}
