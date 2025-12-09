import UIKit

class PropertyRow: UIView {
    let propertyNameField = UITextField()
    let valueField = UITextField()
    let typeSelector = UISegmentedControl(items: ["String", "Number", "Bool", "Date"])
    var datePicker: UIDatePicker?
    var selectedDate: Date?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        propertyNameField.placeholder = "Property Name"
        propertyNameField.borderStyle = .roundedRect
        
        valueField.placeholder = "Property Value"
        valueField.borderStyle = .roundedRect
        
        typeSelector.selectedSegmentIndex = 0
        typeSelector.addTarget(self, action: #selector(typeChanged), for: .valueChanged)
        
        stack.addArrangedSubview(propertyNameField)
        stack.addArrangedSubview(typeSelector)
        stack.addArrangedSubview(valueField)
        
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    @objc private func typeChanged() {
        if typeSelector.titleForSegment(at: typeSelector.selectedSegmentIndex) == "Date" {
            let picker = UIDatePicker()
            picker.datePickerMode = .dateAndTime
            picker.preferredDatePickerStyle = .wheels
            picker.addTarget(self, action: #selector(dateSelected(_:)), for: .valueChanged)
            valueField.inputView = picker
            datePicker = picker
        } else {
            valueField.inputView = nil
            selectedDate = nil
        }
        valueField.reloadInputViews()
    }
    
    @objc private func dateSelected(_ sender: UIDatePicker) {
        selectedDate = sender.date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        valueField.text = formatter.string(from: sender.date)
    }
}
