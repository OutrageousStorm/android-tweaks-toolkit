#!/bin/bash
# batch_permission_revoke.sh -- Revoke permissions from multiple apps matching a pattern
# Usage: ./batch_permission_revoke.sh google CAMERA LOCATION
#        ./batch_permission_revoke.sh facebook READ_CONTACTS GET_ACCOUNTS

PATTERN="${1:?Usage: $0 <package-pattern> <perm1> <perm2> ...}"
shift
PERMS=("$@")

[[ ${#PERMS[@]} -eq 0 ]] && { echo "No permissions specified"; exit 1; }

echo "🔐 Batch Permission Revoker"
echo "Pattern: $PATTERN"
echo "Permissions: ${PERMS[@]}"
echo ""

PKGS=$(adb shell pm list packages | grep "$PATTERN" | sed 's/package://')
COUNT=$(echo "$PKGS" | wc -l)
echo "Found $COUNT matching packages\n"

REVOKED=0
for pkg in $PKGS; do
    for perm in "${PERMS[@]}"; do
        full_perm="android.permission.$perm"
        result=$(adb shell pm revoke "$pkg" "$full_perm" 2>&1)
        if [ $? -eq 0 ]; then
            echo "  ✓ $pkg: $perm"
            ((REVOKED++))
        fi
    done
done

echo ""
echo "✅ Revoked $REVOKED permission(s)"
