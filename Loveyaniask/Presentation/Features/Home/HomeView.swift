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
    @State private var profileViewModel: ProfileViewModel
    @State private var specialDaysViewModel: SpecialDaysViewModel
    @State private var moodViewModel: MoodViewModel
    @State private var plansViewModel: PlansViewModel
    @State private var jarViewModel: JarViewModel
    /// Home sekmesi seçili mi? Canlı sayaç sadece görünürken çalışsın diye.
    var isActive: Bool = true
    /// Çıkış yap (oturumu kapat) aksiyonu.
    var onSignOut: () -> Void = {}

    @State private var showingProfile = false

    init(viewModel: HomeViewModel, quickNotesViewModel: QuickNotesViewModel, profileViewModel: ProfileViewModel, specialDaysViewModel: SpecialDaysViewModel, moodViewModel: MoodViewModel, plansViewModel: PlansViewModel, jarViewModel: JarViewModel, isActive: Bool = true, onSignOut: @escaping () -> Void = {}) {
        _viewModel = State(initialValue: viewModel)
        _quickNotesViewModel = State(initialValue: quickNotesViewModel)
        _profileViewModel = State(initialValue: profileViewModel)
        _specialDaysViewModel = State(initialValue: specialDaysViewModel)
        _moodViewModel = State(initialValue: moodViewModel)
        _plansViewModel = State(initialValue: plansViewModel)
        _jarViewModel = State(initialValue: jarViewModel)
        self.isActive = isActive
        self.onSignOut = onSignOut
    }

    var body: some View {
        ZStack {
            GlowBackground()

            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    HStack {
                        Menu {
                            Button {
                                quickNotesViewModel.showingAdd = true
                            } label: { Label("Hızlı Not", systemImage: "sparkles") }
                            Button {
                                plansViewModel.startNew()
                            } label: { Label("Plan Ekle", systemImage: "calendar.badge.plus") }
                            Button {
                                specialDaysViewModel.startNew()
                            } label: { Label("Özel Gün", systemImage: "heart.circle") }
                        } label: {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 36, height: 36)
                                .background(AppColors.accentGradient)
                                .clipShape(Circle())
                                .shadow(color: AppColors.primary.opacity(0.4), radius: 8, y: 3)
                        }

                        Spacer()

                        Button {
                            showingProfile = true
                        } label: {
                            profileButtonLabel
                        }
                        .buttonStyle(.plain)
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
        .sheet(isPresented: $showingProfile) {
            ProfileView(viewModel: profileViewModel, onSignOut: onSignOut)
        }
    }

    private var profileButtonLabel: some View {
        Group {
            if let img = profileViewModel.image(for: profileViewModel.currentUser) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(AppColors.glassStroke, lineWidth: 1))
            } else {
                Image(systemName: "person.crop.circle")
                    .font(.title2)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }
}

#Preview {
    let dependencies = AppDependencies()
    return HomeView(
        viewModel: dependencies.makeHomeViewModel(),
        quickNotesViewModel: dependencies.makeQuickNotesViewModel(currentUser: .orhun),
        profileViewModel: dependencies.makeProfileViewModel(currentUser: .orhun),
        specialDaysViewModel: dependencies.makeSpecialDaysViewModel(),
        moodViewModel: dependencies.makeMoodViewModel(currentUser: .orhun),
        plansViewModel: dependencies.makePlansViewModel(currentUser: .orhun),
        jarViewModel: dependencies.makeJarViewModel(currentUser: .orhun)
    )
}
