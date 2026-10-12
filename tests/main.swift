import Foundation
let store = UserDefaults(suiteName: "Tasbeeh.Tests")!
store.removePersistentDomain(forName: "Tasbeeh.Tests")
var day = "2026-10-12"
let counts = Counts(defaults: store, date: { day })
for _ in 0..<33 { counts.tap() }
assert(counts.today == 33 && counts.session == 33)
counts.undo()
assert(counts.today == 32 && counts.session == 32)
counts.undo()
assert(counts.today == 32)
counts.resetSession()
assert(counts.session == 0 && counts.today == 32)
assert(counts.adjust("150"))
counts.tap()
assert(counts.today == 151 && counts.session == 1)
for invalid in ["", "-1", "1.5", "abc", "10000000", " 5", "١"] { assert(!counts.adjust(invalid)) }
let restored = Counts(defaults: store, date: { day })
assert(restored.today == 151 && restored.session == 1)
day = "2026-10-13"
restored.refreshDay()
assert(restored.today == 0 && restored.session == 1)
restored.undo()
assert(restored.session == 1)
assert(restored.adjust("0"))
restored.tap()
assert(restored.today == 1 && restored.session == 2)
print("PASS: taps, undo, reset, adjustment, validation, persistence, rollover")
