# SwiftEvent

A simple Swift library for using libevent on linux and OS X.

## Usage
For libevent you need a basic runloop in order for it to work. This means your application will technically block for all code you put after the event loop.

This code should only be used in asynchronous situations, e.g. when you are implementing a **socket**.

### Creating and adding events
It is important you create events before you start the run loop. As all code run after it won't be called till the loop is broken.

##### Example 1: Creating an accept socket event
`Event(types: [.read, .persistent], fd: fileDescriptor, handler: self)`

Classes that handle events should implement the `EventHandler` protocol.

##### Example 2: Creating a write socket event
`Event(types: [.write], fd: fileDescriptor, handler: self)`

With write events it is a good idea to use non-persistent events; Usually when writing you want to write in chunks ( as you cannot send big chunks of data at once, depending on your OS etc. ).
Instead of using a while loop in whatever write function you use which usually returns the amount of bytes written; using libevent you can use the write event as the 'loop' itself, and be sure that the write occurs asynchronously while also allowing other work to be done in your app if the write is of a considerable size.

In order to re-activate a used write event:
`writeEvent.add()`


### Registering your events

Simply: 

`EventManager.shared.register(event)`

To remove again: 

`EventManager.shared.remove(event)`



### Starting the loop
This is as simple as:

`SwiftRunloop.start()`

or alternatively:

`EventManager.shared.run()`


