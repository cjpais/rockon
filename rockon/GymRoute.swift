//
//  GymRoute.swift
//  rockon
//
//  Created by CJ Pais on 12/1/20.
//

import Foundation

struct GymRoute: Identifiable, Hashable, Decodable {
    static func == (lhs: GymRoute, rhs: GymRoute) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: Int?
    var gym: Gym?
    var gym_wall: GymWall?
    var gym_rope: GymRope?
    var setter: GymSetter?
    var name: String = ""
    //var date_set: Date?
    //var dateUnset: Date?
    var color: String?
    var set_grade: String?
}
