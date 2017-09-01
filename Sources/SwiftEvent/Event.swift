import EventC

typealias SocketEvent = OpaquePointer

enum EventType: Int16 {
	case timeout     = 0x01
	case read        = 0x02
	case write       = 0x04
	case signal      = 0x08
	case persistent  = 0x10
	case finalize    = 0x40
	case closed      = 0x80
}

protocol EventHandler {
	func readEvent()
	func writeEvent()
}
extension EventHandler {
	func readEvent() {}
	func writeEvent() {}
}

class Event {
	let types:         [EventType]
	let fd:            Int32
	var internalEvent: SocketEvent!
	var handler:       EventHandler?

	init(types: [EventType], fd: Int32, handler: EventHandler? = nil) {
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

	func handle(type: EventType) {
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

	func remove() {
		if let internalEvent = internalEvent {
			event_del(internalEvent)
		}
	}

	func add()
	{
		if let internalEvent = internalEvent {
			event_add(internalEvent, nil)
		}
	}

	func getEvent() -> SocketEvent {
		return internalEvent!
	}

	@inline(__always) final func toRaw() -> Int16 {
		return types.reduce(0) { return $0 + $1.rawValue }
	}
}
