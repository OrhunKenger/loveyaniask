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
        // Giriş artık Firebase Authentication üzerinden; oturum kalıcı.
        AuthViewModel(auth: FirebaseAuthService())
    }

    func makeHomeViewModel() -> HomeViewModel {
        let dataSource = UserDefaultsCoupleDataSource()
        let repository = CoupleRepositoryImpl(localDataSource: dataSource)
        return HomeViewModel(
            getDaysTogether: GetDaysTogetherUseCase(repository: repository),
            getTimeTogether: GetTimeTogetherUseCase(repository: repository)
        )
    }

    func makeQuickNotesViewModel(currentUser: UserProfile) -> QuickNotesViewModel {
        // Hızlı notlar Firebase Realtime Database'de (gerçek zamanlı senkron).
        let repository = FirebaseQuickNoteRepository()
        return QuickNotesViewModel(currentUser: currentUser, repository: repository)
    }

    func makeSpecialDaysViewModel() -> SpecialDaysViewModel {
        // Özel günler artık Firebase'de (sabit günler + eklenenler, senkron).
        let repository = FirebaseSpecialDayRepository()
        return SpecialDaysViewModel(
            getDays: GetSpecialDaysUseCase(repository: repository),
            observeDays: ObserveSpecialDaysUseCase(repository: repository),
            addDay: AddSpecialDayUseCase(repository: repository),
            updateDay: UpdateSpecialDayUseCase(repository: repository),
            deleteDay: DeleteSpecialDayUseCase(repository: repository)
        )
    }

    func makeLibraryViewModel(currentUser: UserProfile) -> LibraryViewModel {
        let repository = FirebaseLibraryRepository()
        let search = RemoteLibrarySearchService()
        return LibraryViewModel(
            currentUser: currentUser,
            observe: ObserveLibraryUseCase(repository: repository),
            add: AddLibraryItemUseCase(repository: repository),
            update: UpdateLibraryItemUseCase(repository: repository),
            delete: DeleteLibraryItemUseCase(repository: repository),
            search: search
        )
    }

    func makePlansViewModel(currentUser: UserProfile) -> PlansViewModel {
        let repository = FirebasePlanRepository()
        let scheduler = LocalPlanReminderScheduler()
        return PlansViewModel(
            currentUser: currentUser,
            observePlans: ObservePlansUseCase(repository: repository),
            addPlan: AddPlanUseCase(repository: repository),
            updatePlan: UpdatePlanUseCase(repository: repository),
            deletePlan: DeletePlanUseCase(repository: repository),
            scheduler: scheduler
        )
    }

    func makeJarViewModel(currentUser: UserProfile) -> JarViewModel {
        // Kavanoz artık Firebase Firestore üzerinden gerçek zamanlı senkron.
        let repository = FirebaseJarRepository()
        return JarViewModel(currentUser: currentUser, repository: repository)
    }

    func makePlacesViewModel(currentUser: UserProfile) -> PlacesViewModel {
        // Mekanlar artık Firebase Realtime Database'de (gerçek zamanlı senkron).
        let repository = FirebasePlaceRepository()
        let photoStore = FilePlacePhotoStore()   // fotoğraflar şimdilik cihazda yerel
        return PlacesViewModel(
            currentUser: currentUser,
            getPlaces: GetPlacesUseCase(repository: repository),
            observePlaces: ObservePlacesUseCase(repository: repository),
            addPlace: AddPlaceUseCase(repository: repository, photoStore: photoStore),
            deletePlace: DeletePlaceUseCase(repository: repository, photoStore: photoStore),
            getPhoto: GetPlacePhotoUseCase(photoStore: photoStore),
            setRating: SetPlaceRatingUseCase(repository: repository),
            setVisited: SetPlaceVisitedUseCase(repository: repository)
        )
    }

    func makeMoodViewModel(currentUser: UserProfile) -> MoodViewModel {
        // Ruh halleri artık Firebase'de (gerçek kişiye göre, senkron). Fotoğraflar cihazda yerel.
        let repository = FirebaseMoodRepository(currentUser: currentUser)
        let photoStore = FileMoodPhotoStore()
        return MoodViewModel(
            getEntries: GetMoodEntriesUseCase(repository: repository),
            observeEntries: ObserveMoodEntriesUseCase(repository: repository),
            setMoodUseCase: SetMoodUseCase(repository: repository),
            setPhotoUseCase: SetMoodPhotoUseCase(repository: repository, photoStore: photoStore),
            getPhotoUseCase: GetMoodPhotoUseCase(photoStore: photoStore),
            currentUser: currentUser
        )
    }

    func makePeriodViewModel() -> PeriodViewModel {
        // Regl takvimi artık Firebase'de (ayarlar + kayıtlar + notlar, senkron).
        let repository = FirebasePeriodRepository()
        let scheduler = LocalPeriodReminderScheduler()
        return PeriodViewModel(
            getSettings: GetPeriodSettingsUseCase(repository: repository),
            saveSettings: SavePeriodSettingsUseCase(repository: repository),
            logPeriod: LogPeriodUseCase(repository: repository),
            getLogs: GetPeriodLogsUseCase(repository: repository),
            deleteLog: DeletePeriodLogUseCase(repository: repository),
            getNote: GetDayNoteUseCase(repository: repository),
            getNotes: GetDayNotesUseCase(repository: repository),
            saveNote: SaveDayNoteUseCase(repository: repository),
            observePeriod: ObservePeriodUseCase(repository: repository),
            reminderScheduler: scheduler
        )
    }
}
