type SectionIntroProps = {
  eyebrow: string;
  title: string;
  description: string;
};

export function SectionIntro({ eyebrow, title, description }: SectionIntroProps) {
  return (
    <div className="flex max-w-2xl flex-col gap-4">
      <p className="font-display text-sm uppercase tracking-[0.32em] text-ember-300">{eyebrow}</p>
      <h2 className="font-display text-3xl font-bold text-white sm:text-4xl">{title}</h2>
      <p className="text-lg leading-8 text-white/68">{description}</p>
    </div>
  );
}
