//
//  PlansViewModel.swift
//  Loveyaniask
//
//  Yaklaşan planlar: gerçek zamanlı dinleme, en yakın üstte, geri sayım, bildirim.
//

import Foundation
import Observation

/// Ekleme/düzenleme sheet hedefi (plan = nil ise yeni).
struct PlanFormTarget: Identifiable {
    let id = UUID()
    let plan: Plan?
}

@Observable
final class PlansViewModel {
    private(set) var plans: [Plan] = []   // sadece yaklaşanlar, en yakın en üstte
    var formTarget: PlanFormTarget?

    private let currentUser: UserProfile
    private let observePlansUseCase: ObservePlansUseCase
    private let addPlanUseCase: AddPlanUseCase
    private let updatePlanUseCase: UpdatePlanUseCase
    private let deletePlanUseCase: DeletePlanUseCase
    private let scheduler: PlanReminderScheduler

    init(
        currentUser: UserProfile,
        observePlans: ObservePlansUseCase,
        addPlan: AddPlanUseCase,
        updatePlan: UpdatePlanUseCase,
        deletePlan: DeletePlanUseCase,
        scheduler: PlanReminderScheduler
    ) {
        self.currentUser = currentUser
        self.observePlansUseCase = observePlans
        self.addPlanUseCase = addPlan
        self.updatePlanUseCase = updatePlan
        self.deletePlanUseCase = deletePlan
        self.scheduler = scheduler
        scheduler.requestAuthorization()

        observePlans.execute { [weak self] all in
            guard let self else { return }
            let startOfToday = Calendar.current.startOfDay(for: Date())
            self.plans = all
                .filter { $0.date >= startOfToday }
                .sorted { $0.date < $1.date }
            self.scheduler.reschedule(all)
        }
    }

    func add(title: String, date: Date, note: String, remindEnabled: Bool) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        addPlanUseCase.execute(
            title: trimmed, date: date, note: note,
            remindEnabled: remindEnabled, authorKey: currentUser.rawValue
        )
    }

    func update(_ plan: Plan, title: String, date: Date, note: String, remindEnabled: Bool) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let updated = Plan(
            id: plan.id, title: trimmed, date: date, note: note,
            remindEnabled: remindEnabled, authorKey: plan.authorKey
        )
        updatePlanUseCase.execute(updated)
    }

    func startNew() { formTarget = PlanFormTarget(plan: nil) }
    func startEdit(_ plan: Plan) { formTarget = PlanFormTarget(plan: plan) }

    func delete(_ plan: Plan) {
        deletePlanUseCase.execute(id: plan.id)
    }

    // MARK: - Görüntü yardımcıları

    func countdownText(for plan: Plan) -> String {
        let calendar = Calendar.current
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: Date()),
            to: calendar.startOfDay(for: plan.date)
        ).day ?? 0
        if days <= 0 { return "Bugün" }
        if days == 1 { return "Yarın" }
        return "\(days) gün"
    }

    func dateText(for plan: Plan) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM EEEE · HH:mm"
        return formatter.string(from: plan.date)
    }

    func authorName(for plan: Plan) -> String {
        (UserProfile(rawValue: plan.authorKey) ?? .orhun).firstName
    }
}
