# SwiftEvent

A simple Swift library for using libevent on linux and OS X.

##Usage
For libevent you need a basic runloop in order for it to work. This means your application will technically block for all code you put after the event loop.

This code should only be used in asynchronous situations, e.g. when you are implementing a **socket**.

###Creating and adding events
It is important you create events before you start the run loop. As all code run after it won't be called till the loop is broken.

#####Example 1: Creating an accept socket event
`Event(types: [.read, .persistent], fd: fileDescriptor, handler: self)`

###Starting the loop
This is as simple as:

`SwiftRunloop.start()`


