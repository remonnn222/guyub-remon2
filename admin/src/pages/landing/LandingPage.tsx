import { Link } from 'react-router-dom';
import {
  TreeDeciduous,
  Users,
  Shield,
  History,
  ArrowRight,
  Github,
  Heart,
  Sparkles,
} from 'lucide-react';
import { FamilyTree } from '@/components/family';
import type { FamilyTreeData, Gender, RelationshipType, MarriageStatus } from '@/types';

// Demo data for landing page preview
const demoFamily: FamilyTreeData = {
  family: {
    id: 'demo',
    name: 'Keluarga Kusuma',
    description: 'Silsilah keluarga besar Kusuma',
    origin: 'Yogyakarta',
    motto: '',
    coat_of_arms: null,
    cover_image: null,
    is_public: true,
    invite_code: '',
    created_by: 1,
    created_at: '',
    updated_at: '',
  },
  persons: [
    {
      id: '1', family_id: 'demo', first_name: 'Soekarno', last_name: 'Kusuma', nickname: 'Eyang Kakung',
      gender: 'male' as Gender, birth_date: '1922-03-15', birth_place: 'Yogyakarta',
      death_date: '1998-08-20', death_place: 'Yogyakarta', is_alive: false, photo_url: null,
      bio: '', occupation: 'Pegawai Negeri', education: null, email: null, phone: null, address: null,
      generation_level: 1, created_by: 1, created_at: '', updated_at: '',
    },
    {
      id: '2', family_id: 'demo', first_name: 'Kartini', last_name: 'Wulandari', nickname: 'Eyang Putri',
      gender: 'female' as Gender, birth_date: '1925-04-21', birth_place: 'Surakarta',
      death_date: '2005-12-10', death_place: 'Yogyakarta', is_alive: false, photo_url: null,
      bio: '', occupation: 'Guru', education: null, email: null, phone: null, address: null,
      generation_level: 1, created_by: 1, created_at: '', updated_at: '',
    },
    {
      id: '3', family_id: 'demo', first_name: 'Bambang', last_name: 'Kusuma', nickname: 'Pak De',
      gender: 'male' as Gender, birth_date: '1948-07-12', birth_place: 'Yogyakarta',
      death_date: null, death_place: null, is_alive: true, photo_url: null,
      bio: '', occupation: 'Insinyur', education: 'ITB', email: null, phone: null, address: null,
      generation_level: 2, created_by: 1, created_at: '', updated_at: '',
    },
    {
      id: '4', family_id: 'demo', first_name: 'Siti', last_name: 'Kusuma', nickname: 'Bu Lik',
      gender: 'female' as Gender, birth_date: '1950-11-25', birth_place: 'Yogyakarta',
      death_date: null, death_place: null, is_alive: true, photo_url: null,
      bio: '', occupation: 'Pengusaha', education: 'UGM', email: null, phone: null, address: null,
      generation_level: 2, created_by: 1, created_at: '', updated_at: '',
    },
    {
      id: '5', family_id: 'demo', first_name: 'Budi', last_name: 'Kusuma', nickname: 'Cucu',
      gender: 'male' as Gender, birth_date: '1975-03-28', birth_place: 'Jakarta',
      death_date: null, death_place: null, is_alive: true, photo_url: null,
      bio: '', occupation: 'Arsitek', education: 'ITB', email: null, phone: null, address: null,
      generation_level: 3, created_by: 1, created_at: '', updated_at: '',
    },
  ],
  relationships: [
    { id: 1, person_id: '1', related_person_id: '2', type: 'spouse' as RelationshipType, marriage_status: 'married' as MarriageStatus, marriage_date: '1945-08-17', marriage_place: 'Yogyakarta', divorce_date: null, notes: null, created_by: 1, created_at: '', updated_at: '' },
    { id: 2, person_id: '1', related_person_id: '3', type: 'parent' as RelationshipType, marriage_status: null, marriage_date: null, marriage_place: null, divorce_date: null, notes: null, created_by: 1, created_at: '', updated_at: '' },
    { id: 3, person_id: '2', related_person_id: '3', type: 'parent' as RelationshipType, marriage_status: null, marriage_date: null, marriage_place: null, divorce_date: null, notes: null, created_by: 1, created_at: '', updated_at: '' },
    { id: 4, person_id: '1', related_person_id: '4', type: 'parent' as RelationshipType, marriage_status: null, marriage_date: null, marriage_place: null, divorce_date: null, notes: null, created_by: 1, created_at: '', updated_at: '' },
    { id: 5, person_id: '2', related_person_id: '4', type: 'parent' as RelationshipType, marriage_status: null, marriage_date: null, marriage_place: null, divorce_date: null, notes: null, created_by: 1, created_at: '', updated_at: '' },
    { id: 6, person_id: '3', related_person_id: '5', type: 'parent' as RelationshipType, marriage_status: null, marriage_date: null, marriage_place: null, divorce_date: null, notes: null, created_by: 1, created_at: '', updated_at: '' },
  ],
  positions: [
    { id: 1, person_id: '1', family_id: 'demo', x: -120, y: 0, level: 1, order: 1, created_at: '', updated_at: '' },
    { id: 2, person_id: '2', family_id: 'demo', x: 120, y: 0, level: 1, order: 2, created_at: '', updated_at: '' },
    { id: 3, person_id: '3', family_id: 'demo', x: -120, y: 180, level: 2, order: 1, created_at: '', updated_at: '' },
    { id: 4, person_id: '4', family_id: 'demo', x: 120, y: 180, level: 2, order: 2, created_at: '', updated_at: '' },
    { id: 5, person_id: '5', family_id: 'demo', x: -120, y: 360, level: 3, order: 1, created_at: '', updated_at: '' },
  ],
  root_persons: [],
  statistics: { total_persons: 5, total_living: 3, total_deceased: 2, total_male: 3, total_female: 2, generations: 3, oldest_person: null, youngest_person: null, total_marriages: 1, average_children: 2, by_generation: {}, by_decade: {} },
};

