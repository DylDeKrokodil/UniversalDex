import homepageScreenshot from '../assets/homepage.png';

export function DevicePreview() {
  return (
    <div className="relative flex items-center justify-center">
      <div className="absolute inset-auto h-72 w-72 rounded-full bg-ember-500/20 blur-3xl" />
      <div className="relative w-full max-w-[24rem] rounded-[3.6rem] bg-[linear-gradient(155deg,#4f4349_0%,#21191d_28%,#120d10_70%,#43373d_100%)] p-[10px] shadow-[0_36px_90px_rgba(0,0,0,0.52),inset_0_1px_0_rgba(255,255,255,0.18),inset_0_-1px_0_rgba(0,0,0,0.28)]">
        <div className="pointer-events-none absolute left-[4px] top-28 h-16 w-[3px] rounded-full bg-white/14" />
        <div className="pointer-events-none absolute left-[4px] top-48 h-24 w-[3px] rounded-full bg-white/14" />
        <div className="pointer-events-none absolute left-[4px] top-80 h-24 w-[3px] rounded-full bg-white/14" />
        <div className="pointer-events-none absolute right-[4px] top-56 h-28 w-[3px] rounded-full bg-white/14" />

        <div className="overflow-hidden rounded-[3rem] border border-black/35 bg-black shadow-[inset_0_0_0_1px_rgba(255,255,255,0.05)]">
          <img
            src={homepageScreenshot}
            alt="UniversalDex home screen showing the app dashboard"
            className="block aspect-[1320/2868] w-full object-cover object-top"
          />
        </div>
      </div>
    </div>
  );
}
