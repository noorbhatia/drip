//
//  MainTabView.swift
//  drip
//

import SwiftData
import SwiftUI

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: DripTab = .home

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
        TabView(selection: $selectedTab) {
            tabs
        }
    }

   
}

#Preview {
    MainTabView()
        .modelContainer(PreviewData.previewContainer)
}
