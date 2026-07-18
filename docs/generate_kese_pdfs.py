from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    Image,
    KeepTogether,
    ListFlowable,
    ListItem,
    PageBreak,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs" / "pdf"
BRANDING = ROOT / "assets" / "branding"

LOGO_DTECH = BRANDING / "logo-dtech.png"
LOGO_KESE = BRANDING / "logo-kese.png"
ARCHITECT = BRANDING / "img-architecte.jpeg"

FONT_REGULAR = r"C:\Windows\Fonts\arial.ttf"
FONT_BOLD = r"C:\Windows\Fonts\arialbd.ttf"

pdfmetrics.registerFont(TTFont("Arial", FONT_REGULAR))
pdfmetrics.registerFont(TTFont("Arial-Bold", FONT_BOLD))


def styles():
    base = getSampleStyleSheet()
    base.add(
        ParagraphStyle(
            name="DocTitle",
            fontName="Arial-Bold",
            fontSize=20,
            leading=24,
            textColor=colors.HexColor("#073B48"),
            alignment=TA_CENTER,
            spaceAfter=14,
        )
    )
    base.add(
        ParagraphStyle(
            name="DocSubtitle",
            fontName="Arial",
            fontSize=10.5,
            leading=15,
            textColor=colors.HexColor("#41525A"),
            alignment=TA_CENTER,
            spaceAfter=16,
        )
    )
    base.add(
        ParagraphStyle(
            name="SectionTitle",
            fontName="Arial-Bold",
            fontSize=14,
            leading=18,
            textColor=colors.HexColor("#0C5D6D"),
            spaceBefore=10,
            spaceAfter=8,
        )
    )
    base.add(
        ParagraphStyle(
            name="Body",
            fontName="Arial",
            fontSize=10.4,
            leading=15.5,
            alignment=TA_JUSTIFY,
            textColor=colors.HexColor("#172A31"),
            spaceAfter=7,
        )
    )
    base.add(
        ParagraphStyle(
            name="KeseBullet",
            fontName="Arial",
            fontSize=10.2,
            leading=14,
            textColor=colors.HexColor("#172A31"),
        )
    )
    base.add(
        ParagraphStyle(
            name="Small",
            fontName="Arial",
            fontSize=8.6,
            leading=11,
            textColor=colors.HexColor("#5B6B73"),
            alignment=TA_LEFT,
        )
    )
    base.add(
        ParagraphStyle(
            name="Contact",
            fontName="Arial-Bold",
            fontSize=10.2,
            leading=14,
            textColor=colors.HexColor("#073B48"),
        )
    )
    return base


S = styles()


def p(text, style="Body"):
    return Paragraph(text, S[style])


def bullets(items):
    return ListFlowable(
        [ListItem(p(item, "KeseBullet"), leftIndent=8) for item in items],
        bulletType="bullet",
        start="circle",
        leftIndent=16,
        bulletFontName="Arial",
        bulletFontSize=8,
    )


def header_table(title):
    imgs = []
    if LOGO_DTECH.exists():
        imgs.append(Image(str(LOGO_DTECH), width=2.0 * cm, height=2.0 * cm))
    if LOGO_KESE.exists():
        imgs.append(Image(str(LOGO_KESE), width=2.0 * cm, height=2.0 * cm))

    logo_cell = Table([imgs], colWidths=[2.1 * cm for _ in imgs]) if imgs else ""
    table = Table(
        [[logo_cell, Paragraph(title, S["DocTitle"])]],
        colWidths=[4.8 * cm, 11.8 * cm],
    )
    table.setStyle(
        TableStyle(
            [
                ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                ("BACKGROUND", (0, 0), (-1, -1), colors.HexColor("#F3FAF8")),
                ("BOX", (0, 0), (-1, -1), 0.5, colors.HexColor("#B9D8D2")),
                ("LEFTPADDING", (0, 0), (-1, -1), 10),
                ("RIGHTPADDING", (0, 0), (-1, -1), 10),
                ("TOPPADDING", (0, 0), (-1, -1), 10),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 10),
            ]
        )
    )
    return table


def footer(canvas, doc):
    canvas.saveState()
    canvas.setFont("Arial", 8)
    canvas.setFillColor(colors.HexColor("#5B6B73"))
    canvas.drawString(
        doc.leftMargin,
        1.05 * cm,
        "D-Square Technologies — KESE — Document de référence",
    )
    canvas.drawRightString(
        A4[0] - doc.rightMargin,
        1.05 * cm,
        f"Page {doc.page}",
    )
    canvas.restoreState()


