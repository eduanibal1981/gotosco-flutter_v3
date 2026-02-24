import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/repositories/booking_flow_repository_impl.dart';
import '../domain/contracts/booking_flow_contract.dart';

part 'booking_flow_contract_provider.g.dart';

@riverpod
BookingFlowContract bookingFlowContract(Ref ref) {
  return ref.watch(bookingFlowRepositoryProvider);
}
