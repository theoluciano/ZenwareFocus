import SwiftUI

struct FocusView: View {
    @EnvironmentObject var focusManager: FocusManager
    @State private var selectedTab: FocusTab = .start
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HeaderView()
            
            Divider()
            
            // Main Content
            if let session = focusManager.currentSession, session.isActive {
                ActiveSessionView(focusManager: focusManager)
            } else {
                VStack(spacing: 0) {
                    // Tab Bar
                    TabBar(selectedTab: $selectedTab)
                    
                    Divider()
                    
                    // Tab Content
                    Group {
                        switch selectedTab {
                        case .start:
                            StartSessionView(focusManager: focusManager)
                        case .presets:
                            PresetsView(focusManager: focusManager)
                        case .history:
                            HistoryView(focusManager: focusManager)
                        }
                    }
                }
            }
        }
        .frame(width: 400, height: 560)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
// MARK: - Header View

struct HeaderView: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "scope")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.blue)
            
            Text("Zenware Focus")
                .font(.system(size: 16, weight: .semibold))
            
            Spacer()
            
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("Quit Zenware Focus")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - Tab Bar

struct TabBar: View {
    @Binding var selectedTab: FocusTab
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(FocusTab.allCases) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 18))
                        Text(tab.title)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundColor(selectedTab == tab ? .blue : .secondary)
                    .background(selectedTab == tab ? Color.blue.opacity(0.1) : Color.clear)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}

// MARK: - Preview

struct FocusView_Previews: PreviewProvider {
    static var previews: some View {
        FocusView()
    }
}