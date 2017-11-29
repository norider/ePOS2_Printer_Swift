import UIKit

protocol DiscoveryViewDelegate {
    func discoveryView(sendor:DiscoveryViewController, onSelectPrinterTarget target:String)
}

class DiscoveryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, Epos2DiscoveryDelegate {
    
    
    @IBOutlet weak var printerView: UITableView!
    
    private var printerList: [Epos2DeviceInfo] = []
    private var filterOption: Epos2FilterOption = Epos2FilterOption()
    
    var delegate: DiscoveryViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        filterOption.deviceType = EPOS2_TYPE_PRINTER.rawValue
        
        printerView.delegate = self
        printerView.dataSource = self
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let result = Epos2Discovery.start(filterOption, delegate: self)
        if result != EPOS2_SUCCESS.rawValue {
            //ShowMsg showErrorEpos(result, method: "start")
        }
        printerView.reloadData()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        while Epos2Discovery.stop() == EPOS2_ERR_PROCESSING.rawValue {
            // retry stop function
        }
        
        printerList.removeAll()
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowNumber: Int = 0
        if section == 0 {
            rowNumber = printerList.count
        }
        else {
            rowNumber = 1
        }
        return rowNumber
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "basis-cell"
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(identifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: identifier)
        }
        
        if indexPath.section == 0 {
            if indexPath.row >= 0 && indexPath.row < printerList.count {
                cell!.textLabel?.text = printerList[indexPath.row].deviceName
                cell!.detailTextLabel?.text = printerList[indexPath.row].target
            }
        }
        else {
            cell!.textLabel?.text = "other..."
            cell!.detailTextLabel?.text = ""
        }
        
        return cell!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if delegate != nil {
                delegate!.discoveryView(self, onSelectPrinterTarget: printerList[indexPath.row].target)
                delegate = nil
                navigationController?.popToRootViewControllerAnimated(true)
            }
        }
        else {
            performSelectorOnMainThread("connectDevice", withObject:self, waitUntilDone:false)
        }

    }
    func connectDevice() {
        Epos2Discovery.stop()
        printerList.removeAll()
        
        let btConnection = Epos2BluetoothConnection()
        let BDAddress = NSMutableString()
        let result = btConnection.connectDevice(BDAddress)
        if result == EPOS2_SUCCESS.rawValue {
            delegate?.discoveryView(self, onSelectPrinterTarget: BDAddress as String)
            delegate = nil
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        else {
            Epos2Discovery.start(filterOption, delegate:self)
            printerView.reloadData()
        }
    }
    @IBAction func restartDiscovery(sender: AnyObject) {
        var result = EPOS2_SUCCESS.rawValue;
        
        while true {
            result = Epos2Discovery.stop()
            
            if result != EPOS2_ERR_PROCESSING.rawValue {
                if (result == EPOS2_SUCCESS.rawValue) {
                    break;
                }
                else {
                    MessageView.showErrorEpos(result, method:"stop")
                    return;
                }
            }
        }
        
        printerList.removeAll()
        printerView.reloadData()

        result = Epos2Discovery.start(filterOption, delegate:self)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"start")
        }
    }
    func onDiscovery(deviceInfo: Epos2DeviceInfo!) {
        printerList.append(deviceInfo)
        printerView.reloadData()
    }
}