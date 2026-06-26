//
//  HomeView.swift
//  Loveyaniask
//
//  Ana ekran: canlı sayaç, özel günler, "birbirimiz hakkında" kavanozu.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @State private var quickNotesViewModel: QuickNotesViewModel
    @State private var specialDaysViewModel: SpecialDaysViewModel
    @State private var moodViewModel: MoodViewModel
    @State private var plansViewModel: PlansViewModel
    @State private var jarViewModel: JarViewModel
    /// Home sekmesi seçili mi? Canlı sayaç sadece görünürken çalışsın diye.
    var isActive: Bool = true
    /// Çıkış yap (oturumu kapat) aksiyonu.
    var onSignOut: () -> Void = {}

    init(viewModel: HomeViewModel, quickNotesViewModel: QuickNotesViewModel, specialDaysViewModel: SpecialDaysViewModel, moodViewModel: MoodViewModel, plansViewModel: PlansViewModel, jarViewModel: JarViewModel, isActive: Bool = true, onSignOut: @escaping () -> Void = {}) {
        _viewModel = State(initialValue: viewModel)
        _quickNotesViewModel = State(initialValue: quickNotesViewModel)
        _specialDaysViewModel = State(initialValue: specialDaysViewModel)
        _moodViewModel = State(initialValue: moodViewModel)
        _plansViewModel = State(initialValue: plansViewModel)
        _jarViewModel = State(initialValue: jarViewModel)
        self.isActive = isActive
        self.onSignOut = onSignOut
    }

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    HStack {
                        Spacer()
                        Menu {
                            Button(role: .destructive, action: onSignOut) {
                                Label("Çıkış yap", systemImage: "rectangle.portrait.and.arrow.right")
                            }
                        } label: {
                            Image(systemName: "person.crop.circle")
                                .font(.title2)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }

                    TimeTogetherCard(viewModel: viewModel, isActive: isActive)

                    QuickNotesSection(viewModel: quickNotesViewModel)

                    SpecialDaysSection(viewModel: specialDaysViewModel)

                    MoodHomeSection(viewModel: moodViewModel)

                    PlansSection(viewModel: plansViewModel)
                }
                .padding(AppSpacing.md)
            }

            // Yüzen, sürüklenebilir kavanoz (her şeyin üstünde).
            MemoryJarSection(viewModel: jarViewModel)
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
        quickNotesViewModel: dependencies.makeQuickNotesViewModel(currentUser: .orhun),
        specialDaysViewModel: dependencies.makeSpecialDaysViewModel(),
        moodViewModel: dependencies.makeMoodViewModel(currentUser: .orhun),
        plansViewModel: dependencies.makePlansViewModel(currentUser: .orhun),
        jarViewModel: dependencies.makeJarViewModel(currentUser: .orhun)
    )
}
