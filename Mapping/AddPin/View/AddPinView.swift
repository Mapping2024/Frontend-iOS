import SwiftUI

struct AddPinView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var update: Bool

    @StateObject private var viewModel = AddPinViewModel()
    @State private var backFlag: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                CustomMapView(
                    mapView: $viewModel.mapView,
                    region: $viewModel.region,
                    pinCoordinate: $viewModel.pinCoordinate,
                    isPinActive: $viewModel.isPinActive
                )
                .edgesIgnoringSafeArea(.bottom)

                VStack {
                    Spacer()
                    if let coordinate = viewModel.pinCoordinate {
//                        Text("Latitude: \(coordinate.latitude), Longitude: \(coordinate.longitude)")
//                            .padding()
//                            .background(Color.cWhite.opacity(0.8))
//                            .cornerRadius(8)
//                            .padding()
                    } else {
                        Text("지도를 길게 눌러 핀을 생성하세요.")
                            .padding()
                            .background(Color.cWhite.opacity(0.8))
                            .cornerRadius(8)
                            .padding()
                    }
                }
            }
        }
        .navigationBarTitle(Text("핀 생성"), displayMode: .inline)
        .navigationBarItems(
            trailing: Group {
                if let coordinate = viewModel.pinCoordinate {
                    NavigationLink(
                        destination: AddPinDetailView(
                            backFlag: $backFlag,
                            latitude: coordinate.latitude,
                            longitude: coordinate.longitude,
                            currentLocation: viewModel.region.center
                        )
                        .onDisappear {
                            viewModel.removePin()
                            if backFlag {
                                update = true
                                dismiss()
                            }
                        }
                    ) {
                        Image(systemName: "plus")
                    }
                } else {
                    Image(systemName: "plus")
                        .disabled(true)
                }
            }
        )
    }
}


#Preview {
    AddPinView(update: .constant(false))
}
