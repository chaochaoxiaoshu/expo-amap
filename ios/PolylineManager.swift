import MAMapKit

class PolylineManager {
    private weak var mapView: MAMapView?
    private var polylines: [MAPolyline] = []
    private var styles: [String: PolylineStyle] = [:]

    init(mapView: MAMapView) {
        self.mapView = mapView
    }

    func setPolylines(_ polylines: [Polyline]) {
        guard let mapView = mapView else { return }

        self.polylines.removeAll()
        mapView.removeOverlays(polylines)
        styles.removeAll()

        for (index, item) in polylines.enumerated() {
            var coordsArray = item.coordinates.map {
                CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
            }

            let polyline: MAPolyline = MAPolyline(
                coordinates: &coordsArray, count: UInt(coordsArray.count))
            let polylineId = "polyline-\(index)"
            polyline.title = polylineId
            
            self.polylines.append(polyline)
            styles[polylineId] = item.style
            mapView.add(polyline)
        }
        
        print("设置好的 polylines 条数：\(mapView.overlays.count)")
    }

    func styleForPolyline(_ polyline: MAPolyline) -> PolylineStyle? {
        return styles[polyline.title ?? ""]
    }
}
