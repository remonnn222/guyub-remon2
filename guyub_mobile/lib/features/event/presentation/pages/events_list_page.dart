import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/event.dart';
import '../../domain/usecases/create_event_usecase.dart';
import '../providers/event_provider.dart';
import '../event_state.dart';


class EventsListPage extends ConsumerStatefulWidget {
  const EventsListPage({super.key});

  @override
  ConsumerState<EventsListPage> createState() => _EventsListPageState();
}

class _EventsListPageState extends ConsumerState<EventsListPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Semua', 'Mendatang', 'Berlangsung', 'Selesai'];
  String _currentFilter = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        final newFilter = _getFilterFromTab(_tabController.index);
        if (_currentFilter != newFilter) {
          _currentFilter = newFilter;
          ref.read(eventListProvider.notifier).loadEvents(filter: newFilter);
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(eventListProvider.notifier).loadEvents();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getFilterFromTab(int index) {
    return switch (index) {
      0 => '',
      1 => 'scheduled',
      2 => 'ongoing',
      3 => 'finished',
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final eventState = ref.watch(eventListProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Keluarga'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateEventDialog(currentUser),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(eventListProvider.notifier).refresh(),
        child: eventState.when(
          initial: () => const Center(child: CircularProgressIndicator()),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (events) => _buildEventsList(events),
          error: (message) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.event_busy, size: 64, color: Colors.grey),
                AppSpacing.verticalMD,
                Text(message),
                AppSpacing.verticalSM,
                ElevatedButton(
                  onPressed: () =>
                      ref.read(eventListProvider.notifier).loadEvents(),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventsList(List<Event> events) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_available, size: 64, color: Colors.grey),
            AppSpacing.verticalMD,
            const Text('Belum ada event'),
            AppSpacing.verticalSM,
            ElevatedButton.icon(
              onPressed: () =>
                  _showCreateEventDialog(ref.read(currentUserProvider)),
              icon: const Icon(Icons.add),
              label: const Text('Buat Event Pertama'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: AppSpacing.paddingLG,
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: AppSpacing.paddingMD,
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.event, color: AppColors.primary),
            ),
            title: Text(event.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.typeDisplay),
                Text(
                  '${_formatDate(event.startDate)}${event.endDate != null ? ' - ${_formatDate(event.endDate!)}' : ''}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(event.location),
              ],
            ),
            trailing: _buildStatusBadge(event.status),
            onTap: () => context.go('/events/${event.id}'),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(EventStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors[status.badgeColorClass]?.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: AppColors[status.badgeColorClass],
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year) {
      return '${date.day} ${_getMonthName(date.month)}';
    }
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month - 1];
  }

  void _showCreateEventDialog(User? currentUser) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buat Event Baru'),
        content: const Text('Fitur create event akan segera hadir'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Nanti'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/events/create');
            },
            child: const Text('Buat Sekarang'),
          ),
        ],
      ),
    );
  }
}
