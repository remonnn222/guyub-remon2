import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../config/theme/app_colors.dart';
import '../../domain/entities/family.dart';

/// Person Node Widget for Graph View
class PersonNodeWidget extends StatelessWidget {
  final Person person;
  final bool isSelected;
  final VoidCallback? onTap;
  final Person? spouse;

  const PersonNodeWidget({
    super.key,
    required this.person,
    this.isSelected = false,
    this.onTap,
    this.spouse,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 100,
          maxWidth: 160,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main person node
            _buildPersonCard(person, isSelected),

            // Spouse node (if married)
            if (spouse != null) ...[
              // Marriage connector
              Container(
                width: 20,
                height: 2,
                color: AppColors.border,
              ),
              _buildPersonCard(spouse!, false, isSpouse: true),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPersonCard(Person p, bool selected, {bool isSpouse = false}) {
    final nodeColor = _getNodeColor(p.gender);

    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.primary : nodeColor,
          width: selected ? 3 : 2,
        ),
        boxShadow: [
          if (selected)
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 2,
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
            ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar section
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: nodeColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
            child: _buildAvatar(p, nodeColor),
          ),

          // Info section
          Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                Text(
                  p.firstName,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (p.lastName != null && p.lastName!.isNotEmpty)
                  Text(
                    p.lastName!,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (p.birthDate != null)
                  Text(
                    p.age != null ? '${p.age} th' : _formatYear(p.birthDate!),
                    style: TextStyle(
                      fontSize: 9,
                      color: p.isAlive
                          ? AppColors.textTertiary
                          : AppColors.danger,
                    ),
                  ),
              ],
            ),
          ),

          // Death indicator
          if (!p.isAlive)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
              ),
              child: const Icon(
                Icons.brightness_1,
                size: 8,
                color: AppColors.textTertiary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(Person p, Color nodeColor) {
    final size = 40.0;

    if (p.avatarUrl != null && p.avatarUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: p.avatarUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildInitialsAvatar(p, nodeColor, size),
          errorWidget: (context, url, error) =>
              _buildInitialsAvatar(p, nodeColor, size),
        ),
      );
    }

    return _buildInitialsAvatar(p, nodeColor, size);
  }

  Widget _buildInitialsAvatar(Person p, Color nodeColor, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: nodeColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          p.initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
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

  String _formatYear(DateTime date) {
    return date.year.toString();
  }
}

/// Compact Person Node for smaller displays
class PersonNodeCompact extends StatelessWidget {
  final Person person;
  final bool isSelected;
  final VoidCallback? onTap;

  const PersonNodeCompact({
    super.key,
    required this.person,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nodeColor = _getNodeColor(person.gender);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : nodeColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.all(6),
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
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            // Name
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
              child: Text(
                person.firstName,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
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
