#!/usr/bin/env python3
"""Migrate old Fredoka/Quicksand fonts to AppTextStyles across all feature screens."""

import re
import os
import glob

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FEATURES_DIR = os.path.join(PROJECT_ROOT, "lib", "features")
CORE_WIDGETS_DIR = os.path.join(PROJECT_ROOT, "lib", "core", "widgets")

def find_dart_files():
    """Find all dart files in features/ and core/widgets/ that use old fonts."""
    files = []
    for pattern in [os.path.join(FEATURES_DIR, "**", "*.dart"),
                    os.path.join(CORE_WIDGETS_DIR, "**", "*.dart")]:
        for f in glob.glob(pattern, recursive=True):
            # Skip app_text_styles.dart itself
            if "app_text_styles.dart" in f:
                continue
            with open(f, 'r') as fh:
                content = fh.read()
            if "GoogleFonts.fredoka" in content or "GoogleFonts.quicksand" in content or "fontFamily: 'Quicksand'" in content or "fontFamily: 'Fredoka'" in content:
                files.append(f)
    return files

def get_size_from_props(props_str):
    """Extract fontSize from a properties string."""
    m = re.search(r'fontSize:\s*(\d+)', props_str)
    if m:
        return int(m.group(1))
    return None

def get_weight_from_props(props_str):
    """Extract FontWeight from a properties string."""
    m = re.search(r'fontWeight:\s*(FontWeight\.\w+)', props_str)
    if m:
        return m.group(1)
    return None

def get_color_from_props(props_str):
    """Extract color from a properties string."""
    # Match color: SomeColor or color: SomeColor.withValues(...)
    m = re.search(r'color:\s*((?:AppColors\.\w+(?:\.\w+)?(?:\.withValues\([^)]*\))?|Color\(0x[0-9A-Fa-f]+\)(?:\.withValues\([^)]*\))?|Colors\.\w+(?:\.withValues\([^)]*\))?|Theme\.of\([^)]*\)\.\w+(?:\.withValues\([^)]*\))?))', props_str)
    if m:
        return m.group(1)
    return None

def get_height_from_props(props_str):
    """Extract height from a properties string."""
    m = re.search(r'height:\s*([\d.]+)', props_str)
    if m:
        return m.group(1)
    return None

def map_fredoka_to_app_text_style(props_str):
    """Map GoogleFonts.fredoka(...) to AppTextStyles method."""
    size = get_size_from_props(props_str)
    weight = get_weight_from_props(props_str)
    color = get_color_from_props(props_str)

    # Determine the AppTextStyles method based on size
    if size and size >= 28:
        method = "displayMedium"
    elif size and size >= 20:
        method = "headingLarge"
    elif size and size >= 17:
        method = "headingMedium"
    elif size and size >= 15:
        method = "headingSmall"
    else:
        method = "headingSmall"

    # Build the replacement
    args = []
    if color:
        args.append(f"color: {color}")

    if args:
        return f"AppTextStyles.{method}({', '.join(args)})"
    else:
        return f"AppTextStyles.{method}()"

def map_quicksand_to_app_text_style(props_str):
    """Map GoogleFonts.quicksand(...) to AppTextStyles method."""
    size = get_size_from_props(props_str)
    weight = get_weight_from_props(props_str)
    color = get_color_from_props(props_str)

    # Determine the AppTextStyles method based on size and weight
    if size and size >= 16:
        method = "bodyLarge"
    elif size and size >= 14:
        if weight == "FontWeight.w600" or weight == "FontWeight.w700":
            method = "labelLarge"
        else:
            method = "bodyMedium"
    elif size and size >= 13:
        if weight == "FontWeight.w600" or weight == "FontWeight.w700":
            method = "labelMedium"
        else:
            method = "labelMedium"
    elif size and size >= 11:
        method = "labelSmall"
    else:
        # No size specified - default to bodyMedium
        if weight == "FontWeight.w600" or weight == "FontWeight.w700":
            method = "labelLarge"
        else:
            method = "bodyMedium"

    # Build the replacement
    args = []
    if color:
        args.append(f"color: {color}")

    if args:
        return f"AppTextStyles.{method}({', '.join(args)})"
    else:
        return f"AppTextStyles.{method}()"

def ensure_import(content, file_path):
    """Ensure AppTextStyles import exists."""
    import_line = "import '../../../core/theme/app_text_styles.dart';"

    # Calculate relative import based on file depth
    rel = os.path.relpath(file_path, os.path.join(PROJECT_ROOT, "lib"))
    depth = rel.count(os.sep)
    if "core/widgets/" in rel:
        import_line = "import '../theme/app_text_styles.dart';"
    elif depth == 3:  # features/X/screens/ or features/X/widgets/
        import_line = "import '../../../core/theme/app_text_styles.dart';"
    elif depth == 4:  # features/X/Y/widgets/ (deeper)
        import_line = "import '../../../../core/theme/app_text_styles.dart';"

    if import_line in content:
        return content

    # Add import after the last existing import
    lines = content.split('\n')
    last_import_idx = -1
    for i, line in enumerate(lines):
        if line.startswith('import '):
            last_import_idx = i

    if last_import_idx >= 0:
        lines.insert(last_import_idx + 1, import_line)
    else:
        lines.insert(0, import_line)

    return '\n'.join(lines)

