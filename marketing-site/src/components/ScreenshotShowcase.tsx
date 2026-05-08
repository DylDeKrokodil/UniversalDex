import type { ScreenshotItem } from '../content/siteContent';
import listScreenshot from '../assets/shiny-list.png';
import detailScreenshot from '../assets/shiny-hunt-turtwig.png';
import appIcon from '../assets/app-icon-universaldex.png';
import { SectionIntro } from './SectionIntro';

type ScreenshotShowcaseProps = {
  items: ScreenshotItem[];
};

const screenshotImages = [listScreenshot, detailScreenshot];

type IPhoneMockupProps = {
  imageSrc: string;
  imageAlt: string;
};

function IPhoneMockup({ imageSrc, imageAlt }: IPhoneMockupProps) {
  return (
    <div className="relative mx-auto w-full max-w-[22rem]">
      <div className="absolute inset-x-10 bottom-0 h-12 rounded-full bg-black/40 blur-2xl" />
      <div className="relative rounded-[3.6rem] bg-[linear-gradient(155deg,#4f4349_0%,#21191d_28%,#120d10_70%,#43373d_100%)] p-[10px] shadow-[0_36px_90px_rgba(0,0,0,0.52),inset_0_1px_0_rgba(255,255,255,0.18),inset_0_-1px_0_rgba(0,0,0,0.28)]">
        <div className="pointer-events-none absolute left-[4px] top-28 h-16 w-[3px] rounded-full bg-white/14" />
        <div className="pointer-events-none absolute left-[4px] top-48 h-24 w-[3px] rounded-full bg-white/14" />
        <div className="pointer-events-none absolute left-[4px] top-80 h-24 w-[3px] rounded-full bg-white/14" />
        <div className="pointer-events-none absolute right-[4px] top-56 h-28 w-[3px] rounded-full bg-white/14" />

        <div className="overflow-hidden rounded-[3rem] border border-black/35 bg-black shadow-[inset_0_0_0_1px_rgba(255,255,255,0.05)]">
          <img
            src={imageSrc}
            alt={imageAlt}
            className="block aspect-[603/1311] w-full object-cover object-top"
          />
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
        description="These screens show how UniversalDex keeps hunt tracking calm, readable, and satisfying during real shiny hunting sessions."
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
                <IPhoneMockup
                  imageSrc={screenshotImages[index]}
                  imageAlt={item.imageAlt}
                />
              </div>
              <figcaption className="mx-auto max-w-[22rem] px-2 pb-2 pt-5">
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
