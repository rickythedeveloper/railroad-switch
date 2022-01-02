//
//  GameScene.swift
//  railroad-switch Shared
//
//  Created by Rintaro Kawagishi on 02/01/2022.
//

import SpriteKit

class GameScene: SKScene {
    
    
    fileprivate var label : SKLabelNode?
    fileprivate var spinnyNode : SKShapeNode?
    
    var gameEngine: GameEngine!
    
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        return scene
    }
    
    func setUpScene() {
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 4.0
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
            
            #if os(watchOS)
                // For watch we just periodically create one of these and let it spin
                // For other platforms we let user touch/mouse events create these
                spinnyNode.position = CGPoint(x: 0.0, y: 0.0)
                spinnyNode.strokeColor = SKColor.red
                self.run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 2.0),
                                                                   SKAction.run({
                                                                       let n = spinnyNode.copy() as! SKShapeNode
                                                                       self.addChild(n)
                                                                   })])))
            #endif
        }
        
        self.gameEngine = GameEngine(startTrainInScene: self.startTrain)
        self.addRailwayNode(position: CGPoint(x: 0, y: 0))
        self.addRailwayNode(position: CGPoint(x: 100, y: 0))
        self.addRailwayNode(position: CGPoint(x: 100, y: 100))
        self.addTrack(node1: self.gameEngine.nodes[0], node2: self.gameEngine.nodes[1])
        self.addTrack(node1: self.gameEngine.nodes[1], node2: self.gameEngine.nodes[2])
        self.addTrain(track: self.gameEngine.tracks[0], node: self.gameEngine.nodes[0])
        self.gameEngine.startTrain(train: self.gameEngine.trains[0])
    }
    
    #if os(watchOS)
    override func sceneDidLoad() {
        self.setUpScene()
    }
    #else
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    #endif

    func makeSpinny(at pos: CGPoint, color: SKColor) {
        if let spinny = self.spinnyNode?.copy() as! SKShapeNode? {
            spinny.position = pos
            spinny.strokeColor = color
            self.addChild(spinny)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func addRailwayNode(position: CGPoint) {
        let node = SKShapeNode(circleOfRadius: 20)
        node.position = position
        node.fillColor = UIColor.red
        self.addChild(node)
        self.gameEngine.nodes.append(RailwayNode(skNode: node, position: position))
    }
    
    func addTrack(node1: RailwayNode, node2: RailwayNode) {
        let line = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: node1.skNode.position)
        path.addLine(to: node2.skNode.position)
        line.path = path
        line.strokeColor = UIColor.yellow
        self.addChild(line)
        self.gameEngine.tracks.append(Track(skNode: line, node1: node1, node2: node2))
    }
    
    func addTrain(track: Track, node: RailwayNode) {
        let rect = SKShapeNode(rectOf: CGSize(width: 30, height: 20))
        rect.position = node.skNode.position
        rect.fillColor = UIColor.blue
        self.addChild(rect)
        self.gameEngine.trains.append(Train(skNode: rect, track: track, from1To2: track.node1 == node))
    }
    
    func startTrain(train: Train, duration: TimeInterval) {
        let startingNode = train.from1To2 ? train.track.node1 : train.track.node2
        let endNode = train.from1To2 ? train.track.node2 : train.track.node1
        train.skNode.position = startingNode.skNode.position
        train.skNode.run(SKAction.move(to: endNode.skNode.position, duration: duration))
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.green)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.blue)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.red)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.red)
        }
    }
    
   
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {

    override func mouseDown(with event: NSEvent) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        self.makeSpinny(at: event.location(in: self), color: SKColor.green)
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.makeSpinny(at: event.location(in: self), color: SKColor.blue)
    }
    
    override func mouseUp(with event: NSEvent) {
        self.makeSpinny(at: event.location(in: self), color: SKColor.red)
    }

}
#endif

