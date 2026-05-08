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
    title: 'Made for long sessions',
    body: 'UniversalDex keeps the important details visible so you can stay in rhythm through chain hunting, resets, and repeat encounters.',
  },
  {
    title: 'Built for collectors',
    body: 'A companion for players who care about progress, patterns, and the satisfaction of seeing every hunt take shape.',
  },
];

export const socialProofItems: SocialProofItem[] = [
  {
    kicker: 'Focused',
    title: 'Everything points back to the hunt',
    body: 'The product is designed to keep your active targets, odds, and progress close at hand without overwhelming the screen.',
  },
  {
    kicker: 'Motivating',
    title: 'Progress you actually want to check',
    body: 'A warm visual language and clear progress surfaces make every session feel like it is moving somewhere meaningful.',
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
    question: 'What is UniversalDex for?',
    answer:
      'UniversalDex is built for shiny hunters and collectors who want a cleaner, more motivating way to track hunts, odds, and completed catches.',
  },
  {
    question: 'What is the current launch offer?',
    answer:
      'The current primary call to action is a Discord invite for the first 100 members, giving early supporters a direct place to follow progress and shape the product.',
  },
  {
    question: 'What can early members expect?',
    answer:
      'Early members get product updates, a closer look at features in progress, and a chance to influence the direction of the app before wider launch.',
  },
  {
    question: 'What makes it different from a generic tracker?',
    answer:
      'UniversalDex is built around the feeling of shiny hunting itself, with a calmer interface, clearer progress views, and a collector-first visual style.',
  },
];
