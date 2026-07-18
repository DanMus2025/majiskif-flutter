import math
import subprocess
from io import BytesIO
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[2]
VIDEO_DIR = ROOT / "docs" / "video"
BRANDING = ROOT / "assets" / "branding"
OUT = VIDEO_DIR / "KESE-publicite-HD.webm"
FFMPEG = Path(r"C:\Users\DT\AppData\Local\ms-playwright\ffmpeg-1011\ffmpeg-win64.exe")

W, H = 1920, 1080
FPS = 24
DURATION = 76
TOTAL_FRAMES = FPS * DURATION

LOGO_DTECH = BRANDING / "logo-dtech.png"
LOGO_KESE = BRANDING / "logo-kese.png"
ARCHITECT = BRANDING / "img-architecte.jpeg"
POS_IMAGE = Path(r"C:\Users\DT\Desktop\android-pos-terminal-machine-1000x1000.jpg")
MOBILE_1 = VIDEO_DIR / "KESE-demo-mobile1.mp4"
MOBILE_2 = VIDEO_DIR / "KESE-demo-mobile2.mp4"


FONT_REG = r"C:\Windows\Fonts\arial.ttf"
FONT_BOLD = r"C:\Windows\Fonts\arialbd.ttf"


def font(size, bold=False):
    return ImageFont.truetype(FONT_BOLD if bold else FONT_REG, size)


F = {
    "hero": font(92, True),
    "h1": font(66, True),
    "h2": font(44, True),
    "body": font(32, False),
    "body_b": font(32, True),
    "small": font(24, False),
    "small_b": font(24, True),
    "tiny": font(20, False),
    "mono": ImageFont.truetype(r"C:\Windows\Fonts\consola.ttf", 25),
    "ticket": ImageFont.truetype(r"C:\Windows\Fonts\consola.ttf", 22),
}


def open_rgba(path, size=None):
    img = Image.open(path).convert("RGBA")
    if size:
        img.thumbnail(size, Image.Resampling.LANCZOS)
    return img


logo_dtech = open_rgba(LOGO_DTECH, (170, 170))
logo_kese = open_rgba(LOGO_KESE, (170, 170))
architect = open_rgba(ARCHITECT, (220, 220))
pos = open_rgba(POS_IMAGE, (760, 760))


