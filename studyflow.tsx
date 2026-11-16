import React, { useState, useEffect, useMemo, useRef, useId, useCallback, lazy, Suspense, createContext, useContext } from 'react';
import { createPortal } from 'react-dom';
import { localDateKey, validGoal, validTimer, scheduledMinutes } from './ui-utils';
import { t, getLocale, setTranslationLanguage, type Language } from './i18n';
import {
  Home, Calendar as CalendarIcon, BookOpen, CheckSquare, Clock,
  Target, Activity, Moon, GraduationCap, FileText, PieChart,
  Settings, Plus, Trash2, Edit2, Play, Pause, RotateCcw,
  ChevronRight, ChevronLeft, Menu, X, Bell, Search, Sun,
  MoreVertical, Check, Circle, AlertCircle, Bookmark, Star,
  Award, TrendingUp, Book, Briefcase, Coffee, Folder, FolderPlus, ExternalLink, Link2,
  Sparkles, Send, Bot, Zap, HelpCircle, RefreshCw, Trophy, Flame, Crown, ShieldCheck
} from 'lucide-react';
import { FlipClock } from './FlipClock';
import { callRealAi, generateRealPlan, summarizeRealNotes, generateRealQuiz, generatePedagogicalAdvice } from './aiService';
const StatisticsCharts = lazy(() => import('./StatisticsCharts'));
import { initializeApp } from 'firebase/app';
import { getAuth, signInAnonymously, signInWithCustomToken, onAuthStateChanged } from 'firebase/auth';
import { getFirestore, doc, getDoc, setDoc } from 'firebase/firestore';

// --- FIREBASE SETUP ---
let app, auth, db, appId;
try {
  const firebaseConfig = typeof __firebase_config !== 'undefined' ? JSON.parse(__firebase_config) : null;
  if (firebaseConfig) {
    app = initializeApp(firebaseConfig);
    auth = getAuth(app);
    db = getFirestore(app);
    appId = typeof __app_id !== 'undefined' ? __app_id : 'default-app-id';
  }
} catch (error) {
  console.error("Firebase init error:", error);
}

// --- UTILITIES ---
const generateId = () => crypto.randomUUID();
const formatNumber = value => new Intl.NumberFormat(getLocale()).format(value);
const readStorage = key => { try { return localStorage.getItem(key); } catch { return null; } };
const writeStorage = (key, value) => { try { localStorage.setItem(key, value); return true; } catch { return false; } };
const formatShortDate = value => value ? new Intl.DateTimeFormat(getLocale(), {month:'short',day:'numeric'}).format(new Date(`${value}T12:00:00`)) : t('بدون موعد');
const formatDate = (date) => new Intl.DateTimeFormat(getLocale(), { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }).format(date);
const formatTime = (date) => new Intl.DateTimeFormat(getLocale(), { hour: '2-digit', minute: '2-digit' }).format(date);

const CATEGORY_COLORS = {
  study: 'bg-blue-500', school: 'bg-indigo-500', lesson: 'bg-purple-500',
  homework: 'bg-pink-500', sleep: 'bg-slate-500', exercise: 'bg-green-500',
  meal: 'bg-orange-500', reading: 'bg-teal-500', break: 'bg-yellow-500', personal: 'bg-red-500'
};

const CATEGORY_LABELS_AR = {
  study: 'دراسة', school: 'مدرسة', lesson: 'درس خصوصي', homework: 'واجبات',
  sleep: 'نوم', exercise: 'رياضة', meal: 'طعام', reading: 'قراءة', break: 'استراحة', personal: 'شخصي'
};

// --- INITIAL MOCK DATA ---
const INITIAL_DATA = {
  tasks: [
    { id: '1', title: 'مراجعة فيزياء الباب الأول', category: 'study', startTime: '10:00', endTime: '12:00', completed: false, priority: 'high', date: localDateKey() },
    { id: '2', title: 'حل تمارين الرياضيات', category: 'homework', startTime: '14:00', endTime: '15:30', completed: true, priority: 'medium', date: localDateKey() },
    { id: '3', title: 'درس لغة عربية', category: 'lesson', startTime: '16:00', endTime: '18:00', completed: false, priority: 'high', date: localDateKey() }
  ],
  homework: [
    { id: '1', subject: 'رياضيات', description: 'حل صفحة 45 و 46', deadline: localDateKey(new Date(Date.now() + 86400000)), priority: 'high', status: 'pending' },
    { id: '2', subject: 'لغة إنجليزية', description: 'كتابة مقال عن التلوث', deadline: localDateKey(new Date(Date.now() + 86400000 * 2)), priority: 'medium', status: 'completed' }
  ],
  exams: [
    { id: '1', subject: 'كيمياء', date: localDateKey(new Date(Date.now() + 86400000 * 5)), time: '09:00', location: 'المدرسة - قاعة 3', priority: 'high' }
  ],
  habits: [
    { id: '1', name: 'الاستيقاظ مبكراً (6 ص)', icon: 'Sun', color: 'text-yellow-500', history: {} },
    { id: '2', name: 'شرب 2 لتر ماء', icon: 'Coffee', color: 'text-blue-500', history: {} },
    { id: '3', name: 'قراءة 10 صفحات', icon: 'Book', color: 'text-teal-500', history: {} }
  ],
  goals: [
    { id: '1', title: 'الحصول على 95% في الرياضيات', target: 100, current: 80, deadline: localDateKey(new Date(Date.now() + 86400000 * 30)), color: 'bg-green-500' },
    { id: '2', title: 'ختم القرآن الكريم', target: 30, current: 15, deadline: localDateKey(new Date(Date.now() + 86400000 * 60)), color: 'bg-indigo-500' }
  ],
  notes: [
    { id: '1', title: 'ملخص قوانين نيوتن', content: 'القانون الأول: يظل الجسم على حالته...\nالقانون الثاني: القوة = الكتلة × العجلة...', folder: 'فيزياء', date: new Date().toISOString() }
  ],
  materialsFolders: [
    { id: '1', name: 'رياضيات بحتة', color: 'bg-indigo-500', icon: 'Book', filesCount: 2 },
    { id: '2', name: 'فيزياء', color: 'bg-blue-500', icon: 'BookOpen', filesCount: 2 },
    { id: '3', name: 'كيمياء', color: 'bg-emerald-500', icon: 'FileText', filesCount: 1 },
    { id: '4', name: 'لغة إنجليزية', color: 'bg-amber-500', icon: 'Book', filesCount: 0 }
  ],
  materialsItems: [
    { id: '1', folderId: '1', subject: 'رياضيات بحتة', title: 'كتاب التفاضل والتكامل الرسمي', type: 'book', totalPages: 180, readPages: 65, fileUrl: 'https://example.com/math-book.pdf', dateAdded: '2026-11-15' },
    { id: '2', folderId: '1', subject: 'رياضيات بحتة', title: 'ملخص قوانين المشتقات والنهايات', type: 'summary', totalPages: 24, readPages: 24, fileUrl: '', dateAdded: '2026-11-14' },
    { id: '3', folderId: '2', subject: 'فيزياء', title: 'مذكرة شرح الباب الأول كهربية', type: 'pdf', totalPages: 90, readPages: 30, fileUrl: '', dateAdded: '2026-11-12' },
    { id: '4', folderId: '2', subject: 'فيزياء', title: 'رابط فيديو شرح كيرشوف على يوتيوب', type: 'link', totalPages: 1, readPages: 1, fileUrl: 'https://youtube.com', dateAdded: '2026-11-10' },
    { id: '5', folderId: '3', subject: 'كيمياء', title: 'بنك أسئلة الكيمياء العضوية الشامل', type: 'exam', totalPages: 50, readPages: 15, fileUrl: '', dateAdded: '2026-11-08' }
  ],
  schedule: Array(7).fill(null).map((_, i) => ({ day: i, lessons: [] })), // 0: Sat, 1: Sun...
  stats: { studyTimeMinutes: 450, tasksCompleted: 12, focusScore: 85 },
  profile: null
};

// --- GLOBAL CONTEXT ---
const AppContext = createContext(null);

const AppProvider = ({ children }) => {
  const [language, setLanguage] = useState<Language>(() => readStorage('enote_language') === 'en' ? 'en' : 'ar');
  setTranslationLanguage(language);
  useEffect(() => {
    writeStorage('enote_language', language);
    document.documentElement.lang = language;
    document.documentElement.dir = language === 'ar' ? 'rtl' : 'ltr';
  }, [language]);
  const [data, setData] = useState(() => {
    const saved = readStorage('studyflow_data');
    if (saved) {
      try {
        const parsedData = JSON.parse(saved);
        // Safely merge saved data with INITIAL_DATA to ensure no missing keys from app updates
        return { ...INITIAL_DATA, ...parsedData };
      } catch (error) {
        console.error("Error parsing local storage data, falling back to initial data:", error);
        return INITIAL_DATA;
      }
    }
    return INITIAL_DATA;
  });
  
  const [theme, setTheme] = useState(() => {
    const savedTheme = readStorage('studyflow_theme');
    return savedTheme || 'light';
  });

  const [storageError, setStorageError] = useState(false);
  const [toast, setToast] = useState('');
  const [undoItem, setUndoItem] = useState(null);
  const notify = useCallback((message, keepUndo = false) => { setToast(message); if (!keepUndo) setUndoItem(null); }, []);
  const [user, setUser] = useState(null);
  const [isFirebaseLoading, setIsFirebaseLoading] = useState(!!auth);

  // 1. Firebase Authentication
  useEffect(() => {
    if (!auth) return;
    const initAuth = async () => {
      try {
        if (typeof __initial_auth_token !== 'undefined' && __initial_auth_token) {
          await signInWithCustomToken(auth, __initial_auth_token);
        } else {
          await signInAnonymously(auth);
        }
      } catch (err) {
        console.error("Auth Error", err);
      }
    };
    initAuth();
    const unsubscribe = onAuthStateChanged(auth, setUser);
    return () => unsubscribe();
  }, []);

  // 2. Fetch from Firebase Cloud on login
  useEffect(() => {
    if (!user || !db) return;
    const fetchData = async () => {
      try {
        const docRef = doc(db, 'artifacts', appId, 'users', user.uid, 'studyflow_data', 'main');
        const snap = await getDoc(docRef);
        if (snap.exists()) {
          setData(prev => ({ ...prev, ...snap.data() }));
        } else {
          // If no cloud data exists yet, push the current local data up securely
          await setDoc(docRef, data);
        }
      } catch (err) {
        console.error("Fetch error", err);
      } finally {
        setIsFirebaseLoading(false);
      }
    };
    fetchData();
  }, [user]);

  // 3. Save data to LocalStorage & Firebase Cloud Instantly
  useEffect(() => {
    setStorageError(!writeStorage('studyflow_data', JSON.stringify(data)));
    
    if (user && db && !isFirebaseLoading) {
       const docRef = doc(db, 'artifacts', appId, 'users', user.uid, 'studyflow_data', 'main');
       setDoc(docRef, data, { merge: true }).catch(console.error);
    }
  }, [data, user, isFirebaseLoading]);

  useEffect(() => {
    writeStorage('studyflow_theme', theme);
    document.body.classList.toggle('dark', theme === 'dark');
    document.documentElement.style.colorScheme = theme;
    document.querySelector('meta[name="theme-color"]')?.setAttribute('content', theme === 'dark' ? '#191824' : '#f7f7fb');
  }, [theme]);

  const toggleTheme = () => setTheme(prev => prev === 'dark' ? 'light' : 'dark');

  // Generic updater
  const updateData = useCallback((key, newData) => {
    setData(prev => ({ ...prev, [key]: typeof newData === 'function' ? newData(prev[key]) : newData }));
  }, []);

  const addItem = (key, item) => { updateData(key, prev => [...prev, { ...item, id: generateId() }]); notify(t('تم الحفظ')); };
  const updateItem = (key, id, updates) => updateData(key, prev => prev.map(item => item.id === id ? { ...item, ...updates } : item));
  const deleteItem = (key, id) => {
    const index = data[key].findIndex(item => item.id === id);
    if (index < 0) return;
    setUndoItem({key, index, item: data[key][index]});
    updateData(key, prev => prev.filter(item => item.id !== id));
    notify(t('تم الحذف. يمكنك التراجع.'), true);
  };
  const undoDelete = () => {
    if (!undoItem) return;
    const {key, index, item} = undoItem;
    updateData(key, prev => prev.some(entry => entry.id === item.id) ? prev : [...prev.slice(0,index), item, ...prev.slice(index)]);
    setUndoItem(null); notify(t('تمت استعادة العنصر'));
  };
  const resetData = () => { setData(structuredClone(INITIAL_DATA)); setUndoItem(null); notify(t('تمت إعادة الضبط')); };

  return (
    <AppContext.Provider value={{ data, updateData, addItem, updateItem, deleteItem, theme, toggleTheme, language, setLanguage, notify, resetData }}>
      {children}
      {storageError && <div role="alert" className="sf-storage-warning">{t('التخزين غير متاح. اترك هذه الصفحة مفتوحة لتجنب فقدان التغييرات.')}</div>}
      {toast && <div className="sf-toast" role="status"><Check size={18} aria-hidden="true"/><span>{toast}</span>{undoItem && <button onClick={undoDelete}>{t('تراجع')}</button>}<button aria-label={t('إغلاق الإشعار')} onClick={()=>{setToast('');setUndoItem(null)}}><X size={18}/></button></div>}
    </AppContext.Provider>
  );
};

const useAppContext = () => useContext(AppContext);

const LanguagePicker = () => {
  const { language, setLanguage } = useAppContext();
  return <div className="sf-language-picker"><label htmlFor="app-language" className="text-sm font-bold">{t('اللغة')}</label><select id="app-language" value={language} onChange={e => setLanguage(e.target.value)} className="sf-language-select"><option value="ar">العربية</option><option value="en">English</option></select></div>;
};

// --- UI COMPONENTS ---
const Card = ({ children, className = '', noPadding = false, hover = false }) => (
  <div className={`sf-card ${hover ? 'hover:shadow-md transition-shadow duration-300' : ''} ${noPadding ? '' : 'p-6'} ${className}`}>
    {children}
  </div>
);

const Button = ({ children, onClick, variant = 'primary', className = '', icon: Icon, disabled, type = 'button', ...props }) => (
  <button type={type} onClick={onClick} disabled={disabled} className={`sf-button sf-button-${variant} ${className}`} {...props}>{Icon && <Icon size={18} aria-hidden="true"/>}{children}</button>
);

const Input = ({ label, type = 'text', value, onChange, className = '', as: Control = 'input', ...props }) => {
  const id = useId();
  const [invalid, setInvalid] = useState(false);
  return <label className={`sf-field ${className}`} htmlFor={id}><span><span id={`${id}-label`}>{label}</span>{props.required && <span className="sf-required" aria-hidden="true"> *</span>}</span><Control aria-labelledby={`${id}-label`} id={id} name={props.name || label} type={Control === 'input' ? type : undefined} value={value} aria-invalid={invalid || undefined} aria-describedby={invalid ? `${id}-error` : undefined} autoComplete="off" pattern={props.required && type==='text' ? '.*\\S.*' : undefined} {...props} onInvalid={()=>setInvalid(true)} onChange={e=>{setInvalid(false);onChange(e)}} />{invalid && <span id={`${id}-error`} className="sf-field-error" role="alert">{t(type === 'number' ? 'أدخل رقمًا صالحًا ضمن الحدود الموضحة.' : 'يرجى إكمال هذا الحقل بقيمة صالحة.')}{props.min !== undefined && ` (${props.min}–${props.max ?? '∞'})`}</span>}</label>;
};

const Select = ({ label, value, onChange, options, className = '', required = false }) => {
  const id = useId();
  return <label className={`sf-field ${className}`} htmlFor={id}><span><span id={`${id}-label`}>{label}</span>{required && <span className="sf-required" aria-hidden="true"> *</span>}</span><select aria-labelledby={`${id}-label`} id={id} name={label} value={value} onChange={onChange} required={required}>{options.map(opt=><option key={opt.value} value={opt.value}>{t(opt.label)}</option>)}</select></label>;
};

const Form = ({ onSubmit, children, className = '' }) => <form className={`sf-form ${className}`} onSubmit={e=>{e.preventDefault();onSubmit()}}>{children}</form>;
const EmptyState = ({ title = 'لا توجد عناصر بعد', description = 'أضف أول عنصر للبدء.', action, icon: Icon = BookOpen }) => <div className="sf-empty"><Icon size={30} aria-hidden="true"/><h2>{t(title)}</h2><p>{t(description)}</p>{action}</div>;
const ProgressBar = ({ progress, color = 'bg-indigo-500', height = 'h-2' }) => {
  const value = Number.isFinite(progress) ? Math.min(100,Math.max(0,progress)) : 0;
  return <div role="progressbar" aria-label={t('التقدم')} aria-valuenow={Math.round(value)} aria-valuemin={0} aria-valuemax={100} className={`sf-progress ${height}`}><div className={color} style={{width:`${value}%`}}/></div>;
};
const PageHeader = ({ title, description, action }) => <div className="sf-page-header"><div><h1 tabIndex={-1}>{title}</h1>{description&&<p>{description}</p>}</div>{action&&<div>{action}</div>}</div>;

