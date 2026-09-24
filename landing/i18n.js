const copy = {
  en: {
    brand: "QR CODE FOUNDRY",
    brandShort: "QR CODE FOUNDRY",
    "nav.features": "Features",
    "nav.how": "How it works",
    "hero.title": "Forge branded QR pages",
    "hero.lead":
      "Design professional QR pages for Wi‑Fi, links, Google reviews and more — then export in HD.",
    "hero.cta": "Get on the App Store",
    "hero.secondary": "See what’s inside",
    "features.title": "Built for real-world QR use",
    "features.sub": "From shop Wi‑Fi to Google reviews — one toolkit, fully on brand.",
    "features.f1.title": "Every essential QR type",
    "features.f1.body":
      "URL, Wi‑Fi, text, email, phone, SMS, contact cards and Google Review pages.",
    "features.f2.title": "Brand your page",
    "features.f2.body": "Add a logo, rewrite titles and buttons, and match your colors.",
    "features.f3.title": "Shape the code",
    "features.f3.body":
      "Square, round or dot modules — plus thin, rounded, bold or double frames.",
    "features.f4.title": "Export HD",
    "features.f4.body":
      "Share your page or save it to Photos in high quality, ready to print or post.",
    "how.title": "Three steps to a forged QR",
    "how.s1": "Pick a QR type and fill in the content.",
    "how.s2": "Customize the page: logo, text, colors, modules and frame.",
    "how.s3": "Export in HD and share or save to Photos.",
    "final.title": "Ready to forge your codes?",
    "final.lead":
      "Download QR CODE FOUNDRY on the App Store and start designing branded pages today.",
    "final.cta": "Download on the App Store",
    "final.note": "App Store link coming soon · Bundle ID com.magicsplitter.qrcodefoundry",
    "footer.brand": "QR CODE FOUNDRY",
    "footer.tag": "Forge your codes",
  },
  fr: {
    brand: "QR CODE LA FABRIQUE",
    brandShort: "QR CODE LA FABRIQUE",
    "nav.features": "Fonctionnalités",
    "nav.how": "Comment ça marche",
    "hero.title": "Forgez des pages QR de marque",
    "hero.lead":
      "Créez des pages QR professionnelles pour le Wi‑Fi, les liens, les avis Google et plus — puis exportez en HD.",
    "hero.cta": "Sur l’App Store",
    "hero.secondary": "Voir le contenu",
    "features.title": "Pensé pour un usage concret",
    "features.sub":
      "Du Wi‑Fi boutique aux avis Google — une seule boîte à outils, 100 % à votre image.",
    "features.f1.title": "Tous les QR essentiels",
    "features.f1.body":
      "URL, Wi‑Fi, texte, e‑mail, téléphone, SMS, carte de visite et pages Avis Google.",
    "features.f2.title": "Votre marque sur la page",
    "features.f2.body":
      "Ajoutez un logo, réécrivez titres et boutons, et calquez vos couleurs.",
    "features.f3.title": "Façonnez le code",
    "features.f3.body":
      "Modules carrés, ronds ou en points — plus cadres fin, arrondi, épais ou double.",
    "features.f4.title": "Export HD",
    "features.f4.body":
      "Partagez votre page ou enregistrez-la dans Photos en haute qualité, prête à imprimer.",
    "how.title": "Trois étapes pour forger un QR",
    "how.s1": "Choisissez un type de QR et renseignez le contenu.",
    "how.s2": "Personnalisez la page : logo, textes, couleurs, motifs et cadre.",
    "how.s3": "Exportez en HD, puis partagez ou enregistrez dans Photos.",
    "final.title": "Prêt à forger vos codes ?",
    "final.lead":
      "Téléchargez QR CODE LA FABRIQUE sur l’App Store et créez des pages de marque dès aujourd’hui.",
    "final.cta": "Télécharger sur l’App Store",
    "final.note": "Lien App Store bientôt disponible · Bundle ID com.magicsplitter.qrcodefoundry",
    "footer.brand": "QR CODE LA FABRIQUE",
    "footer.tag": "Forgez vos codes",
  },
};

function applyLang(lang) {
  const dict = copy[lang] || copy.en;
  document.documentElement.lang = lang;

  document.querySelectorAll("[data-i18n]").forEach((el) => {
    const key = el.getAttribute("data-i18n");
    if (dict[key] != null) el.textContent = dict[key];
  });

  document.title = dict.brand;

  document.querySelectorAll(".lang__btn").forEach((btn) => {
    btn.classList.toggle("is-active", btn.dataset.lang === lang);
  });

  localStorage.setItem("qrf-lang", lang);
}

function init() {
  const saved = localStorage.getItem("qrf-lang");
  const browser = (navigator.language || "en").toLowerCase().startsWith("fr") ? "fr" : "en";
  applyLang(saved || browser);

  document.querySelectorAll(".lang__btn").forEach((btn) => {
    btn.addEventListener("click", () => applyLang(btn.dataset.lang));
  });
}

init();
