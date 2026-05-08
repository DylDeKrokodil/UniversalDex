import type { FAQItem } from '../content/siteContent';

type FAQSectionProps = {
  items: FAQItem[];
};

export function FAQSection({ items }: FAQSectionProps) {
  return (
    <section id="faq" className="mx-auto max-w-5xl px-6 py-20 lg:px-10">
      <p className="font-display text-sm uppercase tracking-[0.32em] text-ember-300">FAQ</p>
      <div className="mt-6 grid gap-4">
        {items.map((item) => (
          <article key={item.question} className="rounded-3xl border border-white/8 bg-white/4 p-6">
            <h3 className="font-display text-xl font-bold text-white">{item.question}</h3>
            <p className="mt-3 leading-7 text-white/65">{item.answer}</p>
          </article>
        ))}
      </div>
    </section>
  );
}
