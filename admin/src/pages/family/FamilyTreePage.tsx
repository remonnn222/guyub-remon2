import { useState } from 'react';
import { TreeDeciduous, Users, Info, Plus } from 'lucide-react';
import { FamilyTree } from '../../components/family';
import type {
  FamilyTreeData,
  Person,
  Gender,
  RelationshipType,
  MarriageStatus,
} from '../../types';

// Demo data - Kusuma Family from Indonesia
const demoFamily: FamilyTreeData = {
  family: {
    id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
    name: 'Keluarga Kusuma',
    description:
      'Keluarga besar Kusuma yang berasal dari Yogyakarta. Silsilah keluarga ini mencakup lima generasi.',
    origin: 'Yogyakarta, Indonesia',
    motto: 'Bersatu Kita Teguh, Bercerai Kita Runtuh',
    coat_of_arms: null,
    cover_image: null,
    is_public: true,
    invite_code: 'KUSUMA01',
    created_by: 1,
    created_at: '2024-01-01T00:00:00Z',
    updated_at: '2024-01-01T00:00:00Z',
  },

  persons: [
    // Generation 1 - Great Grandparents
    {
      id: '11111111-1111-1111-1111-111111111111',
      family_id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
      first_name: 'Soekarno',
      last_name: 'Kusuma',
      nickname: 'Eyang Kakung',
      gender: 'male' as Gender,
      birth_date: '1922-03-15',
      birth_place: 'Yogyakarta',
      death_date: '1998-08-20',
      death_place: 'Yogyakarta',
      is_alive: false,
      photo_url: null,
      bio: 'Pendiri keluarga Kusuma. Seorang pegawai negeri yang dihormati.',
      occupation: 'Pegawai Negeri',
      education: null,
      email: null,
      phone: null,
      address: null,
      generation_level: 1,
      created_by: 1,
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
    },
    {
      id: '11111111-1111-1111-1111-111111111112',
      family_id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
      first_name: 'Kartini',
      last_name: 'Wulandari',
      nickname: 'Eyang Putri',
      gender: 'female' as Gender,
      birth_date: '1925-04-21',
      birth_place: 'Surakarta',
      death_date: '2005-12-10',
      death_place: 'Yogyakarta',
      is_alive: false,
      photo_url: null,
      bio: 'Istri tercinta Soekarno Kusuma. Seorang ibu yang penuh kasih sayang.',
      occupation: 'Guru',
      education: null,
      email: null,
      phone: null,
      address: null,
      generation_level: 1,
      created_by: 1,
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
    },

    // Generation 2 - Grandparents
    {
      id: '22222222-2222-2222-2222-222222222221',
      family_id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
      first_name: 'Bambang',
      last_name: 'Kusuma',
      nickname: 'Pak De',
      gender: 'male' as Gender,
      birth_date: '1948-07-12',
      birth_place: 'Yogyakarta',
      death_date: '2020-03-15',
      death_place: 'Jakarta',
      is_alive: false,
      photo_url: null,
      bio: 'Anak sulung Soekarno dan Kartini. Seorang insinyur sukses.',
      occupation: 'Insinyur Sipil',
      education: 'ITB - Teknik Sipil',
      email: null,
      phone: null,
      address: null,
      generation_level: 2,
      created_by: 1,
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
    },
    {
      id: '22222222-2222-2222-2222-222222222222',
      family_id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
      first_name: 'Sri',
      last_name: 'Rahayu',
      nickname: 'Bu De',
      gender: 'female' as Gender,
      birth_date: '1952-09-03',
      birth_place: 'Bandung',
      death_date: null,
      death_place: null,
      is_alive: true,
      photo_url: null,
      bio: 'Istri setia Bambang Kusuma. Seorang dokter yang mengabdi.',
      occupation: 'Dokter',
      education: 'UI - Kedokteran',
      email: null,
      phone: null,
      address: null,
      generation_level: 2,
      created_by: 1,
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
    },
    {
      id: '22222222-2222-2222-2222-222222222223',
      family_id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
      first_name: 'Siti',
      last_name: 'Kusuma',
      nickname: 'Bu Lik',
      gender: 'female' as Gender,
      birth_date: '1950-11-25',
      birth_place: 'Yogyakarta',
      death_date: null,
      death_place: null,
      is_alive: true,
      photo_url: null,
      bio: 'Anak kedua. Pengusaha batik sukses di Yogyakarta.',
      occupation: 'Pengusaha Batik',
      education: 'UGM - Ekonomi',
      email: null,
      phone: null,
      address: null,
      generation_level: 2,
      created_by: 1,
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
    },

    // Generation 3 - Parents
    {
      id: '33333333-3333-3333-3333-333333333331',
      family_id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
      first_name: 'Budi',
      last_name: 'Kusuma',
      nickname: 'Pak Budi',
      gender: 'male' as Gender,
      birth_date: '1975-03-28',
      birth_place: 'Jakarta',
      death_date: null,
      death_place: null,
      is_alive: true,
      photo_url: null,
      bio: 'Anak sulung Bambang dan Sri. Arsitek sukses di Jakarta.',
      occupation: 'Arsitek',
      education: 'ITB - Arsitektur',
      email: 'budi.kusuma@email.com',
      phone: '+62812345678',
      address: 'Jl. Menteng Raya No. 123, Jakarta Pusat',
      generation_level: 3,
      created_by: 1,
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
    },
    {
      id: '33333333-3333-3333-3333-333333333332',
      family_id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
      first_name: 'Dewi',
      last_name: 'Lestari',
      nickname: 'Bu Dewi',
      gender: 'female' as Gender,
      birth_date: '1978-08-14',
      birth_place: 'Surabaya',
      death_date: null,
      death_place: null,
      is_alive: true,
      photo_url: null,
      bio: 'Istri Budi Kusuma. Penulis novel terkenal.',
      occupation: 'Penulis',
      education: 'UI - Sastra Indonesia',
      email: 'dewi.lestari@email.com',
      phone: '+62812345679',
      address: 'Jl. Menteng Raya No. 123, Jakarta Pusat',
      generation_level: 3,
      created_by: 1,
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
    },
    {
      id: '33333333-3333-3333-3333-333333333333',
      family_id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
      first_name: 'Ratna',
      last_name: 'Kusuma',
      nickname: 'Bu Ratna',
      gender: 'female' as Gender,
      birth_date: '1972-12-05',
      birth_place: 'Jakarta',
      death_date: null,
      death_place: null,
      is_alive: true,
      photo_url: null,
      bio: 'Anak kedua Bambang dan Sri. Psikolog anak.',
      occupation: 'Psikolog',
      education: 'UI - Psikologi',
      email: 'ratna.kusuma@email.com',
      phone: '+62812345680',
      address: 'Jl. Kemang Raya No. 45, Jakarta Selatan',
      generation_level: 3,
      created_by: 1,
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
    },

    // Generation 4 - Current Generation
    {
      id: '44444444-4444-4444-4444-444444444441',
      family_id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
      first_name: 'Arya',
      last_name: 'Kusuma',
      nickname: 'Arya',
      gender: 'male' as Gender,
      birth_date: '1998-05-20',
      birth_place: 'Jakarta',
      death_date: null,
      death_place: null,
      is_alive: true,
      photo_url: null,
      bio: 'Anak sulung Budi dan Dewi. Mahasiswa S2 di MIT.',
      occupation: 'Mahasiswa S2',
      education: 'MIT - Computer Science',
      email: 'arya.kusuma@email.com',
      phone: '+62812345684',
      address: null,
      generation_level: 4,
      created_by: 1,
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
    },
    {
      id: '44444444-4444-4444-4444-444444444442',
      family_id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
      first_name: 'Putri',
      last_name: 'Kusuma',
      nickname: 'Putri',
      gender: 'female' as Gender,
      birth_date: '2001-11-15',
      birth_place: 'Jakarta',
      death_date: null,
      death_place: null,
      is_alive: true,
      photo_url: null,
      bio: 'Anak kedua Budi dan Dewi. Mahasiswa kedokteran.',
      occupation: 'Mahasiswa',
      education: 'UI - Kedokteran',
      email: 'putri.kusuma@email.com',
      phone: '+62812345685',
      address: null,
      generation_level: 4,
      created_by: 1,
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
    },
    {
      id: '44444444-4444-4444-4444-444444444446',
      family_id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
      first_name: 'Sarah',
      last_name: 'Anderson',
      nickname: 'Sarah',
      gender: 'female' as Gender,
      birth_date: '1999-04-10',
      birth_place: 'Boston, USA',
      death_date: null,
      death_place: null,
      is_alive: true,
      photo_url: null,
      bio: 'Istri Arya Kusuma. Data scientist dari Amerika.',
      occupation: 'Data Scientist',
      education: 'Stanford - Data Science',
      email: 'sarah.anderson@email.com',
      phone: '+1234567890',
      address: null,
      generation_level: 4,
      created_by: 1,
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
    },

    // Generation 5 - Youngest
    {
      id: '55555555-5555-5555-5555-555555555551',
      family_id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
      first_name: 'Adam',
      last_name: 'Kusuma',
      nickname: 'Baby Adam',
      gender: 'male' as Gender,
      birth_date: '2023-06-15',
      birth_place: 'Boston, USA',
      death_date: null,
      death_place: null,
      is_alive: true,
      photo_url: null,
      bio: 'Anak pertama Arya dan Sarah. Generasi penerus.',
      occupation: null,
      education: null,
      email: null,
      phone: null,
      address: null,
      generation_level: 5,
      created_by: 1,
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
    },
  ],

  relationships: [
    // Gen 1 - Spouse
    {
      id: 1,
      person_id: '11111111-1111-1111-1111-111111111111',
      related_person_id: '11111111-1111-1111-1111-111111111112',
      type: 'spouse' as RelationshipType,
      marriage_status: 'married' as MarriageStatus,
      marriage_date: '1945-08-17',
      marriage_place: 'Yogyakarta',
      divorce_date: null,
      notes: null,
      created_by: 1,
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
    },
    // Gen 1 -> 2 (Parent-Child)
    {
      id: 2,
      person_id: '11111111-1111-1111-1111-111111111111',
      related_person_id: '22222222-2222-2222-2222-222222222221',
      type: 'parent' as RelationshipType,
      marriage_status: null,
      marriage_date: null,
      marriage_place: null,
      divorce_date: null,
      notes: null,
      created_by: 1,
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
    },
    {
      id: 3,
      person_id: '11111111-1111-1111-1111-111111111112',
      related_person_id: '22222222-2222-2222-2222-222222222221',
      type: 'parent' as RelationshipType,
      marriage_status: null,
      marriage_date: null,
      marriage_place: null,
      divorce_date: null,
      notes: null,
      created_by: 1,
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
    },
    {
      id: 4,
      person_id: '11111111-1111-1111-1111-111111111111',
      related_person_id: '22222222-2222-2222-2222-222222222223',
      type: 'parent' as RelationshipType,
      marriage_status: null,
      marriage_date: null,
      marriage_place: null,
      divorce_date: null,
      notes: null,
      created_by: 1,
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
    },
    // Gen 2 - Spouse
    {
      id: 5,
      person_id: '22222222-2222-2222-2222-222222222221',
      related_person_id: '22222222-2222-2222-2222-222222222222',
      type: 'spouse' as RelationshipType,
      marriage_status: 'widowed' as MarriageStatus,
      marriage_date: '1972-06-15',
      marriage_place: 'Jakarta',
      divorce_date: null,
      notes: null,
      created_by: 1,
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
    },
    // Gen 2 -> 3
    {
      id: 6,
      person_id: '22222222-2222-2222-2222-222222222221',
      related_person_id: '33333333-3333-3333-3333-333333333331',
      type: 'parent' as RelationshipType,
      marriage_status: null,
      marriage_date: null,
      marriage_place: null,
      divorce_date: null,
      notes: null,
      created_by: 1,
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
    },
    {
      id: 7,
      person_id: '22222222-2222-2222-2222-222222222222',
      related_person_id: '33333333-3333-3333-3333-333333333331',
      type: 'parent' as RelationshipType,
      marriage_status: null,
      marriage_date: null,
      marriage_place: null,
      divorce_date: null,
      notes: null,
      created_by: 1,
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
    },
    {
      id: 8,
      person_id: '22222222-2222-2222-2222-222222222221',
      related_person_id: '33333333-3333-3333-3333-333333333333',
      type: 'parent' as RelationshipType,
      marriage_status: null,
      marriage_date: null,
      marriage_place: null,
      divorce_date: null,
      notes: null,
      created_by: 1,
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
    },
    // Gen 3 - Spouse
    {
      id: 9,
      person_id: '33333333-3333-3333-3333-333333333331',
      related_person_id: '33333333-3333-3333-3333-333333333332',
      type: 'spouse' as RelationshipType,
      marriage_status: 'married' as MarriageStatus,
      marriage_date: '1997-12-25',
      marriage_place: 'Jakarta',
      divorce_date: null,
      notes: null,
      created_by: 1,
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
    },
    // Gen 3 -> 4
    {
      id: 10,
      person_id: '33333333-3333-3333-3333-333333333331',
      related_person_id: '44444444-4444-4444-4444-444444444441',
      type: 'parent' as RelationshipType,
      marriage_status: null,
      marriage_date: null,
      marriage_place: null,
      divorce_date: null,
      notes: null,
      created_by: 1,
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
    },
    {
      id: 11,
      person_id: '33333333-3333-3333-3333-333333333332',
      related_person_id: '44444444-4444-4444-4444-444444444441',
      type: 'parent' as RelationshipType,
      marriage_status: null,
      marriage_date: null,
      marriage_place: null,
      divorce_date: null,
      notes: null,
      created_by: 1,
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
    },
    {
      id: 12,
      person_id: '33333333-3333-3333-3333-333333333331',
      related_person_id: '44444444-4444-4444-4444-444444444442',
      type: 'parent' as RelationshipType,
      marriage_status: null,
      marriage_date: null,
      marriage_place: null,
      divorce_date: null,
      notes: null,
      created_by: 1,
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
    },
    // Gen 4 - Spouse
    {
      id: 13,
      person_id: '44444444-4444-4444-4444-444444444441',
      related_person_id: '44444444-4444-4444-4444-444444444446',
      type: 'spouse' as RelationshipType,
      marriage_status: 'married' as MarriageStatus,
      marriage_date: '2022-06-01',
      marriage_place: 'Boston, USA',
      divorce_date: null,
      notes: null,
      created_by: 1,
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
    },
    // Gen 4 -> 5
    {
      id: 14,
      person_id: '44444444-4444-4444-4444-444444444441',
      related_person_id: '55555555-5555-5555-5555-555555555551',
      type: 'parent' as RelationshipType,
      marriage_status: null,
      marriage_date: null,
      marriage_place: null,
      divorce_date: null,
      notes: null,
      created_by: 1,
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
    },
    {
      id: 15,
      person_id: '44444444-4444-4444-4444-444444444446',
      related_person_id: '55555555-5555-5555-5555-555555555551',
      type: 'parent' as RelationshipType,
      marriage_status: null,
      marriage_date: null,
      marriage_place: null,
      divorce_date: null,
      notes: null,
      created_by: 1,
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
    },
  ],

  positions: [
    // Generation 1
    { id: 1, person_id: '11111111-1111-1111-1111-111111111111', family_id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479', x: -100, y: 0, level: 1, order: 1, created_at: '', updated_at: '' },
    { id: 2, person_id: '11111111-1111-1111-1111-111111111112', family_id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479', x: 150, y: 0, level: 1, order: 2, created_at: '', updated_at: '' },
    // Generation 2
    { id: 3, person_id: '22222222-2222-2222-2222-222222222221', family_id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479', x: -200, y: 200, level: 2, order: 1, created_at: '', updated_at: '' },
    { id: 4, person_id: '22222222-2222-2222-2222-222222222222', family_id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479', x: 50, y: 200, level: 2, order: 2, created_at: '', updated_at: '' },
    { id: 5, person_id: '22222222-2222-2222-2222-222222222223', family_id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479', x: 300, y: 200, level: 2, order: 3, created_at: '', updated_at: '' },
    // Generation 3
    { id: 6, person_id: '33333333-3333-3333-3333-333333333331', family_id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479', x: -300, y: 400, level: 3, order: 1, created_at: '', updated_at: '' },
    { id: 7, person_id: '33333333-3333-3333-3333-333333333332', family_id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479', x: -50, y: 400, level: 3, order: 2, created_at: '', updated_at: '' },
    { id: 8, person_id: '33333333-3333-3333-3333-333333333333', family_id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479', x: 200, y: 400, level: 3, order: 3, created_at: '', updated_at: '' },
    // Generation 4
    { id: 9, person_id: '44444444-4444-4444-4444-444444444441', family_id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479', x: -350, y: 600, level: 4, order: 1, created_at: '', updated_at: '' },
    { id: 10, person_id: '44444444-4444-4444-4444-444444444442', family_id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479', x: -100, y: 600, level: 4, order: 2, created_at: '', updated_at: '' },
    { id: 11, person_id: '44444444-4444-4444-4444-444444444446', family_id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479', x: 150, y: 600, level: 4, order: 3, created_at: '', updated_at: '' },
    // Generation 5
    { id: 12, person_id: '55555555-5555-5555-5555-555555555551', family_id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479', x: -100, y: 800, level: 5, order: 1, created_at: '', updated_at: '' },
  ],

  root_persons: [],

  statistics: {
    total_persons: 12,
    total_living: 9,
    total_deceased: 3,
    total_male: 6,
    total_female: 6,
    generations: 5,
    oldest_person: null,
    youngest_person: null,
    total_marriages: 4,
    average_children: 2.3,
    by_generation: { 1: 2, 2: 3, 3: 3, 4: 3, 5: 1 },
    by_decade: {},
  },
};

export default function FamilyTreePage() {
  const [selectedPerson, setSelectedPerson] = useState<Person | null>(null);
  const [isEditing, setIsEditing] = useState(false);

  const handlePersonEdit = (person: Person) => {
    setSelectedPerson(person);
    setIsEditing(true);
  };

  const handleAddRelative = (person: Person, type: RelationshipType) => {
    console.log('Add relative:', type, 'to', person.first_name);
    // TODO: Open modal to add relative
  };

  const handlePositionsChange = (
    positions: Array<{ person_id: string; x: number; y: number }>
  ) => {
    console.log('Positions updated:', positions);
    // TODO: Save positions to backend
  };

  return (
    <div className="h-screen flex flex-col bg-amber-50">
      {/* Header */}
      <header className="bg-white border-b border-amber-200 px-6 py-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-4">
            <div className="w-12 h-12 rounded-full bg-gradient-to-br from-amber-400 to-amber-600 flex items-center justify-center">
              <TreeDeciduous className="w-6 h-6 text-white" />
            </div>
            <div>
              <h1 className="text-2xl font-bold text-amber-900" style={{ fontFamily: 'Georgia, serif' }}>
                {demoFamily.family.name}
              </h1>
              <p className="text-sm text-amber-600">{demoFamily.family.origin}</p>
            </div>
          </div>

          <div className="flex items-center gap-3">
            <button className="flex items-center gap-2 px-4 py-2 text-amber-700 hover:bg-amber-100 rounded-lg transition-colors">
              <Users className="w-4 h-4" />
              <span>{demoFamily.statistics.total_persons} Members</span>
            </button>
            <button className="flex items-center gap-2 px-4 py-2 text-amber-700 hover:bg-amber-100 rounded-lg transition-colors">
              <Info className="w-4 h-4" />
              <span>About</span>
            </button>
            <button className="flex items-center gap-2 px-4 py-2 bg-amber-500 hover:bg-amber-600 text-white rounded-lg transition-colors">
              <Plus className="w-4 h-4" />
              <span>Add Person</span>
            </button>
          </div>
        </div>

        {/* Family Motto */}
        {demoFamily.family.motto && (
          <div className="mt-3 text-center">
            <p className="text-sm italic text-amber-700">"{demoFamily.family.motto}"</p>
          </div>
        )}
      </header>

      {/* Family Tree Visualization */}
      <main className="flex-1">
        <FamilyTree
          data={demoFamily}
          onPersonEdit={handlePersonEdit}
          onAddRelative={handleAddRelative}
          onPositionsChange={handlePositionsChange}
          isEditable={true}
        />
      </main>

      {/* Person Detail Sidebar (when selected) */}
      {selectedPerson && isEditing && (
        <div className="fixed right-0 top-0 h-full w-96 bg-white shadow-2xl border-l border-amber-200 p-6 overflow-y-auto">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-xl font-bold text-amber-900">Edit Person</h2>
            <button
              onClick={() => {
                setSelectedPerson(null);
                setIsEditing(false);
              }}
              className="p-2 hover:bg-amber-100 rounded-lg transition-colors"
            >
              ×
            </button>
          </div>

          <div className="space-y-4">
            <div className="text-center mb-6">
              <div className="w-24 h-24 mx-auto rounded-full bg-gradient-to-br from-amber-200 to-amber-300 flex items-center justify-center text-3xl font-bold text-amber-800">
                {selectedPerson.first_name.charAt(0)}
                {selectedPerson.last_name.charAt(0)}
              </div>
              <h3 className="mt-3 text-lg font-semibold text-amber-900">
                {selectedPerson.first_name} {selectedPerson.last_name}
              </h3>
              {selectedPerson.nickname && (
                <p className="text-sm text-amber-600">"{selectedPerson.nickname}"</p>
              )}
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-amber-700 mb-1">First Name</label>
                <input
                  type="text"
                  defaultValue={selectedPerson.first_name}
                  className="w-full px-3 py-2 border border-amber-200 rounded-lg focus:ring-2 focus:ring-amber-400"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-amber-700 mb-1">Last Name</label>
                <input
                  type="text"
                  defaultValue={selectedPerson.last_name}
                  className="w-full px-3 py-2 border border-amber-200 rounded-lg focus:ring-2 focus:ring-amber-400"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-amber-700 mb-1">Nickname</label>
              <input
                type="text"
                defaultValue={selectedPerson.nickname || ''}
                className="w-full px-3 py-2 border border-amber-200 rounded-lg focus:ring-2 focus:ring-amber-400"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-amber-700 mb-1">Gender</label>
              <select
                defaultValue={selectedPerson.gender}
                className="w-full px-3 py-2 border border-amber-200 rounded-lg focus:ring-2 focus:ring-amber-400"
              >
                <option value="male">Male</option>
                <option value="female">Female</option>
                <option value="other">Other</option>
              </select>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-amber-700 mb-1">Birth Date</label>
                <input
                  type="date"
                  defaultValue={selectedPerson.birth_date || ''}
                  className="w-full px-3 py-2 border border-amber-200 rounded-lg focus:ring-2 focus:ring-amber-400"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-amber-700 mb-1">Birth Place</label>
                <input
                  type="text"
                  defaultValue={selectedPerson.birth_place || ''}
                  className="w-full px-3 py-2 border border-amber-200 rounded-lg focus:ring-2 focus:ring-amber-400"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-amber-700 mb-1">Occupation</label>
              <input
                type="text"
                defaultValue={selectedPerson.occupation || ''}
                className="w-full px-3 py-2 border border-amber-200 rounded-lg focus:ring-2 focus:ring-amber-400"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-amber-700 mb-1">Bio</label>
              <textarea
                defaultValue={selectedPerson.bio || ''}
                rows={4}
                className="w-full px-3 py-2 border border-amber-200 rounded-lg focus:ring-2 focus:ring-amber-400"
              />
            </div>

            <div className="flex gap-3 pt-4">
              <button className="flex-1 py-2 bg-amber-500 hover:bg-amber-600 text-white rounded-lg transition-colors font-medium">
                Save Changes
              </button>
              <button
                onClick={() => {
                  setSelectedPerson(null);
                  setIsEditing(false);
                }}
                className="flex-1 py-2 border border-amber-200 text-amber-700 hover:bg-amber-50 rounded-lg transition-colors font-medium"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
