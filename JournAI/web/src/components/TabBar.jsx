import { NavLink, useNavigate } from 'react-router-dom'
import './TabBar.css'

export default function TabBar() {
  const navigate = useNavigate()

  return (
    <nav className="tab-bar">
      <NavLink to="/home" className={({ isActive }) => `tab-bar__item ${isActive ? 'is-active' : ''}`}>
        <HomeIcon />
        <span>Home</span>
      </NavLink>

      <button type="button" className="tab-bar__fab" onClick={() => navigate('/new-entry')} aria-label="New entry">
        <PlusIcon />
      </button>

      <NavLink to="/settings" className={({ isActive }) => `tab-bar__item ${isActive ? 'is-active' : ''}`}>
        <SettingsIcon />
        <span>Settings</span>
      </NavLink>
    </nav>
  )
}

function HomeIcon() {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <path d="M4 11l8-7 8 7" />
      <path d="M6 10v9a1 1 0 0 0 1 1h10a1 1 0 0 0 1-1v-9" />
    </svg>
  )
}

function SettingsIcon() {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <path d="M15 4H6a1 1 0 0 0-1 1v15l4-2.5L13 20l4-2.5V6.5" />
      <path d="M13 4v9l2-1.3 2 1.3V4" />
    </svg>
  )
}

function PlusIcon() {
  return (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#FBF6F0" strokeWidth="2.2" strokeLinecap="round">
      <path d="M12 5v14M5 12h14" />
    </svg>
  )
}
