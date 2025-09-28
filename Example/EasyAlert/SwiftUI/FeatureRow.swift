//
//  FeatureRow.swift
//

import SwiftUI

struct FeatureRow: View {
  let icon: String
  let title: String
  let description: String

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .foregroundColor(.accentColor)
        .font(.title3)
        .frame(width: 24)

      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(.system(size: 16, weight: .medium))
        Text(description)
          .font(.system(size: 14))
          .foregroundColor(.secondary)
      }

      Spacer()
    }
    .padding(.horizontal, 20)
  }
}

