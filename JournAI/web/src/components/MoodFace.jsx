import { moodById } from '../lib/moods.js'

export default function MoodFace({ moodId, selected = false, size = 44, onClick }) {
  const mood = moodById(moodId)
  const stroke = selected ? 'var(--accent-dark)' : 'var(--ink-faint)'
  const fill = selected ? 'var(--accent-tint)' : 'transparent'

  const mouthWidth = size * 0.36
  const mouthHeight = 12
  const curve = mood.mouthCurve * (size / 44)

  const face = (
    <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`} role="img" aria-label={mood.label}>
      <circle cx={size / 2} cy={size / 2} r={size / 2 - 1} fill={fill} stroke={stroke} strokeWidth="1.5" />
      <circle cx={size * 0.36} cy={size * 0.42} r={size * 0.03} fill={stroke} />
      <circle cx={size * 0.64} cy={size * 0.42} r={size * 0.03} fill={stroke} />
      <path
        d={`M ${(size - mouthWidth) / 2} ${size * 0.64 - mouthHeight / 2 + mouthHeight / 2}
            Q ${size / 2} ${size * 0.64 - mouthHeight / 2 + mouthHeight / 2 + curve}
              ${(size + mouthWidth) / 2} ${size * 0.64 - mouthHeight / 2 + mouthHeight / 2}`}
        fill="none"
        stroke={stroke}
        strokeWidth="1.5"
        strokeLinecap="round"
      />
    </svg>
  )

  if (!onClick) {
    return face
  }

  return (
    <button
      type="button"
      onClick={onClick}
      aria-pressed={selected}
      aria-label={mood.label}
      style={{
        background: 'none',
        border: 'none',
        padding: 0,
        display: 'inline-flex',
      }}
    >
      {face}
    </button>
  )
}
