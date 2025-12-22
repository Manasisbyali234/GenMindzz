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
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.textLight,
          unselectedLabelColor: AppColors.textLight.withOpacity(0.7),
          indicatorColor: AppColors.textLight,
          tabs: const [
            Tab(text: "Today's Visitors"),
            Tab(text: 'All Visitors'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Blue Search Section
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: _buildSearchAndFilters(selectedFilter),
          ),
          // White Visitor List Section
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildVisitorsList(visitors),
                  _buildVisitorsList(visitors),
                ],
              ),
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
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                hintText: 'Search visitors...',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                fillColor: Colors.white,
                filled: true,
              ),
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
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: () {
          ref.read(selectedFilterProvider.notifier).state = isSelected ? null : status;
        },
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
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