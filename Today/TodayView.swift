import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @Query private var toDoListItems: [ToDoListItem]
    @State private var newToDoText = ""
    @State private var showingAddToDo = false

    var body: some View {
        VStack {
            Text("Today")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            List {
                ForEach(toDoListItems) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.toDoListText)
                        }
                        Spacer()

                        Button(action: {
                            item.isCompleted.toggle()
                        }) {
                            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            Spacer()
            
            HStack {
                
                Button(action: {
                }) {
                    Image(systemName: "chevron.backward")
                }.padding()
                
                Button(action: {
                    self.showingAddToDo = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.blue)
                        .padding()
                }
            
                Button(action: {
                                   navigationViewModel.currentScreen = .tomorrow
                               }) {
                                   Image(systemName: "chevron.forward")
                               }.padding()
            }
            
        }.sheet(isPresented: $showingAddToDo) {
            
            VStack {
                TextField("Enter new task", text: $newToDoText)
                
                Spacer()
                
                HStack{
                    
                    Button("Discard") {
                                  newToDoText = ""
                                  self.showingAddToDo = false
                              }
                              .foregroundColor(.gray)
                              .font(.title3)

                              Spacer()
                    
                    Button("Save") {
                        addItem()
                        self.showingAddToDo = false
                    }
                    .foregroundColor(.gray)
                    .font(.title3)
                    
                }.padding(.vertical)
             
            }
            .padding()
            .presentationDetents([.height(100)])
        }
        
    }
    
    private func addItem() {
           withAnimation {
               let newItem = ToDoListItem(timestamp: Date(), toDoListText: newToDoText, isCompleted: false)
               modelContext.insert(newItem)
               newToDoText = "" // Reset the text field after adding
           }
       }

       private func deleteItems(offsets: IndexSet) {
           withAnimation {
               for index in offsets {
                   modelContext.delete(toDoListItems[index])
               }
           }
       }
}
