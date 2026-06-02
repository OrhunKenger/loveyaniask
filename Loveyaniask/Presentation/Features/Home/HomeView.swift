//
//  HomeView.swift
//  Loveyaniask
//
//  Ana ekran. En üstte canlı sayaç kartı, altında özel günler baloncukları.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @State private var specialDaysViewModel: SpecialDaysViewModel

    init(viewModel: HomeViewModel, specialDaysViewModel: SpecialDaysViewModel) {
        _viewModel = State(initialValue: viewModel)
        _specialDaysViewModel = State(initialValue: specialDaysViewModel)
    }

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    TimeTogetherCard(viewModel: viewModel)

                    SpecialDaysSection(viewModel: specialDaysViewModel)

                    // İleride: diğer kartlar (anılar, istek listesi, ...) buraya gelecek.
                }
                .padding(AppSpacing.md)
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}

#Preview {
    let dependencies = AppDependencies()
    return HomeView(
        viewModel: dependencies.makeHomeViewModel(),
        specialDaysViewModel: dependencies.makeSpecialDaysViewModel()
    )
}
