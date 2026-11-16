import React from 'react';
import { Area, AreaChart, CartesianGrid, Cell, Pie, PieChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';
import { t, getLocale } from './i18n';

const COLORS = ['#6443b1', '#16776a', '#b55514', '#426bbb', '#ad397b', '#756033', '#7842a1', '#306d71', '#ab4439', '#686274'];
const number = (value: number) => new Intl.NumberFormat(getLocale()).format(value);
export default function StatisticsCharts({ week, categories }) {
  return <div className="sf-chart-grid">
    <section className="sf-card sf-chart-panel" aria-labelledby="weekly-chart-title">
      <h2 id="weekly-chart-title">{t('المهام المكتملة خلال أسبوع')}</h2><p>{t('عدد المهام التي أنجزتها حسب اليوم المحدد لها.')}</p>
      <div className="sf-chart" dir="ltr" aria-hidden="true"><ResponsiveContainer width="100%" height="100%"><AreaChart data={week} margin={{left:-20,right:12,top:16,bottom:0}}><CartesianGrid vertical={false} stroke="var(--line)"/><XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fill:'var(--muted)',fontSize:12}}/><YAxis allowDecimals={false} axisLine={false} tickLine={false} tick={{fill:'var(--muted)',fontSize:12}}/><Tooltip contentStyle={{background:'var(--surface)',border:'1px solid var(--line)',borderRadius:12,color:'var(--ink)'}}/><Area name={t('مهام مكتملة')} dataKey="value" type="monotone" stroke="#7552bd" strokeWidth={3} fill="#7552bd" fillOpacity={0.12} isAnimationActive={false}/></AreaChart></ResponsiveContainer></div>
      <details className="sf-chart-data"><summary>{t('عرض بيانات الرسم')}</summary><table><caption>{t('المهام المكتملة خلال أسبوع')}</caption><thead><tr><th scope="col">{t('اليوم')}</th><th scope="col">{t('مهام مكتملة')}</th></tr></thead><tbody>{week.map(day=><tr key={day.date}><th scope="row">{day.name}</th><td>{number(day.value)}</td></tr>)}</tbody></table></details>
    </section>
    <section className="sf-card sf-chart-panel" aria-labelledby="planned-chart-title"><h2 id="planned-chart-title">{t('توزيع الوقت المخطط اليوم')}</h2><p>{t('الدقائق المجدولة في المخطط، وليست قياسًا لوقت التركيز الفعلي.')}</p>{categories.length ? <><div className="sf-chart" dir="ltr" aria-hidden="true"><ResponsiveContainer width="100%" height="100%"><PieChart><Pie data={categories} dataKey="value" nameKey="name" innerRadius={62} outerRadius={100} paddingAngle={3} stroke="var(--surface)" strokeWidth={3} isAnimationActive={false}>{categories.map((category,index)=><Cell key={category.name} fill={COLORS[index % COLORS.length]}/>)}</Pie><Tooltip formatter={value=>`${number(Number(value))} ${t('دقيقة')}`} contentStyle={{background:'var(--surface)',border:'1px solid var(--line)',borderRadius:12,color:'var(--ink)'}}/></PieChart></ResponsiveContainer></div><ul className="sf-chart-legend">{categories.map((category,index)=><li key={category.name}><span style={{background:COLORS[index % COLORS.length]}} aria-hidden="true"/>{category.name}<strong>{number(category.value)} {t('دقيقة')}</strong></li>)}</ul></>:<div className="sf-empty"><p>{t('أضف أوقاتًا لمهام اليوم ليظهر توزيع وقتك هنا.')}</p></div>}</section>
  </div>;
}
