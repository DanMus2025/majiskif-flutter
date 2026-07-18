import math
import subprocess
import wave
from pathlib import Path

import imageio.v2 as imageio
import imageio_ffmpeg
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[2]
VIDEO_DIR = ROOT / "docs" / "video"
BRANDING = ROOT / "assets" / "branding"

OUT = VIDEO_DIR / "KESE-publicite-cinematique-premium.mp4"
TEMP_VIDEO = VIDEO_DIR / "KESE-publicite-cinematique-premium-sans-audio.mp4"
MUSIC_WAV = VIDEO_DIR / "KESE-musique-cinematique-premium.wav"
MOBILE_1 = VIDEO_DIR / "KESE-demo-mobile1.mp4"
MOBILE_2 = VIDEO_DIR / "KESE-demo-mobile2.mp4"
POS_IMAGE = Path(r"C:\Users\DT\Desktop\android-pos-terminal-machine-1000x1000.jpg")

W, H = 1920, 1080
FPS = 24
DURATION = 55
TOTAL_FRAMES = FPS * DURATION
SCENE_SECONDS = 5


def font(size, bold=False):
    base = r"C:\Windows\Fonts\arialbd.ttf" if bold else r"C:\Windows\Fonts\arial.ttf"
    return ImageFont.truetype(base, size)


F = {
    "hero": font(88, True),
    "h1": font(60, True),
    "h2": font(42, True),
    "body": font(31),
    "body_b": font(31, True),
    "small": font(23),
    "small_b": font(23, True),
    "caption": font(27, True),
    "tiny": font(18),
    "ticket": ImageFont.truetype(r"C:\Windows\Fonts\consola.ttf", 22),
}


def load_rgba(path, size=None):
    img = Image.open(path).convert("RGBA")
    if size:
        img.thumbnail(size, Image.Resampling.LANCZOS)
    return img


LOGO_DTECH = load_rgba(BRANDING / "logo-dtech.png", (190, 190))
LOGO_KESE = load_rgba(BRANDING / "logo-kese.png", (190, 190))
POS = load_rgba(POS_IMAGE, (760, 760))


class SourceVideo:
    def __init__(self, path):
        self.path = Path(path)
        self.reader = imageio.get_reader(str(path))
        meta = self.reader.get_meta_data()
        self.fps = float(meta.get("fps") or 24)
        self.duration = float(meta.get("duration") or 60)
        self.last_index = -1
        self.last = None

    def frame_at(self, seconds):
        seconds = max(0.0, min(seconds, self.duration - 0.1))
        index = int(seconds * self.fps)
        if index == self.last_index and self.last is not None:
            return self.last
        try:
            arr = self.reader.get_data(index)
        except Exception:
            arr = self.reader.get_data(max(0, index - 2))
        self.last_index = index
        self.last = Image.fromarray(arr).convert("RGBA")
        return self.last

    def close(self):
        self.reader.close()


SRC1 = SourceVideo(MOBILE_1)
SRC2 = SourceVideo(MOBILE_2)


