import Foundation

public struct Sitemap {
    public let urls: [Sitemap.URL]

    public init(urls: [Sitemap.URL]) {
        self.urls = urls
    }
}

extension Sitemap {
    public var xml: String {
        """
        <?xml version="1.0" encoding="UTF-8"?>
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
        \(urls.map(\.xml).joined(separator: "\n"))
        </urlset>
        """
    }
}

extension Sitemap {
    public struct URL {
        public let location: Foundation.URL
        public let metadata: MetaData

        public struct MetaData: Sendable {
            public let lastModification: Date?
            public let changeFrequency: Sitemap.URL.ChangeFrequency?
            public let priority: Float?

            public init(
                lastModification: Date? = nil,
                changeFrequency: Sitemap.URL.ChangeFrequency? = nil,
                priority: Float? = nil
            ) {
                self.lastModification = lastModification
                self.changeFrequency = changeFrequency
                self.priority = priority
            }

            public static let empty: Self = .init(
                lastModification: nil,
                changeFrequency: nil,
                priority: nil
            )
        }

        public init(
            location: Foundation.URL,
            lastModification: Date? = nil,
            changeFrequency: Sitemap.URL.ChangeFrequency? = nil,
            priority: Float? = nil
        ) {
            self.location = location
            self.metadata = .init(
                lastModification: lastModification,
                changeFrequency: changeFrequency,
                priority: priority
            )
        }
    }
}

extension Sitemap.URL {
    public var xml: String {
        var elements = [
            "<loc>\(location.absoluteString)</loc>"
        ]

        if let lastModification = metadata.lastModification {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            elements.append("<lastmod>\(formatter.string(from: lastModification))</lastmod>")
        }
        if let changeFrequency = metadata.changeFrequency {
            elements.append("<changefreq>\(changeFrequency.rawValue)</changefreq>")
        }
        if let priority = metadata.priority {
            elements.append("<priority>\(priority)</priority>")
        }

        return "<url>\n\(elements.joined(separator: "\n"))\n</url>"
    }
}

extension Sitemap.URL {
    public enum ChangeFrequency: String, Codable, Hashable, Sendable {
        case always
        case hourly
        case daily
        case weekly
        case monthly
        case yearly
        case never
    }
}

extension [Sitemap.URL] {
    public init<Page: Hashable>(
        router: (_ page: Page) -> Foundation.URL,
        _ dictionary: [Page: Sitemap.URL.MetaData]
    ) {

        self = dictionary.map { page, metadata in
            let location = router(page)

            return Sitemap.URL(
                location: location,
                lastModification: metadata.lastModification,
                changeFrequency: metadata.changeFrequency,
                priority: metadata.priority
            )
        }
    }
}
