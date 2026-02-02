import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../domain/entities/family.dart';

/// Family Tree List View
/// Hierarchical expandable list for phone/portrait mode
class FamilyTreeList extends StatefulWidget {
  final FamilyTreeData treeData;
  final Person? selectedPerson;
  final void Function(Person person)? onPersonSelected;

  const FamilyTreeList({
    super.key,
    required this.treeData,
    this.selectedPerson,
    this.onPersonSelected,
  });

  @override
  State<FamilyTreeList> createState() => _FamilyTreeListState();
}

class _FamilyTreeListState extends State<FamilyTreeList> {
  final Set<int> _expandedPersons = {};
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Group persons by generation level
    final generations = <int, List<Person>>{};
    for (final person in widget.treeData.persons) {
      generations.putIfAbsent(person.generationLevel, () => []).add(person);
    }

    // Sort generations
    final sortedGenerations = generations.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Filter by search if active
    List<Person> filteredPersons = widget.treeData.persons;
    if (_searchQuery.isNotEmpty) {
      filteredPersons = widget.treeData.persons.where((p) {
        final name = '${p.firstName} ${p.lastName ?? ''}'.toLowerCase();
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return Column(
      children: [
        // Search bar
        Padding(
          padding: AppSpacing.paddingMD,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari anggota keluarga...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),

        // Expand/Collapse all
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '${widget.treeData.persons.length} Anggota',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => setState(() {
                  if (_expandedPersons.length == widget.treeData.persons.length) {
                    _expandedPersons.clear();
                  } else {
                    _expandedPersons.addAll(
                      widget.treeData.persons.map((p) => p.id),
                    );
                  }
                }),
                icon: Icon(
                  _expandedPersons.length == widget.treeData.persons.length
                      ? Icons.unfold_less
                      : Icons.unfold_more,
                  size: 18,
                ),
                label: Text(
                  _expandedPersons.length == widget.treeData.persons.length
                      ? 'Tutup Semua'
                      : 'Buka Semua',
                ),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: _searchQuery.isNotEmpty
              ? _buildSearchResults(filteredPersons)
              : _buildGenerationList(sortedGenerations),
        ),
      ],
    );
  }

  Widget _buildSearchResults(List<Person> persons) {
    if (persons.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ditemukan',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: AppSpacing.paddingMD,
      itemCount: persons.length,
      itemBuilder: (context, index) {
        return _buildPersonTile(persons[index]);
      },
    );
  }

  Widget _buildGenerationList(List<MapEntry<int, List<Person>>> generations) {
    return ListView.builder(
      padding: AppSpacing.paddingMD,
      itemCount: generations.length,
      itemBuilder: (context, index) {
        final generation = generations[index];
        return _buildGenerationSection(
          generation.key,
          generation.value,
        );
      },
    );
  }

  Widget _buildGenerationSection(int level, List<Person> persons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Generation header
        Container(
          margin: const EdgeInsets.only(bottom: 8, top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Generasi ${level + 1}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),

        // Persons in this generation
        ...persons.map((person) => _buildPersonTile(person)),

        AppSpacing.verticalMD,
      ],
    );
  }

  Widget _buildPersonTile(Person person) {
    final isExpanded = _expandedPersons.contains(person.id);
    final isSelected = widget.selectedPerson?.id == person.id;
    final nodeColor = _getNodeColor(person.gender);

    // Get relationships for expanded view
    final spouse = widget.treeData.getSpouse(person.id);
    final children = widget.treeData.getChildren(person.id);
    final parents = widget.treeData.getParents(person.id);
    final siblings = widget.treeData.getSiblings(person.id);

    final hasRelationships = spouse != null ||
        children.isNotEmpty ||
        parents.isNotEmpty ||
        siblings.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: Column(
        children: [
          // Main person info
          InkWell(
            onTap: () => widget.onPersonSelected?.call(person),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: AppSpacing.paddingMD,
              child: Row(
                children: [
                  // Avatar
                  _buildAvatar(person, nodeColor),
                  AppSpacing.horizontalMD,

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          person.fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              person.genderDisplay,
                              style: TextStyle(
                                fontSize: 12,
                                color: nodeColor,
                              ),
                            ),
                            if (person.age != null) ...[
                              const Text(' · ', style: TextStyle(fontSize: 12)),
                              Text(
                                '${person.age} tahun',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                            if (!person.isAlive) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.brightness_1,
                                size: 8,
                                color: AppColors.textTertiary,
                              ),
                            ],
                          ],
                        ),
                        if (person.occupation != null)
                          Text(
                            person.occupation!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),

                  // Expand button
                  if (hasRelationships)
                    IconButton(
                      onPressed: () => setState(() {
                        if (isExpanded) {
                          _expandedPersons.remove(person.id);
                        } else {
                          _expandedPersons.add(person.id);
                        }
                      }),
                      icon: Icon(
                        isExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Expanded relationships
          if (isExpanded && hasRelationships)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(),
                  if (spouse != null)
                    _buildRelationshipRow(
                      Icons.favorite,
                      'Pasangan',
                      [spouse],
                    ),
                  if (parents.isNotEmpty)
                    _buildRelationshipRow(
                      Icons.supervisor_account,
                      'Orang Tua',
                      parents,
                    ),
                  if (children.isNotEmpty)
                    _buildRelationshipRow(
                      Icons.child_care,
                      'Anak',
                      children,
                    ),
                  if (siblings.isNotEmpty)
                    _buildRelationshipRow(
                      Icons.people,
                      'Saudara',
                      siblings,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRelationshipRow(IconData icon, String label, List<Person> persons) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: persons.map((p) {
                return InkWell(
                  onTap: () => widget.onPersonSelected?.call(p),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getNodeColor(p.gender).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      p.firstName,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getNodeColor(p.gender),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(Person person, Color nodeColor) {
    const size = 48.0;

    if (person.avatarUrl != null && person.avatarUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: person.avatarUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              _buildInitialsAvatar(person, nodeColor, size),
          errorWidget: (context, url, error) =>
              _buildInitialsAvatar(person, nodeColor, size),
        ),
      );
    }

    return _buildInitialsAvatar(person, nodeColor, size);
  }

  Widget _buildInitialsAvatar(Person person, Color nodeColor, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: nodeColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          person.initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Color _getNodeColor(String? gender) {
    switch (gender?.toLowerCase()) {
      case 'male':
        return AppColors.maleNode;
      case 'female':
        return AppColors.femaleNode;
      default:
        return AppColors.otherNode;
    }
  }
}
