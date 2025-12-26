//
//  FallAnalysisViewModel.swift
//  FamilyApp
//
//  Created by imac-3570 on 2025/12/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class FallAnalysisViewModel: ObservableObject {
    @Published var fallAnalysisList: [FallAnalysis] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 訂閱 FamilyViewModel 的 fallAnalysisList
        FamilyViewModel.shared.$fallAnalysisList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] list in
                self?.fallAnalysisList = list
            }
            .store(in: &cancellables)
    }
    
    func clearAll() {
        FamilyViewModel.shared.clearFallAnalysisList()
    }
}