def doc(path, title):
    return SimpleDocTemplate(
        str(path),
        pagesize=A4,
        rightMargin=1.7 * cm,
        leftMargin=1.7 * cm,
        topMargin=1.5 * cm,
        bottomMargin=1.6 * cm,
        title=title,
        author="D-Square Technologies",
        subject="KESE",
    )


def contact_block():
    rows = [
        ["Entreprise", "D-Square Technologies"],
        ["Fondateur", "Musagara Daniel"],
        ["Email", "danielmusagara@gmail.com"],
        ["Téléphone", "+243 971 238 634"],
        ["WhatsApp", "+243 971 238 634"],
        ["Application", "KESE"],
    ]
    table = Table(rows, colWidths=[4.0 * cm, 11.8 * cm])
    table.setStyle(
        TableStyle(
            [
                ("FONTNAME", (0, 0), (0, -1), "Arial-Bold"),
                ("FONTNAME", (1, 0), (1, -1), "Arial"),
                ("FONTSIZE", (0, 0), (-1, -1), 10),
                ("TEXTCOLOR", (0, 0), (0, -1), colors.HexColor("#0C5D6D")),
                ("GRID", (0, 0), (-1, -1), 0.35, colors.HexColor("#C7D9D6")),
                ("BACKGROUND", (0, 0), (0, -1), colors.HexColor("#EEF7F5")),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (-1, -1), 8),
                ("RIGHTPADDING", (0, 0), (-1, -1), 8),
                ("TOPPADDING", (0, 0), (-1, -1), 7),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 7),
            ]
        )
    )
    return table


def architect_card():
    if not ARCHITECT.exists():
        return []
    image = Image(str(ARCHITECT), width=3.0 * cm, height=3.0 * cm)
    text = [
        p("<b>Musagara Daniel</b>", "Contact"),
        p(
            "Entrepreneur technologique congolais, CEO & Founder de D-Square Technologies, "
            "engagé dans la création de solutions modernes pour la gestion, la productivité "
            "et la transformation numérique.",
            "Small",
        ),
    ]
    table = Table([[image, text]], colWidths=[3.4 * cm, 12.4 * cm])
    table.setStyle(
        TableStyle(
            [
                ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                ("BOX", (0, 0), (-1, -1), 0.5, colors.HexColor("#B9D8D2")),
                ("BACKGROUND", (0, 0), (-1, -1), colors.HexColor("#F7FBFA")),
                ("LEFTPADDING", (0, 0), (-1, -1), 10),
                ("RIGHTPADDING", (0, 0), (-1, -1), 10),
                ("TOPPADDING", (0, 0), (-1, -1), 10),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 10),
            ]
        )
    )
    return [table, Spacer(1, 12)]


