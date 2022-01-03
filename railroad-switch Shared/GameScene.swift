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
    private let TRAIN_ANIMATION_KEY = "train-animation"
    
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
        self.gameEngine = GameEngine(moveTrainInScene: self.moveTrain, pauseTrainInScene: self.pauseTrain)
        self.addJoint(position: CGPoint(x: -200, y: 0))
        self.addJoint(position: CGPoint(x: 0, y: 0))
        self.addJoint(position: CGPoint(x: 100, y: 0))
        self.addJoint(position: CGPoint(x: 200, y: 0))
        self.addJoint(position: CGPoint(x: 100, y: 100))
        self.addJoint(position: CGPoint(x: 200, y: 100))
        self.addTrack(singleJoint: self.gameEngine.joints[0], multiJoint: [self.gameEngine.joints[1]])
        self.addTrack(singleJoint: self.gameEngine.joints[1], multiJoint: [self.gameEngine.joints[2], self.gameEngine.joints[4]], jointIndex: 1)
        self.addTrack(singleJoint: self.gameEngine.joints[2], multiJoint: [self.gameEngine.joints[3]])
        self.addTrack(singleJoint: self.gameEngine.joints[4], multiJoint: [self.gameEngine.joints[5]])
        self.addTrain(track: self.gameEngine.tracks[0], joint: self.gameEngine.joints[0], goalJoint: self.gameEngine.joints[3])
        self.gameEngine.startTrain(train: self.gameEngine.trains[0])
        
        self.renderAll()
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
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func addJoint(position: CGPoint) {
        let joint = Joint(position: position)
        self.gameEngine.joints.append(joint)
    }
    
    func addTrack(singleJoint: Joint, multiJoint: [Joint], jointIndex: Int = 0) {
        let track = Track(singleJoint: singleJoint, multiJoint: multiJoint, jointIndex: jointIndex)
        self.gameEngine.tracks.append(track)
    }
    
    func addTrain(track: Track, joint: Joint, goalJoint: Joint) {
        let train = Train(track: track, joint: joint, goalJoint: goalJoint)
        self.gameEngine.trains.append(train)
    }
    
    func moveTrain(_ train: Train, to joint: Joint, duration: TimeInterval) {
        train.skNode.run(SKAction.move(to: joint.skNode.position, duration: duration), withKey: TRAIN_ANIMATION_KEY)
    }
    
    func pauseTrain(_ train: Train) {
        train.skNode.removeAction(forKey: TRAIN_ANIMATION_KEY)
    }
    
    func renderAll() {
        for track in self.gameEngine.tracks { self.addChild(track.skNode) }
        for joint in self.gameEngine.joints { self.addChild(joint.skNode) }
        for train in self.gameEngine.trains { self.addChild(train.skNode) }
    }
    
    func respondToTouch(location: CGPoint) {
        let touchedNodes = self.nodes(at: location)
        for n in touchedNodes {
            let tracks = self.gameEngine.tracks.filter { track in track.skNode == n }
            tracks.forEach { track in self.gameEngine.switchTrack(track) }
            
            let trains = self.gameEngine.trains.filter { train in train.skNode == n }
            for train in trains { self.gameEngine.pauseResumeTrain(train) }
        }
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.respondToTouch(location: t.location(in: self)) }
    }
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {
    override func mouseDown(with event: NSEvent) { self.respondToTouch(location: event.location(in: self)) }
}
#endif

