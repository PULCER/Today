import SwiftUI
import SwiftData

struct RecurringView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @AppStorage("swipeSensitivity") private var swipeSensitivity: Double = 20.0
    
    
    var body: some View {
        VStack {
            Text("Recurring")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer()
            
            VStack {
                
    
                HStack {
                    
                    Button(action: {
                        navigationViewModel.currentScreen = .today
                    }) {
                        Image(systemName: "chevron.down")
                    }.padding()
                    
                    Button(action: {
                //        self.showingAddToDo = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 48, height: 48)
                            .foregroundColor(.blue)
                            .padding()
                    }
                    
                    Button(action: {
                        navigationViewModel.currentScreen = .today
                    }) {
                        Image(systemName: "chevron.down")
                    }.padding()
                }
            }
        }
    }
}


