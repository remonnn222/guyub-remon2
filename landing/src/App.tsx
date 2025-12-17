import { motion } from 'framer-motion';
import {
  TreeDeciduous,
  Users,
  Shield,
  Share2,
  ChevronRight,
  Heart,
  History,
  Search,
  Menu,
  X,
  ArrowRight,
  Star,
  Sparkles,
} from 'lucide-react';
import { useState, useCallback, memo } from 'react';
import {
  ReactFlow,
  Background,
  useNodesState,
  useEdgesState,
  Handle,
  Position,
} from '@xyflow/react';
import '@xyflow/react/dist/style.css';
import './index.css';

// Admin URL - change this for production
const ADMIN_URL = 'http://localhost:3000';

// Animation variants
const fadeIn = {
  hidden: { opacity: 0, y: 10 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.4 } },
};

const stagger = {
  hidden: { opacity: 0 },
  visible: { opacity: 1, transition: { staggerChildren: 0.08 } },
};

// Navbar
function Navbar() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <nav className="fixed top-0 left-0 right-0 z-50 bg-white/95 backdrop-blur-sm border-b border-stone-100">
      <div className="max-w-6xl mx-auto px-4 sm:px-6">
        <div className="flex justify-between items-center h-14">
          <a href="#" className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-amber-500 to-amber-600 flex items-center justify-center">
              <TreeDeciduous className="w-4 h-4 text-white" />
            </div>
            <span className="text-lg font-semibold text-stone-800">Guyub</span>
          </a>

          <div className="hidden md:flex items-center gap-6">
            <a href="#fitur" className="text-sm text-stone-500 hover:text-stone-800 transition-colors">
              Fitur
            </a>
            <a href="#cara-kerja" className="text-sm text-stone-500 hover:text-stone-800 transition-colors">
              Cara Kerja
            </a>
            <a href="#testimoni" className="text-sm text-stone-500 hover:text-stone-800 transition-colors">
              Testimoni
            </a>
          </div>

          <div className="hidden md:flex items-center gap-3">
            <a
              href={`${ADMIN_URL}/login`}
              className="text-sm text-stone-600 hover:text-stone-800 font-medium"
            >
              Masuk
            </a>
            <a
              href={ADMIN_URL}
              className="px-4 py-2 text-sm font-medium text-white bg-stone-900 hover:bg-stone-800 rounded-lg transition-colors"
            >
              Mulai Gratis
            </a>
          </div>

          <button
            onClick={() => setIsOpen(!isOpen)}
            className="md:hidden p-2 text-stone-600 hover:bg-stone-100 rounded-lg"
          >
            {isOpen ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
          </button>
        </div>
      </div>

      {isOpen && (
        <motion.div
          initial={{ opacity: 0, height: 0 }}
          animate={{ opacity: 1, height: 'auto' }}
          className="md:hidden bg-white border-t border-stone-100"
        >
          <div className="px-4 py-3 space-y-1">
            <a href="#fitur" className="block py-2 text-sm text-stone-600">Fitur</a>
            <a href="#cara-kerja" className="block py-2 text-sm text-stone-600">Cara Kerja</a>
            <a href="#testimoni" className="block py-2 text-sm text-stone-600">Testimoni</a>
            <div className="pt-3 flex flex-col gap-2">
              <a href={`${ADMIN_URL}/login`} className="py-2 text-sm text-center text-stone-600 font-medium">Masuk</a>
              <a href={ADMIN_URL} className="py-2 text-sm text-center bg-stone-900 text-white rounded-lg font-medium">
                Mulai Gratis
              </a>
            </div>
          </div>
        </motion.div>
      )}
    </nav>
  );
}

