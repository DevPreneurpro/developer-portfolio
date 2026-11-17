import Foundation

enum BackendConfig {
    /// The iOS Simulator shares the Mac's localhost, so this reaches the
    /// Express server in JournAI/web/server when it's running (`npm run
    /// server` or `npm run dev` from JournAI/web). A physical device can't
    /// reach "localhost" on your Mac — point this at your Mac's LAN IP
    /// instead, e.g. "http://192.168.1.23:8787", while testing on a device.
    static let baseURL = URL(string: "http://localhost:8787")!
}
