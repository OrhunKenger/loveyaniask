//
//  HomeView.swift
//  Loveyaniask
//
//  Ana ekran. En üstte canlı "birlikteyiz" sayaç kartı.
//  Sadece görünümden sorumlu; tüm mantık HomeViewModel'de.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    TimeTogetherCard(viewModel: viewModel)

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
    let dataSource = UserDefaultsCoupleDataSource()
    let repository = CoupleRepositoryImpl(localDataSource: dataSource)
    return HomeView(viewModel: HomeViewModel(
        getDaysTogether: GetDaysTogetherUseCase(repository: repository),
        getTimeTogether: GetTimeTogetherUseCase(repository: repository)
    ))
}
