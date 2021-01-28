//
//  GymRope.swift
//  rockon
//
//  Created by CJ Pais on 12/1/20.
//

import Foundation

struct GymRope: Identifiable, Hashable, Decodable {
    var id: Int?
    var gymId: Int?
    var wallId: Int?
    var name: String = ""
    var last_replaced: Date?
}
