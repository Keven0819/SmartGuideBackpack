//
//  MapView.swift
//  SmartGuideBackpack
//
//  Created by imac-3570 on 2025/10/9.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var targetCoordinate: CLLocationCoordinate2D?
    
    func makeUIView(context: Context) -> MKMapView {
        MKMapView()
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        if let coord = targetCoordinate {
            let anno = MKPointAnnotation()
            anno.coordinate = coord
            uiView.addAnnotation(anno)
            uiView.setCenter(coord, animated: true)
        }
    }
}