const Modal = ({ isOpen, onClose, title, children }) => {
  const panel = useRef(null);
  const headingId = useId();
  const close = useRef(onClose); close.current = onClose;
  useEffect(()=>{
    if (!isOpen || !panel.current) return;
    const previous = document.activeElement;
    panel.current.showModal();
    return ()=>{panel.current?.close();previous?.focus?.()};
  },[isOpen]);
  if (!isOpen) return null;
  return createPortal(<dialog ref={panel} className="sf-modal" aria-labelledby={headingId} onCancel={e=>{e.preventDefault();close.current()}} onClick={e=>{if(e.target===e.currentTarget)close.current()}}><div className="sf-modal-panel"><header><h2 id={headingId}>{title}</h2><button type="button" className="sf-icon-button" aria-label={t('إغلاق النافذة')} onClick={onClose}><X size={20}/></button></header>{children}</div></dialog>,document.body);
};

const Pomodoro = () => {
  const { data, updateData } = useAppContext();
  const pomodoroSettings = data.pomodoro || { study: 25, break: 5, longBreak: 15 };

  const modes = useMemo(() => ({
    study: { time: pomodoroSettings.study * 60, label: 'وقت التركيز', color: 'text-indigo-500', stroke: '#4f46e5' },
    break: { time: pomodoroSettings.break * 60, label: 'استراحة قصيرة', color: 'text-green-500', stroke: '#22c55e' },
    longBreak: { time: pomodoroSettings.longBreak * 60, label: 'استراحة طويلة', color: 'text-blue-500', stroke: '#3b82f6' }
  }), [pomodoroSettings]);

  const [mode, setMode] = useState('study'); // study, break, longBreak
  const [timeLeft, setTimeLeft] = useState(modes.study.time);
  const [isActive, setIsActive] = useState(false);
  const [isSettingsOpen, setIsSettingsOpen] = useState(false);
  const [tempSettings, setTempSettings] = useState(pomodoroSettings);
  const [timerDisplayType, setTimerDisplayType] = useState<'flip' | 'circular'>('flip');

  const switchMode = (newMode) => {
    setMode(newMode);
    setTimeLeft(modes[newMode].time);
    setIsActive(false);
  };

  const deadline = useRef(0);
  const { notify } = useAppContext();
  useEffect(()=>{
    if (!isActive) return;
    deadline.current = Date.now()+timeLeft*1000;
    const interval = setInterval(()=>setTimeLeft(Math.max(0,Math.ceil((deadline.current-Date.now())/1000))),250);
    return ()=>clearInterval(interval);
  },[isActive]);
  useEffect(()=>{
    if (timeLeft !== 0 || !isActive) return;
    setIsActive(false);
    if (mode==='study') {
      updateData('stats',stats=>({...stats,studyTimeMinutes:(stats.studyTimeMinutes||0)+pomodoroSettings.study}));
      notify(t('انتهت جلسة التركيز! خذ استراحة.'));switchMode('break');
    } else { notify(t('انتهت الاستراحة. عد للعمل!'));switchMode('study'); }
  },[timeLeft,isActive,mode,updateData,pomodoroSettings.study,notify]);

  const toggleTimer = () => setIsActive(active=>!active);
  const resetTimer = () => { setIsActive(false); setTimeLeft(modes[mode].time); };

  const handleSaveSettings = () => {
    if (!validTimer(tempSettings)) return;
    const newSettings = {
       study: Number(tempSettings.study),
       break: Number(tempSettings.break),
       longBreak: Number(tempSettings.longBreak)
    };
    updateData('pomodoro', newSettings);
    setIsSettingsOpen(false);
    setIsActive(false);
    
    // Update time left based on the new settings immediately
    const newTime = mode === 'study' ? newSettings.study * 60 : mode === 'break' ? newSettings.break * 60 : newSettings.longBreak * 60;
    setTimeLeft(newTime);
  };

  const formatDisplayTime = (seconds) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  const progress = ((modes[mode].time - timeLeft) / modes[mode].time) * 100;
  const radius = 120;
  const circumference = 2 * Math.PI * radius;
  const strokeDashoffset = (progress / 100) * circumference;

  return (
    <div className="animate-fade-in max-w-2xl mx-auto text-center">
       <PageHeader title={t("مؤقت بومودورو")} description={t("حافظ على تركيزك وزد من إنتاجيتك")} />

       <Card className="flex flex-col items-center py-10 relative overflow-hidden">
         {/* Settings Button */}
         <button aria-label={t("إعدادات المؤقت (بالدقائق)")} onClick={() => {setTempSettings(pomodoroSettings); setIsSettingsOpen(true);}} className="absolute top-6 left-6 p-2 rounded-full hover:bg-gray-100 dark:hover:bg-gray-700 text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 transition-colors z-20">
           <Settings size={24} />
         </button>

         {/* Decorative background blurs */}
         <div className={`absolute -top-20 -left-20 w-64 h-64 rounded-full blur-3xl opacity-20 ${mode === 'study' ? 'bg-indigo-500' : 'bg-green-500'}`}></div>

         {/* Mode Selectors */}
         <div role="group" aria-label={t("نوع الجلسة")} className="sf-timer-modes flex gap-2 p-1 bg-gray-100 dark:bg-gray-700/50 rounded-full mb-12 z-10">
           {Object.keys(modes).map(m => (
             <button aria-pressed={mode === m} key={m} onClick={() => switchMode(m)}
               className={`px-6 py-2 rounded-full text-sm font-bold transition-all ${mode === m ? 'bg-white dark:bg-gray-800 shadow-sm text-gray-900 dark:text-white' : 'text-gray-500 hover:text-gray-700 dark:hover:text-gray-300'}`}
             >
               {t(modes[m].label)}
             </button>
           ))}
         </div>

          {/* Timer View Switcher */}
          <div className="flex items-center gap-1 p-1 bg-gray-100 dark:bg-gray-700/60 rounded-full mb-8 z-10 text-xs font-semibold">
            <button
              type="button"
              aria-pressed={timerDisplayType === 'flip'}
              onClick={() => setTimerDisplayType('flip')}
              className={`px-4 py-1.5 rounded-full transition-all ${timerDisplayType === 'flip' ? 'bg-white dark:bg-gray-800 text-indigo-600 dark:text-indigo-400 shadow-sm' : 'text-gray-500 hover:text-gray-900 dark:hover:text-gray-300'}`}
            >
              {t("ساعة قلابة 3D")}
            </button>
            <button
              type="button"
              aria-pressed={timerDisplayType === 'circular'}
              onClick={() => setTimerDisplayType('circular')}
              className={`px-4 py-1.5 rounded-full transition-all ${timerDisplayType === 'circular' ? 'bg-white dark:bg-gray-800 text-indigo-600 dark:text-indigo-400 shadow-sm' : 'text-gray-500 hover:text-gray-900 dark:hover:text-gray-300'}`}
            >
              {t("مؤشر دائري")}
            </button>
          </div>

          {/* Timer Display Area */}
          {timerDisplayType === 'flip' ? (
            <div className="w-full max-w-md my-4 mb-10 z-10">
              <FlipClock
                timeLeft={timeLeft}
                totalTime={modes[mode].time}
                mode={mode}
                modeLabel={t(modes[mode].label)}
                isActive={isActive}
                accentColor={modes[mode].stroke}
              />
            </div>
          ) : (
            <div className="relative w-72 h-72 mb-10 flex items-center justify-center z-10">
               <svg aria-hidden="true" className="absolute inset-0 w-full h-full transform -rotate-90">
                 <circle cx="144" cy="144" r={radius} className="stroke-gray-200 dark:stroke-gray-700" strokeWidth="12" fill="none" />
                 <circle cx="144" cy="144" r={radius} 
                         className="transition-all duration-1000 ease-linear"
                         stroke={modes[mode].stroke} strokeWidth="12" fill="none" strokeLinecap="round"
                         strokeDasharray={circumference} strokeDashoffset={strokeDashoffset} />
               </svg>
               <div className="sf-timer-readout flex flex-col items-center">
                  <span className="text-6xl font-black tabular-nums tracking-tighter dark:text-white">{formatDisplayTime(timeLeft)}</span>
                  <span className={`text-lg font-medium mt-2 ${modes[mode].color}`}>{t(modes[mode].label)}</span>
               </div>
            </div>
          )}

         {/* Controls */}
         <div className="flex items-center gap-4 z-10">
            <Button aria-label={t("إعادة تشغيل المؤقت")} variant="outline" className="w-14 h-14 rounded-full p-0 flex justify-center items-center" onClick={resetTimer}>
              <RotateCcw size={24} />
            </Button>
            <Button onClick={toggleTimer} className={`h-16 px-12 rounded-full text-xl shadow-xl transition-transform ${isActive ? 'bg-red-500 hover:bg-red-600 shadow-red-200' : 'bg-indigo-600 hover:bg-indigo-700 shadow-indigo-200'}`}>
              {isActive ? <Pause size={28} className="me-2" /> : <Play size={28} className="me-2 ml-1" />}
              {isActive ? t("إيقاف مؤقت") : t("ابدأ التركيز")}
            </Button>
         </div>
       </Card>

       <Modal isOpen={isSettingsOpen} onClose={() => setIsSettingsOpen(false)} title={t("إعدادات المؤقت (بالدقائق)")}>
          <Form onSubmit={handleSaveSettings}>
            <Input label={t("وقت التركيز (دقائق)")} required type="number" min="1" max="120" value={tempSettings.study} onChange={e => setTempSettings({...tempSettings, study: e.target.value})} />
            <Input label={t("استراحة قصيرة (دقائق)")} required type="number" min="1" max="30" value={tempSettings.break} onChange={e => setTempSettings({...tempSettings, break: e.target.value})} />
            <Input label={t("استراحة طويلة (دقائق)")} required type="number" min="1" max="60" value={tempSettings.longBreak} onChange={e => setTempSettings({...tempSettings, longBreak: e.target.value})} />
            <Button type="submit" className="w-full mt-4">{t("حفظ التغييرات")}</Button>
          </Form>
       </Modal>
    </div>
  );
};

const Homework = () => {
  const { data, addItem, updateItem, deleteItem } = useAppContext();
  const [isOpen, setIsOpen] = useState(false);
  const [newHw, setNewHw] = useState({ subject: '', description: '', deadline: '', priority: 'medium' });

  const handleAdd = () => {
    if(newHw.subject.trim() && newHw.description.trim()) { addItem('homework', {...newHw, status: 'pending'}); setIsOpen(false); setNewHw({ subject: '', description: '', deadline: '', priority: 'medium' }); }
  };

  return (
    <div className="animate-fade-in">
      <PageHeader title={t("مدير الواجبات")} description={t("تتبع واجباتك المدرسية ومواعيد تسليمها")} action={<Button onClick={() => setIsOpen(true)} icon={Plus}>{t("إضافة واجب")}</Button>} />
      
      <Summary items={[["كل الواجبات",data.homework.length,BookOpen],["بانتظار الإنجاز",data.homework.filter(h=>h.status==='pending').length,Clock],["تم إنجازها",data.homework.filter(h=>h.status==='completed').length,CheckSquare]]}/><div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Pending */}
        <div className="space-y-4">
          <h2 className="font-bold text-gray-700 dark:text-gray-300 flex items-center gap-2"><Clock size={18}/>{t("قيد الانتظار")}</h2>
          {!data.homework.some(h=>h.status==='pending')&&<EmptyState title="لا توجد واجبات معلقة" description="أضف واجبًا جديدًا أو استمتع بوقت الراحة."/>}
          {data.homework.filter(h => h.status === 'pending').map(hw => (
            <Card key={hw.id} className="border-l-4 border-l-orange-500">
              <div className="flex justify-between items-start mb-2">
                <div>
                  <span className="text-xs font-bold text-orange-600 bg-orange-100 px-2 py-1 rounded">{hw.subject}</span>
                  <h3 dir="auto" className="font-bold mt-2 dark:text-white text-lg">{hw.description}</h3>
                </div>
                <div className="flex gap-2">
                  <button aria-label={t('إكمال {name}', {name:hw.subject})} onClick={() => updateItem('homework', hw.id, {status: 'completed'})} className="text-gray-400 hover:text-green-500"><CheckCircleIcon /></button>
                  <button aria-label={t('حذف {name}',{name:hw.subject})} onClick={() => deleteItem('homework', hw.id)} className="text-gray-400 hover:text-red-500"><Trash2 size={18}/></button>
                </div>
              </div>
              <div className="text-sm text-gray-500 mt-4 flex items-center gap-1"><CalendarIcon size={14}/>{t("التسليم:")} {formatShortDate(hw.deadline)}</div>
            </Card>
          ))}
        </div>
        {/* Completed */}
        <div className="space-y-4 opacity-70">
           <h2 className="font-bold text-gray-700 dark:text-gray-300 flex items-center gap-2"><CheckSquare size={18}/>{t("مكتمل")}</h2>
           {!data.homework.some(h=>h.status==='completed')&&<EmptyState title="إنجازاتك ستظهر هنا" description="أكمل أول واجب لتراه في هذه القائمة."/>}
           {data.homework.filter(h => h.status === 'completed').map(hw => (
            <Card key={hw.id} className="border-l-4 border-l-green-500 bg-gray-50 dark:bg-gray-800/50">
              <div className="flex justify-between items-center">
                <div>
                  <h3 dir="auto" className="font-bold dark:text-white line-through text-gray-500">{hw.description}</h3>
                  <span className="text-xs text-gray-500">{hw.subject}</span>
                </div>
                <button aria-label={t('إعادة إلى الانتظار')} onClick={() => updateItem('homework', hw.id, {status: 'pending'})} className="text-green-500"><RotateCcw size={18}/></button>
              </div>
            </Card>
          ))}
        </div>
      </div>

      <Modal isOpen={isOpen} onClose={() => setIsOpen(false)} title={t("إضافة واجب جديد")}>
         <Form onSubmit={handleAdd}>
          <Input required label={t("المادة")} value={newHw.subject} onChange={e => setNewHw({...newHw, subject: e.target.value})} />
          <Input required label={t("تفاصيل الواجب")} value={newHw.description} onChange={e => setNewHw({...newHw, description: e.target.value})} />
          <Input label={t("تاريخ التسليم")} type="date" value={newHw.deadline} onChange={e => setNewHw({...newHw, deadline: e.target.value})} />
          <Button type="submit" className="w-full">{t("حفظ")}</Button>
        </Form>
      </Modal>
    </div>
  );
};

const CheckCircleIcon = () => <svg aria-hidden="true" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>;


