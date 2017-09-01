
///
/// More logical name for starting the libevent
/// event loop.
///
public class SwiftRunloop {
    public static func start() {
        EventManager.shared.run()
    }
}
