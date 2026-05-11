export function formatDuration(seconds: number): String {
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = Math.floor(seconds % 60);

  if (h > 0) {
    return `${h}h ${m.toString().padStart(2, '0')}m ${s.toString().padStart(2, '0')}s`;
  } else if (m > 0) {
    return `${m}m ${s.toString().padStart(2, '0')}s`;
  } else {
    return `${s}s`;
  }
}
