import Foundation


/// Wraps an object in a weak reference.
/// This is useful for creating an array of weak references.
public class WeakWrapper<T: AnyObject> {
    
    public weak var object: T?
    
    public init(_ object: T) {
        self.object = object
    }
    
    
}

public extension RangeReplaceableCollection {
    
    /**
     Removes the first element that satisfies the given
     predicate.
     
     This method usually has better
     performance characteristics than `self.removeAll(where:)`
     if only a single element needs to be removed from the
     collection because it returns after the first time that
     the predicate returns true, whereas `self.removeAll(where:)`
     will traverse the entire collection.
     
     - Parameter shouldBeRemoved: A closure that takes an element of
           the collection as its argument and returns a Boolean value
           indicating whether the element should be removed
           from the collection.
     
     - Returns: The element of the collection that was removed
           or nil if an item was not removed.
     */
    @discardableResult
    mutating func removeFirst(
        where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows -> Element? {
        
        for (indx, element) in zip(self.indices, self) {
            if try shouldBeRemoved(element) {
                self.remove(at: indx)
                return element
            }
        }
        return nil
    }

}

