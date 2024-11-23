import SwiftUI
import MapKit
import Alamofire

enum DisplayMode {
    case main
    case detail
}


struct MapView: View {
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)// 카메라 시점 설정
    @EnvironmentObject var userManager: UserManager
    @State private var locationManager = LocationManager.shared
    
    @State private var query: String = ""

    @State private var mapItems :[Item] = []
    @State private var selectedMemoId: Int?
    @State private var isMyInfo: Bool = false
    @State private var displayMode: DisplayMode = .main
    
    @State private var locationData: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0) // 기본값 설정
    
    private func matching() async {
        do {
            mapItems = try await MemoMatching(location: locationData, accessToken: userManager.accessToken)
            //print(mapItems)
        } catch {
            mapItems = []
            print(error.localizedDescription)
        }
    }
    
    private func categoryImage(for category: String) -> String {
        switch category {
        case "공용 화장실":
            return "toilet.fill"
        case "쓰레기통":
            return "trash.fill"
        case "흡연장":
            return "smoke.fill"
        default:
            return "mappin"
        }
    }
    
    private func categoryColor(for category: String) -> Color {
        switch category {
        case "공용 화장실":
            return .blue
        case "쓰레기통":
            return .red
        case "흡연장":
            return .gray
        default:
            return .yellow
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $position, selection: $selectedMemoId) {
                ForEach(mapItems, id: \.self) { mapItem in
                    Marker(mapItem.title,systemImage: categoryImage(for: mapItem.category) , coordinate: mapItem.location)
                        .tint(categoryColor(for: mapItem.category))
                        .tag(mapItem.id)
                }
                UserAnnotation() // 내 위치 표현
            }
            .sheet(isPresented: .constant(true), content: {
                VStack{
                    switch displayMode {
                    case .main:
                        SearchBarView(query: $query, isMyInfo: $isMyInfo)
                    case .detail:
                        MemoDetailView(id: $selectedMemoId)
                    }
                }
                .presentationDetents([.fraction(0.15), .medium, .large])
                .presentationDragIndicator(.visible) // 드래그할 수 있는게 표시된다.
                .interactiveDismissDisabled() // 사용자가 직업 없애는걸 막아준다.
                .presentationBackgroundInteraction(.enabled(upThrough: .medium)) // 중간 위로부터는 시트 뒤에 있는 배경과 상호작용이 가능해진다.
            })
            .onChange(of: locationManager.region, { oldValue, newValue in
                position = .region(locationManager.region) // 내 위치가 바뀌면 지도 시선 위치를 변경해준다.
                if let location = position.region?.center {
                    locationData = location
                    Task {
                        await matching()
                    }
                }
            })
            .mapControls({
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            })
        }
        .onChange(of: selectedMemoId, { oldValue, newValue in
            if selectedMemoId != nil {
                displayMode = .detail
            } else {
                displayMode = .main
            }
        })
        .onAppear {
            print(UserManager().accessToken)
            print(UserManager().isLoggedIn)
            if userManager.isLoggedIn && userManager.userInfo == nil {
                userManager.fetchUserInfo()
            }
        }
    }
}


extension MKCoordinateRegion: @retroactive Equatable {
    
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        if lhs.center.latitude == rhs.center.latitude && lhs.span.latitudeDelta == rhs.span.latitudeDelta && lhs.span.longitudeDelta == rhs.span.longitudeDelta {
            return true
        } else {
            return false
        }
    }
}

#Preview {
    MapView()
        .environmentObject(UserManager())
}

