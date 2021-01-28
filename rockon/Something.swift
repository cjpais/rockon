//
//  Something.swift
//  rockon
//
//  Created by CJ Pais on 11/23/20.
//

import SwiftUI

struct Something: View {
    
    @State var arLocalized: String = "INITIALIZING"
    @State var point: CGPoint?
    
    var body: some View {
        VStack {
            Text(arLocalized)
            //Text("\(point?.debugDescription ?? "no point")")
        }.onReceive(NotificationCenter.default.publisher(for: Notification.Name.init(rawValue: "CJCUSTOM")), perform: { state in
            self.arLocalized = state.object as! String
        })
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.init(rawValue: "CJPOINT")), perform: { state in
            self.point = state.object as! CGPoint
        })
        
    }
}

struct Something_Previews: PreviewProvider {
    static var previews: some View {
        Something()
    }
}
