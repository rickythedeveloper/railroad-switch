//
//  Track.swift
//  railroad-switch
//
//  Created by Rintaro Kawagishi on 02/01/2022.
//

import SpriteKit

class Joint: Hashable {
    let id: UUID
    let position: CGPoint
    
    init(position: CGPoint) {
        self.id = UUID()
        self.position = position
    }
    
    static func ==(lhs: Joint, rhs: Joint) -> Bool { ObjectIdentifier(lhs) == ObjectIdentifier(rhs) }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

class Track: Hashable {
    let id: UUID
    let singleJoint: Joint
    let multiJoint: [Joint]
    var jointIndex: Int {
        didSet {
            self.jointIndexDidChange(self)
        }
    }
    let jointIndexDidChange: (_ track: Track) -> Void
    
    var joint1: Joint {
        get { singleJoint }
    }
    var joint2: Joint {
        get { multiJoint[jointIndex] }
    }
    var angle: Double {
        get { (self.joint2.position - self.joint1.position).angle }
    }
    
    init(singleJoint: Joint, multiJoint: [Joint], jointIndex: Int = 0, jointIndexDidChange: @escaping (_ track: Track) -> Void) {
        self.id = UUID()
        self.singleJoint = singleJoint
        self.multiJoint = multiJoint
        self.jointIndex = jointIndex
        self.jointIndexDidChange = jointIndexDidChange
    }
    
    static func ==(lhs: Track, rhs: Track) -> Bool { ObjectIdentifier(lhs) == ObjectIdentifier(rhs) }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

class Train: Hashable {
    let id: UUID
    var track: Track
    var from1To2: Bool
    var goalJoint: Joint
    
    init(track: Track, joint: Joint, goalJoint: Joint) {
        self.id = UUID()
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
    let trainDidReachGoal: () -> Void
    
    init(
        moveTrainInScene: @escaping (_ train: Train,_ joint: Joint,_ duration: TimeInterval) -> Void,
        pauseTrainInScene: @escaping (_ train: Train) -> Void,
        trainDidReachGoal: @escaping () -> Void
    ) {
        self.moveTrainInScene = moveTrainInScene
        self.pauseTrainInScene = pauseTrainInScene
        self.trainDidReachGoal = trainDidReachGoal
    }
    
    func trainDidArriveAtNode(train: Train) {
        let currentTrack = train.track
        let currentJoint = train.from1To2 ? currentTrack.joint2 : currentTrack.joint1
        if currentJoint == train.goalJoint {
            self.trainDidReachGoal()
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
