import UIKit

let emerald = UIColor(red: 0.025, green: 0.17, blue: 0.14, alpha: 1)
let ivory = UIColor(red: 0.96, green: 0.94, blue: 0.86, alpha: 1)
let gold = UIColor(red: 0.78, green: 0.67, blue: 0.40, alpha: 1)

final class CounterViewController: UIViewController {
    let counts = Counts()
    let number = UILabel()
    let today = UILabel()
    let undoButton = UIButton(type: .system)
    let circle = UIButton(type: .custom)
    var observer: NSObjectProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = emerald
        let title = UILabel()
        title.text = "Tasbeeh"
        title.font = .systemFont(ofSize: 30, weight: .semibold)
        title.textColor = ivory
        title.textAlignment = .center
        title.isUserInteractionEnabled = true
        let press = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        press.minimumPressDuration = 1
        title.addGestureRecognizer(press)
        let settings = UIButton(type: .system)
        settings.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        settings.tintColor = gold
        settings.accessibilityLabel = "Settings"
        settings.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        let ornament = UILabel()
        ornament.text = "۞"
        ornament.font = .systemFont(ofSize: 46)
        ornament.textColor = gold
        ornament.textAlignment = .center
        let dhikr = UISegmentedControl(items: ["SubhanAllah", "Alhamdulillah", "Allahu Akbar", "Astaghfirullah"])
        dhikr.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "dhikr")
        dhikr.selectedSegmentTintColor = gold
        dhikr.setTitleTextAttributes([.foregroundColor: ivory, .font: UIFont.systemFont(ofSize: 10, weight: .medium)], for: .normal)
        dhikr.setTitleTextAttributes([.foregroundColor: emerald], for: .selected)
        dhikr.addTarget(self, action: #selector(changeDhikr(_:)), for: .valueChanged)
        circle.backgroundColor = UIColor.white.withAlphaComponent(0.035)
        circle.layer.borderColor = gold.withAlphaComponent(0.65).cgColor
        circle.layer.borderWidth = 1.5
        circle.addTarget(self, action: #selector(tap), for: .touchUpInside)
        circle.accessibilityLabel = "Count one tasbeeh"
        number.font = .monospacedDigitSystemFont(ofSize: 76, weight: .light)
        number.textColor = ivory
        number.textAlignment = .center
        number.adjustsFontSizeToFitWidth = true
        number.minimumScaleFactor = 0.3
        number.isUserInteractionEnabled = false
        number.translatesAutoresizingMaskIntoConstraints = false
        circle.addSubview(number)
        let hint = UILabel()
        hint.text = "TAP TO COUNT"
        hint.font = .systemFont(ofSize: 11, weight: .medium)
        hint.textColor = gold
        hint.textAlignment = .center
        today.font = .monospacedDigitSystemFont(ofSize: 19, weight: .medium)
        today.textColor = ivory
        today.textAlignment = .center
        undoButton.setTitle("Undo", for: .normal)
        undoButton.addTarget(self, action: #selector(undo), for: .touchUpInside)
        let reset = UIButton(type: .system)
        reset.setTitle("Reset session", for: .normal)
        reset.addTarget(self, action: #selector(resetSession), for: .touchUpInside)
        [undoButton, reset].forEach { $0.tintColor = gold }
        let actions = UIStackView(arrangedSubviews: [undoButton, reset])
        actions.axis = .horizontal
        actions.distribution = .fillEqually
        let footer = UILabel()
        footer.text = "A quiet moment of remembrance"
        footer.textColor = ivory.withAlphaComponent(0.5)
        footer.font = .systemFont(ofSize: 12)
        footer.textAlignment = .center
        let stack = UIStackView(arrangedSubviews: [title, ornament, dhikr, circle, hint, today, actions, footer])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false
        settings.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        view.addSubview(settings)
        let size = min(UIScreen.main.bounds.width - 80, UIScreen.main.bounds.height * 0.34, 290)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            dhikr.widthAnchor.constraint(equalTo: stack.widthAnchor),
            dhikr.heightAnchor.constraint(equalToConstant: 38),
            circle.widthAnchor.constraint(equalToConstant: size), circle.heightAnchor.constraint(equalToConstant: size),
            number.leadingAnchor.constraint(equalTo: circle.leadingAnchor, constant: 16),
            number.trailingAnchor.constraint(equalTo: circle.trailingAnchor, constant: -16),
            number.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
            actions.widthAnchor.constraint(equalTo: stack.widthAnchor),
            settings.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            settings.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -14),
            settings.widthAnchor.constraint(equalToConstant: 44), settings.heightAnchor.constraint(equalToConstant: 44)
        ])
        circle.layer.cornerRadius = size / 2
        observer = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in self?.render() }
        render()
    }
    deinit { if let observer = observer { NotificationCenter.default.removeObserver(observer) } }
    func render() {
        counts.refreshDay()
        number.text = String(counts.session)
        today.text = "Today  ·  \(counts.today)"
        undoButton.isEnabled = counts.undoAvailable
        circle.accessibilityValue = String(counts.session)
    }
    @objc func tap() {
        counts.tap()
        if counts.haptics { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
        render()
        UIView.animate(withDuration: 0.08, animations: { self.circle.transform = CGAffineTransform(scaleX: 0.97, y: 0.97) }) { _ in
            UIView.animate(withDuration: 0.12) { self.circle.transform = .identity }
        }
    }
    @objc func undo() { counts.undo(); render() }
    @objc func changeDhikr(_ control: UISegmentedControl) { UserDefaults.standard.set(control.selectedSegmentIndex, forKey: "dhikr") }
    @objc func longPress(_ recognizer: UILongPressGestureRecognizer) { if recognizer.state == .began { openSettings() } }
    @objc func resetSession() {
        let alert = UIAlertController(title: "Reset session?", message: "Today’s total will be kept.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in self?.counts.resetSession(); self?.render() })
        present(alert, animated: true)
    }
    @objc func openSettings() {
        guard presentedViewController == nil else { return }
        counts.refreshDay()
        let settings = SettingsViewController(counts: counts)
        settings.onSave = { [weak self] in self?.render() }
        present(UINavigationController(rootViewController: settings), animated: true)
    }
}

final class SettingsViewController: UIViewController {
    let counts: Counts
    let input = UITextField()
    let toggle = UISwitch()
    let error = UILabel()
    var onSave: (() -> Void)?
    init(counts: Counts) { self.counts = counts; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError("init(coder:) unavailable") }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = emerald
        title = "Settings"
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = gold
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save))
        let label = UILabel()
        label.text = "Adjust today’s count"
        label.textColor = ivory
        label.font = .systemFont(ofSize: 23, weight: .semibold)
        input.text = String(counts.today)
        input.keyboardType = .numberPad
        input.textColor = ivory
        input.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        input.font = .monospacedDigitSystemFont(ofSize: 32, weight: .regular)
        input.textAlignment = .center
        input.layer.cornerRadius = 12
        input.accessibilityLabel = "Today's count"
        let hint = UILabel()
        hint.text = "Set today’s total and the number in the counter."
        hint.numberOfLines = 0
        hint.textColor = ivory.withAlphaComponent(0.65)
        hint.font = .systemFont(ofSize: 14)
        error.textColor = .systemOrange
        error.numberOfLines = 0
        error.font = .systemFont(ofSize: 14)
        let hapticLabel = UILabel()
        hapticLabel.text = "Gentle haptics"
        hapticLabel.textColor = ivory
        toggle.isOn = counts.haptics
        toggle.onTintColor = gold
        let row = UIStackView(arrangedSubviews: [hapticLabel, toggle])
        row.axis = .horizontal
        let stack = UIStackView(arrangedSubviews: [label, input, hint, error, row])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            input.heightAnchor.constraint(equalToConstant: 72)
        ])
    }
    @objc func cancel() { dismiss(animated: true) }
    @objc func save() {
        guard counts.adjust(input.text ?? "") else { error.text = "Enter a whole number from 0 to 9,999,999."; return }
        counts.haptics = toggle.isOn
        onSave?()
        dismiss(animated: true)
    }
}

final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions options: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = CounterViewController()
        window?.makeKeyAndVisible()
        return true
    }
}
UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(AppDelegate.self))
