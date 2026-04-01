import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/visitor.dart';
import '../../mock_data/mock_data.dart';

final visitorsProvider = StateProvider<List<Visitor>>((ref) {
  return MockData.visitors;
});

final selectedFilterProvider = StateProvider<VisitorStatus?>((ref) => null);
final visitorSearchProvider = StateProvider<String>((ref) => '');

final filteredVisitorsProvider = Provider<List<Visitor>>((ref) {
  final visitors = ref.watch(visitorsProvider);
  final filter = ref.watch(selectedFilterProvider);
  final search = ref.watch(visitorSearchProvider).toLowerCase();
  
  var result = visitors;
  
  if (filter != null) {
    result = result.where((visitor) => visitor.status == filter).toList();
  }
  
  if (search.isNotEmpty) {
    result = result.where((visitor) => 
      visitor.name.toLowerCase().contains(search) || 
      visitor.email.toLowerCase().contains(search) ||
      visitor.phone.contains(search)
    ).toList();
  }
  
  return result;
});