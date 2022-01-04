//
//  GameScene.swift
//  railroad-switch Shared
//
//  Created by Rintaro Kawagishi on 02/01/2022.
//

import SpriteKit


class GameScene: SKScene {
    private let TRACK_WIDTH: CGFloat = 20
    private let TRACK_LINE_WIDTH: CGFloat = 2
    private let TRAIN_WIDTH: CGFloat = 40
    private let ANIMATION_DURATION: TimeInterval = 0.3
    
    private var gameEngine: GameEngine!
    private let TRAIN_ANIMATION_KEY = "train-animation"
    private var scoreLabel: SKLabelNode!
    private var score: Int = 0 {
        didSet {
            self.scoreLabel.text = "Score: \(self.score)"
        }
    }
    private var trackMainNodes: [Track:SKShapeNode] = [:]
    private var initialTrackSceneLength: [Track:Double] = [:]
    private var trainNode: [Train:SKShapeNode] = [:]
    private var scale: Double = 1
    private var center: CGPoint = CGPoint.zero
    
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .resizeFill
        return scene
    }
    
    func setUpScene() {
        self.gameEngine = GameEngine(moveTrainInScene: self.moveTrain, pauseTrainInScene: self.pauseTrain, trainDidReachGoal: self.trainDidReachGoal)
        self.gameEngine.joints.append(contentsOf: [
            Joint(position: CGPoint(x: -200, y: 0)),
            Joint(position: CGPoint(x: 0, y: 0)),
            Joint(position: CGPoint(x: 100, y: 0)),
            Joint(position: CGPoint(x: 200, y: 0)),
            Joint(position: CGPoint(x: 100, y: 100)),
            Joint(position: CGPoint(x: 200, y: 100)),
        ])
        self.gameEngine.tracks.append(contentsOf: [
            self.getTrack(singleJoint: self.gameEngine.joints[0], multiJoint: [self.gameEngine.joints[1]]),
            self.getTrack(singleJoint: self.gameEngine.joints[1], multiJoint: [self.gameEngine.joints[2], self.gameEngine.joints[4]], jointIndex: 1),
            self.getTrack(singleJoint: self.gameEngine.joints[2], multiJoint: [self.gameEngine.joints[3]]),
            self.getTrack(singleJoint: self.gameEngine.joints[4], multiJoint: [self.gameEngine.joints[5]]),
        ])
        self.gameEngine.trains.append(contentsOf: [
            Train(track: self.gameEngine.tracks[0], joint: self.gameEngine.joints[0], goalJoint: self.gameEngine.joints[3])
        ])
        
        self.renderAll()
        self.gameEngine.startTrain(train: self.gameEngine.trains[0])
        
        
        self.scoreLabel = SKLabelNode()
        self.scoreLabel.fontSize = 15
        self.scoreLabel.fontColor = SKColor.white
        self.scoreLabel.text = "Score: ----"
        self.scoreLabel.position = CGPoint(x: self.frame.width/2 - scoreLabel.frame.width/2 - 10, y: self.frame.height/2 - scoreLabel.frame.height/2 - 10)
        self.addChild(self.scoreLabel)
        self.score = 0
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
    
    private func adjustPosition(_ position: CGPoint) -> CGPoint { (position - self.center) * self.scale }
    
    private func getTrack(singleJoint: Joint, multiJoint: [Joint], jointIndex: Int = 0) -> Track {
        return Track(singleJoint: singleJoint, multiJoint: multiJoint, jointIndex: jointIndex, jointIndexDidChange: { t in
            let trackSceneLength = self.getTrackSceneLength(track: t)
            let trackAngle = (t.joint2.position - t.joint1.position).angle
            if let mainNode = self.trackMainNodes[t], let initialTrackSceneLength2 = self.initialTrackSceneLength[t] {
                mainNode.run(SKAction.scaleX(to: trackSceneLength / initialTrackSceneLength2, duration: self.ANIMATION_DURATION))
                mainNode.run(SKAction.rotate(toAngle: trackAngle, duration: self.ANIMATION_DURATION))
            }
        })
    }
    
    private func moveTrain(_ train: Train, to joint: Joint, duration: TimeInterval) {
        if let node = self.trainNode[train] {
            node.run(SKAction.move(to: adjustPosition(joint.position), duration: duration), withKey: TRAIN_ANIMATION_KEY)
        } else {fatalError()}
    }
    
    private func pauseTrain(_ train: Train) {
        if let node = self.trainNode[train] {
            node.removeAction(forKey: TRAIN_ANIMATION_KEY)
        } else {fatalError()}
    }
    
    private func trainDidReachGoal() { self.score += 1 }
    
    private func renderAll() {
        let (minX, maxX, minY, maxY) = CGPoint.getMaxMin(points: self.gameEngine.joints.map({ j in j.position }))
        let minWidth = (maxX - minX) * 1.2
        let minHeight = (maxY - minY) * 1.2
        self.scale = min(self.frame.width / minWidth, self.frame.height / minHeight)
        self.center = CGPoint(x: (minX + maxX) / 2, y: (minY + maxY) / 2)
        for track in self.gameEngine.tracks { self.addChild(self.createTrackNode(track: track)) }
        for joint in self.gameEngine.joints { self.addChild(self.createJointNode(joint: joint)) }
        for train in self.gameEngine.trains {
            let trainNode = self.createTrainNode(train: train)
            self.trainNode[train] = trainNode
            self.addChild(trainNode)
        }
    }
    
    private func getTrackSceneLength(track: Track) -> Double { self.getJointsSceneLength(from: track.joint1, to: track.joint2) }
    
    private func getJointsSceneLength(from joint1: Joint, to joint2: Joint) -> Double { (self.adjustPosition(joint1.position) - self.adjustPosition(joint2.position)).magnitude }

    private func createJointNode(joint: Joint) -> SKShapeNode {
        let node = SKShapeNode(circleOfRadius: TRACK_WIDTH/2)
        node.position = self.adjustPosition(joint.position)
        node.strokeColor = .clear
        node.fillColor = .white
        return node
    }
    
    private func getTrackPath(distance: Double, lineWidth: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let topY = TRACK_WIDTH/2 - lineWidth/2
        let bottomY = -topY
        path.move(to: CGPoint(x: 0, y: topY))
        path.addLine(to: CGPoint(x: distance, y: topY))
        path.move(to: CGPoint(x: 0, y: bottomY))
        path.addLine(to: CGPoint(x: distance, y: bottomY))
        return path
    }
    
    private func createTrackNode(track: Track) -> SKNode {
        let mainAngle = (track.joint2.position - track.joint1.position).angle
        let mainLength = getTrackSceneLength(track: track)
        let mainPath = getTrackPath(distance: mainLength, lineWidth: TRACK_LINE_WIDTH)
        initialTrackSceneLength[track] = mainLength
        let mainNode = SKShapeNode()
        mainNode.path = mainPath
        self.trackMainNodes[track] = mainNode
        mainNode.strokeColor = .red
        mainNode.run(SKAction.rotate(toAngle: mainAngle, duration: 0))
        
        
        let node = SKNode()
        node.position = self.adjustPosition(track.singleJoint.position)
        
        if track.multiJoint.count > 1 {
            for j in track.multiJoint {
                let dummySceneLength = getJointsSceneLength(from: track.singleJoint, to: j)
                let dummyAngle = (j.position - track.singleJoint.position).angle
                let dummyPath = getTrackPath(distance: dummySceneLength, lineWidth: TRACK_LINE_WIDTH)
                let dummyNode = SKShapeNode()
                dummyNode.path = dummyPath
                dummyNode.strokeColor = .darkGray
                dummyNode.position = CGPoint.zero
                dummyNode.run(SKAction.rotate(toAngle: dummyAngle, duration: 0))
                node.addChild(dummyNode)
            }
        }
        
        node.addChild(mainNode)
        return node
    }
    
    private func createTrainNode(train: Train) -> SKShapeNode {
        let node = SKShapeNode(rectOf: CGSize(width: TRAIN_WIDTH * 1.5, height: TRAIN_WIDTH))
        let joint = train.from1To2 ? train.track.joint1 : train.track.joint2
        node.position = self.adjustPosition(joint.position)
        node.strokeColor = .clear
        node.fillColor = .blue
        return node
    }
    
    private func respondToTouch(location: CGPoint) {
        let touchedNodes = self.nodes(at: location)
        for n in touchedNodes {
            var tracks: [Track] = []
            for (track, mainNode) in trackMainNodes {
                if mainNode == n { tracks.append(track) }
            }
            
            tracks.forEach { track in self.gameEngine.switchTrack(track) }
            
            var trains: [Train] = []
            for (train, nodee) in trainNode {
                if nodee == n { trains.append(train)}
            }
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

