#!/usr/bin/env python3
import argparse
import os
import re
import shutil

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def update_file_regex(rel_path, pattern, replacement):
    full_path = os.path.join(ROOT, rel_path)
    if not os.path.exists(full_path):
        return
    with open(full_path, "r", encoding="utf-8") as f:
        content = f.read()
    new_content = re.sub(pattern, replacement, content)
    with open(full_path, "w", encoding="utf-8") as f:
        f.write(new_content)
    print(f"[✓] Updated {rel_path}")

def main():
    parser = argparse.ArgumentParser(description="Customize Miqati App Name, Logo, and Adhan Sounds")
    parser.add_argument("--name-ar", help="New Arabic App Name")
    parser.add_argument("--name-en", help="New English App Name")
    parser.add_argument("--bundle-id", help="New Android/iOS Package ID")
    parser.add_argument("--logo", help="Path to new PNG logo file")
    parser.add_argument("--add-adhan", help="Format: 'Muezzin Name:/path/to/adhan.mp3'")
    args = parser.parse_args()

    if args.name_ar:
        update_file_regex(
            "lib/config/app_branding_and_sounds.dart",
            r"defaultAppNameAr = '[^']*';",
            f"defaultAppNameAr = '{args.name_ar}';"
        )
        update_file_regex(
            "android/app/src/main/AndroidManifest.xml",
            r'android:label="[^"]*"',
            f'android:label="{args.name_ar}"'
        )
        update_file_regex(
            "ios/Runner/Info.plist",
            r"<key>CFBundleDisplayName</key>\s*<string>[^<]*</string>",
            f"<key>CFBundleDisplayName</key>\n\t<string>{args.name_ar}</string>"
        )

    if args.name_en:
        update_file_regex(
            "lib/config/app_branding_and_sounds.dart",
            r"defaultAppNameEn = '[^']*';",
            f"defaultAppNameEn = '{args.name_en}';"
        )

    if args.logo and os.path.exists(args.logo):
        dest = os.path.join(ROOT, "assets", "logo", "app_logo.png")
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        shutil.copy2(args.logo, dest)
        print("[✓] Copied new logo to assets/logo/app_logo.png")

    if args.add_adhan and ":" in args.add_adhan:
        title, mp3_path = args.add_adhan.split(":", 1)
        if os.path.exists(mp3_path):
            fname = os.path.basename(mp3_path)
            dest = os.path.join(ROOT, "assets", "audio", fname)
            os.makedirs(os.path.dirname(dest), exist_ok=True)
            shutil.copy2(mp3_path, dest)
            voice_id = os.path.splitext(fname)[0]
            snippet = f"""  AdhanVoiceOption(
      id: '{voice_id}',
      nameAr: '{title}',
      nameEn: '{title}',
      pathOrUrl: 'assets/audio/{fname}',
    ),\n  """
            update_file_regex(
                "lib/config/app_branding_and_sounds.dart",
                r"(static final List<AdhanVoiceOption> defaultAdhanVoices = <AdhanVoiceOption>\[\n)",
                r"\1  " + snippet
            )
            print(f"[✓] Added Adhan audio '{title}' -> assets/audio/{fname}")

if __name__ == "__main__":
    main()
