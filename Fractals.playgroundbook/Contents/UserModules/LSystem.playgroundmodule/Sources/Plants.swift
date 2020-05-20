/// Plants contains some L-Systems which describe plants.
public enum Plants {
    public static let farn1 = LSystemEvolutionDrawingDescription(
        system: LSystem(
            startString: "F",
            productionRules: [
                "F" ~> "F[-F]F[+F][F]"
            ],
            drawingRules: [
                "F": .draw,
                "+": .turnRight(angle: 25),
                "-": .turnLeft(angle: 25),
                "[": .saveState,
                "]": .restoreState,
            ]
        ),
        gradient: .green,
        startingAngle: .angle(45),
        startGeneration: 0,
        maxGeneration: 5,
        lineWidthRange: 1 ..< 2
    )

    public static let weed = LSystemEvolutionDrawingDescription(
        system: LSystem(
            startString: "X",
            productionRules: [
                "F" ~> "FF",
                "X" ~> "F[+X]F[-X]+X"
            ],
            drawingRules: [
                "F": .draw,
                "X": .draw,
                "-": .turnLeft(angle: 25),
                "+": .turnRight(angle: 25),
                "[": .saveState,
                "]": .restoreState
            ]
        ),
        gradient: .green,
        startingAngle: .angle(90),
        startGeneration: 0,
        maxGeneration: 8,
        lineWidthRange: 1.5 ..< 3
    )

    public static let binaryTree = LSystemEvolutionDrawingDescription(
       system: LSystem(
           startString: "0",
           productionRules: [
               "0" ~> "1[-0]+0",
               "1" ~> "11"
           ],
           drawingRules: [
               "0": .draw,
               "1": .draw,
               "+": .turnRight(angle: 45),
               "-": .turnLeft(angle: 45),
               "[": .saveState,
               "]": .restoreState
           ]
       ),
       gradient: .green,
       startingAngle: .angle(90),
       startGeneration: 0,
       maxGeneration: 8
    )

    public static let farn2 = LSystemEvolutionDrawingDescription(
        system: LSystem(
            startString: "aF",
            productionRules: [
                "a" ~> "FFFFFv[+++h][---q]fb",
                "b" ~> "FFFFFv[+++h][---q]fc",
                "c" ~> "FFFFFv[+++fa]fd",
                "d" ~> "FFFFFv[+++h][---q]fe",
                "e" ~> "FFFFFv[+++h][---q]fg",
                "g" ~> "FFFFFv[---fa]fa",
                "h" ~> "ifFF",
                "i" ~> "fFFF[--m]j",
                "j" ~> "fFFF[--n]k",
                "k" ~> "fFFF[--o]l",
                "l" ~> "fFFF[--p]",
                "m" ~> "fFn",
                "n" ~> "fFo",
                "o" ~> "fFp",
                "p" ~> "fF",
                "q" ~> "rfF",
                "r" ~> "fFFF[++m]s",
                "s" ~> "fFFF[++n]t",
                "t" ~> "fFFF[++o]u",
                "u" ~> "fFFF[++p]",
                "v" ~> "Fv"
            ],
            drawingRules: [
                "a": .move,
                "b": .move,
                "c": .move,
                "d": .move,
                "e": .move,
                "g": .move,
                "h": .move,
                "i": .move,
                "j": .move,
                "k": .move,
                "l": .move,
                "m": .move,
                "n": .move,
                "o": .move,
                "p": .move,
                "q": .move,
                "r": .move,
                "s": .move,
                "t": .move,
                "u": .move,
                "v": .move,
                "F": .draw,
                "-": .turnLeft(angle: 12),
                "+": .turnRight(angle: 12),
                "[": .saveState,
                "]": .restoreState
            ]
        ),
        gradient: .green,
        startingAngle: .angle(90),
        startGeneration: 4,
        maxGeneration: 22,
        lineWidthRange: 1 ..< 2
    )
}
