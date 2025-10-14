//
//  LocationService.swift
//  SmartGuideBackpack
//
//  Created by imac-3570 on 2025/10/9.
//

import CoreLocation
import Combine

public class LocationService: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    // MARK: -- 單例模式
    
    public static let shared = LocationService()
    private let manager = CLLocationManager()

    // MARK: -- Published 屬性
    
    @Published public var coordinate: CLLocationCoordinate2D?
    @Published public var heading: CLHeading?
    @Published public var address: String?  // 新增存放中文地址

    // MARK: -- 初始化
    
    private override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        manager.startUpdatingHeading()
    }

    // MARK: -- CLLocationManagerDelegate 方法
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        coordinate = locations.last?.coordinate
        if let coordinate = coordinate {
            getAddressFromCoordinate(coordinate) { [weak self] address in
                DispatchQueue.main.async {
                    self?.address = address
                }
            }
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading
    }

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            manager.startUpdatingHeading()
        case .denied, .notDetermined, .restricted:
            // 權限不足的邏輯
            break
        @unknown default:
            break
        }
    }

    // MARK: -- 地理編碼方法
    
    // 反向地理編碼方法
    public func getAddressFromCoordinate(_ coordinate: CLLocationCoordinate2D, completion: @escaping (String?) -> Void) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("反向地理編碼失敗: \(error.localizedDescription)")
                completion(nil)
                return
            }
            if let placemark = placemarks?.first {
                let address = [
                    placemark.country,
                    placemark.administrativeArea,
                    placemark.locality,
                    placemark.thoroughfare,
                    placemark.subThoroughfare
                ].compactMap { $0 }.joined(separator: " ")
                completion(address)
            } else {
                completion(nil)
            }
        }
    }
}
