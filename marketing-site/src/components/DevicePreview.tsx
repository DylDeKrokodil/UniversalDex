const chartHeights = [35, 58, 44, 76, 62, 84, 68, 92];

export function DevicePreview() {
  return (
    <div className="relative flex items-center justify-center">
      <div className="absolute inset-auto h-72 w-72 rounded-full bg-ember-500/20 blur-3xl" />
      <div className="relative w-full max-w-md rounded-[2rem] border border-white/10 bg-white/6 p-4 shadow-[0_30px_90px_rgba(0,0,0,0.4)] backdrop-blur-xl">
        <div className="rounded-[1.6rem] border border-white/10 bg-ink-900 p-4">
          <div className="flex items-center justify-between rounded-2xl bg-white/6 px-4 py-3">
            <div>
              <p className="text-xs uppercase tracking-[0.25em] text-white/45">Active Hunt</p>
              <p className="mt-1 font-display text-2xl font-bold text-white">Charmander</p>
            </div>
            <div className="rounded-full bg-ember-500/18 px-3 py-1 text-sm font-medium text-ember-200">
              Masuda
            </div>
          </div>

          <div className="mt-4 grid grid-cols-2 gap-3">
            <div className="rounded-2xl bg-gradient-to-br from-ember-500 to-ember-700 p-4">
              <p className="text-xs uppercase tracking-[0.22em] text-white/70">Encounters</p>
              <p className="mt-3 font-display text-4xl font-bold text-white">1,284</p>
            </div>
            <div className="rounded-2xl border border-white/8 bg-white/5 p-4">
              <p className="text-xs uppercase tracking-[0.22em] text-white/45">Target odds</p>
              <p className="mt-3 font-display text-4xl font-bold text-sky-300">1/512</p>
            </div>
          </div>

          <div className="mt-4 rounded-3xl border border-white/8 bg-white/4 p-4">
            <div className="flex items-end justify-between">
              <div>
                <p className="text-xs uppercase tracking-[0.22em] text-white/45">Session pace</p>
                <p className="mt-1 font-display text-2xl font-bold text-white">Fast and focused</p>
              </div>
              <p className="rounded-full bg-mint-300/18 px-3 py-1 text-sm font-medium text-mint-300">
                +82 today
              </p>
            </div>

            <div className="mt-5 flex h-28 items-end gap-2">
              {chartHeights.map((height) => (
                <div
                  key={height}
                  className="flex-1 rounded-t-full bg-gradient-to-t from-ember-600 to-ember-300/90"
                  style={{ height: `${height}%` }}
                />
              ))}
            </div>
          </div>

          <div className="mt-4 rounded-3xl border border-dashed border-white/10 bg-white/[0.03] p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="font-semibold text-white">Caught archive</p>
                <p className="mt-1 text-sm text-white/55">See completed hunts without losing today’s focus.</p>
              </div>
              <div className="rounded-full border border-white/10 px-3 py-1 text-sm text-white/70">
                24 saved
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
