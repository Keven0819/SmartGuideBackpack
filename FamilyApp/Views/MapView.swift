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
    
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            
            let identifier = "CustomPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKAnnotationView
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                
                // 自訂標註圖示，可用SF Symbol Image
                let pinImage = UIImage(systemName: "location.fill")?
                    .withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
                annotationView?.image = pinImage
                
                // 加光暈效果的UIView
                let glowView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                glowView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.3)
                glowView.layer.cornerRadius = 25
                glowView.layer.shadowColor = UIColor.systemBlue.cgColor
                glowView.layer.shadowRadius = 10
                glowView.layer.shadowOpacity = 0.8
                glowView.layer.shadowOffset = .zero
                glowView.isUserInteractionEnabled = false
                
                annotationView?.addSubview(glowView)
                glowView.center = CGPoint(x: annotationView!.bounds.midX, y: annotationView!.bounds.midY)
                glowView.layer.add(pulseAnimation(), forKey: "pulse")
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }
        
        func pulseAnimation() -> CABasicAnimation {
            let animation = CABasicAnimation(keyPath: "shadowRadius")
            animation.fromValue = 5
            animation.toValue = 15
            animation.duration = 1.5
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.autoreverses = true
            animation.repeatCount = .infinity
            return animation
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        mapView.mapType = .hybrid
        
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.pointOfInterestFilter = .includingAll
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations.filter { !($0 is MKUserLocation) })
        uiView.removeOverlays(uiView.overlays)
        
        if let coord = targetCoordinate {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coord
            annotation.title = "目標位置"
            uiView.addAnnotation(annotation)
            
            // 加圓形覆蓋顯示附近範圍 (半徑1000米)
            let circle = MKCircle(center: coord, radius: 1000)
            uiView.addOverlay(circle)
            
            let region = MKCoordinateRegion(center: coord, latitudinalMeters: 2000, longitudinalMeters: 2000)
            uiView.setRegion(region, animated: true)
        }
    }
}

// 同步覆蓋物樣式
extension MapView.Coordinator {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circleOverlay = overlay as? MKCircle {
            let renderer = MKCircleRenderer(circle: circleOverlay)
            renderer.fillColor = UIColor.systemBlue.withAlphaComponent(0.2)
            renderer.strokeColor = UIColor.systemBlue.withAlphaComponent(0.7)
            renderer.lineWidth = 2
            return renderer
        }
        return MKOverlayRenderer()
    }
}
