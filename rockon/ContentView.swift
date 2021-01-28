//
//  ContentView.swift
//  rockon
//
//  Created by CJ Pais on 11/23/20.
//

import SwiftUI
import RealityKit
import ARKit
import UIKit
import Combine

struct ContentView : View {
    
    @EnvironmentObject var state: RockState
    
    var body: some View {
        GeometryReader { geo in
            ZStack() {

                Text(geo.size.debugDescription)
                ARViewContainer(status: $state.isARLocalized)

                VStack {
                    LocationInfo()
                    Something()
                    Spacer()
                }
                
                Dot()

            }.edgesIgnoringSafeArea(.all)
        }
            
    }
}

let missionGorgeRoutes: [(String, ARGeoAnchor)] = [
    ("CJ HOUSE", ARGeoAnchor(coordinate: CLLocationCoordinate2D(latitude: 32.91924848276427, longitude: -117.13945682127047))),
    ("Easy Rider", ARGeoAnchor(coordinate: CLLocationCoordinate2D(latitude: 32.82417615492066, longitude: -117.0509599662065), altitude: 181.4845558675606)),
    ("Black Rider", ARGeoAnchor(coordinate: CLLocationCoordinate2D(latitude: 32.82414944174535, longitude: -117.050960966521))),
    //("Black Rider", ARGeoAnchor(coordinate: CLLocationCoordinate2D(latitude: 32.82414944174535, longitude: -117.050960966521), altitude: 179.4071381076546)),
]

struct ARViewContainer: UIViewRepresentable {
    
    var arView: ARView = ARView(frame: .zero)
    @Binding var status: Bool
    
    var isGeoTrackingLocalized: Bool {
        if let status = arView.session.currentFrame?.geoTrackingStatus, status.state == .localized {
            return true
        }
        return false
    }
    
    func makeCoordinator() -> ARViewContainer.Coordinator {
        return Coordinator(parent: self, view: arView, callback: addBox)
    }
    
    func addGeoText() {
        
        for route in missionGorgeRoutes {
            let camera = AnchorEntity(.camera)
            arView.session.add(anchor: route.1)
            
            let anchor = AnchorEntity(anchor: route.1)
            let model = ModelEntity(mesh: MeshResource.generateText(route.0, extrusionDepth: 1.0), materials: [SimpleMaterial(color: .cyan, isMetallic: true)])
            camera.addChild(anchor)
            anchor.addChild(model)
            arView.scene.anchors.append(camera)
            
            print("added \(route.0)")
        }
    }
    
    func addBox() {
        let boxAnchor = try! Experience.loadBox()
        arView.scene.anchors.append(boxAnchor)
    }
    
    func setupGeo() {
        ARGeoTrackingConfiguration.checkAvailability { (available, error) in
            if !available {
                let errorDescription = error?.localizedDescription ?? ""
                let recommendation = "Please try again in an area where geo tracking is supported."
                print("Geo tracking unavailable \(errorDescription)\n\(recommendation)")
            }
        }
        
        let geoTrackingConfig = ARGeoTrackingConfiguration()
        geoTrackingConfig.planeDetection = [.horizontal]
        arView.session.run(geoTrackingConfig)
    }
    
    func addGeoBox() {
        let boxAnchor = try! Experience.loadBox()
        arView.session.add(anchor: missionGorgeRoutes[0].1)
        
        let boxEntity = AnchorEntity(anchor: missionGorgeRoutes[0].1)
        boxEntity.children.append(boxAnchor)
        arView.scene.anchors.append(boxEntity)
    }
    
