import SwiftUI
import AppKit

struct AppIconView: View {
    let appName: String
    @State private var appIcon: NSImage?
    
    var body: some View {
        Group {
            if let icon = appIcon {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(systemName: "app.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            }
        }
        .onAppear {
            loadAppIcon()
        }
    }
    
    private func loadAppIcon() {
        let workspace = NSWorkspace.shared
        let fileManager = FileManager.default
        
        let applicationDirs = [
            "/Applications",
            "/System/Applications",
            fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Applications").path
        ]
        
        for dir in applicationDirs {
            let appPath = "\(dir)/\(appName).app"
            if fileManager.fileExists(atPath: appPath) {
                let icon = workspace.icon(forFile: appPath)
                appIcon = icon
                return
            }
        }
        
        // Fallback: try to get icon from running app
        let runningApps = workspace.runningApplications
        if let app = runningApps.first(where: { $0.localizedName == appName }) {
            if let bundleURL = app.bundleURL {
                appIcon = workspace.icon(forFile: bundleURL.path)
            }
        }
    }
}