const features = [
  {
    icon: TreeDeciduous,
    title: 'Pohon Keluarga Interaktif',
    description: 'Buat silsilah keluarga yang indah dengan tampilan visual drag-and-drop.',
  },
  {
    icon: Users,
    title: 'Kelola Anggota',
    description: 'Tambah dan kelola anggota keluarga dengan profil lengkap dan relasi.',
  },
  {
    icon: Shield,
    title: 'Aman & Privat',
    description: 'Data keluarga Anda dilindungi dengan keamanan tingkat enterprise.',
  },
  {
    icon: History,
    title: 'Abadikan Sejarah',
    description: 'Dokumentasikan cerita, foto, dan kenangan untuk generasi mendatang.',
  },
];

const LandingPage: React.FC = () => {
  return (
    <div className="min-h-screen bg-stone-50">
      {/* Navigation */}
      <nav className="bg-white/80 backdrop-blur-sm border-b border-stone-200 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            {/* Logo */}
            <div className="flex items-center gap-2">
              <div className="w-9 h-9 rounded-xl bg-amber-500 flex items-center justify-center shadow-lg shadow-amber-500/20">
                <TreeDeciduous className="w-5 h-5 text-white" />
              </div>
              <span className="text-xl font-bold text-stone-800">Guyub</span>
            </div>

            {/* Nav Links */}
            <div className="hidden md:flex items-center gap-8">
              <a href="#fitur" className="text-sm text-stone-600 hover:text-stone-900 transition-colors">
                Fitur
              </a>
              <a href="#demo" className="text-sm text-stone-600 hover:text-stone-900 transition-colors">
                Demo
              </a>
              <a href="#tentang" className="text-sm text-stone-600 hover:text-stone-900 transition-colors">
                Tentang
              </a>
            </div>

            {/* CTA */}
            <div className="flex items-center gap-3">
              <Link
                to="/login"
                className="px-4 py-2 text-sm font-medium text-stone-700 hover:text-stone-900 transition-colors"
              >
                Masuk
              </Link>
              <Link
                to="/login"
                className="px-4 py-2 text-sm font-medium text-white bg-stone-900 hover:bg-stone-800 rounded-lg transition-colors flex items-center gap-2"
              >
                Mulai Sekarang
                <ArrowRight className="w-4 h-4" />
              </Link>
            </div>
          </div>
        </div>
      </nav>

      {/* Hero Section with Family Tree */}
      <section id="demo" className="relative overflow-hidden min-h-[calc(100vh-64px)]">
        {/* Background Pattern */}
        <div className="absolute inset-0 opacity-5">
          <div
            className="absolute inset-0"
            style={{
              backgroundImage: `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='60' height='60' viewBox='0 0 60 60'%3E%3Cpath d='M30 10 L30 50 M30 25 L20 15 M30 25 L40 15 M30 35 L18 25 M30 35 L42 25' stroke='%23000000' stroke-width='1' fill='none'/%3E%3C/svg%3E")`,
              backgroundSize: '60px 60px',
            }}
          />
        </div>

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 lg:py-16 relative">
          <div className="grid lg:grid-cols-2 gap-8 lg:gap-12 items-center">
            {/* Left: Text Content */}
            <div className="text-center lg:text-left order-2 lg:order-1">
              {/* Badge */}
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-amber-100 text-amber-700 text-sm font-medium mb-6">
                <Sparkles className="w-4 h-4" />
                Platform Silsilah Keluarga
              </div>

              {/* Headline */}
              <h1 className="text-4xl sm:text-5xl lg:text-5xl xl:text-6xl font-bold text-stone-900 leading-tight mb-6">
                Abadikan Warisan
                <span className="text-amber-500"> Keluarga</span> Anda
              </h1>

              {/* Subheadline */}
              <p className="text-lg text-stone-600 mb-8 max-w-xl">
                Bangun pohon keluarga yang indah, kelola anggota, dan lestarikan sejarah keluarga
                untuk generasi mendatang. Hubungkan akar Anda dan bagikan warisan keluarga.
              </p>

              {/* CTA Buttons */}
              <div className="flex flex-col sm:flex-row items-center lg:items-start gap-4">
                <Link
                  to="/login"
                  className="w-full sm:w-auto px-8 py-3.5 text-base font-medium text-white bg-stone-900 hover:bg-stone-800 rounded-xl transition-all shadow-lg shadow-stone-900/20 flex items-center justify-center gap-2"
                >
                  Mulai Buat Pohon Keluarga
                  <ArrowRight className="w-5 h-5" />
                </Link>
                <Link
                  to="/demo/tree"
                  className="w-full sm:w-auto px-8 py-3.5 text-base font-medium text-stone-700 bg-white hover:bg-stone-50 border border-stone-200 rounded-xl transition-colors flex items-center justify-center gap-2"
                >
                  Lihat Demo Lengkap
                </Link>
              </div>

              {/* Stats */}
              <div className="mt-12 pt-8 border-t border-stone-200 grid grid-cols-3 gap-6">
                <div>
                  <p className="text-2xl font-bold text-stone-900">1000+</p>
                  <p className="text-sm text-stone-500">Keluarga</p>
                </div>
                <div>
                  <p className="text-2xl font-bold text-stone-900">50K+</p>
                  <p className="text-sm text-stone-500">Anggota</p>
                </div>
                <div>
                  <p className="text-2xl font-bold text-stone-900">5</p>
                  <p className="text-sm text-stone-500">Generasi</p>
                </div>
              </div>
            </div>

            {/* Right: Family Tree Preview */}
            <div className="order-1 lg:order-2">
              <div className="relative">
                {/* Decorative elements */}
                <div className="absolute -top-4 -right-4 w-24 h-24 bg-amber-200 rounded-full opacity-50 blur-2xl" />
                <div className="absolute -bottom-4 -left-4 w-32 h-32 bg-amber-300 rounded-full opacity-30 blur-3xl" />

                {/* Tree Container */}
                <div className="relative bg-gradient-to-br from-amber-50 to-orange-50 rounded-3xl shadow-2xl shadow-amber-200/50 border border-amber-100 overflow-hidden">
                  {/* Header */}
                  <div className="bg-white/80 backdrop-blur-sm border-b border-amber-100 px-6 py-4">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-amber-400 to-amber-600 flex items-center justify-center shadow-lg shadow-amber-400/30">
                          <TreeDeciduous className="w-5 h-5 text-white" />
                        </div>
                        <div>
                          <h3 className="font-semibold text-stone-800">Keluarga Kusuma</h3>
                          <p className="text-xs text-stone-500">Yogyakarta, Indonesia</p>
                        </div>
                      </div>
                      <div className="flex items-center gap-2">
                        <span className="px-2 py-1 bg-green-100 text-green-700 text-xs font-medium rounded-full">
                          5 Anggota
                        </span>
                        <span className="px-2 py-1 bg-amber-100 text-amber-700 text-xs font-medium rounded-full">
                          3 Generasi
                        </span>
                      </div>
                    </div>
                  </div>

                  {/* Family Tree Visualization with React Flow */}
                  <div className="h-[400px] relative">
                    <FamilyTree
                      data={demoFamily}
                      minimal={true}
                      isEditable={false}
                    />
                  </div>

                  {/* Footer */}
                  <div className="bg-white/80 backdrop-blur-sm border-t border-amber-100 px-6 py-4">
                    <div className="flex items-center justify-between">
                      <p className="text-sm text-stone-600">
                        Contoh silsilah keluarga interaktif
                      </p>
                      <Link
                        to="/demo/tree"
                        className="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-amber-500 hover:bg-amber-600 rounded-lg transition-colors shadow-lg shadow-amber-500/30"
                      >
                        Lihat Demo
                        <ArrowRight className="w-4 h-4" />
                      </Link>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="fitur" className="py-24 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl font-bold text-stone-900 mb-4">
              Semua yang Anda Butuhkan untuk Mengelola Sejarah Keluarga
            </h2>
            <p className="text-lg text-stone-600 max-w-2xl mx-auto">
              Fitur-fitur canggih yang dirancang untuk membantu Anda membangun, mengelola,
              dan melestarikan warisan keluarga dengan mudah.
            </p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            {features.map((feature, index) => (
              <div
                key={index}
                className="p-6 rounded-2xl bg-stone-50 hover:bg-stone-100 transition-colors group"
              >
                <div className="w-12 h-12 rounded-xl bg-amber-100 flex items-center justify-center mb-4 group-hover:bg-amber-200 transition-colors">
                  <feature.icon className="w-6 h-6 text-amber-600" />
                </div>
                <h3 className="text-lg font-semibold text-stone-900 mb-2">{feature.title}</h3>
                <p className="text-sm text-stone-600">{feature.description}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* About Section */}
      <section id="tentang" className="py-24 bg-stone-900 text-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid lg:grid-cols-2 gap-12 items-center">
            <div>
              <h2 className="text-3xl font-bold mb-6">Dibuat dengan Cinta untuk Keluarga</h2>
              <p className="text-stone-400 mb-6">
                Guyub (bahasa Jawa untuk "kebersamaan") adalah platform yang didedikasikan untuk
                membantu keluarga melestarikan sejarah mereka dan memperkuat ikatan lintas generasi.
              </p>
              <p className="text-stone-400 mb-8">
                Misi kami adalah membuat sejarah keluarga menjadi mudah diakses, indah, dan bermakna
                bagi semua orang. Baik Anda menelusuri akar atau mendokumentasikan warisan,
                Guyub siap membantu.
              </p>
              <div className="flex items-center gap-4">
                <Link
                  to="/login"
                  className="px-6 py-3 text-sm font-medium text-stone-900 bg-amber-500 hover:bg-amber-400 rounded-lg transition-colors"
                >
                  Mulai Gratis
                </Link>
              </div>
            </div>
            <div className="relative">
              <div className="aspect-square rounded-2xl bg-stone-800 flex items-center justify-center">
                <TreeDeciduous className="w-48 h-48 text-stone-700" />
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-24 bg-amber-50">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-3xl font-bold text-stone-900 mb-4">
            Siap Memulai Perjalanan Keluarga Anda?
          </h2>
          <p className="text-lg text-stone-600 mb-8">
            Bergabung dengan ribuan keluarga yang mempercayakan Guyub untuk melestarikan warisan mereka.
          </p>
          <Link
            to="/login"
            className="inline-flex items-center gap-2 px-8 py-4 text-base font-medium text-white bg-stone-900 hover:bg-stone-800 rounded-xl transition-all shadow-lg"
          >
            Buat Pohon Keluarga Anda
            <ArrowRight className="w-5 h-5" />
          </Link>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-white border-t border-stone-200 py-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex flex-col md:flex-row justify-between items-center gap-4">
            {/* Logo */}
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 rounded-lg bg-amber-500 flex items-center justify-center">
                <TreeDeciduous className="w-4 h-4 text-white" />
              </div>
              <span className="text-lg font-semibold text-stone-800">Guyub</span>
            </div>

            {/* Links */}
            <div className="flex items-center gap-6">
              <a href="#fitur" className="text-sm text-stone-500 hover:text-stone-700">
                Fitur
              </a>
              <a href="#tentang" className="text-sm text-stone-500 hover:text-stone-700">
                Tentang
              </a>
              <a
                href="https://github.com/jaroteko18/guyub"
                target="_blank"
                rel="noopener noreferrer"
                className="text-sm text-stone-500 hover:text-stone-700 flex items-center gap-1"
              >
                <Github className="w-4 h-4" />
                GitHub
              </a>
            </div>

            {/* Copyright */}
            <p className="text-sm text-stone-500 flex items-center gap-1">
              Dibuat dengan <Heart className="w-4 h-4 text-red-500 fill-red-500" /> di Indonesia
            </p>
          </div>
          <div className="mt-8 pt-8 border-t border-stone-100 text-center">
            <p className="text-xs text-stone-400">
              © {new Date().getFullYear()} Guyub Platform. Hak cipta dilindungi.
            </p>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default LandingPage;
