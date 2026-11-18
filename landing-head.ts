import seo from './landing-seo.json';

export type LandingLanguage = 'ar' | 'en';

/** "/en" and "/en/..." are the English landing; every other landing path is Arabic. */
export function languageFromPath(pathname: string): LandingLanguage | null {
  return /^\/en(\/|$)/.test(pathname) ? 'en' : null;
}

export const landingPath = (language: LandingLanguage) => seo[language].path;

function setContent(selector: string, value: string) {
  document.querySelector(selector)?.setAttribute('content', value);
}

/**
 * Keeps the head in step with the language the visitor is actually looking at (the language switch is
 * client-side). The static HTML of "/" and "/en/" already carries the right values for crawlers, so on a
 * first load this is an idempotent rewrite; it only changes something after a switch or for ?lang=en on "/".
 */
export function applyLandingHead(language: LandingLanguage) {
  document.documentElement.removeAttribute('data-lang-mismatch'); // set by the early script in index.html
  const s = seo[language];
  const other = seo[language === 'ar' ? 'en' : 'ar'];
  const canonical = document.querySelector<HTMLLinkElement>('link[rel="canonical"]');
  const origin = canonical ? new URL(canonical.href).origin : location.origin;
  const url = `${origin}${s.path}`;
  document.title = s.title;
  setContent('meta[name="description"]', s.description);
  canonical?.setAttribute('href', url);
  setContent('meta[property="og:url"]', url);
  setContent('meta[property="og:title"]', s.ogTitle);
  setContent('meta[property="og:description"]', s.description);
  setContent('meta[property="og:locale"]', s.ogLocale);
  setContent('meta[property="og:locale:alternate"]', other.ogLocale);
  setContent('meta[property="og:image"]', `${origin}${s.ogImage}`);
  setContent('meta[property="og:image:alt"]', s.ogImageAlt);
  setContent('meta[name="twitter:title"]', s.ogTitle);
  setContent('meta[name="twitter:description"]', s.description);
  setContent('meta[name="twitter:image"]', `${origin}${s.ogImage}`);
  setContent('meta[name="twitter:image:alt"]', s.ogImageAlt);
}
