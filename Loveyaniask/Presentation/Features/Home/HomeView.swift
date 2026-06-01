//
//  HomeView.swift
//  Loveyaniask
//
//  Ana ekran: kaç gündür birlikte olduğumuzu gösterir.
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

            VStack(spacing: AppSpacing.md) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(AppColors.primary)

                Text("\(viewModel.daysTogether)")
                    .font(.system(size: 96, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .contentTransition(.numericText())

                Text("gün birlikteyiz")
                    .font(.title3)
                    .foregroundStyle(AppColors.textSecondary)

                Text("\(viewModel.formattedStartDate)'dan beri")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.top, AppSpacing.xs)
            }
            .padding(AppSpacing.lg)
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}

#Preview {
    let dataSource = UserDefaultsCoupleDataSource()
    let repository = CoupleRepositoryImpl(localDataSource: dataSource)
    let useCase = GetDaysTogetherUseCase(repository: repository)
    return HomeView(viewModel: HomeViewModel(getDaysTogether: useCase))
}
