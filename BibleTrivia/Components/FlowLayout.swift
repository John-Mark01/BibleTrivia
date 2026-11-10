//
//  FlowLayout.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 25.10.24.
//

import SwiftUI


/// The FlowLayout struct implements SwiftUI's Layout protocol to create a custom container that automatically arranges items in centered rows with consistent spacing (20pt default), where each row starts fresh when items won't fit the width (like text wrapping), calculating optimal positions using sizeThatFits for dimensions and placeSubviews for item positioning, with a helper FlowResult struct tracking row information (ranges, positions, widths) to achieve centered alignment by offsetting each row's x-position by (total width - row width) / 2.
struct FlowLayout: Layout {
    var spacing: CGFloat = 20
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for row in result.rows {
            let y = bounds.minY + row.y
            var x = bounds.minX + (bounds.width - row.width) / 2 // This centers the row
            for index in row.range {
                let subview = subviews[index]
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                x += size.width + spacing
            }
        }
    }
    
    struct FlowResult {
        struct Row {
            var range: Range<Int>
            var y: CGFloat
            var width: CGFloat
        }
        
        var rows: [Row]
        var size: CGSize
        
        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var rows: [Row] = []
            var currentRow: Row?
            var y: CGFloat = 0
            var maxWidth: CGFloat = 0
            
            for (index, subview) in subviews.enumerated() {
                let size = subview.sizeThatFits(.unspecified)
                
                if let row = currentRow {
                    let rowWidth = row.width + spacing + size.width
                    if rowWidth <= width {
                        currentRow?.width = rowWidth
                        currentRow?.range = row.range.startIndex..<index + 1
                    } else {
                        rows.append(row)
                        maxWidth = max(maxWidth, row.width)
                        y += size.height + spacing
                        currentRow = Row(range: index..<index + 1, y: y, width: size.width)
                    }
                } else {
                    currentRow = Row(range: index..<index + 1, y: y, width: size.width)
                }
            }
            
            if let row = currentRow {
                rows.append(row)
                maxWidth = max(maxWidth, row.width)
                y += subviews[row.range.startIndex].sizeThatFits(.unspecified).height
            }
            
            self.rows = rows
            self.size = CGSize(width: maxWidth, height: y)
        }
    }
}
