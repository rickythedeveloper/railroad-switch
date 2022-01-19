//
//  Stage.swift
//  railroad-switch
//
//  Created by Rintaro Kawagishi on 05/01/2022.
//

import Foundation
import CoreGraphics

struct JointInfo {
    let position: CGPoint
}

struct TrackInfo {
    let singleJoint: Int
    let multiJoint: [Int]
    var jointIndex: Int = 0
}

struct TrainInfo {
    let trackIndex: Int
    let jointIndex: Int
    let goalJointIndex: Int
    let startTime: TimeInterval
}

struct Stage {
    let joints: [JointInfo]
    let tracks: [TrackInfo]
    let trainStartTime: [TrainInfo]
}

let STAGES: [Stage] = [
    Stage(joints: [
        JointInfo(position: CGPoint(x: -200, y: 0)),
        JointInfo(position: CGPoint(x: 0, y: 0)),
        JointInfo(position: CGPoint(x: 100, y: 0)),
        JointInfo(position: CGPoint(x: 200, y: 0)),
        JointInfo(position: CGPoint(x: 100, y: 100)),
        JointInfo(position: CGPoint(x: 200, y: 100)),
    ], tracks: [
        TrackInfo(singleJoint: 0, multiJoint: [1]),
        TrackInfo(singleJoint: 1, multiJoint: [2, 4], jointIndex: 1),
        TrackInfo(singleJoint: 2, multiJoint: [3]),
        TrackInfo(singleJoint: 4, multiJoint: [5]),
    ], trainStartTime: [
        TrainInfo(trackIndex: 0, jointIndex: 0, goalJointIndex: 3, startTime: 1.0),
        TrainInfo(trackIndex: 3, jointIndex: 5, goalJointIndex: 0, startTime: 5.0)
    ]),
    Stage(joints: [
        JointInfo(position: CGPoint(x: -200, y: 0)),
        JointInfo(position: CGPoint(x: 0, y: 0)),
        JointInfo(position: CGPoint(x: 100, y: 0)),
        JointInfo(position: CGPoint(x: 200, y: 0)),
        JointInfo(position: CGPoint(x: 100, y: 100)),
        JointInfo(position: CGPoint(x: 200, y: 100)),
    ], tracks: [
        TrackInfo(singleJoint: 0, multiJoint: [1]),
        TrackInfo(singleJoint: 1, multiJoint: [2, 4], jointIndex: 1),
        TrackInfo(singleJoint: 2, multiJoint: [3]),
        TrackInfo(singleJoint: 4, multiJoint: [5]),
    ], trainStartTime: [
        TrainInfo(trackIndex: 0, jointIndex: 0, goalJointIndex: 3, startTime: 1.0),
        TrainInfo(trackIndex: 3, jointIndex: 5, goalJointIndex: 0, startTime: 5.0)
    ]),
    Stage(joints: [
        JointInfo(position: CGPoint(x: -200, y: 0)),
        JointInfo(position: CGPoint(x: 0, y: 0)),
        JointInfo(position: CGPoint(x: 100, y: 0)),
        JointInfo(position: CGPoint(x: 200, y: 0)),
        JointInfo(position: CGPoint(x: 100, y: 100)),
        JointInfo(position: CGPoint(x: 200, y: 100)),
    ], tracks: [
        TrackInfo(singleJoint: 0, multiJoint: [1]),
        TrackInfo(singleJoint: 1, multiJoint: [2, 4], jointIndex: 1),
        TrackInfo(singleJoint: 2, multiJoint: [3]),
        TrackInfo(singleJoint: 4, multiJoint: [5]),
    ], trainStartTime: [
        TrainInfo(trackIndex: 0, jointIndex: 0, goalJointIndex: 3, startTime: 1.0),
        TrainInfo(trackIndex: 3, jointIndex: 5, goalJointIndex: 0, startTime: 5.0)
    ]),
]
