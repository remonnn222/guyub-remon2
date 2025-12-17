import { useCallback, useMemo, useState } from 'react';
import {
  ReactFlow,
  Background,
  Controls,
  MiniMap,
  useNodesState,
  useEdgesState,
  addEdge,
  Panel,
  Node,
  Edge,
  Connection,
  BackgroundVariant,
  MarkerType,
} from '@xyflow/react';
import '@xyflow/react/dist/style.css';
import {
  LayoutGrid,
  Search,
  Filter,
} from 'lucide-react';

import PersonNode from './PersonNode';
import type { Person, Relationship, TreePosition, RelationshipType, FamilyTreeData } from '../../types';

interface FamilyTreeProps {
  data: FamilyTreeData;
  onPersonEdit?: (person: Person) => void;
  onAddRelative?: (person: Person, type: RelationshipType) => void;
  onPositionsChange?: (positions: Array<{ person_id: string; x: number; y: number }>) => void;
  isEditable?: boolean;
}

// Custom node types
const nodeTypes = {
  person: PersonNode,
};

// Constants for layout
const NODE_WIDTH = 200;
const NODE_HEIGHT = 100;
const HORIZONTAL_GAP = 50;
const VERTICAL_GAP = 120;

// Convert data to React Flow nodes
function createNodes(
  persons: Person[],
  positions: TreePosition[],
  selectedPersonId: string | null,
  onEdit?: (person: Person) => void,
  onAddRelative?: (person: Person, type: RelationshipType) => void
): Node[] {
  const positionMap = new Map(positions.map((p) => [p.person_id, p]));

  return persons.map((person, index) => {
    const position = positionMap.get(person.id);
    const x = position?.x ?? (index % 5) * (NODE_WIDTH + HORIZONTAL_GAP);
    const y = position?.y ?? person.generation_level * (NODE_HEIGHT + VERTICAL_GAP);

    return {
      id: person.id,
      type: 'person',
      position: { x, y },
      data: {
        person,
        isHighlighted: person.id === selectedPersonId,
        onEdit,
        onAddRelative,
      },
    };
  });
}

// Convert relationships to React Flow edges
function createEdges(relationships: Relationship[]): Edge[] {
  const edges: Edge[] = [];
  const processedPairs = new Set<string>();

  relationships.forEach((rel) => {
    const pairKey = [rel.person_id, rel.related_person_id].sort().join('-');

    // Skip if we've already processed this pair
    if (processedPairs.has(pairKey)) return;
    processedPairs.add(pairKey);

    let style: React.CSSProperties = {};
    let animated = false;
    let sourceHandle: string | undefined;
    let targetHandle: string | undefined;
    let markerEnd: Edge['markerEnd'];

    switch (rel.type) {
      case 'parent':
        style = { stroke: '#92400e', strokeWidth: 2 };
        markerEnd = {
          type: MarkerType.ArrowClosed,
          color: '#92400e',
        };
        break;
      case 'child':
        style = { stroke: '#92400e', strokeWidth: 2 };
        break;
      case 'spouse':
        style = { stroke: '#be185d', strokeWidth: 2, strokeDasharray: '5,5' };
        sourceHandle = 'spouse-right';
        targetHandle = 'spouse-left';
        animated = true;
        break;
      case 'sibling':
        style = { stroke: '#6366f1', strokeWidth: 1.5, strokeDasharray: '3,3' };
        break;
      default:
        style = { stroke: '#9ca3af', strokeWidth: 1 };
    }

    edges.push({
      id: `${rel.id}-${rel.person_id}-${rel.related_person_id}`,
      source: rel.person_id,
      target: rel.related_person_id,
      type: 'smoothstep',
      sourceHandle,
      targetHandle,
      style,
      animated,
      markerEnd,
    });
  });

  return edges;
}

