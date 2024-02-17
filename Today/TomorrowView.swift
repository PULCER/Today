import SwiftUI

struct TomorrowView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    
    var body: some View {
        VStack{
            
            Text("Tomorrow")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
    }
}