def rounded_mask(size, radius):
    mask = Image.new("L", size, 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle((0, 0, size[0] - 1, size[1] - 1), radius=radius, fill=255)
    return mask


def paste_round(base, img, xy, radius):
    mask = rounded_mask(img.size, radius)
    base.alpha_composite(img, xy, mask)


def fit_cover(img, size):
    iw, ih = img.size
    sw, sh = size
    scale = max(sw / iw, sh / ih)
    nw, nh = int(iw * scale), int(ih * scale)
    resized = img.resize((nw, nh), Image.Resampling.LANCZOS)
    left = (nw - sw) // 2
    top = (nh - sh) // 2
    return resized.crop((left, top, left + sw, top + sh))


def fit_contain(img, size):
    out = Image.new("RGBA", size, (0, 0, 0, 0))
    copy = img.copy()
    copy.thumbnail(size, Image.Resampling.LANCZOS)
    out.alpha_composite(copy, ((size[0] - copy.width) // 2, (size[1] - copy.height) // 2))
    return out


class VideoReader:
    def __init__(self, path, width=430, height=760):
        self.width = width
        self.height = height
        self.index = 0

    def frame(self):
        self.index += 1
        return mock_app_screen(self.width, self.height, self.index)

    def close(self):
        pass


reader1 = VideoReader(MOBILE_1)
reader2 = VideoReader(MOBILE_2)


def mock_app_screen(width, height, frame_index):
    img = Image.new("RGBA", (width, height), (244, 250, 248, 255))
    d = ImageDraw.Draw(img)
    y_shift = int((frame_index * 1.3) % 140)
    rect(d, (0, 0, width, 92), 0, (7, 59, 72, 255))
    d.text((24, 28), "KESE", font=F["h2"], fill=(255, 255, 255, 255))
    d.text((24, 104), "Tableau de bord", font=F["body_b"], fill=(16, 37, 29, 255))
    cards = [
        ("Ventes", "1 245 USD"),
        ("Stock", "248 articles"),
        ("Caisse", "875 USD"),
        ("Sync", "Cloud actif"),
    ]
    for i, (a, b) in enumerate(cards):
        x = 24 + (i % 2) * ((width - 60) // 2)
        y = 165 + (i // 2) * 126 - y_shift // 4
        rect(d, (x, y, x + (width - 72) // 2, y + 104), 22, (255, 255, 255, 255), (210, 225, 221, 255), 2)
        d.text((x + 18, y + 18), a, font=F["small_b"], fill=(12, 93, 109, 255))
        d.text((x + 18, y + 58), b, font=F["small"], fill=(16, 37, 29, 255))
    d.text((24, 430 - y_shift // 2), "Produits populaires", font=F["body_b"], fill=(16, 37, 29, 255))
    products = [
        ("Riz local 25 kg", "22.00 USD", "Stock 30"),
        ("Huile végétale 5 L", "11.00 USD", "Stock 24"),
        ("Sucre 10 kg", "14.00 USD", "Stock 18"),
    ]
    for i, (name, price, stock) in enumerate(products):
        y = 485 + i * 98 - y_shift
        rect(d, (24, y, width - 24, y + 78), 18, (255, 255, 255, 255), (210, 225, 221, 255), 2)
        d.text((44, y + 15), name, font=F["small_b"], fill=(16, 37, 29, 255))
        d.text((44, y + 45), stock, font=F["tiny"], fill=(91, 107, 115, 255))
        d.text((width - 150, y + 25), price, font=F["tiny"], fill=(12, 93, 109, 255))
    rect(d, (0, height - 82, width, height), 0, (255, 255, 255, 255), (210, 225, 221, 255), 2)
    for i, label in enumerate(["Accueil", "Vendre", "Caisse", "Plus"]):
        d.text((28 + i * 100, height - 52), label, font=F["tiny"], fill=(12, 93, 109, 255))
    return img


def gradient_bg():
    img = Image.new("RGBA", (W, H), "#06161d")
    px = img.load()
    for y in range(H):
        for x in range(W):
            t = (x + y) / (W + H)
            r = int(4 + 12 * t)
            g = int(16 + 86 * t)
            b = int(23 + 96 * t)
            px[x, y] = (r, g, b, 255)
    overlay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    od = ImageDraw.Draw(overlay)
    od.ellipse((-160, -170, 590, 580), fill=(22, 146, 162, 70))
    od.ellipse((1360, 620, 2180, 1450), fill=(245, 200, 93, 38))
    od.ellipse((900, -230, 1670, 520), fill=(255, 255, 255, 22))
    return Image.alpha_composite(img, overlay)


BG_CACHE = None


def cached_bg():
    global BG_CACHE
    if BG_CACHE is None:
        BG_CACHE = gradient_bg()
    return BG_CACHE.copy()


def rect(draw, xy, radius, fill, outline=None, width=2):
    draw.rounded_rectangle(xy, radius=radius, fill=fill, outline=outline, width=width)


def wrap(draw, text, fnt, width):
    words = text.split()
    lines = []
    line = ""
    for word in words:
        test = (line + " " + word).strip()
        if draw.textbbox((0, 0), test, font=fnt)[2] > width and line:
            lines.append(line)
            line = word
        else:
            line = test
    if line:
        lines.append(line)
    return lines


def draw_text(draw, text, xy, fnt, fill=(255, 255, 255, 255), width=900, line_gap=8):
    x, y = xy
    for line in wrap(draw, text, fnt, width):
        draw.text((x, y), line, font=fnt, fill=fill)
        y += fnt.size + line_gap
    return y


def chip(draw, text, x, y):
    bbox = draw.textbbox((0, 0), text, font=F["small_b"])
    w = bbox[2] + 44
    rect(draw, (x, y, x + w, y + 56), 28, (12, 93, 109, 235), (185, 237, 241, 130))
    draw.text((x + 22, y + 15), text, font=F["small_b"], fill=(255, 255, 255, 255))
    return w


def logo_box(base, img, xy, size=130):
    layer = Image.new("RGBA", (size, size), (255, 255, 255, 34))
    ImageDraw.Draw(layer).rounded_rectangle((0, 0, size - 1, size - 1), 28, outline=(255, 255, 255, 64), width=2)
    icon = fit_contain(img, (size - 24, size - 24))
    layer.alpha_composite(icon, (12, 12))
    base.alpha_composite(layer, xy)


def phone(base, video_frame, xy=(1330, 105), size=(430, 760), title=None):
    x, y = xy
    w, h = size
    shadow = Image.new("RGBA", (w + 70, h + 70), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle((35, 35, w + 35, h + 35), 55, fill=(0, 0, 0, 130))
    shadow = shadow.filter(ImageFilter.GaussianBlur(22))
    base.alpha_composite(shadow, (x - 35, y - 20))
    d = ImageDraw.Draw(base)
    rect(d, (x, y, x + w, y + h), 56, (8, 12, 16, 255), (255, 255, 255, 55), 6)
    screen = fit_cover(video_frame, (w - 38, h - 42))
    mask = rounded_mask(screen.size, 38)
    base.paste(screen, (x + 19, y + 21), mask)
    rect(d, (x + w // 2 - 65, y + 18, x + w // 2 + 65, y + 35), 10, (0, 0, 0, 230))
    if title:
        rect(d, (x + 20, y + h - 78, x + w - 20, y + h - 24), 24, (12, 93, 109, 225))
        d.text((x + 42, y + h - 64), title, font=F["small_b"], fill=(255, 255, 255, 255))


def pos_scene(base, t):
    d = ImageDraw.Draw(base)
    img = fit_contain(pos, (720, 720))
    base.alpha_composite(img, (1160, 175))
    paper_x, paper_y = 1228, 120 + int(min(1, t / 5) * 185)
    paper = Image.new("RGBA", (430, 540), (255, 255, 255, 250))
    pd = ImageDraw.Draw(paper)
    pd.text((82, 32), "KESE SHOP", font=F["body_b"], fill=(20, 37, 44, 255))
    rows = [
        "Ticket #000128",
        "Client: Client Demo",
        "--------------------",
        "Riz 25 kg      22.00",
        "Huile 5 L      11.00",
        "--------------------",
        "TOTAL       33.00 USD",
        "Payé        33.00 USD",
        "Merci pour votre confiance",
    ]
    for i, row in enumerate(rows):
        pd.text((28, 88 + i * 38), row, font=F["ticket"], fill=(20, 37, 44, 255))
    paper = paper.rotate(-8, resample=Image.Resampling.BICUBIC, expand=True)
    base.alpha_composite(paper, (paper_x, paper_y))
    d.text((95, 230), "Impression POS intégrée", font=F["h1"], fill=(255, 255, 255, 255))
    draw_text(
        d,
        "Simulez l’impression directe de tickets de caisse depuis les terminaux Android POS professionnels.",
        (100, 335),
        F["body"],
        (232, 247, 249, 255),
        890,
    )
    x = 100
    for label in ["Ticket", "Facture", "Paiement", "Point de vente"]:
        x += chip(d, label, x, 545) + 16


def sync_scene(base, t):
    d = ImageDraw.Draw(base)
    d.text((95, 235), "Synchronisation cloud sécurisée", font=F["h1"], fill=(255, 255, 255, 255))
    draw_text(
        d,
        "Travaillez hors ligne, continuez vos ventes, puis synchronisez automatiquement les données dès que la connexion revient.",
        (100, 340),
        F["body"],
        (232, 247, 249, 255),
        900,
    )
    cx, cy = 1450, 545
    pulse = 70 + int(40 * (1 + math.sin(t * 3)))
    d.ellipse((cx - pulse, cy - pulse, cx + pulse, cy + pulse), outline=(255, 255, 255, 55), width=5)
    rect(d, (cx - 180, cy - 95, cx + 180, cy + 95), 95, (255, 255, 255, 245))
    d.text((cx - 108, cy - 25), "KESE Cloud", font=F["h2"], fill=(7, 59, 72, 255))
    devices = [("Android", 1190, 250), ("Desktop", 1600, 255), ("Web", 1180, 760), ("POS", 1610, 760)]
    for name, x, y in devices:
        d.line((cx, cy, x + 80, y + 55), fill=(255, 255, 255, 110), width=4)
        rect(d, (x, y, x + 165, y + 112), 24, (255, 255, 255, 36), (255, 255, 255, 80), 2)
        d.text((x + 28, y + 42), name, font=F["small_b"], fill=(255, 255, 255, 255))


def modules_scene(base):
    d = ImageDraw.Draw(base)
    d.text((95, 165), "Une plateforme complète", font=F["h1"], fill=(255, 255, 255, 255))
    modules = [
        ("Ventes", "Panier, paiements, crédits"),
        ("Stocks", "Produits, catégories, alertes"),
        ("Caisse", "Revenus, dépenses, bénéfices"),
        ("Équipes", "Admin, gestionnaires, caissiers"),
        ("Messages", "Chat, documents, notes vocales"),
        ("Factures", "Tickets, PDF, impression POS"),
    ]
    for i, (title, sub) in enumerate(modules):
        x = 100 + (i % 3) * 560
        y = 315 + (i // 3) * 250
        rect(d, (x, y, x + 500, y + 170), 26, (255, 255, 255, 34), (255, 255, 255, 75), 2)
        d.text((x + 34, y + 42), title, font=F["h2"], fill=(255, 255, 255, 255))
        draw_text(d, sub, (x + 34, y + 100), F["small"], (214, 239, 242, 255), 410)


def final_scene(base):
    d = ImageDraw.Draw(base)
    logo_box(base, logo_dtech, (725, 110), 150)
    logo_box(base, logo_kese, (1045, 110), 150)
    d.text((765, 345), "KESE", font=F["hero"], fill=(255, 255, 255, 255))
    d.text((315, 485), "Gérez votre entreprise avec intelligence", font=F["h1"], fill=(255, 255, 255, 255))
    draw_text(
        d,
        "Achetez votre licence KESE dès aujourd’hui et bénéficiez gratuitement de l’intégration Android POS professionnelle pour vos points de vente.",
        (250, 610),
        F["body_b"],
        (255, 239, 191, 255),
        1420,
        12,
    )
    d.text((485, 825), "D-Square Technologies · Musagara Daniel", font=F["body_b"], fill=(232, 247, 249, 255))
    d.text((520, 890), "danielmusagara@gmail.com · +243 971 238 634", font=F["small_b"], fill=(185, 237, 241, 255))


def render_frame(i):
    t = i / FPS
    base = cached_bg()
    d = ImageDraw.Draw(base)
    v1 = reader1.frame()
    v2 = reader2.frame()
    scene = min(8, int(t // 8))
    local = t - scene * 8
    if scene == 0:
        logo_box(base, logo_kese, (95, 90), 135)
        d.text((255, 125), "D-Square Technologies présente", font=F["small_b"], fill=(185, 237, 241, 255))
        d.text((95, 285), "KESE", font=F["hero"], fill=(255, 255, 255, 255))
        d.text((95, 405), "L’assistante commerciale numérique", font=F["h1"], fill=(255, 255, 255, 255))
        draw_text(
            d,
            "Une application intelligente de gestion commerciale conçue pour révolutionner les activités quotidiennes des entreprises modernes.",
            (100, 525),
            F["body"],
            (232, 247, 249, 255),
            1010,
        )
        x = 100
        for label in ["Ventes", "Stocks", "Factures", "Cloud", "Offline"]:
            x += chip(d, label, x, 735) + 16
        phone(base, v1, title="Application Android")
    elif scene == 1:
        d.text((95, 230), "Online et offline", font=F["h1"], fill=(255, 255, 255, 255))
        draw_text(
            d,
            "Même sans Internet, les utilisateurs continuent à travailler. Dès que la connexion revient, les données sont synchronisées de manière fluide et sécurisée.",
            (100, 340),
            F["body"],
            (232, 247, 249, 255),
            960,
        )
        phone(base, v2, title="Travail mobile")
    elif scene == 2:
        modules_scene(base)
    elif scene == 3:
        d.text((95, 220), "Multi-utilisateurs", font=F["h1"], fill=(255, 255, 255, 255))
        draw_text(
            d,
            "Administrateur, gestionnaires et caissiers disposent chacun d’un niveau d’accès personnalisé et sécurisé.",
            (100, 330),
            F["body"],
            (232, 247, 249, 255),
            960,
        )
        x = 100
        for label in ["Admin", "Gestionnaire", "Caissier", "Boutiques"]:
            x += chip(d, label, x, 570) + 16
        phone(base, v1, title="Accès sécurisés")
    elif scene == 4:
        pos_scene(base, local)
    elif scene == 5:
        d.text((95, 210), "Communication interne", font=F["h1"], fill=(255, 255, 255, 255))
        draw_text(
            d,
            "Messages instantanés, documents, images et notes vocales pour coordonner les équipes sans quitter l’application.",
            (100, 320),
            F["body"],
            (232, 247, 249, 255),
            960,
        )
        phone(base, v2, title="Messages et fichiers")
    elif scene == 6:
        sync_scene(base, local)
    elif scene == 7:
        d.text((95, 170), "Personnalisation professionnelle", font=F["h1"], fill=(255, 255, 255, 255))
        draw_text(
            d,
            "Logo, identité visuelle, RCCM, numéro d’impôt, coordonnées, adresse et informations légales complètes sur les factures.",
            (100, 280),
            F["body"],
            (232, 247, 249, 255),
            900,
        )
        base.alpha_composite(fit_contain(architect, (220, 220)), (1285, 270))
        logo_box(base, logo_dtech, (1180, 540), 150)
        logo_box(base, logo_kese, (1440, 540), 150)
    else:
        final_scene(base)
    return base.convert("RGB")


def main():
    VIDEO_DIR.mkdir(parents=True, exist_ok=True)
    cmd = [
        str(FFMPEG),
        "-y",
        "-r",
        str(FPS),
        "-f",
        "image2pipe",
        "-vcodec",
        "mjpeg",
        "-i",
        "pipe:0",
        "-c:v",
        "libvpx",
        "-b:v",
        "6M",
        "-pix_fmt",
        "yuv420p",
        str(OUT),
    ]
    proc = subprocess.Popen(cmd, stdin=subprocess.PIPE)
    try:
        for i in range(TOTAL_FRAMES):
            frame = render_frame(i)
            buffer = BytesIO()
            frame.save(buffer, format="JPEG", quality=92)
            proc.stdin.write(buffer.getvalue())
            if i % (FPS * 8) == 0:
                print(f"frame {i}/{TOTAL_FRAMES}")
    finally:
        reader1.close()
        reader2.close()
        proc.stdin.close()
        proc.wait()
    if proc.returncode != 0:
        raise SystemExit(proc.returncode)
    print(OUT)


if __name__ == "__main__":
    main()
