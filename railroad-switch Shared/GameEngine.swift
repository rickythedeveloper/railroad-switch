//
//  Track.swift
//  railroad-switch
//
//  Created by Rintaro Kawagishi on 02/01/2022.
//

import SpriteKit

class Joint: Equatable {
    let skNode: SKShapeNode
    let position: CGPoint
    
    init(position: CGPoint) {
        let node = SKShapeNode(circleOfRadius: 20)
        node.position = position
        node.fillColor = UIColor.red
        self.skNode = node
        self.position = position
    }
    
    static func ==(lhs: Joint, rhs: Joint) -> Bool { ObjectIdentifier(lhs) == ObjectIdentifier(rhs) }
}

class Track: Equatable {
    let skNode: SKShapeNode
    let singleJoint: Joint
    let multiJoint: [Joint]
    var jointIndex: Int {
        didSet {
            let path = CGMutablePath()
            path.move(to: joint1.skNode.position)
            path.addLine(to: joint2.skNode.position)
            skNode.path = path
            for child in skNode.children {
                (child as! SKShapeNode).path = path
            }
        }
    }
    
    var joint1: Joint {
        get { singleJoint }
    }
    var joint2: Joint {
        get { multiJoint[jointIndex] }
    }
    
    init(singleJoint: Joint, multiJoint: [Joint], jointIndex: Int = 0) {
        let bigLine = SKShapeNode()
        let line = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: singleJoint.skNode.position)
        path.addLine(to: multiJoint[jointIndex].skNode.position)
        bigLine.strokeColor = UIColor.clear
        bigLine.lineWidth = 50
        line.strokeColor = multiJoint.count == 1 ? UIColor.yellow : UIColor.green
        line.lineWidth = 10
        line.path = path
        bigLine.path = path
        bigLine.addChild(line)
        self.skNode = bigLine
        self.singleJoint = singleJoint
        self.multiJoint = multiJoint
        self.jointIndex = jointIndex
    }
    
    static func ==(lhs: Track, rhs: Track) -> Bool { ObjectIdentifier(lhs) == ObjectIdentifier(rhs) }
}

class Train {
    let skNode: SKShapeNode
    var track: Track
    var from1To2: Bool
    var goalJoint: Joint
    
    init(track: Track, joint: Joint, goalJoint: Joint) {
        let rect = SKShapeNode(rectOf: CGSize(width: 30, height: 20))
        rect.position = joint.skNode.position
        rect.fillColor = UIColor.blue
        self.skNode = rect
        self.track = track
        self.from1To2 = track.joint1 == joint
        self.goalJoint = goalJoint
    }
}

class GameEngine {
    var joints: [Joint] = []
    var tracks: [Track] = []
    var trains: [Train] = []
    let startTrainInScene: (_ train: Train,_ duration: TimeInterval) -> Void
    
    init(startTrainInScene: @escaping (_ train: Train,_ duration: TimeInterval) -> Void) {
        self.startTrainInScene = startTrainInScene
    }
    
    func trainDidArriveAtNode(train: Train) {
        let currentTrack = train.track
        let currentJoint = train.from1To2 ? currentTrack.joint2 : currentTrack.joint1
        if currentJoint == train.goalJoint {
            print("Goal reached!")
            return
        }
        for newTrack in self.tracks {
            guard newTrack != currentTrack else { continue }
            if newTrack.joint1 == currentJoint || newTrack.joint2 == currentJoint {
                train.track = newTrack
                train.from1To2 = newTrack.joint1 == currentJoint
                self.startTrain(train: train)
                return
            }
        }
        
        print("Failed!")
    }
    
    func startTrain(train: Train) {
        let distance = getTrackDistance(train.track)
        let trainSpeed = 100.0
        let time = distance / trainSpeed
        Timer.scheduledTimer(withTimeInterval: time, repeats: false) { timer in
            self.trainDidArriveAtNode(train: train)
        }
        
        self.startTrainInScene(train, time)
    }
    
    func getTrackDistance(_ track: Track) -> Double { CGPoint.getDistanceBetween(track.joint1.position, track.joint2.position) }
    
    func switchTrack(_ track: Track) {
        for t in self.trains {
            if t.track == track { return }
        }
        track.jointIndex = track.jointIndex == track.multiJoint.count - 1 ? 0 : track.jointIndex + 1
    }
}
