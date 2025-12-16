import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/visitor.dart';
import '../../mock_data/mock_data.dart';

final visitorsProvider = StateProvider<List<Visitor>>((ref) {
  return MockData.visitors;
});

final selectedFilterProvider = StateProvider<VisitorStatus?>((ref) => null);

final filteredVisitorsProvider = Provider<List<Visitor>>((ref) {
  final visitors = ref.watch(visitorsProvider);
  final filter = ref.watch(selectedFilterProvider);
  
  if (filter == null) return visitors;
  return visitors.where((visitor) => visitor.status == filter).toList();
});