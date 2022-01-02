//
//  Track.swift
//  railroad-switch
//
//  Created by Rintaro Kawagishi on 02/01/2022.
//

import SpriteKit

class RailwayNode: Equatable {
    let skNode: SKShapeNode
    let position: CGPoint
    
    init(position: CGPoint) {
        let node = SKShapeNode(circleOfRadius: 20)
        node.position = position
        node.fillColor = UIColor.red
        self.skNode = node
        self.position = position
    }
    
    static func ==(lhs: RailwayNode, rhs: RailwayNode) -> Bool { ObjectIdentifier(lhs) == ObjectIdentifier(rhs) }
}

class Track: Equatable {
    let skNode: SKShapeNode
    let singleNode: RailwayNode
    let multiNode: [RailwayNode]
    var nodeIndex: Int {
        didSet {
            let path = CGMutablePath()
            path.move(to: node1.skNode.position)
            path.addLine(to: node2.skNode.position)
            skNode.path = path
            for child in skNode.children {
                (child as! SKShapeNode).path = path
            }
        }
    }
    
    var node1: RailwayNode {
        get { singleNode }
    }
    var node2: RailwayNode {
        get { multiNode[nodeIndex] }
    }
    
    init(singleNode: RailwayNode, multiNode: [RailwayNode], nodeIndex: Int = 0) {
        let bigLine = SKShapeNode()
        let line = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: singleNode.skNode.position)
        path.addLine(to: multiNode[nodeIndex].skNode.position)
        bigLine.strokeColor = UIColor.clear
        bigLine.lineWidth = 50
        line.strokeColor = multiNode.count == 1 ? UIColor.yellow : UIColor.green
        line.lineWidth = 10
        line.path = path
        bigLine.path = path
        bigLine.addChild(line)
        self.skNode = bigLine
        self.singleNode = singleNode
        self.multiNode = multiNode
        self.nodeIndex = nodeIndex
    }
    
    static func ==(lhs: Track, rhs: Track) -> Bool { ObjectIdentifier(lhs) == ObjectIdentifier(rhs) }
}

class Train {
    let skNode: SKShapeNode
    var track: Track
    var from1To2: Bool
    
    init(track: Track, node: RailwayNode) {
        let rect = SKShapeNode(rectOf: CGSize(width: 30, height: 20))
        rect.position = node.skNode.position
        rect.fillColor = UIColor.blue
        self.skNode = rect
        self.track = track
        self.from1To2 = track.node1 == node
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
        
//        If no tracks found then do something?
        print("No new track found")
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
    
    func getTrackDistance(_ track: Track) -> Double { CGPoint.getDistanceBetween(track.node1.position, track.node2.position) }
    
    func switchTrack(_ track: Track) {
        for t in self.trains {
            if t.track == track { return }
        }
        track.nodeIndex = track.nodeIndex == track.multiNode.count - 1 ? 0 : track.nodeIndex + 1
    }
}
