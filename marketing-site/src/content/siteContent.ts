export type NavItem = {
  label: string;
  href: string;
};

export type MetricItem = {
  value: string;
  label: string;
};

export type FeatureItem = {
  title: string;
  body: string;
};

export type HighlightItem = {
  title: string;
  body: string;
};

export type FAQItem = {
  question: string;
  answer: string;
};

export type ScreenshotItem = {
  title: string;
  description: string;
  imageAlt: string;
};

export type SocialProofItem = {
  kicker: string;
  title: string;
  body: string;
};

export const navigationItems: NavItem[] = [
  { label: 'Features', href: '#features' },
  { label: 'Screenshots', href: '#screenshots' },
  { label: 'Why it works', href: '#why' },
  { label: 'FAQ', href: '#faq' },
];

export const heroMetrics: MetricItem[] = [
  { value: '3 taps', label: 'to start a new hunt' },
  { value: '1 view', label: 'to scan active progress' },
  { value: '0 clutter', label: 'between you and the next encounter' },
];

export const featureCards: FeatureItem[] = [
  {
    title: 'Shiny hunts with momentum',
    body: 'Track active hunts, encounter counts, methods, and caught targets in one focused flow built for repetition.',
  },
  {
    title: 'Professional product framing',
    body: 'Reusable sections and consistent copy make the site feel intentional now and easier to expand later.',
  },
  {
    title: 'Built for collectors',
    body: 'A companion for players who care about progress, patterns, and the satisfaction of seeing every hunt take shape.',
  },
];

export const socialProofItems: SocialProofItem[] = [
  {
    kicker: 'Focused',
    title: 'A single clear conversion goal',
    body: 'The landing page is shaped around one priority: moving interested players into the founding Discord community.',
  },
  {
    kicker: 'Structured',
    title: 'Reusable components from the start',
    body: 'Instead of a one-off page, the site now has a component structure that supports future sections, screenshots, and launch content.',
  },
  {
    kicker: 'Branded',
    title: 'A sharper visual direction',
    body: 'The design keeps the warm collector energy of the app while presenting it with a more polished marketing tone.',
  },
];

export const productHighlights: HighlightItem[] = [
  {
    title: 'Focused shiny hunt tracking',
    body: 'Active and completed hunts stay easy to scan so the product supports the ritual instead of interrupting it.',
  },
  {
    title: 'Fast encounter logging',
    body: 'The experience is designed around repetition, helping players keep pace during long sessions.',
  },
  {
    title: 'Quick setup for each target',
    body: 'Game and method selection help new hunts start fast, which keeps the product approachable even for casual players.',
  },
  {
    title: 'A collector-first interface',
    body: 'The visual style feels like a crafted companion app rather than a generic tracking dashboard.',
  },
];

export const screenshotItems: ScreenshotItem[] = [
  {
    title: 'Your shiny hunts at a glance',
    description:
      'The hunt list keeps active goals and completed catches readable, warm, and motivating instead of dumping everything into a sterile tracker.',
    imageAlt: 'UniversalDex shiny hunt list screen showing active hunts and completed catches',
  },
  {
    title: 'Detailed progress for every target',
    description:
      'The detail view gives each hunt room to breathe, making encounter counts and capture progress feel like part of the journey.',
    imageAlt: 'UniversalDex shiny hunt detail screen for a Turtwig hunt',
  },
];

export const faqItems: FAQItem[] = [
  {
    question: 'Can this become a real production marketing site?',
    answer:
      'Yes. The page is now structured as a reusable React and Tailwind app, so adding more sections, routes, analytics, or forms will be straightforward.',
  },
  {
    question: 'What is the current launch offer?',
    answer:
      'The current primary call to action is a Discord invite for the first 100 members, giving early supporters a direct place to follow progress and shape the product.',
  },
  {
    question: 'Can we add screenshots from the app later?',
    answer:
      'Absolutely. The structure is ready for App Store badges, product screenshots, founder messaging, and a more detailed launch narrative.',
  },
  {
    question: 'Can this stay separate from the Swift app?',
    answer:
      'Yes. Keeping the site in its own folder makes deployment and marketing iteration much easier while the app evolves independently.',
  },
];
