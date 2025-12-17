import { memo } from 'react';
import { Handle, Position } from '@xyflow/react';
import { User, Edit, Plus, Heart, Calendar, MapPin, Briefcase } from 'lucide-react';
import type { Person, Gender, RelationshipType } from '../../types';

export interface PersonNodeData {
  person: Person;
  isHighlighted?: boolean;
  isSelected?: boolean;
  onEdit?: (person: Person) => void;
  onAddRelative?: (person: Person, type: RelationshipType) => void;
}

const PersonNode = memo(({ data, selected }: { data: PersonNodeData; selected?: boolean }) => {
  const { person, isHighlighted, onEdit, onAddRelative } = data;

  // Calculate age or lifespan
  const getAge = () => {
    if (!person.birth_date) return null;
    const birthYear = new Date(person.birth_date).getFullYear();
    if (person.death_date) {
      const deathYear = new Date(person.death_date).getFullYear();
      return `${birthYear} - ${deathYear}`;
    }
    if (person.is_alive) {
      const age = new Date().getFullYear() - birthYear;
      return `${age} years`;
    }
    return `${birthYear} - ?`;
  };

  // Gender-based styling
  const getGenderStyles = (gender: Gender) => {
    switch (gender) {
      case 'male':
        return {
          bg: 'bg-gradient-to-br from-blue-100 to-blue-200',
          border: 'border-blue-400',
          ring: 'ring-blue-300',
          icon: 'text-blue-600',
        };
      case 'female':
        return {
          bg: 'bg-gradient-to-br from-pink-100 to-pink-200',
          border: 'border-pink-400',
          ring: 'ring-pink-300',
          icon: 'text-pink-600',
        };
      default:
        return {
          bg: 'bg-gradient-to-br from-purple-100 to-purple-200',
          border: 'border-purple-400',
          ring: 'ring-purple-300',
          icon: 'text-purple-600',
        };
    }
  };

  const styles = getGenderStyles(person.gender);
  const age = getAge();
  const fullName = person.nickname
    ? `${person.first_name} "${person.nickname}" ${person.last_name}`
    : `${person.first_name} ${person.last_name}`;

  return (
    <div
      className={`
        relative px-4 py-3 rounded-xl shadow-lg border-2 transition-all duration-200 min-w-[180px] max-w-[220px]
        ${styles.bg} ${styles.border}
        ${selected ? `ring-4 ${styles.ring} scale-105` : ''}
        ${isHighlighted ? 'ring-4 ring-amber-400 scale-105' : ''}
        ${!person.is_alive ? 'opacity-75' : ''}
        hover:shadow-xl hover:scale-102 cursor-pointer
      `}
    >
      {/* Connection Handles */}
      <Handle
        type="target"
        position={Position.Top}
        className="!w-3 !h-3 !bg-amber-500 !border-2 !border-white"
      />
      <Handle
        type="source"
        position={Position.Bottom}
        className="!w-3 !h-3 !bg-amber-500 !border-2 !border-white"
      />
      <Handle
        type="target"
        position={Position.Left}
        id="spouse-left"
        className="!w-3 !h-3 !bg-pink-500 !border-2 !border-white"
      />
      <Handle
        type="source"
        position={Position.Right}
        id="spouse-right"
        className="!w-3 !h-3 !bg-pink-500 !border-2 !border-white"
      />

      {/* Photo or Avatar */}
      <div className="flex items-start gap-3">
        <div
          className={`
            w-12 h-12 rounded-full flex items-center justify-center text-xl font-bold shadow-md
            ${person.photo_url ? '' : 'bg-white/60'}
          `}
        >
          {person.photo_url ? (
            <img
              src={person.photo_url}
              alt={fullName}
              className="w-full h-full rounded-full object-cover"
            />
          ) : (
            <span className={styles.icon}>
              {person.first_name.charAt(0)}
              {person.last_name.charAt(0)}
            </span>
          )}
        </div>

        <div className="flex-1 min-w-0">
          {/* Name */}
          <h3 className="font-semibold text-gray-800 text-sm truncate" title={fullName}>
            {person.first_name} {person.last_name}
          </h3>

          {/* Nickname */}
          {person.nickname && (
            <p className="text-xs text-gray-500 italic truncate">"{person.nickname}"</p>
          )}

          {/* Age/Lifespan */}
          {age && (
            <div className="flex items-center gap-1 text-xs text-gray-600 mt-0.5">
              <Calendar className="w-3 h-3" />
              <span>{age}</span>
            </div>
          )}
        </div>
      </div>

      {/* Deceased indicator */}
      {!person.is_alive && (
        <div className="absolute -top-2 -right-2 w-6 h-6 bg-gray-600 rounded-full flex items-center justify-center text-white text-xs">
          †
        </div>
      )}

      {/* Additional Info (shown on hover/select) */}
      {(selected || isHighlighted) && (
        <div className="mt-2 pt-2 border-t border-gray-300/50 space-y-1">
          {person.birth_place && (
            <div className="flex items-center gap-1 text-xs text-gray-600">
              <MapPin className="w-3 h-3" />
              <span className="truncate">{person.birth_place}</span>
            </div>
          )}
          {person.occupation && (
            <div className="flex items-center gap-1 text-xs text-gray-600">
              <Briefcase className="w-3 h-3" />
              <span className="truncate">{person.occupation}</span>
            </div>
          )}
        </div>
      )}

      {/* Quick Actions (shown on hover) */}
      {(selected || isHighlighted) && (onEdit || onAddRelative) && (
        <div className="absolute -bottom-10 left-1/2 -translate-x-1/2 flex gap-1 bg-white rounded-lg shadow-lg p-1 z-10">
          {onEdit && (
            <button
              onClick={(e) => {
                e.stopPropagation();
                onEdit(person);
              }}
              className="p-1.5 rounded hover:bg-amber-100 text-amber-600 transition-colors"
              title="Edit Person"
            >
              <Edit className="w-4 h-4" />
            </button>
          )}
          {onAddRelative && (
            <>
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  onAddRelative(person, 'parent' as RelationshipType);
                }}
                className="p-1.5 rounded hover:bg-blue-100 text-blue-600 transition-colors"
                title="Add Parent"
              >
                <Plus className="w-4 h-4" />
              </button>
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  onAddRelative(person, 'child' as RelationshipType);
                }}
                className="p-1.5 rounded hover:bg-green-100 text-green-600 transition-colors"
                title="Add Child"
              >
                <User className="w-4 h-4" />
              </button>
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  onAddRelative(person, 'spouse' as RelationshipType);
                }}
                className="p-1.5 rounded hover:bg-pink-100 text-pink-600 transition-colors"
                title="Add Spouse"
              >
                <Heart className="w-4 h-4" />
              </button>
            </>
          )}
        </div>
      )}
    </div>
  );
});

PersonNode.displayName = 'PersonNode';

export default PersonNode;
