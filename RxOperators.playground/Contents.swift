//: Playground - noun: a place where people can play

import Foundation
import RxSwift


example(of: "IgnoreElements") {
    // Ignore everything except completed event.
    let strikes = PublishSubject<String>()
    let disposeBag = DisposeBag()
    
    strikes
        .ignoreElements()
        .subscribe({_ in
            print("You are out!")
        })
        .addDisposableTo(disposeBag)
    
    strikes.onNext("X")
    strikes.onNext("Y")
    strikes.onNext("Z")
    strikes.onCompleted()
}

example(of: "EleementAt") {
    // Ignore element with providing n(th) order element
    let strikes = PublishSubject<String>()
    let disposeBag = DisposeBag()
    
    strikes
        .elementAt(2)
        .subscribe({ _ in
            print("You're out!")
        })
        .addDisposableTo(disposeBag)
    
    strikes.onNext("X")
    strikes.onNext("Y")
    strikes.onNext("Z")
    strikes.onCompleted()
}

example(of: "SkipUntil") {
    // Skip emission untill the certain number of element
    let disposeBag = DisposeBag()
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<Int>()
    
    subject
        .skipUntil(trigger)
        .subscribe(onNext: {
            print($0)
        })
        .addDisposableTo(disposeBag)
    
    subject.onNext("A")
    subject.onNext("B")
    trigger.onNext(3)
    subject.onNext("D")
}

example(of: "take") {
    // Opposite of skipping
    let disposeBag = DisposeBag()
    Observable
        .of(1, 2, 3, 4, 5, 6)
        .take(3)
        .subscribe(onNext: {
            print($0) })
        .addDisposableTo(disposeBag)
}

example(of: "distinctUntilChanged(_:)") {
    //prevents duplicates that are right next to each other(sequential pair of elements)
    let disposeBag = DisposeBag()
    Observable.of("A", "A", "B", "B", "A")
        .distinctUntilChanged()
        .subscribe(onNext: {
            print($0) })
        .disposed(by: disposeBag)
}

example(of: "flatMap") {
    // Merge observable sequences into single sequence
    struct Student {
        var score: Variable<Int>
    }
    
    let disposeBag = DisposeBag()
    let ryan = Student(score: Variable(80))
    let charlotte = Student(score: Variable(90))
    let student = PublishSubject<Student>()
    
    student.asObservable()
        .flatMap {
            $0.score.asObservable()
        }
        .subscribe(onNext: {
            print($0)
        })
        .addDisposableTo(disposeBag)
    
    student.onNext(ryan)
    ryan.score.value = 85
    
    student.onNext(charlotte)
    charlotte.score.value = 45
    ryan.score.value = 81
}

/*
 More Example...
 */
example(of: "usage") {
    let disposeBag = DisposeBag()
    let phoneNumbers = ["603-555-1212": "Florent", "212-555-1212": "Junior", "408-555-1212": "Marin", "617-555-1212": "Scott"]
    
    func numberFormatter(from inputs: [Int]) -> String {
        var phone = inputs.map(String.init).joined()
        
        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 3)
        )
        
        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 7)
        )
        
        return phone
    }
    
    let input = PublishSubject<Int>()
    
    input.skipWhile { $0 == 0 }
        .filter { $0 < 10 }
        .take(10)
        .toArray()
        .subscribe(onNext: {
            let phone = numberFormatter(from: $0)
            
            if let contact = phoneNumbers[phone] {
                print("Dialing \(contact) (\(phone))...")
            } else {
                print("Contact not found")
            }
        })
        .addDisposableTo(disposeBag)
    
    input.onNext(0)
    input.onNext(603)
    
    input.onNext(2)
    input.onNext(1)
    
    // Confirm that 7 results in "Contact not found", and then change to 2 and confirm that Junior is found
    input.onNext(7)
    
    "5551212".characters.forEach {
        if let number = (Int("\($0)")) {
            input.onNext(number)
        }
    }
    
    input.onNext(9)
}

