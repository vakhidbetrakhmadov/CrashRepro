import UIKit
import Polling

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let somePollingService = SomePollingService()
        print(somePollingService)

        let pollingServiceWrapper = PollingServiceWrapper(pollingService: somePollingService)
        print(pollingServiceWrapper)
    }
}
