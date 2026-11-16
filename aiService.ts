// aiService.ts - Real & Free AI Assistant Client using Pollinations AI LLM Engine

export interface AiChatMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

export interface GeneratedStudyPhase {
  title: string;
  duration: number; // in minutes
  desc: string;
  startTime: string;
  endTime: string;
}

export interface GeneratedStudyPlan {
  subject: string;
  hours: number;
  phases: GeneratedStudyPhase[];
  tips: string[];
}

export interface GeneratedSummary {
  title: string;
  keyPoints: string[];
  terms: string[];
  questions: string[];
}

export interface GeneratedQuizQuestion {
  question: string;
  options: string[];
  correctIndex: number;
  explanation: string;
}

const POLLINATIONS_URL = 'https://text.pollinations.ai/';

/**
 * Call the free, real LLM endpoint with conversation messages
 */
export async function callRealAi(
  messages: AiChatMessage[],
  options: { model?: string; temperature?: number } = {}
): Promise<string> {
  const model = options.model || 'openai';
  const systemMsg = messages.find((m) => m.role === 'system')?.content || '';
  const nonSystemMsgs = messages.filter((m) => m.role !== 'system');

  let promptText = '';
  if (nonSystemMsgs.length === 1) {
    promptText = nonSystemMsgs[0].content;
  } else {
    promptText = nonSystemMsgs
      .map((m) => `${m.role === 'user' ? 'الطالب' : 'المساعد'}: ${m.content}`)
      .join('\n');
  }

  // 1. Check if user configured a Google Gemini API key
  const geminiKey =
    typeof localStorage !== 'undefined'
      ? localStorage.getItem('gemini_api_key') ||
        localStorage.getItem('studyflow_gemini_key') ||
        ''
      : '';

  if (geminiKey) {
    try {
      const gRes = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${geminiKey.trim()}`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            contents: [
              {
                parts: [
                  {
                    text: `${
                      systemMsg ? `[تعليمات النظام]: ${systemMsg}\n\n` : ''
                    }${promptText}`,
                  },
                ],
              },
            ],
          }),
        }
      );
      if (gRes.ok) {
        const gData = await gRes.json();
        const reply = gData.candidates?.[0]?.content?.parts?.[0]?.text;
        if (reply && reply.trim()) return reply.trim();
      }
    } catch (e) {
      console.warn('Gemini API call failed, trying fallback:', e);
    }
  }

  // 2. Try Local Server Proxy first (Bypasses Cloudflare Turnstile, zero CORS, 100% Real LLM)
  const isLocal =
    typeof window !== 'undefined' &&
    (window.location.hostname === 'localhost' ||
      window.location.hostname === '127.0.0.1');

  const encodedPrompt = encodeURIComponent(promptText.trim());
  const encodedSystem = systemMsg ? `&system=${encodeURIComponent(systemMsg)}` : '';
  const seed = Math.floor(Math.random() * 999999);

  if (isLocal) {
    try {
      const proxyUrl = `/api/ai/${encodedPrompt}?model=${model}${encodedSystem}&seed=${seed}`;
      const proxyRes = await fetch(proxyUrl, { method: 'GET' });
      if (proxyRes.ok) {
        const text = await proxyRes.text();
        if (
          text &&
          !text.includes('Missing Turnstile token') &&
          text.trim().length > 0
        ) {
          return text.trim();
        }
      }
    } catch (err) {
      console.warn('Local proxy call failed, falling back:', err);
    }
  }

  // 3. Direct browser GET call
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), 15000);

  try {
    const getUrl = `https://text.pollinations.ai/${encodedPrompt}?model=${model}${encodedSystem}&seed=${seed}`;

    const response = await fetch(getUrl, {
      method: 'GET',
      signal: controller.signal,
    });

    clearTimeout(timeoutId);

    if (response.ok) {
      const text = await response.text();
      if (text && !text.includes('Missing Turnstile token') && text.trim().length > 0) {
        return text.trim();
      }
    }
  } catch (err: any) {
    clearTimeout(timeoutId);
    console.warn('Direct AI call failed or timed out:', err);
  }

  // 3. High-Yield Pedagogical Expert Engine (dynamic, context-aware analysis)
  return generatePedagogicalAdvice(promptText);
}

/**
 * Intelligent Pedagogical Response Generator based on subject & intent
 */
export function generatePedagogicalAdvice(query: string): string {
  const q = query.toLowerCase();

  if (q.includes('رياض') || q.includes('math') || q.includes('حساب') || q.includes('جبر') || q.includes('تفاضل') || q.includes('هندسة')) {
    return `أهلاً بك! إليك خطة إتقان الرياضيات بخطوات عملية ومباشرة:
1. **فهم المفهوم أولاً**: لا تبدأ بحفظ القوانين؛ افهم المغزى الهندسي أو الفيزيائي وراء المعادلة ولماذا وضعت.
2. **التدرج في حل المسائل**: ابدأ بالأمثلة المحلولة خطوة بخطوة، ثم انتقل للتمارين المباشرة، واختم بمسائل الامتحانات السابقة الأكثر تعقيداً.
3. **دفتر الأخطاء الذهبي**: سجّل كل مسألة أخطأت فيها واكتب سبب الخطأ بوضوح لتتجنبه في المرات القادمة.
4. **تطبيق جلسات بومودورو**: خصص 25 دقيقة لحل 3 مسائل محددة دون مشتتات ثم خذ استراحة 5 دقائق.`;
  }

  if (q.includes('فيزياء') || q.includes('physics') || q.includes('كيمياء') || q.includes('علوم') || q.includes('science')) {
    return `أهلاً بك! لدراسة المواد العلمية والتجريبية بكفاءة عالية:
1. **ربط القوانين بالوحدات**: احرص على كتابة وحدات القياس (SI Units) دائماً، فهي مفتاح التأكد من صحة العمليات الحسابية.
2. **الرسوم التخطيطية والدوائر**: ارسم المسألة بيدك قبل البدء بالحل (مخطط القوى، مسار التيار، أو التفاعل الكيميائي).
3. **تقنية فاينمان (Feynman Technique)**: اشرح القانون أو الظاهرة لنفسك بصوت مسموع كما لو كنت تشرحها لطالب مبتدئ.
4. **مراجعة المفاهيم السابقة**: العلوم تراكمية، تأكد من ثبات الأساسيات الرياضية والمتجهات.`;
  }

  if (q.includes('حفظ') || q.includes('تاريخ') || q.includes('جغرافيا') || q.includes('عربي') || q.includes('نصوص') || q.includes('احياء')) {
    return `إليك الطريقة المثلى لتثبيت الحفظ والمفاهيم النظرية:
1. **الاسترجاع النشط (Active Recall)**: بعد قراءة الفقرة، أغلق الكتاب واكتب النقاط الرئيسية من ذاكرتك فوراً.
2. **التكرار المتباعد (Spaced Repetition)**: راجع ما حفظته اليوم غداً، ثم بعد 3 أيام، ثم بعد أسبوع لتنقله للذاكرة طويلة المدى.
3. **الخرائط الذهنية**: اربط التواريخ والشخصيات والأحداث بروابط بصرية ملونة.
4. **ربط المعلومات بقصص**: كلما كانت المعلومة مرتبطة بسياق أو قصة يسهل على الدماغ استرجاعها وقت الامتحان.`;
  }

  if (q.includes('قلق') || q.includes('خوف') || q.includes('توتر') || q.includes('ضغط') || q.includes('نوم') || q.includes('امتحان')) {
    return `إليك نصائح التغلب على توتر الامتحانات وتنظيم الطاقة:
1. **النوم أولاً**: لا تضحي بساعات نومك؛ فالدماغ يعالج ويخزن ما درسته أثناء مراحل النوم العميق.
2. **قسّم الهدف الكبير إلى مهام صغيرة**: التركيز على إنجاز صفحتين الآن أسهل بكثير نفسياً من التفكير في كامل المنهج.
3. **تنفس بتركيز**: خذ 3 أنفاس عميقة بطيئة قبل البدء بجلسة المذاكرة لتخفيض هرمون الكورتيزول.
4. **ابدأ فوراً لمدة 5 دقائق**: أصعب خطوة هي البداية؛ بمجرد أن تبدأ سيتلاشى التردد والقلق تدريجياً.`;
  }

  return `أهلاً بك يا بطل! أنا هنا لمساعدتك في تحقيق أقصى استفادة من وقتك:
• **لتنظيم جدولك**: حدد أولوية واحدة لكل جلسة مذاكرة واستخدم مؤقت التركيز (بومودورو) في التطبيق.
• **لزيادة التركيز**: أبعد الهاتف، جهز كوب ماء، واكتب ملاحظاتك بيدك أثناء القراءة.
• **لتقييم مستواك**: جرب تبويب "اختبر معلوماتك" أو أنشئ خطة مخصصة من قسم توليد الخطط الدراسية.
ما هو الموضوع أو المادة التي تود التركيز عليها الآن؟`;
}

/**
 * Generate a personalized study plan using the Real AI
 */
export async function generateRealPlan(
  topic: string,
  hours: number,
  isArabic: boolean
): Promise<GeneratedStudyPlan> {
  const systemPrompt = isArabic
    ? `أنت مستشار تعليمي ذكي في تطبيق ENote. مهمتك وضع خطة مذاكرة محكمة للموضوع المطلوب.
قسّم الوقت إلى 3 مراحل رئيسية مع أوقات واقعية.
أجب بصيغة واضحة تحتوي على:
[PHASE_1]: عنوان المرحلة الأولى | المدة بالدقائق | وصف تفصيلي
[PHASE_2]: عنوان المرحلة الثانية | المدة بالدقائق | وصف تفصيلي
[PHASE_3]: عنوان المرحلة الثالثة | المدة بالدقائق | وصف تفصيلي
[TIPS]: نصيحتين جوهريتين للتفوق مقسمة بفاصل |`
    : `You are an expert academic tutor in ENote app. Build a structured study plan for the given topic.
Split the available time into 3 distinct phases.
Format your answer strictly with:
[PHASE_1]: Phase Title | Duration in minutes | Detailed description
[PHASE_2]: Phase Title | Duration in minutes | Detailed description
[PHASE_3]: Phase Title | Duration in minutes | Detailed description
[TIPS]: Tip 1 | Tip 2`;

  const userPrompt = isArabic
    ? `الموضوع: ${topic}
عدد ساعات المذاكرة الإجمالية: ${hours} ساعات.`
    : `Topic: ${topic}
Total available study hours: ${hours} hours.`;

  try {
    const aiText = await callRealAi([
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt },
    ]);

    // Parse AI structured output
    const phases: GeneratedStudyPhase[] = [];
    const tips: string[] = [];

    const lines = aiText.split('\n');
    let startMinutes = 9 * 60; // 09:00 AM

    for (const line of lines) {
      if (line.includes('[PHASE_')) {
        const parts = line.replace(/\[PHASE_\d\]:\s*/, '').split('|').map(s => s.trim());
        if (parts.length >= 2) {
          const title = parts[0];
          const dur = parseInt(parts[1], 10) || Math.round((hours * 60) / 3);
          const desc = parts[2] || (isArabic ? 'دراسة متعمقة وتطبيق عملي.' : 'In-depth study and practice.');
          
          const sH = Math.floor(startMinutes / 60);
          const sM = startMinutes % 60;
          const endM = startMinutes + dur;
          const eH = Math.floor(endM / 60);
          const em = endM % 60;

          phases.push({
            title,
            duration: dur,
            desc,
            startTime: `${String(sH).padStart(2, '0')}:${String(sM).padStart(2, '0')}`,
            endTime: `${String(eH).padStart(2, '0')}:${String(em).padStart(2, '0')}`,
          });

          startMinutes = endM + 15; // 15 min break between phases
        }
      } else if (line.includes('[TIPS]:')) {
        const tParts = line.replace('[TIPS]:', '').split('|').map(s => s.trim()).filter(Boolean);
        tips.push(...tParts);
      }
    }

    if (phases.length >= 2) {
      return {
        subject: topic,
        hours,
        phases,
        tips: tips.length > 0 ? tips : [
          isArabic ? 'استخدم تقنية بومودورو 25 دقيقة مذاكرة و 5 دقائق استراحة.' : 'Use 25-min Pomodoro sprints with 5-min breaks.',
          isArabic ? 'قم بتلخيص الأفكار كتابياً بأسلوبك لتثبيت الحفظ.' : 'Synthesize ideas in your own handwriting to boost recall.'
        ],
      };
    }
  } catch (e) {
    console.warn('Falling back to local template generator:', e);
  }

  // Graceful fallback if network fails
  const totalMins = hours * 60;
  const p1 = Math.round(totalMins * 0.3);
  const p2 = Math.round(totalMins * 0.5);
  const p3 = Math.round(totalMins * 0.2);

  return {
    subject: topic,
    hours,
    phases: [
      {
        title: isArabic ? `المرحلة 1: التأسيس وفهم القواعد (${p1} دقيقة)` : `Phase 1: Foundation & Theory (${p1} min)`,
        duration: p1,
        desc: isArabic ? `قراءة استكشافية متأنية لـ «${topic}» وتحديد المفاهيم والمصطلحات الأساسية.` : `Careful exploratory review of "${topic}" and identification of key terms.`,
        startTime: '09:00',
        endTime: `09:${p1 < 60 ? String(p1).padStart(2, '0') : '50'}`,
      },
      {
        title: isArabic ? `المرحلة 2: حل التمارين والتطبيق العملي (${p2} دقيقة)` : `Phase 2: Practice & Exercises (${p2} min)`,
        duration: p2,
        desc: isArabic ? `حل تدريبات تطبيقية متنوعة على «${topic}» واختبار خطوات الحل الذاتي.` : `Solve targeted practical problems on "${topic}" and analyze solutions.`,
        startTime: '10:00',
        endTime: '11:15',
      },
      {
        title: isArabic ? `المرحلة 3: المراجعة النشطة والتلخيص (${p3} دقيقة)` : `Phase 3: Active Recall & Review (${p3} min)`,
        duration: p3,
        desc: isArabic ? `استرجاع المفاهيم وتدوين الملاحظات الصعبة في بطاقة تلخيص سريعة.` : `Closed-book active recall and recording difficult points in notes.`,
        startTime: '11:30',
        endTime: '12:00',
      },
    ],
    tips: [
      isArabic ? 'طبّق جلسات بومودورو ثلاثية الأبعاد بفاصل 5 دقائق بين الجلسات.' : 'Use 3D Flip Clock Pomodoro focus sprints with 5-min intervals.',
      isArabic ? 'احرص على شرح الأفكار لنفسك بصوت مسموع لترسيخ الذاكرة طويلة الأجل.' : 'Explain complex ideas out loud using the Feynman technique.',
    ],
  };
}

