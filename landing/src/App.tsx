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
  Check,
  Sparkles,
} from 'lucide-react';
import { useState } from 'react';
import './index.css';

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
            <a href="#features" className="text-sm text-stone-500 hover:text-stone-800 transition-colors">
              Features
            </a>
            <a href="#how-it-works" className="text-sm text-stone-500 hover:text-stone-800 transition-colors">
              How It Works
            </a>
            <a href="#pricing" className="text-sm text-stone-500 hover:text-stone-800 transition-colors">
              Pricing
            </a>
          </div>

          <div className="hidden md:flex items-center gap-3">
            <a href="/admin/login" className="text-sm text-stone-600 hover:text-stone-800 font-medium">
              Sign In
            </a>
            <a
              href="/admin"
              className="px-4 py-2 text-sm font-medium text-white bg-stone-900 hover:bg-stone-800 rounded-lg transition-colors"
            >
              Get Started
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
            <a href="#features" className="block py-2 text-sm text-stone-600">Features</a>
            <a href="#how-it-works" className="block py-2 text-sm text-stone-600">How It Works</a>
            <a href="#pricing" className="block py-2 text-sm text-stone-600">Pricing</a>
            <div className="pt-3 flex flex-col gap-2">
              <a href="/admin/login" className="py-2 text-sm text-center text-stone-600 font-medium">Sign In</a>
              <a href="/admin" className="py-2 text-sm text-center bg-stone-900 text-white rounded-lg font-medium">
                Get Started
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
              Connecting Families Together
            </motion.div>

            <motion.h1
              variants={fadeIn}
              className="text-3xl sm:text-4xl font-bold text-stone-900 leading-tight mb-4"
            >
              Discover Your{' '}
              <span className="text-amber-600">Family Legacy</span>
            </motion.h1>

            <motion.p variants={fadeIn} className="text-stone-500 mb-6 max-w-md mx-auto lg:mx-0">
              Build beautiful family trees, preserve memories, and connect generations.
              Bring your family history to life with interactive visualizations.
            </motion.p>

            <motion.div variants={fadeIn} className="flex flex-col sm:flex-row gap-3 justify-center lg:justify-start">
              <a
                href="/admin"
                className="inline-flex items-center justify-center gap-2 px-5 py-2.5 bg-stone-900 hover:bg-stone-800 text-white text-sm font-medium rounded-lg transition-colors"
              >
                Start Your Tree
                <ChevronRight className="w-4 h-4" />
              </a>
              <a
                href="#demo"
                className="inline-flex items-center justify-center gap-2 px-5 py-2.5 bg-white hover:bg-stone-50 text-stone-700 text-sm font-medium rounded-lg border border-stone-200 transition-colors"
              >
                View Demo
              </a>
            </motion.div>

            <motion.div variants={fadeIn} className="mt-8 grid grid-cols-3 gap-4 max-w-sm mx-auto lg:mx-0">
              {[
                { number: '50K+', label: 'Families' },
                { number: '1M+', label: 'Members' },
                { number: '99%', label: 'Satisfaction' },
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

// Family Tree Illustration
function FamilyTreeIllustration() {
  const members = [
    { id: 1, name: 'G', x: 200, y: 40, size: 44, highlight: false },
    { id: 2, name: 'G', x: 280, y: 40, size: 44, highlight: false },
    { id: 3, name: 'D', x: 140, y: 140, size: 40 },
    { id: 4, name: 'M', x: 220, y: 140, size: 40 },
    { id: 5, name: 'U', x: 300, y: 140, size: 40 },
    { id: 6, name: 'Y', x: 100, y: 240, size: 36, highlight: true },
    { id: 7, name: 'S', x: 170, y: 240, size: 36 },
    { id: 8, name: 'B', x: 240, y: 240, size: 36 },
    { id: 9, name: 'C', x: 310, y: 240, size: 36 },
  ];

  const connections = [
    { from: 1, to: 3 }, { from: 1, to: 5 }, { from: 2, to: 3 }, { from: 2, to: 5 },
    { from: 3, to: 6 }, { from: 3, to: 7 }, { from: 4, to: 6 }, { from: 4, to: 7 },
    { from: 5, to: 8 }, { from: 5, to: 9 },
  ];

  return (
    <div className="relative w-full h-[340px]">
      <div className="absolute inset-0 bg-gradient-to-br from-amber-50 to-stone-50 rounded-2xl border border-stone-100 overflow-hidden">
        <div className="absolute inset-0 pattern-dots opacity-30" />
      </div>

      <svg className="absolute inset-0 w-full h-full" viewBox="0 0 420 340">
        {connections.map((conn, idx) => {
          const from = members.find((m) => m.id === conn.from)!;
          const to = members.find((m) => m.id === conn.to)!;
          return (
            <motion.line
              key={idx}
              x1={from.x}
              y1={from.y + from.size / 2}
              x2={to.x}
              y2={to.y - to.size / 2}
              stroke="#d4d4d4"
              strokeWidth="1.5"
              initial={{ pathLength: 0 }}
              animate={{ pathLength: 1 }}
              transition={{ duration: 0.8, delay: idx * 0.05 }}
            />
          );
        })}
      </svg>

      {members.map((member, idx) => (
        <motion.div
          key={member.id}
          initial={{ opacity: 0, scale: 0 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.3, delay: 0.2 + idx * 0.05 }}
          className="absolute flex flex-col items-center cursor-pointer group"
          style={{ left: member.x - member.size / 2, top: member.y - member.size / 2 }}
        >
          <div
            className={`rounded-full flex items-center justify-center shadow-sm transition-transform group-hover:scale-105 ${
              member.highlight
                ? 'bg-amber-500 ring-2 ring-amber-300'
                : 'bg-white border border-stone-200'
            }`}
            style={{ width: member.size, height: member.size }}
          >
            <span className={`text-sm font-semibold ${member.highlight ? 'text-white' : 'text-stone-600'}`}>
              {member.name}
            </span>
          </div>
        </motion.div>
      ))}
    </div>
  );
}

// Features Section
function FeaturesSection() {
  const features = [
    {
      icon: TreeDeciduous,
      title: 'Interactive Trees',
      description: 'Build visual family trees with drag-and-drop simplicity.',
    },
    {
      icon: Users,
      title: 'Collaborate',
      description: 'Invite family members to contribute in real-time.',
    },
    {
      icon: Shield,
      title: 'Privacy First',
      description: 'Control who sees what with granular permissions.',
    },
    {
      icon: Share2,
      title: 'Easy Sharing',
      description: 'Share via secure links or export to PDF.',
    },
    {
      icon: History,
      title: 'Timeline View',
      description: 'See your family history as an interactive timeline.',
    },
    {
      icon: Search,
      title: 'Smart Search',
      description: 'Find any family member instantly by any field.',
    },
  ];

  return (
    <section id="features" className="py-16 bg-white">
      <div className="max-w-6xl mx-auto px-4 sm:px-6">
        <motion.div
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          variants={stagger}
          className="text-center mb-12"
        >
          <motion.h2 variants={fadeIn} className="text-2xl sm:text-3xl font-bold text-stone-900 mb-3">
            Everything You Need
          </motion.h2>
          <motion.p variants={fadeIn} className="text-stone-500 max-w-lg mx-auto">
            Powerful features to build, share, and preserve your family history.
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
    { step: 1, title: 'Create Account', description: 'Sign up in seconds', icon: Users },
    { step: 2, title: 'Add Members', description: 'Start with yourself', icon: TreeDeciduous },
    { step: 3, title: 'Invite Family', description: 'Share access easily', icon: Share2 },
    { step: 4, title: 'Grow Together', description: 'Watch it flourish', icon: Heart },
  ];

  return (
    <section id="how-it-works" className="py-16 bg-stone-50">
      <div className="max-w-6xl mx-auto px-4 sm:px-6">
        <motion.div
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          variants={stagger}
          className="text-center mb-12"
        >
          <motion.h2 variants={fadeIn} className="text-2xl sm:text-3xl font-bold text-stone-900 mb-3">
            Get Started in Minutes
          </motion.h2>
          <motion.p variants={fadeIn} className="text-stone-500">
            Four simple steps to build your family tree.
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

// Pricing Section
function PricingSection() {
  const plans = [
    {
      name: 'Free',
      price: 'Rp 0',
      period: 'forever',
      description: 'Perfect for getting started',
      features: ['Up to 50 members', '1 family tree', 'Basic views', 'Community support'],
      cta: 'Start Free',
      popular: false,
    },
    {
      name: 'Family',
      price: 'Rp 99K',
      period: '/month',
      description: 'Best for growing families',
      features: ['Unlimited members', 'Up to 5 trees', 'Advanced views', 'Photo galleries', 'Export PDF', 'Priority support'],
      cta: 'Get Started',
      popular: true,
    },
    {
      name: 'Clan',
      price: 'Rp 249K',
      period: '/month',
      description: 'For large extended families',
      features: ['Everything in Family', 'Unlimited trees', 'Custom branding', 'DNA integration', 'API access', 'Dedicated support'],
      cta: 'Contact Us',
      popular: false,
    },
  ];

  return (
    <section id="pricing" className="py-16 bg-white">
      <div className="max-w-5xl mx-auto px-4 sm:px-6">
        <motion.div
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          variants={stagger}
          className="text-center mb-12"
        >
          <motion.h2 variants={fadeIn} className="text-2xl sm:text-3xl font-bold text-stone-900 mb-3">
            Simple Pricing
          </motion.h2>
          <motion.p variants={fadeIn} className="text-stone-500">
            Choose the perfect plan. No hidden fees.
          </motion.p>
        </motion.div>

        <motion.div
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          variants={stagger}
          className="grid md:grid-cols-3 gap-6"
        >
          {plans.map((plan) => (
            <motion.div
              key={plan.name}
              variants={fadeIn}
              className={`relative p-6 rounded-xl ${
                plan.popular
                  ? 'bg-stone-900 text-white ring-2 ring-amber-500'
                  : 'bg-stone-50 border border-stone-100'
              }`}
            >
              {plan.popular && (
                <div className="absolute -top-2.5 left-1/2 -translate-x-1/2 px-2.5 py-0.5 bg-amber-500 text-[10px] font-semibold text-white rounded-full uppercase tracking-wide">
                  Popular
                </div>
              )}
              <div className="mb-4">
                <h3 className={`text-sm font-semibold ${plan.popular ? 'text-white' : 'text-stone-800'}`}>
                  {plan.name}
                </h3>
                <div className="mt-1 flex items-baseline gap-1">
                  <span className={`text-2xl font-bold ${plan.popular ? 'text-white' : 'text-stone-900'}`}>
                    {plan.price}
                  </span>
                  <span className={`text-xs ${plan.popular ? 'text-stone-400' : 'text-stone-500'}`}>
                    {plan.period}
                  </span>
                </div>
                <p className={`mt-1 text-xs ${plan.popular ? 'text-stone-400' : 'text-stone-500'}`}>
                  {plan.description}
                </p>
              </div>

              <ul className="space-y-2 mb-5">
                {plan.features.map((feature) => (
                  <li key={feature} className="flex items-center gap-2 text-xs">
                    <Check className={`w-3.5 h-3.5 ${plan.popular ? 'text-amber-400' : 'text-amber-500'}`} />
                    <span className={plan.popular ? 'text-stone-300' : 'text-stone-600'}>{feature}</span>
                  </li>
                ))}
              </ul>

              <button
                className={`w-full py-2 text-sm font-medium rounded-lg transition-colors ${
                  plan.popular
                    ? 'bg-white text-stone-900 hover:bg-stone-100'
                    : 'bg-stone-900 text-white hover:bg-stone-800'
                }`}
              >
                {plan.cta}
              </button>
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
      name: 'Ibu Kartini',
      role: 'Family Historian',
      avatar: 'K',
      content: 'Guyub transformed how our family connects. My grandchildren can now see their heritage come alive.',
      rating: 5,
    },
    {
      name: 'Pak Bambang',
      role: 'Retired Teacher',
      avatar: 'B',
      content: 'I spent years collecting records in notebooks. Guyub helped me digitize everything beautifully.',
      rating: 5,
    },
    {
      name: 'Dewi Lestari',
      role: 'Professional',
      avatar: 'D',
      content: "With a large Javanese family, keeping track was impossible. Guyub made it easy and even fun!",
      rating: 5,
    },
  ];

  return (
    <section id="testimonials" className="py-16 bg-stone-50">
      <div className="max-w-6xl mx-auto px-4 sm:px-6">
        <motion.div
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          variants={stagger}
          className="text-center mb-12"
        >
          <motion.h2 variants={fadeIn} className="text-2xl sm:text-3xl font-bold text-stone-900 mb-3">
            Loved by Families
          </motion.h2>
          <motion.p variants={fadeIn} className="text-stone-500">
            See what families are saying about Guyub.
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
              className="p-5 rounded-xl bg-white border border-stone-100"
            >
              <div className="flex gap-0.5 mb-3">
                {[...Array(t.rating)].map((_, i) => (
                  <Star key={i} className="w-3.5 h-3.5 text-amber-400 fill-amber-400" />
                ))}
              </div>
              <p className="text-xs text-stone-600 mb-4 leading-relaxed">"{t.content}"</p>
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-full bg-amber-100 flex items-center justify-center text-amber-700 text-xs font-semibold">
                  {t.avatar}
                </div>
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
            Ready to Start Your Family Journey?
          </motion.h2>
          <motion.p variants={fadeIn} className="text-sm text-stone-400 mb-6 max-w-md mx-auto">
            Join thousands of families preserving their legacy. Start free, no credit card required.
          </motion.p>
          <motion.div variants={fadeIn} className="flex flex-col sm:flex-row gap-3 justify-center">
            <a
              href="/admin"
              className="inline-flex items-center justify-center gap-2 px-5 py-2.5 bg-white text-stone-900 text-sm font-medium rounded-lg hover:bg-stone-100 transition-colors"
            >
              Get Started Free
              <ArrowRight className="w-4 h-4" />
            </a>
            <a
              href="#demo"
              className="inline-flex items-center justify-center px-5 py-2.5 text-sm font-medium text-stone-400 hover:text-white border border-stone-700 hover:border-stone-600 rounded-lg transition-colors"
            >
              Watch Demo
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
              Connecting families, preserving legacies, bringing generations together.
            </p>
          </div>

          <div>
            <h4 className="text-xs font-semibold text-white uppercase tracking-wider mb-3">Product</h4>
            <ul className="space-y-2">
              {['Features', 'Pricing', 'Security'].map((item) => (
                <li key={item}><a href="#" className="text-xs hover:text-white transition-colors">{item}</a></li>
              ))}
            </ul>
          </div>

          <div>
            <h4 className="text-xs font-semibold text-white uppercase tracking-wider mb-3">Company</h4>
            <ul className="space-y-2">
              {['About', 'Blog', 'Careers'].map((item) => (
                <li key={item}><a href="#" className="text-xs hover:text-white transition-colors">{item}</a></li>
              ))}
            </ul>
          </div>

          <div>
            <h4 className="text-xs font-semibold text-white uppercase tracking-wider mb-3">Support</h4>
            <ul className="space-y-2">
              {['Help Center', 'Privacy', 'Terms'].map((item) => (
                <li key={item}><a href="#" className="text-xs hover:text-white transition-colors">{item}</a></li>
              ))}
            </ul>
          </div>
        </div>

        <div className="border-t border-stone-800 pt-6 flex flex-col sm:flex-row justify-between items-center gap-4">
          <p className="text-[10px] text-stone-600">
            © {new Date().getFullYear()} Guyub. All rights reserved.
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
        <PricingSection />
        <TestimonialsSection />
        <CTASection />
      </main>
      <Footer />
    </div>
  );
}

export default App;
