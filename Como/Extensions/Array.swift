// Extension to Array that adds insertion and removal operations that make copies
// instead of mutating the array

extension Array {
    
    func appended(newValue: Element) -> Array {
        var copy = self
        copy.append(newValue)
        return copy
    }
    
    func inserted(newValue: Element, atIndex index: Int) -> Array {
        var copy = self
        copy.insert(newValue, at: index)
        return copy
    }
    
    func removedRange(subRange: Range<Int>) -> Array {
        var copy = self
        copy.removeSubrange(subRange)
        return copy
    }
    
    func removedAtIndex(index: Int) -> Array {
        let (_, arr) = takeAtIndex(index: index)
        return arr
    }
    
    func removedLast() -> Array {
        let (_, arr) = takeLast()
        return arr
    }
    
    func takeAtIndex(index: Int) -> (Element, Array) {
        var copy = self
        let result = copy.remove(at: index)
        return (result, copy)
    }
    
    func takeLast() -> (Element, Array) {
        var copy = self
        let result = copy.removeLast()
        return (result, copy)
    }
    
    mutating func prepend(newValue: Element) {
        insert(newValue, at: 0)
    }
    
    func prepended(newValue: Element) -> Array {
        var copy = self
        copy.prepend(newValue: newValue)
        return copy
    }
}

// Example how to use
/*
var arr = [1, 2, 3, 4, 5]

let removedSecond = arr.removedAtIndex(1)
let insertedFirst = arr.inserted(8, atIndex: 0)
let tookLast = arr.takeLast()

print(arr)           // [1, 2, 3, 4, 5]
print(removedSecond) // [1, 3, 4, 5]
print(insertedFirst) // [8, 1, 2, 3, 4, 5]
print(tookLast)      // (5, [1, 2, 3, 4])
 */


