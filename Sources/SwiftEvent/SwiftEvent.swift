
///
/// More logical name for starting the libevent
/// event loop.
///
class SwiftRunloop {
    static func start() {
        EventManager.shared.run()
    }
}
