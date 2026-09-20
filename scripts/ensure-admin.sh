#!/bin/sh
# Ensure Strapi admin exists. Creates first admin if DB has none.
# Toggle via AUTO_CREATE_ADMIN in .env (true/false)

if [ "$AUTO_CREATE_ADMIN" != "true" ]; then
  echo "[admin-init] AUTO_CREATE_ADMIN is not 'true', skipping."
  exit 0
fi

echo "[admin-init] Waiting for Strapi app to be ready ..."
for i in $(seq 1 30); do
  code=$(curl -s -o /dev/null -w '%{http_code}' "$STRAPI_URL/admin/init" 2>/dev/null)
  if [ "$code" = "200" ]; then
    break
  fi
  sleep 2
done

init_json=$(curl -s "$STRAPI_URL/admin/init")
echo "[admin-init] init response: $init_json"

has_admin=$(echo "$init_json" | grep -o '"hasAdmin":[a-z]*' | cut -d':' -f2)
if [ "$has_admin" = "true" ]; then
  echo "[admin-init] Admin already exists, nothing to do."
  exit 0
fi

echo "[admin-init] No admin found, creating first admin ..."
curl -s -X POST "$STRAPI_URL/admin/register-admin" \
  -H 'Content-Type: application/json' \
  -d "{\"firstname\":\"Admin\",\"email\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASSWORD\"}"
echo ""
echo "[admin-init] Done."