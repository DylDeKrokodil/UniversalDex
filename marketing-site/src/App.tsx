import {
  faqItems,
  featureCards,
  heroMetrics,
  navigationItems,
  productHighlights,
  screenshotItems,
  socialProofItems,
} from './content/siteContent';
import { CTAButtons } from './components/CTAButtons';
import { DevicePreview } from './components/DevicePreview';
import { FAQSection } from './components/FAQSection';
import { FeatureGrid } from './components/FeatureGrid';
import { Footer } from './components/Footer';
import { Header } from './components/Header';
import { LaunchCommunitySection } from './components/LaunchCommunitySection';
import { ScreenshotShowcase } from './components/ScreenshotShowcase';
import { SectionIntro } from './components/SectionIntro';
import { WhySection } from './components/WhySection';

function App() {
  return (
    <div className="min-h-screen overflow-x-hidden bg-transparent text-cream-100">
      <div className="pointer-events-none absolute inset-x-0 top-0 -z-10 h-[38rem] bg-[radial-gradient(circle_at_top,_rgba(147,216,255,0.12),_transparent_28%),radial-gradient(circle_at_20%_20%,_rgba(255,115,57,0.22),_transparent_26%)]" />

      <Header navigationItems={navigationItems} />

      <main>
        <section className="mx-auto grid max-w-7xl gap-14 px-6 pb-24 pt-8 lg:grid-cols-[1.05fr_0.95fr] lg:px-10 lg:pb-32 lg:pt-14">
          <div className="max-w-2xl">
            <div className="inline-flex items-center gap-2 rounded-full border border-ember-400/25 bg-ember-400/10 px-4 py-2 text-sm text-ember-100 backdrop-blur">
              <span className="h-2 w-2 rounded-full bg-mint-300" />
              Built for hunters who want less friction and more focus
            </div>

            <h1 className="mt-6 font-display text-5xl font-bold leading-none text-white sm:text-6xl lg:text-7xl">
              Hunt smarter.
              <br />
              <span className="text-ember-300">Catch happier.</span>
            </h1>

            <p className="mt-6 max-w-xl text-lg leading-8 text-white/72 sm:text-xl">
              UniversalDex is a modern companion for shiny hunters and collectors who want a cleaner way to track progress, stay motivated, and keep every target in motion.
            </p>

            <CTAButtons
              primaryLabel="Join the first 100"
              primaryHref="https://discord.gg/j9qSKKgjTz"
              secondaryLabel="Explore the product"
              secondaryHref="#features"
              className="mt-8"
            />

            <div className="mt-10 grid gap-4 sm:grid-cols-3">
              {heroMetrics.map((metric) => (
                <div
                  key={metric.label}
                  className="rounded-3xl border border-white/8 bg-white/5 p-5 backdrop-blur-sm"
                >
                  <p className="font-display text-3xl font-bold text-white">{metric.value}</p>
                  <p className="mt-2 text-sm leading-6 text-white/60">{metric.label}</p>
                </div>
              ))}
            </div>
          </div>

          <DevicePreview />
        </section>

        <section id="features" className="mx-auto max-w-7xl px-6 py-8 lg:px-10">
          <SectionIntro
            eyebrow="Features"
            title="A product story with real structure behind it"
            description="This version is organized to scale: reusable sections, shared content, and a clean visual system that can grow into a full production marketing site."
          />
          <FeatureGrid items={featureCards} />
        </section>

        <section className="mx-auto max-w-7xl px-6 py-8 lg:px-10">
          <div className="grid gap-5 lg:grid-cols-3">
            {socialProofItems.map((item) => (
              <article
                key={item.title}
                className="rounded-[2rem] border border-white/8 bg-gradient-to-br from-white/8 to-white/[0.03] p-6 backdrop-blur-sm"
              >
                <p className="text-sm uppercase tracking-[0.24em] text-white/45">{item.kicker}</p>
                <h3 className="mt-3 font-display text-2xl font-bold text-white">{item.title}</h3>
                <p className="mt-3 leading-7 text-white/65">{item.body}</p>
              </article>
            ))}
          </div>
        </section>

        <ScreenshotShowcase items={screenshotItems} />

        <WhySection highlights={productHighlights} />

        <LaunchCommunitySection
          discordHref="https://discord.gg/j9qSKKgjTz"
          secondaryHref="#faq"
        />

        <FAQSection items={faqItems} />
      </main>

      <Footer />
    </div>
  );
}

export default App;
