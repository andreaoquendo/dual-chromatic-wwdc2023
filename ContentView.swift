import SwiftUI
import SpriteKit

class GameViewController: UIViewController {
    
    var skView: SKView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = SKView(frame: view.frame)
        view.addSubview(skView)
        
        let scene = GameScene()
        scene.scaleMode = .resizeFill
        
        skView.presentScene(scene)
        
        
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            
            if let skView = view.subviews.first(where: { $0 is SKView }) as? SKView, let scene = skView.scene as? GameScene {
                scene.motionBegan()
            } else {
            }
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            
            if let skView = view.subviews.first(where: { $0 is SKView }) as? SKView, let scene = skView.scene as? GameScene {
                scene.motionEnded()
            }
        }
    }
    
}

struct GameViewControllerWrapper: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> GameViewController {
        let gameVC = GameViewController()
        return gameVC
    }
    
    func updateUIViewController(_ uiViewController: GameViewController, context: Context) {
        // Update the view controller if needed
    }
}

struct ContentView: View {

    var body: some View {
        ZStack(alignment: .top){
            GameViewControllerWrapper()
                .edgesIgnoringSafeArea(.all)
        }
        
    }
}

