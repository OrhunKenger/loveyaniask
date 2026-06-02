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

    func makePlacesViewModel(currentUser: UserProfile) -> PlacesViewModel {
        let dataSource = UserDefaultsPlaceDataSource()
        let repository = PlaceRepositoryImpl(localDataSource: dataSource)
        let photoStore = FilePlacePhotoStore()
        return PlacesViewModel(
            currentUser: currentUser,
            getPlaces: GetPlacesUseCase(repository: repository),
            addPlace: AddPlaceUseCase(repository: repository, photoStore: photoStore),
            deletePlace: DeletePlaceUseCase(repository: repository, photoStore: photoStore),
            getPhoto: GetPlacePhotoUseCase(photoStore: photoStore),
            setRating: SetPlaceRatingUseCase(repository: repository)
        )
    }

    func makeMoodViewModel(currentUser: UserProfile) -> MoodViewModel {
        let dataSource = UserDefaultsMoodDataSource()
        let repository = MoodRepositoryImpl(localDataSource: dataSource)
        let photoStore = FileMoodPhotoStore()
        return MoodViewModel(
            getEntries: GetMoodEntriesUseCase(repository: repository),
            setMoodUseCase: SetMoodUseCase(repository: repository),
            setPhotoUseCase: SetMoodPhotoUseCase(repository: repository, photoStore: photoStore),
            getPhotoUseCase: GetMoodPhotoUseCase(photoStore: photoStore),
            currentUser: currentUser
        )
    }

    func makePeriodViewModel() -> PeriodViewModel {
        let dataSource = UserDefaultsPeriodDataSource()
        let repository = PeriodRepositoryImpl(localDataSource: dataSource)
        let scheduler = LocalPeriodReminderScheduler()
        return PeriodViewModel(
            getSettings: GetPeriodSettingsUseCase(repository: repository),
            saveSettings: SavePeriodSettingsUseCase(repository: repository),
            logPeriod: LogPeriodUseCase(repository: repository),
            getLogs: GetPeriodLogsUseCase(repository: repository),
            deleteLog: DeletePeriodLogUseCase(repository: repository),
            getNote: GetDayNoteUseCase(repository: repository),
            saveNote: SaveDayNoteUseCase(repository: repository),
            reminderScheduler: scheduler
        )
    }
}
