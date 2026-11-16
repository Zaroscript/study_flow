import React, { useEffect, useRef, useState, useCallback } from 'react';
import { t } from './i18n';
import './flip-clock.css';

/**
 * High-precision synthesized mechanical flip sound using Web Audio API.
 * Whisper-quiet, authentic tactile click with zero audio lag.
 */
class FlipSoundManager {
  private static ctx: AudioContext | null = null;
  private static isMuted: boolean = false;

  public static setMuted(muted: boolean) {
    FlipSoundManager.isMuted = muted;
  }

  public static getMuted(): boolean {
    return FlipSoundManager.isMuted;
  }

  public static playTick() {
    if (FlipSoundManager.isMuted) return;
    try {
      if (!FlipSoundManager.ctx) {
        const AudioCtx = window.AudioContext || (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext;
        if (AudioCtx) {
          FlipSoundManager.ctx = new AudioCtx();
        }
      }
      if (FlipSoundManager.ctx && FlipSoundManager.ctx.state === 'suspended') {
        FlipSoundManager.ctx.resume();
      }
      if (!FlipSoundManager.ctx || FlipSoundManager.ctx.state !== 'running') return;

      const now = FlipSoundManager.ctx.currentTime;
      const osc = FlipSoundManager.ctx.createOscillator();
      const gain = FlipSoundManager.ctx.createGain();
      const filter = FlipSoundManager.ctx.createBiquadFilter();

      osc.type = 'triangle';
      osc.frequency.setValueAtTime(160, now);
      osc.frequency.exponentialRampToValueAtTime(36, now + 0.032);

      filter.type = 'lowpass';
      filter.frequency.setValueAtTime(950, now);

      gain.gain.setValueAtTime(0.045, now);
      gain.gain.exponentialRampToValueAtTime(0.0001, now + 0.032);

      osc.connect(filter);
      filter.connect(gain);
      gain.connect(FlipSoundManager.ctx.destination);

      osc.start(now);
      osc.stop(now + 0.032);
    } catch {
      // Audio playback blocked or unpermitted; fail gracefully without crashing
    }
  }
}

interface FlipDigitProps {
  digit: number | string;
  enableSound?: boolean;
}

/**
 * Individual 3D Split-Flap Card Component.
 * Flips top flap down (0 to -90deg) and reveals landing bottom flap (90deg to 0deg).
 */
const FlipDigitCard: React.FC<FlipDigitProps> = ({ digit, enableSound = true }) => {
  const [currentVal, setCurrentVal] = useState(digit);
  const [prevVal, setPrevVal] = useState(digit);
  const [isFlipping, setIsFlipping] = useState(false);
  const timerRef = useRef<number | null>(null);

  useEffect(() => {
    if (digit !== currentVal) {
      setPrevVal(currentVal);
      setCurrentVal(digit);
      setIsFlipping(true);

      if (enableSound) {
        FlipSoundManager.playTick();
      }

      if (timerRef.current) {
        clearTimeout(timerRef.current);
      }

      timerRef.current = window.setTimeout(() => {
        setIsFlipping(false);
        setPrevVal(digit);
      }, 450);
    }
  }, [digit, currentVal, enableSound]);

  useEffect(() => {
    return () => {
      if (timerRef.current) {
        clearTimeout(timerRef.current);
      }
    };
  }, []);

  return (
    <div className="flip-card" aria-hidden="true">
      {/* 1. Static Top Card (Shows incoming/current value underneath) */}
      <div className="flip-card-half flip-card-top">
        <div className="flip-card-half-inner">{currentVal}</div>
      </div>

      {/* 2. Static Bottom Card (Shows old value until covered) */}
      <div className="flip-card-half flip-card-bottom">
        <div className="flip-card-half-inner">{isFlipping ? prevVal : currentVal}</div>
      </div>

      {/* 3. Flipping Top Flap (Flips down from 0 to -90deg showing old value) */}
      {isFlipping && (
        <div className="flip-card-half flip-card-top flip-card-flap-top flipping">
          <div className="flip-card-half-inner">{prevVal}</div>
        </div>
      )}

      {/* 4. Landing Bottom Flap (Lands from 90deg to 0deg showing new value) */}
      {isFlipping && (
        <div className="flip-card-half flip-card-bottom flip-card-flap-bottom flipping">
          <div className="flip-card-half-inner">{currentVal}</div>
        </div>
      )}

      {/* Center Hinge Line */}
      <div className="flip-card-hinge" />
    </div>
  );
};

export interface FlipClockProps {
  timeLeft: number;
  totalTime?: number;
  mode?: 'study' | 'break' | 'longBreak' | string;
  modeLabel?: string;
  isActive?: boolean;
  accentColor?: string;
  showStatusPill?: boolean;
  showProgress?: boolean;
}

export const FlipClock: React.FC<FlipClockProps> = ({
  timeLeft,
  totalTime = 1500,
  mode = 'study',
  modeLabel,
  isActive = false,
  accentColor,
  showStatusPill = true,
  showProgress = true,
}) => {
  const [soundMuted, setSoundMuted] = useState(false);

  const toggleSound = useCallback(() => {
    setSoundMuted((prev) => {
      const next = !prev;
      FlipSoundManager.setMuted(next);
      return next;
    });
  }, []);

  // Time calculations
  const minutes = Math.floor(Math.max(0, timeLeft) / 60);
  const seconds = Math.max(0, timeLeft) % 60;

  const m1 = Math.floor(minutes / 10);
  const m2 = minutes % 10;
  const s1 = Math.floor(seconds / 10);
  const s2 = seconds % 10;

  // Theme color mapping based on mode
  const effectiveAccent = accentColor || (mode === 'study' ? '#6366f1' : mode === 'break' ? '#10b981' : '#38bdf8');
  const progressPercent = totalTime > 0 ? Math.min(100, Math.max(0, ((totalTime - timeLeft) / totalTime) * 100)) : 0;
  const currentModeLabel = modeLabel || t('وقت التركيز');

  return (
    <div
      className="flip-clock-wrapper"
      role="timer"
      aria-label={t('مؤقت: {minutes} دقيقة و {seconds} ثانية', { minutes: String(minutes), seconds: String(seconds) })}
      title={t('مؤقت: {minutes} دقيقة و {seconds} ثانية', { minutes: String(minutes), seconds: String(seconds) })}
    >
      {/* Session Status Pill */}
      {showStatusPill && (
        <div
          className="flip-status-pill shadow-sm"
          style={{
            backgroundColor: `${effectiveAccent}18`,
            color: effectiveAccent,
            border: `1px solid ${effectiveAccent}33`,
          }}
        >
          <span
            className={`flip-beacon ${isActive ? 'active' : ''}`}
            style={{ backgroundColor: effectiveAccent, color: effectiveAccent }}
          />
          <span>{currentModeLabel}</span>
          <span className="opacity-60 text-xs">
            {isActive ? t('• جارية الآن') : t('• متوقف مؤقتاً')}
          </span>
          <button
            type="button"
            onClick={toggleSound}
            className="ms-1 p-1 hover:opacity-100 opacity-70 transition-opacity"
            title={soundMuted ? t('تشغيل صوت التكتكة الميكانيكية') : t('كتم صوت التكتكة')}
            aria-label={soundMuted ? t('تشغيل الصوت') : t('كتم الصوت')}
          >
            {soundMuted ? (
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <line x1="1" y1="1" x2="23" y2="23" />
                <path d="M9 9v3a3 3 0 0 0 5.12 2.12M15 9.34V4a3 3 0 0 0-5.94-.6" />
                <path d="M17 16.95A7 7 0 0 1 5 12v-2m14 0v2a7 7 0 0 1-.11 1.23" />
                <line x1="12" y1="19" x2="12" y2="23" />
                <line x1="8" y1="23" x2="16" y2="23" />
              </svg>
            ) : (
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5" />
                <path d="M15.54 8.46a5 5 0 0 1 0 7.07" />
                <path d="M19.07 4.93a10 10 0 0 1 0 14.14" />
              </svg>
            )}
          </button>
        </div>
      )}

      {/* Clock Display Grid: [Minutes Tens & Ones] : [Seconds Tens & Ones] */}
      <div className="flip-clock-row" dir="ltr">
        {/* Minutes Pair */}
        <div
          className="flip-group"
          title={t('الدقائق: {minutes}', { minutes: String(minutes) })}
          aria-label={t('الدقائق: {minutes}', { minutes: String(minutes) })}
        >
          <FlipDigitCard digit={m1} enableSound={!soundMuted && isActive} />
          <FlipDigitCard digit={m2} enableSound={!soundMuted && isActive} />
        </div>

        {/* Colon Separator */}
        <div className="flip-colon" style={{ color: effectiveAccent }}>
          <span className={`flip-colon-dot ${isActive ? 'blinking' : ''}`} />
          <span className={`flip-colon-dot ${isActive ? 'blinking' : ''}`} />
        </div>

        {/* Seconds Pair */}
        <div
          className="flip-group"
          title={t('الثواني: {seconds}', { seconds: String(seconds) })}
          aria-label={t('الثواني: {seconds}', { seconds: String(seconds) })}
        >
          <FlipDigitCard digit={s1} enableSound={!soundMuted && isActive} />
          <FlipDigitCard digit={s2} enableSound={!soundMuted && isActive} />
        </div>
      </div>

      {/* Progress Bar Track */}
      {showProgress && (
        <div
          className="flip-progress-bar"
          role="progressbar"
          aria-valuenow={Math.round(progressPercent)}
          aria-valuemin={0}
          aria-valuemax={100}
          title={t('التقدم: {percent}%', { percent: String(Math.round(progressPercent)) })}
          aria-label={t('التقدم: {percent}%', { percent: String(Math.round(progressPercent)) })}
        >
          <div
            className="flip-progress-fill"
            style={{
              width: `${progressPercent}%`,
              backgroundColor: effectiveAccent,
              boxShadow: `0 0 8px ${effectiveAccent}66`,
            }}
          />
        </div>
      )}
    </div>
  );
};

export default FlipClock;
