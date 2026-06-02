//
//  AppDependencies.swift
//  Loveyaniask
//
//  Composition Root: tüm katmanların birbirine bağlandığı tek yer.
//  Gerçek (live) implementasyonları kurar ve hazır ViewModel'ler sunar.
//  Bağımlılıkları buradan enjekte ediyoruz (Dependency Injection).
//

import Foundation

struct AppDependencies {
    func makeAuthViewModel() -> AuthViewModel {
        let store = KeychainCredentialStore()
        return AuthViewModel(
            hasPassword: HasPasswordUseCase(store: store),
            setPassword: SetPasswordUseCase(store: store),
            verifyPassword: VerifyPasswordUseCase(store: store)
        )
    }

    func makeHomeViewModel() -> HomeViewModel {
        let dataSource = UserDefaultsCoupleDataSource()
        let repository = CoupleRepositoryImpl(localDataSource: dataSource)
        return HomeViewModel(
            getDaysTogether: GetDaysTogetherUseCase(repository: repository),
            getTimeTogether: GetTimeTogetherUseCase(repository: repository)
        )
    }

    func makeSpecialDaysViewModel() -> SpecialDaysViewModel {
        SpecialDaysViewModel(getDays: GetSpecialDaysUseCase(repository: SpecialDayRepositoryImpl()))
    }

    func makeMoodViewModel() -> MoodViewModel {
        let dataSource = UserDefaultsMoodDataSource()
        let repository = MoodRepositoryImpl(localDataSource: dataSource)
        let photoStore = FileMoodPhotoStore()
        return MoodViewModel(
            getEntries: GetMoodEntriesUseCase(repository: repository),
            setMoodUseCase: SetMoodUseCase(repository: repository),
            setPhotoUseCase: SetMoodPhotoUseCase(repository: repository, photoStore: photoStore),
            getPhotoUseCase: GetMoodPhotoUseCase(photoStore: photoStore)
        )
    }

    func makePeriodViewModel() -> PeriodViewModel {
        let dataSource = UserDefaultsPeriodDataSource()
        let repository = PeriodRepositoryImpl(localDataSource: dataSource)
        return PeriodViewModel(
            getSettings: GetPeriodSettingsUseCase(repository: repository),
            saveSettings: SavePeriodSettingsUseCase(repository: repository)
        )
    }
}
