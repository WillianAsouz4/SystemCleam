import SwiftUI

struct SegmentedProgressBar: View {
    var progress: Double
    var segmentCount: Int = 24
    var tint: Color = AppColors.accent

    private var filledSegments: Int {
        Int(min(max(progress, 0), 1) * Double(segmentCount))
    }

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<segmentCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(index < filledSegments ? tint : AppColors.hairline)
                    .frame(width: 3, height: 12)
            }
        }
        .accessibilityElement()
        .accessibilityValue("\(Int(min(max(progress, 0), 1) * 100))%")
    }
}
