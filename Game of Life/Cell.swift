//
//  Cell.swift
//  Game of Life
//
//  Created by Jake on 10/31/15.
//  Copyright © 2015 Flat Cap. All rights reserved.
//

import Foundation

enum Vitality {
    case Alive
    case Dead
}

extension Vitality : BooleanLiteralConvertible {
    typealias BooleanLiteralType = Bool
    init(booleanLiteral value: BooleanLiteralType) {
        self = value ? .Alive : .Dead
    }
}

extension Vitality : BooleanType {
    var boolValue : Bool {
        get {
            switch self {
            case .Alive: return true
            case .Dead: return false
            }
        }
    }
}

let A : Vitality = false

protocol CellType {
    typealias HealthType
    typealias Neighbors = [Self]
    typealias State = (health: HealthType, neighbors: Neighbors, rate: Set<Int>)
    
    func birthRule(_:State) -> HealthType
    func deathRule(_:State) -> HealthType
    
    var neighbors : Neighbors { get }
    var health : HealthType { get }
    var birthRate : Set<Int> { get }
    var deathRate : Set<Int> { get }
}

struct ConwayCell : CellType {
    typealias HealthType = Vitality
    
    func birthRule(state: ConwayCell.State) -> Vitality {
        switch state.health {
        case .Alive: return .Alive
        case .Dead: return state.rate.contains(livingNeighbors(state.neighbors)) ? .Alive : .Dead
        }
    }
    
    func deathRule(state: ConwayCell.State) -> Vitality {
        let ln = livingNeighbors(state.neighbors)
        return state.rate.contains(ln) ? .Alive : .Dead
    }
    
    var neighbors : [ConwayCell] {
        willSet(newNeighbors) {
            let (rule, rate) = health == .Dead ? (birthRule, birthRate) : (deathRule, deathRate)

            health = rule((health, newNeighbors, rate))
        }
    }
    
    var health : HealthType
    let birthRate : Set<Int>
    let deathRate : Set<Int>
    
    private func livingNeighbors(neighbors: Neighbors) -> Int {
        return neighbors.filter { $0.health == Vitality.Alive }.count
    }
}

