from pathlib import Path

from PIL import Image

src = Path(r"C:\Users\Wahid\.cursor\projects\d-S2-2026-W1-W3\assets\mysihat-app-icon.png")
web = Path(r"D:\S2-2026\W1-W3\frontend\web")
icons = web / "icons"
icons.mkdir(exist_ok=True)

img = Image.open(src).convert("RGBA")


def save_square(path: Path, size: int, maskable: bool = False) -> None:
    if maskable:
        content = img.resize((int(size * 0.8), int(size * 0.8)), Image.Resampling.LANCZOS)
        bg = Image.new("RGBA", (size, size), (23, 104, 63, 255))  # #17683F
        offset = ((size - content.width) // 2, (size - content.height) // 2)
        bg.paste(content, offset, content)
        bg.save(path, "PNG")
    else:
        content = img.resize((size, size), Image.Resampling.LANCZOS)
        content.save(path, "PNG")
    print(f"wrote {path} ({path.stat().st_size} bytes)")


save_square(web / "favicon.png", 48)
save_square(icons / "Icon-192.png", 192)
save_square(icons / "Icon-512.png", 512)
save_square(icons / "Icon-maskable-192.png", 192, maskable=True)
save_square(icons / "Icon-maskable-512.png", 512, maskable=True)
img.resize((512, 512), Image.Resampling.LANCZOS).save(web / "favicon-512.png", "PNG")
print("done")
