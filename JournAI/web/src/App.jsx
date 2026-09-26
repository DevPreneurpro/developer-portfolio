import { Navigate, Route, Routes } from 'react-router-dom'
import AppShell from './components/AppShell.jsx'
import { useLocalStorageState } from './lib/storage.js'
import { ONBOARDING_KEY } from './lib/session.js'
import OnboardingScreen from './screens/OnboardingScreen.jsx'
import HomeScreen from './screens/HomeScreen.jsx'
import NewEntryScreen from './screens/NewEntryScreen.jsx'
import EntryDetailScreen from './screens/EntryDetailScreen.jsx'
import SettingsScreen from './screens/SettingsScreen.jsx'
import './App.css'

export default function App() {
  const [hasCompletedOnboarding] = useLocalStorageState(ONBOARDING_KEY, false)

  return (
    <AppShell>
      <Routes>
        <Route
          path="/"
          element={<Navigate to={hasCompletedOnboarding ? '/home' : '/onboarding'} replace />}
        />
        <Route path="/onboarding" element={<OnboardingScreen />} />
        <Route path="/home" element={<HomeScreen />} />
        <Route path="/new-entry" element={<NewEntryScreen />} />
        <Route path="/entry/:entryId" element={<EntryDetailScreen />} />
        <Route path="/settings" element={<SettingsScreen />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </AppShell>
  )
}
