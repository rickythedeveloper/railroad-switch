//
//  Track.swift
//  railroad-switch
//
//  Created by Rintaro Kawagishi on 02/01/2022.
//

import SpriteKit

typealias NodeID = Int

class RailwayNode: Equatable {
    let skNode: SKShapeNode
    let position: CGPoint
    
    init(skNode: SKShapeNode, position: CGPoint) {
//        self.id = id
        self.skNode = skNode
        self.position = position
    }
    
    static func ==(lhs: RailwayNode, rhs: RailwayNode) -> Bool { ObjectIdentifier(lhs) == ObjectIdentifier(rhs) }
}

typealias TrackID = Int

class Track: Equatable {
//    let id: TrackID
    let skNode: SKShapeNode
    let node1: RailwayNode
    let node2: RailwayNode
    
    init(skNode: SKShapeNode, node1: RailwayNode, node2: RailwayNode) {
//        self.id = id
        self.skNode = skNode
        self.node1 = node1
        self.node2 = node2
    }
    
    static func ==(lhs: Track, rhs: Track) -> Bool { ObjectIdentifier(lhs) == ObjectIdentifier(rhs) }
}

typealias TrainID = Int

class Train {
//    let id: TrainID
    let skNode: SKShapeNode
    var track: Track
    var from1To2: Bool
    
    init(skNode: SKShapeNode, track: Track, from1To2: Bool) {
        self.skNode = skNode
        self.track = track
        self.from1To2 = from1To2
    }
}

class GameEngine {
    var nodes: [RailwayNode] = []
    var tracks: [Track] = []
    var trains: [Train] = []
    let startTrainInScene: (_ train: Train,_ duration: TimeInterval) -> Void
    
    init(startTrainInScene: @escaping (_ train: Train,_ duration: TimeInterval) -> Void) {
        self.startTrainInScene = startTrainInScene
    }
    
    func trainDidArriveAtNode(train: Train) {
        let currentTrack = train.track
        let arrivingNode = train.from1To2 ? currentTrack.node2 : currentTrack.node1
        for newTrack in self.tracks {
            guard newTrack != currentTrack else { continue }
            if newTrack.node1 == arrivingNode || newTrack.node2 == arrivingNode {
                train.track = newTrack
                train.from1To2 = newTrack.node1 == arrivingNode
                self.startTrain(train: train)
                return
            }
        }
        print("No new track found")
        
//        If no tracks found then do something?
    }
    
    func startTrain(train: Train) {
        let start = train.from1To2 ? train.track.node1 : train.track.node2
        let end = train.from1To2 ? train.track.node2 : train.track.node1
        print("\(start.skNode.position) to \(end.skNode.position)")
        let distance = getTrackDistance(train.track)
        let trainSpeed = 100.0
        let time = distance / trainSpeed
        Timer.scheduledTimer(withTimeInterval: time, repeats: false) { timer in
            self.trainDidArriveAtNode(train: train)
        }
        
        self.startTrainInScene(train, time)
    }
    
    func getTrackDistance(_ track: Track) -> Double {
        let delta = track.node2.position - track.node1.position
        return (pow(Double(delta.x), 2) + pow(Double(delta.y), 2)).squareRoot()
    }
}