    func makeUIView(context: Context) -> ARView {
        
        setupGeo()
        
        let gesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapped))
        arView.addGestureRecognizer(gesture)
        
        arView.session.delegate = context.coordinator
        
        return arView
        
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        
        var parent: ARViewContainer
        var arView: ARView
        var tappedCallback: (() -> Void)
        
        private var processing: Bool = false
        private var qrRequests = [VNRequest]()
        private var detectedDataAnchor: ARAnchor?
        private var latestFrame: ARFrame?
        
        private var addedBox: Bool = false
        
        private var qr: DetectedQRCode?
        
        func startQrCodeDetection() {
           // Create a Barcode Detection Request
           let request = VNDetectBarcodesRequest(completionHandler: self.requestHandler)
           // Set it to recognize QR code only
           request.symbologies = [.QR]
           self.qrRequests = [request]
       }
        
        init(parent: ARViewContainer, view: ARView, callback: @escaping (() -> Void)) {
            
            self.parent = parent
            self.arView = view
            self.tappedCallback = callback
            super.init()
            self.startQrCodeDetection()
        }
        
        @objc func tapped(gesture: UITapGestureRecognizer) {
            print(gesture)
            self.tappedCallback()
        }
        
        func getAccuracyString(_ accuracy: ARGeoTrackingStatus.Accuracy) -> String {
            switch accuracy {
            case .high:
                return("high")
            case .medium:
                return("medium")
            case .low:
                return("low")
            default:
                return "undetermined"
            }
        }
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            self.latestFrame = frame
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    if self.processing {
                      return
                    }
                    self.processing = true
                    // Create a request handler using the captured image from the ARFrame
                    let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage,
                                                                    options: [:])
                    // Process the request
                    try imageRequestHandler.perform(self.qrRequests)
                } catch {
                    print(error)
                }
            }
        }
        
        func requestHandler(request: VNRequest, error: Error?) {
            // Get the first result out of the results, if there are any
            if let results = request.results, let result = results.first as? VNBarcodeObservation {
                if results.count > 1 {
                    print("MULTIPLE RESULTS:", results)
                }
                guard let payload = result.payloadStringValue else {return}
                //print(payload)
                // Get the bounding box for the bar code and find the center
                var rect = result.boundingBox
                // Flip coordinates
                rect = rect.applying(CGAffineTransform(scaleX: 1, y: -1))
                rect = rect.applying(CGAffineTransform(translationX: 0, y: 1))
                // Get center
                let center = CGPoint(x: rect.midX, y: rect.midY)

                DispatchQueue.main.async {
                    //print(center)
                    
                    if self.qr == nil || self.qr!.url.description != payload {
                        let req = URLRequest(url: URL(string: payload)!)
                        
                        let decoder = JSONDecoder()
                        
    //                    URLSession.shared.dataTaskPublisher(for: req)
    //                        .map { $0.data }
    //                        .decode(type: GymRouteResponse.self, decoder: decoder)
    //                        .map { $0.gym_route }
    //                        .receive(on: RunLoop.main)
    //                        .catch({ (error) -> Just<[GymRoute]> in
    //                            print(error)
    //                            return Just([])
    //                        })
    //                        .sink(receiveValue: { routes in
    //                            print(routes)
    //                        })
                        //print(req)
                        let task = URLSession.shared.dataTask(with: req) { data, response, error in
                            //print("pass")
                            let routes = try! decoder.decode(GymRouteResponse.self, from: data!)
                            print(routes)
                            self.qr = DetectedQRCode(url: req.url!, route: routes.gym_route.first!, point: center)
                            
                            let not2 = Notification(name: .init(rawValue: "CJDATA"), object: self.qr!)
                            NotificationCenter.default.post(not2)
                        }
    //
                        task.resume()
                        
                        
                    }

                        let not = Notification(name: .init(rawValue: "CJPOINT"), object: center)
                        
                        NotificationCenter.default.post(not)
                        
                    
                    
//                    let hitResults = self.arView.raycast(from: center, allowing: .estimatedPlane, alignment: .any)
//                    if let hitResult = hitResults.first {
//                        if !self.addedBox {
//                            let anchor = ARAnchor(transform: hitResult.worldTransform)
//                            self.arView.session.add(anchor: anchor)
//                            let boxEntity = AnchorEntity(anchor: anchor)
//                            let boxAnchor = try! Experience.loadBox()
//                            boxEntity.children.append(boxAnchor)
//                            self.arView.scene.anchors.append(boxEntity)
//                            self.addedBox = true
//                        }
//                    } else {
//                        print("raycast fail", self.addedBox)
//                    }
                    
                    self.processing = false
                }
            } else {
                self.processing = false
            }
        }
        
        func session(_ session: ARSession, didChange geoTrackingStatus: ARGeoTrackingStatus) {
            var text = ""

            // In localized state, show geo tracking accuracy
            if geoTrackingStatus.state == .localized {
                text += "Available, Accuracy: \(getAccuracyString(geoTrackingStatus.accuracy))"
                //parent.addBox()\
                if addedBox == false {
                    print("ADDED GEO TEXT")
                    parent.addGeoText()
                    addedBox = true
                }
                
                

            } else {
                // Otherwise show details why geo tracking couldn't localize (yet)
                //parent.status = false
                switch geoTrackingStatus.stateReason {
                case .none:
                    break
                case .worldTrackingUnstable:
                    let arTrackingState = session.currentFrame?.camera.trackingState
                    if case let .limited(arTrackingStateReason) = arTrackingState {
                        text += "unavail"
                    } else {
                        fallthrough
                    }
                default: text += "unavail"
                }
            }
            
            let not = Notification(name: .init(rawValue: "CJCUSTOM"), object: text)
            NotificationCenter.default.post(not)
        }
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
