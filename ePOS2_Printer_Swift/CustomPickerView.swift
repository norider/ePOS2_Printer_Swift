import UIKit

public protocol CustomPickerViewDelegate {
    func customPickerView(pickerView: CustomPickerView, didSelectItem text: String, itemValue value: Any) -> Void
}

public class CustomPickerDataSource {
    private var textItems: [String] = []
    private var valueItems: [Any] = []
    
    var count: Int {
        return textItems.count
    }
    public func addItem(text: String, value: Any) {
        textItems.append(text)
        valueItems.append(value)
    }
    func textItem(index: Int) -> String {
        return textItems[index]
    }
    func valueItem(index: Int) -> Any {
        return valueItems[index]
    }
}

public class CustomPickerView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    private var backView:UIView!
    private var baseView:UIView!
    private var pickerView: UIPickerView!
    private var toolBar: UIToolbar!
    private var toolBarItems: [UIBarButtonItem]!
    
    public var dataSource: CustomPickerDataSource? {
        didSet {
            pickerView.reloadAllComponents()
        }
    }
    public var delegate: CustomPickerViewDelegate!
    
    convenience public init() {
        self.init(frame: CGRectMake(0, 0, 100, 100))
    }
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initializePicker()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializePicker()
    }
    
    private func initializePicker() {
        pickerView = UIPickerView()
        toolBar = UIToolbar()
        baseView = UIView()
        backView = UIView()
        toolBarItems = []
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        toolBar.translucent = true
        
        let screenSize = UIScreen.mainScreen().bounds.size
        let pickerHeight = screenSize.height / 3
        let toolbarHeight:CGFloat = 44
        
        baseView.bounds = CGRectMake(0, 0, screenSize.width, pickerHeight)
        baseView.frame = CGRectMake(0, screenSize.height, screenSize.width, pickerHeight)
        pickerView.bounds = CGRectMake(0, 0, screenSize.width, pickerHeight - toolbarHeight)
        pickerView.frame = CGRectMake(0, 44, screenSize.width, pickerHeight - toolbarHeight)
        toolBar.bounds = CGRectMake(0, 0, screenSize.width, toolbarHeight)
        toolBar.frame = CGRectMake(0, 0, screenSize.width, toolbarHeight)
        toolBar.sizeToFit()
        
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target:self, action:"didTouchDone")
        toolBarItems! += [space, doneButtonItem]
        
        baseView.backgroundColor = UIColor.whiteColor()
        toolBar.barStyle = UIBarStyle.BlackTranslucent
        
        toolBar.setItems(toolBarItems, animated: true)
        baseView.addSubview(toolBar)
        baseView.addSubview(pickerView)
        
        self.bounds = CGRectMake(0, 0, screenSize.width, screenSize.height)
        self.frame = CGRectMake(0, screenSize.height, screenSize.width, screenSize.height)
        backView.bounds = CGRectMake(0, 0, screenSize.width, screenSize.height)
        backView.frame = CGRectMake(0, 0, screenSize.width, screenSize.height)
        backView.backgroundColor = UIColor.grayColor()
        backView.alpha = 0.5
        
        self.addSubview(backView)
        self.addSubview(baseView)
    }
    public func showPicker() {
        let screenSize = UIScreen.mainScreen().bounds.size
        let pickerSize = self.baseView.frame.size

        self.frame = CGRectMake(0, 0, screenSize.width, screenSize.height)
        UIView.animateWithDuration(0.2) {
            self.baseView.frame = CGRectMake(0, screenSize.height - pickerSize.height, screenSize.width, pickerSize.height)
        }
    }
    func didTouchDone() {
        let screenSize = UIScreen.mainScreen().bounds.size
        let pickerSize = self.baseView.frame.size
        
        UIView.animateWithDuration(0.2, delay:0.0, options: UIViewAnimationOptions.TransitionNone, animations:{() -> Void in
                self.baseView.frame = CGRectMake(0, screenSize.height, screenSize.width, pickerSize.height)
            }, completion:{(finished: Bool) -> Void in
                self.frame = CGRectMake(0, screenSize.height, screenSize.width, screenSize.height)
            })
    }
    
    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        if dataSource == nil {
            return 0
        }
        return 1
    }
    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if dataSource == nil {
            return 0
        }
        return dataSource!.count
    }
    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource?.textItem(row)
    }
    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if dataSource == nil {
            return
        }
        
        delegate?.customPickerView(self, didSelectItem: dataSource!.textItem(row), itemValue: dataSource!.valueItem(row))
    }
    
}