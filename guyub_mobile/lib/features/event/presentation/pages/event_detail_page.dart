import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../domain/entities/event.dart';
import '../providers/event_provider.dart';
import '../event_state.dart';

class EventDetailPage extends ConsumerStatefulWidget {
  final int eventId;

  const EventDetailPage({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends ConsumerState<EventDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(eventDetailProvider.notifier).loadEvent(widget.eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(eventDetailProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Event'),
        actions: [
          IconButton(
            onPressed: () => ref.read(eventDetailProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: state.when(
        initial: () => const Center(child: CircularProgressIndicator()),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (event) => _buildEventDetail(event),
        error: (message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              AppSpacing.verticalMD,
              Text(message),
              AppSpacing.verticalSM,
              ElevatedButton(
                onPressed: () => ref
                    .read(eventDetailProvider.notifier)
                    .loadEvent(widget.eventId),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventDetail(Event event) {
    return RefreshIndicator(
      onRefresh: () => ref.read(eventDetailProvider.notifier).refresh(),
      child: ListView(
        padding: AppSpacing.paddingLG,
        children: [
          // Header Card
          Card(
            child: Padding(
              padding: AppSpacing.paddingLG,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(event.status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          event.status.displayName,
                          style: TextStyle(
                            color: _getStatusColor(event.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          event.type.displayName,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.verticalLG,
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (event.description.isNotEmpty) ...[
                    AppSpacing.verticalSM,
                    Text(
                      event.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          AppSpacing.verticalMD,

          // Info Cards
          _buildInfoCard(
            icon: Icons.calendar_today,
            title: 'Tanggal',
            content: _formatDateRange(event.startDate, event.endDate),
          ),
          AppSpacing.verticalSM,
          _buildInfoCard(
            icon: Icons.location_on,
            title: 'Lokasi',
            content: event.location,
            subtitle: event.locationAddress,
          ),
          AppSpacing.verticalSM,
          _buildInfoCard(
            icon: Icons.people,
            title: 'Peserta',
            content: '${event.participantIds.length} orang',
          ),
          AppSpacing.verticalLG,

          // Action Buttons
          if (event.status == EventStatus.pending) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveEvent(),
                    icon: const Icon(Icons.check),
                    label: const Text('Setujui'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                  ),
                ),
                AppSpacing.horizontalSM,
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _rejectEvent(),
                    icon: const Icon(Icons.close),
                    label: const Text('Tolak'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    String? subtitle,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight.withOpacity(0.2),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content, style: const TextStyle(fontWeight: FontWeight.w500)),
            if (subtitle != null) Text(subtitle),
          ],
        ),
        isThreeLine: subtitle != null,
      ),
    );
  }

  Color _getStatusColor(EventStatus status) {
    return switch (status.badgeColorClass) {
      'grey' => Colors.grey,
      'orange' => Colors.orange,
      'green' => Colors.green,
      'blue' => Colors.blue,
      'purple' => Colors.purple,
      'red' => Colors.red,
      _ => Colors.grey,
    };
  }

  String _formatDateRange(DateTime start, DateTime? end) {
    final startStr = _formatDate(start);
    if (end == null) return startStr;
    final endStr = _formatDate(end);
    return '$startStr - $endStr';
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month - 1];
  }

  void _approveEvent() async {
    await ref.read(eventDetailProvider.notifier).approveEvent();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Event berhasil disetujui')));
    }
  }

  void _rejectEvent() async {
    await ref.read(eventDetailProvider.notifier).rejectEvent();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Event berhasil ditolak')));
    }
  }
}
