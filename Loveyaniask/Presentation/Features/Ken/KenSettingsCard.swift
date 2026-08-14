//
//  KenSettingsCard.swift
//  Loveyaniask
//
//  Profil sayfasındaki küçük Ken ayarı: onu ne sıklıkta görmek istediğiniz.
//  Seçim doğrudan UserDefaults'a yazılır, KenCompanion boşta bekleme süresini
//  her turda oradan okur (bkz. KenFrequency).
//

import SwiftUI

struct KenSettingsCard: View {
    let companion: KenCompanion

    @AppStorage(KenFrequency.storageKey) private var frequency = KenFrequency.normal.rawValue

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.md) {
                KenCharacterView(behavior: .sit, tone: companion.moodTone, fps: 30)
                    .frame(width: 44, height: 50)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Ken")
                        .font(AppTypography.cardTitle)
                        .foregroundStyle(AppColors.textPrimary)
                    Text("Onu ne sıklıkta görmek istersiniz?")
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer(minLength: 0)
            }

            Picker("Sıklık", selection: $frequency) {
                ForEach(KenFrequency.allCases) { option in
                    Text(option.label).tag(option.rawValue)
                }
            }
            .pickerStyle(.segmented)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: 20, padding: AppSpacing.md)
    }
}
