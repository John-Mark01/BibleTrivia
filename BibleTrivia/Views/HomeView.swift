//
//  HomeView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 8.10.24.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Text("Welcome, Chris!")
                        .modifier(CustomText(size: 24, font: .title))
                    Spacer()
                }
                HStack {
                    Button(action: {
                        
                    }) {
                        Rectangle()
                            .frame(width: 210, height: 70)
                            .cornerRadius(16)
                            .foregroundStyle(Color.BTPrimary)
                            .overlay(
                                HStack {
                                    Image(systemName: "star.fill")
                                        .resizable()
                                        .frame(width: 34, height: 34)
                                        .foregroundStyle(Color.yellow)
                                        .padding(.trailing, 4)
                                    Text("Score:")
                                        .font(Font.custom("Rubik", size: 24))
                                        .foregroundStyle(Color.white)
                                        .bold()
                                    Text("328")
                                        .font(Font.custom("Rubik", size: 24))
                                        .foregroundStyle(Color.white)
                                }
                                
                            )
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, Constants.hPadding)
            .padding(.vertical, Constants.vPadding)
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.BTBackground)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        
                    }) {
                        Image(systemName: "line.3.horizontal")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        
                    }) {
                        Circle()
                            .frame(width: 32, height: 32)
                            .background(
                                Image("profile_pic")
                                    .resizable()
                                    .scaledToFit()
                            )
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
