import UIKit
import CleverTapSDK

class EventPageViewController: UIViewController {
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIStackView()
    
    private let eventNameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter Event Name"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let addPropertyButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Add Property", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let removePropertyButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Remove Last Property", for: .normal)
        btn.backgroundColor = .systemRed
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Send Event", for: .normal)
        btn.backgroundColor = .systemGreen
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - Data
    private var propertyRows: [PropertyRow] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Event Page"
        view.backgroundColor = .systemBackground
        
        setupLayout()
        setupActions()
        setupKeyboardObservers()
        setupTapToDismiss()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Layout
    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.axis = .vertical
        contentView.spacing = 15
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
        
        contentView.addArrangedSubview(eventNameField)
        contentView.addArrangedSubview(addPropertyButton)
        contentView.addArrangedSubview(removePropertyButton)
        contentView.addArrangedSubview(sendButton)
    }
    
    // MARK: - Setup Actions
    private func setupActions() {
        addPropertyButton.addTarget(self, action: #selector(addPropertyRow), for: .touchUpInside)
        removePropertyButton.addTarget(self, action: #selector(removePropertyRow), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(sendEvent), for: .touchUpInside)
    }
    
    // MARK: - Keyboard Handling
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let bottomInset = keyboardFrame.height - view.safeAreaInsets.bottom
        scrollView.contentInset.bottom = bottomInset + 20
        scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
    
    private func setupTapToDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Property Row Handling
    @objc private func addPropertyRow() {
        let row = PropertyRow()
        propertyRows.append(row)
        contentView.insertArrangedSubview(row, at: contentView.arrangedSubviews.count - 3)
    }
    
    @objc private func removePropertyRow() {
        guard let last = propertyRows.popLast() else { return }
        contentView.removeArrangedSubview(last)
        last.removeFromSuperview()
    }
    
    // MARK: - Send Event
    @objc private func sendEvent() {
        guard let eventName = eventNameField.text, !eventName.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert("Event name cannot be empty")
            return
        }
        
        var props: [String: Any] = [:]
        
        for row in propertyRows {
            guard let propName = row.propertyNameField.text, !propName.isEmpty else {
                showAlert("Property name cannot be empty.")
                return
            }
            
            let selectedType = row.typeSelector.titleForSegment(at: row.typeSelector.selectedSegmentIndex) ?? "String"
            let rawValue = row.valueField.text ?? ""
            
            switch selectedType {
            case "String":
                props[propName] = rawValue
                
            case "Number":
                if let num = Double(rawValue) {
                    props[propName] = num
                } else {
                    showAlert("Invalid number for property '\(propName)'")
                    return
                }
                
            case "Bool":
                let lower = rawValue.lowercased()
                if lower == "true" {
                    props[propName] = true
                } else if lower == "false" {
                    props[propName] = false
                } else {
                    showAlert("Boolean must be 'true' or 'false' for property '\(propName)'")
                    return
                }
                
            case "Date":
                if let date = row.selectedDate {
                    props[propName] = date
                } else {
                    showAlert("Please pick a date for '\(propName)'")
                    return
                }
                
            default:
                props[propName] = rawValue
            }
        }
        
        // Send event to CleverTap
        CleverTap.sharedInstance()?.recordEvent(eventName, withProps: props)
        
        showAlert("Event '\(eventName)' sent successfully with \(props.count) properties!")
        clearAll()
    }
    
    private func clearAll() {
        eventNameField.text = ""
        propertyRows.forEach { $0.removeFromSuperview() }
        propertyRows.removeAll()
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
