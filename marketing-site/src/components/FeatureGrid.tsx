import type { FeatureItem } from '../content/siteContent';

type FeatureGridProps = {
  items: FeatureItem[];
};

export function FeatureGrid({ items }: FeatureGridProps) {
  return (
    <div className="mt-10 grid gap-5 lg:grid-cols-3">
      {items.map((card, index) => (
        <article
          key={card.title}
          className="rounded-[2rem] border border-white/8 bg-white/5 p-6 backdrop-blur-sm transition hover:-translate-y-1 hover:border-ember-300/35"
        >
          <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-ember-500/14 font-display text-lg font-bold text-ember-200">
            0{index + 1}
          </div>
          <h3 className="mt-5 font-display text-2xl font-bold text-white">{card.title}</h3>
          <p className="mt-3 leading-7 text-white/64">{card.body}</p>
        </article>
      ))}
    </div>
  );
}
