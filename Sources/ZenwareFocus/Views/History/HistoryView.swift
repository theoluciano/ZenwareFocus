import SwiftUI

struct HistoryView: View {
    @ObservedObject var focusManager: FocusManager
    @State private var showingClearAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if focusManager.sessionHistory.isEmpty {
                    emptyStateView
                } else {
                    historyContentView
                }
            }
        }
        .alert("Clear All History?", isPresented: $showingClearAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                focusManager.clearHistory()
            }
        } message: {
            Text("This will permanently delete all your session history.")
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No sessions yet")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("Start your first focus session\nto see your history here")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 80)
    }
    
    // MARK: - History Content
    
    private var historyContentView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Sessions")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: { showingClearAlert = true }) {
                    Text("Clear All")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            ForEach(focusManager.sessionHistory.reversed().prefix(10)) { session in
                HistoryCard(
                    session: session,
                    onDelete: {
                        focusManager.deleteSession(session)
                    },
                    onSavePreset: {
                        focusManager.savePreset(from: session)
                    },
                    isSaved: focusManager.isSessionSaved(session)
                )
                .padding(.horizontal, 20)
            }
            
            Spacer(minLength: 20)
        }
    }
}