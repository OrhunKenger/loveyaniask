//
//  AppViewModels.swift
//  Loveyaniask
//
//  Uygulamanın ViewModel'lerinin TEK örneği. Bir kez kurulur, ekranlar
//  bunları hazır alır.
//
//  NEDEN VAR: Eskiden bu nesneler RootView'ın init'inde yaratılıyordu
//  (`State(initialValue: dependencies.makeXViewModel(...))`). SwiftUI
//  `State(initialValue:)` içindeki ifadeyi VIEW HER YENİDEN KURULDUĞUNDA
//  çalıştırır — sadece ilk sonucu saklar, ama ifade her seferinde çalışır.
//  RootView de üstündeki AuthGateView her çizildiğinde yeniden kuruluyordu.
//
//  Sonuç: her yeniden çizimde 11 ViewModel, onların repository'leri ve
//  17 Firebase `.observe(.value)` dinleyicisi baştan bağlanıyordu. Her yeni
//  dinleyici bağlandığı anda ilgili alt ağacın TAMAMINI indirip ana thread'de
//  ayrıştırır. Ölçümde bu saniyede 4 tur × 17 dinleyici = 56 geri çağrı,
//  2.3 saniyelik donmuş kareler ve 1-2 fps olarak görüldü. Üstelik kendini
//  besliyordu: ana thread tıkandıkça daha çok yeniden çizim, daha çok dinleyici.
//
//  Bu yüzden nesne grafiği ARTIK BİR VIEW'IN INIT'İNDE KURULMUYOR. Buraya
//  yeni bir ViewModel eklerken de aynı kurala uy.
//

import Foundation

final class AppViewModels {
    let home: HomeViewModel
    let quickNotes: QuickNotesViewModel
    let profile: ProfileViewModel
    let specialDays: SpecialDaysViewModel
    let plans: PlansViewModel
    let jar: JarViewModel
    let mood: MoodViewModel
    let period: PeriodViewModel
    let places: PlacesViewModel
    let library: LibraryViewModel
    let akis: AkisViewModel

    init(dependencies: AppDependencies, currentUser: UserProfile) {
        home = dependencies.makeHomeViewModel()
        quickNotes = dependencies.makeQuickNotesViewModel(currentUser: currentUser)
        profile = dependencies.makeProfileViewModel(currentUser: currentUser)
        specialDays = dependencies.makeSpecialDaysViewModel()
        plans = dependencies.makePlansViewModel(currentUser: currentUser)
        jar = dependencies.makeJarViewModel(currentUser: currentUser)
        mood = dependencies.makeMoodViewModel(currentUser: currentUser)
        period = dependencies.makePeriodViewModel()
        places = dependencies.makePlacesViewModel(currentUser: currentUser)
        library = dependencies.makeLibraryViewModel(currentUser: currentUser)
        akis = dependencies.makeAkisViewModel(currentUser: currentUser)
    }
}