def build_confidentiality():
    story = [
        header_table("Conditions internes de confidentialité"),
        Spacer(1, 10),
        p(
            "Ce document présente les règles internes de confidentialité applicables à l’utilisation "
            "de KESE, solution développée par D-Square Technologies. Il vise à protéger les données "
            "commerciales, les accès, les informations de gestion et les échanges internes de chaque entreprise utilisatrice.",
            "DocSubtitle",
        ),
        p("1. Objet du document", "SectionTitle"),
        p(
            "Les présentes conditions définissent les obligations de confidentialité liées à l’usage "
            "de l’application KESE, de ses modules de gestion, de ses données locales, de ses données synchronisées "
            "et de ses services cloud.",
        ),
        p("2. Informations considérées comme confidentielles", "SectionTitle"),
        bullets(
            [
                "les licences, clés d’entreprise, identifiants, codes secrets et droits d’accès ;",
                "les ventes, factures, tickets, paiements, dettes, crédits, dépenses et revenus ;",
                "les données clients, fournisseurs, produits, stocks, prix, bénéfices et mouvements ;",
                "les messages internes, instructions, notes, documents, images, audios et pièces jointes ;",
                "les informations techniques liées aux serveurs, bases de données, adresses cloud et synchronisations.",
            ]
        ),
        p("3. Accès et responsabilité des utilisateurs", "SectionTitle"),
        p(
            "Chaque utilisateur doit conserver son identifiant et son code secret de manière strictement personnelle. "
            "Le partage non autorisé des accès, l’utilisation d’un compte appartenant à un autre utilisateur ou la "
            "transmission de mots de passe à des personnes non habilitées sont interdits.",
        ),
        p(
            "L’administrateur de l’entreprise utilisatrice reste responsable de la création des comptes, de l’attribution "
            "des rôles, du contrôle des droits et du suivi des activités réalisées dans l’application.",
        ),
        p("4. Protection des données locales et cloud", "SectionTitle"),
        p(
            "KESE peut fonctionner en mode local, en mode cloud ou en mode synchronisé. Les données enregistrées localement "
            "sur un téléphone, un ordinateur ou une version desktop doivent être protégées contre la perte, le vol, la copie "
            "non autorisée et l’accès par des tiers.",
        ),
        p(
            "Lorsque la synchronisation cloud est activée, les données sont transmises vers l’adresse cloud configurée pour "
            "l’entreprise. Toute modification de l’adresse cloud doit rester contrôlée par les responsables autorisés afin "
            "d’éviter la dispersion ou la perte de cohérence des données.",
        ),
        p("5. Communication interne", "SectionTitle"),
        p(
            "Les messages échangés dans KESE sont destinés à la coordination interne de l’entreprise. Ils ne doivent pas "
            "être copiés, publiés ou transférés à l’extérieur sans autorisation de l’administrateur ou du responsable habilité.",
        ),
        p("6. Interdictions", "SectionTitle"),
        bullets(
            [
                "copier, extraire ou vendre les données d’une entreprise utilisatrice ;",
                "contourner les droits d’accès, modifier les journaux ou masquer des opérations ;",
                "utiliser une mauvaise adresse cloud pour détourner les données ;",
                "partager publiquement des captures contenant des données sensibles ;",
                "réinstaller, déplacer ou synchroniser l’application sans respecter les procédures autorisées.",
            ]
        ),
        p("7. Conservation et sauvegarde", "SectionTitle"),
        p(
            "Les utilisateurs doivent veiller à sauvegarder régulièrement leurs données, à synchroniser les appareils lorsque "
            "la connexion est disponible et à signaler toute anomalie technique. Les données locales doivent être conservées "
            "avec soin jusqu’à leur transmission vers le cloud configuré.",
        ),
        p("8. Incident de sécurité", "SectionTitle"),
        p(
            "En cas de perte d’un appareil, suspicion de vol de compte, mot de passe compromis ou erreur de synchronisation, "
            "l’utilisateur doit prévenir immédiatement l’administrateur et contacter le support de référence.",
        ),
        p("9. Contacts de référence", "SectionTitle"),
        contact_block(),
        Spacer(1, 12),
        *architect_card(),
        p(
            "Toute utilisation de KESE implique l’acceptation de ces règles internes de confidentialité par l’entreprise "
            "utilisatrice et par ses utilisateurs autorisés.",
            "Small",
        ),
    ]
    pdf = doc(OUT / "KESE-Conditions-internes-confidentialite.pdf", "Conditions internes de confidentialité")
    pdf.build(story, onFirstPage=footer, onLaterPages=footer)


