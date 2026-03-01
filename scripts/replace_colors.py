#!/usr/bin/env python3
"""
Bulk dark-mode color replacement for Machinify home pages.
Replaces hardcoded semantic colors with context.cs.* equivalents.
Brand / accent / gradient colors are preserved.
"""
import re, sys

FILES = [
    "/Users/ahmedashraf/Antegravity/FailurePredectiveSystmeMobileApp/lib/Screens/engineer_home_page.dart",
    "/Users/ahmedashraf/Antegravity/FailurePredectiveSystmeMobileApp/lib/Screens/employee_home_page.dart",
    "/Users/ahmedashraf/Antegravity/FailurePredectiveSystmeMobileApp/lib/Screens/manager_home_page.dart",
]

# ── Exact hex replacements ────────────────────────────────────────────────────
HEX_MAP = {
    # Primary text
    "Color(0xFF1A1A1A)": "context.cs.onSurface",
    "Color(0xFF2A2A2A)": "context.cs.onSurface",
    "Color(0xFF333333)": "context.cs.onSurface",
    # Secondary / hint text
    "Color(0xFF888888)": "context.cs.onSurfaceVariant",
    "Color(0xFF999999)": "context.cs.onSurfaceVariant",
    "Color(0xFF555555)": "context.cs.onSurfaceVariant",
    "Color(0xFF444444)": "context.cs.onSurfaceVariant",
    "Color(0xFFBBBBBB)": "context.cs.onSurfaceVariant",
    "Color(0xFFAAAAAA)": "context.cs.onSurfaceVariant",
    # Borders / dividers
    "Color(0xFFEEEEEE)": "context.cs.outline",
    "Color(0xFFE0E0E0)": "context.cs.outline",
    "Color(0xFFDDDDDD)": "context.cs.outline",
    "Color(0xFFE8E8E8)": "context.cs.outline",
    # Input / subtle fills
    "Color(0xFFF8F8F8)": "context.cs.surfaceContainerHighest",
    "Color(0xFFF0F0F0)": "context.cs.surfaceContainerHighest",
    "Color(0xFFF5F5F5)": "context.cs.surfaceContainerHighest",
}

def apply_hex(src: str) -> str:
    for old, new in HEX_MAP.items():
        src = src.replace(old, new)
    return src

# ── Colors.white in BoxDecoration/Container/Scaffold/nav ─────────────────────
# Replace `color: Colors.white` and `backgroundColor: Colors.white`
# but NOT in TextStyle where white is intentional text-on-dark colour.
def apply_white(src: str) -> str:
    # color: Colors.white  →  color: context.cs.surface
    src = re.sub(r'((?:color|backgroundColor)\s*:\s*)Colors\.white\b(?!\d)',
                 r'\1context.cs.surface', src)
    return src

def process(path: str):
    with open(path, encoding="utf-8") as f:
        src = f.read()

    original = src
    src = apply_hex(src)
    src = apply_white(src)

    changed = src != original
    if changed:
        with open(path, "w", encoding="utf-8") as f:
            f.write(src)
        print(f"✓ Updated: {path.split('/')[-1]}")
    else:
        print(f"  No changes: {path.split('/')[-1]}")

for p in FILES:
    process(p)

print("\n✅ Bulk replacement done.")
