#!/bin/bash
# Hot Zone Check — fires before Edit/Write tool calls.
# Warns when editing a component with historical issue cases so the engineer
# reads docs/issue-cases/INDEX.md and applies the relevant Takeaway rules first.

FILE_PATH=$(cat | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('file_path', d.get('path', '')))
except:
    print('')
" 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

MSG=""

# AppsFlyerRokuSDK.brs — IC-001 (logger), IC-002 (GetVersion), IC-003 (counter/first_open)
if echo "$FILE_PATH" | grep -qE "AppsFlyerRokuSDK\.brs"; then
  MSG="HOT ZONE — AppsFlyerRokuSDK.brs (core/launch/logger/fields): read docs/issue-cases/INDEX.md (IC-001, IC-002, IC-003) and apply GR-01/02/03/04 before writing code. Advance counters/flags only after a confirmed 200/202; guard tmp:/ reads with MatchFiles; validate device APIs."
fi

if [ -n "$MSG" ]; then
  echo "$MSG"
fi

exit 0
