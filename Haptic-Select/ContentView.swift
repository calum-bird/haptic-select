import AppKit
import SwiftUI

struct ScrollableView: NSViewRepresentable {
    var items: [String]
    @Binding var selection: Int
    let itemHeight: CGFloat = 30.0 // Single item's height matching the ScrollableView height
    let action: () -> Void

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let contentView = NSView()
        
        contentView.frame = CGRect(x: 0, y: 0, width: 50, height: itemHeight * CGFloat(items.count))
        
        for (index, item) in items.enumerated() {
            let label = NSTextField(labelWithString: item)
            label.isBordered = false
            label.alignment = .center
            
            let box = NSBox(frame: CGRect(x: 0, y: CGFloat(index) * itemHeight, width: 50, height: itemHeight))
            box.contentView = label
            box.fillColor = (selection == index) ? NSColor.blue : NSColor.clear
            box.boxType = .custom
            box.isTransparent = false
            
            contentView.addSubview(box)
        }
        
        scrollView.documentView = contentView
        scrollView.hasVerticalScroller = true
        scrollView.contentView.postsBoundsChangedNotifications = true
        NotificationCenter.default.addObserver(context.coordinator, selector: #selector(Coordinator.boundsDidChange(_:)), name: NSView.boundsDidChangeNotification, object: scrollView.contentView)

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        let contentView = nsView.documentView!
        for (index, view) in contentView.subviews.enumerated() {
            guard let box = view as? NSBox else { continue }
            let isSelected = index == selection
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = 0.15
                box.animator().fillColor = isSelected ? NSColor.lightGray : NSColor.clear
            }, completionHandler: nil)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: ScrollableView

        init(_ parent: ScrollableView) {
            self.parent = parent
        }

        @objc func boundsDidChange(_ notification: Notification) {
            let contentView = notification.object as! NSClipView
            let boundsOrigin = contentView.bounds.origin.y
            let index = Int(round(boundsOrigin / parent.itemHeight))
            if parent.selection != index {
                parent.selection = index
                parent.action()
            }
        }
    }
}





struct ContentView: View {
    @State private var items = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5", "Item 6", "Item 7", "Item 8", "Item 9", "Item 10"]
    @State private var selection: Int = 0
    
    var body: some View {
        VStack {
            ScrollableView(items: items, selection: $selection) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    HapticManager.triggerFeedback()
                }
            }
            .frame(height: 50.0)
            .border(Color.gray)
        }
    }
}
