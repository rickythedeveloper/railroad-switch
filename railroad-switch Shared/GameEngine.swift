//
//  Track.swift
//  railroad-switch
//
//  Created by Rintaro Kawagishi on 02/01/2022.
//

import SpriteKit

fileprivate let TRACK_WIDTH: CGFloat = 20
fileprivate let TRAIN_WIDTH: CGFloat = 40
fileprivate let ANIMATION_DURATION: TimeInterval = 0.3

class Joint: Equatable {
    let skNode: SKShapeNode
    let position: CGPoint
    
    init(position: CGPoint) {
        let node = SKShapeNode(circleOfRadius: TRACK_WIDTH/2)
        node.position = position
        node.strokeColor = .clear
        node.fillColor = .white
        self.skNode = node
        self.position = position
    }
    
    static func ==(lhs: Joint, rhs: Joint) -> Bool { ObjectIdentifier(lhs) == ObjectIdentifier(rhs) }
}

class Track: Equatable {
    let skNode: SKShapeNode
    private var currentLength: Double
    var currentAngle: Double
    let singleJoint: Joint
    let multiJoint: [Joint]
    var jointIndex: Int {
        didSet {
            let newLength = CGPoint.getDistanceBetween(self.joint1.skNode.position, self.joint2.skNode.position)
            let newAngle = (self.joint2.skNode.position - self.joint1.skNode.position).angle
            self.skNode.run(SKAction.scaleX(by: newLength / currentLength, y: 1, duration: ANIMATION_DURATION))
            currentLength = newLength
            self.skNode.run(SKAction.rotate(toAngle: newAngle, duration: ANIMATION_DURATION))
        }
    }
    
    var joint1: Joint {
        get { singleJoint }
    }
    var joint2: Joint {
        get { multiJoint[jointIndex] }
    }
    
    init(singleJoint: Joint, multiJoint: [Joint], jointIndex: Int = 0) {
        self.singleJoint = singleJoint
        self.multiJoint = multiJoint
        self.jointIndex = jointIndex
        self.currentLength = CGPoint.getDistanceBetween(singleJoint.skNode.position, multiJoint[jointIndex].skNode.position)
        self.currentAngle = (multiJoint[jointIndex].skNode.position - singleJoint.skNode.position).angle
        self.skNode = SKShapeNode(rect: CGRect(x: -TRACK_WIDTH/2, y: -TRACK_WIDTH/2, width: self.currentLength + TRACK_WIDTH, height: TRACK_WIDTH), cornerRadius: TRACK_WIDTH/2)
        self.skNode.strokeColor = .white
        self.skNode.position = singleJoint.skNode.position
        self.skNode.run(SKAction.rotate(toAngle: self.currentAngle, duration: 0))
    }
    
    static func ==(lhs: Track, rhs: Track) -> Bool { ObjectIdentifier(lhs) == ObjectIdentifier(rhs) }
}

class Train: Hashable {
    let id: UUID
    let skNode: SKShapeNode
    var track: Track
    var from1To2: Bool
    var goalJoint: Joint
    
    init(track: Track, joint: Joint, goalJoint: Joint) {
        self.id = UUID()
        let rect = SKShapeNode(rectOf: CGSize(width: TRAIN_WIDTH * 1.5, height: TRAIN_WIDTH))
        rect.position = joint.skNode.position
        rect.strokeColor = .clear
        rect.fillColor = .blue
        self.skNode = rect
        self.track = track
        self.from1To2 = track.joint1 == joint
        self.goalJoint = goalJoint
    }
    
    static func ==(lhs: Train, rhs: Train) -> Bool { ObjectIdentifier(lhs) == ObjectIdentifier(rhs) }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

enum TimerInfo {
    case timer(Timer)
    case duration(TimeInterval)
}

class GameEngine {
    var joints: [Joint] = []
    var tracks: [Track] = []
    var trains: [Train] = []
    var trainTimers: [Train: TimerInfo] = [:]
    let moveTrainInScene: (_ train: Train,_ joint: Joint,_ duration: TimeInterval) -> Void
    let pauseTrainInScene: (_ train: Train) -> Void
    
    init(moveTrainInScene: @escaping (_ train: Train,_ joint: Joint,_ duration: TimeInterval) -> Void, pauseTrainInScene: @escaping (_ train: Train) -> Void) {
        self.moveTrainInScene = moveTrainInScene
        self.pauseTrainInScene = pauseTrainInScene
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
        trainTimers[train] = TimerInfo.timer(Timer.scheduledTimer(withTimeInterval: time, repeats: false) { timer in
            self.trainDidArriveAtNode(train: train)
        })
        self.moveTrainInScene(train, train.from1To2 ? train.track.joint2 : train.track.joint1, time)
    }
    
    func getTrackDistance(_ track: Track) -> Double { CGPoint.getDistanceBetween(track.joint1.position, track.joint2.position) }
    
    func switchTrack(_ track: Track) {
        for t in self.trains {
            if t.track == track { return }
        }
        track.jointIndex = track.jointIndex == track.multiJoint.count - 1 ? 0 : track.jointIndex + 1
    }
    
    func pauseResumeTrain(_ train: Train) {
        if let timerInfo = trainTimers[train] {
            switch timerInfo {
            case .timer(let timer):
                let remaining = timer.fireDate - Date()
                trainTimers[train] = .duration(remaining)
                timer.invalidate()
                self.pauseTrainInScene(train)
            case .duration(let duration):
                trainTimers[train] = .timer(Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { timer in
                    self.trainDidArriveAtNode(train: train)
                })
                self.moveTrainInScene(train, train.from1To2 ? train.track.joint2 : train.track.joint1, duration)
            }
        }
    }
}
