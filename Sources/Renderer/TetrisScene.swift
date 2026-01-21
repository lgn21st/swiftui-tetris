import SpriteKit
import Core

public final class TetrisScene: SKScene {
    public static let defaultSize = CGSize(width: 480, height: 720)

    public override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .resizeFill
        backgroundColor = .black
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        scaleMode = .resizeFill
        backgroundColor = .black
    }

    public override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        // Placeholder for tick-driven updates.
    }
}
