import SwiftUI
import AVFoundation
import LocalAuthentication

extension AnyTransition {
    static var moveAndFade: AnyTransition {
        .asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal:
                //                    .move(edge: .leading)
                .opacity
        )
    }
}

class PlayerUIView: UIView {
    let playerLayer = AVPlayerLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let avPlayer = AVPlayer(url:  Bundle.main.url(forResource: "SplashVideo", withExtension: "mp4")!)
        playerLayer.player = avPlayer
        layer.addSublayer(playerLayer)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}


struct PlayerView: UIViewRepresentable {
    @Binding var playing: Bool
    
    func makeUIView(context: Context) -> PlayerUIView {
        PlayerUIView(frame: .zero)
    }
    
    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        if playing {
            uiView.playerLayer.player?.play()
        } else {
            uiView.playerLayer.player?.pause()
        }
    }
}

struct SplashView: View {
    @State var isActive: Bool = false
    @State var playing: Bool = false
    let dev = true
    
    var body: some View {
        ZStack {
            if self.isActive || dev {
                ContentView()
            } else {
                PlayerView(playing: $playing)
                    .ignoresSafeArea(.all)
                    .scaledToFill()
                    .transition(.moveAndFade)
                    .onAppear {
                        Task {
                            do {
                                let context = LAContext()
                                var canAuth: Bool {
                                    var error: NSError?
                                    context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
                                    return error == nil
                                }
                                if canAuth {
                                    try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Log in to your account")
                                }
                                self.playing = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                    withAnimation(.linear(duration: 0.5)) {
                                        self.isActive = true
                                    }
                                }
                            } catch let error {
                                print(error.localizedDescription)
                            }
                        }
                    }
            }
        }
    }
}
