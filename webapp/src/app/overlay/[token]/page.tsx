import OverlayClient from "./OverlayClient";
import { parseOverlayOptions } from "@/features/shiny-hunts/utils/overlayOptions";

interface PageProps {
  params: Promise<{
    token: string;
  }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}

export default async function OverlayPage({ params, searchParams }: PageProps) {
  const { token } = await params;
  const resolvedSearchParams = await searchParams;
  const options = parseOverlayOptions(resolvedSearchParams);

  return <OverlayClient token={token} options={options} />;
}
