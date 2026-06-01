//
//  RootView.swift
//  Loveyaniask
//
//  Uygulamanın kök ekranı / kabuğu. İleride sekmeler (TabView)
//  ve gezinme (navigation) burada yaşayacak. Şimdilik Home'u gösterir.
//

import SwiftUI

struct RootView: View {
    let homeViewModel: HomeViewModel

    var body: some View {
        HomeView(viewModel: homeViewModel)
    }
}