// Hero Section
function HeroSection() {
  return (
    <section className="pt-24 pb-16 sm:pt-32 sm:pb-24">
      <div className="max-w-6xl mx-auto px-4 sm:px-6">
        <div className="grid lg:grid-cols-2 gap-12 lg:gap-16 items-center">
          <motion.div initial="hidden" animate="visible" variants={stagger} className="text-center lg:text-left">
            <motion.div
              variants={fadeIn}
              className="inline-flex items-center gap-1.5 px-3 py-1 bg-amber-50 border border-amber-200 rounded-full text-xs font-medium text-amber-700 mb-4"
            >
              <Sparkles className="w-3 h-3" />
              Menghubungkan Keluarga Indonesia
            </motion.div>

            <motion.h1
              variants={fadeIn}
              className="text-3xl sm:text-4xl font-bold text-stone-900 leading-tight mb-4"
            >
              Bangun Silsilah{' '}
              <span className="text-amber-600">Keluarga Anda</span>
            </motion.h1>

            <motion.p variants={fadeIn} className="text-stone-500 mb-6 max-w-md mx-auto lg:mx-0">
              Buat pohon keluarga yang indah, abadikan kenangan, dan hubungkan generasi.
              Wujudkan sejarah keluarga Anda dengan visualisasi interaktif.
            </motion.p>

            <motion.div variants={fadeIn} className="flex flex-col sm:flex-row gap-3 justify-center lg:justify-start">
              <a
                href={ADMIN_URL}
                className="inline-flex items-center justify-center gap-2 px-5 py-2.5 bg-stone-900 hover:bg-stone-800 text-white text-sm font-medium rounded-lg transition-colors"
              >
                Mulai Sekarang
                <ChevronRight className="w-4 h-4" />
              </a>
              <a
                href="#demo"
                className="inline-flex items-center justify-center gap-2 px-5 py-2.5 bg-white hover:bg-stone-50 text-stone-700 text-sm font-medium rounded-lg border border-stone-200 transition-colors"
              >
                Lihat Demo
              </a>
            </motion.div>

            <motion.div variants={fadeIn} className="mt-8 grid grid-cols-3 gap-4 max-w-sm mx-auto lg:mx-0">
              {[
                { number: '10K+', label: 'Keluarga' },
                { number: '500K+', label: 'Anggota' },
                { number: '99%', label: 'Kepuasan' },
              ].map((stat) => (
                <div key={stat.label} className="text-center lg:text-left">
                  <div className="text-xl font-bold text-stone-800">{stat.number}</div>
                  <div className="text-xs text-stone-400">{stat.label}</div>
                </div>
              ))}
            </motion.div>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.5, delay: 0.2 }}
            className="relative hidden lg:block"
          >
            <FamilyTreeIllustration />
          </motion.div>
        </div>
      </div>
    </section>
  );
}

// Silhouette avatar component
const SilhouetteAvatar = ({ gender, size, className }: { gender: 'male' | 'female'; size: number; className?: string }) => {
  const iconSize = size * 0.5;
  return (
    <div
      className={`flex items-center justify-center ${className}`}
      style={{ width: size, height: size }}
    >
      {gender === 'male' ? (
        <svg width={iconSize} height={iconSize} viewBox="0 0 24 24" fill="currentColor" className="text-white/90">
          <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
        </svg>
      ) : (
        <svg width={iconSize} height={iconSize} viewBox="0 0 24 24" fill="currentColor" className="text-white/90">
          <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
        </svg>
      )}
    </div>
  );
};

// Custom node component for family members with silhouette
const FamilyMemberNode = memo(({ data }: { data: { name: string; gender: 'male' | 'female'; bgColor: string; ring: string; highlight?: boolean; size: number; generation: 'grandparent' | 'parent' | 'child' } }) => {
  return (
    <div className="flex flex-col items-center">
      <Handle type="target" position={Position.Top} className="!bg-transparent !border-0 !w-0 !h-0" />
      <div
        className={`rounded-full shadow-md ring-2 ${data.ring} ${data.bgColor} ${
          data.highlight ? '!ring-4 !ring-amber-400 ring-offset-2' : ''
        }`}
        style={{ width: data.size, height: data.size }}
      >
        <SilhouetteAvatar gender={data.gender} size={data.size} />
      </div>
      {data.highlight && (
        <div className="mt-1 text-center">
          <div className="text-[10px] font-medium text-amber-600">{data.name}</div>
          <div className="text-[8px] text-amber-500 font-medium">(Anda)</div>
        </div>
      )}
      <Handle type="source" position={Position.Bottom} className="!bg-transparent !border-0 !w-0 !h-0" />
      <Handle type="source" position={Position.Left} id="left" className="!bg-transparent !border-0 !w-0 !h-0" />
      <Handle type="target" position={Position.Right} id="right" className="!bg-transparent !border-0 !w-0 !h-0" />
    </div>
  );
});

