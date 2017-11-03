import CEvent

typealias SocketEvent = OpaquePointer

public enum EventType: Int16 {
	case timeout     = 0x01
	case read        = 0x02
	case write       = 0x04
	case signal      = 0x08
	case persistent  = 0x10
	case finalize    = 0x40
	case closed      = 0x80
}

public protocol EventHandler {
	func readEvent()
	func writeEvent()
}
public extension EventHandler {
	func readEvent() {}
	func writeEvent() {}
}

public class Event {
	public let types:   [EventType]
	public let fd:      Int32
	var internalEvent:  SocketEvent!
	public var handler: EventHandler?

	public init(types: [EventType], fd: Int32, handler: EventHandler? = nil) {
		self.types = types
		self.fd    = fd
		self.handler = handler
		internalEvent = event_new(
			EventManager.shared.eventBase,
			fd,
			toRaw(),
			{ (fileDescriptor, eventTypeRaw, instancePtr) in
				guard let eventType = EventType(rawValue: eventTypeRaw) else { return }
				let event = unsafeBitCast(instancePtr, to: Event.self)
				event.handle(type: eventType)
			},
			Unmanaged.passUnretained(self).toOpaque()
		)
	}

	deinit
	{
		if let internalEvent = internalEvent {
			event_del(internalEvent)
			event_free(internalEvent)
		}
	}

	internal func handle(type: EventType) {
		switch(type) {
		case .read:
			handler?.readEvent()
			break

		case .write:
			handler?.writeEvent()
			break

		default:
			print("[Event] Unhandled type: \(type)")
			break
		}
	}

	public func remove() {
		if let internalEvent = internalEvent {
			event_del(internalEvent)
		}
	}

	public func add()
	{
		if let internalEvent = internalEvent {
			event_add(internalEvent, nil)
		}
	}

	internal func getEvent() -> SocketEvent {
		return internalEvent!
	}

	@inline(__always) final func toRaw() -> Int16 {
		return types.reduce(0) { return $0 + $1.rawValue }
	}
}