// Auto-layout algorithm (simple tree layout)
function autoLayout(
  persons: Person[],
  _relationships: Relationship[]
): Array<{ person_id: string; x: number; y: number }> {
  // Group by generation level
  const byGeneration = new Map<number, Person[]>();
  persons.forEach((person) => {
    const level = person.generation_level;
    if (!byGeneration.has(level)) {
      byGeneration.set(level, []);
    }
    byGeneration.get(level)!.push(person);
  });

  // Sort generations
  const sortedLevels = Array.from(byGeneration.keys()).sort((a, b) => a - b);

  // Calculate positions
  const positions: Array<{ person_id: string; x: number; y: number }> = [];

  sortedLevels.forEach((level, levelIndex) => {
    const personsInLevel = byGeneration.get(level)!;
    const totalWidth = personsInLevel.length * (NODE_WIDTH + HORIZONTAL_GAP) - HORIZONTAL_GAP;
    const startX = -totalWidth / 2;

    personsInLevel.forEach((person, personIndex) => {
      positions.push({
        person_id: person.id,
        x: startX + personIndex * (NODE_WIDTH + HORIZONTAL_GAP),
        y: levelIndex * (NODE_HEIGHT + VERTICAL_GAP),
      });
    });
  });

  return positions;
}

export default function FamilyTree({
  data,
  onPersonEdit,
  onAddRelative,
  onPositionsChange,
  isEditable = true,
}: FamilyTreeProps) {
  const [selectedPerson, setSelectedPerson] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState('');

  // Create initial nodes and edges
  const initialNodes = useMemo(
    () =>
      createNodes(
        data.persons,
        data.positions,
        selectedPerson,
        isEditable ? onPersonEdit : undefined,
        isEditable ? onAddRelative : undefined
      ),
    [data.persons, data.positions, selectedPerson, onPersonEdit, onAddRelative, isEditable]
  );

  const initialEdges = useMemo(() => createEdges(data.relationships), [data.relationships]);

  const [nodes, setNodes, onNodesChange] = useNodesState(initialNodes);
  const [edges, setEdges, onEdgesChange] = useEdgesState(initialEdges);

  // Handle new connections (if editable)
  const onConnect = useCallback(
    (connection: Connection) => {
      if (!isEditable) return;
      setEdges((eds) => addEdge({ ...connection, type: 'smoothstep' }, eds));
    },
    [setEdges, isEditable]
  );

  // Handle node drag end
  const onNodeDragStop = useCallback(
    (_: React.MouseEvent, node: Node) => {
      if (onPositionsChange) {
        const updatedPositions = nodes.map((n) =>
          n.id === node.id
            ? { person_id: n.id, x: node.position.x, y: node.position.y }
            : { person_id: n.id, x: n.position.x, y: n.position.y }
        );
        onPositionsChange(updatedPositions);
      }
    },
    [nodes, onPositionsChange]
  );

  // Auto-layout handler
  const handleAutoLayout = useCallback(() => {
    const newPositions = autoLayout(data.persons, data.relationships);
    const positionMap = new Map(newPositions.map((p) => [p.person_id, p]));

    setNodes((nds) =>
      nds.map((node) => {
        const pos = positionMap.get(node.id);
        if (pos) {
          return { ...node, position: { x: pos.x, y: pos.y } };
        }
        return node;
      })
    );

    if (onPositionsChange) {
      onPositionsChange(newPositions);
    }
  }, [data.persons, data.relationships, setNodes, onPositionsChange]);

  // Filter nodes by search
  const filteredNodes = useMemo(() => {
    if (!searchQuery.trim()) return nodes;

    const query = searchQuery.toLowerCase();
    return nodes.map((node) => {
      const person = node.data.person as Person;
      const matches =
        person.first_name.toLowerCase().includes(query) ||
        person.last_name.toLowerCase().includes(query) ||
        person.nickname?.toLowerCase().includes(query) ||
        person.occupation?.toLowerCase().includes(query);

      return {
        ...node,
        data: { ...node.data, isHighlighted: matches },
        style: matches ? undefined : { opacity: 0.3 },
      };
    });
  }, [nodes, searchQuery]);

  // Statistics panel
  const stats = data.statistics;

  return (
    <div className="w-full h-full relative">
      <ReactFlow
        nodes={filteredNodes}
        edges={edges}
        onNodesChange={onNodesChange}
        onEdgesChange={onEdgesChange}
        onConnect={onConnect}
        onNodeDragStop={onNodeDragStop}
        onNodeClick={(_, node) => setSelectedPerson(node.id)}
        nodeTypes={nodeTypes}
        fitView
        fitViewOptions={{ padding: 0.2 }}
        minZoom={0.1}
        maxZoom={2}
        defaultEdgeOptions={{
          type: 'smoothstep',
        }}
        nodesDraggable={isEditable}
        nodesConnectable={isEditable}
        elementsSelectable={true}
        className="bg-gradient-to-br from-amber-50 via-white to-amber-50"
      >
        <Background variant={BackgroundVariant.Dots} gap={20} size={1} color="#d4b896" />
        <Controls showInteractive={false} />
        <MiniMap
          nodeColor={(node) => {
            const person = node.data?.person as Person | undefined;
            if (!person) return '#9ca3af';
            switch (person.gender) {
              case 'male':
                return '#3b82f6';
              case 'female':
                return '#ec4899';
              default:
                return '#8b5cf6';
            }
          }}
          maskColor="rgba(255, 255, 255, 0.8)"
          className="bg-white/80"
        />

        {/* Top Panel - Search & Actions */}
        <Panel position="top-left" className="flex gap-2">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <input
              type="text"
              placeholder="Search family members..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="pl-10 pr-4 py-2 rounded-lg border border-amber-200 bg-white shadow-sm focus:ring-2 focus:ring-amber-400 focus:border-transparent w-64"
            />
          </div>
          <button
            onClick={handleAutoLayout}
            className="flex items-center gap-2 px-4 py-2 bg-white border border-amber-200 rounded-lg shadow-sm hover:bg-amber-50 transition-colors"
            title="Auto-arrange tree"
          >
            <LayoutGrid className="w-4 h-4" />
            <span className="text-sm">Auto Layout</span>
          </button>
        </Panel>

        {/* Stats Panel */}
        <Panel position="top-right">
          <div className="bg-white/90 backdrop-blur-sm rounded-lg shadow-lg p-4 min-w-[200px]">
            <h3 className="font-semibold text-amber-800 mb-3 flex items-center gap-2">
              <Filter className="w-4 h-4" />
              Family Statistics
            </h3>
            <div className="grid grid-cols-2 gap-3 text-sm">
              <div>
                <div className="text-2xl font-bold text-amber-600">{stats.total_persons}</div>
                <div className="text-gray-500">Total Members</div>
              </div>
              <div>
                <div className="text-2xl font-bold text-green-600">{stats.total_living}</div>
                <div className="text-gray-500">Living</div>
              </div>
              <div>
                <div className="text-2xl font-bold text-blue-600">{stats.total_male}</div>
                <div className="text-gray-500">Male</div>
              </div>
              <div>
                <div className="text-2xl font-bold text-pink-600">{stats.total_female}</div>
                <div className="text-gray-500">Female</div>
              </div>
              <div className="col-span-2">
                <div className="text-xl font-bold text-amber-800">{stats.generations}</div>
                <div className="text-gray-500">Generations</div>
              </div>
            </div>
          </div>
        </Panel>

        {/* Legend Panel */}
        <Panel position="bottom-left">
          <div className="bg-white/90 backdrop-blur-sm rounded-lg shadow-lg p-3">
            <h4 className="text-xs font-semibold text-gray-600 mb-2">Legend</h4>
            <div className="flex flex-wrap gap-3 text-xs">
              <div className="flex items-center gap-1">
                <div className="w-3 h-3 rounded-full bg-blue-400" />
                <span>Male</span>
              </div>
              <div className="flex items-center gap-1">
                <div className="w-3 h-3 rounded-full bg-pink-400" />
                <span>Female</span>
              </div>
              <div className="flex items-center gap-1">
                <div className="w-8 h-0.5 bg-amber-700" />
                <span>Parent-Child</span>
              </div>
              <div className="flex items-center gap-1">
                <div className="w-8 h-0.5 bg-pink-600 border-dashed border-t-2" />
                <span>Spouse</span>
              </div>
            </div>
          </div>
        </Panel>
      </ReactFlow>
    </div>
  );
}
