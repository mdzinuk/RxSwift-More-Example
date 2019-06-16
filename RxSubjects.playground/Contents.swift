import Foundation
import RxSwift

/*
 SUBJECTS: When we need developing apps to manually add new values onto runtime that will be emitted to subscribers is called Subjects.
 
 Subjects work as both Observable and Observer.
 
 There are four subject types in RxSwift~
 */

example(of: "publishing subject") {
    // Starts empty and only emits new elements to subscribers. 
    // Useful when you simply want subscribers to be notified of new events from the point at which they subscribed, until they either unsubscribe, 
    // or the subject has terminated with a .completed or .error event.
    
    // Emits after subscriber
    // Would not emits anything after dispose
    // Will send Completed event after completion.
    let subject = PublishSubject<String>()
    subject.onNext("Is anyone listening?")
    let subscriptionOne = subject
        .subscribe(onNext: { string in
            print(string)
        })
    
    subject.onNext("1")
    subject.onNext("2")
    
    let subscriptionTwo = subject
        .subscribe { event in
            print("2)", event.element ?? event)
    }
    subject.onNext("3")
    
    subscriptionOne.dispose()
    subject.onNext("4")
    
    subject.onCompleted()
    subject.onNext("5")
    subscriptionTwo.dispose()
    
    let disposeBag = DisposeBag()
    subject.subscribe {
        print("3)", $0.element ?? $0)
        }
        .disposed(by: disposeBag)
    subject.onNext("?")
}

example(of: "Behavior Subject") {
    // Starts with an initial value and replays it or the latest element to new subscribers
    // Behave same as Publisher subject except they will reply the latest value to all the subscribers.
    enum MyError: Error { case anError }
    
    func description<T: CustomStringConvertible>(label: String, event: Event<T>) {
        print(label, event.element ?? event.error ?? "" )
    }
    
    let subject = BehaviorSubject(value: "Init value")
    let disposeBag = DisposeBag()
    subject.onNext("X")
    
    subject.subscribe{
        description(label: "1)", event: $0)
        }.disposed(by: disposeBag)
    
    subject.onError(MyError.anError)
    subject.subscribe{
        description(label: "2)", event: $0)
        }.disposed(by: disposeBag)
}

example(of: "ReplaySubject") {
    // Initialized with a buffer size and will maintain a buffer of elements up to that size and replay it to new subscribers
    // temporarily cache, or buffer, the latest elements it emits, up to a specified size of our choosing
    enum MyError: Error { case anError }
    func description<T: CustomStringConvertible>(label: String, event: Event<T>) {
        print(label, event.element ?? event.error ?? "")
    }
    
    let subject = ReplaySubject<String>.create(bufferSize: 2)
    let disposeBag = DisposeBag()
    
    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")
    
    subject.subscribe { description(label: "1)", event: $0) }
        .disposed(by: disposeBag)
    subject.subscribe { description(label: "2)", event: $0) }
        .disposed(by: disposeBag)
    
    subject.onNext("4")
    subject.subscribe { description(label: "3)", event: $0) }
        .disposed(by: disposeBag)
    
    subject.onError(MyError.anError)
    subject.dispose()
    subject.subscribe { description(label: "4)", event: $0) }
        .disposed(by: disposeBag)
}

example(of: "Variable") {
    // Wraps a BehaviorSubject, preserves its current value as state, and replays only the latest/initial value to new subscribers
    enum MyError: Error { case anError }
    func description<T: CustomStringConvertible>(label: String, event: Event<T>) {
        print(label, event.element ?? event.error ?? "")
    }
    
    let variable = Variable<String>("InitialValue")
    let disposeBag = DisposeBag()
    
    variable.value = "New value"
    variable.asObservable()
        .subscribe { description(label: "1)", event: $0) }
        .disposed(by: disposeBag)
    
    variable.value = "1"
    variable.asObservable()
        .subscribe { description(label: "2)", event: $0) }
        .disposed(by: disposeBag)
    
    variable.value = "2"
}



/*
 More Example...
 */
example(of: "PublishSubject") {
    let disposeBag = DisposeBag()
    let dealtHandler = PublishSubject<[(String, Int)]>()
    
    func deal(_ cardCount: UInt) {
        var deck = cards
        var cardRemaining: UInt32 = 52
        var hand = [(String, Int)]()
        
        for _ in 0..<cardCount {
            let randomIndex = Int(arc4random_uniform(cardRemaining))
            hand.append(deck[randomIndex])
            deck.remove(at: randomIndex)
            cardRemaining -= 1
        }
        
        // Add code to update dealtHand here
        if points(for: hand) > 21 {
            dealtHandler.onError(HandError.busted)
        } else {
            dealtHandler.onNext(hand)
        }
    }
    
    dealtHandler.subscribe(onNext: { print(cardString(for: $0), "for", points(for: $0), "points")},
                           onError: { print(String(describing: $0).capitalized) })
        .disposed(by: disposeBag)
    
    deal(10)
}


/*
 More Example of sync and async...
 */
var array = [1, 2, 3]
for number in array {
    print(number)
    array = [4, 5, 6]
}
print(array)


var array2 = [1, 2, 3]
var currentIndex = 0
func printNext() {
    print(array2[currentIndex])
    if currentIndex != array2.count-1 {
        currentIndex += 1
    }
}
printNext()
printNext()
printNext()
printNext()
printNext()
printNext()



