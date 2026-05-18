import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/model/call_item_model.dart';
import 'package:frontend/repositry/call_repositry.dart';

final recentCallsProvider = FutureProvider<List<CallItemModel>>((ref) async {
  return ref.read(callRepositryProvider).getRecentCalls();
});
