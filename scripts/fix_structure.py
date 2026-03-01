#!/usr/bin/env python3
"""
Post-process home pages after color replacement:
1. Add app_theme.dart import if missing
2. Remove isDarkMode + onThemeChanged from home page states
3. Remove 'const' next to context.cs usages (they can't be const)
4. Replace ProfileScreen(isDarkMode:..., onThemeChanged:...) with ProfileScreen()
"""
import re

FILES = [
    "/Users/ahmedashraf/Antegravity/FailurePredectiveSystmeMobileApp/lib/Screens/engineer_home_page.dart",
    "/Users/ahmedashraf/Antegravity/FailurePredectiveSystmeMobileApp/lib/Screens/employee_home_page.dart",
    "/Users/ahmedashraf/Antegravity/FailurePredectiveSystmeMobileApp/lib/Screens/manager_home_page.dart",
]

IMPORT_ANCHOR = "import 'package:google_fonts/google_fonts.dart';"
NEW_IMPORTS = (
    "import 'package:fpms_app/core/theme/app_theme.dart';\n"
    "import 'package:fpms_app/core/theme/theme_controller.dart';\n"
)

def process(path: str):
    with open(path, encoding="utf-8") as f:
        src = f.read()

    original = src

    # 1. Add missing imports after google_fonts import
    if "core/theme/app_theme.dart" not in src and IMPORT_ANCHOR in src:
        src = src.replace(IMPORT_ANCHOR, IMPORT_ANCHOR + "\n" + NEW_IMPORTS)

    # 2. Remove isDarkMode field declaration
    src = re.sub(r'\s*bool isDarkMode\s*=\s*(true|false)\s*;\n', '\n', src)

    # 3. Remove _toggleTheme method
    src = re.sub(
        r'\s*void _toggleTheme\(bool v\)\s*=>\s*setState\(\(\)\s*=>\s*isDarkMode\s*=\s*v\)\s*;\n',
        '\n', src
    )

    # 4. Remove ProfileScreen isDarkMode/onThemeChanged arguments
    # Pattern: ProfileScreen(isDarkMode: isDarkMode, onThemeChanged: _toggleTheme)
    src = re.sub(
        r'ProfileScreen\s*\(\s*isDarkMode\s*:\s*\w+\s*,\s*onThemeChanged\s*:\s*\w+\s*\)',
        'const ProfileScreen()',
        src
    )
    # Also handle multi-line version
    src = re.sub(
        r'ProfileScreen\s*\(\s*\n\s*isDarkMode\s*:\s*\w+\s*,\s*\n\s*onThemeChanged\s*:\s*\w+\s*,?\s*\n\s*\)',
        'const ProfileScreen()',
        src
    )

    # 5. Remove 'const' before expressions that now contain context.cs (non-const)
    # const [...] or const SomeWidget(...) that now references context.cs
    # Strategy: remove `const` immediately before Color/Container/Widget calls
    #           that contain 'context.cs'
    # Simple pass: remove `const` in lines containing context.cs
    lines = src.split('\n')
    result = []
    for line in lines:
        if 'context.cs' in line:
            # Remove leading const keyword (with optional whitespace)
            line = re.sub(r'\bconst\b\s*(?=context\.cs)', '', line)
        result.append(line)
    src = '\n'.join(result)

    # 6. Remove invalid 'const' from lists/arrays that contain context.cs items
    # Multi-line pass: find const [ ... ] blocks that span lines with context.cs
    # Simpler: just find `const [` then scan until `]` — if context.cs found, remove const
    # Do this iteratively
    def remove_const_blocks(text):
        pattern = re.compile(r'\bconst\s*\[', re.MULTILINE)
        offset = 0
        result_parts = []
        for m in pattern.finditer(text):
            # Scan forward to find matching ]
            start = m.start()
            bracket_start = m.end() - 1  # position of '['
            depth = 0
            i = bracket_start
            while i < len(text):
                if text[i] == '[':
                    depth += 1
                elif text[i] == ']':
                    depth -= 1
                    if depth == 0:
                        block = text[bracket_start:i+1]
                        if 'context.cs' in block:
                            # Replace 'const [' with '['
                            result_parts.append(text[offset:start])
                            result_parts.append(text[start + len(m.group()) - 1: i + 1])
                            offset = i + 1
                        break
                i += 1
        result_parts.append(text[offset:])
        return ''.join(result_parts)

    src = remove_const_blocks(src)

    changed = src != original
    if changed:
        with open(path, "w", encoding="utf-8") as f:
            f.write(src)
        print(f"✓ Fixed: {path.split('/')[-1]}")
    else:
        print(f"  No change: {path.split('/')[-1]}")

for p in FILES:
    process(p)

print("\n✅ Structural fixes done.")