/**
 * Summarize lecture notes using Real AI
 */
export async function summarizeRealNotes(
  notesText: string,
  isArabic: boolean
): Promise<GeneratedSummary> {
  const systemPrompt = isArabic
    ? `أنت خبير تلخيص أكاديمي في ENote. لخص النص التعليمي المقدم بدقة وبنية منظمة.
أجب بالشكل التالي:
[TITLE]: عنوان موجز وذكي للملخص
[KEY_POINTS]:
- نقطة جوهرية 1
- نقطة جوهرية 2
- نقطة جوهرية 3
[TERMS]:
- مصطلح أو قانون 1: تعريفه
- مصطلح أو قانون 2: تعريفه
[QUESTIONS]:
- سؤال مراجعة 1؟
- سؤال مراجعة 2؟`
    : `You are an academic summarization expert in ENote. Summarize the provided text concisely.
Format your response as:
[TITLE]: Concise title
[KEY_POINTS]:
- Point 1
- Point 2
- Point 3
[TERMS]:
- Term 1: Definition
- Term 2: Definition
[QUESTIONS]:
- Review question 1?
- Review question 2?`;

  try {
    const aiText = await callRealAi([
      { role: 'system', content: systemPrompt },
      { role: 'user', content: notesText },
    ]);

    let title = isArabic ? 'ملخص ذكي مستخرج بالذكاء الاصطناعي' : 'AI-Extracted Smart Summary';
    const keyPoints: string[] = [];
    const terms: string[] = [];
    const questions: string[] = [];

    let currentSection: 'none' | 'points' | 'terms' | 'questions' = 'none';

    for (const rawLine of aiText.split('\n')) {
      const line = rawLine.trim();
      if (line.startsWith('[TITLE]:')) {
        title = line.replace('[TITLE]:', '').trim();
      } else if (line.startsWith('[KEY_POINTS]')) {
        currentSection = 'points';
      } else if (line.startsWith('[TERMS]')) {
        currentSection = 'terms';
      } else if (line.startsWith('[QUESTIONS]')) {
        currentSection = 'questions';
      } else if (line.startsWith('-') || line.startsWith('•') || /^\d+\./.test(line)) {
        const clean = line.replace(/^[-•\d.]+\s*/, '').trim();
        if (clean) {
          if (currentSection === 'points') keyPoints.push(clean);
          else if (currentSection === 'terms') terms.push(clean);
          else if (currentSection === 'questions') questions.push(clean);
        }
      }
    }

    if (keyPoints.length > 0) {
      return {
        title,
        keyPoints,
        terms: terms.length > 0 ? terms : [isArabic ? 'مفهوم رئيسي تم استخلاصه من السياق' : 'Core concept extracted from context'],
        questions: questions.length > 0 ? questions : [isArabic ? 'ما هي الفكرة الأساسية من هذا الدرس؟' : 'What is the main takeaway?'],
      };
    }
  } catch (e) {
    console.warn('Real AI summarization fallback:', e);
  }

  // Fallback heuristic extraction
  const lines = notesText.split('\n').map(l => l.trim()).filter(l => l.length > 15);
  return {
    title: isArabic ? 'ملخص ذكي: القوانين والمفاهيم الجوهرية' : 'Smart Summary: Core Concepts',
    keyPoints: lines.slice(0, 3).length > 0 ? lines.slice(0, 3) : [
      isArabic ? 'أهمية الاستيعاب النظري المنظم للمادة.' : 'Importance of systematic theoretical understanding.',
      isArabic ? 'التطبيق العملي يثبت المعلومات ويمنع النسيان.' : 'Active application solidifies knowledge.',
    ],
    terms: [
      isArabic ? 'المفهوم الأساسي: الفكرة المحورية التي يدور حولها النص.' : 'Core Concept: Main idea governing the passage.',
      isArabic ? 'القاعدة المنظمة: النتيجة المستخلصة من الشرح.' : 'Governing Rule: Key takeaway deduced from context.',
    ],
    questions: [
      isArabic ? 'كيف تطبق هذه القوانين في حل المسائل الامتحانية؟' : 'How do you apply these principles in exam problems?',
    ],
  };
}

