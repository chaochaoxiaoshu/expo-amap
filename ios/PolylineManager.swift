import MAMapKit

class PolylineManager {
    private weak var mapView: MAMapView?
    var polylines: [MAPolyline] = []
    private var styles: [String: PolylineStyle] = [:]

    init(mapView: MAMapView) {
        self.mapView = mapView
    }

    func setPolylines(_ polylines: [Polyline]) {
        guard let mapView = mapView else { return }

        mapView.removeOverlays(self.polylines)
        self.polylines.removeAll()
        styles.removeAll()

        for (index, item) in polylines.enumerated() {
            var coordsArray = item.coordinates.map {
                CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
            }

            let polyline: MAPolyline = MAPolyline(
                coordinates: &coordsArray, count: UInt(coordsArray.count))
            polyline.title = item.id

            self.polylines.append(polyline)
            styles[item.id] = item.style
            mapView.add(polyline)
        }
    }

    func styleForPolyline(_ polyline: MAPolyline) -> PolylineStyle? {
        return styles[polyline.title ?? ""]
    }
}
