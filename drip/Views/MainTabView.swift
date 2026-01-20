//
//  MainTabView.swift
//  drip
//

import SwiftData
import SwiftUI

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: DripTab = .home
    @State private var isMenuExpanded = false
    @State private var showAddClothing = false
    @State private var showOutfitBuilder = false

    enum DripTab {
        case home
        case closet
        

        var title: String {
            switch self {
            case .home: return "Home"
            case .closet: return "Closet"
            
            }
        }

        var image: String {
            switch self {
            case .home: return "house"
            case .closet: return "cabinet"
            
            }
        }
    }

    @TabContentBuilder<DripTab>
    private var tabs: some TabContent<DripTab> {
        homeTab
        closetTab
    }

    private var homeTab: some TabContent<DripTab> {
        Tab(DripTab.home.title, systemImage: DripTab.home.image, value: .home) {
            HomeView()
        }
    }

    private var closetTab: some TabContent<DripTab> {
        Tab(DripTab.closet.title, systemImage: DripTab.closet.image, value: .closet) {
            ClosetView()
        }
    }
    

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                tabs
            }

            FloatingActionButton(
                isMenuExpanded: $isMenuExpanded,
                onAddClothes: { showAddClothing = true },
                onBuildOutfit: { showOutfitBuilder = true }
            )
            .padding(.bottom, 2)

            if isMenuExpanded {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.snappy(duration: Constants.Animation.snappyDuration)) {
                            isMenuExpanded = false
                        }
                    }
                    .zIndex(-1)
            }
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            
        }
        .sheet(isPresented: $showAddClothing) {
            AddClothingView()
        }
        .fullScreenCover(isPresented: $showOutfitBuilder) {
            OutfitBuilderView()
        }
    }

   
}

#Preview {
    MainTabView()
        .modelContainer(PreviewData.previewContainer)
}
