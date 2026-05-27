import { NextResponse } from "next/server";
import { createSupabaseAdminClient } from "@/lib/supabaseAdmin";

export const dynamic = "force-dynamic";

interface RouteContext {
  params: Promise<{
    token: string;
  }>;
}

export async function GET(_request: Request, { params }: RouteContext) {
  const { token } = await params;

  if (!token) {
    return NextResponse.json({ error: "Missing overlay token" }, { status: 400 });
  }

  let supabaseAdmin;

  try {
    supabaseAdmin = createSupabaseAdminClient();
  } catch {
    return NextResponse.json({ error: "Overlay API is not configured" }, { status: 500 });
  }

  const { data, error } = await supabaseAdmin
    .from("shiny_hunts")
    .select(
      [
        "pokemon_id",
        "pokemon_form_id",
        "pokemon_name",
        "hunt_name",
        "gender",
        "game",
        "encounters",
        "encounter_increment",
        "tracking_metric",
        "is_caught",
      ].join(","),
    )
    .eq("overlay_token", token)
    .maybeSingle();

  if (error) {
    console.error("Overlay API load failed", error);

    return NextResponse.json(
      {
        error: "Could not load overlay",
        ...(process.env.NODE_ENV === "development" ? { details: error.message } : {}),
      },
      { status: 500 },
    );
  }

  if (!data) {
    return NextResponse.json({ error: "Overlay not found" }, { status: 404 });
  }

  return NextResponse.json(data, {
    headers: {
      "Cache-Control": "no-store",
    },
  });
}
