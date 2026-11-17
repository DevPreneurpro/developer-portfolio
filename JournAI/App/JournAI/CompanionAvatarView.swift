import SwiftUI
import AVKit

/// Seamlessly loops a short video clip using AVQueuePlayer + AVPlayerLooper
/// (the standard gapless-looping approach) — plain AVPlayer + seek-to-zero
/// visibly stutters at the loop point. Swap `url` to switch clips (idle vs.
/// talking); the player reconfigures itself with the new clip.
struct LoopingVideoPlayer: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        controller.view.backgroundColor = .clear
        context.coordinator.configure(controller: controller, url: url)
        return controller
    }

    func updateUIViewController(_ controller: AVPlayerViewController, context: Context) {
        context.coordinator.update(url: url)
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator {
        private var player: AVQueuePlayer?
        private var looper: AVPlayerLooper?
        private var currentURL: URL?

        func configure(controller: AVPlayerViewController, url: URL) {
            let queuePlayer = AVQueuePlayer()
            let item = AVPlayerItem(url: url)
            looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
            queuePlayer.isMuted = true
            player = queuePlayer
            controller.player = queuePlayer
            currentURL = url
            queuePlayer.play()
        }

        func update(url: URL) {
            guard url != currentURL, let player else { return }
            looper = nil
            let item = AVPlayerItem(url: url)
            looper = AVPlayerLooper(player: player, templateItem: item)
            currentURL = url
            player.play()
        }
    }
}

/// The companion's face, wherever it's shown: a looping clip when one's
/// been generated, else the static portrait, else a placeholder icon.
/// `isTalking` picks which clip plays — switch it on while the companion
/// is "speaking" a reply.
struct CompanionAvatarView: View {
    @ObservedObject private var store = CompanionAppearanceStore.shared
    var isTalking = false
    var size: CGFloat = 32

    var body: some View {
        ZStack {
            Circle().fill(Color("JournalAccentTint"))

            if let clipURL = isTalking ? (store.talkingClipURL ?? store.idleClipURL) : store.idleClipURL {
                LoopingVideoPlayer(url: clipURL)
                    .clipShape(Circle())
            } else if let portraitURL = store.portraitURL {
                AsyncImage(url: portraitURL) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else {
                        Color.clear
                    }
                }
                .clipShape(Circle())
            } else {
                Image(systemName: "sparkles")
                    .font(.system(size: size * 0.4))
                    .foregroundColor(Color("JournalAccentDark"))
            }
        }
        .frame(width: size, height: size)
    }
}
