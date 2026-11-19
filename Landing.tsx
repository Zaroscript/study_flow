import React, { useRef, useState, useEffect } from 'react';
import {
  ArrowUpRight, ArrowDown, Check, Plus, Play, Pause,
  Menu, X, ChevronDown, FileText, CheckCheck, Timer, Sparkles, CalendarDays, BookOpen,
  Target, Globe2, Trophy, Flame, Crown, ShieldCheck, Volume2, VolumeX,
  Download, Smartphone
} from 'lucide-react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import { useGSAP } from '@gsap/react';
import './landing.css';
import { applyLandingHead, landingPath, languageFromPath } from './landing-head';

gsap.registerPlugin(useGSAP, ScrollTrigger);

type Language = 'ar' | 'en';

/**
 * Authentic mechanical flip sound synthesized via Web Audio API.
 * High-precision, zero asset latency, fails gracefully.
 */
function playMechanicalTick() {
  try {
    const AudioCtx = window.AudioContext || (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext;
    if (!AudioCtx) return;
    const ctx = new AudioCtx();
    if (ctx.state === 'suspended') ctx.resume();
    const now = ctx.currentTime;
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    const filter = ctx.createBiquadFilter();

    osc.type = 'triangle';
    osc.frequency.setValueAtTime(160, now);
    osc.frequency.exponentialRampToValueAtTime(36, now + 0.032);

    filter.type = 'lowpass';
    filter.frequency.setValueAtTime(950, now);

    gain.gain.setValueAtTime(0.045, now);
    gain.gain.exponentialRampToValueAtTime(0.0001, now + 0.032);

    osc.connect(filter);
    filter.connect(gain);
    gain.connect(ctx.destination);

    osc.start(now);
    osc.stop(now + 0.032);
  } catch {}
}

const copy = {
  ar: {
    nav: ['الفكرة', 'المميزات', 'أسئلة شائعة'], lang: 'English', navTeam: 'الفريق', getCta: 'احصل على ENote',
    headline: ['مساحة لأفكارك.', 'وقت لإنجازك.'], intro: 'كل اللي في بالك، له مكان. نظّم مذكراتك وملازمك، جهّز خططك بأدوات المذاكرة، واكسب المكافآت مع ENote.', explore: 'اكتشف ENote', note: 'ملاحظات · خطط · مساعد دراسي · ساعة 3D · مكافآت · إيقاعك أنت.',
    floatNote: 'الفكرة الحلوة؟ اكتبها.', floatTask: 'خطوة صغيرة. فرق كبير.', floatFocus: 'ساعة بومودورو 3D.', floatAi: 'مساعد دراسي ✦',
    strip: ['أفكار تستاهل مكان', 'خطط على مقاس يومك', 'مساعد دراسي', 'تركيز ميكانيكي غامر', 'مكتبة ملازم منظمة', 'مكافآت وأوسمة تحفيزية'],
    storyTitle: ['من زحمة الأفكار،', 'لوضوح الخطوة الجاية.'], storyBody: 'بين المحاضرة، الفكرة المفاجئة، وتراكم الملازم… ENote يجمع كل أدوات دراستك وتفوقك في مساحة واحدة هادئة ومحفزة.',
    features: [
      ['اكتب قبل ما الفكرة تطير.', 'ملاحظاتك كاملة، مرتبة في مجلدات، وتوصل لها بالبحث وقت ما تحتاجها.'],
      ['يومك، خطوة بخطوة.', 'رتّب المهام والمواعيد والواجبات. خلّي خطتك واضحة، وسيب مساحة لليوم نفسه.'],
      ['ساعة بومودورو 3D القلابة.', 'حركة ميكانيكية واقعية مع صوت تكتكة اختياري وجلسات تركيز غامرة تفصلك عن أي تشتت.'],
      ['أدوات مساعدة دراسية.', 'جهّز خطة للمذاكرة، جرّب أسئلة تدريبية، واستخرج نقاطًا من ملاحظاتك باستخدام أدوات محلية واضحة المصدر.'],
      ['مكتبة الملازم والكتب.', 'نظّم مذكراتك وكتبك حسب المواد، وتابع صفحات قراءتك صفحة بصفحة مع احتفال عند الختم.'],
      ['نظام المكافآت والأوسمة.', 'حوّل مذاكرتك إلى رحلة مشوقة؛ اكسب نقاط الخبرة (XP)، ارتقِ بالمستويات، واجمع أوسمة الإنجاز.']
    ],
    tasks: ['مراجعة محاضرة الفيزياء', 'قراءة فصل من كتاب الأحياء', 'حل واجب الرياضيات'],
    start: 'ابدأ المؤقت', pause: 'وقفة صغيرة',
    aiQuizQ: 'س: ما هي وحدة قياس القوة في النظام الدولي (SI)؟',
    aiQuizOpts: ['نيوتن (Newton)', 'جول (Joule)', 'واط (Watt)'],
    materialsBook: 'كتاب التفاضل والتكامل الرسمي 2026',
    materialsSubject: 'رياضيات بحتة 📐',
    rewardsLevel: 'المستوى 5 · متفوق منظم',
    rewardsStreak: '7 أيام متتالية!',
    rewardsClaim: 'احصل على مكافأة الالتزام (+50 XP)',
    rewardsClaimed: 'تمت إضافة +50 XP! استمر في الإنجاز ✨',
    extrasTitle: 'تجربة متكاملة مصممة للإنجاز والتفوق.',
    extras: [
      ['أدوات مساعدة دراسية ✦', 'قوالب خطط وتدريبات وأدوات استخراج نقاط من النص، كلها محلية على جهازك وتظهر كل نتيجة بتوضيح صريح لمصدرها.'],
      ['ساعة بومودورو 3D القلابة', 'آلية flip ميكانيكية واقعية مع صوت التكتكة وضبط التركيز في بيئة دراسية غامرة.'],
      ['مكتبة الملازم والكتب', 'نظّم ملفاتك ومذكراتك في مجلدات لكل مادة دراسية وتابع عدد الصفحات المنجزة صفحة بصفحة.'],
      ['نظام مكافآت وأوسمة تحفيزية', 'اجمع نقاط الخبرة XP، نافس نفسك في مستويات متصاعدة، وافتح أوسمة الإنجاز مع كل خطوة.'],
      ['شاشات ترحيب مخصّصة لك', 'تجربة إعداد مبهرة وسلسة تنقلك مباشرة من أول فتحة للتطبيق لتحديد هدفك ومرحلتك.'],
      ['بيانات محلية وخيارات واضحة', 'المذكرات تُحفظ على جهازك ولا تُرسل إلى أي مكان. التفاصيل في سياسة الخصوصية.']
    ],
    getTitle: 'احصل على ENote.', getBody: 'ثبّته على موبايلك الأندرويد في 3 خطوات.',
    androidTitle: 'ENote لأندرويد', androidSoon: 'نسخة أندرويد قيد التجهيز، وهتلاقي زر التنزيل هنا أول ما تجهز.', getApk: 'نزّل ملف الـ APK',
    installTitle: 'التثبيت في 3 خطوات',
    installSteps: ['نزّل ملف الـ APK من الزر أعلاه.', 'افتح الملف. لو طلب أندرويد السماح بالتثبيت من هذا المصدر فوافق، لأن التطبيق غير منشور على Google Play بعد.', 'افتح ENote واكتب أول فكرة.'],
    footerGet: 'التنزيل', footerTeam: 'الفريق',
    teamTitle: ['اتعمل بإيد طلبة،', 'علشان الطلبة.'],
    teamBody: 'ENote من تطوير طلبة في الصف الثاني الثانوي. التطبيق وواجهته من شغلهم.',
    teamRole: 'تطوير التطبيق وواجهته', teamGrade: 'الصف الثاني الثانوي',
    faqTitle: 'كل ما تحتاج معرفته.',
    faqs: [
      ['كيف أثبّت تطبيق أندرويد؟', 'نزّل ملف الـ APK من هذه الصفحة وافتحه. التطبيق غير منشور على Google Play بعد، فقد يطلب أندرويد السماح بالتثبيت من هذا المصدر. ملف الـ APK في هذه الصفحة موقّع بمفتاح إصدار، وبصمته (SHA-256) مكتوبة في وصف الإصدار على GitHub لمن يحب يتحقق منه.'],
      ['كيف تعمل أدوات المساعد الدراسي؟', 'المساعد الدراسي يعمل بقوالب محلية على جهازك، وتُعرض كل نتيجة مع بيان مصدرها. لا توجد خدمة ذكاء اصطناعي خارجية، ولا يُرسل أي نص تكتبه إلى أي مكان.'],
      ['أين ذهبت صفحة الإحصائيات؟', 'تم دمج جميع الرسوم البيانية وإحصائيات الأداء الأسبوعي وتوزيع الوقت مباشرة داخل صفحة «الرئيسية» في لوحة التحكم، واستُبدلت في شريط التنقل بصفحة «المكافآت والجوائز» لمتابعة أوسمتك ونقاط خبرتك.'],
      ['ما هي ساعة بومودورو 3D القلابة؟', 'تصميم skeuomorphic مبتكر لمؤقت التركيز يحاكي الساعات الميكانيكية الكلاسيكية بأرقام ثلاثية الأبعاد تقلب بسلاسة مع صوت تكتكة اختياري لتهيئة ذهنك لأعمق درجات التركيز.'],
      ['كيف تساعدني مكتبة الملازم في متابعة دراستي؟', 'تمكنك من تصنيف مذكراتك وكتبك حسب المواد في مجلدات ملونة، وتحديث عدد الصفحات المقروءة بأزرار سريعة (+5 و -5 وتحديد الصفحة)، مع شريط تقدم واحتفال عند ختم المرجع 100%.'],
      ['هل التطبيق يدعم اللغتين العربية والإنجليزية؟', 'نعم، التطبيق بالكامل يدعم اللغتين العربية والإنجليزية مع اتجاه كتابة RTL و LTR متقن وتنسيقات طباعية مريحة للعين.']
    ],
    cta: ['أفكار أكتر.', 'دوشة أقل.'], ctaBody: 'اعمل مساحة للي يهمك. والبداية؟ خطوة واحدة.', footer: 'مساحة لأفكارك، على إيقاعك.', top: 'ارجع لأول الصفحة', menu: 'قائمة التنقل', previewStatus: 'الوقت في المعاينة توضيحي',
  },
  en: {
    nav: ['The idea', 'Features', 'Questions'], lang: 'العربية', navTeam: 'Team', getCta: 'Get ENote',
    headline: ['Room for ideas.', 'Time for you.'], intro: 'Give everything on your mind a place. Capture your notes, organize study materials, generate study assistance plans, and earn rewards — with ENote.', explore: 'Meet ENote', note: 'Notes · Plans · Study assistant · 3D Clock · Rewards · Your rhythm.',
    floatNote: 'Good idea? Keep it.', floatTask: 'Small steps. Big difference.', floatFocus: '3D Flip Clock Pomodoro.', floatAi: 'Study assistant ✦',
    strip: ['Ideas worth keeping', 'Plans that fit your day', 'Local study tools', 'Mechanical 3D focus', 'Organized materials hub', 'Gamified reward badges'],
    storyTitle: ['From a busy mind,', 'to a clear next step.'], storyBody: 'The lecture, the sudden idea, the pile of handouts to finish… ENote brings all your study essentials together into one serene workspace.',
    features: [
      ['Catch it before it goes.', 'Keep full notes in folders, and find the thought you need with instant search.'],
      ['Your day. Step by step.', 'Organize tasks, schedules, and homework. Make a clear plan with room for life.'],
      ['3D Mechanical Flip Clock.', 'Authentic mechanical card flips with optional clockwork ticking and immersive focus sessions.'],
      ['Study tools with clear sources.', 'Build a study plan, extract points from notes and practice recall using clearly labelled local tools.'],
      ['Materials & Textbooks Hub.', 'Organize subject handouts in color-coded folders and track page-by-page reading progress.'],
      ['Gamified Rewards & Trophies.', 'Turn your study journey into an inspiring adventure with XP, levels, and collectible achievement badges.']
    ],
    tasks: ['Review Physics Unit 1', 'Read Biology Chapter 3', 'Complete Calculus problem set'],
    start: 'Start timer', pause: 'Take a pause',
    aiQuizQ: 'Q: What is the International System (SI) unit of force?',
    aiQuizOpts: ['Newton (N)', 'Joule (J)', 'Watt (W)'],
    materialsBook: 'Official Calculus & Analysis Coursebook 2026',
    materialsSubject: 'Pure Mathematics 📐',
    rewardsLevel: 'Level 5 · Organized Achiever',
    rewardsStreak: '7-Day Study Streak!',
    rewardsClaim: 'Claim Daily Streak Bonus (+50 XP)',
    rewardsClaimed: '+50 XP claimed! Keep up the momentum ✨',
    extrasTitle: 'Crafted for seamless learning and achievement.',
    extras: [
      ['Local Study Tools ✦', 'Study templates and note extraction, all running on your device, with every result labelled.'],
      ['3D Mechanical Flip Clock', 'Authentic mechanical card flips, optional clockwork ticks, and distraction-free focus sprints.'],
      ['Smart Materials & Books Hub', 'Color-coded subject folders and page-by-page progress trackers with celebratory badges.'],
      ['Gamified Rewards & Levels', 'Earn XP, level up your academic rank, and collect shiny achievement badges for your daily consistency.'],
      ['Personalized Onboarding', 'Smooth multi-step onboarding that tailors your academic level and study targets in seconds.'],
      ['Local storage, clear choices', 'Notes are stored on your device and are not sent anywhere. See our privacy notice.']
    ],
    getTitle: 'Get ENote.', getBody: 'Install it on your Android phone in three steps.',
    androidTitle: 'ENote for Android', androidSoon: 'The Android release is in preparation. The download button will appear here when it is ready.', getApk: 'Download the APK',
    installTitle: 'Install in 3 steps',
    installSteps: ['Download the APK with the button above.', 'Open the file. If Android asks to allow installs from this source, allow it. The app is not on Google Play yet.', 'Open ENote and write your first note.'],
    footerGet: 'Download', footerTeam: 'Team',
    teamTitle: ['Built by students,', 'for students.'],
    teamBody: 'ENote is built by second-year secondary school students: the app and its interface are their work.',
    teamRole: 'App and interface development', teamGrade: 'Second-year secondary school',
    faqTitle: 'Frequently asked questions.',
    faqs: [
      ['How do I install the Android app?', 'Download the APK from this page and open it. The app is not on Google Play yet, so Android may ask you to allow installs from this source. The APK on this page is signed with a release key, and its SHA-256 is listed in the release notes on GitHub if you want to verify it.'],
      ['How do the study tools work?', 'The study assistant works from local templates on your device, and every result says where it comes from. There is no external AI service, and nothing you write is sent anywhere.'],
      ['Where did the Statistics page go?', 'All weekly performance charts and time distribution analytics are now integrated directly into the Dashboard page, and replaced in navigation with the new Rewards & Trophies screen.'],
      ['What is the 3D Flip Clock Pomodoro?', 'It is a skeuomorphic focus timer inspired by vintage mechanical split-flap clocks, featuring physical depth, smooth flipping animation, and optional mechanical ticking sound.'],
      ['How does the Materials Hub track reading progress?', 'You can organize handouts and PDFs by subject folder and update read pages using quick -5 and +5 buttons or direct page entry, complete with celebratory 100% badges.'],
      ['Does it support both Arabic and English?', 'Yes, the entire application natively supports both Arabic (RTL) and English (LTR) with meticulous typography and responsive ergonomics.']
    ],
    cta: ['More ideas.', 'Less noise.'], ctaBody: 'Make room for what matters. It starts with one small step.', footer: 'A space for your mind. A rhythm of your own.', top: 'Back to top', menu: 'Navigation menu', previewStatus: 'Sample preview timer',
  },
};

function Phone({ language }: { language: Language }) {
  const ar = language === 'ar';
  return (
    <div className="lp-phone" dir={ar ? 'rtl' : 'ltr'} aria-label={ar ? 'تصوّر توضيحي لواجهة ENote' : 'Illustrative ENote interface'}>
      <div className="lp-phone-status"><span>9:41</span><span className="lp-island"/><span>••• ▰</span></div>
      <div className="lp-phone-heading"><div><small>{ar ? 'مساحة جديدة ليومك' : 'A fresh space for your day'}</small><b className="lp-phone-title">{ar ? 'صباح الأفكار الحلوة' : 'Hello, fresh ideas'}</b></div><span className="lp-avatar">A</span></div>
      <div className="lp-phone-date"><CalendarDays size={15}/>{ar ? 'الأربعاء، يوم على مزاجك' : 'Wednesday, at your own pace'}</div>
      <div className="lp-phone-focus"><div><Timer size={21}/><span>{ar ? 'وقت للتركيز' : 'A moment to focus'}</span></div><strong>25:00</strong><span className="lp-phone-start"><Play size={12} fill="currentColor"/>{ar ? 'ابدأ جلستك' : 'Start a session'}</span></div>
      <div className="lp-phone-section"><b>{ar ? 'خطوتك الجاية' : 'Your next step'}</b><Plus size={17}/></div>
      {[ar ? 'مراجعة محاضرة الفيزياء' : 'Review physics lecture', ar ? 'قراءة ٢٠ صفحة ملازم' : 'Read 20 pages'].map((title, i) => (
        <div className="lp-phone-task" key={title}>
          <span className={i ? 'lp-small-check' : 'lp-small-check checked'}>{!i && <Check size={11}/>}</span>
          <span>{title}<small>{ar ? 'مساحة للتعلّم' : 'Room to learn'}</small></span>
          <span className="lp-task-dot"/>
        </div>
      ))}
      <div className="lp-phone-section"><b>{ar ? 'فكرة تستاهل' : 'One to keep'}</b><FileText size={16}/></div>
      <div className="lp-phone-note">
        <span>{ar ? 'أفكار المشروع الجديد' : 'New project ideas'}</span>
        <p>{ar ? 'مش لازم تكون الفكرة كاملة… المهم تبدأ.' : 'It doesn’t have to be perfect. It just needs a start.'}</p>
        <small>{ar ? 'أفكار شخصية' : 'Personal notes'}</small>
      </div>
      <div className="lp-phone-nav"><span><BookOpen size={18}/></span><CalendarDays size={18}/><Timer size={18}/><Trophy size={18}/></div>
    </div>
  );
}

type ReleaseInfo = { version: string; apkUrl: string; sha256: string; sizeBytes: number };
const RELEASE_URL = /^https:\/\/github\.com\/Zaroscript\/study_flow\/releases\/(?:latest\/download|download\/[A-Za-z0-9._-]+)\/ENote[A-Za-z0-9._-]*\.apk$/;

// Only accept a manifest written by the release pipeline: verified fields, official release host.
function parseRelease(data: unknown): ReleaseInfo | null {
  if (!data || typeof data !== 'object') return null;
  const r = data as Record<string, unknown>;
  if (r.available !== true) return null;
  if (typeof r.version !== 'string' || !/^\d+\.\d+\.\d+$/.test(r.version)) return null;
  if (typeof r.apkUrl !== 'string' || !RELEASE_URL.test(r.apkUrl)) return null;
  if (typeof r.sha256 !== 'string' || !/^[a-f0-9]{64}$/.test(r.sha256)) return null;
  if (typeof r.sizeBytes !== 'number' || !(r.sizeBytes > 0)) return null;
  return { version: r.version, apkUrl: r.apkUrl, sha256: r.sha256, sizeBytes: r.sizeBytes };
}

export default function Landing() {
  const root = useRef<HTMLDivElement>(null);
  const [language, setLanguage] = useState<Language>(() => {
    try {
      // Language precedence: URL path (/en/ is English) -> ?lang= -> saved choice -> Arabic.
      const fromPath = languageFromPath(location.pathname);
      if (fromPath) return fromPath;
      const requested = new URLSearchParams(location.search).get('lang');
      return requested === 'en' || requested === 'ar' ? requested : localStorage.getItem('enote_landing_language') === 'en' ? 'en' : 'ar';
    } catch {
      return 'ar';
    }
  });
  const [menu, setMenu] = useState(false);
  const [tasks, setTasks] = useState<{ text: string; done: boolean }[]>([]);

  // 3D Flip Clock Pomodoro state
  const [seconds, setSeconds] = useState(25 * 60);
  const [running, setRunning] = useState(false);
  const [soundEnabled, setSoundEnabled] = useState(true);
  const deadline = useRef(0);

  // Materials Hub state
  const [matPages, setMatPages] = useState(145);
  const [matFinished, setMatFinished] = useState(false);

  // Study assistant state
  const [aiTopicInput, setAiTopicInput] = useState('فيزياء: قوانين نيوتن والجاذبية');
  const [aiGeneratedPhases, setAiGeneratedPhases] = useState<{ title: string; time: string }[]>([
    { title: 'استيعاب المفاهيم والقوانين (F = m × a)', time: '40 دقيقة' },
    { title: 'حل مسائل تدريبية وتطبيقات عملية', time: '60 دقيقة' },
    { title: 'اختبار ذاتي واستخلاص القوانين', time: '30 دقيقة' }
  ]);
  const [aiQuizSelection, setAiQuizSelection] = useState<number | null>(null);

  // Gamification & Rewards state
  const [xp, setXp] = useState(1450);
  const [claimedBonus, setClaimedBonus] = useState(false);

  const t = copy[language];
  const ar = language === 'ar';
  const [release, setRelease] = useState<ReleaseInfo | null>(null);

  useEffect(() => {
    const controller = new AbortController();
    fetch('/release.json', { cache: 'no-store', signal: controller.signal })
      .then((res) => (res.ok && (res.headers.get('content-type') || '').includes('json') ? res.json() : null))
      .then((data) => setRelease(parseRelease(data)))
      .catch(() => setRelease(null));
    return () => controller.abort();
  }, []);

  const releaseMb = release ? (release.sizeBytes / 1e6).toFixed(1) : '';
  // With a verified release the Android download is the primary action; without one the page says so honestly.
  const apkButton = (primary: boolean) =>
    release ? (
      <a href={release.apkUrl} className={`lp-button ${primary ? 'lp-button-orange' : 'lp-button-outline'}`} rel="noopener" download>
        <Download size={19} aria-hidden="true" />
        {ar ? 'تنزيل لأندرويد' : 'Download for Android'}
      </a>
    ) : null;
  const primaryActions = release ? (
    apkButton(true)
  ) : (
    <a href="#get" className="lp-button lp-button-orange">
      {t.getCta}
      <ArrowDown size={20} />
    </a>
  );

  useEffect(() => {
    document.documentElement.lang = language;
    document.documentElement.dir = ar ? 'rtl' : 'ltr';
    document.documentElement.style.colorScheme = 'dark';
    applyLandingHead(language);
    try { localStorage.setItem('enote_landing_language', language); } catch {}
    try {
      // Each language has its own URL: "/" (Arabic) and "/en/" (English). Drop the legacy ?lang= parameter.
      const url = new URL(location.href); url.pathname = landingPath(language); url.searchParams.delete('lang'); history.replaceState(null, '', url);
    } catch {}
    setTasks(t.tasks.map((text, i) => ({ text, done: i === 0 })));
    setMenu(false);
    if (language === 'en') {
      setAiTopicInput('Physics: Newton\'s Laws & Gravity');
      setAiGeneratedPhases([
        { title: 'Core Principles & Formulas (F = m × a)', time: '40 mins' },
        { title: 'Applied Practice Problems & Drills', time: '60 mins' },
        { title: 'Self-Quiz & Key Takeaways', time: '30 mins' }
      ]);
    } else {
      setAiTopicInput('فيزياء: قوانين نيوتن والجاذبية');
      setAiGeneratedPhases([
        { title: 'استيعاب المفاهيم والقوانين (F = m × a)', time: '40 دقيقة' },
        { title: 'حل مسائل تدريبية وتطبيقات عملية', time: '60 دقيقة' },
        { title: 'اختبار ذاتي واستخلاص القوانين', time: '30 دقيقة' }
      ]);
    }
  }, [language]);

  // Pomodoro countdown timer tick
  useEffect(() => {
    if (!running) return;
    const update = () => {
      const left = Math.max(0, Math.ceil((deadline.current - Date.now()) / 1000));
      setSeconds(left);
      if (soundEnabled && left > 0) {
        playMechanicalTick();
      }
      if (!left) setRunning(false);
    };
    const id = window.setInterval(update, 1000);
    return () => window.clearInterval(id);
  }, [running, soundEnabled]);

  // Master GSAP animations with matchMedia and ScrollTrigger
  useGSAP(
    () => {
      const cleanups: (() => void)[] = [];
      const mm = gsap.matchMedia();

      mm.add(
        {
          isDesktop: '(min-width: 1000px)',
          isTablet: '(min-width: 600px) and (max-width: 999px)',
          isMobile: '(max-width: 599px)',
          reduceMotion: '(prefers-reduced-motion: reduce)',
        },
        (context) => {
          const { isDesktop, isMobile, reduceMotion } = context.conditions as {
            isDesktop: boolean;
            isTablet: boolean;
            isMobile: boolean;
            reduceMotion: boolean;
          };

          // Accessibility: respect prefers-reduced-motion
          if (reduceMotion) {
            gsap.set('.lp-scroll-progress', { scaleX: 1 });
            return;
          }

          // 1. Top Scroll Progress Indicator tracking whole document
          gsap.to('.lp-scroll-progress', {
            scaleX: 1,
            ease: 'none',
            scrollTrigger: {
              trigger: document.body,
              start: 'top top',
              end: 'bottom bottom',
              scrub: 0.25,
            },
          });

          // 2. Hero entrance timeline
          const heroTl = gsap.timeline({ defaults: { ease: 'power3.out' } });
          heroTl
            .from('.lp-header', { y: -30, autoAlpha: 0, duration: 0.8 })
            .from('.lp-hero-copy > *', { y: 35, autoAlpha: 0, duration: 0.9, stagger: 0.08 }, '-=0.4')
            .from('.lp-hero-phone-wrap', { y: 60, autoAlpha: 0, scale: 0.92, duration: 1.1, ease: 'back.out(1.3)' }, '-=0.7')
            .from('.lp-floating-wrap', { scale: 0.65, autoAlpha: 0, stagger: 0.12, duration: 0.85, ease: 'back.out(1.8)' }, '-=0.8')
            .from('.lp-orbit', { scale: 0.8, autoAlpha: 0, duration: 1.2, ease: 'power2.out' }, '-=0.9');

          // 3. Parallax Multi-depth Scroll Scrub (Single unified ScrollTrigger)
          const yMult = isMobile ? 0.4 : 1;
          const heroParallax = gsap.timeline({
            scrollTrigger: {
              trigger: '.lp-hero',
              start: 'top top',
              end: 'bottom top',
              scrub: 1,
            },
          });

          heroParallax
            .to('.lp-hero-phone-wrap', { y: -50 * yMult, ease: 'none' }, 0)
            .to(
              '.lp-floating-wrap-note',
              {
                y: -115 * yMult,
                x: isMobile ? 0 : (language === 'ar' ? -15 : 15),
                rotation: isMobile ? 6 : 14,
                ease: 'none',
              },
              0
            )
            .to(
              '.lp-floating-wrap-task',
              {
                y: -150 * yMult,
                x: isMobile ? 0 : (language === 'ar' ? 20 : -20),
                rotation: isMobile ? -5 : -12,
                ease: 'none',
              },
              0
            )
            .to(
              '.lp-floating-wrap-focus',
              {
                y: -80 * yMult,
                x: isMobile ? 0 : (language === 'ar' ? -10 : 10),
                rotation: isMobile ? 4 : 10,
                ease: 'none',
              },
              0
            )
            .to(
              '.lp-floating-wrap-ai',
              {
                y: -125 * yMult,
                x: isMobile ? 0 : (language === 'ar' ? 18 : -18),
                rotation: isMobile ? -4 : -8,
                ease: 'none',
              },
              0
            )
            .to('.lp-orbit', { rotation: 40, scale: 1.06, ease: 'none' }, 0)
            .to('.lp-orbit-two', { rotation: -35, scale: 0.94, ease: 'none' }, 0);

          // 4. Subtle Organic Floating Physics
          gsap.to('.lp-floating-note', {
            y: -9,
            rotation: 2.2,
            duration: 3.4,
            repeat: -1,
            yoyo: true,
            ease: 'sine.inOut',
          });

          gsap.to('.lp-floating-task', {
            y: 11,
            rotation: -2,
            duration: 4.1,
            repeat: -1,
            yoyo: true,
            ease: 'sine.inOut',
            delay: 0.4,
          });

          gsap.to('.lp-floating-focus', {
            y: -8,
            rotation: 1.8,
            duration: 3.1,
            repeat: -1,
            yoyo: true,
            ease: 'sine.inOut',
            delay: 0.8,
          });

          gsap.to('.lp-floating-ai', {
            y: 9,
            rotation: -1.6,
            duration: 3.8,
            repeat: -1,
            yoyo: true,
            ease: 'sine.inOut',
            delay: 0.6,
          });

          gsap.to('.lp-hero-phone', {
            y: -10,
            rotation: -7.5,
            duration: 4.6,
            repeat: -1,
            yoyo: true,
            ease: 'sine.inOut',
          });

          // 5. Strip reveal
          gsap.from('.lp-strip > *', {
            autoAlpha: 0,
            y: 20,
            scale: 0.95,
            stagger: 0.08,
            duration: 0.7,
            ease: 'power2.out',
            scrollTrigger: { trigger: '.lp-strip', start: 'top 85%', once: true },
          });

          // Story section reveal
          const storyTl = gsap.timeline({
            scrollTrigger: { trigger: '.lp-story', start: 'top 80%', once: true },
          });
          storyTl
            .from('.lp-story-orb', { autoAlpha: 0, scale: 0.4, rotation: -80, duration: 1, ease: 'back.out(1.8)' })
            .from('.lp-story h2', { autoAlpha: 0, y: 35, duration: 0.9, ease: 'power3.out' }, '-=0.6')
            .from('.lp-story p', { autoAlpha: 0, y: 25, duration: 0.8, ease: 'power3.out' }, '-=0.5');

          gsap.to('.lp-story-orb', {
            rotation: 160,
            y: 75,
            ease: 'none',
            scrollTrigger: { trigger: '.lp-story', start: 'top bottom', end: 'bottom top', scrub: 1.3 },
          });

          // Feature sections staggered reveal & card animations
          gsap.utils.toArray<HTMLElement>('.lp-feature').forEach((el) => {
            const symbol = el.querySelector('.lp-feature-symbol');
            const h2 = el.querySelector('h2');
            const p = el.querySelector('p');
            const art = el.querySelector('.lp-feature-art');

            const featTl = gsap.timeline({
              scrollTrigger: { trigger: el, start: 'top 78%', once: true },
            });

            featTl
              .from([symbol, h2, p].filter(Boolean), {
                autoAlpha: 0,
                y: 35,
                stagger: 0.1,
                duration: 0.85,
                ease: 'power3.out',
              })
              .from(
                art,
                {
                  autoAlpha: 0,
                  y: 50,
                  scale: 0.9,
                  rotation: 3,
                  duration: 1.1,
                  ease: 'back.out(1.3)',
                },
                '-=0.5'
              );
          });

          // Extras cards stagger reveal
          gsap.from('.lp-extras article', {
            autoAlpha: 0,
            y: 45,
            scale: 0.94,
            duration: 0.85,
            stagger: 0.12,
            ease: 'power3.out',
            scrollTrigger: { trigger: '.lp-extras', start: 'top 75%', once: true },
          });

          // FAQ items stagger reveal
          const faqTl = gsap.timeline({
            scrollTrigger: { trigger: '.lp-faq', start: 'top 75%', once: true },
          });
          faqTl
            .from('.lp-faq h2', { autoAlpha: 0, y: 30, duration: 0.8, ease: 'power3.out' })
            .from(
              '.lp-faq details',
              {
                autoAlpha: 0,
                y: 25,
                duration: 0.7,
                stagger: 0.09,
                ease: 'power2.out',
              },
              '-=0.4'
            );

          // Final CTA section entrance
          const finalTl = gsap.timeline({
            scrollTrigger: { trigger: '.lp-final', start: 'top 80%', once: true },
          });
          finalTl
            .from('.lp-final > img', {
              autoAlpha: 0,
              scale: 0.7,
              rotation: -22,
              duration: 0.9,
              ease: 'back.out(1.7)',
            })
            .from('.lp-final h2', { autoAlpha: 0, y: 35, duration: 0.8, ease: 'power3.out' }, '-=0.5')
            .from('.lp-final p', { autoAlpha: 0, y: 20, duration: 0.8, ease: 'power3.out' }, '-=0.4')
            .from('.lp-final a', { autoAlpha: 0, scale: 0.9, duration: 0.8, ease: 'back.out(1.5)' }, '-=0.4');

          gsap.to('.lp-final-orbit', {
            rotation: 15,
            scale: 1.05,
            ease: 'none',
            scrollTrigger: { trigger: '.lp-final', start: 'top bottom', end: 'bottom top', scrub: 1.5 },
          });

          // 6. Desktop-specific Enhanced Interactions: 3D Card Tilt & Magnetic Button Pull
          if (isDesktop) {
            const magneticButtons = gsap.utils.toArray<HTMLElement>(
              '.lp-button, .lp-nav-cta, .lp-back-top, .lp-scroll, .lp-language, .lp-flip-btn, .lp-reward-claim-btn'
            );

            magneticButtons.forEach((btn) => {
              const onMove = (e: MouseEvent) => {
                const rect = btn.getBoundingClientRect();
                const x = (e.clientX - rect.left - rect.width / 2) * 0.32;
                const y = (e.clientY - rect.top - rect.height / 2) * 0.32;
                gsap.to(btn, { x, y, duration: 0.3, ease: 'power2.out', overwrite: 'auto' });
              };

              const onLeave = () => {
                gsap.to(btn, { x: 0, y: 0, duration: 0.7, ease: 'elastic.out(1.1, 0.4)', overwrite: 'auto' });
              };

              btn.addEventListener('mousemove', onMove);
              btn.addEventListener('mouseleave', onLeave);
              cleanups.push(() => {
                btn.removeEventListener('mousemove', onMove);
                btn.removeEventListener('mouseleave', onLeave);
              });
            });

            const tiltCards = gsap.utils.toArray<HTMLElement>(
              '.lp-phone, .lp-floating-note, .lp-floating-task, .lp-floating-focus, .lp-floating-ai, .lp-paper, .lp-plan-art, .lp-flip-art, .lp-ai-art, .lp-materials-art, .lp-rewards-art, .lp-extras article'
            );

            tiltCards.forEach((card) => {
              const onMove = (e: MouseEvent) => {
                const rect = card.getBoundingClientRect();
                const x = e.clientX - rect.left;
                const y = e.clientY - rect.top;
                const centerX = rect.width / 2;
                const centerY = rect.height / 2;
                const percentX = (x - centerX) / centerX;
                const percentY = (y - centerY) / centerY;

                gsap.to(card, {
                  rotationX: -percentY * 8,
                  rotationY: percentX * 8,
                  transformPerspective: 850,
                  duration: 0.35,
                  ease: 'power2.out',
                  overwrite: 'auto',
                });
              };

              const onLeave = () => {
                gsap.to(card, {
                  rotationX: 0,
                  rotationY: 0,
                  duration: 0.75,
                  ease: 'elastic.out(1, 0.4)',
                  overwrite: 'auto',
                });
              };

              card.addEventListener('mousemove', onMove);
              card.addEventListener('mouseleave', onLeave);
              cleanups.push(() => {
                card.removeEventListener('mousemove', onMove);
                card.removeEventListener('mouseleave', onLeave);
              });
            });
          }
        }
      );

      return () => {
        cleanups.forEach((fn) => fn());
        mm.revert();
      };
    },
    { scope: root, dependencies: [language], revertOnUpdate: true }
  );

  // The tilted feature previews are decorative (aria-hidden).
  // Keep their controls out of the keyboard tab order so focus never lands on content hidden from screen readers.
  useEffect(() => {
    document
      .querySelectorAll<HTMLElement>('.lp-feature-art button, .lp-feature-art a[href], .lp-feature-art input, .lp-feature-art textarea, .lp-feature-art select, .lp-feature-art [tabindex]')
      .forEach((el) => el.setAttribute('tabindex', '-1'));
  });

  // Feature mockups have a natural width of ~370px; on narrow phones scale them to fit instead of cropping them.
  useEffect(() => {
    const arts = Array.from(document.querySelectorAll<HTMLElement>('.lp-feature-art'));
    if (!arts.length || typeof ResizeObserver === 'undefined') return;
    const NATURAL_WIDTH = 372;
    const fit = () =>
      arts.forEach((art) => {
        const scale = Math.min(1, Math.max(0.6, (art.clientWidth - 16) / NATURAL_WIDTH));
        art.style.setProperty('--art-scale', scale.toFixed(3));
      });
    fit();
    const observer = new ResizeObserver(fit);
    arts.forEach((art) => observer.observe(art));
    return () => observer.disconnect();
  }, [language]);

  // Team: cards drop onto the page, then the underline under each name is drawn once.
  useGSAP(
    () => {
      if (matchMedia('(prefers-reduced-motion: reduce)').matches) return;
      const tl = gsap.timeline({ scrollTrigger: { trigger: '.lp-team', start: 'top 70%', once: true } });
      tl.from('.lp-team-copy > *', { autoAlpha: 0, y: 26, stagger: 0.12, duration: 0.8, ease: 'power3.out' })
        .from('.lp-note-card', { autoAlpha: 0, y: 70, rotation: (i: number) => (i === 0 ? -9 : 8), stagger: 0.22, duration: 1, ease: 'power3.out' }, '-=0.5')
        .from('.lp-note-underline path', { strokeDashoffset: 1, stagger: 0.25, duration: 0.9, ease: 'power2.inOut' }, '-=0.4');
    },
    { scope: root, dependencies: [language], revertOnUpdate: true }
  );

  const handleAddMatPages = (delta: number) => {
    setMatPages((prev) => {
      const next = Math.max(0, Math.min(220, prev + delta));
      setMatFinished(next >= 220);
      return next;
    });
  };

  const minutes = Math.floor(seconds / 60);
  const remainingSecs = seconds % 60;
  const mStr = String(minutes).padStart(2, '0');
  const sStr = String(remainingSecs).padStart(2, '0');

  return (
    <div className="lp" ref={root}>
      {/* 1. Top scroll progress bar */}
      <div className="lp-scroll-progress" aria-hidden="true" />
      <a className="lp-skip" href="#main">
        {ar ? 'انتقل للمحتوى' : 'Skip to content'}
      </a>
      <header className="lp-header">
        <a className="lp-brand" href="#" aria-label="ENote">
          <img src="/assets/icons/icon-96.png" width="42" height="42" alt="" />
          <span>
            ENote<span className="lp-brand-dot">.</span>
          </span>
        </a>
        <nav className={menu ? 'lp-nav is-open' : 'lp-nav'} aria-label={t.menu}>
          {[
            ['idea', t.nav[0]],
            ['features', t.nav[1]],
            ['team', t.navTeam],
            ['questions', t.nav[2]],
          ].map(([id, label]) => (
            <a href={`#${id}`} key={id} onClick={() => setMenu(false)}>
              {label}
            </a>
          ))}
          <div className="lp-nav-mobile-actions">
            <a href="#get" className="lp-button lp-button-orange" onClick={() => setMenu(false)}>
              {t.getCta}
              <ArrowDown size={17} />
            </a>
            
          </div>
        </nav>
        <div className="lp-header-actions">
          <button className="lp-language" onClick={() => setLanguage(ar ? 'en' : 'ar')} aria-label={ar ? 'English · التبديل إلى الإنجليزية' : 'العربية · Switch to Arabic'}>
            <Globe2 size={16} />
            {t.lang}
          </button>
          
          {release ? (
            <a className="lp-nav-cta" href={release.apkUrl} rel="noopener" download>
              <Download size={16} aria-hidden="true" />
              {ar ? 'تنزيل' : 'Download'}
            </a>
          ) : (
            <a className="lp-nav-cta" href="#get">
              {t.getCta}
            </a>
          )}
          <button className="lp-menu" aria-label={t.menu} aria-expanded={menu} onClick={() => setMenu(!menu)}>
            {menu ? <X /> : <Menu />}
          </button>
        </div>
      </header>
      <main id="main">
        <section className="lp-hero" aria-labelledby="hero-title">
          <div className="lp-hero-copy">
            <h1 id="hero-title">
              {t.headline[0]}
              <br />
              <span>{t.headline[1]}</span>
            </h1>
            <p>{t.intro}</p>
            <div className="lp-hero-actions">
              {primaryActions}
              <a href="#features" className="lp-text-link">
                {t.explore}
                <ArrowDown size={17} />
              </a>
            </div>
            <p className="lp-release-status">
              {release ? (
                <>
                  {ar ? (<>الإصدار <bdi dir="ltr">{release.version}</bdi> · <bdi dir="ltr">{releaseMb} MB</bdi> · أندرويد 7.0 فأعلى · </>) : `Version ${release.version} · ${releaseMb} MB · Android 7.0+ · `}
                  <a href="#get">{ar ? 'طريقة التثبيت' : 'How to install'}</a>
                </>
              ) : ar ? (
                'نسخة Android قيد التجهيز.'
              ) : (
                'Android release in preparation.'
              )}
            </p>
            <div className="lp-hero-foot">
              <span className="lp-live-dot" />
              {t.note}
            </div>
          </div>
          <div className="lp-hero-art">
            <div className="lp-orbit" aria-hidden="true" />
            <div className="lp-orbit lp-orbit-two" aria-hidden="true" />

            {/* Note badge with parallax wrap and inner float */}
            <div className="lp-floating-wrap lp-floating-wrap-note">
              <div className="lp-floating lp-floating-note">
                <div className="lp-floating-icon">
                  <FileText size={23} />
                </div>
                <b>{t.floatNote}</b>
                <span className="lp-note-lines">
                  <i />
                  <i />
                  <i />
                </span>
              </div>
            </div>

            {/* Hero phone with parallax wrap and inner organic breathing */}
            <div className="lp-hero-phone-wrap">
              <div className="lp-hero-phone">
                <Phone language={language} />
              </div>
            </div>

            {/* Task badge with parallax wrap and inner float */}
            <div className="lp-floating-wrap lp-floating-wrap-task">
              <div className="lp-floating lp-floating-task">
                <span className="lp-round-check">
                  <Check size={19} />
                </span>
                <b>{t.floatTask}</b>
              </div>
            </div>

            {/* Focus badge with parallax wrap and inner float */}
            <div className="lp-floating-wrap lp-floating-wrap-focus">
              <div className="lp-floating lp-floating-focus">
                <Timer size={20} />
                <b dir="ltr">25:00</b>
                <span>{t.floatFocus}</span>
              </div>
            </div>

            {/* AI Assistant floating badge */}
            <div className="lp-floating-wrap lp-floating-wrap-ai">
              <div className="lp-floating lp-floating-ai">
                <Sparkles size={19} />
                <div>
                  <b>{t.floatAi}</b>
                  <span>{ar ? 'توليد خطة فيزياء ✦' : 'Physics Plan Ready ✦'}</span>
                </div>
              </div>
            </div>

            <span className="lp-art-caption">{ar ? 'تصوّر للواجهة · بيانات تفاعلية حية' : 'Live interactive interface concept'}</span>
          </div>
          <a href="#idea" className="lp-scroll" aria-label={ar ? 'اكتشف الفكرة' : 'Explore the idea'}>
            <ArrowDown size={18} />
          </a>
        </section>

        <div className="lp-strip" role="group" aria-label={ar ? 'مساحة ليومك' : 'Room for your day'}>
          {t.strip.map((text) => (
            <React.Fragment key={text}>
              <span>{text}</span>
              <Sparkles size={21} aria-hidden="true" />
            </React.Fragment>
          ))}
        </div>

        <section className="lp-story lp-section" id="idea">
          <div className="lp-story-orb" aria-hidden="true">
            <span />
            <span />
          </div>
          <h2>
            {t.storyTitle[0]}
            <br />
            <span>{t.storyTitle[1]}</span>
          </h2>
          <p>{t.storyBody}</p>
        </section>

        {/* 6 Features Showcase: Distinct, Dynamic & Non-Duplicated Live Previews */}
        <div className="lp-features lp-section" id="features">
          {t.features.map((f, i) => {
            const featureSymbols = [
              <FileText key="0" />,
              <CheckCheck key="1" />,
              <Timer key="2" />,
              <Sparkles key="3" />,
              <BookOpen key="4" />,
              <Trophy key="5" />
            ];

            return (
              <section className={`lp-feature lp-feature-${i}`} key={i}>
                <div className="lp-feature-copy">
                  <div className="lp-feature-symbol" aria-hidden="true">
                    {featureSymbols[i]}
                  </div>
                  <h2>{f[0]}</h2>
                  <p>{f[1]}</p>
                </div>

                <div className="lp-feature-art" aria-hidden="true">
                  {i === 0 ? (
                    /* Feature 0: Notes Card */
                    <>
                      <div className="lp-paper lp-paper-back" />
                      <div className="lp-paper">
                        <span className="lp-paper-tab" />
                        <FileText size={28} />
                        <h3>{ar ? 'فكرة تستاهل تتكتب.' : 'A thought worth keeping.'}</h3>
                        <p>{ar ? 'إيه لو خلّينا البداية أبسط؟' : 'What if we made the start simpler?'}</p>
                        <div className="lp-paper-rule" />
                        <div className="lp-paper-rule short" />
                        <span className="lp-paper-tag">{ar ? 'أفكار شخصية' : 'Personal ideas'}</span>
                      </div>
                      <span className="lp-art-spark">
                        <Sparkles size={36} />
                      </span>
                    </>
                  ) : i === 1 ? (
                    /* Feature 1: Plan Card */
                    <div className="lp-plan-art">
                      <div className="lp-plan-top">
                        <CalendarDays />
                        <span>{ar ? 'خطوة ورا خطوة.' : 'One step at a time.'}</span>
                      </div>
                      {tasks.slice(0, 3).map((task, j) => (
                        <div
                          className={`lp-plan-row ${task.done ? 'done' : ''}`}
                          key={task.text + j}
                          style={{ cursor: 'pointer' }}
                          onClick={() => {
                            setTasks((prev) =>
                              prev.map((t, idx) => (idx === j ? { ...t, done: !t.done } : t))
                            );
                          }}
                        >
                          <span>{task.done ? <Check size={16} /> : null}</span>
                          <b>{task.text}</b>
                          <small dir="ltr">{['09:00', '11:30', '14:00'][j]}</small>
                        </div>
                      ))}
                      <div className="lp-plan-bottom">
                        <span>
                          {tasks.filter((x) => x.done).length} / {tasks.length || 3}
                        </span>
                        <div>
                          <i
                            style={{
                              width: `${((tasks.filter((x) => x.done).length) / Math.max(1, tasks.length)) * 100}%`,
                              transition: 'width 0.3s ease'
                            }}
                          />
                        </div>
                      </div>
                    </div>
                  ) : i === 2 ? (
                    /* Feature 2: 3D Flip Clock Pomodoro Card */
                    <div className="lp-flip-art">
                      <div className="lp-flip-art-head">
                        <div className="lp-flip-art-status">
                          <span className="dot" />
                          <span>{ar ? 'جلسة تركيز عميق' : 'Deep Focus Sprint'}</span>
                        </div>
                        <div className="lp-tick-eq active">
                          <span /><span /><span /><span />
                        </div>
                      </div>

                      <div className="lp-flip-card-preview" dir="ltr">
                        <div className="lp-flip-digit">{mStr}</div>
                        <div className="lp-flip-sep">:</div>
                        <div className="lp-flip-digit">{sStr}</div>
                      </div>

                      <div className="lp-flip-art-actions">
                        <button
                          type="button"
                          className={`lp-flip-btn ${running ? 'active' : ''}`}
                          onClick={() => {
                            if (!running) {
                              deadline.current = Date.now() + (seconds || 1500) * 1000;
                            }
                            setRunning(!running);
                            if (soundEnabled) playMechanicalTick();
                          }}
                        >
                          {running ? <Pause size={14} /> : <Play size={14} fill="currentColor" />}
                          {running ? t.pause : t.start}
                        </button>
                        <button
                          type="button"
                          className="lp-flip-sound-btn"
                          title={soundEnabled ? (ar ? 'كتم التكتكة' : 'Mute Ticking') : (ar ? 'تشغيل التكتكة' : 'Enable Ticking')}
                          onClick={() => {
                            const next = !soundEnabled;
                            setSoundEnabled(next);
                            if (next) playMechanicalTick();
                          }}
                        >
                          {soundEnabled ? <Volume2 size={16} /> : <VolumeX size={16} />}
                        </button>
                      </div>
                    </div>
                  ) : i === 3 ? (
                    /* Feature 3: Study assistant card */
                    <div className="lp-ai-art">
                      <div className="lp-ai-art-head">
                        <span className="lp-ai-art-badge">
                          <Sparkles size={13} />
                          {ar ? 'مساعد دراسي ✦' : 'Study tools ✦'}
                        </span>
                        <small style={{ color: '#94a3b8', fontSize: '10px' }}>{ar ? 'معاينة توضيحية' : 'Sample preview'}</small>
                      </div>

                      <div className="lp-ai-art-topic">
                        <span>{ar ? 'موضوع الخطة:' : 'Study Topic:'} <strong>{aiTopicInput}</strong></span>
                      </div>

                      <div className="lp-ai-art-phases">
                        {aiGeneratedPhases.map((phase) => (
                          <div className="lp-ai-art-phase" key={phase.title}>
                            <strong>{phase.title}</strong>
                            <span>{phase.time}</span>
                          </div>
                        ))}
                      </div>

                      <div className="lp-ai-art-quiz">
                        <div className="lp-ai-art-quiz-q">{t.aiQuizQ}</div>
                        <div className="lp-ai-art-quiz-btns">
                          {t.aiQuizOpts.map((opt, optIdx) => (
                            <button
                              key={opt}
                              type="button"
                              className={`lp-ai-quiz-chip ${
                                aiQuizSelection === optIdx
                                  ? optIdx === 0
                                    ? 'correct'
                                    : 'wrong'
                                  : ''
                              }`}
                              onClick={() => {
                                setAiQuizSelection(optIdx);
                                if (soundEnabled) playMechanicalTick();
                              }}
                            >
                              {opt}
                            </button>
                          ))}
                        </div>
                      </div>
                    </div>
                  ) : i === 4 ? (
                    /* Feature 4: Materials & Books Hub Card */
                    <div className="lp-materials-art">
                      <div className="lp-materials-art-head">
                        <span className="lp-materials-badge">
                          <BookOpen size={13} />
                          {t.materialsSubject}
                        </span>
                        <small style={{ color: '#64748b', fontSize: '11px', fontWeight: '700' }}>PDF · 220 {ar ? 'صفحة' : 'pages'}</small>
                      </div>

                      <div className="lp-materials-art-title">
                        {t.materialsBook}
                      </div>

                      <div className="lp-materials-art-info">
                        <span>{ar ? 'تقدم القراءة:' : 'Reading Progress:'}</span>
                        <strong>{matPages} / 220 {ar ? 'صفحة' : 'pages'} ({Math.round((matPages / 220) * 100)}%)</strong>
                      </div>

                      <div className="lp-mat-progress-bar">
                        <div
                          className={`lp-mat-progress-fill ${matFinished ? 'done' : ''}`}
                          style={{ width: `${(matPages / 220) * 100}%` }}
                        />
                      </div>

                      <div className="lp-materials-art-controls">
                        <button type="button" onClick={() => handleAddMatPages(-5)}>
                          -5 {ar ? 'صفحات' : 'pg'}
                        </button>
                        <button type="button" onClick={() => handleAddMatPages(5)}>
                          +5 {ar ? 'صفحات' : 'pg'}
                        </button>
                        <button
                          type="button"
                          className="primary"
                          onClick={() => {
                            setMatPages(220);
                            setMatFinished(true);
                            if (soundEnabled) playMechanicalTick();
                          }}
                        >
                          {ar ? '✓ ختم المرجع' : '✓ Finish Book'}
                        </button>
                      </div>
                    </div>
                  ) : (
                    /* Feature 5: Gamified Rewards & Badges Card */
                    <div className="lp-rewards-art">
                      <div className="lp-rewards-art-head">
                        <span className="lp-rewards-level-pill">
                          <Crown size={14} />
                          {t.rewardsLevel}
                        </span>
                        <span className="lp-rewards-streak-pill">
                          <Flame size={14} />
                          {t.rewardsStreak}
                        </span>
                      </div>

                      <div className="lp-rewards-xp-row">
                        <div className="lp-rewards-xp-labels">
                          <span>{ar ? 'نقاط الخبرة (XP):' : 'Experience Points:'}</span>
                          <strong>{xp.toLocaleString()} / 2,000 XP</strong>
                        </div>
                        <div className="lp-rewards-xp-track">
                          <div
                            className="lp-rewards-xp-fill"
                            style={{ width: `${(xp / 2000) * 100}%` }}
                          />
                        </div>
                      </div>

                      <div className="lp-rewards-badges-grid">
                        <div className="lp-reward-badge-card">
                          <span className="lp-reward-badge-icon">🏆</span>
                          <span className="lp-reward-badge-name">{ar ? 'سيد التركيز' : 'Focus Master'}</span>
                          <span className="lp-reward-badge-status">{ar ? 'مكتمل ✦' : 'Unlocked ✦'}</span>
                        </div>
                        <div className="lp-reward-badge-card">
                          <span className="lp-reward-badge-icon">📚</span>
                          <span className="lp-reward-badge-name">{ar ? 'قارئ شغوف' : 'Avid Reader'}</span>
                          <span className="lp-reward-badge-status">{ar ? 'مكتمل ✦' : 'Unlocked ✦'}</span>
                        </div>
                        <div className="lp-reward-badge-card">
                          <span className="lp-reward-badge-icon">⚡</span>
                          <span className="lp-reward-badge-name">{ar ? 'عقل مفكر' : 'AI Mind'}</span>
                          <span className="lp-reward-badge-status">{ar ? 'مكتمل ✦' : 'Unlocked ✦'}</span>
                        </div>
                      </div>

                      <button
                        type="button"
                        className="lp-reward-claim-btn"
                        onClick={() => {
                          if (!claimedBonus) {
                            setXp((prev) => Math.min(2000, prev + 50));
                            setClaimedBonus(true);
                            if (soundEnabled) playMechanicalTick();
                          }
                        }}
                      >
                        <Sparkles size={14} />
                        {claimedBonus ? t.rewardsClaimed : t.rewardsClaim}
                      </button>
                    </div>
                  )}
                </div>
              </section>
            );
          })}
        </div>

        {/* Extras: 6 Distinct Icons for 6 Items */}
        <section className="lp-extras lp-section">
          <h2>{t.extrasTitle}</h2>
          <div>
            {t.extras.map((e, i) => {
              const extraIcons = [
                <Sparkles size={29} key="0" />,
                <Timer size={29} key="1" />,
                <BookOpen size={29} key="2" />,
                <Trophy size={29} key="3" />,
                <Target size={29} key="4" />,
                <ShieldCheck size={29} key="5" />
              ];
              return (
                <article key={e[0]}>
                  <span className="lp-extra-icon">{extraIcons[i]}</span>
                  <h3>{e[0]}</h3>
                  <p>{e[1]}</p>
                </article>
              );
            })}
          </div>
        </section>

        <section className="lp-get lp-section" id="get" aria-labelledby="get-title">
          <div className="lp-get-head">
            <h2 id="get-title">{t.getTitle}</h2>
            <p>{t.getBody}</p>
          </div>
          <article className="lp-get-card lp-get-android">
            <h3>
              <Smartphone size={22} aria-hidden="true" />
              {t.androidTitle}
            </h3>
            {release ? (
              <div className="lp-get-cols">
                <div className="lp-get-main">
                  <p className="lp-get-meta">
                    {ar ? (<>الإصدار <bdi dir="ltr">{release.version}</bdi> · <bdi dir="ltr">{releaseMb} MB</bdi> · أندرويد 7.0 فأعلى</>) : `Version ${release.version} · ${releaseMb} MB · Android 7.0+`}
                  </p>
                  <a href={release.apkUrl} className="lp-button lp-button-orange" rel="noopener" download>
                    <Download size={19} aria-hidden="true" />
                    {t.getApk}
                  </a>
                </div>
                <div className="lp-get-guide">
                  <h4>{t.installTitle}</h4>
                  <ol className="lp-get-steps" role="list">
                    {t.installSteps.map((step) => (
                      <li key={step}>{step}</li>
                    ))}
                  </ol>
                </div>
              </div>
            ) : (
              <p className="lp-get-meta">{t.androidSoon}</p>
            )}
          </article>
        </section>

        <section className="lp-team lp-section" id="team" aria-labelledby="team-title">
          <div className="lp-team-copy">
            <h2 id="team-title">
              {t.teamTitle[0]}
              <br />
              <span>{t.teamTitle[1]}</span>
            </h2>
            <p>{t.teamBody}</p>
          </div>
          <ul className="lp-team-notes">
            {(ar ? ['أماني روماني', 'إيريني عاطف'] : ['Amany Romany', 'Ereeny Atef']).map((name, i) => (
              <li className={`lp-note-card lp-note-card-${i}`} key={name}>
                <span className="lp-note-tape" aria-hidden="true" />
                <h3 lang={ar ? 'ar' : 'en'} dir={ar ? 'rtl' : 'ltr'}>
                  <span>{name}</span>
                  <svg className="lp-note-underline" viewBox="0 0 200 12" preserveAspectRatio="none" aria-hidden="true">
                    <path pathLength="1" d="M2 7 C 30 1, 52 11, 82 6 S 142 2, 170 7 S 192 8, 198 5" />
                  </svg>
                </h3>
                <p className="lp-note-role">{t.teamRole}</p>
                <small className="lp-note-grade">{t.teamGrade}</small>
              </li>
            ))}
          </ul>
        </section>

        <section className="lp-faq lp-section" id="questions">
          <h2>{t.faqTitle}</h2>
          <div>
            {t.faqs.map(([q, a]) => (
              <details key={q}>
                <summary>
                  {q}
                  <ChevronDown size={21} />
                </summary>
                <p>{a}</p>
              </details>
            ))}
          </div>
        </section>

        <section className="lp-final">
          <div className="lp-final-orbit" aria-hidden="true" />
          <img src="/assets/icons/icon-192.png" width="94" height="94" alt="" loading="lazy" />
          <h2>
            {t.cta[0]}
            <br />
            <span>{t.cta[1]}</span>
          </h2>
          <p>{t.ctaBody}</p>
          <div className="lp-final-actions">
            {primaryActions}
          </div>
        </section>
      </main>
      <footer className="lp-footer">
        <nav className="lp-footer-links" aria-label={ar ? 'روابط' : 'Links'}>
          <a href="#get">{t.footerGet}</a>
          <a href="#team">{t.footerTeam}</a>
          <a href="/privacy">{ar ? 'الخصوصية' : 'Privacy'}</a>
        </nav>
        <a className="lp-brand" href="#">
          <img src="/assets/icons/icon-96.png" width="34" height="34" alt="" />
          <span>ENote.</span>
        </a>
        <p>{t.footer}</p>
        <a href="#" className="lp-back-top" aria-label={t.top}>
          <ArrowUpRight size={21} />
        </a>
        <span>© {new Date().getFullYear()} ENote</span>
      </footer>
    </div>
  );
}
