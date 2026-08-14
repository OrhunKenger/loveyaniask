//
//  MoodAnalysisRepository.swift
//  Loveyaniask
//

import Foundation

protocol MoodAnalysisRepository {
    /// En son AI analizini gerçek zamanlı dinler. Henüz üretilmemişse nil verir.
    func observe(_ onChange: @escaping (MoodAnalysis?) -> Void)
}
