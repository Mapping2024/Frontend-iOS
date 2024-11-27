import SwiftUI
import MapKit
import Alamofire

enum DisplayMode {
    case main
    case detail
}

struct MapView: View {
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic) // 카메라 시점 설정
    @EnvironmentObject var userManager: UserManager
    @State private var locationManager = LocationManager.shared
    @State var update: Bool = false
    @State var category: String = "전체"
    
    @State private var query: String = ""
    @State private var mapItems: [Item] = []
    @State private var filteredMapItems: [Item] = [] // 필터링된 데이터를 저장할 변수
    @State private var selectedMemoId: Int?
    @State private var isMyInfo: Bool = false
    @State private var isPinAdd: Bool = false
    @State private var displayMode: DisplayMode = .main
    
    @State private var locationData: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0) // 기본값 설정
    
    private func matching() async {
        do {
            mapItems = try await MemoMatching(location: locationData, accessToken: userManager.accessToken)
            applyFilter() // 필터 적용
        } catch {
            mapItems = []
            filteredMapItems = []
            print(error.localizedDescription)
        }
    }
    
    private func applyFilter() {
        if category == "전체" {
            filteredMapItems = mapItems
        } else {
            filteredMapItems = mapItems.filter { $0.category == category }
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
            return "star.fill"
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
                ForEach(filteredMapItems, id: \.self) { mapItem in // 필터링된 데이터를 사용
                    Marker(mapItem.title, systemImage: categoryImage(for: mapItem.category), coordinate: mapItem.location)
                        .tint(categoryColor(for: mapItem.category))
                        .tag(mapItem.id)
                }
                UserAnnotation() // 내 위치 표현
            }
            .sheet(isPresented: .constant(true), content: {
                VStack {
                    switch displayMode {
                    case .main:
                        SearchBarView(query: $query, isMyInfo: $isMyInfo, category: $category)
                        if userManager.isLoggedIn && userManager.userInfo != nil {
                            PinAddButton(isPinAdd: $isPinAdd, update: $update)
                        }
                    case .detail:
                        MemoDetailView(id: $selectedMemoId)
                    }
                }
                .presentationDetents([.fraction(0.15), .medium, .large])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled()
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            })
            .onChange(of: locationManager.region, { oldValue, newValue in
                position = .region(locationManager.region) // 내 위치가 바뀌면 지도 시선 위치를 변경
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
            displayMode = (selectedMemoId != nil) ? .detail : .main
        })
        .onChange(of: update, { oldValue, newValue in
            if update {
                Task {
                    await matching()
                }
                update = false
            }
        })
        .onChange(of: category, { oldValue, newValue in
            applyFilter() // 카테고리가 변경될 때 필터링 적용
        })
        .onAppear {
            if userManager.isLoggedIn && userManager.userInfo == nil {
                userManager.fetchUserInfo()
                print(userManager.accessToken)
                print(userManager.refreshToken)
            }
        }
    }
}

extension MKCoordinateRegion: @retroactive Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        lhs.center.latitude == rhs.center.latitude &&
        lhs.span.latitudeDelta == rhs.span.latitudeDelta &&
        lhs.span.longitudeDelta == rhs.span.longitudeDelta
    }
}

#Preview {
    MapView()
        .environmentObject(UserManager())
}
