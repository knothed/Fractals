public extension LSystem {
    /// Apply the system to a string, character by character, using the production rules.
    func apply(to input: String) -> String {
        var result = ""

        for char in input {
            if let rule = self.rule(for: char) {
                result.append(contentsOf: rule.successor)
            } else {
                result.append(char)
            }
        }

        return result
    }

    /// Find the production rule for a given character, if existing.
    private func rule(for char: Character) -> ProductionRule? {
        for rule in productionRules {
            if rule.predecessor == String(char) { return rule }
        }

        return nil
    }

    /// Apply the system multiple times to a string, i.e. evolve the system `count` times.
    func apply(count: Int, to input: String) -> String {
        (0 ..< count).reduce(input) { string, _ in
            apply(to: string)
        }
    }
}
