export const MOODS = [
  { id: 'veryLow', label: 'Struggling', mouthCurve: -6 },
  { id: 'low', label: 'Low', mouthCurve: -3 },
  { id: 'neutral', label: 'Reflective', mouthCurve: 0 },
  { id: 'good', label: 'Good', mouthCurve: 4 },
  { id: 'great', label: 'Great', mouthCurve: 8 },
]

export function moodById(id) {
  return MOODS.find((mood) => mood.id === id) ?? MOODS[2]
}