def rounded_mask(size, radius):
    mask = Image.new("L", size, 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle((0, 0, size[0] - 1, size[1] - 1), radius=radius, fill=255)
    return mask


def rect(draw, xy, radius, fill, outline=None, width=2):
    draw.rounded_rectangle(xy, radius=radius, fill=fill, outline=outline, width=width)


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


BG = None


def background():
    global BG
    if BG is not None:
        return BG.copy()
    img = Image.new("RGBA", (W, H), (4, 18, 25, 255))
    px = img.load()
    for y in range(H):
        for x in range(W):
            t = (x * 0.7 + y * 1.2) / (W + H)
            px[x, y] = (int(5 + 8 * t), int(28 + 68 * t), int(36 + 74 * t), 255)
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    d.ellipse((-230, -180, 620, 640), fill=(19, 143, 161, 58))
    d.ellipse((1040, -270, 1870, 560), fill=(255, 255, 255, 24))
    d.ellipse((1340, 670, 2190, 1480), fill=(238, 196, 90, 34))
    d.rounded_rectangle((0, 0, W - 1, H - 1), radius=0, outline=(255, 255, 255, 12), width=2)
    BG = Image.alpha_composite(img, layer)
    return BG.copy()


def wrap(draw, text, fnt, width):
    words = text.split()
    lines = []
    line = ""
    for word in words:
        test = (line + " " + word).strip()
        if line and draw.textbbox((0, 0), test, font=fnt)[2] > width:
            lines.append(line)
            line = word
        else:
            line = test
    if line:
        lines.append(line)
    return lines


def text_block(draw, text, xy, fnt, fill, width, gap=8):
    x, y = xy
    for line in wrap(draw, text, fnt, width):
        draw.text((x, y), line, font=fnt, fill=fill)
        y += fnt.size + gap
    return y


def chip(draw, text, x, y):
    bb = draw.textbbox((0, 0), text, font=F["small_b"])
    w = bb[2] + 42
    rect(draw, (x, y, x + w, y + 54), 27, (12, 93, 109, 235), (186, 239, 242, 150), 2)
    draw.text((x + 21, y + 14), text, font=F["small_b"], fill=(255, 255, 255, 255))
    return w


def logo_card(base, logo, xy, size=130):
    card = Image.new("RGBA", (size, size), (255, 255, 255, 30))
    cd = ImageDraw.Draw(card)
    cd.rounded_rectangle((0, 0, size - 1, size - 1), radius=26, outline=(255, 255, 255, 70), width=2)
    icon = fit_contain(logo, (size - 24, size - 24))
    card.alpha_composite(icon, (12, 12))
    base.alpha_composite(card, xy)


def phone(base, frame, xy, size=(430, 830), title=""):
    x, y = xy
    w, h = size
    shadow = Image.new("RGBA", (w + 90, h + 90), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle((45, 38, w + 45, h + 38), radius=64, fill=(0, 0, 0, 155))
    shadow = shadow.filter(ImageFilter.GaussianBlur(24))
    base.alpha_composite(shadow, (x - 45, y - 35))
    d = ImageDraw.Draw(base)
    rect(d, (x, y, x + w, y + h), 58, (7, 12, 16, 255), (255, 255, 255, 70), 6)
    screen = fit_cover(frame, (w - 38, h - 46))
    mask = rounded_mask(screen.size, 40)
    base.paste(screen, (x + 19, y + 23), mask)
    rect(d, (x + w // 2 - 72, y + 18, x + w // 2 + 72, y + 36), 10, (0, 0, 0, 235))


def desktop_panel(base, frame, xy=(930, 195), size=(850, 540), title="Version Web / Desktop"):
    x, y = xy
    w, h = size
    d = ImageDraw.Draw(base)
    shadow = Image.new("RGBA", (w + 70, h + 80), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle((35, 35, w + 35, h + 35), 26, fill=(0, 0, 0, 145))
    shadow = shadow.filter(ImageFilter.GaussianBlur(22))
    base.alpha_composite(shadow, (x - 35, y - 30))
    rect(d, (x, y, x + w, y + h), 26, (13, 28, 34, 255), (255, 255, 255, 75), 3)
    rect(d, (x, y, x + w, y + 58), 26, (7, 59, 72, 255))
    d.text((x + 28, y + 17), title, font=F["small_b"], fill=(255, 255, 255, 255))
    screen = fit_cover(frame, (w - 34, h - 86))
    base.paste(screen, (x + 17, y + 70), rounded_mask(screen.size, 16))


def ticket_layer():
    paper = Image.new("RGBA", (440, 535), (255, 255, 255, 250))
    d = ImageDraw.Draw(paper)
    d.text((116, 30), "KESE SHOP", font=F["body_b"], fill=(20, 37, 44, 255))
    rows = [
        "Ticket #000128",
        "Client: Client Demo",
        "--------------------",
        "Riz 25 kg      22.00",
        "Huile 5 L      11.00",
        "Sucre 10 kg    14.00",
        "--------------------",
        "TOTAL       47.00 USD",
        "Payé        47.00 USD",
        "Merci pour votre confiance",
    ]
    for i, row in enumerate(rows):
        d.text((30, 86 + i * 36), row, font=F["ticket"], fill=(20, 37, 44, 255))
    return paper.rotate(-7, resample=Image.Resampling.BICUBIC, expand=True)


TICKET = ticket_layer()


def printed_receipt(progress):
    progress = max(0.0, min(1.0, progress))
    full_h = 560
    visible_h = int(80 + progress * (full_h - 80))
    paper = Image.new("RGBA", (380, visible_h), (255, 255, 255, 252))
    d = ImageDraw.Draw(paper)
    d.text((95, 24), "KESE SHOP", font=F["body_b"], fill=(20, 37, 44, 255))
    rows = [
        "Ticket #000128",
        "Client: Client Demo",
        "--------------------",
        "Pain          500 FC",
        "Coca        1000 FC",
        "Riz 25 kg  22000 FC",
        "--------------------",
        "TOTAL      23500 FC",
        "Payé       23500 FC",
        "Merci pour votre confiance",
    ]
    for i, row in enumerate(rows):
        y = 82 + i * 34
        if y < visible_h - 28:
            d.text((26, y), row, font=F["ticket"], fill=(20, 37, 44, 255))
    return paper


def pos_with_real_screen(base, frame, t):
    d = ImageDraw.Draw(base)
    pos_img = fit_contain(POS, (780, 780))
    base.alpha_composite(pos_img, (1080, 165))

    app_screen = fit_cover(frame, (300, 530)).resize((248, 438), Image.Resampling.LANCZOS)
    app_screen = app_screen.rotate(-18, resample=Image.Resampling.BICUBIC, expand=True)
    base.alpha_composite(app_screen, (1214, 450))

    receipt = printed_receipt(min(1.0, t / 7.5)).rotate(-7, resample=Image.Resampling.BICUBIC, expand=True)
    base.alpha_composite(receipt, (1332, 80))

    rect(d, (1132, 130, 1810, 205), 38, (255, 239, 191, 245), (255, 255, 255, 110), 2)
    d.text((1170, 149), "Terminal Android POS offert avec la licence KESE", font=F["caption"], fill=(7, 59, 72, 255))

    d.text((95, 170), "Vente, ticket et appareil POS", font=F["h1"], fill=(255, 255, 255, 255))
    text_block(
        d,
        "En achetant votre licence KESE, nous vous offrons un terminal Android POS professionnel avec l’application intégrée. Vous vendez, vous validez, puis le ticket sort directement de l’appareil.",
        (100, 285),
        F["body"],
        (232, 247, 249, 255),
        890,
    )
    x = 100
    for label in ["Licence KESE", "Appareil offert", "Ticket imprimé", "Stock mis à jour"]:
        x += chip(d, label, x, 565) + 16


def scene_pos_presentation(base, frame, t):
    d = ImageDraw.Draw(base)
    base.alpha_composite(fit_contain(POS, (860, 860)), (920, 115))
    screen = fit_cover(frame, (300, 540)).resize((255, 460), Image.Resampling.LANCZOS)
    screen = screen.rotate(-18, resample=Image.Resampling.BICUBIC, expand=True)
    base.alpha_composite(screen, (1105, 495))
    receipt = printed_receipt(min(1.0, t / 4.2)).rotate(-7, resample=Image.Resampling.BICUBIC, expand=True)
    base.alpha_composite(receipt, (1258, 42))
    d.text((95, 145), "Android POS Professionnel", font=F["h1"], fill=(255, 255, 255, 255))
    rows = [
        "Impression instantanée des tickets",
        "Synchronisation Cloud",
        "Paiement rapide",
        "Gestion intelligente",
        "Sécurisé et fiable",
    ]
    for i, row in enumerate(rows):
        y = 285 + i * 72
        rect(d, (110, y, 650, y + 50), 25, (255, 255, 255, 28), (185, 237, 241, 90), 2)
        d.text((140, y + 13), row, font=F["small_b"], fill=(255, 255, 255, 255))
    text_block(
        d,
        "Le terminal est fourni avec KESE intégré pour permettre aux points de vente d’imprimer directement leurs tickets.",
        (100, 690),
        F["body"],
        (232, 247, 249, 255),
        720,
    )


def scene_connection(base, t):
    d = ImageDraw.Draw(base)
    d.text((95, 150), "Connexion sécurisée", font=F["h1"], fill=(255, 255, 255, 255))
    text_block(
        d,
        "Activation de licence, connexion caissier, chargement sécurisé et validation cloud en quelques secondes.",
        (100, 260),
        F["body"],
        (232, 247, 249, 255),
        800,
    )
    steps = ["Licence", "Appareil", "Caissier", "Cloud OK"]
    for i, step in enumerate(steps):
        x = 105 + i * 205
        y = 520
        pulse = int(18 * (1 + math.sin(t * 4 + i)))
        rect(d, (x, y, x + 165, y + 118), 26, (255, 255, 255, 35 + pulse), (185, 237, 241, 120), 2)
        d.text((x + 25, y + 45), step, font=F["small_b"], fill=(255, 255, 255, 255))
    cx, cy = 1390, 505
    d.ellipse((cx - 135, cy - 135, cx + 135, cy + 135), outline=(252, 205, 88, 95), width=5)
    rect(d, (cx - 160, cy - 88, cx + 160, cy + 88), 42, (255, 255, 255, 235))
    d.text((cx - 92, cy - 24), "Sécurisé", font=F["h2"], fill=(7, 59, 72, 255))
    for x, y in [(810, 580), (1050, 578), (1230, 545)]:
        d.line((x, y, cx - 160, cy), fill=(185, 237, 241, 100), width=4)
    phone(base, SRC1.frame_at(16 + t * 2.2), (1450, 150), (330, 650))


def scene_dashboard_admin(base, t):
    d = ImageDraw.Draw(base)
    d.text((95, 130), "Tableau de bord administrateur", font=F["h1"], fill=(255, 255, 255, 255))
    text_block(
        d,
        "Ventes du jour, revenus, statistiques, stocks et activités des caissiers se mettent à jour en temps réel.",
        (100, 235),
        F["body"],
        (232, 247, 249, 255),
        800,
    )
    metrics = [("Ventes", "2000 FC"), ("Revenus", "7400 FC"), ("Bénéfice", "2300 FC"), ("Stocks", "32")]
    for i, (a, b) in enumerate(metrics):
        x = 105 + (i % 2) * 300
        y = 500 + (i // 2) * 125
        rect(d, (x, y, x + 250, y + 92), 24, (255, 255, 255, 34), (185, 237, 241, 95), 2)
        d.text((x + 24, y + 18), a, font=F["small_b"], fill=(185, 237, 241, 255))
        d.text((x + 24, y + 48), b, font=F["body_b"], fill=(255, 255, 255, 255))
    phone(base, SRC1.frame_at(120 + t * 2.0), (1320, 95), title="")


def scene_realtime_sale(base, t):
    d = ImageDraw.Draw(base)
    d.text((95, 150), "Vente synchronisée en temps réel", font=F["h1"], fill=(255, 255, 255, 255))
    text_block(
        d,
        "Le caissier vend sur le POS. L’administrateur reçoit la notification, le stock diminue et le revenu augmente automatiquement.",
        (100, 260),
        F["body"],
        (232, 247, 249, 255),
        820,
    )
    phone(base, SRC1.frame_at(45 + t * 4.0), (980, 160), (340, 680), "")
    phone(base, SRC2.frame_at(130 + t * 2.0), (1450, 160), (340, 680), "")
    cx, cy = 1390, 500
    d.arc((cx - 95, cy - 95, cx + 95, cy + 95), start=int(t * 160) % 360, end=(int(t * 160) + 250) % 360, fill=(252, 205, 88, 220), width=7)
    rect(d, (1265, 455, 1515, 545), 45, (255, 255, 255, 235))
    d.text((1312, 482), "Cloud Sync", font=F["small_b"], fill=(7, 59, 72, 255))


def scene_stock_accounting(base, t):
    d = ImageDraw.Draw(base)
    d.text((95, 135), "Stocks et comptabilité intelligente", font=F["h1"], fill=(255, 255, 255, 255))
    text_block(
        d,
        "Alertes de stock faible, revenus, dépenses, bénéfices et statistiques : KESE automatise les calculs essentiels.",
        (100, 245),
        F["body"],
        (232, 247, 249, 255),
        850,
    )
    bars = [0.35, 0.66, 0.48, 0.82, 0.58, 0.92]
    for i, val in enumerate(bars):
        x = 120 + i * 88
        y = 760
        h = int(330 * (val + 0.08 * math.sin(t * 3 + i)))
        rect(d, (x, y - h, x + 52, y), 16, (252, 205, 88, 210), (255, 255, 255, 70), 2)
    desktop_panel(base, SRC1.frame_at(175 - t * 1.5), (970, 210), (805, 520), "Statistiques et gestion")


def progress_bar(draw, t, total):
    w = 630
    x, y = 100, 930
    rect(draw, (x, y, x + w, y + 10), 5, (255, 255, 255, 45))
    rect(draw, (x, y, x + int(w * min(1, t / total)), y + 10), 5, (252, 205, 88, 235))


def scene_intro(base, t):
    d = ImageDraw.Draw(base)
    logo_card(base, LOGO_KESE, (95, 86), 138)
    d.text((255, 126), "D-Square Technologies présente", font=F["small_b"], fill=(185, 237, 241, 255))
    d.text((95, 275), "KESE", font=F["hero"], fill=(255, 255, 255, 255))
    d.text((95, 395), "L’assistante commerciale numérique", font=F["h1"], fill=(255, 255, 255, 255))
    text_block(
        d,
        "Une application intelligente de gestion commerciale conçue pour révolutionner la manière dont les entreprises gèrent leurs activités quotidiennes.",
        (100, 520),
        F["body"],
        (232, 247, 249, 255),
        1020,
    )
    x = 100
    for label in ["Ventes", "Stocks", "Factures", "Cloud", "POS"]:
        x += chip(d, label, x, 730) + 16
    phone(base, SRC1.frame_at(t), (1335, 105), title="Vraie démonstration mobile")


def scene_offline(base, t, source_t):
    d = ImageDraw.Draw(base)
    d.text((95, 210), "Online et offline", font=F["h1"], fill=(255, 255, 255, 255))
    text_block(
        d,
        "Même sans connexion Internet, vos équipes continuent à vendre, gérer les stocks et consulter les données. Dès que la connexion revient, KESE synchronise les informations de manière fluide et sécurisée.",
        (100, 315),
        F["body"],
        (232, 247, 249, 255),
        860,
    )
    x = 100
    for label in ["Mode local", "Cloud sécurisé", "Synchronisation", "Continuité"]:
        x += chip(d, label, x, 620) + 16
    phone(base, SRC1.frame_at(source_t), (1320, 95), title="Travail hors ligne")


def scene_modules(base, source_t):
    d = ImageDraw.Draw(base)
    d.text((95, 120), "Gestion commerciale complète", font=F["h1"], fill=(255, 255, 255, 255))
    modules = [
        ("Ventes", "Panier, paiements, factures"),
        ("Produits", "Catégories, prix, stocks"),
        ("Caisse", "Revenus, dépenses, bénéfices"),
        ("Équipes", "Admin, gestionnaires, caissiers"),
        ("Messages", "Chat, documents, notes vocales"),
        ("Notifications", "Alertes et suivi en temps réel"),
    ]
    for i, (title, desc) in enumerate(modules):
        x = 95 + (i % 2) * 430
        y = 250 + (i // 2) * 190
        rect(d, (x, y, x + 380, y + 130), 24, (255, 255, 255, 34), (255, 255, 255, 75), 2)
        d.text((x + 28, y + 28), title, font=F["h2"], fill=(255, 255, 255, 255))
        text_block(d, desc, (x + 28, y + 80), F["small"], (214, 239, 242, 255), 310)
    desktop_panel(base, SRC1.frame_at(source_t), (1040, 210), (740, 520), "Parcours réel de l’application")


def scene_multi(base, source_t1, source_t2):
    d = ImageDraw.Draw(base)
    d.text((95, 170), "Architecture multi-utilisateurs", font=F["h1"], fill=(255, 255, 255, 255))
    text_block(
        d,
        "Un administrateur principal gère plusieurs boutiques, plusieurs gestionnaires et plusieurs caissiers depuis un espace centralisé avec des accès personnalisés.",
        (100, 280),
        F["body"],
        (232, 247, 249, 255),
        820,
    )
    for i, label in enumerate(["Administrateur", "Gestionnaire", "Caissier"]):
        rect(d, (110, 530 + i * 90, 480, 590 + i * 90), 30, (12, 93, 109, 230), (185, 237, 241, 130), 2)
        d.text((140, 546 + i * 90), label, font=F["body_b"], fill=(255, 255, 255, 255))
    phone(base, SRC1.frame_at(source_t1), (1040, 125), (360, 720), "Admin")
    phone(base, SRC2.frame_at(source_t2), (1450, 125), (360, 720), "Caisse")


def scene_messages(base, source_t):
    d = ImageDraw.Draw(base)
    d.text((95, 195), "Communication interne", font=F["h1"], fill=(255, 255, 255, 255))
    text_block(
        d,
        "Messages instantanés, documents, images et notes vocales : les équipes collaborent directement dans KESE sans dépendre d’une plateforme externe.",
        (100, 305),
        F["body"],
        (232, 247, 249, 255),
        820,
    )
    x = 100
    for label in ["Chat", "Documents", "Images", "Notes vocales"]:
        x += chip(d, label, x, 585) + 16
    phone(base, SRC2.frame_at(source_t), (1320, 95), title="Messages et fichiers")


def scene_sync(base, t, source_t):
    d = ImageDraw.Draw(base)
    d.text((95, 210), "Synchronisation cloud sécurisée", font=F["h1"], fill=(255, 255, 255, 255))
    text_block(
        d,
        "Android, Web et Desktop restent connectés. Les opérations sont sauvegardées localement puis envoyées vers le cloud dès que la synchronisation est disponible.",
        (100, 320),
        F["body"],
        (232, 247, 249, 255),
        860,
    )
    cx, cy = 1390, 540
    pulse = 80 + int(24 * (1 + math.sin(t * 3.4)))
    d.ellipse((cx - pulse, cy - pulse, cx + pulse, cy + pulse), outline=(255, 255, 255, 55), width=5)
    rect(d, (cx - 185, cy - 95, cx + 185, cy + 95), 95, (255, 255, 255, 245))
    d.text((cx - 112, cy - 25), "KESE Cloud", font=F["h2"], fill=(7, 59, 72, 255))
    for label, x, y in [("Android", 1115, 245), ("Desktop", 1585, 245), ("Web", 1115, 765), ("POS", 1605, 765)]:
        d.line((cx, cy, x + 90, y + 55), fill=(255, 255, 255, 120), width=4)
        rect(d, (x, y, x + 180, y + 112), 26, (255, 255, 255, 36), (255, 255, 255, 85), 2)
        d.text((x + 34, y + 42), label, font=F["small_b"], fill=(255, 255, 255, 255))
    desktop_panel(base, SRC1.frame_at(source_t), (1000, 390), (365, 250), "Données réelles")


def scene_branding(base):
    d = ImageDraw.Draw(base)
    d.text((95, 145), "Entreprise personnalisée", font=F["h1"], fill=(255, 255, 255, 255))
    text_block(
        d,
        "Chaque entreprise peut intégrer son logo, son identité visuelle, son RCCM, son numéro d’impôt, son adresse et ses informations légales complètes sur les factures.",
        (100, 255),
        F["body"],
        (232, 247, 249, 255),
        900,
    )
    items = ["Logo", "RCCM", "ID nationale", "Impôt", "Coordonnées", "Adresse"]
    for i, item in enumerate(items):
        x = 110 + (i % 3) * 260
        y = 520 + (i // 3) * 95
        rect(d, (x, y, x + 220, y + 60), 30, (12, 93, 109, 230), (185, 237, 241, 130), 2)
        d.text((x + 28, y + 17), item, font=F["small_b"], fill=(255, 255, 255, 255))
    logo_card(base, LOGO_DTECH, (1190, 320), 170)
    logo_card(base, LOGO_KESE, (1460, 320), 170)
    rect(d, (1130, 570, 1685, 735), 30, (255, 255, 255, 245))
    d.text((1175, 610), "Factures professionnelles", font=F["h2"], fill=(7, 59, 72, 255))
    d.text((1178, 675), "Tickets • PDF • Impression POS", font=F["body_b"], fill=(20, 37, 44, 255))


def scene_final(base):
    d = ImageDraw.Draw(base)
    logo_card(base, LOGO_DTECH, (710, 98), 152)
    logo_card(base, LOGO_KESE, (1058, 98), 152)
    d.text((765, 330), "KESE", font=F["hero"], fill=(255, 255, 255, 255))
    d.text((245, 470), "La gestion commerciale nouvelle génération", font=F["h1"], fill=(255, 255, 255, 255))
    text_block(
        d,
        "Achetez votre licence KESE dès aujourd’hui. Pour toute licence à durée illimitée, un terminal Android POS professionnel est offert gratuitement.",
        (250, 600),
        F["body_b"],
        (255, 239, 191, 255),
        1420,
        12,
    )
    d.text((480, 815), "D-Square Technologies · Musagara Daniel", font=F["body_b"], fill=(232, 247, 249, 255))
    d.text((520, 875), "danielmusagara@gmail.com · +243 971 238 634", font=F["small_b"], fill=(185, 237, 241, 255))


def create_music(path):
    sample_rate = 44100
    seconds = DURATION
    t = np.linspace(0, seconds, int(sample_rate * seconds), endpoint=False)
    bpm = 148
    beat = 60 / bpm
    chords = [
        (261.63, 329.63, 392.00),
        (196.00, 246.94, 329.63),
        (220.00, 277.18, 329.63),
        (174.61, 220.00, 261.63),
    ]
    audio = np.zeros_like(t)
    for bar in range(int(seconds / (beat * 4)) + 1):
        chord = chords[bar % len(chords)]
        start = int(bar * beat * 4 * sample_rate)
        end = min(len(t), int((bar + 1) * beat * 4 * sample_rate))
        local = np.arange(end - start) / sample_rate
        pad = np.zeros(end - start)
        for freq in chord:
            pulse = (np.sin(2 * math.pi * (1 / beat) * local) > -0.25).astype(float)
            pad += 0.045 * np.sin(2 * math.pi * freq * local) * (0.45 + 0.55 * pulse)
            pad += 0.035 * np.sin(2 * math.pi * freq * 2 * local)
        envelope = np.minimum(1, local / 0.08) * np.minimum(1, (len(local) / sample_rate - local) / 0.22)
        audio[start:end] += pad * envelope
    notes = [659.25, 783.99, 987.77, 1174.66, 1046.50, 987.77, 880.00, 783.99]
    for i in range(int(seconds / (beat / 4))):
        start = int(i * beat / 4 * sample_rate)
        end = min(len(t), start + int(0.12 * sample_rate))
        local = np.arange(end - start) / sample_rate
        freq = notes[i % len(notes)]
        env = np.sin(np.linspace(0, math.pi, end - start))
        audio[start:end] += 0.075 * np.sin(2 * math.pi * freq * local) * env
    for i in range(int(seconds / beat)):
        start = int(i * beat * sample_rate)
        end = min(len(t), start + int(0.08 * sample_rate))
        env = np.exp(-np.linspace(0, 7, end - start))
        audio[start:end] += 0.14 * np.sin(2 * math.pi * 100 * np.arange(end - start) / sample_rate) * env
        if i % 2 == 1:
            start2 = min(len(t), start + int(0.5 * beat * sample_rate))
            end2 = min(len(t), start2 + int(0.035 * sample_rate))
            noise = np.random.default_rng(i).normal(0, 1, end2 - start2)
            audio[start2:end2] += 0.055 * noise * np.exp(-np.linspace(0, 5, end2 - start2))
    fade = int(sample_rate * 2)
    audio[:fade] *= np.linspace(0, 1, fade)
    audio[-fade:] *= np.linspace(1, 0, fade)
    audio = audio / max(1e-6, np.max(np.abs(audio))) * 0.55
    pcm = (audio * 32767).astype(np.int16)
    with wave.open(str(path), "wb") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(sample_rate)
        wav.writeframes(pcm.tobytes())


def mux_audio(video_path, audio_path, output_path):
    ffmpeg = imageio_ffmpeg.get_ffmpeg_exe()
    subprocess.run(
        [
            ffmpeg,
            "-y",
            "-i",
            str(video_path),
            "-i",
            str(audio_path),
            "-c:v",
            "copy",
            "-c:a",
            "aac",
            "-b:a",
            "160k",
            "-shortest",
            "-movflags",
            "+faststart",
            str(output_path),
        ],
        check=True,
    )


def render_frame(index):
    t = index / FPS
    base = background()
    d = ImageDraw.Draw(base)
    scene = min(10, int(t // SCENE_SECONDS))
    local = t - scene * SCENE_SECONDS
    if scene == 0:
        scene_intro(base, 9 + local * 2.0)
    elif scene == 1:
        scene_pos_presentation(base, SRC1.frame_at(45 + local * 4.0), local)
    elif scene == 2:
        scene_connection(base, local)
    elif scene == 3:
        scene_dashboard_admin(base, local)
    elif scene == 4:
        scene_realtime_sale(base, local)
    elif scene == 5:
        scene_multi(base, 60 + local * 3.0, 20 + local * 3.8)
    elif scene == 6:
        scene_messages(base, source_t=20 + local * 10.0)
    elif scene == 7:
        scene_stock_accounting(base, local)
    elif scene == 8:
        scene_branding(base)
    elif scene == 9:
        scene_sync(base, local, source_t=120 + local * 3.2)
    else:
        scene_final(base)
    progress_bar(d, t, DURATION)
    return base.convert("RGB")


def main():
    VIDEO_DIR.mkdir(parents=True, exist_ok=True)
    with imageio.get_writer(
        str(TEMP_VIDEO),
        fps=FPS,
        codec="libx264",
        quality=8,
        macro_block_size=1,
        ffmpeg_params=["-pix_fmt", "yuv420p", "-crf", "18", "-preset", "medium", "-movflags", "+faststart"],
    ) as writer:
        for i in range(TOTAL_FRAMES):
            writer.append_data(np.asarray(render_frame(i)))
            if i % (FPS * 6) == 0:
                print(f"frame {i}/{TOTAL_FRAMES}")
    SRC1.close()
    SRC2.close()
    create_music(MUSIC_WAV)
    mux_audio(TEMP_VIDEO, MUSIC_WAV, OUT)
    print(OUT)


if __name__ == "__main__":
    main()
