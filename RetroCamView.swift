import SwiftUI
import CoreHaptics

struct RetroCamView: View {
    @State private var remainingPhotos = 12
    @State private var showFilm = false
    @State private var development: Double = 0.0
    @State private var isShutterTargeted = false
    
    var body: some View {
        ZStack {
            Color(red: 0.75, green: 0.15, blue: 0.15)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: { playHaptic(.light) }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                    Text("GRAIN")
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(.white)
                        .tracking(2)
                    Spacer()
                    Text("\(remainingPhotos)")
                        .font(.system(.title2, design: .monospaced))
                        .bold()
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color(red: 0.12, green: 0.12, blue: 0.14))
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.black)
                            
                            Image(systemName: "camera.metering.matrix")
                                .font(.largeTitle)
                                .foregroundColor(.white.opacity(0.1))
                        }
                        .padding(24)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                
                VStack(spacing: 24) {
                    HStack(spacing: 48) {
                        Button(action: { playHaptic(.light) }) {
                            Image(systemName: "bolt.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        Button(action: { triggerCamera() }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 88, height: 88)
                                Circle()
                                    .fill(Color(red: 0.9, green: 0.45, blue: 0.1))
                                    .frame(width: 70, height: 70)
                            }
                        }
                        .scaleEffect(isShutterTargeted ? 0.95 : 1.0)
                        
                        Button(action: { playHaptic(.light) }) {
                            Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.2))
                        .frame(width: 140, height: 5)
                }
                .padding(.bottom, 16)
            }
            
            if showFilm {
                VStack {
                    ZStack {
                        Rectangle()
                            .fill(Color(red: 0.95, green: 0.95, blue: 0.95))
                            .frame(width: 240, height: 290)
                            .cornerRadius(4)
                            .shadow(color: Color.black.opacity(0.4), radius: 12, x: 0, y: 8)
                        
                        VStack(spacing: 0) {
                            ZStack {
                                Rectangle()
                                    .fill(Color(red: 0.08, green: 0.08, blue: 0.1))
                                    .frame(width: 208, height: 208)
                                
                                Image(systemName: "waveform.transition")
                                    .font(.largeTitle)
                                    .foregroundColor(.white.opacity(0.05))
                                
                                Color(red: 0.2, green: 0.25, blue: 0.3)
                                    .opacity(development)
                                    .frame(width: 208, height: 208)
                                    .blendMode(.colorBurn)
                            }
                            .padding(.top, 16)
                            
                            Spacer()
                        }
                        .frame(width: 240, height: 290)
                    }
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                if value.translation.height < -60 {
                                    withAnimation(.easeIn(duration: 0.25)) {
                                        showFilm = false
                                    }
                                }
                            }
                    )
                    Spacer()
                }
                .padding(.top, 44)
                .transition(.move(edge: .top))
            }
        }
    }
    
    private func playHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    private func triggerCamera() {
        guard remainingPhotos > 0, !showFilm else { return }
        
        isShutterTargeted = true
        playHaptic(.rigid)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            isShutterTargeted = false
            playHaptic(.heavy)
            remainingPhotos -= 1
            
            withAnimation(.interpolatingSpring(stiffness: 120, damping: 14)) {
                showFilm = true
                development = 0.0
            }
            
            runMotorHaptics()
        }
    }
    
    private func runMotorHaptics() {
        var ticks = 0
        Timer.scheduledTimer(withTimeInterval: 0.06, repeats: true) { timer in
            if ticks > 15 {
                timer.invalidate()
                startDevelopmentProcess()
            } else {
                playHaptic(.soft)
                ticks += 1
            }
        }
    }
    
    private func startDevelopmentProcess() {
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { timer in
            if development >= 1.0 {
                timer.invalidate()
            } else {
                development += 0.08
            }
        }
    }
}
