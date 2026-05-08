import type { ScreenshotItem } from '../content/siteContent';
import listScreenshot from '../assets/shiny-list.png';
import detailScreenshot from '../assets/shiny-hunt-turtwig.png';
import appIcon from '../assets/app-icon-universaldex.png';
import { SectionIntro } from './SectionIntro';

type ScreenshotShowcaseProps = {
  items: ScreenshotItem[];
};

const screenshotImages = [listScreenshot, detailScreenshot];

type PhoneMockupProps = {
  imageSrc: string;
  imageAlt: string;
};

function PhoneMockup({ imageSrc, imageAlt }: PhoneMockupProps) {
  return (
    <div className="relative mx-auto w-full max-w-[22rem]">
      <div className="absolute inset-x-10 top-4 h-8 rounded-full bg-white/8 blur-xl" />
      <div className="relative rounded-[3.4rem] bg-[linear-gradient(160deg,#3f353a_0%,#1c1618_45%,#0f0b0d_100%)] p-[10px] shadow-[0_30px_80px_rgba(0,0,0,0.45),inset_0_1px_0_rgba(255,255,255,0.14)]">
        <div className="pointer-events-none absolute inset-y-24 left-[5px] w-[3px] rounded-full bg-white/10" />
        <div className="pointer-events-none absolute inset-y-32 right-[5px] w-[3px] rounded-full bg-white/10" />
        <div className="relative overflow-hidden rounded-[2.9rem] border border-black/30 bg-black shadow-[inset_0_0_0_1px_rgba(255,255,255,0.05)]">
          <div className="pointer-events-none absolute inset-x-0 top-0 z-20 flex justify-center pt-3">
            <div className="h-8 w-40 rounded-full bg-black shadow-[inset_0_-1px_0_rgba(255,255,255,0.05)]" />
          </div>
          <div className="pointer-events-none absolute left-1/2 top-2 z-20 h-1.5 w-16 -translate-x-1/2 rounded-full bg-white/8 blur-[1px]" />
          <img
            src={imageSrc}
            alt={imageAlt}
            className="block aspect-[603/1311] w-full object-cover object-top"
          />
          <div className="pointer-events-none absolute inset-x-0 top-0 h-24 bg-[linear-gradient(180deg,rgba(255,255,255,0.06),transparent)]" />
          <div className="pointer-events-none absolute inset-x-0 bottom-0 h-12 bg-[linear-gradient(0deg,rgba(0,0,0,0.22),transparent)]" />
        </div>
      </div>
    </div>
  );
}

export function ScreenshotShowcase({ items }: ScreenshotShowcaseProps) {
  return (
    <section id="screenshots" className="mx-auto max-w-7xl px-6 py-20 lg:px-10">
      <SectionIntro
        eyebrow="Screenshots"
        title="The real product now leads the story"
        description="These screens give the landing page actual product proof and help the site feel grounded in what UniversalDex already does well."
      />

      <div className="mt-10 grid gap-8 xl:grid-cols-[0.9fr_1.1fr]">
        <div className="rounded-[2rem] border border-white/8 bg-gradient-to-br from-white/8 to-white/[0.03] p-6 backdrop-blur-sm">
          <div className="flex items-center gap-4">
            <img
              src={appIcon}
              alt="UniversalDex icon"
              className="h-16 w-16 rounded-[1.4rem] border border-white/10 object-cover shadow-[0_18px_50px_rgba(0,0,0,0.22)]"
            />
            <div>
              <p className="font-display text-2xl font-bold text-white">UniversalDex</p>
              <p className="mt-1 text-white/60">A focused companion for hunters who care about momentum.</p>
            </div>
          </div>

          <div className="mt-8 space-y-4">
            {items.map((item, index) => (
              <article
                key={item.title}
                className="rounded-3xl border border-white/8 bg-white/4 p-5 transition hover:border-ember-300/25 hover:bg-white/6"
              >
                <p className="text-sm uppercase tracking-[0.24em] text-ember-300">Screen 0{index + 1}</p>
                <h3 className="mt-3 font-display text-2xl font-bold text-white">{item.title}</h3>
                <p className="mt-3 leading-7 text-white/68">{item.description}</p>
              </article>
            ))}
          </div>
        </div>

        <div className="grid gap-8 lg:grid-cols-2">
          {items.map((item, index) => (
            <figure
              key={item.title}
              className="group"
            >
              <div className="transition duration-300 group-hover:-translate-y-1 group-hover:scale-[1.01]">
                <PhoneMockup
                  imageSrc={screenshotImages[index]}
                  imageAlt={item.imageAlt}
                />
              </div>
              <figcaption className="mx-auto mt-5 max-w-[22rem] px-1">
                <p className="font-display text-2xl font-bold text-white">{item.title}</p>
                <p className="mt-2 text-base leading-7 text-white/58">{item.description}</p>
              </figcaption>
            </figure>
          ))}
        </div>
      </div>
    </section>
  );
}
