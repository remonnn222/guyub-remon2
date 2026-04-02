import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';
import '../providers/event_provider.dart';
import '../event_state.dart';

class CreateEventPage extends ConsumerStatefulWidget {
  const CreateEventPage({super.key});

  @override
  ConsumerState<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends ConsumerState<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _locationAddressController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  EventType _selectedType = EventType.family_gathering;
  int? _selectedFamilyId;
  final List<int> _participantIds = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _locationAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(eventFormProvider);

    // Listen for success/error states
    ref.listen(eventFormProvider, (previous, current) {
      if (current is EventFormSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(current.message)),
        );
        context.pop();
      } else if (current is EventFormError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(current.message), backgroundColor: AppColors.error),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Event Baru'),
        actions: [
          if (formState is EventFormLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _submitForm,
              child: const Text('SIMPAN'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.paddingLG,
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Nama Event *',
                hintText: 'Contoh: Reuni Keluarga 2024',
                prefixIcon: Icon(Icons.event),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama event harus diisi';
                }
                return null;
              },
            ),
            AppSpacing.verticalMD,

            // Type Dropdown
            DropdownButtonFormField<EventType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Jenis Event *',
                prefixIcon: Icon(Icons.category),
              ),
              items: EventType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            AppSpacing.verticalMD,

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                hintText: 'Jelaskan detail event...',
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            AppSpacing.verticalMD,

            // Start Date
            InkWell(
              onTap: () => _pickDate(isStartDate: true),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Tanggal Mulai *',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _startDate != null
                      ? _formatDate(_startDate!)
                      : 'Pilih tanggal',
                ),
              ),
            ),
            AppSpacing.verticalMD,

            // End Date
            InkWell(
              onTap: () => _pickDate(isStartDate: false),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Tanggal Selesai (Opsional)',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _endDate != null
                      ? _formatDate(_endDate!)
                      : 'Pilih tanggal (opsional)',
                ),
              ),
            ),
            AppSpacing.verticalMD,

            // Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Lokasi *',
                hintText: 'Contoh: Rumah Bude Ani',
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lokasi harus diisi';
                }
                return null;
              },
            ),
            AppSpacing.verticalMD,

            // Location Address
            TextFormField(
              controller: _locationAddressController,
              decoration: const InputDecoration(
                labelText: 'Alamat Lengkap',
                hintText: 'Jalan, RT/RW, Kelurahan, Kecamatan',
                prefixIcon: Icon(Icons.home),
              ),
              maxLines: 2,
            ),
            AppSpacing.verticalLG,

            // Submit Button
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: formState is EventFormLoading ? null : _submitForm,
                icon: formState is EventFormLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  formState is EventFormLoading ? 'Menyimpan...' : 'Simpan Event',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isStartDate}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? now)
          : (_endDate ?? _startDate ?? now),
      firstDate: isStartDate ? now : (_startDate ?? now),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Reset end date if it's before start date
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal mulai harus diisi')),
      );
      return;
    }

    final params = CreateEventParams(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _selectedType.value,
      familyId: _selectedFamilyId,
      startDate: _startDate!.toIso8601String(),
      endDate: _endDate?.toIso8601String(),
      location: _locationController.text.trim(),
      locationAddress: _locationAddressController.text.trim().isEmpty
          ? null
          : _locationAddressController.text.trim(),
      participantIds: _participantIds,
    );

    ref.read(eventFormProvider.notifier).createEvent(params);
  }
}
