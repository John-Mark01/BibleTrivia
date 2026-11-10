//
//  ValidationAndPagingTests.swift
//  BibleTriviaTests
//

import Testing
@testable import BibleTrivia

struct ValidationTests {
    @Test(arguments: ["a@b.co", "john.doe+bible@example.org"])
    func validEmails(_ email: String) { #expect(Validation.isValid(email: email)) }

    @Test(arguments: ["", "plain", "a@b", "a@b.", "@example.com"])
    func invalidEmails(_ email: String) { #expect(!Validation.isValid(email: email)) }

    @Test(arguments: ["Jo", "Mary-Jane", "O'Brien", "Ана", "Jean Luc"])
    func validNames(_ name: String) { #expect(Validation.isValid(name: name)) }

    @Test(arguments: ["", "J", "R2D2", "  "])
    func invalidNames(_ name: String) { #expect(!Validation.isValid(name: name)) }

    @Test func passwordRules() {
        #expect(Validation.isValid(password: "Genesis1"))
        #expect(!Validation.isValid(password: "genesis1"))
        #expect(!Validation.isValid(password: "GENESIS1"))
        #expect(!Validation.isValid(password: "Genesis"))
        #expect(!Validation.isValid(password: "Gen1"))
    }

    @Test func ageRules() {
        #expect(Validation.isValid(age: "14"))
        #expect(!Validation.isValid(age: "13"))
        #expect(!Validation.isValid(age: "abc"))
        #expect(!Validation.isValid(age: "500"))
    }
}

struct PagedListTests {
    struct Item: Identifiable, Sendable { let id: Int }

    @Test func firstPageThenNextPage() {
        var list = PagedList<Item>(pageSize: 2)
        let first = list.begin(reset: true)
        #expect(first?.offset == 0)
        #expect(list.begin(reset: false) == nil) // already loading

        list.finish(with: [Item(id: 1), Item(id: 2)], reset: true)
        #expect(list.hasMore)

        let next = list.begin(reset: false)
        #expect(next?.offset == 2)
        list.finish(with: [Item(id: 3)], reset: false)
        #expect(!list.hasMore)
        #expect(list.items.map(\.id) == [1, 2, 3])
        #expect(list.begin(reset: false) == nil) // nothing more
    }

    @Test func appendSkipsDuplicates() {
        var list = PagedList<Item>(pageSize: 2)
        _ = list.begin(reset: true)
        list.finish(with: [Item(id: 1), Item(id: 2)], reset: true)
        _ = list.begin(reset: false)
        list.finish(with: [Item(id: 2), Item(id: 3)], reset: false)
        #expect(list.items.map(\.id) == [1, 2, 3])
    }

    @Test func failureKeepsItems() {
        var list = PagedList<Item>(pageSize: 2)
        _ = list.begin(reset: true)
        list.finish(with: [Item(id: 1), Item(id: 2)], reset: true)
        _ = list.begin(reset: false)
        list.fail()
        #expect(!list.isLoading)
        #expect(list.items.count == 2)
    }

    @Test func shouldLoadMoreNearTheEnd() {
        var list = PagedList<Item>(pageSize: 5)
        _ = list.begin(reset: true)
        list.finish(with: (1...5).map(Item.init), reset: true)
        #expect(!list.shouldLoadMore(after: Item(id: 1)))
        #expect(list.shouldLoadMore(after: Item(id: 3)))
        #expect(list.shouldLoadMore(after: Item(id: 5)))
    }
}
