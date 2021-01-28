//
//  GymSetter.swift
//  rockon
//
//  Created by CJ Pais on 12/1/20.
//

import Foundation

struct GymSetter: Identifiable, Hashable, Decodable {
    var id: Int?
    var climberId: Int?
    var name: String = ""
}
