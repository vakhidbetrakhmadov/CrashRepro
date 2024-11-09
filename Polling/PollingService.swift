import Foundation

public protocol PollingService {}

public final class PollingServiceWrapper<Service: PollingService> {
    public init(pollingService: Service, debounceInterval: TimeInterval = 0.5) {
        print(pollingService)
        print(debounceInterval)
    }
}