#!/usr/bin/env python3
"""
Final pass: fix all remaining compile errors from color replacement.

1. 'invalid_constant': remove `const` from any widget/constructor line that 
   contains `context.cs`
2. 'context undefined': In StatelessWidget.build(), colors ARE accessible via
   context. But in CustomPainter / static methods they are not.
   Strategy: find lines with `context.cs` that are NOT inside build(ctx) — 
   identify them by checking if they're used in a `const` constructor argument 
   (like `BoxShadow`, `Border`, `BorderSide`) and replace with a fallback 
   constant color or extract them from a parameter passed in.
   
   Simpler approach: for ColorScheme calls that appear in non-build contexts
   (CustomPainter, const list items), replace them back with a sensible literal:
     context.cs.onSurface         → const Color(0xFF1A1A1A)  [text]
     context.cs.onSurfaceVariant  → const Color(0xFF888888)  [hint]
     context.cs.outline           → const Color(0xFFEEEEEE)  [border]
     context.cs.surfaceContainerHighest → const Color(0xFFF8F8F8) [input]
     context.cs.surface           → Colors.white
   These are rare edge-cases and will be corrected by the inherited theme for 
   non-custom-painted widgets. Only CustomPainter and const constructors reach 
   this code path.
"""
import re, subprocess

FILES = [
    "/Users/ahmedashraf/Antegravity/FailurePredectiveSystmeMobileApp/lib/Screens/engineer_home_page.dart",
    "/Users/ahmedashraf/Antegravity/FailurePredectiveSystmeMobileApp/lib/Screens/employee_home_page.dart",
    "/Users/ahmedashraf/Antegravity/FailurePredectiveSystmeMobileApp/lib/Screens/manager_home_page.dart",
]

# Lines that are part of const collections or non-build contexts will still
# contain context.cs — remove `const` keyword from the whole statement.

def aggressive_remove_const(src: str) -> str:
    """Remove `const` from any statement line that has context.cs on that 
    line OR on any line of the surrounding block (within 8 lines)."""
    lines = src.split('\n')
    # Mark lines that contain context.cs
    cs_lines = set(i for i, l in enumerate(lines) if 'context.cs' in l)
    
    result = []
    for i, line in enumerate(lines):
        if 'const ' in line:
            # Check if this line or nearby lines have context.cs
            nearby = range(max(0, i-1), min(len(lines), i+8))
            if any(j in cs_lines for j in nearby):
                line = re.sub(r'\bconst\b\s*', '', line, count=1)
        result.append(line)
    return '\n'.join(result)

# Fallback map for truly inaccessible contexts (CustomPainter, static, etc.)
FALLBACK = {
    "context.cs.onSurface": "const Color(0xFF1A1A1A)",
    "context.cs.onSurfaceVariant": "const Color(0xFF888888)",
    "context.cs.outline": "const Color(0xFFEEEEEE)",
    "context.cs.surfaceContainerHighest": "const Color(0xFFF8F8F8)",
    "context.cs.surface": "Colors.white",
    "context.cs.primary": "const Color(0xFF5C3A9E)",
}

def is_in_build_context(src: str, pos: int) -> bool:
    """
    Heuristic: check if the character at pos is inside a method that has
    BuildContext in its signature by scanning backwards for 'BuildContext'.
    """
    before = src[:pos]
    # Find the innermost method/function by looking for the last '{' before pos
    # and check if its signature contains 'BuildContext'
    # Simple heuristic: look back up to 500 chars for '(BuildContext context)'
    snippet = before[-800:]
    return 'BuildContext' in snippet

def fix_context_in_non_build(src: str) -> str:
    """Replace context.cs.X with fallback literal when not in build context."""
    for token, fallback in FALLBACK.items():
        while token in src:
            idx = src.find(token)
            if is_in_build_context(src, idx):
                break  # leave it — it's in a valid build context
            # Replace this one occurrence
            src = src[:idx] + fallback + src[idx + len(token):]
    return src

def process(path: str):
    with open(path, encoding="utf-8") as f:
        src = f.read()

    original = src
    src = aggressive_remove_const(src)
    src = fix_context_in_non_build(src)

    changed = src != original
    if changed:
        with open(path, "w", encoding="utf-8") as f:
            f.write(src)
        print(f"✓ Final-fixed: {path.split('/')[-1]}")
    else:
        print(f"  No change: {path.split('/')[-1]}")

for p in FILES:
    process(p)

print("\n✅ Final fix done.")
