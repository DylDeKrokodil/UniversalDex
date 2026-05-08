type LaunchCommunitySectionProps = {
  discordHref: string;
  secondaryHref: string;
};

export function LaunchCommunitySection({
  discordHref,
  secondaryHref,
}: LaunchCommunitySectionProps) {
  return (
    <section id="signup" className="mx-auto max-w-5xl px-6 py-6 lg:px-10">
      <div className="overflow-hidden rounded-[2.25rem] border border-ember-300/20 bg-[linear-gradient(135deg,rgba(244,81,30,0.22),rgba(147,216,255,0.12))] p-8 shadow-[0_24px_80px_rgba(0,0,0,0.25)]">
        <div className="max-w-2xl">
          <p className="font-display text-sm uppercase tracking-[0.32em] text-ember-100">Launch Community</p>
          <h2 className="mt-4 font-display text-3xl font-bold text-white sm:text-4xl">
            Join the first 100 members shaping UniversalDex
          </h2>
          <p className="mt-4 text-lg leading-8 text-white/78">
            Early members get a front-row seat for progress updates, product feedback, and the momentum leading into launch.
          </p>
        </div>

        <div className="mt-8 flex flex-col gap-3 sm:flex-row">
          <a
            href={discordHref}
            target="_blank"
            rel="noreferrer"
            className="inline-flex items-center justify-center rounded-full bg-white px-6 py-3 text-base font-semibold text-ink-950 transition hover:-translate-y-0.5"
          >
            Enter the Discord
          </a>
          <a
            href={secondaryHref}
            className="inline-flex items-center justify-center rounded-full border border-white/18 px-6 py-3 text-base font-semibold text-white/92 transition hover:bg-white/8"
          >
            See next steps
          </a>
        </div>
      </div>
    </section>
  );
}
