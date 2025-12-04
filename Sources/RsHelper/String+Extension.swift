import Foundation

#if os(Windows)

extension String {
    static private let lock = NSLock()
    static nonisolated(unsafe) private let interpolationParameters = /\d+\$\(\w+\)/
    static nonisolated(unsafe) private var localizations: [String : [String : Any]] = [:]

    public init(
        localized keyAndValue: String,
        table: String? = nil,
        bundle: Bundle = Bundle.main,
        locale: Locale = .current,
        comment: String? = nil
    ) {
        self = keyAndValue

        let table = table ?? "Localizable"
        guard let path = bundle.path(forResource: "\(table).xcstrings") else {
            log.info("Failed to find string catalog \(table) in \(bundle.bundleURL.path)")
            return
        }

        String.lock.lock()
        defer { String.lock.unlock() }

        if !String.localizations.keys.contains(path) {
            guard let fileData = try? Data(contentsOf: URL(filePath: path)) else {
                log.info("Failed to read localization data of \(path)")
                return
            }
            guard let jsonObj = try? JSONSerialization.jsonObject(with: fileData) as? [String : Any] else {
                log.info("Failed to parse JSON of \(path)")
                return
            }
            guard let strings = jsonObj["strings"] as? [String : Any] else {
                log.info("Failed to load strings from \(path)")
                return
            }
            String.localizations[path] = strings
            log.info("Cached \(path)")
        }

        guard let strings = String.localizations[path],
            let kv = strings[keyAndValue] as? [String : Any],
            let loc = kv["localizations"] as? [String : Any],
            let trans = loc[locale.identifier] as? [String : Any],
            let unit = trans["stringUnit"] as? [String : Any],
            let v = unit["value"] as? String else {
            log.info("Failed to find \(keyAndValue) of \(locale.identifier)")
            return
        }

        self = v.replacing(String.interpolationParameters, with: "") // Ignore parameter, use format instead.
    }
}

#endif