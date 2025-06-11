import Foundation

protocol NotificationCenterObserving {
    func addObserver(
        forName name: NSNotification.Name?,
        object obj: Any?,
        queue: OperationQueue?,
        using block: @escaping @Sendable (Notification) -> Void
    ) -> NSObjectProtocol
}

extension NotificationCenter: NotificationCenterObserving {}