const Goals = () => {
  const { data, updateItem, addItem, deleteItem } = useAppContext();
  const [isOpen, setIsOpen] = useState(false);
  const [newGoal, setNewGoal] = useState({ title: '', target: 10, current: 0, deadline: '', color: 'bg-green-500' });

  const handleAdd = () => {
    if (validGoal(newGoal)) {
      addItem('goals', { ...newGoal, target: Number(newGoal.target), current: Number(newGoal.current) });
      setIsOpen(false);
      setNewGoal({ title: '', target: 10, current: 0, deadline: '', color: 'bg-green-500' });
    }
  };

  return (
    <div className="animate-fade-in">
      <PageHeader title={t("الأهداف")} description={t("تتبع تقدمك نحو أهدافك الكبيرة")} action={<Button onClick={() => setIsOpen(true)} icon={Plus}>{t("هدف جديد")}</Button>} />
      <Summary items={[["أهدافك",data.goals.length,Target],["أهداف مكتملة",data.goals.filter(g=>g.current>=g.target).length,Award],["قيد التحقيق",data.goals.filter(g=>g.current<g.target).length,TrendingUp]]}/><div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {!data.goals.length&&<EmptyState title="ابدأ بهدف واحد" description="حوّل طموحك إلى خطوة قابلة للقياس." action={<Button onClick={()=>setIsOpen(true)} icon={Plus}>{t('هدف جديد')}</Button>}/>}
        {data.goals.map(goal => {
          const percent = Math.min(100, Math.round((goal.current / Math.max(1,goal.target)) * 100));
          return (
            <Card key={goal.id} className="relative overflow-hidden group">
              
              <div className="flex justify-between items-start mb-4">
                <h2 dir="auto" className="text-xl font-bold dark:text-white pr-4">{goal.title}</h2>
                <Target className={goal.color.replace('bg-', 'text-')} size={24} />
              </div>
              
              <div className="mb-2 flex justify-between text-sm font-bold dark:text-gray-300">
                <span>{t("التقدم")}</span>
                <span>{formatNumber(percent)}%</span>
              </div>
              <ProgressBar progress={percent} color={goal.color} height="h-3" />
              
              <div className="mt-6 flex justify-between items-center text-sm text-gray-500">
                 <span>{t("الهدف:")} {formatNumber(goal.target)}</span>
                 <span>{t("الحالي:")} {formatNumber(goal.current)}</span>
                 <div className="flex gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                   <button aria-label={t('زيادة تقدم {name}', {name:goal.title})} disabled={goal.current >= goal.target} onClick={() => updateItem('goals', goal.id, {current: Math.min(goal.target, goal.current + 1)})} className="bg-gray-100 dark:bg-gray-700 p-1.5 rounded hover:bg-gray-200 dark:hover:bg-gray-600 text-gray-700 dark:text-gray-300 transition-colors"><Plus size={16}/></button>
                   <button aria-label={t('حذف {name}',{name:goal.title})} onClick={() => deleteItem('goals', goal.id)} className="bg-red-50 dark:bg-red-900/30 p-1.5 rounded hover:bg-red-100 dark:hover:bg-red-900/50 text-red-500 transition-colors"><Trash2 size={16}/></button>
                 </div>
              </div>
            </Card>
          )
        })}
      </div>

      <Modal isOpen={isOpen} onClose={() => setIsOpen(false)} title={t("إضافة هدف/مهمة جديدة")}>
        <Form onSubmit={handleAdd}>
          <Input 
            required label={t("عنوان الهدف")} 
            value={newGoal.title} 
            onChange={e => setNewGoal({...newGoal, title: e.target.value})} 
            placeholder={t("مثال: إنهاء 5 فصول من الكيمياء")} 
          />
          <div className="grid grid-cols-2 gap-4">
            <Input 
              required min="1" max="1000000" label={t("الهدف الإجمالي")} 
              type="number" 
              value={newGoal.target} 
              onChange={e => setNewGoal({...newGoal, target: e.target.value})} 
            />
            <Input 
              required min="0" max={Number(newGoal.target) || 0} label={t("الإنجاز الحالي")} 
              type="number" 
              value={newGoal.current} 
              onChange={e => setNewGoal({...newGoal, current: e.target.value})} 
            />
          </div>
          <Input 
            label={t("تاريخ الانتهاء")} 
            type="date" 
            value={newGoal.deadline} 
            onChange={e => setNewGoal({...newGoal, deadline: e.target.value})} 
          />
          <Select 
            label={t("لون الهدف")} 
            value={newGoal.color} 
            onChange={e => setNewGoal({...newGoal, color: e.target.value})} 
            options={[
              {value: 'bg-green-500', label: 'أخضر'},
              {value: 'bg-indigo-500', label: 'بنفسجي'},
              {value: 'bg-blue-500', label: 'أزرق'},
              {value: 'bg-yellow-500', label: 'أصفر'},
              {value: 'bg-pink-500', label: 'وردي'},
              {value: 'bg-red-500', label: 'أحمر'}
            ]} 
          />
          <Button type="submit" className="w-full mt-2">{t("حفظ الهدف")}</Button>
        </Form>
      </Modal>
    </div>
  )
}

const Habits = () => {
  const { data, updateItem, addItem, deleteItem } = useAppContext();
  const [isOpen, setIsOpen] = useState(false);
  const [newHabit, setNewHabit] = useState({ name: '', color: 'text-indigo-500' });
  const todayStr = localDateKey();
  
  // Generate last 7 days
  const days = Array.from({length: 7}, (_, i) => {
    const d = new Date(); d.setDate(d.getDate() - (6 - i));
    return localDateKey(d);
  });

  const toggleHabit = (habitId, date) => {
    const habit = data.habits.find(h => h.id === habitId);
    const newHistory = { ...habit.history, [date]: !habit.history[date] };
    updateItem('habits', habitId, { history: newHistory });
  };

  const handleAdd = () => {
    if (newHabit.name.trim() !== '') {
      addItem('habits', { ...newHabit, icon: 'Star', history: {} });
      setIsOpen(false);
      setNewHabit({ name: '', color: 'text-indigo-500' });
    }
  };

  return (
    <div className="animate-fade-in">
       <PageHeader 
         title={t("متتبع العادات")} 
         description={t("ابنِ عادات إيجابية يومية")} 
         action={<Button icon={Plus} onClick={() => setIsOpen(true)}>{t("إضافة عادة")}</Button>} 
       />
       
       <Summary items={[["عادات إيجابية",data.habits.length,Activity],["أنجزتها اليوم",data.habits.filter(h=>h.history[todayStr]).length,CheckSquare],["أيام المتابعة",7,CalendarIcon]]}/><p className="text-xs text-gray-400 mb-4">{t("اضغط على اليوم لتسجيل إنجازك. كل علامة هي خطوة للأمام.")}</p><div role="region" aria-label={t('متابعة العادات الأسبوعية')} tabIndex={0} className="sf-table-region"><Card noPadding className="overflow-x-auto">
         <table className="w-full text-right border-collapse">
           <thead>
             <tr className="bg-gray-50 dark:bg-gray-800/50 border-b dark:border-gray-700">
               <th className="p-4 font-bold text-gray-600 dark:text-gray-300">{t("العادة")}</th>
               {days.map(d => (
                 <th key={d} className="p-4 text-center font-semibold text-sm text-gray-500">
                   <div>{new Date(d).toLocaleDateString(getLocale(), { weekday: 'short' })}</div>
                   <div className="text-xs">{formatNumber(Number(d.split('-')[2]))}</div>
                 </th>
               ))}
             </tr>
           </thead>
           <tbody>
             {data.habits.map(habit => (
               <tr key={habit.id} className="border-b dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-800/30 group">
                 <td className="p-4 flex items-center gap-3">
                   <div className={`w-10 h-10 rounded-xl bg-gray-100 dark:bg-gray-700 flex items-center justify-center ${habit.color}`}>
                     <Star size={20} />
                   </div>
                   <span className="font-bold dark:text-white">{habit.name}</span>
                   <button 
                     onClick={() => deleteItem('habits', habit.id)}
                     className="mr-auto opacity-0 group-hover:opacity-100 text-gray-400 hover:text-red-500 p-1.5 transition-all rounded-lg hover:bg-red-50 dark:hover:bg-red-900/30"
                     title={t("حذف العادة")}
                   >
                     <Trash2 size={18} />
                   </button>
                 </td>
                 {days.map(d => (
                   <td key={d} className="p-4 text-center">
                     <button 
                       aria-label={`${habit.name} — ${d}`} aria-pressed={!!habit.history[d]} onClick={() => toggleHabit(habit.id, d)}
                       className={`w-8 h-8 rounded-lg flex items-center justify-center mx-auto transition-all ${habit.history[d] ? 'bg-green-500 text-white shadow-md shadow-green-200 dark:shadow-none scale-110' : 'bg-gray-100 dark:bg-gray-700 text-transparent hover:bg-gray-200 dark:hover:bg-gray-600'}`}
                     >
                       <Check size={16} />
                     </button>
                   </td>
                 ))}
               </tr>
             ))}
           </tbody>
         </table>
       </Card></div>
       {!data.habits.length&&<EmptyState title="عادة صغيرة تصنع فرقًا" description="أضف أول عادة وسجّل تقدمك كل يوم."/>}

       <Modal isOpen={isOpen} onClose={() => setIsOpen(false)} title={t("إضافة عادة جديدة")}>
          <Form onSubmit={handleAdd}>
            <Input 
              required label={t("اسم العادة")} 
              value={newHabit.name} 
              onChange={e => setNewHabit({...newHabit, name: e.target.value})} 
              placeholder={t("مثال: القراءة لمدة 20 دقيقة")} 
            />
            <Select 
              label={t("لون العادة")} 
              value={newHabit.color} 
              onChange={e => setNewHabit({...newHabit, color: e.target.value})} 
              options={[
                {value: 'text-indigo-500', label: 'بنفسجي'},
                {value: 'text-blue-500', label: 'أزرق'},
                {value: 'text-green-500', label: 'أخضر'},
                {value: 'text-yellow-500', label: 'أصفر'},
                {value: 'text-pink-500', label: 'وردي'},
                {value: 'text-red-500', label: 'أحمر'}
              ]} 
            />
            <Button type="submit" className="w-full mt-2">{t("حفظ العادة")}</Button>
          </Form>
       </Modal>
    </div>
  )
}

