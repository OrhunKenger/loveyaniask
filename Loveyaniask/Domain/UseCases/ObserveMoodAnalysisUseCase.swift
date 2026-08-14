//
//  ObserveMoodAnalysisUseCase.swift
//  Loveyaniask
//

import Foundation

struct ObserveMoodAnalysisUseCase {
    private let repository: MoodAnalysisRepository

    init(repository: MoodAnalysisRepository) {
        self.repository = repository
    }

    func execute(_ onChange: @escaping (MoodAnalysis?) -> Void) {
        repository.observe(onChange)
    }
}
