import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../domain/entities/family.dart';
import 'person_node_widget.dart';

/// Family Tree Graph Visualization
/// Uses GraphView package for interactive tree rendering
class FamilyTreeGraph extends StatefulWidget {
  final FamilyTreeData treeData;
  final Person? selectedPerson;
  final void Function(Person person)? onPersonSelected;
  final void Function(List<TreePosition> positions)? onPositionsChanged;

  const FamilyTreeGraph({
    super.key,
    required this.treeData,
    this.selectedPerson,
    this.onPersonSelected,
    this.onPositionsChanged,
  });

  @override
  State<FamilyTreeGraph> createState() => _FamilyTreeGraphState();
}

class _FamilyTreeGraphState extends State<FamilyTreeGraph> {
  final Graph _graph = Graph();
  final TransformationController _transformController = TransformationController();
  late BuchheimWalkerConfiguration _builder;

  @override
  void initState() {
    super.initState();
    _builder = BuchheimWalkerConfiguration()
      ..siblingSeparation = 60
      ..levelSeparation = 100
      ..subtreeSeparation = 80
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;

    _buildGraph();
  }

  @override
  void didUpdateWidget(FamilyTreeGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.treeData != oldWidget.treeData) {
      _graph.nodes.clear();
      _graph.edges.clear();
      _buildGraph();
    }
  }

  void _buildGraph() {
    // Create nodes for each person
    final nodeMap = <int, Node>{};

    for (final person in widget.treeData.persons) {
      final node = Node.Id(person.id);
      nodeMap[person.id] = node;
      _graph.addNode(node);
    }

    // Create edges for relationships
    for (final relationship in widget.treeData.relationships) {
      final sourceNode = nodeMap[relationship.personId];
      final targetNode = nodeMap[relationship.relatedPersonId];

      if (sourceNode != null && targetNode != null) {
        // Only add parent-child edges to avoid duplicates
        if (relationship.type == RelationshipType.parent) {
          _graph.addEdge(sourceNode, targetNode);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.treeData.persons.isEmpty) {
      return const Center(
        child: Text('Tidak ada anggota keluarga'),
      );
    }

    return Stack(
      children: [
        // Graph view
        InteractiveViewer(
          constrained: false,
          boundaryMargin: const EdgeInsets.all(300),
          minScale: 0.3,
          maxScale: 2.0,
          transformationController: _transformController,
          child: GraphView(
            graph: _graph,
            algorithm: BuchheimWalkerAlgorithm(
              _builder,
              TreeEdgeRenderer(_builder),
            ),
            paint: Paint()
              ..color = AppColors.border
              ..strokeWidth = 2
              ..style = PaintingStyle.stroke,
            builder: (Node node) {
              final personId = node.key!.value as int;
              final person = widget.treeData.getPersonById(personId);

              if (person == null) {
                return const SizedBox.shrink();
              }

              return PersonNodeWidget(
                person: person,
                isSelected: widget.selectedPerson?.id == person.id,
                onTap: () => widget.onPersonSelected?.call(person),
                spouse: widget.treeData.getSpouse(person.id),
              );
            },
          ),
        ),

        // Controls overlay
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            children: [
              // Zoom in
              FloatingActionButton.small(
                heroTag: 'zoom_in',
                onPressed: _zoomIn,
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textPrimary,
                child: const Icon(Icons.add),
              ),
              AppSpacing.verticalXS,
              // Zoom out
              FloatingActionButton.small(
                heroTag: 'zoom_out',
                onPressed: _zoomOut,
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textPrimary,
                child: const Icon(Icons.remove),
              ),
              AppSpacing.verticalXS,
              // Reset view
              FloatingActionButton.small(
                heroTag: 'reset',
                onPressed: _resetView,
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textPrimary,
                child: const Icon(Icons.center_focus_strong),
              ),
            ],
          ),
        ),

        // Legend
        Positioned(
          left: 16,
          bottom: 16,
          child: Container(
            padding: AppSpacing.paddingSM,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLegendItem(AppColors.maleNode, 'Laki-laki'),
                AppSpacing.verticalXS,
                _buildLegendItem(AppColors.femaleNode, 'Perempuan'),
                AppSpacing.verticalXS,
                _buildLegendItem(AppColors.otherNode, 'Lainnya'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  void _zoomIn() {
    final currentScale = _transformController.value.getMaxScaleOnAxis();
    final newScale = (currentScale * 1.2).clamp(0.3, 2.0);
    _setScale(newScale);
  }

  void _zoomOut() {
    final currentScale = _transformController.value.getMaxScaleOnAxis();
    final newScale = (currentScale / 1.2).clamp(0.3, 2.0);
    _setScale(newScale);
  }

  void _setScale(double scale) {
    final currentMatrix = _transformController.value;
    final translation = currentMatrix.getTranslation();
    final newMatrix = Matrix4.identity()
      ..translate(translation.x, translation.y)
      ..scale(scale);

    _transformController.value = newMatrix;
  }

  void _resetView() {
    _transformController.value = Matrix4.identity();
  }
}

/// Custom Edge Renderer for Tree
class TreeEdgeRenderer extends EdgeRenderer {
  final BuchheimWalkerConfiguration configuration;

  TreeEdgeRenderer(this.configuration);

  @override
  void renderEdge(Canvas canvas, Edge edge, Paint paint) {
    final source = edge.source;
    final destination = edge.destination;

    final sourceX = source.x + source.width / 2;
    final sourceY = source.y + source.height;
    final destX = destination.x + destination.width / 2;
    final destY = destination.y;

    // Draw a smooth line from parent to child
    final path = Path()
      ..moveTo(sourceX, sourceY)
      ..cubicTo(
        sourceX,
        sourceY + (destY - sourceY) / 2,
        destX,
        destY - (destY - sourceY) / 2,
        destX,
        destY,
      );

    canvas.drawPath(path, paint);
  }
}
