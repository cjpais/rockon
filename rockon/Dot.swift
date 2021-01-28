//
//  Dot.swift
//  rockon
//
//  Created by CJ Pais on 12/1/20.
//

import SwiftUI

struct Dot: View {
    @State var qr: DetectedQRCode?
    @State var point: CGPoint?
    
    @State private var timer: Timer?
    private var display: Bool = false
    
    var body: some View {
        ZStack {
            if (qr != nil) {
                VStack {
                    Text(qr!.route.name)
                    Text(qr!.route.set_grade!)
                }
                .background(Color(UIColor.systemGray6))
                .position(x: 320 * (1-(point?.y ?? 0.5)), y: 460 * (point?.x ?? 0.5))
            }
        }

//        Circle()
//            .frame(width: 5, height: 5)
//            .foregroundColor(.red)

        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.init(rawValue: "CJDATA")), perform: { state in
            self.qr = state.object as! DetectedQRCode
        })
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.init(rawValue: "CJPOINT")), perform: { state in
            self.point = state.object as! CGPoint
            if self.timer != nil {
                self.timer?.invalidate()
            }
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                self.point = nil
            }
        })

    }
}

struct Dot_Previews: PreviewProvider {
    static var previews: some View {
        Dot()
    }
}
