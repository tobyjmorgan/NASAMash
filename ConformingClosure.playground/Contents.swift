//: Playground - noun: a place where people can play

import UIKit

/////////////////////////////////////////////////////////
// Your playground set-up
protocol Foo {}

struct Bar: Foo {
    static func action(_ i: Int) -> [Bar] {
        return []
    }
}
/////////////////////////////////////////////////////////



// DEFINITION (for the sake of discussion):
// Conforming Closure
// A closure that contains a type that conforms to a
// protocol, such that the closure's signature should be
// recognized by the compiler as conforming to the expected
// closure signature (as either a parameter or return type).
// e.g.
// (Int) -> [Bar] is a conforming closure for (Int) -> [Foo]
// where Bar conforms to protocol Foo


/////////////////////////////////////////////////////////
// This struct pretends to be the API Client's fetch method
// and expects a closure that conforms to return type of [Foo]
struct ActionPerformer {
    func performsAction<T: Foo>(closure: (Int) -> [T]) -> [T] {
        return closure(1)
    }
}
/////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////
// I tried the version below first and it didn't work...
// Seems it has to use a generic, conforming to Foo rather
// than Foo directly
//struct ActionPerformer {
//    func performsAction(closure: (Int) -> [Foo]) -> [Foo] {
//        return closure(1)
//    }
//}
/////////////////////////////////////////////////////////





/////////////////////////////////////////////////////////
// Now create an instance of the [Bar] closure that should
// be a conforming closure
//let baz: (Int) -> [Foo] = Bar.action // nope
//let baz: (Int) -> [Foo] = Bar.action as! (Int) -> [Foo] // nope
//let baz: (Int) -> [Foo] = Bar.action as! (Int) -> [Bar as! Foo] // nope
let baz = Bar.action // not casting it to a particular type - works
/////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////
// Now to pass it in to our simulation of API Client's fetch
let performer = ActionPerformer()
performer.performsAction(closure: baz) // nice - works!
// So when passing the closure in as a parameter it recognizes
// [Bar] as conforming to [Foo]
/////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////
// Now to get a closure (as if getting it from the endpoint
// enumeration case)
//struct ActionObtainer {
//    func getAction() -> (Int) -> [Foo] {
//        return Bar.action // nope - doesn't work
//    }
//}
// So when returning the closure it does not recognize Bar
// as conforming to Foo
/////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////
// I also tried making this guy generic over T conforming
// to Foo
//struct ActionObtainer {
//    func getAction<T: Foo>() -> (Int) -> [T] {
//        return Bar.action // no dice
//    }
//}
/////////////////////////////////////////////////////////



// CONCLUSION
// So in summary, you CAN pass a conforming closure INTO a
// function, but only if you use generics.
// But you CANNOT return a conforming closure FROM a function




