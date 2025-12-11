import SwiftUI

struct ActiveSessionView: View {
    @ObservedObject var focusManager: FocusManager
    
    var body: some View {
        VStack(spacing: 0) {
            if let session = focusManager.currentSession {
                goalSection(for: session)
                timerCircle(for: session)
                controlButtons(for: session)
                
                Spacer()
            }
        }
    }
    
    // MARK: - Goal Section
    
    private func goalSection(for session: FocusSession) -> some View {
        VStack(spacing: 12) {
            Text("Focusing on:")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            
            Text(session.goal)
                .font(.system(size: 18, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .padding(.horizontal, 30)
        }
        .padding(.top, 30)
        .padding(.bottom, 20)
    }
    
    // MARK: - Timer Circle
    
    private func timerCircle(for session: FocusSession) -> some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: 18)
                .frame(width: 200, height: 200)
            
            Circle()
                .trim(from: 0, to: session.progress)
                .stroke(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.5), value: session.progress)
            
            VStack(spacing: 4) {
                Text(session.formattedRemainingTime)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .monospacedDigit()
                
                if session.isPaused {
                    Text("Paused")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.vertical, 30)
    }
    
    // MARK: - Control Buttons
    
    private func controlButtons(for session: FocusSession) -> some View {
        HStack(spacing: 10) {
            if session.isPaused {
                ControlButton(
                    icon: "play.fill",
                    title: "Resume",
                    color: .green,
                    action: { focusManager.resumeSession() }
                )
            } else {
                ControlButton(
                    icon: "pause.fill",
                    title: "Pause",
                    color: .orange,
                    action: { focusManager.pauseSession() }
                )
            }
            
            ControlButton(
                icon: "stop.fill",
                title: "Stop",
                color: .red,
                action: { focusManager.stopSession() }
            )
            
            ControlButton(
                icon: "plus.circle.fill",
                title: "+5 min",
                color: .blue,
                action: { focusManager.extendSession(by: 300) }
            )
        }
        .padding(.horizontal, 30)
    }
}