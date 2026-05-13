#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: ./scripts/preview_delivery_sheet.sh <google-sheet-share-url>"
  exit 1
fi

SHARE_URL="$1"

python3 - "$SHARE_URL" <<'PYEOF'
import csv
import io
import re
import sys
import urllib.request
import urllib.parse

share_url = sys.argv[1].strip()
match = re.search(r"/spreadsheets/d/([^/]+)/", share_url)
if not match:
    print("Invalid Google Sheet URL")
    sys.exit(1)

sheet_id = match.group(1)
parsed = urllib.parse.urlparse(share_url)
query = urllib.parse.parse_qs(parsed.query)
gid = query.get("gid", ["0"])[0]
export_url = f"https://docs.google.com/spreadsheets/d/{sheet_id}/export?format=csv&gid={gid}"

req = urllib.request.Request(
    export_url,
    headers={"User-Agent": "Mozilla/5.0 Delivery Sheet Preview"},
)

with urllib.request.urlopen(req) as response:
    data = response.read().decode("utf-8")

reader = csv.DictReader(io.StringIO(data))
reader.fieldnames = [name.strip().lower() for name in reader.fieldnames]
required = ["shop", "customername", "phone", "location", "totalprice", "deliver_service"]
missing = [key for key in required if key not in reader.fieldnames]
if missing:
    print(f"Missing required columns: {', '.join(missing)}")
    sys.exit(1)

print(f"Export URL: {export_url}")
print("Rows:")
for index, row in enumerate(reader, start=2):
    customer = (row.get("customername") or "").strip()
    phone = (row.get("phone") or "").strip()
    location = (row.get("location") or "").strip()
    price = (row.get("totalprice") or "").strip()
    service = (row.get("deliver_service") or "").strip()
    shop = (row.get("shop") or "").strip()

    if not any([customer, phone, location, price, service, shop]):
        continue

    print(
        f"- {customer} | {phone} | {location} | {price} | {service} | {shop}"
    )
PYEOF
