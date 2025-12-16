import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/visitor.dart';
import 'visitors_provider.dart';
import 'widgets/visitor_card.dart';

class VisitorsScreen extends ConsumerStatefulWidget {
  const VisitorsScreen({super.key});

  @override
  ConsumerState<VisitorsScreen> createState() => _VisitorsScreenState();
}

class _VisitorsScreenState extends ConsumerState<VisitorsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final visitors = ref.watch(filteredVisitorsProvider);
    final selectedFilter = ref.watch(selectedFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitors'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Today's Visitors"),
            Tab(text: 'All Visitors'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(selectedFilter),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVisitorsList(visitors),
                _buildVisitorsList(visitors),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddWalkinDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Walk-in'),
      ),
    );
  }

  Widget _buildSearchAndFilters(VisitorStatus? selectedFilter) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search visitors...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', null, selectedFilter),
                const SizedBox(width: 8),
                _buildFilterChip('Pending', VisitorStatus.pending, selectedFilter),
                const SizedBox(width: 8),
                _buildFilterChip('Approved', VisitorStatus.approved, selectedFilter),
                const SizedBox(width: 8),
                _buildFilterChip('Checked-in', VisitorStatus.checkedIn, selectedFilter),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VisitorStatus? status, VisitorStatus? selectedFilter) {
    final isSelected = selectedFilter == status;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        ref.read(selectedFilterProvider.notifier).state = selected ? status : null;
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildVisitorsList(List<Visitor> visitors) {
    if (visitors.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text('No visitors found', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: visitors.length,
      itemBuilder: (context, index) => VisitorCard(visitor: visitors[index]),
    );
  }

  void _showAddWalkinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Walk-in Visitor'),
        content: const Text('Walk-in visitor form would be shown here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}