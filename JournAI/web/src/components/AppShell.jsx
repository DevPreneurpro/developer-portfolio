import './AppShell.css'

export default function AppShell({ children }) {
  return (
    <div className="app-shell-backdrop">
      <div className="app-shell">{children}</div>
    </div>
  )
}
