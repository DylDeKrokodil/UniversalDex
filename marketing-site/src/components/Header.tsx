import type { NavItem } from '../content/siteContent';
import appIcon from '../assets/app-icon-universaldex.png';

type HeaderProps = {
  navigationItems: NavItem[];
};

export function Header({ navigationItems }: HeaderProps) {
  return (
    <header className="mx-auto flex w-full max-w-7xl items-center justify-between px-6 py-6 lg:px-10">
      <div className="flex items-center gap-3">
        <img
          src={appIcon}
          alt="UniversalDex app icon"
          className="h-14 w-14 rounded-3xl border border-white/10 object-cover shadow-[0_0_35px_rgba(244,81,30,0.22)]"
        />
        <div>
          <p className="font-display text-lg font-bold tracking-wide">UniversalDex</p>
          <p className="text-sm text-white/55">Shiny hunting, sharpened.</p>
        </div>
      </div>

      <nav className="hidden items-center gap-6 text-sm text-white/70 md:flex">
        {navigationItems.map((item) => (
          <a key={item.href} href={item.href} className="transition hover:text-white">
            {item.label}
          </a>
        ))}
      </nav>
    </header>
  );
}
