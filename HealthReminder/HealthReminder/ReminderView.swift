//
//  ReminderView.swift
//  HealthReminder
//
//  Created by Dũng Phùng on 3/2/26.
//

import SwiftUI
import Combine

struct ReminderView: View {
    @ObservedObject var appState: AppState
    @ObservedObject var timerManager: TimerManager
    @State private var countdown: Int = 0
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.8
    @State private var breathingScale: CGFloat = 1.0
    @State private var blurRadius: CGFloat = 0
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var reminderType: ReminderType {
        appState.currentReminderType
    }
    
    private var reminderSettings: ReminderSettings {
        appState.settings.settings(for: reminderType)
    }
    
    var progress: Double {
        guard reminderSettings.durationSeconds > 0 else { return 0 }
        return Double(countdown) / Double(reminderSettings.durationSeconds)
    }
    
    var body: some View {
        ZStack {
            // Gradient background with blur
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.4).opacity(0.95),
                    Color(red: 0.15, green: 0.25, blue: 0.45).opacity(0.95)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .blur(radius: blurRadius)
            
            // Floating particles effect (subtle)
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.03))
                    .frame(width: CGFloat.random(in: 40...80))
                    .offset(
                        x: CGFloat.random(in: -400...400),
                        y: CGFloat.random(in: -300...300)
                    )
                    .blur(radius: 20)
            }
            
            // Main content card with glassmorphism
            VStack(spacing: 32) {
                Spacer()
                
                // Breathing icon with gradient
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    reminderType.color.opacity(0.3),
                                    reminderType.color.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .blur(radius: 20)
                        .scaleEffect(breathingScale)
                    
                    // Icon
                    Image(systemName: reminderType.icon)
                        .font(.system(size: 80, weight: .light))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [reminderType.color, reminderType.color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(breathingScale)
                        .shadow(color: reminderType.color.opacity(0.5), radius: 20, x: 0, y: 0)
                }
                .padding(.bottom, 8)
                
                // Main title with better typography
                VStack(spacing: 12) {
                    Text(reminderType.title)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    Text(reminderType.subtitle)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text(reminderType.helper)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                }
                .multilineTextAlignment(.center)
                
                // Enhanced countdown circle
                ZStack {
                    // Outer glow ring
                    Circle()
                        .stroke(reminderType.color.opacity(0.2), lineWidth: 3)
                        .frame(width: 180, height: 180)
                        .blur(radius: 8)
                    
                    // Background ring
                    Circle()
                        .stroke(
                            Color.white.opacity(0.15),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 180, height: 180)
                    
                    // Progress ring with gradient
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [reminderType.color, reminderType.color.opacity(0.7), reminderType.color]),
                                center: .center,
                                startAngle: .degrees(0),
                                endAngle: .degrees(360)
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 180, height: 180)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: countdown)
                        .shadow(color: reminderType.color.opacity(0.6), radius: 10, x: 0, y: 0)
                    
                    // Inner content
                    VStack(spacing: 8) {
                        Text("\(countdown)")
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .white.opacity(0.9)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: reminderType.color.opacity(0.5), radius: 10, x: 0, y: 0)
                            .contentTransition(.numericText())
                        
                        Text("seconds")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .textCase(.uppercase)
                            .tracking(2)
                    }
                }
                .padding(.vertical, 24)
                
                Spacer()
                
                // Modern dismiss button
                Button(action: dismissReminder) {
                    HStack(spacing: 10) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                        Text("Skip Break")
                            .font(.system(size: 17, weight: .semibold))
                        Text("(ESC)")
                            .font(.system(size: 14, weight: .regular))
                            .opacity(0.7)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    )
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.05))
                            .blur(radius: 20)
                            .padding(-10)
                    )
                }
                .buttonStyle(.plain)
                .scaleEffect(opacity > 0.5 ? 1.0 : 0.9)
                
                Spacer()
                    .frame(height: 40)
            }
            .padding(60)
            .scaleEffect(scale)
        }
        .opacity(opacity)
        .onAppear {
            countdown = reminderSettings.durationSeconds
            
            // Entrance animation
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                opacity = 1.0
                scale = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.5)) {
                blurRadius = 30
            }
            
            // Start breathing animation
            startBreathingAnimation()
        }
        .onReceive(timer) { _ in
            if countdown > 0 {
                countdown -= 1
            } else {
                dismissReminder()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DismissReminder"))) { _ in
            dismissReminder()
        }
        .background(KeyEventHandlingView(onEscape: dismissReminder))
    }
    
    private func startBreathingAnimation() {
        withAnimation(
            Animation.easeInOut(duration: 3.0)
                .repeatForever(autoreverses: true)
        ) {
            breathingScale = 1.15
        }
    }
    
    private func dismissReminder() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            opacity = 0.0
            scale = 0.9
        }
        
        withAnimation(.easeIn(duration: 0.3)) {
            blurRadius = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            timerManager.dismissReminder()
        }
    }
}

// Helper view to handle keyboard events
struct KeyEventHandlingView: NSViewRepresentable {
    let onEscape: () -> Void
    
    func makeNSView(context: Context) -> NSView {
        let view = KeyEventNSView(onEscape: onEscape)
        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}

class KeyEventNSView: NSView {
    let onEscape: () -> Void
    
    init(onEscape: @escaping () -> Void) {
        self.onEscape = onEscape
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var acceptsFirstResponder: Bool { true }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // ESC key
            onEscape()
        } else {
            super.keyDown(with: event)
        }
    }
}