const nodeTypes = { familyMember: FamilyMemberNode };

// Family Tree Illustration using React Flow
function FamilyTreeIllustration() {
  // Node positions with silhouette avatars
  const initialNodes = [
    // Grandparents (Row 1) - Gray color
    {
      id: 'kakek',
      type: 'familyMember',
      position: { x: 160, y: 10 },
      data: {
        name: 'Kakek',
        gender: 'male' as const,
        bgColor: 'bg-stone-400',
        ring: 'ring-stone-300',
        size: 56,
        generation: 'grandparent' as const
      },
      draggable: false,
    },
    {
      id: 'nenek',
      type: 'familyMember',
      position: { x: 250, y: 10 },
      data: {
        name: 'Nenek',
        gender: 'female' as const,
        bgColor: 'bg-stone-400',
        ring: 'ring-stone-300',
        size: 56,
        generation: 'grandparent' as const
      },
      draggable: false,
    },
    // Parents (Row 2) - Blue color
    {
      id: 'dewi',
      type: 'familyMember',
      position: { x: 50, y: 120 },
      data: {
        name: 'Dewi',
        gender: 'female' as const,
        bgColor: 'bg-sky-400',
        ring: 'ring-sky-300',
        size: 50,
        generation: 'parent' as const
      },
      draggable: false,
    },
    {
      id: 'made',
      type: 'familyMember',
      position: { x: 130, y: 120 },
      data: {
        name: 'Made',
        gender: 'male' as const,
        bgColor: 'bg-sky-400',
        ring: 'ring-sky-300',
        size: 50,
        generation: 'parent' as const
      },
      draggable: false,
    },
    {
      id: 'umar',
      type: 'familyMember',
      position: { x: 330, y: 120 },
      data: {
        name: 'Umar',
        gender: 'male' as const,
        bgColor: 'bg-sky-400',
        ring: 'ring-sky-300',
        size: 50,
        generation: 'parent' as const
      },
      draggable: false,
    },
    // Children (Row 3) - Green color, except highlighted one
    {
      id: 'yudha',
      type: 'familyMember',
      position: { x: 20, y: 230 },
      data: {
        name: 'Yudha',
        gender: 'male' as const,
        bgColor: 'bg-amber-400',
        ring: 'ring-amber-300',
        size: 44,
        generation: 'child' as const,
        highlight: true
      },
      draggable: false,
    },
    {
      id: 'sari',
      type: 'familyMember',
      position: { x: 120, y: 230 },
      data: {
        name: 'Sari',
        gender: 'female' as const,
        bgColor: 'bg-emerald-400',
        ring: 'ring-emerald-300',
        size: 44,
        generation: 'child' as const
      },
      draggable: false,
    },
    {
      id: 'bayu',
      type: 'familyMember',
      position: { x: 290, y: 230 },
      data: {
        name: 'Bayu',
        gender: 'male' as const,
        bgColor: 'bg-emerald-400',
        ring: 'ring-emerald-300',
        size: 44,
        generation: 'child' as const
      },
      draggable: false,
    },
    {
      id: 'citra',
      type: 'familyMember',
      position: { x: 380, y: 230 },
      data: {
        name: 'Citra',
        gender: 'female' as const,
        bgColor: 'bg-emerald-400',
        ring: 'ring-emerald-300',
        size: 44,
        generation: 'child' as const
      },
      draggable: false,
    },
  ];

  // Edges (connections)
  const initialEdges = [
    // Marriage line between Kakek and Nenek
    { id: 'e-kakek-nenek', source: 'kakek', target: 'nenek', sourceHandle: 'left', targetHandle: 'right', type: 'straight', style: { stroke: '#a8a29e', strokeWidth: 2 } },
    // From grandparents to Dewi
    { id: 'e-kakek-dewi', source: 'kakek', target: 'dewi', type: 'smoothstep', style: { stroke: '#a8a29e', strokeWidth: 2 } },
    // From grandparents to Made
    { id: 'e-nenek-made', source: 'nenek', target: 'made', type: 'smoothstep', style: { stroke: '#a8a29e', strokeWidth: 2 } },
    // From grandparents to Umar
    { id: 'e-nenek-umar', source: 'nenek', target: 'umar', type: 'smoothstep', style: { stroke: '#a8a29e', strokeWidth: 2 } },
    // Marriage line between Dewi and Made
    { id: 'e-dewi-made', source: 'dewi', target: 'made', sourceHandle: 'left', targetHandle: 'right', type: 'straight', style: { stroke: '#fda4af', strokeWidth: 2 } },
    // From Dewi-Made to Yudha
    { id: 'e-dewi-yudha', source: 'dewi', target: 'yudha', type: 'smoothstep', style: { stroke: '#a8a29e', strokeWidth: 2 } },
    // From Dewi-Made to Sari
    { id: 'e-made-sari', source: 'made', target: 'sari', type: 'smoothstep', style: { stroke: '#a8a29e', strokeWidth: 2 } },
    // From Umar to Bayu
    { id: 'e-umar-bayu', source: 'umar', target: 'bayu', type: 'smoothstep', style: { stroke: '#a8a29e', strokeWidth: 2 } },
    // From Umar to Citra
    { id: 'e-umar-citra', source: 'umar', target: 'citra', type: 'smoothstep', style: { stroke: '#a8a29e', strokeWidth: 2 } },
  ];

  const [nodes] = useNodesState(initialNodes);
  const [edges] = useEdgesState(initialEdges);

  return (
    <div className="relative w-full h-[360px]">
      <div className="absolute inset-0 bg-gradient-to-br from-amber-50/80 to-stone-50 rounded-2xl border border-stone-200 overflow-hidden">
        <ReactFlow
          nodes={nodes}
          edges={edges}
          nodeTypes={nodeTypes}
          fitView
          fitViewOptions={{ padding: 0.2 }}
          panOnDrag={false}
          zoomOnScroll={false}
          zoomOnPinch={false}
          zoomOnDoubleClick={false}
          preventScrolling={false}
          nodesDraggable={false}
          nodesConnectable={false}
          elementsSelectable={false}
          proOptions={{ hideAttribution: true }}
        >
          <Background color="#d6d3d1" gap={20} size={1} />
        </ReactFlow>
      </div>

      {/* Legend */}
      <div className="absolute bottom-3 right-3 flex items-center gap-3 px-3 py-1.5 bg-white/80 rounded-lg backdrop-blur-sm z-10">
        <div className="flex items-center gap-1.5 text-[9px] text-stone-500">
          <div className="w-2.5 h-2.5 rounded-full bg-stone-400" />
          <span>Kakek/Nenek</span>
        </div>
        <div className="flex items-center gap-1.5 text-[9px] text-stone-500">
          <div className="w-2.5 h-2.5 rounded-full bg-sky-400" />
          <span>Orang Tua</span>
        </div>
        <div className="flex items-center gap-1.5 text-[9px] text-stone-500">
          <div className="w-2.5 h-2.5 rounded-full bg-emerald-400" />
          <span>Saudara</span>
        </div>
        <div className="flex items-center gap-1.5 text-[9px] text-stone-500">
          <div className="w-2.5 h-2.5 rounded-full bg-amber-400" />
          <span>Anda</span>
        </div>
      </div>
    </div>
  );
}

