import Foundation

final class Counts {
    private let defaults: UserDefaults
    private let date: () -> String
    private(set) var today: Int
    private(set) var session: Int
    private(set) var undoAvailable = false
    var haptics: Bool { didSet { defaults.set(haptics, forKey: "haptics") } }
    init(defaults: UserDefaults = .standard, date: @escaping () -> String = {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        return "\(c.year!)-\(c.month!)-\(c.day!)"
    }) {
        self.defaults = defaults
        self.date = date
        today = defaults.integer(forKey: "today")
        session = defaults.integer(forKey: "session")
        haptics = defaults.object(forKey: "haptics") as? Bool ?? true
        refreshDay()
    }
    func refreshDay() {
        if defaults.string(forKey: "day") != date() {
            today = 0
            undoAvailable = false
            defaults.set(date(), forKey: "day")
            save()
        }
    }
    func tap() {
        refreshDay()
        guard today < 9999999, session < 9999999 else { return }
        today += 1
        session += 1
        undoAvailable = true
        save()
    }
    func undo() {
        refreshDay()
        guard undoAvailable, today > 0, session > 0 else { return }
        today -= 1
        session -= 1
        undoAvailable = false
        save()
    }
    func resetSession() { session = 0; undoAvailable = false; save() }
    @discardableResult func adjust(_ text: String) -> Bool {
        refreshDay()
        guard !text.isEmpty, text.utf8.allSatisfy({ $0 >= 48 && $0 <= 57 }),
              let n = Int(text), n <= 9999999 else { return false }
        today = n
        session = n
        undoAvailable = false
        save()
        return true
    }
    private func save() {
        defaults.set(today, forKey: "today")
        defaults.set(session, forKey: "session")
    }
}
