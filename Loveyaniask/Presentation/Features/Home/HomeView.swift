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
    let kenCompanion: KenCompanion
    /// Home sekmesi seçili mi? Canlı sayaç sadece görünürken çalışsın diye.
    var isActive: Bool = true
    /// Çıkış yap (oturumu kapat) aksiyonu.
    var onSignOut: () -> Void = {}

    @State private var showingProfile = false

    init(viewModel: HomeViewModel, quickNotesViewModel: QuickNotesViewModel, profileViewModel: ProfileViewModel, specialDaysViewModel: SpecialDaysViewModel, moodViewModel: MoodViewModel, plansViewModel: PlansViewModel, jarViewModel: JarViewModel, kenCompanion: KenCompanion, isActive: Bool = true, onSignOut: @escaping () -> Void = {}) {
        _viewModel = State(initialValue: viewModel)
        _quickNotesViewModel = State(initialValue: quickNotesViewModel)
        _profileViewModel = State(initialValue: profileViewModel)
        _specialDaysViewModel = State(initialValue: specialDaysViewModel)
        _moodViewModel = State(initialValue: moodViewModel)
        _plansViewModel = State(initialValue: plansViewModel)
        _jarViewModel = State(initialValue: jarViewModel)
        self.kenCompanion = kenCompanion
        self.isActive = isActive
        self.onSignOut = onSignOut
    }

    var body: some View {
        ZStack {
            GlowBackground()

            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    HStack(spacing: AppSpacing.sm) {
                        // Küçük canlı sayaç — sola yaslı
                        TimeTogetherCompact(viewModel: viewModel, isActive: isActive)

                        Spacer()

                        // Profil butonu — sağa yaslı
                        Button {
                            showingProfile = true
                        } label: {
                            profileButtonLabel
                        }
                        .buttonStyle(.plain)
                    }

                    KenHomeNoteCard(companion: kenCompanion)

                    SpecialDaysSection(viewModel: specialDaysViewModel)

                    QuickNotesSection(viewModel: quickNotesViewModel, kenCompanion: kenCompanion)

                    MoodHomeSection(viewModel: moodViewModel, kenCompanion: kenCompanion)

                    PlansSection(viewModel: plansViewModel)
                }
                .padding(AppSpacing.md)
            }

            // Yüzen, sürüklenebilir kavanoz (her şeyin üstünde).
            MemoryJarSection(viewModel: jarViewModel)
        }
        .onAppear {
            viewModel.onAppear()
            updateKenUpcomingDay()
        }
        .onChange(of: specialDaysViewModel.days) { _, _ in
            updateKenUpcomingDay()
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView(viewModel: profileViewModel, onSignOut: onSignOut)
        }
    }

    /// En yakın özel gün birkaç gün içindeyse Ken'in bundan haberi olsun —
    /// dokununca kendiliğinden hatırlatabilsin diye (bkz. KenLineSelector).
    private func updateKenUpcomingDay() {
        guard let next = specialDaysViewModel.days.first else {
            kenCompanion.upcomingSpecialDay = nil
            return
        }
        let remaining = specialDaysViewModel.daysRemaining(for: next)
        kenCompanion.upcomingSpecialDay = remaining <= 5
            ? KenUpcomingDay(title: next.title, daysRemaining: remaining)
            : nil
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
        jarViewModel: dependencies.makeJarViewModel(currentUser: .orhun),
        kenCompanion: dependencies.kenCompanion
    )
}