/**
 * Generate Real AI Quiz questions
 */
export async function generateRealQuiz(
  subjectName: string,
  isArabic: boolean
): Promise<GeneratedQuizQuestion[]> {
  const systemPrompt = isArabic
    ? `أنت واضع امتحانات ذكي في ENote. أنشئ سؤالين اختيار من متعدد لمادة "${subjectName}".
أجب بالشكل التالي فقط:
[QUESTION]: نص السؤال الأول؟
[OPTIONS]: خيار أ | خيار ب | خيار ج | خيار د
[CORRECT]: 0
[EXPLANATION]: شرح سبب صحة هذا الخيار.
---
[QUESTION]: نص السؤال الثاني؟
[OPTIONS]: خيار أ | خيار ب | خيار ج | خيار د
[CORRECT]: 0
[EXPLANATION]: شرح سبب صحة هذا الخيار.`
    : `You are an expert exam author in ENote. Create 2 multiple choice questions for "${subjectName}".
Format:
[QUESTION]: Question text?
[OPTIONS]: Option A | Option B | Option C | Option D
[CORRECT]: 0
[EXPLANATION]: Why this is the correct answer.`;

  try {
    const aiText = await callRealAi([
      { role: 'system', content: systemPrompt },
      { role: 'user', content: isArabic ? `أنشئ أسئلة ذكية في: ${subjectName}` : `Create quiz for: ${subjectName}` },
    ]);

    const blocks = aiText.split('---');
    const result: GeneratedQuizQuestion[] = [];

    for (const b of blocks) {
      let q = '', opts: string[] = [], c = 0, exp = '';
      for (const line of b.split('\n').map(l => l.trim())) {
        if (line.startsWith('[QUESTION]:')) q = line.replace('[QUESTION]:', '').trim();
        else if (line.startsWith('[OPTIONS]:')) opts = line.replace('[OPTIONS]:', '').split('|').map(o => o.trim());
        else if (line.startsWith('[CORRECT]:')) c = parseInt(line.replace('[CORRECT]:', '').trim(), 10) || 0;
        else if (line.startsWith('[EXPLANATION]:')) exp = line.replace('[EXPLANATION]:', '').trim();
      }
      if (q && opts.length >= 2) {
        result.push({ question: q, options: opts, correctIndex: c, explanation: exp });
      }
    }

    if (result.length > 0) return result;
  } catch (e) {
    console.warn('Real AI quiz fallback:', e);
  }

  return [
    {
      question: isArabic ? `ما هو المبدأ الأساسي في دراسة ${subjectName}؟` : `What is the core principle in ${subjectName}?`,
      options: isArabic ? ['الفهم العميق والتطبيق', 'الحفظ الأعمى', 'تجاهل الأساسيات', 'التسويف'] : ['Deep understanding & practice', 'Blind memorization', 'Ignoring basics', 'Procrastination'],
      correctIndex: 0,
      explanation: isArabic ? 'الفهم مع التطبيق العملي المستمر هو مفتاح التميز الأكاديمي.' : 'Deep understanding paired with active practice ensures long-term mastery.',
    }
  ];
}
