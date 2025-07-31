import Combine
import SwiftUI

class KeyboardResponder: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    private var cancellables: Set<AnyCancellable> = []

    init() {
        NotificationCenter.Publisher(center: .default, name: UIResponder.keyboardWillChangeFrameNotification)
            .merge(with: NotificationCenter.Publisher(center: .default, name: UIResponder.keyboardWillShowNotification))
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map { $0.height }
            .sink { [weak self] height in
                self?.keyboardHeight = height
            }
            .store(in: &cancellables)

        NotificationCenter.Publisher(center: .default, name: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
            .sink { [weak self] _ in
                self?.keyboardHeight = 0
            }
            .store(in: &cancellables)
    }
}