// Features Section
function FeaturesSection() {
  const features = [
    {
      icon: TreeDeciduous,
      title: 'Pohon Interaktif',
      description: 'Bangun silsilah keluarga dengan mudah menggunakan fitur drag-and-drop.',
    },
    {
      icon: Users,
      title: 'Kolaborasi',
      description: 'Undang anggota keluarga untuk berkontribusi secara real-time.',
    },
    {
      icon: Shield,
      title: 'Privasi Terjamin',
      description: 'Kontrol siapa yang dapat melihat data dengan pengaturan privasi.',
    },
    {
      icon: Share2,
      title: 'Mudah Dibagikan',
      description: 'Bagikan via link aman atau ekspor ke format PDF.',
    },
    {
      icon: History,
      title: 'Tampilan Timeline',
      description: 'Lihat sejarah keluarga dalam tampilan timeline interaktif.',
    },
    {
      icon: Search,
      title: 'Pencarian Cerdas',
      description: 'Temukan anggota keluarga dengan cepat berdasarkan nama atau data lainnya.',
    },
  ];

  return (
    <section id="fitur" className="py-16 bg-white">
      <div className="max-w-6xl mx-auto px-4 sm:px-6">
        <motion.div
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          variants={stagger}
          className="text-center mb-12"
        >
          <motion.h2 variants={fadeIn} className="text-2xl sm:text-3xl font-bold text-stone-900 mb-3">
            Semua yang Anda Butuhkan
          </motion.h2>
          <motion.p variants={fadeIn} className="text-stone-500 max-w-lg mx-auto">
            Fitur lengkap untuk membangun, berbagi, dan melestarikan sejarah keluarga Anda.
          </motion.p>
        </motion.div>

        <motion.div
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          variants={stagger}
          className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6"
        >
          {features.map((feature) => (
            <motion.div
              key={feature.title}
              variants={fadeIn}
              className="group p-5 rounded-xl bg-stone-50 hover:bg-white hover:shadow-md border border-transparent hover:border-stone-100 transition-all"
            >
              <div className="w-10 h-10 rounded-lg bg-amber-100 flex items-center justify-center mb-3 group-hover:bg-amber-500 transition-colors">
                <feature.icon className="w-5 h-5 text-amber-600 group-hover:text-white transition-colors" />
              </div>
              <h3 className="text-sm font-semibold text-stone-800 mb-1">{feature.title}</h3>
              <p className="text-xs text-stone-500">{feature.description}</p>
            </motion.div>
          ))}
        </motion.div>
      </div>
    </section>
  );
}

