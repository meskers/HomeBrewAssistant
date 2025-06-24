#!/usr/bin/env python3
"""
Script to convert a logo image to all required iOS formats
"""

from PIL import Image
import os
import sys

def resize_image_for_app_icon(input_path, output_path, size):
    try:
        with Image.open(input_path) as img:
            if img.mode != 'RGBA':
                img = img.convert('RGBA')
            
            # White background for app icons
            background = Image.new('RGBA', img.size, (255, 255, 255, 255))
            combined = Image.alpha_composite(background, img)
            final_img = combined.convert('RGB')
            resized = final_img.resize((size, size), Image.Resampling.LANCZOS)
            resized.save(output_path, 'PNG', quality=100, optimize=True)
            print(f"✅ App Icon: {output_path} ({size}x{size})")
    except Exception as e:
        print(f"❌ Error: {e}")

def resize_image_for_splash(input_path, output_path, size):
    try:
        with Image.open(input_path) as img:
            if img.mode != 'RGBA':
                img = img.convert('RGBA')
            resized = img.resize((size, size), Image.Resampling.LANCZOS)
            resized.save(output_path, 'PNG', quality=100, optimize=True)
            print(f"✅ Splash Logo: {output_path} ({size}x{size})")
    except Exception as e:
        print(f"❌ Error: {e}")

def convert_beer_brewing_logo(input_logo_path):
    if not os.path.exists(input_logo_path):
        print(f"❌ Logo file not found: {input_logo_path}")
        return False
    
    app_icon_sizes = [
        ('iPhone-20@2x.png', 40), ('iPhone-20@3x.png', 60),
        ('iPhone-29@2x.png', 58), ('iPhone-29@3x.png', 87),
        ('iPhone-40@2x.png', 80), ('iPhone-40@3x.png', 120),
        ('iPhone-60@2x.png', 120), ('iPhone-60@3x.png', 180),
        ('AppStore-1024.png', 1024)
    ]
    
    splash_logo_sizes = [
        ('beer-brewing-logo@1x.png', 120),
        ('beer-brewing-logo@2x.png', 240),
        ('beer-brewing-logo@3x.png', 360)
    ]
    
    app_icon_dir = "HomeBrewAssistant/Assets.xcassets/AppIcon.appiconset"
    splash_logo_dir = "HomeBrewAssistant/Assets.xcassets/BeerBrewingLogo.imageset"
    
    os.makedirs(app_icon_dir, exist_ok=True)
    os.makedirs(splash_logo_dir, exist_ok=True)
    
    print(f"📱 Creating App Icons:")
    for filename, size in app_icon_sizes:
        output_path = os.path.join(app_icon_dir, filename)
        resize_image_for_app_icon(input_logo_path, output_path, size)
    
    print(f"\n🌟 Creating Splash Logos:")
    for filename, size in splash_logo_sizes:
        output_path = os.path.join(splash_logo_dir, filename)
        resize_image_for_splash(input_logo_path, output_path, size)
    
    print(f"\n🎉 Logo conversion complete!")
    return True

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("🍺 Usage: python3 convert_logo.py <logo_file>")
        sys.exit(1)
    
    logo_path = sys.argv[1]
    if convert_beer_brewing_logo(logo_path):
        print("✅ SUCCESS! New logo ready for 5-star app!")
    else:
        sys.exit(1)
