//
//  PastView.swift
//  Today
//
//  Created by Anthony Howell on 2/18/24.
//

import SwiftUI

struct PerformanceView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    
    var body: some View {
        VStack {
            Text("Performance")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer()
            
            HStack {
                
                Button(action: {
                    navigationViewModel.currentScreen = .today
                }) {
                    Image(systemName: "chevron.backward")
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
                    navigationViewModel.currentScreen = .today
                }) {
                    Image(systemName: "chevron.forward")
                }.padding()
            
            }
            
        }
    }
}