// How It Works
function HowItWorksSection() {
  const steps = [
    { step: 1, title: 'Buat Akun', description: 'Daftar dalam hitungan detik', icon: Users },
    { step: 2, title: 'Tambah Anggota', description: 'Mulai dari diri Anda sendiri', icon: TreeDeciduous },
    { step: 3, title: 'Undang Keluarga', description: 'Bagikan akses dengan mudah', icon: Share2 },
    { step: 4, title: 'Tumbuh Bersama', description: 'Lihat pohon keluarga berkembang', icon: Heart },
  ];

  return (
    <section id="cara-kerja" className="py-16 bg-stone-50">
      <div className="max-w-6xl mx-auto px-4 sm:px-6">
        <motion.div
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          variants={stagger}
          className="text-center mb-12"
        >
          <motion.h2 variants={fadeIn} className="text-2xl sm:text-3xl font-bold text-stone-900 mb-3">
            Mulai dalam Hitungan Menit
          </motion.h2>
          <motion.p variants={fadeIn} className="text-stone-500">
            Empat langkah sederhana untuk membangun pohon keluarga Anda.
          </motion.p>
        </motion.div>

        <motion.div
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          variants={stagger}
          className="grid sm:grid-cols-2 lg:grid-cols-4 gap-6"
        >
          {steps.map((step) => (
            <motion.div key={step.step} variants={fadeIn} className="text-center">
              <div className="relative w-14 h-14 mx-auto mb-3">
                <div className="w-14 h-14 rounded-full bg-white border border-stone-200 flex items-center justify-center shadow-sm">
                  <step.icon className="w-6 h-6 text-amber-500" />
                </div>
                <div className="absolute -top-1 -right-1 w-5 h-5 bg-stone-900 rounded-full flex items-center justify-center">
                  <span className="text-[10px] font-bold text-white">{step.step}</span>
                </div>
              </div>
              <h3 className="text-sm font-semibold text-stone-800 mb-1">{step.title}</h3>
              <p className="text-xs text-stone-500">{step.description}</p>
            </motion.div>
          ))}
        </motion.div>
      </div>
    </section>
  );
}

