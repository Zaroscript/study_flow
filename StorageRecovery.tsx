import React from 'react';

/** No automatic reset: let the user export their original bytes first. */
export function StorageRecovery({ raw, onRecover }: { raw: string; onRecover: () => void }) {
  const english = document.documentElement.lang === 'en';
  const exportBackup = () => {
    const url = URL.createObjectURL(new Blob([raw], { type: 'application/json' }));
    const link = document.createElement('a'); link.href = url; link.download = 'ENote-recovery-original.json'; link.click();
    setTimeout(() => URL.revokeObjectURL(url), 1000);
  };
  return <main className="sf-storage-recovery" style={{maxWidth:650,margin:'12vh auto',padding:28,fontFamily:'Cairo, sans-serif'}}>
    <h1>{english ? 'Your saved data needs attention' : 'بياناتك المحفوظة محتاجة مراجعة'}</h1>
    <p>{english ? 'We kept the original data unchanged. Export a backup before starting a fresh workspace.' : 'احتفظنا بالبيانات الأصلية من غير تغيير. نزّل نسخة احتياطية قبل فتح مساحة جديدة.'}</p>
    <button className="sf-button sf-button-primary" onClick={exportBackup}>{english ? 'Export original data' : 'تنزيل البيانات الأصلية'}</button>
    <button className="sf-button sf-button-outline" style={{margin:12}} onClick={onRecover}>{english ? 'Back up and start fresh' : 'حفظ نسخة والبدء من جديد'}</button>
  </main>;
}