const RewardsView = ({ navigate }) => {
  const { data, language } = useAppContext();
  const ar = language === 'ar';
  const today = localDateKey();

  // Metrics calculation
  const completedTasks = data.tasks.filter(t => t.completed).length;
  const focusMinutes = data.stats.studyTimeMinutes || 0;
  const totalPagesRead = (data.materialsItems || []).reduce((acc, m) => acc + (Number(m.readPages) || 0), 0);
  const completedBooks = (data.materialsItems || []).filter(m => Number(m.readPages) >= Number(m.totalPages) && Number(m.totalPages) > 0).length;
  const completedGoals = data.goals.filter(g => g.current >= g.target).length;
  const habitChecks = data.habits.reduce((acc, h) => acc + Object.keys(h.history || {}).length, 0);

  // Experience Points & Level Logic
  const totalXP = (completedTasks * 20) + (focusMinutes * 2) + (totalPagesRead * 2) + (completedBooks * 50) + (completedGoals * 100) + (habitChecks * 15);
  const currentLevel = Math.max(1, Math.floor(totalXP / 250) + 1);
  const currentLevelXP = totalXP % 250;
  const nextLevelProgress = Math.min(100, Math.round((currentLevelXP / 250) * 100));
  const xpNeeded = 250 - currentLevelXP;

  const levelTitles = [
    t('مبتدئ طموح'),
    t('باحث مجتهد'),
    t('متفوق منظم'),
    t('خبير تركيز'),
    t('عبقري إينوت ✦')
  ];
  const levelTitle = levelTitles[Math.min(currentLevel - 1, levelTitles.length - 1)];

  // Badges list
  const BADGES = [
    {
      id: 'first_task',
      title: t('بطل المهام'),
      desc: t('أكمل أول مهمة دراسية مسجلة'),
      icon: CheckSquare,
      color: 'text-blue-500',
      unlocked: completedTasks >= 1,
      progress: `${Math.min(1, completedTasks)} / 1`,
      xp: '+30 XP',
      targetScreen: 'planner'
    },
    {
      id: 'deca_task',
      title: t('عشرة على عشرة'),
      desc: t('أكمل 10 مهام دراسية بنجاح'),
      icon: Trophy,
      color: 'text-amber-500',
      unlocked: completedTasks >= 10,
      progress: `${Math.min(10, completedTasks)} / 10`,
      xp: '+100 XP',
      targetScreen: 'planner'
    },
    {
      id: 'focus_master',
      title: t('سيد التركيز'),
      desc: t('سجّل 50 دقيقة تركيز في بومودورو'),
      icon: Clock,
      color: 'text-purple-500',
      unlocked: focusMinutes >= 50,
      progress: `${Math.min(50, focusMinutes)} / 50 دقيقة`,
      xp: '+80 XP',
      targetScreen: 'pomodoro'
    },
    {
      id: 'focus_marathon',
      title: t('بطل الساعات'),
      desc: t('سجّل 150 دقيقة تركيز في بومودورو'),
      icon: Zap,
      color: 'text-indigo-500',
      unlocked: focusMinutes >= 150,
      progress: `${Math.min(150, focusMinutes)} / 150 دقيقة`,
      xp: '+150 XP',
      targetScreen: 'pomodoro'
    },
    {
      id: 'bookworm',
      title: t('قارئ شغوف'),
      desc: t('اقرأ 50 صفحة من ملازمك ومراجعك'),
      icon: BookOpen,
      color: 'text-teal-500',
      unlocked: totalPagesRead >= 50,
      progress: `${Math.min(50, totalPagesRead)} / 50 صفحة`,
      xp: '+60 XP',
      targetScreen: 'materials'
    },
    {
      id: 'finisher',
      title: t('خاتم المراجع'),
      desc: t('اختم كتاباً أو مذكرة دراسية بالكامل'),
      icon: Crown,
      color: 'text-emerald-500',
      unlocked: completedBooks >= 1,
      progress: `${Math.min(1, completedBooks)} / 1 مراجع`,
      xp: '+120 XP',
      targetScreen: 'materials'
    },
    {
      id: 'habit_hero',
      title: t('روح الالتزام'),
      desc: t('التزم بعادة إيجابية لـ 3 أيام متتالية'),
      icon: Flame,
      color: 'text-red-500',
      unlocked: habitChecks >= 3,
      progress: `${Math.min(3, habitChecks)} / 3 أيام`,
      xp: '+70 XP',
      targetScreen: 'habits'
    },
    {
      id: 'goal_hunter',
      title: t('صائد الأهداف'),
      desc: t('حقق هدفاً دراسياً كبيراً بنسبة 100%'),
      icon: Target,
      color: 'text-orange-500',
      unlocked: completedGoals >= 1,
      progress: `${Math.min(1, completedGoals)} / 1 هدف`,
      xp: '+150 XP',
      targetScreen: 'goals'
    },
    {
      id: 'ai_mind',
      title: t('عقل مفكر'),
      desc: t('استعن بالذكاء الاصطناعي لتوليد خطة أو تلخيص'),
      icon: Sparkles,
      color: 'text-fuchsia-500',
      unlocked: true,
      progress: '1 / 1',
      xp: '+50 XP',
      targetScreen: 'ai'
    },
    {
      id: 'flawless_day',
      title: t('المتعلم المثالي'),
      desc: t('أنجز جميع مهام يومك في المخطط اليومي'),
      icon: ShieldCheck,
      color: 'text-blue-600',
      unlocked: completedTasks > 0 && data.tasks.filter(t => t.date === today && !t.completed).length === 0,
      progress: `${completedTasks > 0 && data.tasks.filter(t => t.date === today && !t.completed).length === 0 ? '1' : '0'} / 1`,
      xp: '+100 XP',
      targetScreen: 'planner'
    }
  ];

  const unlockedCount = BADGES.filter(b => b.unlocked).length;

  return (
    <div className="animate-fade-in sf-rewards-hub">
      <PageHeader
        title={t('المكافآت والجوائز')}
        description={t('احتفل بإنجازاتك اليومية، واكسب الأوسمة ونقاط الخبرة مع كل مهمة تنجزها.')}
      />

      {/* Level & XP Banner */}
      <div className="sf-level-banner">
        <div className="sf-level-info">
          <div className="sf-level-badge">
            <Crown size={34} />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <span className="text-xs uppercase font-extrabold tracking-wider text-amber-600 dark:text-amber-400">
                {t('رتبتك الحالية')}
              </span>
              <span className="sf-tag bg-amber-500/10 text-amber-600 dark:text-amber-400 font-bold">
                {t('المستوى {level}', { level: String(currentLevel) })}
              </span>
            </div>
            <h2 className="text-2xl font-black text-gray-900 dark:text-white mt-0.5">{levelTitle}</h2>
            <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">
              {t('نقاط الخبرة: {xp} XP', { xp: String(totalXP) })} · {t('المتبقي للمستوى التالي: {needed} XP', { needed: String(xpNeeded) })}
            </p>
            <div className="w-56 mt-2">
              <ProgressBar progress={nextLevelProgress} color="bg-amber-500" />
            </div>
          </div>
        </div>

        <div className="sf-streak-card">
          <div className="sf-streak-flame">
            <Flame size={22} />
          </div>
          <div>
            <strong className="text-sm dark:text-white block">
              {Math.max(1, habitChecks || completedTasks ? 4 : 1)} {t('أيام متتالية')}
            </strong>
            <small className="text-xs text-gray-400">{t('أيام الالتزام والاستمرارية')}</small>
          </div>
        </div>
      </div>

      {/* Stats Summary */}
      <Summary
        items={[
          ['أوسمة مكتملة', `${formatNumber(unlockedCount)} / ${formatNumber(BADGES.length)}`, Trophy],
          ['إجمالي نقاط الخبرة', `${formatNumber(totalXP)} XP`, Zap],
          ['أعلى سلسلة التزام', `${Math.max(1, habitChecks || completedTasks ? 4 : 1)} ${t('أيام')}`, Flame]
        ]}
      />

      {/* Badges Gallery */}
      <div>
        <div className="sf-section-head mb-4">
          <h2>{t('سجل الأوسمة المكتسبة')} <span className="sf-tag">{unlockedCount} / {BADGES.length}</span></h2>
        </div>

        <div className="sf-rewards-grid">
          {BADGES.map(badge => {
            const Icon = badge.icon;
            return (
              <div
                key={badge.id}
                className={`sf-reward-card ${badge.unlocked ? 'unlocked' : 'locked'}`}
              >
                <div>
                  <div className="sf-reward-head">
                    <div className="sf-reward-icon">
                      <Icon size={24} className={badge.unlocked ? badge.color : 'text-gray-400'} />
                    </div>
                    <span className={`sf-reward-pill ${badge.unlocked ? 'unlocked' : 'locked'}`}>
                      {badge.unlocked ? t('مكتمل ✦') : t('قيد الإنجاز')}
                    </span>
                  </div>

                  <h3 className="font-bold text-base text-gray-900 dark:text-white mt-3">
                    {badge.title}
                  </h3>
                  <p className="text-xs text-gray-500 dark:text-gray-400 mt-1 leading-relaxed">
                    {badge.desc}
                  </p>
                </div>

                <div className="pt-3 border-t border-gray-100 dark:border-gray-800 flex items-center justify-between">
                  <span className="text-xs font-semibold text-gray-400">
                    {badge.progress}
                  </span>
                  <div className="flex items-center gap-2">
                    <span className="text-xs font-bold text-amber-500 bg-amber-500/10 px-2 py-0.5 rounded-full">
                      {badge.xp}
                    </span>
                    {!badge.unlocked && badge.targetScreen && (
                      <button
                        type="button"
                        onClick={() => navigate(badge.targetScreen)}
                        className="sf-text-link text-xs"
                      >
                        {t('ابدأ')}
                      </button>
                    )}
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};

const Notes = () => {
  const { data, addItem, updateItem, deleteItem, notify } = useAppContext();
  const [editor, setEditor] = useState(null);
  const [discardRequested, setDiscardRequested] = useState(false);
  const closeEditor = () => {
    const original = data.notes.find(note=>note.id===editor?.id) || {title:'',content:'',folder:t('عام')};
    if (editor && ['title','content','folder'].some(key=>editor[key]!==original[key])) setDiscardRequested(true); else setEditor(null);
  };
  const [folder, setFolder] = useState('الكل');
  const [query, setQuery] = useState('');
  const visibleNotes = data.notes.filter(note=>(folder==='الكل'||note.folder===folder)&&`${note.title} ${note.content}`.toLocaleLowerCase(getLocale()).includes(query.trim().toLocaleLowerCase(getLocale())));
  const openEditor = (note = null) => setEditor(note ? {...note} : {title:'', content:'', folder:t('عام')});
  const saveNote = () => {
    if (!editor.title.trim() || !editor.content.trim()) return;
    const note = {...editor,title:editor.title.trim(),folder:editor.folder.trim()||t('عام'),date:new Date().toISOString()};
    if (editor.id) { updateItem('notes',editor.id,note); notify(t('تم الحفظ')); } else addItem('notes',note);
    setEditor(null);
  };
  return <div><PageHeader title={t('مكتبة أفكارك')} description={t('ملخصات، أفكار، وتفاصيل صغيرة تستحق أن تُحفظ.')} action={<Button icon={Plus} onClick={()=>openEditor()}>{t('ملاحظة جديدة')}</Button>}/><div className="sf-note-toolbar"><div className="sf-folder-filters" aria-label={t('المجلد')} role="group">{['الكل',...new Set(data.notes.map(note=>note.folder))].map(value=><button key={value} aria-pressed={folder===value} className={`sf-filter ${folder===value?'active':''}`} onClick={()=>setFolder(value)}>{value==='الكل'?t(value):value}</button>)}</div><label className="sf-search"><Search size={18} aria-hidden="true"/><input type="search" name="note-search" aria-label={t('بحث في الملاحظات')} placeholder={t('ابحث في أفكارك...')} value={query} onChange={event=>setQuery(event.target.value)}/></label></div><p className="sf-results-count" role="status">{formatNumber(visibleNotes.length)} {t('ملاحظة')}</p>{!visibleNotes.length&&<EmptyState title={data.notes.length?'لا توجد نتائج':'مكتبتك تبدأ بفكرة'} description={data.notes.length?'جرّب كلمة أخرى أو اختر مجلدًا مختلفًا.':'احتفظ بأول فكرة أو ملخص دراسي هنا.'} action={!data.notes.length&&<Button icon={Plus} onClick={()=>openEditor()}>{t('ملاحظة جديدة')}</Button>}/>}<div className="sf-notes-grid">{visibleNotes.map(note=><article className="sf-note-card" key={note.id}><button className="sf-note-open" onClick={()=>openEditor(note)} aria-label={t('فتح {name}',{name:note.title})}><span className="sf-tag">{note.folder}</span><h2 dir="auto">{note.title}</h2><p dir="auto">{note.content}</p><footer><time dateTime={note.date}>{new Date(note.date).toLocaleDateString(getLocale(),{dateStyle:'medium'})}</time><span>{t('فتح وتعديل')} <Edit2 size={14} aria-hidden="true"/></span></footer></button></article>)}</div><Modal isOpen={!!editor} onClose={closeEditor} title={t(editor?.id?'تعديل الملاحظة':'إضافة ملاحظة')}>{editor&&<Form onSubmit={saveNote}><Input label={t('العنوان')} required maxLength={200} value={editor.title} onChange={event=>setEditor({...editor,title:event.target.value})}/><Input label={t('المجلد')} value={editor.folder} onChange={event=>setEditor({...editor,folder:event.target.value})}/><Input as="textarea" rows={9} required label={t('المحتوى')} value={editor.content} onChange={event=>setEditor({...editor,content:event.target.value})}/><div className="sf-form-actions"><Button type="submit" icon={Check}>{t('حفظ الملاحظة')}</Button>{editor.id&&<Button variant="danger" icon={Trash2} onClick={()=>{deleteItem('notes',editor.id);setEditor(null)}}>{t('حذف الملاحظة')}</Button>}</div></Form>}</Modal><Modal isOpen={discardRequested} onClose={()=>setDiscardRequested(false)} title={t('تجاهل التغييرات؟')}><p className="mb-6">{t('توجد تغييرات لم تُحفظ في الملاحظة.')}</p><div className="sf-form-actions"><Button onClick={()=>setDiscardRequested(false)}>{t('متابعة التعديل')}</Button><Button variant="danger" onClick={()=>{setDiscardRequested(false);setEditor(null)}}>{t('تجاهل التغييرات')}</Button></div></Modal></div>;
};

const MaterialsHub = () => {
  const { data, addItem, updateItem, deleteItem, notify } = useAppContext();
  const folders = data.materialsFolders || [];
  const items = data.materialsItems || [];
  const [activeFolderId, setActiveFolderId] = useState('all');
  const [filterType, setFilterType] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [newFolderOpen, setNewFolderOpen] = useState(false);
  const [newItemOpen, setNewItemOpen] = useState(false);
  const [pageModalItem, setPageModalItem] = useState<{ id: string; title: string; total: number; current: number } | null>(null);
  const [pageInputVal, setPageInputVal] = useState('0');
  const [newFolderName, setNewFolderName] = useState('');
  const [newFolderColor, setNewFolderColor] = useState('bg-indigo-500');
  
  const [newItem, setNewItem] = useState({
    title: '',
    folderId: folders[0]?.id || '1',
    type: 'pdf',
    totalPages: 100,
    readPages: 0,
    fileUrl: '',
    description: ''
  });

  const filteredItems = items.filter(item => {
    const matchesFolder = activeFolderId === 'all' || item.folderId === activeFolderId;
    const matchesType = filterType === 'all' || item.type === filterType;
    const q = searchQuery.trim().toLowerCase();
    const itemTitle = (t(item.title) || item.title || '').toLowerCase();
    const itemDesc = (item.description || '').toLowerCase();
    const itemSub = (t(item.subject) || item.subject || '').toLowerCase();
    const matchesQuery = !q || itemTitle.includes(q) || itemDesc.includes(q) || itemSub.includes(q);
    return matchesFolder && matchesType && matchesQuery;
  });

  const totalPagesSum = items.reduce((sum, item) => sum + (Number(item.totalPages) || 0), 0);
  const totalReadPagesSum = items.reduce((sum, item) => sum + (Number(item.readPages) || 0), 0);
  const totalBooksCount = items.filter(item => item.type === 'book' || item.type === 'pdf').length;

  const handleAddFolder = () => {
    if (!newFolderName.trim()) return;
    const folder = {
      id: generateId(),
      name: newFolderName.trim(),
      color: newFolderColor,
      icon: 'Book',
      filesCount: 0
    };
    addItem('materialsFolders', folder);
    setNewFolderName('');
    setNewFolderOpen(false);
    notify(t('تمت إضافة مجلد المادة بنجاح'));
  };

  const handleAddItem = () => {
    if (!newItem.title.trim()) return;
    const folder = folders.find(f => f.id === newItem.folderId);
    const item = {
      ...newItem,
      id: generateId(),
      subject: folder?.name || t('عام'),
      totalPages: Math.max(1, Number(newItem.totalPages) || 1),
      readPages: Math.max(0, Number(newItem.readPages) || 0),
      dateAdded: localDateKey()
    };
    addItem('materialsItems', item);
    if (folder) {
      updateItem('materialsFolders', folder.id, { filesCount: (folder.filesCount || 0) + 1 });
    }
    setNewItemOpen(false);
    setNewItem({ title: '', folderId: folders[0]?.id || '1', type: 'pdf', totalPages: 100, readPages: 0, fileUrl: '', description: '' });
    notify(t('تم حفظ المرجع/الملف بنجاح'));
  };

  const updateProgress = (itemId: string, delta: number) => {
    const item = items.find(i => i.id === itemId);
    if (!item) return;
    const total = Math.max(1, Number(item.totalPages) || 1);
    const current = Math.max(0, Number(item.readPages) || 0);
    const updated = Math.min(total, Math.max(0, current + delta));
    updateItem('materialsItems', itemId, { readPages: updated });
    notify(t('تم تحديث التقدم: {updated} / {total} صفحة', { updated: String(updated), total: String(total) }));
  };

  const openPageSetter = (item: any) => {
    const total = Math.max(1, Number(item.totalPages) || 1);
    const current = Math.max(0, Number(item.readPages) || 0);
    setPageInputVal(String(current));
    setPageModalItem({ id: item.id, title: item.title, total, current });
  };

  const TYPE_LABELS: Record<string, string> = {
    all: 'الكل',
    book: 'كتب دراسية 📚',
    pdf: 'ملفات PDF 📄',
    summary: 'ملخصات 📑',
    exam: 'بنوك أسئلة 🎯',
    link: 'روابط محاضرات 🔗'
  };

  return (
    <div className="sf-materials-hub animate-fade-in">
      <PageHeader 
        title={t('مكتبة الملازم والكتب')} 
        description={t('نظّم ملازمك، كتبك، ومحاضراتك في مجلد خاص لكل مادة دراسية.')}
        action={
          <div className="flex gap-2">
            <Button icon={FolderPlus} variant="outline" onClick={() => setNewFolderOpen(true)}>
              {t('مجلد مادة جديد')}
            </Button>
            <Button icon={Plus} onClick={() => setNewItemOpen(true)}>
              {t('إضافة ملف / كتاب')}
            </Button>
          </div>
        }
      />

      <Summary items={[
        ['إجمالي المراجع والملازم', items.length, BookOpen],
        ['الكتب والمذكرات', totalBooksCount, FileText],
        ['صفحات القراءة المنجزة', `${formatNumber(totalReadPagesSum)} / ${formatNumber(totalPagesSum)}`, CheckSquare]
      ]} />

      <section aria-labelledby="materials-folders-title">
        <div className="flex justify-between items-center mb-3">
          <h2 id="materials-folders-title" className="text-lg font-bold flex items-center gap-2" style={{ color: 'var(--ink)' }}>
            <Folder size={20} style={{ color: 'var(--accent)' }} />
            {t('مجلدات المواد الدراسية')}
          </h2>
          <span className="text-xs" style={{ color: 'var(--muted)' }}>
            {formatNumber(folders.length)} {t('مواد')}
          </span>
        </div>

        <div className="sf-materials-shelf" role="tablist" aria-label={t('مجلدات المواد الدراسية')}>
          <button
            type="button"
            role="tab"
            aria-selected={activeFolderId === 'all'}
            className={`sf-folder-card ${activeFolderId === 'all' ? 'active' : ''}`}
            onClick={() => setActiveFolderId('all')}
          >
            <div className="sf-folder-card-top">
              <div className="sf-folder-icon" style={{ background: 'var(--accent)' }}>
                <Folder size={18} />
              </div>
              <span className="sf-folder-badge">{formatNumber(items.length)}</span>
            </div>
            <div>
              <h3 className="sf-folder-name">{t('جميع المواد')}</h3>
              <span className="sf-folder-count">{t('عرض كافة الملفات')}</span>
            </div>
          </button>

          {folders.map(folder => {
            const count = items.filter(i => i.folderId === folder.id).length;
            const isSelected = activeFolderId === folder.id;
            return (
              <button
                key={folder.id}
                type="button"
                role="tab"
                aria-selected={isSelected}
                className={`sf-folder-card ${isSelected ? 'active' : ''}`}
                onClick={() => setActiveFolderId(folder.id)}
              >
                <div className="sf-folder-card-top">
                  <div className={`sf-folder-icon ${folder.color || 'bg-indigo-500'}`}>
                    {t(folder.name).charAt(0)}
                  </div>
                  <span className="sf-folder-badge">{formatNumber(count)}</span>
                </div>
                <div>
                  <h3 className="sf-folder-name" title={t(folder.name)}>{t(folder.name)}</h3>
                  <span className="sf-folder-count">{formatNumber(count)} {t('ملفات ومحاضرات')}</span>
                </div>
              </button>
            );
          })}
        </div>
      </section>

      <section aria-label={t('المكتبة والملازم')}>
        <div className="sf-materials-toolbar">
          <div className="sf-materials-filters" role="group" aria-label={t('نوع المرجع')}>
            {Object.entries(TYPE_LABELS).map(([key, labelKey]) => (
              <button
                key={key}
                type="button"
                className={`sf-filter ${filterType === key ? 'active' : ''}`}
                onClick={() => setFilterType(key)}
                aria-pressed={filterType === key}
              >
                {t(labelKey)}
              </button>
            ))}
          </div>

          <div className="sf-materials-search-wrap">
            <label className="sf-search">
              <Search size={18} aria-hidden="true" />
              <input
                type="search"
                name="materials-search"
                aria-label={t('بحث في الملازم والكتب...')}
                placeholder={t('بحث في الملازم والكتب...')}
                value={searchQuery}
                onChange={e => setSearchQuery(e.target.value)}
              />
            </label>
            <span className="sf-materials-count-badge" role="status">
              {formatNumber(filteredItems.length)} {t('ملفات')}
            </span>
          </div>
        </div>

        {filteredItems.length === 0 ? (
          <EmptyState
            title={t('لا توجد ملازم في هذا القسم')}
            description={t('أضف أول كتاب أو مذكرة أو رابط محاضرة لتنظيم مادتك.')}
            action={<Button icon={Plus} onClick={() => setNewItemOpen(true)}>{t('إضافة ملف للمادة')}</Button>}
          />
        ) : (
          <div className="sf-materials-grid">
            {filteredItems.map(item => {
              const total = Math.max(1, Number(item.totalPages) || 1);
              const read = Math.min(total, Math.max(0, Number(item.readPages) || 0));
              const progress = Math.min(100, Math.round((read / total) * 100));
              const isFinished = read >= total;
              return (
                <article className="sf-material-card" key={item.id}>
                  <div className="sf-material-card-head">
                    <div className="sf-material-card-main">
                      <div className="sf-material-type-icon">
                        {item.type === 'book' ? <BookOpen size={22} /> : item.type === 'link' ? <Link2 size={22} /> : <FileText size={22} />}
                      </div>
                      <div className="sf-material-meta">
                        <div className="sf-material-tags">
                          <span className="sf-material-subject-tag">{t(item.subject)}</span>
                          <span className="sf-material-type-tag">{t(TYPE_LABELS[item.type] || item.type)}</span>
                        </div>
                        <h3 className="sf-material-title" dir="auto">{t(item.title)}</h3>
                        {item.description && <p className="sf-material-desc" dir="auto">{item.description}</p>}
                      </div>
                    </div>
                    <button
                      type="button"
                      aria-label={t('حذف المرجع')}
                      onClick={() => deleteItem('materialsItems', item.id)}
                      className="sf-card-delete-btn"
                    >
                      <Trash2 size={16} />
                    </button>
                  </div>

                  {item.type !== 'link' && (
                    <div className="sf-reading-box">
                      <div className="sf-reading-stats">
                        <span className="sf-reading-fraction">
                          {t('صفحات القراءة')}: <strong>{formatNumber(read)}</strong> / {formatNumber(total)}
                        </span>
                        <span className="sf-reading-percent">{progress}%</span>
                      </div>
                      <ProgressBar progress={progress} color="var(--accent)" />
                      {isFinished ? (
                        <div className="sf-completed-banner">
                          <span className="flex items-center gap-1.5 font-bold">
                            <Check size={14} className="text-emerald-500" />
                            {t('تم ختم المرجع بنجاح!')}
                          </span>
                          <button
                            type="button"
                            onClick={() => updateProgress(item.id, -total)}
                            className="sf-reset-read-btn"
                          >
                            {t('إعادة القراءة')}
                          </button>
                        </div>
                      ) : (
                        <div className="sf-reading-actions">
                          <div className="sf-stepper" role="group" aria-label={t('صفحات القراءة')}>
                            <button
                              type="button"
                              onClick={() => updateProgress(item.id, -5)}
                              className="sf-step-btn"
                              title="-5"
                              aria-label="-5"
                            >
                              -5
                            </button>
                            <button
                              type="button"
                              onClick={() => updateProgress(item.id, +5)}
                              className="sf-step-btn sf-step-btn-plus"
                              title={t('+5 صفحات')}
                              aria-label={t('+5 صفحات')}
                            >
                              +5
                            </button>
                            <button
                              type="button"
                              onClick={() => openPageSetter(item)}
                              className="sf-step-btn sf-step-btn-page"
                              title={t('تحديد الصفحة')}
                              aria-label={t('تحديد الصفحة')}
                            >
                              <Edit2 size={12} style={{ marginInlineEnd: 4 }} />
                              <span>{t('تحديد الصفحة')}</span>
                            </button>
                          </div>
                          <button
                            type="button"
                            onClick={() => updateProgress(item.id, total - read)}
                            className="sf-complete-btn"
                            title={t('✓ ختم')}
                            aria-label={t('✓ ختم')}
                          >
                            <Check size={14} />
                            <span>{t('✓ ختم')}</span>
                          </button>
                        </div>
                      )}
                    </div>
                  )}

                  {item.fileUrl && (
                    <a
                      href={item.fileUrl}
                      target="_blank"
                      rel="noreferrer"
                      className="sf-material-link-btn"
                    >
                      <ExternalLink size={14} />
                      {t('فتح المرجع / الرابط')}
                    </a>
                  )}
                </article>
              );
            })}
          </div>
        )}
      </section>

      <Modal isOpen={newFolderOpen} onClose={() => setNewFolderOpen(false)} title={t('إضافة مجلد مادة جديد')}>
        <Form onSubmit={handleAddFolder}>
          <Input
            required
            label={t('اسم المادة')}
            placeholder={t('مثال: أحياء، جيولوجيا، لغة فرنسية...')}
            value={newFolderName}
            onChange={e => setNewFolderName(e.target.value)}
          />
          <Select
            label={t('لون المجلد')}
            value={newFolderColor}
            onChange={e => setNewFolderColor(e.target.value)}
            options={[
              { value: 'bg-indigo-500', label: t('بنفسجي داكن') },
              { value: 'bg-blue-500', label: t('أزرق سماوي') },
              { value: 'bg-emerald-500', label: t('أخضر زمردي') },
              { value: 'bg-amber-500', label: t('كهرماني برتقالي') },
              { value: 'bg-pink-500', label: t('وردي أنيق') },
              { value: 'bg-rose-500', label: t('أحمر قرمزي') },
            ]}
          />
          <div className="sf-form-actions mt-4">
            <Button type="submit" icon={Check}>{t('إنشاء المجلد')}</Button>
            <Button variant="secondary" onClick={() => setNewFolderOpen(false)}>{t('إلغاء')}</Button>
          </div>
        </Form>
      </Modal>

      <Modal isOpen={newItemOpen} onClose={() => setNewItemOpen(false)} title={t('إضافة مرجع أو كتاب أو رابط')}>
        <Form onSubmit={handleAddItem}>
          <Input
            required
            label={t('عنوان المرجع / المذكرة')}
            placeholder={t('مثال: كتاب الشرح الرسمي 2026')}
            value={newItem.title}
            onChange={e => setNewItem({ ...newItem, title: e.target.value })}
          />
          <Select
            label={t('المادة الدراسية')}
            value={newItem.folderId}
            onChange={e => setNewItem({ ...newItem, folderId: e.target.value })}
            options={folders.map(f => ({ value: f.id, label: t(f.name) }))}
          />
          <Select
            label={t('نوع المرجع')}
            value={newItem.type}
            onChange={e => setNewItem({ ...newItem, type: e.target.value })}
            options={[
              { value: 'book', label: t('كتاب دراسي 📚') },
              { value: 'pdf', label: t('ملف PDF أو مذكرة 📄') },
              { value: 'summary', label: t('ملخص سريع 📑') },
              { value: 'exam', label: t('بنك أسئلة وامتحانات 🎯') },
              { value: 'link', label: t('رابط محاضرة / موقع 🔗') },
            ]}
          />
          {newItem.type !== 'link' && (
            <div className="grid grid-cols-2 gap-4">
              <Input
                required
                type="number"
                min="1"
                label={t('إجمالي الصفحات')}
                value={newItem.totalPages}
                onChange={e => setNewItem({ ...newItem, totalPages: e.target.value })}
              />
              <Input
                type="number"
                min="0"
                label={t('الصفحات المقروءة')}
                value={newItem.readPages}
                onChange={e => setNewItem({ ...newItem, readPages: e.target.value })}
              />
            </div>
          )}
          <Input
            label={t('رابط الملف أو المحاضرة (اختياري)')}
            placeholder="https://..."
            value={newItem.fileUrl}
            onChange={e => setNewItem({ ...newItem, fileUrl: e.target.value })}
          />
          <Input
            label={t('ملاحظة أو وصف مختصر')}
            placeholder={t('مثال: هام لمراجعة ليلة الامتحان')}
            value={newItem.description}
            onChange={e => setNewItem({ ...newItem, description: e.target.value })}
          />
          <div className="sf-form-actions mt-4">
            <Button type="submit" icon={Check}>{t('حفظ في مجلد المادة')}</Button>
            <Button variant="secondary" onClick={() => setNewItemOpen(false)}>{t('إلغاء')}</Button>
          </div>
        </Form>
      </Modal>

      <Modal isOpen={!!pageModalItem} onClose={() => setPageModalItem(null)} title={t('تحديد صفحة القراءة')}>
        {pageModalItem && (
          <Form onSubmit={(e) => {
            e.preventDefault();
            const targetPage = Math.min(pageModalItem.total, Math.max(0, Number(pageInputVal) || 0));
            updateItem('materialsItems', pageModalItem.id, { readPages: targetPage });
            notify(t('تم تحديث التقدم: {updated} / {total} صفحة', { updated: String(targetPage), total: String(pageModalItem.total) }));
            setPageModalItem(null);
          }}>
            <p style={{ color: 'var(--muted)', fontSize: 13, marginBottom: 16 }}>
              {t(pageModalItem.title)} ({t('إجمالي الصفحات')}: {pageModalItem.total})
            </p>
            <Input
              type="number"
              min="0"
              max={pageModalItem.total}
              required
              label={t('الصفحة الحالية')}
              value={pageInputVal}
              onChange={e => setPageInputVal(e.target.value)}
            />
            <div className="sf-form-actions mt-4">
              <Button type="submit" icon={Check}>{t('تحديث الصفحة')}</Button>
              <Button variant="secondary" onClick={() => setPageModalItem(null)}>{t('إلغاء')}</Button>
            </div>
          </Form>
        )}
      </Modal>
    </div>
  );
};

const SettingsView = () => {
  const { data, theme, toggleTheme, updateData, resetData } = useAppContext();
  const [profile, setProfile] = useState(data.profile);
  const [saved, setSaved] = useState(false);
  const [confirmReset, setConfirmReset] = useState(false);
  
  const handleClearData = () => { setConfirmReset(false); resetData(); };

  return (
    <div className="max-w-2xl mx-auto animate-fade-in">
      <PageHeader title={t("على ذوقك")} description={t("مساحتك، تفضيلاتك، والطريقة اللي تناسبك.")} />
      <div className="space-y-4">
        <Card><LanguagePicker/><p className="text-xs text-gray-500 mt-2">{t('اختر لغة التطبيق')}</p></Card>
        <Card><div className="sf-section-head"><h2>{t("الملف الشخصي")}</h2><span className="sf-avatar">{profile.name?.charAt(0)}</span></div><Form onSubmit={()=>{updateData('profile',profile);setSaved(true)}}><Input required label={t("الاسم الكامل")} value={profile.name} onChange={e=>{setSaved(false);setProfile({...profile,name:e.target.value})}}/><Select label={t("المرحلة الدراسية")} value={profile.grade} onChange={e=>{setSaved(false);setProfile({...profile,grade:e.target.value})}} options={['المرحلة الإعدادية','المرحلة الثانوية','المرحلة الجامعية','أخرى'].map(g=>({value:g,label:g}))}/><Button type="submit" icon={Check}>{t("حفظ التغييرات")}</Button>{saved&&<p role="status" className="text-green-600 text-xs">{t("تم تحديث ملفك الشخصي")}</p>}</Form></Card>
        <Card className="flex justify-between items-center">
          <div>
            <h3 className="font-bold text-lg dark:text-white">{t("المظهر")}</h3>
            <p className="text-sm text-gray-500">{t("تغيير مظهر التطبيق (فاتح/داكن)")}</p>
          </div>
          <button aria-label={t("تغيير المظهر")} onClick={toggleTheme} className="p-3 bg-gray-100 dark:bg-gray-700 rounded-xl hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors">
            {theme === 'dark' ? <Sun className="text-yellow-500" /> : <Moon className="text-indigo-600" />}
          </button>
        </Card>
        
        <Card>
           <h3 className="font-bold text-lg dark:text-white mb-4 text-red-500">{t("إعادة ضبط المساحة")}</h3>
           <p className="text-sm text-gray-500 mb-4">{t("إزالة بياناتك الحالية والعودة للبيانات التجريبية وشاشة الترحيب. لا يمكن التراجع عن هذه الخطوة.")}</p>
           <Button variant="outline" icon={Trash2} onClick={()=>setConfirmReset(true)}>{t("إعادة ضبط البيانات")}</Button>
        </Card>
      </div>
      <Modal isOpen={confirmReset} onClose={()=>setConfirmReset(false)} title={t("إعادة ضبط البيانات؟")}><p className="text-sm text-gray-500 mb-6 leading-loose">{t("ستفقد مهامك وملاحظاتك وأهدافك الحالية. ستعود المساحة إلى بياناتها التجريبية.")}</p><div className="flex gap-3"><Button variant="danger" onClick={handleClearData}>{t("نعم، إعادة الضبط")}</Button><Button variant="outline" onClick={()=>setConfirmReset(false)}>{t("الاحتفاظ ببياناتي")}</Button></div></Modal>
    </div>
  )
}

const Summary = ({ items }) => <div className="sf-summary">{items.map(([label, value, Icon]) => <div className="sf-summary-item" key={label}><span className="sf-summary-icon"><Icon size={19}/></span><div><strong>{typeof value === 'number' ? formatNumber(value) : value}</strong><small>{t(label)}</small></div></div>)}</div>;

const Dashboard = ({ navigate }) => {
  const { data, updateItem, language } = useAppContext();
  const today = localDateKey();
  const tasks = data.tasks.filter(t => t.date === today);
  const completed = tasks.filter(t => t.completed).length;

  const week = Array.from({ length: 7 }, (_, index) => {
    const day = new Date();
    day.setDate(day.getDate() - 6 + index);
    const key = localDateKey(day);
    return {
      name: new Intl.DateTimeFormat(getLocale(), { weekday: 'short' }).format(day),
      date: key,
      value: data.tasks.filter(task => task.date === key && task.completed).length
    };
  });

  const categories = Object.keys(CATEGORY_LABELS_AR).map(category => ({
    name: t(CATEGORY_LABELS_AR[category]),
    value: data.tasks.filter(task => task.date === today && task.category === category).reduce((sum, task) => sum + scheduledMinutes(task), 0)
  })).filter(item => item.value > 0);

  return (
    <div className="animate-fade-in space-y-6">
      <PageHeader
        title={t('مرحبًا، {name}', { name: data.profile?.name?.split(' ')[0] || t('يا صديقي') })}
        description={t("كل خطوة صغيرة بتقرّبك من حلم كبير. خلّينا نبدأ يومك.")}
      />
      
      <div className="sf-hero">
        <div>
          <h2>{t("وقتك يستاهل خطة حلوة.")}</h2>
          <p>{t("رتّب أولوياتك، خُد نفس، وابدأ بمهمة واحدة. يوم مثمر بيبدأ بخطوة بسيطة.")}</p>
          <div className="flex gap-3 flex-wrap mt-5">
            <Button icon={Play} onClick={() => navigate('pomodoro')}>{t("ابدأ جلسة تركيز")}</Button>
            <Button variant="secondary" icon={Trophy} onClick={() => navigate('rewards')}>{t("المكافآت والجوائز")}</Button>
          </div>
        </div>
      </div>

      <Summary
        items={[
          ['مهام اليوم المنجزة', `${formatNumber(completed)} / ${formatNumber(tasks.length)}`, CheckSquare],
          ['دقائق التركيز المسجلة', data.stats.studyTimeMinutes, Clock],
          ['أهداف قيد التحقيق', data.goals.filter(g => g.current < g.target).length, Target]
        ]}
      />

      <div className="sf-dashboard-grid">
        <Card>
          <div className="sf-section-head">
            <h2>{t("على خطتك اليوم")} <span className="sf-tag">{tasks.length} {t("مهام")}</span></h2>
            <button className="sf-text-link" onClick={() => navigate('planner')}>
              {t("عرض المخطط")} <ChevronLeft size={14} />
            </button>
          </div>
          {tasks.length ? tasks.map(task => (
            <div className="sf-task-row" key={task.id}>
              <button
                aria-label={t('إكمال {name}', { name: task.title })}
                aria-pressed={task.completed}
                className={`sf-check ${task.completed ? 'done' : ''}`}
                onClick={() => updateItem('tasks', task.id, { completed: !task.completed })}
              >
                {task.completed && <Check size={15} />}
              </button>
              <div>
                <h3 dir="auto" className={task.completed ? 'line-through opacity-50' : ''}>{task.title}</h3>
                <small><Clock size={11} /><bdi>{task.startTime} – {task.endTime}</bdi></small>
              </div>
              <span className="sf-tag">{t(CATEGORY_LABELS_AR[task.category])}</span>
            </div>
          )) : (
            <p className="sf-empty">{t("يومك صفحة جديدة. أضف أول مهمة من المخطط.")}</p>
          )}
        </Card>

        <Card>
          <div className="sf-section-head">
            <h2>{t("خطوة نحو أهدافك")}</h2>
            <Target size={19} className="text-purple-400" />
          </div>
          {data.goals.slice(0, 3).map(goal => (
            <div className="sf-goal-row" key={goal.id}>
              <h3>{goal.title}</h3>
              <div className="flex justify-between mb-2">
                <small>{t("مستمر في التقدم")}</small>
                <small>{Math.round(goal.current / Math.max(1, goal.target) * 100)}%</small>
              </div>
              <ProgressBar progress={goal.current / Math.max(1, goal.target) * 100} color={goal.color} />
            </div>
          ))}
          <button className="sf-text-link mt-5" onClick={() => navigate('goals')}>
            {t("كل الأهداف")} <ChevronLeft size={14} />
          </button>
        </Card>
      </div>

      {/* Embedded Statistics and Performance Charts Section */}
      <Card>
        <div className="sf-section-head mb-4">
          <div>
            <h2 className="text-lg font-bold dark:text-white flex items-center gap-2">
              <PieChart size={20} className="text-indigo-500" />
              <span>{t('إحصائيات الأداء الأسبوعي')}</span>
            </h2>
            <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">
              {t('صورة واضحة من مهامك الفعلية، تساعدك على التخطيط للخطوة التالية.')}
            </p>
          </div>
          <span className="sf-tag">
            {week.reduce((sum, day) => sum + day.value, 0)} {t('مهام')}
          </span>
        </div>
        <Suspense fallback={<div className="sf-chart-loading" role="status">{t('جارٍ تحميل الرسوم…')}</div>}>
          <StatisticsCharts key={language} week={week} categories={categories} />
        </Suspense>
      </Card>

      <div className="sf-notice flex gap-3">
        <Sun size={22} className="text-amber-400 shrink-0" />
        <div>
          <strong>{t("استراحة صغيرة تصنع فرقًا")}</strong>
          <p className="text-xs text-gray-500 mt-1">
            {t("بعد كل ٢٥ دقيقة تركيز، ابتعد عن الشاشة لخمس دقائق. طاقتك جزء من خطتك.")}
          </p>
        </div>
      </div>
    </div>
  );
};

const DailyPlanner = () => {
  const { data, updateItem, deleteItem, addItem } = useAppContext();
  const [isOpen, setIsOpen] = useState(false);
  const [taskError, setTaskError] = useState(false);
  const [newTask, setNewTask] = useState({ title: '', category: 'study', startTime: '09:00', endTime: '10:00', priority: 'medium' });

  const handleAdd = () => {
    setTaskError(scheduledMinutes(newTask) <= 0);
    if(newTask.title.trim() && scheduledMinutes(newTask) > 0) {
      addItem('tasks', { ...newTask, completed: false, date: localDateKey() });
      setIsOpen(false);
      setNewTask({ title: '', category: 'study', startTime: '09:00', endTime: '10:00', priority: 'medium' });
    }
  };

  return (
    <div className="animate-fade-in">
      <PageHeader title={t("المخطط اليومي")} description={t("نظم مهامك وجلساتك الدراسية اليومية")} action={<Button onClick={() => setIsOpen(true)} icon={Plus}>{t("مهمة جديدة")}</Button>} />
      
      <Summary items={[["مهام في خطتك",data.tasks.length,CalendarIcon],["تم إنجازها",data.tasks.filter(t=>t.completed).length,CheckSquare],["متبقية",data.tasks.filter(t=>!t.completed).length,Clock]]}/><div className="space-y-4">
        {data.tasks.map(task => (
          <Card key={task.id} hover className={`flex items-center gap-4 transition-all duration-300 ${task.completed ? 'opacity-60 bg-gray-50 dark:bg-gray-800/40 border-dashed' : 'border-l-4 border-l-indigo-500'}`}>
            <button 
              aria-label={t('إكمال {name}',{name:task.title})} aria-pressed={task.completed} onClick={() => updateItem('tasks', task.id, { completed: !task.completed })}
              className={`w-7 h-7 rounded-lg flex items-center justify-center border-2 transition-all ${task.completed ? 'bg-green-500 border-green-500 text-white scale-110 shadow-md shadow-green-200 dark:shadow-none' : 'border-gray-300 dark:border-gray-600 text-transparent hover:border-indigo-400'}`}
            >
              <Check size={16} strokeWidth={3} />
            </button>
            <div className="flex-1">
              <h2 dir="auto" className={`font-bold text-lg dark:text-white ${task.completed ? 'line-through text-gray-500 dark:text-gray-400' : ''}`}>{task.title}</h2>
              <div className="flex flex-wrap gap-3 mt-2 text-xs font-medium text-gray-500 dark:text-gray-400">
                <span className="flex items-center gap-1.5"><Clock size={14}/> <bdi>{task.startTime} – {task.endTime}</bdi></span>
                <span className={`px-2 py-0.5 rounded-md ${CATEGORY_COLORS[task.category]} text-white shadow-sm`}>{t(CATEGORY_LABELS_AR[task.category] || task.category)}</span>
              </div>
            </div>
            <button aria-label={t('حذف {name}',{name:task.title})} onClick={() => deleteItem('tasks', task.id)} className="text-gray-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-900/30 p-2 rounded-lg transition-colors"><Trash2 size={18}/></button>
          </Card>
        ))}
        {data.tasks.length === 0 && (
          <div className="text-center py-16 bg-white dark:bg-gray-800 rounded-2xl border border-dashed border-gray-300 dark:border-gray-700">
             <div className="w-16 h-16 bg-indigo-50 dark:bg-indigo-900/30 rounded-full flex items-center justify-center mx-auto mb-4 text-indigo-500">
                <CheckSquare size={32} />
             </div>
             <h3 className="text-lg font-bold text-gray-700 dark:text-gray-200 mb-1">{t("لا توجد مهام اليوم")}</h3>
             <p className="text-gray-500 dark:text-gray-400 text-sm mb-4">{t("أضف مهمتك الأولى لتنظيم وقتك بفاعلية.")}</p>
             <Button onClick={() => setIsOpen(true)} icon={Plus}>{t("إضافة مهمة")}</Button>
          </div>
        )}
      </div>

      <Modal isOpen={isOpen} onClose={() => setIsOpen(false)} title={t("إضافة مهمة جديدة")}>
        <Form onSubmit={handleAdd}>
          {taskError&&<p role="alert" className="sf-field-error">{t('وقت الانتهاء يجب أن يكون بعد وقت البدء.')}</p>}
          <Input required label={t("عنوان المهمة")} placeholder={t("مثال: مراجعة الفصل الثالث فيزياء")} value={newTask.title} onChange={e => setNewTask({...newTask, title: e.target.value})} />
          <Select 
            label={t("التصنيف")} value={newTask.category} onChange={e => setNewTask({...newTask, category: e.target.value})}
            options={Object.keys(CATEGORY_LABELS_AR).map(k => ({ value: k, label: CATEGORY_LABELS_AR[k] }))}
          />
          <div className="grid grid-cols-2 gap-4">
            <Input required label={t("وقت البدء")} type="time" value={newTask.startTime} onChange={e => setNewTask({...newTask, startTime: e.target.value})} />
            <Input required min={newTask.startTime} label={t("وقت الانتهاء")} type="time" value={newTask.endTime} onChange={e => setNewTask({...newTask, endTime: e.target.value})} />
          </div>
          <Button type="submit" className="w-full mt-2">{t("حفظ المهمة")}</Button>
        </Form>
      </Modal>
    </div>
  );
};

const Onboarding = () => {
  const { updateData, language } = useAppContext();
  const [profile, setProfile] = useState({ name: '', grade: '', phone: '' });
  const [error, setError] = useState('');

  const handleSave = () => {
    if (!profile.name.trim() || !profile.grade) {
      setError('يرجى إدخال الاسم والمرحلة الدراسية كحد أدنى.');
      return;
    }
    updateData('profile', profile);
  };

  return (
    <div className="sf-onboarding min-h-screen bg-gray-50 dark:bg-gray-900 flex items-center justify-center p-4 text-right" dir={language === 'ar' ? 'rtl' : 'ltr'}>
      <Card className="w-full max-w-md p-8 animate-fade-in shadow-2xl shadow-indigo-500/10 border-indigo-100 dark:border-gray-800 relative overflow-hidden">

         
         <div className="mb-6"><LanguagePicker/></div><div className="w-20 h-20 mb-6 mx-auto">
           <img width="80" height="80" src="/assets/enote-icon.png" alt="ENote" className="w-full h-full rounded-2xl" />
         </div>
         
         <h1 className="text-2xl font-black text-center mb-2 dark:text-white text-gray-800">{t("مرحباً بك في")} <bdi translate="no">ENote</bdi></h1>
         <p className="text-center text-gray-500 dark:text-gray-400 mb-8 text-sm">{t("دعنا نتعرف عليك لنقوم بتخصيص تجربتك ومتابعة أهدافك")}</p>
         
         {error && <div className="mb-4 p-3 bg-red-50 dark:bg-red-900/30 text-red-600 dark:text-red-400 text-sm rounded-xl flex items-center gap-2 font-medium"><AlertCircle size={18}/> {t(error)}</div>}

         <Form onSubmit={handleSave}>
           <Input 
             autoComplete="name" required label={t("الاسم الكامل")} 
             placeholder={t("مثال: أحمد محمد")} 
             value={profile.name} 
             onChange={e => {setProfile({...profile, name: e.target.value}); setError('');}} 
           />
           <Select 
             required label={t("المرحلة الدراسية")} 
             value={profile.grade} 
             onChange={e => {setProfile({...profile, grade: e.target.value}); setError('');}}
             options={[
               {value: '', label: 'اختر المرحلة الدراسية...'},
               {value: 'المرحلة الإعدادية', label: 'المرحلة الإعدادية'},
               {value: 'المرحلة الثانوية', label: 'المرحلة الثانوية'},
               {value: 'المرحلة الجامعية', label: 'المرحلة الجامعية'},
               {value: 'أخرى', label: 'أخرى'}
             ]}
           />
           <Input 
             label={t("رقم الهاتف (اختياري)")} 
             autoComplete="tel" type="tel"
             placeholder="01xxxxxxxxx" 
             value={profile.phone} 
             onChange={e => setProfile({...profile, phone: e.target.value})} 
           />
           
           <Button type="submit" className="w-full mt-6 py-3 text-lg h-12 shadow-xl shadow-indigo-200 dark:shadow-none font-bold" icon={ChevronLeft}>{t("ابدأ رحلتك")} </Button>
         </Form>
      </Card>
    </div>
  );
};


// --- AI STUDY ASSISTANT VIEW ---
const AI_QUIZ_BANKS: Record<string, { q: string; qEn: string; options: string[]; optionsEn: string[]; correct: number; explanation: string; explanationEn: string }[]> = {
  physics: [
    {
      q: 'ما هي وحدة قياس شدة التيار الكهربي في النظام الدولي؟',
      qEn: 'What is the SI unit of electric current?',
      options: ['الأمبير (Ampere)', 'الفولت (Volt)', 'الأوم (Ohm)', 'الجول (Joule)'],
      optionsEn: ['Ampere (A)', 'Volt (V)', 'Ohm (Ω)', 'Joule (J)'],
      correct: 0,
      explanation: 'الأمبير هو وحدة قياس شدة التيار الأساسية في النظام الدولي للوحدات (SI).',
      explanationEn: 'The ampere is the base unit of electric current in the International System of Units.'
    },
    {
      q: 'وفقاً لقانون أوم (V = I × R)، ما هي العلاقة بين شدة التيار وفرق الجهد عند ثبوت درجة الحرارة؟',
      qEn: 'According to Ohm\'s Law (V = I × R), what is the relationship between current and voltage at constant temperature?',
      options: ['علاقة طردية خطية', 'علاقة عكسية', 'علاقة تربيعية متغيرة', 'لا توجد علاقة بينهما'],
      optionsEn: ['Directly proportional', 'Inversely proportional', 'Exponential', 'No correlation'],
      correct: 0,
      explanation: 'شدة التيار تتناسب طردياً مع فرق الجهد بين طرفي الموصل عند ثبوت درجة الحرارة.',
      explanationEn: 'Current is directly proportional to voltage across a conductor at a constant temperature.'
    },
    {
      q: 'القوة الدافعة الكهربية للعمود الكهربي تقاس بوحدة:',
      qEn: 'The electromotive force (EMF) of a cell is measured in:',
      options: ['الفولت (Volt)', 'الكولوم (Coulomb)', 'الواط (Watt)', 'النيوتن (Newton)'],
      optionsEn: ['Volt (V)', 'Coulomb (C)', 'Watt (W)', 'Newton (N)'],
      correct: 0,
      explanation: 'القوة الدافعة الكهربية هي الشغل الكلي المبذول لنقل شحنة وتُقاس بالفولت.',
      explanationEn: 'Electromotive force is the total work done per unit charge and is measured in volts.'
    }
  ],
  math: [
    {
      q: 'ما هي المشتقة الأولى للدالة f(x) = x³ + 5x ؟',
      qEn: 'What is the first derivative of f(x) = x³ + 5x ?',
      options: ['3x² + 5', '3x² + 5x', 'x² + 5', '3x + 5'],
      optionsEn: ['3x² + 5', '3x² + 5x', 'x² + 5', '3x + 5'],
      correct: 0,
      explanation: 'مشتقة x³ هي 3x² ومشتقة 5x هي 5 باستخدام قاعدة القوى.',
      explanationEn: 'Using the power rule: d/dx(x³) = 3x² and d/dx(5x) = 5.'
    },
    {
      q: 'قيمة نها (x → 0) للنسبة [ sin(x) / x ] بالتقدير الدائري تساوي:',
      qEn: 'What is the limit of [ sin(x) / x ] as x approaches 0 (in radians)?',
      options: ['1', '0', 'مالانهاية (∞)', 'غير معرّفة'],
      optionsEn: ['1', '0', 'Infinity (∞)', 'Undefined'],
      correct: 0,
      explanation: 'نهاية شهيرة في حساب المثلثات: lim (sin x / x) = 1 عند اقتراب x من الصفر.',
      explanationEn: 'Standard trigonometric limit: lim (sin x / x) = 1 as x approaches 0.'
    }
  ],
  biology: [
    {
      q: 'ما هو العضي الخلوي الملقب بـ «محطة توليد الطاقة» في الخلية؟',
      qEn: 'Which cellular organelle is known as the "powerhouse of the cell"?',
      options: ['الميتوكوندريا (Mitochondria)', 'جهاز جولجي (Golgi)', 'الريبوسوم (Ribosome)', 'الجسم المركزي (Centrosome)'],
      optionsEn: ['Mitochondria', 'Golgi apparatus', 'Ribosome', 'Centrosome'],
      correct: 0,
      explanation: 'الميتوكوندريا هي المسؤولة عن التنفس الخلوي وإنتاج جزيئات ATP الحاملة للطاقة.',
      explanationEn: 'Mitochondria are responsible for cellular respiration and ATP generation.'
    },
    {
      q: 'انتقال جزيئات الماء عبر غشاء شبه منفذ من التركيز الأعلى للماء إلى التركيز الأقل يُعرف بـ:',
      qEn: 'The diffusion of water molecules through a semipermeable membrane is called:',
      options: ['الخاصية الأسموزية (Osmosis)', 'الانتشار البسيط', 'النقل النشط', 'البلعمة الخلوية'],
      optionsEn: ['Osmosis', 'Simple diffusion', 'Active transport', 'Phagocytosis'],
      correct: 0,
      explanation: 'الخاصية الأسموزية تختص بحركة المذيب (الماء) عبر الأغشية شبه المنفذة.',
      explanationEn: 'Osmosis is specifically the movement of solvent molecules through a selectively permeable membrane.'
    }
  ],
  chemistry: [
    {
      q: 'ما هو العدد الذري لعنصر الكربون في الجدول الدوري؟',
      qEn: 'What is the atomic number of Carbon?',
      options: ['6', '12', '8', '14'],
      optionsEn: ['6', '12', '8', '14'],
      correct: 0,
      explanation: 'العدد الذري للكربون هو 6 (يحتوي على 6 بروتونات في نواته) والكتلة الذرية 12.',
      explanationEn: 'Carbon has atomic number 6 (6 protons in the nucleus) and an atomic mass of approximately 12.'
    },
    {
      q: 'الرابطة المتكونة بين ذرة الصوديوم وذرة الكلور في مركب NaCl هي رابطة:',
      qEn: 'The chemical bond formed between Sodium and Chlorine in NaCl is:',
      options: ['رابطة أيونية', 'رابطة تساهمية نقية', 'رابطة هيدروجينية', 'رابطة فلزية'],
      optionsEn: ['Ionic bond', 'Covalent bond', 'Hydrogen bond', 'Metallic bond'],
      correct: 0,
      explanation: 'تنشأ الرابطة الأيونية نتيجة التجاذب الإلكتروستاتيكي بين أيون الصوديوم الموجب وأيون الكلوريد السالب.',
      explanationEn: 'An ionic bond forms through electrostatic attraction between positively charged Na+ and negatively charged Cl-.'
    }
  ]
};

const FormattedAiMessage: React.FC<{ text: string }> = ({ text }) => {
  const lines = text.split('\n');
  const elements: React.ReactNode[] = [];
  let currentList: { number?: string; title?: string; body: string }[] = [];

  const flushList = () => {
    if (currentList.length > 0) {
      elements.push(
        <div key={`list-${elements.length}`} className="sf-ai-step-list">
          {currentList.map((item, i) => (
            <div key={i} className="sf-ai-step-card">
              {item.number ? (
                <span className="sf-ai-step-num">{item.number}</span>
              ) : (
                <span className="text-amber-500 font-bold shrink-0 mt-0.5">✦</span>
              )}
              <div className="flex-1">
                {item.title && <strong className="sf-ai-step-title">{item.title}</strong>}
                <div className="sf-ai-step-desc">{item.body}</div>
              </div>
            </div>
          ))}
        </div>
      );
      currentList = [];
    }
  };

  lines.forEach((rawLine, idx) => {
    const line = rawLine.trim();
    if (!line) {
      flushList();
      return;
    }

    // Match numbered item e.g. "1. **Title**: Description" or "1. Title: Description"
    const numMatch = line.match(/^(\d+)[\.\-\)]\s*(.*)$/);
    if (numMatch) {
      const num = numMatch[1];
      const rest = numMatch[2];
      const titleMatch = rest.match(/^\*\*(.*?)\*\*[:\-]?\s*(.*)$/) || rest.match(/^(.*?):[:\-]?\s*(.*)$/);
      if (titleMatch) {
        currentList.push({
          number: num,
          title: titleMatch[1].replace(/\*\*/g, '').trim(),
          body: titleMatch[2].replace(/\*\*/g, '').trim(),
        });
      } else {
        currentList.push({
          number: num,
          body: rest.replace(/\*\*/g, '').trim(),
        });
      }
      return;
    }

    // Match bullet point e.g. "• **Title**: Body" or "- Title"
    const bulletMatch = line.match(/^[\u2022\-\*✦]\s*(.*)$/);
    if (bulletMatch) {
      const rest = bulletMatch[1];
      const titleMatch = rest.match(/^\*\*(.*?)\*\*[:\-]?\s*(.*)$/);
      if (titleMatch) {
        currentList.push({
          title: titleMatch[1].replace(/\*\*/g, '').trim(),
          body: titleMatch[2].replace(/\*\*/g, '').trim(),
        });
      } else {
        currentList.push({
          body: rest.replace(/\*\*/g, '').trim(),
        });
      }
      return;
    }

    flushList();

    // Regular line: strip leftover raw asterisks
    const cleanText = line.replace(/\*\*(.*?)\*\*/g, '$1');
    elements.push(
      <p key={`p-${idx}`} className="text-xs leading-relaxed my-1 dark:text-gray-200">
        {cleanText}
      </p>
    );
  });

  flushList();

  return <div className="space-y-1">{elements}</div>;
};

const AiAssistantView = () => {
  const { language, addItem, notify } = useAppContext();
  const ar = language === 'ar';
  const [tab, setTab] = useState<'plan' | 'quiz' | 'summary' | 'chat'>('plan');

  // 1. Plan State
  const [topic, setTopic] = useState('فيزياء الباب الأول: التيار الكهربي وقانون أوم');
  const [hours, setHours] = useState('3');
  const [plan, setPlan] = useState<{
    subject: string;
    hours: number;
    phases: { title: string; duration: number; desc: string; startTime: string; endTime: string }[];
    tips: string[];
  } | null>(() => ({
    subject: 'فيزياء الباب الأول: التيار الكهربي وقانون أوم',
    hours: 3,
    phases: [
      {
        title: ar ? 'المرحلة 1: فهم المفاهيم والقوانين الأساسية' : 'Phase 1: Foundations & Core Concepts',
        duration: 45,
        desc: ar ? 'قراءة مركزة لتعريفات شدة التيار، فرق الجهد، والمقاومة مع كتابة القوانين في ورقة جانبية.' : 'Focused reading of electric current, voltage, resistance, and writing down formulas.',
        startTime: '10:00',
        endTime: '10:45'
      },
      {
        title: ar ? 'المرحلة 2: التطبيق وحل المسائل التدريبية' : 'Phase 2: Practice & Problem Solving',
        duration: 75,
        desc: ar ? 'حل 15 مسألة متدرجة الصعوبة على توصيل المقاومات (توالي وتوازي) وقانون أوم للدائرة المغلقة.' : 'Solve 15 graded questions on resistor circuits (series & parallel) and Ohm’s Law.',
        startTime: '11:00',
        endTime: '12:15'
      },
      {
        title: ar ? 'المرحلة 3: الاختبار الذاتي واستخلاص الملاحظات' : 'Phase 3: Active Recall & Summary',
        duration: 45,
        desc: ar ? 'اختبار سريع بدون النظر للكتاب، وتدوين الأفكار التي تحتاج إلى تثبيت في بطاقة الملاحظات.' : 'Closed-book self-test and jotting down tricky points in your revision flashcard.',
        startTime: '12:30',
        endTime: '13:15'
      }
    ],
    tips: [
      ar ? 'طبّق جلسات بومودورو (25 دقيقة مذاكرة + 5 دقائق استراحة) للحفاظ على صفاء ذهنك.' : 'Use 25-minute Pomodoro sprints with 5-minute walks to maintain optimal focus.',
      ar ? 'لا تنتقل لحل المسائل قبل حفظ وفهم استنتاجات القوانين بشكل بصري.' : 'Master the underlying physics equations before jumping into multi-step problems.'
    ]
  }));

  const [isAiLoading, setIsAiLoading] = useState(false);

  const handleGeneratePlan = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!topic.trim() || isAiLoading) return;
    setIsAiLoading(true);
    try {
      const realPlan = await generateRealPlan(topic.trim(), Number(hours) || 2, ar);
      setPlan(realPlan);
      notify(ar ? 'تم توليد خطة المذاكرة بالذكاء الاصطناعي الحقيقي!' : 'Generated real study plan with AI!');
    } catch (err) {
      console.warn(err);
      notify(ar ? 'تم تجهيز خطة المذاكرة المقترحة!' : 'Study plan ready!');
    } finally {
      setIsAiLoading(false);
    }
  };

  const handleAddPlanToPlanner = () => {
    if (!plan) return;
    const today = localDateKey();
    plan.phases.forEach((p, idx) => {
      addItem('tasks', {
        title: `${plan.subject}: ${p.title}`,
        category: 'study',
        startTime: p.startTime,
        endTime: p.endTime,
        completed: false,
        priority: idx === 1 ? 'high' : 'medium',
        date: today
      });
    });
    notify(t('تمت إضافة مهام الخطة إلى المخطط بنجاح'));
  };

  // 2. Quiz State
  const [selectedSubject, setSelectedSubject] = useState('physics');
  const [answers, setAnswers] = useState<Record<number, number>>({});
  const [dynamicQuestions, setDynamicQuestions] = useState<any[] | null>(null);
  const questions = dynamicQuestions || AI_QUIZ_BANKS[selectedSubject] || AI_QUIZ_BANKS.physics;

  const handleSelectAnswer = (qIdx: number, optIdx: number) => {
    setAnswers(prev => ({ ...prev, [qIdx]: optIdx }));
  };

  const score = Object.entries(answers).reduce((acc, [qIdx, optIdx]) => {
    return acc + (questions[Number(qIdx)]?.correct === optIdx ? 1 : 0);
  }, 0);

  // 3. Summarizer State
  const [summaryInput, setSummaryInput] = useState(
    ar
      ? 'ينص قانون أوم على أن شدة التيار الكهربي المار في موصل فلزي تتناسب طردياً مع فرق الجهد بين طرفيه عند ثبوت درجة الحرارة. ويرمز للقانون رياضياً بالصيغة: V = I × R. حيث V هو فرق الجهد بالفولت، I هي شدة التيار بالأمبير، و R هي المقاومة الكهربية بالأوم. كما يمكن توصيل المقاومات على التوالي للحصول على مقاومة كبيرة من عدة مقاومات صغيرة، أو على التوازي للحصول على مقاومة صغيرة وتوزيع التيار.'
      : 'Ohm’s law states that the current through a conductor between two points is directly proportional to the voltage across the two points, provided the temperature remains constant. Mathematically: V = I × R, where V is voltage (volts), I is current (amperes), and R is resistance (ohms). Resistors can be connected in series to increase equivalent resistance or in parallel to decrease it.'
  );
  const [summaryData, setSummaryData] = useState<{
    title: string;
    keyPoints: string[];
    terms: string[];
    questions: string[];
  } | null>(null);

  const handleSummarize = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!summaryInput.trim() || isAiLoading) return;
    setIsAiLoading(true);
    try {
      const realSum = await summarizeRealNotes(summaryInput.trim(), ar);
      setSummaryData(realSum);
      notify(ar ? 'تم التلخيص بنجاح بواسطة الذكاء الاصطناعي الحقيقي!' : 'Successfully summarized with Real AI!');
    } catch (err) {
      console.warn(err);
      notify(ar ? 'تم استخراج التلخيص بنجاح!' : 'Summary ready!');
    } finally {
      setIsAiLoading(false);
    }
  };

  const handleSaveSummaryAsNote = () => {
    if (!summaryData) return;
    const content = [
      `### ${summaryData.title}`,
      `\n**${t('النقاط الجوهرية المستخلصة')}**:`,
      ...summaryData.keyPoints.map(p => `• ${p}`),
      `\n**${t('المصطلحات والقوانين الهامة')}**:`,
      ...summaryData.terms.map(t => `• ${t}`),
      `\n**${t('أسئلة مراجعة سريعة')}**:`,
      ...summaryData.questions.map(q => `• ${q}`)
    ].join('\n');

    addItem('notes', {
      title: summaryData.title,
      content,
      folder: 'ملخصات ذكية',
      updatedAt: localDateKey()
    });
    notify(t('تم حفظ التلخيص في الملاحظات بنجاح'));
  };

  // 4. Chat State
  const [messages, setMessages] = useState<{ role: 'bot' | 'user'; text: string; time: string }[]>([
    {
      role: 'bot',
      text: t('أهلاً بك! أنا مساعدك الدراسي الذكي في ENote. كيف يمكنني مساعدتك في مذاكرتك اليوم؟'),
      time: '12:00'
    }
  ]);
  const [chatInput, setChatInput] = useState('');
  const chatEndRef = useRef<HTMLDivElement>(null);

  const handleSendChat = async (textToSend?: string) => {
    const query = (textToSend || chatInput).trim();
    if (!query || isAiLoading) return;
    const timeNow = new Intl.DateTimeFormat(getLocale(), { hour: '2-digit', minute: '2-digit' }).format(new Date());
    const newMsgs = [...messages, { role: 'user' as const, text: query, time: timeNow }];
    setMessages(newMsgs);
    if (!textToSend) setChatInput('');
    setIsAiLoading(true);

    try {
      const systemPrompt = ar
        ? 'أنت مساعد دراسي وتربوي ذكي، ودود، ومحفز في تطبيق ENote. تقدم نصائح دراسية عملية ومباشرة، وتقترح طرق تنظيم المذاكرة والتركيز وتلخيص المفاهيم.'
        : 'You are an intelligent, friendly, and motivational study tutor in ENote app. Give practical, structured, and pedagogical advice.';
      
      const apiMessages: any[] = [
        { role: 'system', content: systemPrompt },
        ...newMsgs.slice(-6).map(m => ({
          role: (m.role === 'bot' ? 'assistant' : 'user'),
          content: m.text
        }))
      ];

      const aiReply = await callRealAi(apiMessages);
      const replyTime = new Intl.DateTimeFormat(getLocale(), { hour: '2-digit', minute: '2-digit' }).format(new Date());
      setMessages(prev => [...prev, { role: 'bot', text: aiReply, time: replyTime }]);
    } catch (err) {
      const replyTime = new Intl.DateTimeFormat(getLocale(), { hour: '2-digit', minute: '2-digit' }).format(new Date());
      setMessages(prev => [...prev, {
        role: 'bot',
        text: generatePedagogicalAdvice(query),
        time: replyTime
      }]);
    } finally {
      setIsAiLoading(false);
    }
  };

  useEffect(() => {
    chatEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  return (
    <div className="animate-fade-in sf-ai-hub">
      <PageHeader
        title={t('المساعد الذكي')}
        description={t('رفيقك الذكي لتنظيم المذاكرة، توليد الخطط، والاختبارات السريعة.')}
      />

      <div className="sf-ai-nav" role="tablist" aria-label={t('المساعد الذكي')}>
        {[
          { id: 'plan', label: t('خطة مذاكرة 📋'), icon: Sparkles },
          { id: 'quiz', label: t('اختبار تفاعلي 🎯'), icon: HelpCircle },
          { id: 'summary', label: t('تلخيص مذكرات 📑'), icon: FileText },
          { id: 'chat', label: t('محادثة حرة 💬'), icon: Bot }
        ].map(item => (
          <button
            key={item.id}
            type="button"
            role="tab"
            aria-selected={tab === item.id}
            className={`sf-filter ${tab === item.id ? 'active' : ''}`}
            onClick={() => setTab(item.id as any)}
          >
            <item.icon size={16} aria-hidden="true" />
            <span>{item.label}</span>
          </button>
        ))}
      </div>

      <div className="sf-ai-banner">
        <div className="sf-ai-banner-content">
          <div className="sf-ai-banner-icon">
            <Sparkles size={24} />
          </div>
          <div>
            <div className="flex items-center gap-2 flex-wrap">
              <h2 className="text-base font-bold dark:text-white">{t('مساعد الذكاء الاصطناعي')}</h2>
              <span className="sf-tag bg-purple-500/10 text-purple-600 dark:text-purple-400 font-bold">
                {t('مساعد ذكي حقيقي (LLM مجاني ✦)')}
              </span>
              {isAiLoading && (
                <span className="sf-ai-loading-pill">
                  <Sparkles size={12} className="animate-spin" />
                  {t('جاري التفكير والتوليد بالذكاء الاصطناعي...')}
                </span>
              )}
            </div>
            <p className="text-xs text-gray-500 dark:text-gray-400 mt-0.5">
              {tab === 'plan' && t('توليد خطة مذاكرة ذكية')}
              {tab === 'quiz' && t('بدء اختبار سريع')}
              {tab === 'summary' && t('تلخيص نص أو محاضرة')}
              {tab === 'chat' && t('اسأل المساعد الذكي أي شيء...')}
            </p>
          </div>
        </div>
      </div>

      {/* TAB 1: PLAN GENERATOR */}
      {tab === 'plan' && (
        <div className="space-y-6">
          <Card>
            <Form onSubmit={handleGeneratePlan}>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div className="md:col-span-2">
                  <Input
                    required
                    label={t('المادة أو الدرس')}
                    placeholder={ar ? 'مثال: فيزياء الباب الأول، كيمياء عضوية...' : 'e.g. Unit 1 Physics, Organic Chemistry...'}
                    value={topic}
                    onChange={e => setTopic(e.target.value)}
                  />
                </div>
                <div>
                  <Input
                    required
                    type="number"
                    min="1"
                    max="10"
                    label={t('عدد ساعات المذاكرة المتاحة')}
                    value={hours}
                    onChange={e => setHours(e.target.value)}
                  />
                </div>
              </div>
              <div className="sf-form-actions mt-4 flex items-center justify-between">
                <Button type="submit" icon={Sparkles} disabled={isAiLoading}>
                  {isAiLoading ? t('جاري التفكير والتوليد بالذكاء الاصطناعي...') : t('توليد بالذكاء الاصطناعي الحقيقي')}
                </Button>
                {plan && (
                  <Button type="button" variant="secondary" icon={Check} onClick={handleAddPlanToPlanner}>
                    {t('إضافة الخطة إلى المخطط اليومي')}
                  </Button>
                )}
              </div>
            </Form>
          </Card>

          {plan && (
            <Card>
              <div className="sf-section-head mb-4">
                <h2>{t('مراحل الخطة المقترحة')} — <span className="text-indigo-500 font-bold">{plan.subject}</span></h2>
                <span className="sf-tag">{plan.hours} {t('ساعات')}</span>
              </div>
              <div className="space-y-3">
                {plan.phases.map((ph, idx) => (
                  <div key={idx} className="sf-ai-phase">
                    <div className="flex justify-between items-center mb-1">
                      <strong className="text-sm dark:text-white flex items-center gap-2">
                        <span className="w-5 h-5 rounded-full bg-indigo-500/10 text-indigo-500 inline-grid place-items-center text-xs font-bold">
                          {idx + 1}
                        </span>
                        {ph.title}
                      </strong>
                      <span className="text-xs text-indigo-500 font-semibold bg-indigo-500/10 px-2 py-0.5 rounded-full">
                        {ph.duration} {t('دقيقة')}
                      </span>
                    </div>
                    <p className="text-xs text-gray-500 dark:text-gray-400 mt-1 leading-relaxed">{ph.desc}</p>
                    <div className="mt-2 text-[11px] text-gray-400 flex items-center gap-1">
                      <Clock size={12} />
                      <bdi>{ph.startTime} – {ph.endTime}</bdi>
                    </div>
                  </div>
                ))}
              </div>

              <div className="mt-5 pt-4 border-t border-gray-100 dark:border-gray-800">
                <h3 className="text-xs font-bold uppercase tracking-wider text-gray-400 mb-2">{t('نصائح ذكية للمذاكرة الفعالة')}</h3>
                <ul className="space-y-1.5 text-xs text-gray-600 dark:text-gray-300">
                  {plan.tips.map((tip, idx) => (
                    <li key={idx} className="flex items-start gap-2">
                      <span className="text-amber-500 font-bold mt-0.5">✦</span>
                      <span>{tip}</span>
                    </li>
                  ))}
                </ul>
              </div>
            </Card>
          )}
        </div>
      )}

      {/* TAB 2: QUIZ BANK */}
      {tab === 'quiz' && (
        <div className="space-y-6">
          <Card>
            <div className="flex flex-wrap items-center justify-between gap-3 mb-4">
              <div className="flex items-center gap-2">
                <span className="text-sm font-bold dark:text-white">{t('اختر مادة الاختبار')}:</span>
                <select
                  value={selectedSubject}
                  onChange={e => {
                    setSelectedSubject(e.target.value);
                    setAnswers({});
                  }}
                  className="bg-gray-50 dark:bg-gray-800 border border-gray-200 dark:border-gray-700 text-sm rounded-lg px-3 py-1.5 font-medium outline-none focus:border-indigo-500"
                >
                  <option value="physics">{t('فيزياء')}</option>
                  <option value="math">{t('رياضيات بحتة')}</option>
                  <option value="biology">{t('أحياء')}</option>
                  <option value="chemistry">{t('كيمياء')}</option>
                </select>
              </div>

              <div className="flex items-center gap-3">
                <Button
                  type="button"
                  variant="secondary"
                  icon={Sparkles}
                  disabled={isAiLoading}
                  onClick={async () => {
                    setIsAiLoading(true);
                    try {
                      const newQ = await generateRealQuiz(selectedSubject, ar);
                      if (newQ.length) {
                        setDynamicQuestions(newQ.map(q => ({
                          q: q.question,
                          qEn: q.question,
                          options: q.options,
                          optionsEn: q.options,
                          correct: q.correctIndex,
                          explanation: q.explanation,
                          explanationEn: q.explanation
                        })));
                        setAnswers({});
                        notify(ar ? 'تم توليد أسئلة ذكية جديدة بالذكاء الاصطناعي!' : 'Generated new AI questions!');
                      }
                    } finally {
                      setIsAiLoading(false);
                    }
                  }}
                >
                  {isAiLoading ? t('جاري التفكير والتوليد بالذكاء الاصطناعي...') : t('توليد أسئلة جديدة بالذكاء الاصطناعي')}
                </Button>
                <span className="text-xs font-bold text-indigo-500 bg-indigo-500/10 px-3 py-1 rounded-full">
                  {t('النتيجة: {score} من {total}', { score: String(score), total: String(questions.length) })}
                </span>
                <button
                  type="button"
                  onClick={() => setAnswers({})}
                  className="sf-text-link flex items-center gap-1 text-xs"
                >
                  <RefreshCw size={13} />
                  <span>{t('أعد الاختبار')}</span>
                </button>
              </div>
            </div>

            <div className="space-y-6">
              {questions.map((qItem, qIdx) => {
                const qText = ar ? qItem.q : qItem.qEn;
                const opts = ar ? qItem.options : qItem.optionsEn;
                const explanation = ar ? qItem.explanation : qItem.explanationEn;
                const chosen = answers[qIdx];
                const isAnswered = chosen !== undefined;

                return (
                  <div key={qIdx} className="p-4 rounded-xl border border-gray-100 dark:border-gray-800 bg-gray-50/50 dark:bg-gray-800/30">
                    <p className="text-sm font-bold dark:text-white mb-3 flex items-start gap-2">
                      <span className="text-indigo-500">#{qIdx + 1}</span>
                      <span>{qText}</span>
                    </p>

                    <div className="space-y-2">
                      {opts.map((opt, optIdx) => {
                        let optClass = 'sf-ai-quiz-opt';
                        if (isAnswered) {
                          if (optIdx === qItem.correct) optClass += ' correct';
                          else if (optIdx === chosen) optClass += ' wrong';
                        } else if (chosen === optIdx) {
                          optClass += ' selected';
                        }
                        return (
                          <button
                            key={optIdx}
                            type="button"
                            className={optClass}
                            onClick={() => handleSelectAnswer(qIdx, optIdx)}
                          >
                            <span className="font-mono text-xs opacity-60 mr-2 ml-1">
                              {['A', 'B', 'C', 'D'][optIdx]}.
                            </span>
                            {opt}
                          </button>
                        );
                      })}
                    </div>

                    {isAnswered && (
                      <div className="mt-3 p-3 rounded-lg text-xs bg-indigo-50/50 dark:bg-indigo-950/30 text-indigo-700 dark:text-indigo-300 border border-indigo-100 dark:border-indigo-900/50">
                        <strong>{chosen === qItem.correct ? t('إجابة صحيحة! أحسنت 🎯') : t('إجابة غير صحيحة. الإجابة الصحيحة هي: {ans}', { ans: opts[qItem.correct] })}</strong>
                        <p className="mt-1 opacity-90">{explanation}</p>
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          </Card>
        </div>
      )}

      {/* TAB 3: SUMMARIZER */}
      {tab === 'summary' && (
        <div className="space-y-6">
          <Card>
            <Form onSubmit={handleSummarize}>
              <div className="flex justify-between items-center mb-2">
                <label className="text-sm font-bold dark:text-white">{t('تلخيص نص أو محاضرة')}</label>
                <button
                  type="button"
                  className="sf-text-link text-xs flex items-center gap-1"
                  onClick={() => setSummaryInput(
                    ar
                      ? 'قانون الجاذبية الكونية لنيوتن: كل جسمين في الكون يتجاذبان بقوة تتناسب طردياً مع حاصل ضرب كتلتيهما وعكسياً مع مربع المسافة بين مركزيهما. الصيغة: F = G * (m1 * m2) / r². حيث G هو ثابت الجذب العام، و F هي قوة التجاذب بالنيوتن. تُعد الجاذبية مسؤولة عن حركة الكواكب حول الشمس والمد والجزر في المحيطات.'
                      : 'Newton\'s law of universal gravitation states that any particle of matter attracts any other with a force directly proportional to the product of their masses and inversely proportional to the square of the distance between them: F = G * (m1 * m2) / r².'
                  )}
                >
                  <RefreshCw size={12} />
                  <span>{t('نموذج ملخص جاهز')}</span>
                </button>
              </div>

              <textarea
                rows={5}
                required
                className="w-full bg-gray-50 dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-xl p-3 text-sm dark:text-white outline-none focus:border-indigo-500 leading-relaxed font-sans"
                placeholder={t('الصق محتوى الدرس أو المحاضرة هنا...')}
                value={summaryInput}
                onChange={e => setSummaryInput(e.target.value)}
              />

              <div className="sf-form-actions mt-3 flex justify-between items-center">
                <Button type="submit" icon={Sparkles} disabled={isAiLoading}>
                  {isAiLoading ? t('جاري التفكير والتوليد بالذكاء الاصطناعي...') : t('توليد بالذكاء الاصطناعي الحقيقي')}
                </Button>
                {summaryData && (
                  <Button type="button" variant="secondary" icon={Bookmark} onClick={handleSaveSummaryAsNote}>
                    {t('حفظ التلخيص كملاحظة')}
                  </Button>
                )}
              </div>
            </Form>
          </Card>

          {summaryData && (
            <Card>
              <div className="sf-section-head mb-4">
                <h2>{summaryData.title}</h2>
                <span className="sf-tag">{t('تلخيص فوري')}</span>
              </div>

              <div className="space-y-4">
                <div>
                  <h3 className="text-xs font-bold uppercase tracking-wider text-indigo-500 mb-2 flex items-center gap-1.5">
                    <CheckSquare size={14} />
                    <span>{t('النقاط الجوهرية المستخلصة')}</span>
                  </h3>
                  <ul className="space-y-1.5 text-xs text-gray-700 dark:text-gray-300">
                    {summaryData.keyPoints.map((pt, idx) => (
                      <li key={idx} className="flex items-start gap-2">
                        <span className="text-indigo-500">•</span>
                        <span>{pt}</span>
                      </li>
                    ))}
                  </ul>
                </div>

                <div>
                  <h3 className="text-xs font-bold uppercase tracking-wider text-indigo-500 mb-2 flex items-center gap-1.5">
                    <FileText size={14} />
                    <span>{t('المصطلحات والقوانين الهامة')}</span>
                  </h3>
                  <ul className="space-y-1.5 text-xs text-gray-700 dark:text-gray-300">
                    {summaryData.terms.map((term, idx) => (
                      <li key={idx} className="flex items-start gap-2">
                        <span className="text-indigo-500 font-bold">✦</span>
                        <span>{term}</span>
                      </li>
                    ))}
                  </ul>
                </div>

                <div>
                  <h3 className="text-xs font-bold uppercase tracking-wider text-indigo-500 mb-2 flex items-center gap-1.5">
                    <HelpCircle size={14} />
                    <span>{t('أسئلة مراجعة سريعة')}</span>
                  </h3>
                  <ul className="space-y-1.5 text-xs text-gray-700 dark:text-gray-300">
                    {summaryData.questions.map((q, idx) => (
                      <li key={idx} className="flex items-start gap-2">
                        <span className="text-indigo-500 font-bold">?</span>
                        <span>{q}</span>
                      </li>
                    ))}
                  </ul>
                </div>
              </div>
            </Card>
          )}
        </div>
      )}

      {/* TAB 4: CHAT */}
      {tab === 'chat' && (
        <div className="sf-ai-chat-wrap">
          <div className="p-3 border-b border-gray-100 dark:border-gray-800 bg-gray-50/50 dark:bg-gray-800/40 flex items-center gap-2 overflow-x-auto scrollbar-none">
            <span className="text-xs text-gray-400 font-medium whitespace-nowrap">{t('اقتراحات سريعة')}:</span>
            {[
              ar ? 'نصائح لزيادة التركيز في بومودورو' : 'Tips for Pomodoro focus',
              ar ? 'كيف أذاكر بدون ما أنسى؟' : 'How to remember what I study?',
              ar ? 'كيف أعمل جدول مذاكرة متوازن؟' : 'How to build a balanced study schedule?'
            ].map(prompt => (
              <button
                key={prompt}
                type="button"
                onClick={() => handleSendChat(prompt)}
                className="whitespace-nowrap text-xs px-2.5 py-1 rounded-full bg-white dark:bg-gray-700 border border-gray-200 dark:border-gray-600 hover:border-indigo-500 dark:hover:border-indigo-400 transition-colors"
              >
                {prompt}
              </button>
            ))}
          </div>

          <div className="sf-ai-messages">
            {messages.map((msg, idx) => (
              <div key={idx} className={`sf-ai-msg ${msg.role}`}>
                <div className="sf-ai-bubble">
                  <FormattedAiMessage text={msg.text} />
                  <small className="block text-[10px] opacity-60 mt-2 text-right dir-auto">{msg.time}</small>
                </div>
              </div>
            ))}
            <div ref={chatEndRef} />
          </div>

          <form
            className="sf-ai-input-wrap"
            onSubmit={e => {
              e.preventDefault();
              handleSendChat();
            }}
          >
            <input
              type="text"
              className="sf-ai-input"
              placeholder={t('اسأل المساعد الذكي أي شيء...')}
              value={chatInput}
              onChange={e => setChatInput(e.target.value)}
            />
            <Button type="submit" icon={Send}>{t('إرسال')}</Button>
          </form>
        </div>
      )}
    </div>
  );
};


// --- LAYOUT ---
const NAV_ITEMS = [
  ['dashboard','الرئيسية',Home],['planner','المخطط اليومي',CalendarIcon],['pomodoro','مؤقت التركيز',Clock],['materials','المكتبة والملازم',Folder],['ai','المساعد الذكي',Sparkles],['rewards','المكافآت والجوائز',Trophy],['homework','الواجبات',BookOpen],['goals','الأهداف',Target],['habits','العادات',Activity],['notes','الملاحظات',FileText],['settings','الإعدادات',Settings]
];
const screenFromLocation = () => {
  const hash = location.hash.slice(1);
  if (hash === 'stats') return 'dashboard';
  return NAV_ITEMS.some(([id])=>id===hash) ? hash : 'dashboard';
};
const AppLayout = () => {
  const [currentPage, setCurrentPage] = useState(screenFromLocation);
  const [menuOpen, setMenuOpen] = useState(false);
  const [compact, setCompact] = useState(()=>matchMedia('(max-width:800px)').matches);
  const drawer = useRef(null), content = useRef(null);
  const { data, theme, toggleTheme, language } = useAppContext();
  const navigate = id => { if (id!==currentPage) history.pushState(null,'',`#${id}`);setCurrentPage(id);setMenuOpen(false);window.scrollTo({top:0,behavior:'instant'}); };
  const followLink = (event,id) => { if(event.metaKey||event.ctrlKey||event.shiftKey||event.altKey||event.button!==0)return;event.preventDefault();navigate(id); };
  useEffect(()=>{const sync=()=>{setCurrentPage(screenFromLocation());setMenuOpen(false)};addEventListener('popstate',sync);addEventListener('hashchange',sync);const media=matchMedia('(max-width:800px)');const resize=()=>{setCompact(media.matches);if(!media.matches)setMenuOpen(false)};media.addEventListener('change',resize);return()=>{removeEventListener('popstate',sync);removeEventListener('hashchange',sync);media.removeEventListener('change',resize)}},[]);
  useEffect(()=>{document.title=`${t(NAV_ITEMS.find(([id])=>id===currentPage)?.[1] || '')} · ENote`;const frame=requestAnimationFrame(()=>content.current?.querySelector('.screen-'+currentPage+' h1')?.focus({preventScroll:true}));return()=>cancelAnimationFrame(frame)},[currentPage,language]);
  useEffect(()=>{
    if(!menuOpen||!compact)return;
    const previous=document.activeElement, overflow=document.body.style.overflow;
    document.body.style.overflow='hidden';drawer.current?.querySelector('button,a')?.focus();
    const keydown=event=>{if(event.key==='Escape')setMenuOpen(false);if(event.key==='Tab'){const items=[...drawer.current.querySelectorAll('button,a[href]')];const first=items[0],last=items[items.length-1];if(event.shiftKey&&document.activeElement===first){event.preventDefault();last.focus()}else if(!event.shiftKey&&document.activeElement===last){event.preventDefault();first.focus()}}};
    document.addEventListener('keydown',keydown);return()=>{document.body.style.overflow=overflow;document.removeEventListener('keydown',keydown);previous?.focus?.()};
  },[menuOpen,compact]);
  const screens={dashboard:<Dashboard navigate={navigate}/>,planner:<DailyPlanner/>,materials:<MaterialsHub/>,ai:<AiAssistantView/>,rewards:<RewardsView navigate={navigate}/>,homework:<Homework/>,goals:<Goals/>,habits:<Habits/>,notes:<Notes/>,settings:<SettingsView/>};
  const backgroundInert=menuOpen&&compact?{inert:''}:{};
  return <div className="sf-shell" dir={language==='ar'?'rtl':'ltr'}><a className="sf-skip-link" href="#main-content" onClick={event=>{event.preventDefault();content.current?.focus()}}>{t('تخطي إلى المحتوى')}</a>
    {menuOpen&&compact&&<button type="button" tabIndex={-1} className="sf-drawer-backdrop" aria-label={t('إغلاق القائمة')} onClick={()=>setMenuOpen(false)}/>}
    <aside ref={drawer} className={`sf-sidebar ${menuOpen?'open':''}`} role={compact?'dialog':undefined} aria-modal={compact&&menuOpen?true:undefined} aria-hidden={compact&&!menuOpen?true:undefined} {...(compact&&!menuOpen?{inert:''}:{})} aria-label={t('القائمة الرئيسية')}>
      <div className="sf-brand"><img src="/assets/enote-icon.png" alt="" width="44" height="44"/><div><bdi translate="no">ENote</bdi><small>{t('رفيقك الدراسي')}</small></div><button className="sf-icon-button sf-close-sidebar" aria-label={t('إغلاق القائمة')} onClick={()=>setMenuOpen(false)}><X size={20}/></button></div>
      <nav aria-label={t('القائمة الرئيسية')}>{NAV_ITEMS.map(([id,label,Icon])=><a key={id} href={`#${id}`} aria-current={currentPage===id?'page':undefined} className={`sf-nav-item ${currentPage===id?'active':''}`} onClick={event=>followLink(event,id)}><Icon size={20} aria-hidden="true"/>{t(label)}</a>)}</nav>
      <div className="sf-sidebar-bottom"><div className="sf-sidebar-tip"><Star size={20} aria-hidden="true"/><strong>{t('التزامك اليوم، نجاحك بكرة')}</strong><p>{t('مش لازم تكون مثالي. المهم إنك تكمّل، خطوة كل يوم.')}</p></div><a href="#settings" className="sf-profile" onClick={event=>followLink(event,'settings')}><span className="sf-avatar" aria-hidden="true">{data.profile?.name?.charAt(0)}</span><span><strong dir="auto">{data.profile?.name}</strong><small>{t(data.profile?.grade||'')}</small></span><Settings size={18} aria-hidden="true"/></a></div>
    </aside><main className="sf-main" {...backgroundInert}><header className="sf-topbar"><div className="sf-topbar-location"><button className="sf-icon-button sf-mobile-menu" aria-label={t('فتح القائمة')} aria-expanded={menuOpen} onClick={()=>setMenuOpen(true)}><Menu size={21}/></button><div><strong>{t(NAV_ITEMS.find(([id])=>id===currentPage)?.[1]||'')}</strong><time dateTime={localDateKey()}>{formatDate(new Date())}</time></div></div><div className="sf-topbar-actions"><button className="sf-icon-button" aria-label={t(theme==='dark'?'تفعيل المظهر الفاتح':'تفعيل المظهر الداكن')} onClick={toggleTheme}>{theme==='dark'?<Sun size={20}/>:<Moon size={20}/>}</button><a href="#settings" aria-label={t('الملف الشخصي')} className="sf-avatar" onClick={event=>followLink(event,'settings')}>{data.profile?.name?.charAt(0)}</a></div></header><div className="sf-content" id="main-content" tabIndex={-1} ref={content}><section className="screen-pomodoro" hidden={currentPage!=='pomodoro'}><Pomodoro/></section><section className={`screen-${currentPage}`} hidden={currentPage==='pomodoro'} key={currentPage}>{screens[currentPage]}</section></div></main>
    <nav className="sf-bottom-nav" aria-label={t('التنقل السريع')} {...backgroundInert}>{NAV_ITEMS.slice(0,4).map(([id,label,Icon])=><a key={id} href={`#${id}`} aria-current={currentPage===id?'page':undefined} className={currentPage===id?'active':''} onClick={event=>followLink(event,id)}><Icon size={21} aria-hidden="true"/>{t(label)}</a>)}<button className={NAV_ITEMS.slice(4).some(([id])=>id===currentPage)?'active':''} aria-expanded={menuOpen} onClick={()=>setMenuOpen(true)}><Menu size={21}/>{t('المزيد')}</button></nav>
  </div>;
};

const MainApp = () => {
  const { data } = useAppContext();
  
  // Show Onboarding if user hasn't set up their profile yet
  if (!data.profile) {
    return <Onboarding />;
  }

  return <AppLayout />;
};

export default function App() {
  return (
    <>
      <AppProvider>
        <MainApp />
      </AppProvider>
    </>
  );
}