// Testimonials
function TestimonialsSection() {
  const testimonials = [
    {
      name: 'Ibu Kartini Wijaya',
      role: 'Ibu Rumah Tangga, Jakarta',
      image: 'https://images.unsplash.com/photo-1594744803329-e58b31de8bf5?w=150&h=150&fit=crop&crop=face',
      content: 'Guyub mengubah cara keluarga kami terhubung. Cucu-cucu saya sekarang bisa melihat warisan leluhur dengan mudah.',
      rating: 5,
    },
    {
      name: 'Pak Bambang Sutrisno',
      role: 'Pensiunan Guru, Yogyakarta',
      image: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
      content: 'Selama bertahun-tahun saya mengumpulkan catatan di buku. Guyub membantu saya mendigitalkan semuanya dengan indah.',
      rating: 5,
    },
    {
      name: 'Dewi Lestari',
      role: 'Profesional, Surabaya',
      image: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150&h=150&fit=crop&crop=face',
      content: 'Dengan keluarga besar Jawa, mencatat silsilah itu mustahil. Guyub membuat semuanya mudah dan bahkan menyenangkan!',
      rating: 5,
    },
  ];

  return (
    <section id="testimoni" className="py-16 bg-white">
      <div className="max-w-6xl mx-auto px-4 sm:px-6">
        <motion.div
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          variants={stagger}
          className="text-center mb-12"
        >
          <motion.h2 variants={fadeIn} className="text-2xl sm:text-3xl font-bold text-stone-900 mb-3">
            Dipercaya Ribuan Keluarga
          </motion.h2>
          <motion.p variants={fadeIn} className="text-stone-500">
            Lihat apa kata keluarga-keluarga tentang Guyub.
          </motion.p>
        </motion.div>

        <motion.div
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          variants={stagger}
          className="grid md:grid-cols-3 gap-6"
        >
          {testimonials.map((t) => (
            <motion.div
              key={t.name}
              variants={fadeIn}
              className="p-5 rounded-xl bg-stone-50 border border-stone-100"
            >
              <div className="flex gap-0.5 mb-3">
                {[...Array(t.rating)].map((_, i) => (
                  <Star key={i} className="w-3.5 h-3.5 text-amber-400 fill-amber-400" />
                ))}
              </div>
              <p className="text-xs text-stone-600 mb-4 leading-relaxed">"{t.content}"</p>
              <div className="flex items-center gap-3">
                <img
                  src={t.image}
                  alt={t.name}
                  className="w-10 h-10 rounded-full object-cover"
                />
                <div>
                  <div className="text-xs font-semibold text-stone-800">{t.name}</div>
                  <div className="text-[10px] text-stone-500">{t.role}</div>
                </div>
              </div>
            </motion.div>
          ))}
        </motion.div>
      </div>
    </section>
  );
}

