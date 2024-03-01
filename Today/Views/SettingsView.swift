import SwiftUI
import StoreKit

struct SettingsView: View {
    @AppStorage("swipeSensitivity") var swipeSensitivity: Double = 20.0
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @State private var showingGuide = false
    
    var body: some View {
        VStack {
            VStack {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .gesture(DragGesture(minimumDistance: swipeSensitivity, coordinateSpace: .local)
                .onEnded { value in
                    if value.translation.width < 0 {
                        navigationViewModel.currentScreen = .performance
                    }
                })
            
            Form {
                Section(header: Text("Swipe Sensitivity").font(.headline)) {
                    HStack {
                        Text("Low")
                        Spacer()
                        Slider(value: $swipeSensitivity, in: 10...100)
                        Spacer()
                        Text("High")
                    }
                    Text("Page titles are left and right swipeable")
                }
                
                Section(header: Text("Support")) {
                    Button("Quick Start Guide") {
                        showingGuide = true
                    }
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
                
                Button(action: {}) {
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
        }
        .sheet(isPresented: $showingGuide) {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Welcome to Today")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Get. More. Done.")
                            .font(.headline)
                            .padding(.top)
                        
                        Text("""
                            Our app is designed to help you focus on what you need to get done Today while also planning for the future. Every day, you're presented with a custom itinerary of tasks. There are three types of tasks to help you manage your time effectively:
                            
                            - **Regular Tasks**: These are time-based tasks that appear in your Today and Tomorrow views and then move to the Performance view at midnight. They are manually entered and focus on immediate action. At midnight, any task you entered in Tomorrow, will show up on Today and any task entered on Today will move to the performance view where it will be recorded if it was completed or not. A performance indicator is displayed for readability. You can also complete tasks on this view if you forgot to make something complete from the previous days.
                            
                            - **Timeless Tasks**: These tasks have no time requirements or performance monitoring. They serve as a general to-do list for items that aren't time-sensitive.
                            
                            - **Recurring Tasks**: For tasks that occur on a regular basis, you can set a time interval for completion. These tasks will only reappear in your Today view at the start of a new interval or if they are marked as incomplete. They're highlighted in gold when completed and in red if there's a risk of not completing them within the current interval.
                            
                            - **Future Tasks**: If you go to the tomorrow screen and enter a date before your task it will be saved automatically and show up in the Today view when it's time to be completed. For instance "04/15/2025 do taxes" will attach that date to the task of "do taxes"
                            
                            This system allows you to focus on the present while keeping an eye on future obligations, ensuring you're always one step ahead.
                            """)
                        .padding(.vertical)
                    }
                    .padding()
                    .navigationBarTitle(Text("Quick Start Guide"), displayMode: .inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingGuide = false
                            }
                        }
                    }
                }
            }
        }
    }
}