def build_activation_guide():
    story = [
        header_table("Modalités d’activation et guide complet d’utilisation"),
        Spacer(1, 10),
        p(
            "Ce document regroupe les modalités d’activation de KESE, les principes de fonctionnement local et cloud, "
            "les étapes de synchronisation, les guides d’utilisation et les contacts officiels de référence.",
            "DocSubtitle",
        ),
        p("1. Présentation de D-Square Technologies", "SectionTitle"),
        p(
            "Fondée en 2011 en République démocratique du Congo par Musagara Daniel, D-Square Technologies est une entreprise "
            "spécialisée dans les technologies numériques, l’innovation et le développement de solutions intelligentes adaptées "
            "aux réalités africaines et internationales.",
        ),
        p(
            "L’entreprise accompagne les particuliers, les commerçants, les startups, les PME ainsi que les grandes entreprises "
            "dans leur transition numérique, avec un accent particulier sur la qualité, la fiabilité, la sécurité et l’efficacité.",
        ),
        p("2. Présentation de KESE", "SectionTitle"),
        p(
            "KESE est une solution technologique innovante développée par D-Square Technologies afin d’accompagner les petites, "
            "moyennes et grandes entreprises dans la gestion intelligente et moderne de leurs activités commerciales.",
        ),
        p(
            "L’application simplifie les tâches complexes, automatise plusieurs opérations quotidiennes et aide les entrepreneurs "
            "à gérer efficacement leur business depuis n’importe quel endroit.",
        ),
        p("3. Plateformes disponibles", "SectionTitle"),
        bullets(["Version Desktop", "Version Web", "Version Android"]),
        p(
            "Toutes les versions sont conçues pour rester connectées entre elles lorsque la synchronisation cloud est configurée, "
            "afin d’assurer la continuité des opérations et la mise à jour des données.",
        ),
        p("4. Modalités d’activation", "SectionTitle"),
        bullets(
            [
                "Le premier appareil peut être activé avec le code licence, le nom de l’entreprise, l’identifiant administrateur et le code secret.",
                "La base locale doit être créée dès l’activation afin de conserver la licence, l’entreprise, les utilisateurs et les opérations.",
                "L’adresse cloud peut être fournie dès le départ pour une activation en ligne, ou plus tard au moment de la synchronisation.",
                "Les autres appareils peuvent être rattachés avec la clé entreprise et les identifiants existants.",
                "L’adresse cloud de référence doit être gérée par le créateur ou par le responsable autorisé, afin de préserver la cohérence des données.",
            ]
        ),
        p("5. Fonctionnement hors ligne", "SectionTitle"),
        p(
            "KESE doit permettre de travailler localement même lorsque la connexion Internet n’est pas disponible. Dans ce cas, les opérations "
            "sont enregistrées dans la base locale de l’appareil. Au redémarrage, l’utilisateur ne doit pas ressaisir la licence ; il doit seulement "
            "ouvrir sa session avec son identifiant et son code secret.",
        ),
        p("6. Synchronisation cloud", "SectionTitle"),
        p(
            "Lorsque la connexion est disponible, l’utilisateur peut lancer la synchronisation. Si l’adresse cloud n’a pas encore été fournie, "
            "l’application la demande à ce moment-là. Les données locales sont alors envoyées vers le serveur cloud configuré, puis les autres "
            "appareils rattachés peuvent récupérer les données synchronisées.",
        ),
        p("7. Fonctionnalités principales", "SectionTitle"),
        bullets(
            [
                "gestion complète des ventes ;",
                "gestion des produits et des stocks ;",
                "comptabilité simplifiée ;",
                "gestion des factures, tickets et paiements ;",
                "gestion des dépenses, revenus, clients, fournisseurs et crédits ;",
                "gestion des utilisateurs, rôles et équipes ;",
                "chat interne entre utilisateurs d’une même entreprise ;",
                "synchronisation automatique des données ;",
                "sauvegarde et sécurisation des informations ;",
                "accès centralisé aux données de l’entreprise.",
            ]
        ),
        PageBreak(),
        p("8. Guide d’utilisation rapide", "SectionTitle"),
        bullets(
            [
                "Connectez-vous avec le rôle approprié : administrateur, gestionnaire ou caissier.",
                "Configurez les informations de l’entreprise : nom commercial, contacts, adresse, mentions et logo.",
                "Enregistrez les produits, catégories, prix, unités, images et seuils d’alerte.",
                "Contrôlez le stock initial et les mouvements avant les ventes réelles.",
                "Dans Vendre, sélectionnez les produits, vérifiez le panier, le client, la remise et le mode de paiement.",
                "Pour une vente à crédit, renseignez l’échéance afin d’assurer le suivi.",
                "Après validation, vérifiez le ticket, la facture, l’impression ou l’export PDF.",
                "Consultez la caisse, les bénéfices, les dépenses, les achats, les crédits et les rapports.",
                "Utilisez Messages pour les relances, instructions et communications internes.",
                "En mode hors ligne, continuez à travailler puis utilisez Synchroniser dès que la connexion revient.",
            ]
        ),
        p("9. Bonnes pratiques", "SectionTitle"),
        bullets(
            [
                "ne partagez jamais les codes secrets hors du cadre autorisé ;",
                "vérifiez les ventes, paiements et dettes avant validation ;",
                "synchronisez régulièrement les appareils ;",
                "conservez la clé entreprise pour rattacher les nouveaux appareils ;",
                "signalez immédiatement toute anomalie de données, de licence ou de connexion.",
            ]
        ),
        p("10. Contacts de référence", "SectionTitle"),
        contact_block(),
        Spacer(1, 12),
        *architect_card(),
        p(
            "KESE est un partenaire technologique conçu pour accompagner l’évolution des entreprises modernes, améliorer "
            "l’organisation interne, réduire les erreurs et renforcer la performance commerciale.",
            "Small",
        ),
    ]
    pdf = doc(OUT / "KESE-Modalites-activation-guide-utilisation.pdf", "Modalités d’activation et guide complet")
    pdf.build(story, onFirstPage=footer, onLaterPages=footer)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    build_confidentiality()
    build_activation_guide()
    print(OUT / "KESE-Conditions-internes-confidentialite.pdf")
    print(OUT / "KESE-Modalites-activation-guide-utilisation.pdf")


if __name__ == "__main__":
    main()
