import type { HighlightItem } from '../content/siteContent';
import { SectionIntro } from './SectionIntro';

type WhySectionProps = {
  highlights: HighlightItem[];
};

export function WhySection({ highlights }: WhySectionProps) {
  return (
    <section id="why" className="mx-auto grid max-w-7xl gap-8 px-6 py-20 lg:grid-cols-[0.9fr_1.1fr] lg:px-10">
      <div className="rounded-[2rem] border border-white/8 bg-gradient-to-br from-white/8 to-white/[0.03] p-7 backdrop-blur-sm">
        <SectionIntro
          eyebrow="Why it works"
          title="Built around the rhythm of shiny hunting"
          description="UniversalDex is easiest to understand when you see how every screen supports pace, progress, and that small hit of excitement every time a hunt moves forward."
        />
      </div>

      <div className="grid gap-4">
        {highlights.map((item) => (
          <div
            key={item.title}
            className="flex items-start gap-4 rounded-3xl border border-white/8 bg-white/4 px-5 py-4"
          >
            <div className="mt-1 h-3 w-3 rounded-full bg-ember-300 shadow-[0_0_20px_rgba(255,115,57,0.7)]" />
            <div>
              <p className="font-semibold text-white">{item.title}</p>
              <p className="mt-2 text-base leading-7 text-white/72">{item.body}</p>
            </div>
          </div>
        ))}
      </div>
    </section>
  );
}
