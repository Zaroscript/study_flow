import React, { useRef, useState, useEffect, useCallback } from 'react';
import {
  ArrowUpRight, ArrowDown, ArrowLeft, ArrowRight, Check, Plus, Play, Pause, RotateCcw,
  Menu, X, ChevronDown, FileText, CheckCheck, Timer, Sparkles, CalendarDays, BookOpen,
  Target, Moon, Globe2, Trophy, Flame, Crown, Folder, Zap, ShieldCheck, Award, Volume2, VolumeX,
  GraduationCap, Lightbulb, Compass, Star, Download
} from 'lucide-react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import { useGSAP } from '@gsap/react';
import './landing.css';

gsap.registerPlugin(useGSAP, ScrollTrigger);

type Language = 'ar' | 'en';
type Scene = 'notes' | 'plan' | 'focus' | 'ai' | 'materials' | 'rewards';

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
    nav: ['الفكرة', 'المميزات', 'جرّب بنفسك', 'أسئلة شائعة'], open: 'جرّب نسخة الويب', lang: 'English',
    downloadApk: 'تحميل تطبيق أندرويد (APK)', downloadNav: 'تطبيق أندرويد', downloadTag: 'v1.0.0 · 5.8 MB',
    headline: ['مساحة لأفكارك.', 'وقت لإنجازك.'], intro: 'كل اللي في بالك، له مكان. نظّم مذكراتك وملازمك، ولّد خططك بالذكاء الاصطناعي الحقيقي، واكسب المكافآت مع ENote.', explore: 'اكتشف ENote', note: 'ملاحظات · خطط · ذكاء اصطناعي · ساعة 3D · مكافآت · إيقاعك أنت.',
    floatNote: 'الفكرة الحلوة؟ اكتبها.', floatTask: 'خطوة صغيرة. فرق كبير.', floatFocus: 'ساعة بومودورو 3D.', floatAi: 'مساعد ذكي حقيقي ✦',
    strip: ['أفكار تستاهل مكان', 'خطط على مقاس يومك', 'ذكاء اصطناعي حقيقي ومجاني', 'تركيز ميكانيكي غامر', 'مكتبة ملازم منظمة', 'مكافآت وأوسمة تحفيزية'],
    storyTitle: ['من زحمة الأفكار،', 'لوضوح الخطوة الجاية.'], storyBody: 'بين المحاضرة، الفكرة المفاجئة، وتراكم الملازم… ENote يجمع كل أدوات دراستك وتفوقك في مساحة واحدة هادئة ومحفزة.',
    features: [
      ['اكتب قبل ما الفكرة تطير.', 'ملاحظاتك كاملة، مرتبة في مجلدات، وتوصل لها بالبحث وقت ما تحتاجها.', 'مكان لكل فكرة'],
      ['يومك، خطوة بخطوة.', 'رتّب المهام والمواعيد والواجبات. خلّي خطتك واضحة، وسيب مساحة لليوم نفسه.', 'خطة بطريقتك'],
      ['ساعة بومودورو 3D القلابة.', 'حركة ميكانيكية واقعية مع صوت تكتكة اختياري وجلسات تركيز غامرة تفصلك عن أي تشتت.', 'وقت للتركيز'],
      ['مساعد دراسي ذكي حقيقي.', 'توليد خطط مذاكرة في ثوانٍ، تلخيص فوري للمحاضرات، وبنوك أسئلة ذكية مدعومة بنماذج لغوية حقيقية مجاناً.', 'المساعد الذكي'],
      ['مكتبة الملازم والكتب.', 'نظّم مذكراتك وكتبك حسب المواد، وتابع صفحات قراءتك صفحة بصفحة مع احتفال عند الختم.', 'مكتبة الملازم'],
      ['نظام المكافآت والأوسمة.', 'حوّل مذاكرتك إلى رحلة مشوقة؛ اكسب نقاط الخبرة (XP)، ارتقِ بالمستويات، واجمع أوسمة الإنجاز.', 'المكافآت والجوائز']
    ],
    demoTitle: ['إحساسه أحلى', 'لما تجرّبه.'], demoBody: 'اضغط، بدّل، واكتشف. عاين كل ميزات ENote الجديدة مباشرة وتفاعل معها بتجربة حية.',
    tabs: ['ملاحظاتك', 'خطتك', 'ساعة 3D', 'المساعد الذكي', 'مكتبة الملازم', 'المكافآت'], demoLabel: 'معاينة تفاعلية — بيانات توضيحية',
    notesTitle: 'كل فكرة، بداية لحاجة.', noteTitle: 'أفكار للمشروع', noteText: 'الفكرة الكبيرة بتبدأ بملاحظة صغيرة.\n\n• أبسّط الفكرة الأساسية\n• أجهّز أول مسودة\n• أشاركها مع الفريق', save: 'احفظ الملاحظة', saved: 'اتحفظت في المعاينة',
    planTitle: 'خلّي يومك أخف.', tasks: ['مراجعة محاضرة الفيزياء', 'قراءة فصل من كتاب الأحياء', 'حل واجب الرياضيات'], newTask: 'مهمة جديدة', add: 'أضف', completed: 'مكتملة',
    focusTitle: 'ساعة بومودورو 3D القلابة.', focus: 'جلسة تركيز', start: 'ابدأ المؤقت', pause: 'وقفة صغيرة', reset: 'إعادة المؤقت',
    studyMode: 'تركيز (25د)', breakMode: 'استراحة (5د)', longBreakMode: 'استراحة طويلة (15د)',
    aiTitle: 'توليد خطة ذكية واختبار سريع.', aiDesc: 'اكتب المادة وساعات المذاكرة، ودع المساعد الذكي يقسم لك الوقت بمراحل دقيقة واختبارات تفاعلية.', aiGenerate: 'توليد خطة بالذكاء الاصطناعي ✦',
    aiGenerating: 'جاري التفكير والتوليد بالذكاء الاصطناعي...',
    aiPills: ['فيزياء: قوانين نيوتن', 'أحياء: الوراثة والجينات', 'كيمياء: الاتزان والسرعة'],
    aiQuizQ: 'س: ما هي وحدة قياس القوة في النظام الدولي (SI)؟',
    aiQuizOpts: ['نيوتن (Newton)', 'جول (Joule)', 'واط (Watt)'],
    aiQuizCorrect: 'إجابة صحيحة! أحسنت 🎯 (100%)',
    aiQuizWrong: 'إجابة غير صحيحة. الإجابة الصحيحة هي: نيوتن',
    materialsTitle: 'تتبع صفحات القراءة والملازم.', materialsDesc: 'سجّل تقدمك في كتبك الدراسية صفحة بصفحة واحتفل بختم كل مرجع.',
    materialsBook: 'كتاب التفاضل والتكامل الرسمي 2026',
    materialsSubject: 'رياضيات بحتة 📐',
    materialsDone: 'تم ختم المرجع بالكامل! 🌟 تهانينا',
    rewardsTitle: 'المكافآت، الأوسمة، ونقاط الخبرة.', rewardsDesc: 'كل جلسة تركيز وكل صفحة تقرأها تقربك من المستوى التالي وفتح أوسمة نادرة.',
    rewardsLevel: 'المستوى 5 · متفوق منظم',
    rewardsStreak: '7 أيام متتالية!',
    rewardsClaim: 'احصل على مكافأة الالتزام (+50 XP)',
    rewardsClaimed: 'تمت إضافة +50 XP! استمر في الإنجاز ✨',
    extrasTitle: 'تجربة متكاملة مصممة للإنجاز والتفوق.',
    extras: [
      ['مساعد دراسي ذكي حقيقي ✦', 'توليد خطط مذاكرة متوازنة، بنوك أسئلة تفاعلية فورية، وتلخيص ذكي للمذكرات مدعوم بـ LLM مجاني بدون مفاتيح.'],
      ['ساعة بومودورو 3D القلابة', 'آلية flip ميكانيكية واقعية مع صوت التكتكة وضبط التركيز في بيئة دراسية غامرة.'],
      ['مكتبة الملازم والكتب', 'نظّم ملفاتك ومذكراتك في مجلدات لكل مادة دراسية وتابع عدد الصفحات المنجزة صفحة بصفحة.'],
      ['نظام مكافآت وأوسمة تحفيزية', 'اجمع نقاط الخبرة XP، نافس نفسك في مستويات متصاعدة، وافتح أوسمة الإنجاز مع كل خطوة.'],
      ['شاشات ترحيب Google Play-grade', 'تجربة إعداد مبهرة وسلسة تنقلك مباشرة من أول فتحة للتطبيق لتحديد هدفك ومرحلتك.'],
      ['خصوصية وأمان أوفلاين 100%', 'بياناتك ومذكراتك مخزنة محلياً على جهازك، بدون أي تتبع أو إعلانات وبسرعة فائقة.']
    ],
    faqTitle: 'كل ما تحتاج معرفته.',
    faqs: [
      ['هل مساعد الذكاء الاصطناعي حقيقي ومجاني؟', 'نعم بالكامل! المساعد الذكي مدمج بنموذج لغوي حقيقي فائق الذكاء ومجاني 100% بدون أي مفاتيح API أو اشتراكات، ويتيح لك توليد خطط المذاكرة وتلخيص المذكرات وإجراء الاختبارات التفاعلية وحفظها بضغطة زر.'],
      ['أين ذهبت صفحة الإحصائيات؟', 'تم دمج جميع الرسوم البيانية وإحصائيات الأداء الأسبوعي وتوزيع الوقت مباشرة داخل صفحة «الرئيسية» في لوحة التحكم، واستُبدلت في شريط التنقل بصفحة «المكافآت والجوائز» لمتابعة أوسمتك ونقاط خبرتك.'],
      ['ما هي ساعة بومودورو 3D القلابة؟', 'تصميم skeuomorphic مبتكر لمؤقت التركيز يحاكي الساعات الميكانيكية الكلاسيكية بأرقام ثلاثية الأبعاد تقلب بسلاسة مع صوت تكتكة اختياري لتهيئة ذهنك لأعمق درجات التركيز.'],
      ['كيف تساعدني مكتبة الملازم في متابعة دراستي؟', 'تمكنك من تصنيف مذكراتك وكتبك حسب المواد في مجلدات ملونة، وتحديث عدد الصفحات المقروءة بأزرار سريعة (+5 و -5 وتحديد الصفحة)، مع شريط تقدم واحتفال عند ختم المرجع 100%.'],
      ['هل التطبيق يدعم اللغتين العربية والإنجليزية؟', 'نعم، التطبيق بالكامل يدعم اللغتين العربية والإنجليزية مع اتجاه كتابة RTL و LTR متقن وتنسيقات طباعية مريحة للعين.']
    ],
    cta: ['أفكار أكتر.', 'دوشة أقل.'], ctaBody: 'اعمل مساحة للي يهمك. والبداية؟ خطوة واحدة.', footer: 'مساحة لأفكارك، على إيقاعك.', top: 'ارجع لأول الصفحة', menu: 'قائمة التنقل', previewStatus: 'الوقت في المعاينة توضيحي',
  },
  en: {
    nav: ['The idea', 'Features', 'Try it out', 'Questions'], open: 'Try the web app', lang: 'العربية',
    downloadApk: 'Download Android App (APK)', downloadNav: 'Android App', downloadTag: 'v1.0.0 · 5.8 MB',
    headline: ['Room for ideas.', 'Time for you.'], intro: 'Give everything on your mind a place. Capture your notes, organize study materials, generate real AI plans, and earn rewards — with ENote.', explore: 'Meet ENote', note: 'Notes · Plans · Real AI · 3D Clock · Rewards · Your rhythm.',
    floatNote: 'Good idea? Keep it.', floatTask: 'Small steps. Big difference.', floatFocus: '3D Flip Clock Pomodoro.', floatAi: 'Real AI Assistant ✦',
    strip: ['Ideas worth keeping', 'Plans that fit your day', 'Real & free AI tutor', 'Mechanical 3D focus', 'Organized materials hub', 'Gamified reward badges'],
    storyTitle: ['From a busy mind,', 'to a clear next step.'], storyBody: 'The lecture, the sudden idea, the pile of handouts to finish… ENote brings all your study essentials together into one serene workspace.',
    features: [
      ['Catch it before it goes.', 'Keep full notes in folders, and find the thought you need with instant search.', 'Room for every idea'],
      ['Your day. Step by step.', 'Organize tasks, schedules, and homework. Make a clear plan with room for life.', 'A plan that fits'],
      ['3D Mechanical Flip Clock.', 'Authentic mechanical card flips with optional clockwork ticking and immersive focus sessions.', 'Time to tune in'],
      ['Real & Free AI Assistant.', 'Generate custom study plans in seconds, summarize notes, and test recall with instant smart quizzes powered by real LLM.', 'Smart Assistant'],
      ['Materials & Textbooks Hub.', 'Organize subject handouts in color-coded folders and track page-by-page reading progress.', 'Materials Hub'],
      ['Gamified Rewards & Trophies.', 'Turn your study journey into an inspiring adventure with XP, levels, and collectible achievement badges.', 'Rewards & Badges']
    ],
    demoTitle: ['Better when', 'you try it.'], demoBody: 'Tap, switch, explore. Experience ENote’s latest features hands-on with real-time interactive previews.',
    tabs: ['Your notes', 'Your plan', '3D Pomodoro', 'AI Assistant', 'Materials Hub', 'Rewards'], demoLabel: 'Interactive concept preview — sample data',
    notesTitle: 'Every idea starts somewhere.', noteTitle: 'Project ideas', noteText: 'Big ideas start with a small note.\n\n• Simplify the main idea\n• Put together a first draft\n• Share it with the team', save: 'Save note', saved: 'Saved in this preview',
    planTitle: 'Make room in your day.', tasks: ['Review Physics Unit 1', 'Read Biology Chapter 3', 'Complete Calculus problem set'], newTask: 'New task', add: 'Add', completed: 'completed',
    focusTitle: '3D Mechanical Flip Clock.', focus: 'Focus session', start: 'Start timer', pause: 'Take a pause', reset: 'Reset timer',
    studyMode: 'Focus (25m)', breakMode: 'Break (5m)', longBreakMode: 'Long Break (15m)',
    aiTitle: 'Real AI Study Plan & Rapid Quiz.', aiDesc: 'Enter topic and study hours, and let the real AI build structured phases with self-testing milestones.', aiGenerate: 'Generate AI Study Plan ✦',
    aiGenerating: 'Thinking & generating with Real AI...',
    aiPills: ['Physics: Laws of Motion', 'Biology: Genetics', 'Chemistry: Reaction Rates'],
    aiQuizQ: 'Q: What is the International System (SI) unit of force?',
    aiQuizOpts: ['Newton (N)', 'Joule (J)', 'Watt (W)'],
    aiQuizCorrect: 'Correct answer! Great job 🎯 (100%)',
    aiQuizWrong: 'Incorrect. The correct answer is Newton',
    materialsTitle: 'Track Reading Progress & Handouts.', materialsDesc: 'Log your progress in coursebooks page by page and celebrate completion.',
    materialsBook: 'Official Calculus & Analysis Coursebook 2026',
    materialsSubject: 'Pure Mathematics 📐',
    materialsDone: 'Handout 100% completed! 🌟 Congratulations',
    rewardsTitle: 'Rewards, Trophies, and XP.', rewardsDesc: 'Every focus session and completed task earns XP and unlocks rare achievement medals.',
    rewardsLevel: 'Level 5 · Organized Achiever',
    rewardsStreak: '7-Day Study Streak!',
    rewardsClaim: 'Claim Daily Streak Bonus (+50 XP)',
    rewardsClaimed: '+50 XP claimed! Keep up the momentum ✨',
    extrasTitle: 'Crafted for seamless learning and achievement.',
    extras: [
      ['Real & Free AI Study Assistant ✦', 'Personalized study roadmaps, instant quizzes with scoring, and smart note summarization powered by real free LLM.'],
      ['3D Mechanical Flip Clock', 'Authentic mechanical card flips, optional clockwork ticks, and distraction-free focus sprints.'],
      ['Smart Materials & Books Hub', 'Color-coded subject folders and page-by-page progress trackers with celebratory badges.'],
      ['Gamified Rewards & Levels', 'Earn XP, level up your academic rank, and collect shiny achievement badges for your daily consistency.'],
      ['Google Play-grade Onboarding', 'Smooth multi-step onboarding that tailors your academic level and study targets in seconds.'],
      ['100% Offline-First Privacy', 'Your files and notes live on your device. Zero tracking, zero ads, full peace of mind.']
    ],
    faqTitle: 'Frequently asked questions.',
    faqs: [
      ['Is the AI Assistant real and free?', 'Yes, 100%! The AI Assistant is integrated with a real generative LLM engine that works completely free with zero API key setups, allowing you to generate study plans, test quizzes, and summaries instantly.'],
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
      <div className="lp-phone-heading"><div><small>{ar ? 'مساحة جديدة ليومك' : 'A fresh space for your day'}</small><h3>{ar ? 'صباح الأفكار الحلوة' : 'Hello, fresh ideas'}</h3></div><span className="lp-avatar">A</span></div>
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

export default function Landing() {
  const root = useRef<HTMLDivElement>(null);
  const [language, setLanguage] = useState<Language>(() => {
    try {
      return localStorage.getItem('enote_landing_language') === 'en' ? 'en' : 'ar';
    } catch {
      return 'ar';
    }
  });
  const [menu, setMenu] = useState(false);
  const [scene, setScene] = useState<Scene>('notes');
  const [note, setNote] = useState('');
  const [saved, setSaved] = useState(false);
  const [tasks, setTasks] = useState<{ text: string; done: boolean }[]>([]);
  const [newTask, setNewTask] = useState('');

  // 3D Flip Clock Pomodoro state
  const [seconds, setSeconds] = useState(25 * 60);
  const [running, setRunning] = useState(false);
  const [timerMode, setTimerMode] = useState<'study' | 'break' | 'longBreak'>('study');
  const [soundEnabled, setSoundEnabled] = useState(true);
  const deadline = useRef(0);

  // Materials Hub state
  const [matPages, setMatPages] = useState(145);
  const [matFinished, setMatFinished] = useState(false);

  // Real AI Assistant state
  const [aiTopicInput, setAiTopicInput] = useState('فيزياء: قوانين نيوتن والجاذبية');
  const [aiIsGenerating, setAiIsGenerating] = useState(false);
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

  useEffect(() => {
    document.documentElement.lang = language;
    document.documentElement.dir = ar ? 'rtl' : 'ltr';
    document.documentElement.style.colorScheme = 'dark';
    document.title = ar ? 'ENote — مساحة لأفكارك. وقت لإنجازك.' : 'ENote — Room for ideas. Time for you.';
    try {
      localStorage.setItem('enote_landing_language', language);
    } catch {}
    setNote(t.noteText);
    setTasks(t.tasks.map((text, i) => ({ text, done: i === 0 })));
    setSaved(false);
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
            const a = el.querySelector('a');
            const art = el.querySelector('.lp-feature-art');

            const featTl = gsap.timeline({
              scrollTrigger: { trigger: el, start: 'top 78%', once: true },
            });

            featTl
              .from([symbol, h2, p, a].filter(Boolean), {
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

          // Interactive Playground container entrance
          const playTl = gsap.timeline({
            scrollTrigger: { trigger: '.lp-playground', start: 'top 75%', once: true },
          });
          playTl
            .from('.lp-demo-heading h2, .lp-demo-heading p', {
              autoAlpha: 0,
              y: 30,
              stagger: 0.12,
              duration: 0.8,
              ease: 'power3.out',
            })
            .from('.lp-demo', { autoAlpha: 0, y: 55, scale: 0.96, duration: 1, ease: 'power3.out' }, '-=0.4')
            .from(
              '.lp-demo-sidebar button',
              {
                autoAlpha: 0,
                x: language === 'ar' ? 20 : -20,
                stagger: 0.06,
                duration: 0.6,
                ease: 'power2.out',
              },
              '-=0.5'
            );

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
              '.lp-button, .lp-nav-cta, .lp-back-top, .lp-scroll, .lp-language, .lp-flip-btn, .lp-mat-btn, .lp-reward-claim-btn'
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

  // Playground scene switch smooth transition
  useGSAP(
    () => {
      gsap.fromTo(
        '.lp-demo-panel',
        { autoAlpha: 0, y: 12 },
        { autoAlpha: 1, y: 0, duration: 0.35, ease: 'power2.out', clearProps: 'transform' }
      );
    },
    { scope: root, dependencies: [scene], revertOnUpdate: false }
  );

  // Auto-scroll active tab into view in horizontal scrolling tablist on mobile/tablet
  useEffect(() => {
    const activeTab = document.getElementById(`tab-${scene}`);
    if (activeTab) {
      activeTab.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });
    }
  }, [scene]);

  const changeScene = (next: Scene) => {
    if (next === scene) return;
    setScene(next);
    setSaved(false);
  };

  const handleGenerateAiPlan = (topic?: string) => {
    const selectedTopic = topic || aiTopicInput;
    setAiTopicInput(selectedTopic);
    setAiIsGenerating(true);
    setTimeout(() => {
      setAiIsGenerating(false);
      if (ar) {
        setAiGeneratedPhases([
          { title: `استيعاب أسس ${selectedTopic}`, time: '35 دقيقة' },
          { title: 'حل تطبيقات ونماذج متدرجة الصعوبة', time: '55 دقيقة' },
          { title: 'تقييم فوري وتلخيص أهم القوانين', time: '30 دقيقة' }
        ]);
      } else {
        setAiGeneratedPhases([
          { title: `Master Core Concepts of ${selectedTopic}`, time: '35 mins' },
          { title: 'Solve Graded Drills & Practice Problems', time: '55 mins' },
          { title: 'Instant Knowledge Assessment & Review', time: '30 mins' }
        ]);
      }
    }, 450);
  };

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

  const playgroundScenes: { id: Scene; icon: React.ReactNode; label: string }[] = [
    { id: 'notes', icon: <FileText size={18} />, label: t.tabs[0] },
    { id: 'plan', icon: <CalendarDays size={18} />, label: t.tabs[1] },
    { id: 'focus', icon: <Timer size={18} />, label: t.tabs[2] },
    { id: 'ai', icon: <Sparkles size={18} />, label: t.tabs[3] },
    { id: 'materials', icon: <BookOpen size={18} />, label: t.tabs[4] },
    { id: 'rewards', icon: <Trophy size={18} />, label: t.tabs[5] },
  ];

  return (
    <div className="lp" ref={root}>
      {/* 1. Top scroll progress bar */}
      <div className="lp-scroll-progress" aria-hidden="true" />
      <a className="lp-skip" href="#main">
        {ar ? 'انتقل للمحتوى' : 'Skip to content'}
      </a>
      <header className="lp-header">
        <a className="lp-brand" href="#" aria-label="ENote">
          <img src="/assets/enote-icon.png" width="42" height="42" alt="" />
          <span>
            ENote<span className="lp-brand-dot">.</span>
          </span>
        </a>
        <nav className={menu ? 'lp-nav is-open' : 'lp-nav'} aria-label={t.menu}>
          {['idea', 'playground', 'questions'].map((id, i) => (
            <a href={`#${id}`} key={id} onClick={() => setMenu(false)}>
              {t.nav[i]}
            </a>
          ))}
          <div className="lp-nav-mobile-actions">
            <a href="/app" className="lp-button lp-button-orange" onClick={() => setMenu(false)}>
              {t.open}
              <ArrowUpRight size={17} />
            </a>
            <a
              href="/downloads/ENote-v1.0.0.apk"
              download="ENote-v1.0.0.apk"
              className="lp-button lp-button-apk"
              onClick={() => setMenu(false)}
            >
              <Download size={17} />
              <span>{t.downloadNav}</span>
              <span className="lp-apk-tag">{t.downloadTag}</span>
            </a>
          </div>
        </nav>
        <div className="lp-header-actions">
          <button className="lp-language" onClick={() => setLanguage(ar ? 'en' : 'ar')} aria-label={ar ? 'Switch to English' : 'التبديل للعربية'}>
            <Globe2 size={16} />
            {t.lang}
          </button>
          <a
            className="lp-nav-apk"
            href="/downloads/ENote-v1.0.0.apk"
            download="ENote-v1.0.0.apk"
            title={ar ? 'تحميل تطبيق أندرويد APK' : 'Download Android APK'}
          >
            <Download size={14} />
            <span>{t.downloadNav}</span>
          </a>
          <a className="lp-nav-cta" href="/app">
            {t.open}
            <ArrowUpRight size={16} />
          </a>
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
              <a href="/app" className="lp-button lp-button-orange">
                {t.open}
                <ArrowUpRight size={20} />
              </a>
              <a
                href="/downloads/ENote-v1.0.0.apk"
                download="ENote-v1.0.0.apk"
                className="lp-button lp-button-apk"
                title={ar ? 'تحميل تطبيق الأندرويد المباشر APK' : 'Download Android APK'}
              >
                <Download size={20} />
                <span>{t.downloadApk}</span>
                <span className="lp-apk-tag">{t.downloadTag}</span>
              </a>
              <a href="#playground" className="lp-text-link">
                {t.explore}
                <ArrowDown size={17} />
              </a>
            </div>
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

        <div className="lp-strip" aria-label={ar ? 'مساحة ليومك' : 'Room for your day'}>
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
        <div className="lp-features lp-section">
          {t.features.map((f, i) => {
            const scenesList: Scene[] = ['notes', 'plan', 'focus', 'ai', 'materials', 'rewards'];
            const targetScene = scenesList[i];
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
                  <a href="#playground" onClick={() => changeScene(targetScene)}>
                    {f[2]}
                    {ar ? <ArrowLeft size={19} /> : <ArrowRight size={19} />}
                  </a>
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
                    /* Feature 3: Real AI Study Assistant Card */
                    <div className="lp-ai-art">
                      <div className="lp-ai-art-head">
                        <span className="lp-ai-art-badge">
                          <Sparkles size={13} />
                          {ar ? 'ذكاء اصطناعي حقيقي ✦' : 'Real Free LLM ✦'}
                        </span>
                        <small style={{ color: '#94a3b8', fontSize: '10px' }}>{ar ? 'بدون مفاتيح API' : 'Zero Setup API'}</small>
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

        {/* Interactive Playground: Full 6 Scenes Supported */}
        <section className="lp-playground" id="playground">
          <div className="lp-section lp-playground-inner">
            <div className="lp-demo-heading">
              <h2>
                {t.demoTitle[0]}
                <br />
                <span>{t.demoTitle[1]}</span>
              </h2>
              <p>{t.demoBody}</p>
            </div>
            <div className="lp-demo">
              <div className="lp-demo-sidebar">
                <span className="lp-demo-brand">
                  <img src="/assets/enote-icon.png" width="30" height="30" alt="" />
                  ENote
                </span>
                <div role="tablist" aria-label={ar ? 'اختار المعاينة' : 'Choose a preview'}>
                  {playgroundScenes.map((s, i) => (
                    <button
                      key={s.id}
                      id={`tab-${s.id}`}
                      role="tab"
                      aria-selected={scene === s.id}
                      aria-controls={`panel-${s.id}`}
                      onClick={() => changeScene(s.id)}
                      onKeyDown={(e) => {
                        if (['ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown', 'Home', 'End'].includes(e.key)) {
                          e.preventDefault();
                          const total = playgroundScenes.length;
                          const nextIdx =
                            e.key === 'Home'
                              ? 0
                              : e.key === 'End'
                              ? total - 1
                              : ['ArrowRight', 'ArrowDown'].includes(e.key)
                              ? (i + 1) % total
                              : (i - 1 + total) % total;
                          changeScene(playgroundScenes[nextIdx].id);
                          document.getElementById(`tab-${playgroundScenes[nextIdx].id}`)?.focus();
                        }
                      }}
                      tabIndex={scene === s.id ? 0 : -1}
                    >
                      {s.icon}
                      <span>{s.label}</span>
                    </button>
                  ))}
                </div>
                <small>{t.demoLabel}</small>
              </div>

              <div className="lp-demo-panel" role="tabpanel" id={`panel-${scene}`} aria-labelledby={`tab-${scene}`} tabIndex={0}>
                {scene === 'notes' ? (
                  /* 1. Notes Tab */
                  <>
                    <div className="lp-demo-panel-head">
                      <h3>{t.notesTitle}</h3>
                      <FileText size={25} />
                    </div>
                    <label htmlFor="preview-note">{t.noteTitle}</label>
                    <textarea
                      id="preview-note"
                      value={note}
                      onChange={(e) => {
                        setNote(e.target.value);
                        setSaved(false);
                      }}
                    />
                    <div className="lp-note-save">
                      <button className="lp-button lp-button-blue" onClick={() => setSaved(true)} disabled={saved}>
                        {saved ? <Check size={18} /> : <Plus size={18} />} {saved ? t.saved : t.save}
                      </button>
                      <span role="status">{saved ? (ar ? 'الملاحظة محفوظة طول ما الصفحة مفتوحة.' : 'Kept while this page is open.') : ''}</span>
                    </div>
                  </>
                ) : scene === 'plan' ? (
                  /* 2. Plan Tab */
                  <>
                    <div className="lp-demo-panel-head">
                      <h3>{t.planTitle}</h3>
                      <span>
                        {tasks.filter((x) => x.done).length}/{tasks.length} {t.completed}
                      </span>
                    </div>
                    <div className="lp-demo-tasks">
                      {tasks.map((task, i) => (
                        <label key={i} className={task.done ? 'is-done' : ''}>
                          <input
                            type="checkbox"
                            checked={task.done}
                            onChange={() =>
                              setTasks((prev) =>
                                prev.map((v, j) => (j === i ? { ...v, done: !v.done } : v))
                              )
                            }
                          />
                          <span>{task.text}</span>
                        </label>
                      ))}
                    </div>
                    <form
                      className="lp-add-task"
                      onSubmit={(e) => {
                        e.preventDefault();
                        if (newTask.trim()) {
                          setTasks([...tasks, { text: newTask.trim(), done: false }]);
                          setNewTask('');
                        }
                      }}
                    >
                      <input
                        aria-label={t.newTask}
                        placeholder={t.newTask}
                        value={newTask}
                        maxLength={140}
                        onChange={(e) => setNewTask(e.target.value)}
                        required
                      />
                      <button type="submit" className="lp-button lp-button-blue">
                        <Plus size={18} />
                        {t.add}
                      </button>
                    </form>
                  </>
                ) : scene === 'focus' ? (
                  /* 3. 3D Pomodoro Flip Clock Tab */
                  <div className="lp-timer-demo">
                    <div className="lp-timer-modes">
                      <button
                        type="button"
                        className={`lp-timer-mode-btn ${timerMode === 'study' ? 'active' : ''}`}
                        onClick={() => {
                          setTimerMode('study');
                          setRunning(false);
                          setSeconds(25 * 60);
                        }}
                      >
                        {t.studyMode}
                      </button>
                      <button
                        type="button"
                        className={`lp-timer-mode-btn ${timerMode === 'break' ? 'active' : ''}`}
                        onClick={() => {
                          setTimerMode('break');
                          setRunning(false);
                          setSeconds(5 * 60);
                        }}
                      >
                        {t.breakMode}
                      </button>
                      <button
                        type="button"
                        className={`lp-timer-mode-btn ${timerMode === 'longBreak' ? 'active' : ''}`}
                        onClick={() => {
                          setTimerMode('longBreak');
                          setRunning(false);
                          setSeconds(15 * 60);
                        }}
                      >
                        {t.longBreakMode}
                      </button>
                    </div>

                    <div className="lp-flip-card-preview lp-flip-large" dir="ltr">
                      <div className="lp-flip-digit">
                        {mStr}
                      </div>
                      <div className="lp-flip-sep">:</div>
                      <div className="lp-flip-digit">
                        {sStr}
                      </div>
                    </div>

                    <div style={{ display: 'flex', gap: '12px', alignItems: 'center', marginTop: '10px' }}>
                      <button
                        className="lp-button lp-button-blue"
                        onClick={() => {
                          if (!running) {
                            deadline.current = Date.now() + (seconds || 1500) * 1000;
                            if (!seconds) setSeconds(1500);
                          }
                          setRunning(!running);
                          if (soundEnabled) playMechanicalTick();
                        }}
                      >
                        {running ? <Pause size={18} /> : <Play size={18} fill="currentColor" />} {running ? t.pause : t.start}
                      </button>
                      <button
                        className="lp-reset"
                        aria-label={t.reset}
                        onClick={() => {
                          setRunning(false);
                          const resetSecs = timerMode === 'study' ? 25 * 60 : timerMode === 'break' ? 5 * 60 : 15 * 60;
                          setSeconds(resetSecs);
                          if (soundEnabled) playMechanicalTick();
                        }}
                      >
                        <RotateCcw size={20} />
                      </button>
                      <button
                        className="lp-reset"
                        title={soundEnabled ? (ar ? 'كتم التكتكة' : 'Mute Ticking') : (ar ? 'تشغيل التكتكة' : 'Enable Ticking')}
                        aria-label={soundEnabled ? (ar ? 'كتم التكتكة' : 'Mute Ticking') : (ar ? 'تشغيل التكتكة' : 'Enable Ticking')}
                        onClick={() => {
                          const next = !soundEnabled;
                          setSoundEnabled(next);
                          if (next) playMechanicalTick();
                        }}
                      >
                        {soundEnabled ? <Volume2 size={20} /> : <VolumeX size={20} />}
                      </button>
                    </div>
                  </div>
                ) : scene === 'ai' ? (
                  /* 4. Real AI Assistant Tab */
                  <div className="lp-ai-demo">
                    <div className="lp-demo-panel-head">
                      <div>
                        <h3>{t.aiTitle}</h3>
                        <p style={{ fontSize: '13px', color: '#64748b', marginTop: '4px' }}>{t.aiDesc}</p>
                      </div>
                      <Sparkles size={25} color="#6366f1" />
                    </div>

                    <div className="lp-ai-pills">
                      {t.aiPills.map((pill) => (
                        <button
                          key={pill}
                          type="button"
                          className="lp-ai-pill"
                          onClick={() => handleGenerateAiPlan(pill)}
                        >
                          {pill}
                        </button>
                      ))}
                    </div>

                    <div className="lp-ai-prompt-box">
                      <input
                        value={aiTopicInput}
                        onChange={(e) => setAiTopicInput(e.target.value)}
                        placeholder={ar ? 'اكتب المادة أو الدرس...' : 'Enter subject or lecture topic...'}
                      />
                      <button
                        type="button"
                        className="lp-button lp-button-blue"
                        onClick={() => handleGenerateAiPlan()}
                        disabled={aiIsGenerating}
                      >
                        <Sparkles size={16} />
                        {aiIsGenerating ? t.aiGenerating : t.aiGenerate}
                      </button>
                    </div>

                    <div className="lp-ai-phases">
                      {aiGeneratedPhases.map((phase) => (
                        <div className="lp-ai-phase-item" key={phase.title}>
                          <strong>{phase.title}</strong>
                          <span>{phase.time}</span>
                        </div>
                      ))}
                    </div>

                    <div className="lp-ai-quiz-preview">
                      <div style={{ fontWeight: '800', color: '#1e293b', marginBottom: '8px', fontSize: '14px' }}>
                        {t.aiQuizQ}
                      </div>
                      <div className="lp-ai-quiz-options">
                        {t.aiQuizOpts.map((opt, optIdx) => (
                          <button
                            key={opt}
                            type="button"
                            className={`lp-ai-quiz-btn ${
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
                            <span>{['أ', 'ب', 'ج'][optIdx] || optIdx + 1}. {opt}</span>
                            {aiQuizSelection === optIdx && (
                              <strong style={{ marginInlineStart: 'auto', fontSize: '12px' }}>
                                {optIdx === 0 ? t.aiQuizCorrect : t.aiQuizWrong}
                              </strong>
                            )}
                          </button>
                        ))}
                      </div>
                    </div>
                  </div>
                ) : scene === 'materials' ? (
                  /* 5. Materials Hub Tab */
                  <div className="lp-materials-demo">
                    <div className="lp-demo-panel-head">
                      <div>
                        <h3>{t.materialsTitle}</h3>
                        <p style={{ fontSize: '13px', color: '#64748b', marginTop: '4px' }}>{t.materialsDesc}</p>
                      </div>
                      <BookOpen size={25} color="#2563eb" />
                    </div>

                    <div className="lp-materials-card">
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                        <span className="lp-materials-badge">
                          <Folder size={13} />
                          {t.materialsSubject}
                        </span>
                        <span style={{ fontSize: '12px', fontWeight: '700', color: '#64748b' }}>PDF · 220 {ar ? 'صفحة' : 'pages'}</span>
                      </div>

                      <div style={{ fontSize: '17px', fontWeight: '800', color: '#0f172a' }}>
                        {t.materialsBook}
                      </div>

                      <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '13px', color: '#475569' }}>
                        <span>{ar ? 'معدل الإنجاز:' : 'Completion Rate:'}</span>
                        <strong style={{ color: '#2563eb' }}>
                          {matPages} / 220 {ar ? 'صفحة' : 'pages'} ({Math.round((matPages / 220) * 100)}%)
                        </strong>
                      </div>

                      <div className="lp-materials-progress-track">
                        <div
                          className={`lp-materials-progress-fill ${matFinished ? 'completed' : ''}`}
                          style={{ width: `${(matPages / 220) * 100}%` }}
                        />
                      </div>

                      <div className="lp-materials-btn-group">
                        <button type="button" className="lp-mat-btn" onClick={() => handleAddMatPages(-5)}>
                          -5 {ar ? 'صفحات' : 'pg'}
                        </button>
                        <button type="button" className="lp-mat-btn" onClick={() => handleAddMatPages(5)}>
                          +5 {ar ? 'صفحات' : 'pg'}
                        </button>
                        <button type="button" className="lp-mat-btn" onClick={() => handleAddMatPages(10)}>
                          +10 {ar ? 'صفحات' : 'pg'}
                        </button>
                        <button
                          type="button"
                          className="lp-mat-btn primary"
                          onClick={() => {
                            setMatPages(220);
                            setMatFinished(true);
                            if (soundEnabled) playMechanicalTick();
                          }}
                        >
                          {ar ? '✓ ختم المرجع' : '✓ Mark Done'}
                        </button>
                        {matFinished && (
                          <button
                            type="button"
                            className="lp-mat-btn"
                            onClick={() => {
                              setMatPages(0);
                              setMatFinished(false);
                            }}
                          >
                            {ar ? 'إعادة القراءة' : 'Reset'}
                          </button>
                        )}
                      </div>

                      {matFinished && (
                        <div className="lp-mat-celebrate">
                          <Sparkles size={16} />
                          <span>{t.materialsDone}</span>
                        </div>
                      )}
                    </div>
                  </div>
                ) : (
                  /* 6. Rewards & Badges Tab */
                  <div className="lp-rewards-demo">
                    <div className="lp-demo-panel-head">
                      <div>
                        <h3>{t.rewardsTitle}</h3>
                        <p style={{ fontSize: '13px', color: '#64748b', marginTop: '4px' }}>{t.rewardsDesc}</p>
                      </div>
                      <Trophy size={25} color="#f59e0b" />
                    </div>

                    <div className="lp-rewards-demo-card">
                      <div className="lp-rewards-demo-head">
                        <span className="lp-rewards-level-pill" style={{ fontSize: '13px', padding: '7px 16px' }}>
                          <Crown size={17} />
                          {t.rewardsLevel}
                        </span>
                        <span className="lp-rewards-streak-pill" style={{ fontSize: '13px', padding: '7px 16px' }}>
                          <Flame size={17} />
                          {t.rewardsStreak}
                        </span>
                      </div>

                      <div className="lp-rewards-xp-row">
                        <div className="lp-rewards-xp-labels" style={{ fontSize: '13px' }}>
                          <span>{ar ? 'التقدم نحو المستوى 6:' : 'Progress to Level 6:'}</span>
                          <strong style={{ color: '#d97706', fontWeight: '800' }}>{xp.toLocaleString()} / 2,000 XP</strong>
                        </div>
                        <div className="lp-rewards-xp-track" style={{ height: '12px' }}>
                          <div
                            className="lp-rewards-xp-fill"
                            style={{ width: `${(xp / 2000) * 100}%` }}
                          />
                        </div>
                      </div>

                      <button
                        type="button"
                        className="lp-reward-claim-btn"
                        style={{ padding: '12px 18px', fontSize: '13px' }}
                        onClick={() => {
                          if (!claimedBonus) {
                            setXp((prev) => Math.min(2000, prev + 50));
                            setClaimedBonus(true);
                            if (soundEnabled) playMechanicalTick();
                          }
                        }}
                      >
                        <Sparkles size={16} />
                        {claimedBonus ? t.rewardsClaimed : t.rewardsClaim}
                      </button>

                      <div className="lp-rewards-gallery">
                        {[
                          { title: ar ? 'سيد التركيز' : 'Focus Master', icon: '🏆', desc: ar ? 'سجّل 150د في بومودورو' : 'Log 150m focus' },
                          { title: ar ? 'قارئ شغوف' : 'Avid Reader', icon: '📚', desc: ar ? 'اقرأ 50 صفحة ملازم' : 'Read 50 pages' },
                          { title: ar ? 'عقل مفكر' : 'AI Mind', icon: '⚡', desc: ar ? 'ولّد خطة بالذكاء الاصطناعي' : 'Use AI Planner' },
                          { title: ar ? 'روح الالتزام' : 'Habit Streak', icon: '🔥', desc: ar ? 'التزام 3 أيام متتالية' : '3-Day study streak' },
                          { title: ar ? 'صائد الأهداف' : 'Goal Hunter', icon: '🎯', desc: ar ? 'حقق هدفاً دراسياً 100%' : '100% goal achieved' },
                          { title: ar ? 'عبقري إينوت' : 'ENote Prodigy', icon: '👑', desc: ar ? 'المستوى 10 الدراسي' : 'Reach Level 10' }
                        ].map((badge) => (
                          <div className="lp-rewards-gallery-item unlocked" key={badge.title}>
                            <span className="badge-icon" style={{ fontSize: '24px' }}>{badge.icon}</span>
                            <span className="badge-title">{badge.title}</span>
                            <span className="badge-desc">{badge.desc}</span>
                            <span className="badge-status">{ar ? 'مكتمل ✦' : 'Unlocked ✦'}</span>
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>
                )}
              </div>
            </div>
          </div>
        </section>

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
          <img src="/assets/enote-icon.png" width="94" height="94" alt="" loading="lazy" />
          <h2>
            {t.cta[0]}
            <br />
            <span>{t.cta[1]}</span>
          </h2>
          <p>{t.ctaBody}</p>
          <div className="lp-final-actions">
            <a href="/app" className="lp-button lp-button-orange">
              {t.open}
              <ArrowUpRight size={20} />
            </a>
            <a
              href="/downloads/ENote-v1.0.0.apk"
              download="ENote-v1.0.0.apk"
              className="lp-button lp-button-apk"
            >
              <Download size={20} />
              <span>{t.downloadApk}</span>
              <span className="lp-apk-tag">{t.downloadTag}</span>
            </a>
          </div>
        </section>
      </main>
      <footer className="lp-footer">
        <a className="lp-brand" href="#">
          <img src="/assets/enote-icon.png" width="34" height="34" alt="" />
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
