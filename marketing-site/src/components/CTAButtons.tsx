type CTAButtonsProps = {
  primaryLabel: string;
  primaryHref: string;
  secondaryLabel: string;
  secondaryHref: string;
  className?: string;
};

export function CTAButtons({
  primaryLabel,
  primaryHref,
  secondaryLabel,
  secondaryHref,
  className = '',
}: CTAButtonsProps) {
  return (
    <div className={`flex flex-col gap-4 sm:flex-row ${className}`.trim()}>
      <a
        href={primaryHref}
        target={primaryHref.startsWith('http') ? '_blank' : undefined}
        rel={primaryHref.startsWith('http') ? 'noreferrer' : undefined}
        className="inline-flex items-center justify-center rounded-full bg-ember-500 px-6 py-3 text-base font-semibold text-white shadow-[0_14px_40px_rgba(244,81,30,0.32)] transition hover:-translate-y-0.5 hover:bg-ember-400"
      >
        {primaryLabel}
      </a>
      <a
        href={secondaryHref}
        className="inline-flex items-center justify-center rounded-full border border-white/12 bg-white/6 px-6 py-3 text-base font-semibold text-white/90 backdrop-blur transition hover:border-white/25 hover:bg-white/10"
      >
        {secondaryLabel}
      </a>
    </div>
  );
}
