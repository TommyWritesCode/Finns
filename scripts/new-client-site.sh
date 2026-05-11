#!/usr/bin/env bash
set -euo pipefail

CLIENT_NAME="${1:-}"
TIER="${2:-Standard}"

if [[ -z "$CLIENT_NAME" ]]; then
  echo "Usage: ./scripts/new-client-site.sh \"Client Name\" [Starter|Standard|Plus]"
  exit 1
fi

ROOT="$(pwd)"
STARTER="docs/templates/starter"

mkdir -p docs docs/advice docs/rubrics content src memory

# Brief
if [[ ! -f docs/brief.md ]]; then
  cp docs/templates/brief.md docs/brief.md 2>/dev/null || true
  if [[ -f docs/brief.md ]]; then
    perl -0pi -e "s/<Client Name>/$CLIENT_NAME/g; s/- Tier: Starter \| Standard \| Plus/- Tier: $TIER/g" docs/brief.md
  else
    cat > docs/brief.md <<EOF
# Client Brief — $CLIENT_NAME

## Basics
- Client name: $CLIENT_NAME

## Tier
- Tier: $TIER
EOF
  fi
fi

# Session log + iteration state
[[ -f docs/session-log.md ]] || cp docs/templates/session-log.md docs/session-log.md 2>/dev/null || echo "# Session Log" > docs/session-log.md
[[ -f docs/iteration-state.json ]] || cp docs/templates/iteration-state.json docs/iteration-state.json 2>/dev/null || cat > docs/iteration-state.json <<'EOF'
{"max_iterations":2,"current_iteration":0,"qa_status":"not_started","grade_status":"not_started","deploy_status":"not_started","last_blocker":null}
EOF

mkdir -p docs/advice content src/components src/pages src/layouts src/data src/styles public

# Astro starter — copy only if no package.json yet.
if [[ ! -f package.json && -d "$STARTER" ]]; then
  echo "Seeding Astro starter from $STARTER"
  # Copy starter contents (not the directory itself) into project root.
  for entry in "$STARTER"/* "$STARTER"/.[!.]*; do
    [[ -e "$entry" ]] || continue
    rel="${entry#$STARTER/}"
    dest="$ROOT/$rel"
    if [[ -d "$entry" ]]; then
      mkdir -p "$dest"
      cp -R "$entry/." "$dest/"
    else
      mkdir -p "$(dirname "$dest")"
      cp "$entry" "$dest"
    fi
    echo "  + $rel"
  done

  # Personalize wrangler + package name.
  SLUG="$(echo "$CLIENT_NAME" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9' '-' | sed 's/-\+/-/g; s/^-//; s/-$//')"
  if [[ -f wrangler.toml ]]; then
    perl -0pi -e "s/^name = \"client-site\"/name = \"$SLUG-site\"/m" wrangler.toml
  fi
  if [[ -f package.json ]]; then
    perl -0pi -e "s/\"name\": \"client-site\"/\"name\": \"$SLUG-site\"/" package.json
  fi
fi

# Memory event log (consumed by memory-curator).
[[ -f memory/run-events.jsonl ]] || : > memory/run-events.jsonl

# Append session-start marker.
START_TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
printf '{"ts":"%s","kind":"session_start","client":"%s","tier":"%s"}\n' \
  "$START_TS" "$CLIENT_NAME" "$TIER" >> memory/run-events.jsonl

cat <<EOF

Initialized client workspace for: $CLIENT_NAME ($TIER)

Files seeded:
  docs/brief.md
  docs/iteration-state.json
  docs/session-log.md
  memory/run-events.jsonl
$( [[ -f package.json ]] && echo "  package.json + Astro starter" )

Next:
  1. Fill docs/brief.md with the client facts.
  2. Run \`npm install\` if you have not already.
  3. In Claude Code: /build-site
EOF
