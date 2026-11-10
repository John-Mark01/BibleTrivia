//
//  PagedList.swift
//  BibleTrivia
//

import Foundation

/// An offset-paginated list. Usage from a store:
///
///     guard let page = list.begin(reset: reset) else { return }
///     do { list.finish(with: try await fetch(page.offset, page.limit), reset: reset) }
///     catch { list.fail(); alerts.show(error) }
struct PagedList<Item: Identifiable & Sendable>: Sendable {
    private(set) var items: [Item] = []
    private(set) var hasMore = true
    private(set) var isLoading = false
    let pageSize: Int

    init(pageSize: Int = 20) {
        self.pageSize = pageSize
    }

    /// True when `item` is near the end and another page should be requested.
    func shouldLoadMore(after item: Item) -> Bool {
        guard hasMore, !isLoading, let index = items.firstIndex(where: { $0.id == item.id }) else { return false }
        return index >= items.count - 3
    }

    /// Marks a load as started and returns the range to fetch, or `nil` if a
    /// load is already running or there is nothing more to fetch.
    mutating func begin(reset: Bool) -> (offset: Int, limit: Int)? {
        guard !isLoading, reset || hasMore else { return nil }
        isLoading = true
        return (reset ? 0 : items.count, pageSize)
    }

    mutating func finish(with page: [Item], reset: Bool) {
        if reset {
            items = page
        } else {
            let existing = Set(items.map(\.id))
            items.append(contentsOf: page.filter { !existing.contains($0.id) })
        }
        hasMore = page.count == pageSize
        isLoading = false
    }

    mutating func fail() {
        isLoading = false
    }

    mutating func remove(where shouldRemove: (Item) -> Bool) {
        items.removeAll(where: shouldRemove)
    }

    mutating func replace(_ item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        }
    }

    mutating func prepend(_ item: Item) {
        items.removeAll { $0.id == item.id }
        items.insert(item, at: 0)
    }

    mutating func clear() {
        self = PagedList(pageSize: pageSize)
    }
}