def migrate_file(file_path):
    """Migrate a single file from old fonts to AppTextStyles."""
    with open(file_path, 'r') as f:
        content = f.read()

    original = content
    changes = 0

    # Pattern 1: GoogleFonts.fredoka(\n  ...props...\n)
    # Handle multi-line fredoka calls
    pattern_fredoka = re.compile(
        r'GoogleFonts\.fredoka\(\s*\n((?:\s+[^\n]+\n)*?)\s*\)',
        re.MULTILINE
    )
    def replace_fredoka(m):
        nonlocal changes
        props = m.group(1)
        replacement = map_fredoka_to_app_text_style(props)
        changes += 1
        return replacement
    content = pattern_fredoka.sub(replace_fredoka, content)

    # Pattern 1b: GoogleFonts.fredoka(single-line)
    pattern_fredoka_single = re.compile(
        r'GoogleFonts\.fredoka\(([^)]+)\)'
    )
    def replace_fredoka_single(m):
        nonlocal changes
        props = m.group(1)
        replacement = map_fredoka_to_app_text_style(props)
        changes += 1
        return replacement
    content = pattern_fredoka_single.sub(replace_fredoka_single, content)

    # Pattern 2: GoogleFonts.quicksand(\n  ...props...\n)
    pattern_quicksand = re.compile(
        r'GoogleFonts\.quicksand\(\s*\n((?:\s+[^\n]+\n)*?)\s*\)',
        re.MULTILINE
    )
    def replace_quicksand(m):
        nonlocal changes
        props = m.group(1)
        replacement = map_quicksand_to_app_text_style(props)
        changes += 1
        return replacement
    content = pattern_quicksand.sub(replace_quicksand, content)

    # Pattern 2b: GoogleFonts.quicksand(single-line)
    pattern_quicksand_single = re.compile(
        r'GoogleFonts\.quicksand\(([^)]+)\)'
    )
    def replace_quicksand_single(m):
        nonlocal changes
        props = m.group(1)
        replacement = map_quicksand_to_app_text_style(props)
        changes += 1
        return replacement
    content = pattern_quicksand_single.sub(replace_quicksand_single, content)

    # Pattern 3: fontFamily: 'Quicksand' (inline TextStyle)
    # These are in: TextStyle(fontFamily: 'Quicksand') or similar
    # Replace with AppTextStyles.bodyMedium()
    pattern_inline = re.compile(
        r"(?:style:\s*)?const\s+TextStyle\(fontFamily:\s*'Quicksand'\)"
    )
    def replace_inline(m):
        nonlocal changes
        changes += 1
        return "AppTextStyles.bodyMedium()"
    content = pattern_inline.sub(replace_inline, content)

    # Pattern 3b: style: TextStyle(fontFamily: 'Quicksand')  (non-const)
    pattern_inline2 = re.compile(
        r"style:\s*TextStyle\(fontFamily:\s*'Quicksand'\)"
    )
    def replace_inline2(m):
        nonlocal changes
        changes += 1
        return "style: AppTextStyles.bodyMedium()"
    content = pattern_inline2.sub(replace_inline2, content)

    # Pattern 3c: TextStyle(fontFamily: 'Quicksand', ...) standalone
    pattern_inline3 = re.compile(
        r"TextStyle\(\s*fontFamily:\s*'Quicksand'(?:,\s*\n?\s*([^)]*))?\)",
        re.MULTILINE
    )
    def replace_inline3(m):
        nonlocal changes
        extra_props = m.group(1)
        if extra_props:
            # Has additional properties, map them
            size = get_size_from_props(extra_props)
            color = get_color_from_props(extra_props)
            weight = get_weight_from_props(extra_props)

            if size and size >= 16:
                method = "bodyLarge"
            elif size and size >= 14:
                method = "bodyMedium"
            elif size and size >= 13:
                method = "labelMedium"
            else:
                method = "bodyMedium"

            args = []
            if color:
                args.append(f"color: {color}")
            if args:
                replacement = f"AppTextStyles.{method}({', '.join(args)})"
            else:
                replacement = f"AppTextStyles.{method}()"
        else:
            replacement = "AppTextStyles.bodyMedium()"
        changes += 1
        return replacement
    content = pattern_inline3.sub(replace_inline3, content)

    if changes > 0:
        # Ensure import exists
        content = ensure_import(content, file_path)

        # Remove google_fonts import if no longer used
        if "GoogleFonts." not in content:
            content = content.replace("import 'package:google_fonts/google_fonts.dart';\n", "")

        with open(file_path, 'w') as f:
            f.write(content)

    return changes

def main():
    files = find_dart_files()
    total_changes = 0
    print(f"Found {len(files)} files to migrate\n")

    for f in sorted(files):
        rel = os.path.relpath(f, PROJECT_ROOT)
        changes = migrate_file(f)
        if changes > 0:
            print(f"  ✓ {rel}: {changes} replacements")
            total_changes += changes
        else:
            print(f"  — {rel}: no changes needed")

    print(f"\nTotal: {total_changes} font references migrated")

    # Verify no remaining old fonts
    remaining = 0
    for f in files:
        with open(f, 'r') as fh:
            content = fh.read()
        if "GoogleFonts.fredoka" in content or "GoogleFonts.quicksand" in content:
            remaining += 1
            print(f"  ⚠ Still has old fonts: {os.path.relpath(f, PROJECT_ROOT)}")

    if remaining == 0:
        print("✓ All old font references removed!")
    else:
        print(f"⚠ {remaining} files still have old fonts")

if __name__ == "__main__":
    main()
