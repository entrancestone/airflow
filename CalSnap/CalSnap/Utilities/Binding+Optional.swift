import SwiftUI

extension Binding where Value == Bool {
    init(value: Binding<String?>) {
        self.init(
            get: { value.wrappedValue != nil },
            set: { newValue in
                if !newValue {
                    value.wrappedValue = nil
                }
            }
        )
    }
}
