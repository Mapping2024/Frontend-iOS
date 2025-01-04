import MapKit

struct Item: Identifiable, Hashable, Equatable {
    let id: Int
    let title: String
    let category: String
    let location: CLLocationCoordinate2D
    let secret: Bool
    
    static func == (lhs: Item, rhs: Item) -> Bool {
            return lhs.id == rhs.id &&
                   lhs.title == rhs.title &&
                   lhs.category == rhs.category &&
                   lhs.location.latitude == rhs.location.latitude &&
                   lhs.location.longitude == rhs.location.longitude &&
                   lhs.secret == rhs.secret
        }
    func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(title)
            hasher.combine(category)
            hasher.combine(location.latitude)
            hasher.combine(location.longitude)
            hasher.combine(secret)
        }
}
