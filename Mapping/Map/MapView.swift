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
    @State private var visibleRegion: CLLocationCoordinate2D? // 카메라 시점
    @State var update: Bool = false
    @State var category: String = "전체"
    @State private var selectedDetent: PresentationDetent = .small
    
    @State private var mapItems: [Item] = []
    @State private var filteredMapItems: [Item] = [] // 필터링된 데이터를 저장할 변수
    @State private var selectedMemoId: Int?
    @State private var isPinAdd: Bool = false
    @State private var displayMode: DisplayMode = .main
    
    @State private var locationData: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0) // 기본값 설정
    
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
                Group {
                    switch displayMode {
                    case .main:
                        SearchBarView(update: $update, selectedMemoId: $selectedMemoId, item: $mapItems)
                        CategoryView(category: $category, isPinAdd: $isPinAdd, update: $update)
                    case .detail:
                        MemoDetailView(id: $selectedMemoId, size: $selectedDetent)
                    }
                }
                .presentationDetents([.small, .medium, .large], selection: $selectedDetent)
                .presentationDragIndicator(.visible)
                .padding(.vertical)
                .interactiveDismissDisabled()
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            })
            .onChange(of: locationManager.region, { oldValue, newValue in
                position = .region(locationManager.region)
                if let location = position.region?.center {
                    locationData = location //현재 위치를 저장 나중에 보낼 수 있음
                }
            })
            .mapControls({
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            })
        }
        .onChange(of: selectedMemoId, { oldValue, newValue in
            // `selectedMemoId` 변경 시 지도 중심 업데이트
            if let id = selectedMemoId,
               let selectedItem = mapItems.first(where: { $0.id == id }) {
                let adjustedCenter = CLLocationCoordinate2D(
                            latitude: selectedItem.location.latitude - 0.002,
                            longitude: selectedItem.location.longitude
                        )
                        position = .region(MKCoordinateRegion(center: adjustedCenter, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
                        displayMode = .detail // 상세 모드로 전환
            } else {
                displayMode = .main
            }
        })
        .onChange(of: update, { oldValue, newValue in // 핀 추가후 지도 업데이트
            if update {
                Task {
                    await matching()
                }
                update = false
            }
        })
        .onChange(of: category, { oldValue, newValue in // 카테고리 변경시 지도 업데이트
            applyFilter() // 카테고리가 변경될 때 필터링 적용
        })
        .onAppear {
            if userManager.isLoggedIn && userManager.userInfo == nil {
                userManager.fetchUserInfo()
                print(userManager.accessToken)
            }
            Task {
                await matching()
            }
        }
        .onMapCameraChange { context in
            visibleRegion = context.region.center // 내 위치가 바뀌면 지도 시선 위치를 변경
            Task {
                await matching()
            }
        }
    }
    
    private func matching() async {
        
        do {
            mapItems = try await MemoMatching(location: visibleRegion!, accessToken: userManager.accessToken)
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
        } else if(category == "개인") {
            filteredMapItems = mapItems.filter{ $0.secret == true}
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
        case "붕어빵":
            return "fish.fill"
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
        case "붕어빵":
            return .orange
        default:
            return .yellow
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

extension PresentationDetent {
    static let small = Self.fraction(0.19)
}

#Preview {
    MapView()
        .environmentObject(UserManager())
}