// CTA Section
function CTASection() {
  return (
    <section className="py-16 bg-stone-900">
      <div className="max-w-3xl mx-auto px-4 sm:px-6 text-center">
        <motion.div initial="hidden" whileInView="visible" viewport={{ once: true }} variants={stagger}>
          <motion.h2 variants={fadeIn} className="text-xl sm:text-2xl font-bold text-white mb-3">
            Siap Memulai Perjalanan Keluarga Anda?
          </motion.h2>
          <motion.p variants={fadeIn} className="text-sm text-stone-400 mb-6 max-w-md mx-auto">
            Bergabunglah dengan ribuan keluarga yang melestarikan warisan mereka. Mulai gratis, tanpa kartu kredit.
          </motion.p>
          <motion.div variants={fadeIn} className="flex flex-col sm:flex-row gap-3 justify-center">
            <a
              href={ADMIN_URL}
              className="inline-flex items-center justify-center gap-2 px-5 py-2.5 bg-white text-stone-900 text-sm font-medium rounded-lg hover:bg-stone-100 transition-colors"
            >
              Mulai Gratis Sekarang
              <ArrowRight className="w-4 h-4" />
            </a>
            <a
              href="#demo"
              className="inline-flex items-center justify-center px-5 py-2.5 text-sm font-medium text-stone-400 hover:text-white border border-stone-700 hover:border-stone-600 rounded-lg transition-colors"
            >
              Lihat Demo
            </a>
          </motion.div>
        </motion.div>
      </div>
    </section>
  );
}

// Footer
function Footer() {
  return (
    <footer className="bg-stone-950 text-stone-400 py-12">
      <div className="max-w-6xl mx-auto px-4 sm:px-6">
        <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-8 mb-8">
          <div>
            <div className="flex items-center gap-2 mb-3">
              <div className="w-7 h-7 rounded-lg bg-amber-500 flex items-center justify-center">
                <TreeDeciduous className="w-4 h-4 text-white" />
              </div>
              <span className="text-sm font-semibold text-white">Guyub</span>
            </div>
            <p className="text-xs text-stone-500 leading-relaxed">
              Menghubungkan keluarga, melestarikan warisan, menyatukan generasi.
            </p>
          </div>

          <div>
            <h4 className="text-xs font-semibold text-white uppercase tracking-wider mb-3">Produk</h4>
            <ul className="space-y-2">
              {['Fitur', 'Keamanan', 'Bantuan'].map((item) => (
                <li key={item}><a href="#" className="text-xs hover:text-white transition-colors">{item}</a></li>
              ))}
            </ul>
          </div>

          <div>
            <h4 className="text-xs font-semibold text-white uppercase tracking-wider mb-3">Perusahaan</h4>
            <ul className="space-y-2">
              {['Tentang Kami', 'Blog', 'Karir'].map((item) => (
                <li key={item}><a href="#" className="text-xs hover:text-white transition-colors">{item}</a></li>
              ))}
            </ul>
          </div>

          <div>
            <h4 className="text-xs font-semibold text-white uppercase tracking-wider mb-3">Dukungan</h4>
            <ul className="space-y-2">
              {['Pusat Bantuan', 'Privasi', 'Syarat & Ketentuan'].map((item) => (
                <li key={item}><a href="#" className="text-xs hover:text-white transition-colors">{item}</a></li>
              ))}
            </ul>
          </div>
        </div>

        <div className="border-t border-stone-800 pt-6 flex flex-col sm:flex-row justify-between items-center gap-4">
          <p className="text-[10px] text-stone-600">
            © {new Date().getFullYear()} Guyub. Hak cipta dilindungi.
          </p>
          <div className="flex gap-4">
            {['twitter', 'github', 'instagram'].map((social) => (
              <a key={social} href="#" className="text-stone-600 hover:text-stone-400 transition-colors">
                <span className="sr-only">{social}</span>
                <div className="w-4 h-4 rounded-full bg-stone-800" />
              </a>
            ))}
          </div>
        </div>
      </div>
    </footer>
  );
}

// Main App
function App() {
  return (
    <div className="min-h-screen bg-white">
      <Navbar />
      <main>
        <HeroSection />
        <FeaturesSection />
        <HowItWorksSection />
        <TestimonialsSection />
        <CTASection />
      </main>
      <Footer />
    </div>
  );
}

export default App;
