import SwiftUI
import StoreKit
struct SettingsView: View {
    @AppStorage("swipeSensitivity") var swipeSensitivity: Double = 20.0
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    
    var body: some View {
        
        VStack{
            
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Form {
                Section(header: Text("Swipe Sensitivity")) {
                    HStack {
                        Slider(value: $swipeSensitivity, in: 10...100, step: 1)
                        Text("\(Int(swipeSensitivity))")
                            .frame(width: 40, alignment: .trailing)
                    }
                }
                
                Section(header: Text("Support")) {
                    
                    Button("Leave a Review") {
                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            SKStoreReviewController.requestReview(in: scene)
                        }
                    }
                    
                    Button("Visit Website") {
                        if let websiteURL = URL(string: "https://pulcer.net/") {
                            UIApplication.shared.open(websiteURL)
                        }
                    }
                    
                    Button("Contact Me") {
                        if let emailURL = URL(string: "mailto:anthony@pulcer.net") {
                            if UIApplication.shared.canOpenURL(emailURL) {
                                UIApplication.shared.open(emailURL)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            HStack {
                
                Button(action: {
                    navigationViewModel.currentScreen = .settings
                }) {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 26, weight: .bold))
                }.padding()
                    .opacity(0)
                
                Button(action: {
                    
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.blue)
                        .padding()
                }.opacity(0)
                
                Button(action: {
                    navigationViewModel.currentScreen = .performance
                }) {
                    Image(systemName: "chevron.forward")
                        .font(.system(size: 26, weight: .bold))
                }.padding()
                
            }
        } .gesture(DragGesture(minimumDistance: swipeSensitivity, coordinateSpace: .local)
            .onEnded { value in
                if value.translation.width < 0 {
                    navigationViewModel.currentScreen = .performance
                }
            })
    }
}

