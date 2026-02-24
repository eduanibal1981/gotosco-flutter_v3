import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'booking_flow_contract_provider.dart';
import '../domain/models/booking_flow_child_model.dart';

part 'booking_flow_data_providers.g.dart';

@riverpod
Future<List<BookingFlowChildModel>> bookingFlowChildren(Ref ref) {
  return ref.watch(bookingFlowContractProvider).getMyChildren();
}
