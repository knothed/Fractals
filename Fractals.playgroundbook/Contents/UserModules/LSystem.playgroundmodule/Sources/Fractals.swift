/// Fractals contains some L-Systems which describe fractals.
public enum Fractals {
    /// A fractal snowflake consisting of triangles.
    public static let snowflake = LSystemEvolutionDrawingDescription(
        system: LSystem(
            startString: "A--A--A",
            productionRules: [
                "A" ~> "A+A--A+A"
            ],
            drawingRules: [
                "A": .draw,
                "-": .turnRight(angle: 60),
                "+": .turnLeft(angle: 60)
            ]
        ),
        gradient: .snow,
        startingAngle: .angle(60),
        startGeneration: 0,
        maxGeneration: 5,
        lineWidthRange: 1 ..< 2
    )

    /// The sierpinski arrowhead curve, approximating the sierpinski triangle.
    public static let sierpinski = LSystemEvolutionDrawingDescription(
        system: LSystem(
            startString: "A",
            productionRules: [
                "A" ~> "B-A-B",
                "B" ~> "A+B+A"
            ],
            drawingRules: [
                "A": .draw,
                "B": .draw,
                "-": .turnRight(angle: 60),
                "+": .turnLeft(angle: 60)
            ]
        ),
        gradient: .orange,
        startingAngle: .even(0, odd: 60),
        startGeneration: 0,
        maxGeneration: 9,
        lineWidthRange: 1.5 ..< 3.5
    )

    /// The classic dragon curve.
    public static let dragon = Self.dragon(angle: 90)

    /// The dragon curve, using a different turning angle.
    public static func dragon(angle: Double) -> LSystemEvolutionDrawingDescription {
        let angleFromEvolution: (Int) -> Double = { evolution -> Double in
            angle * Double(evolution) * 0.5
        }

        return LSystemEvolutionDrawingDescription(
            system: LSystem(
                startString: "FX",
                productionRules: [
                    "X" ~> "X+YF+",
                    "Y" ~> "-FX-Y"
                ],
                drawingRules: [
                    "F": .draw,
                    "X": .ignore,
                    "Y": .ignore,
                    "-": .turnLeft(angle: angle),
                    "+": .turnRight(angle: angle),
                ]
            ),
            gradient: .orange,
            startingAngle: .block(angleFromEvolution),
            startGeneration: 0,
            maxGeneration: 13
        )
    }

    /// A board consisting of nested rectangles. Not really a chessboard.
    public static let chessboard = LSystemEvolutionDrawingDescription(
        system: LSystem(
            startString: "F+F+F+F",
            productionRules: [
                "F" ~> "FF+F+F+F+FF"
            ],
            drawingRules: [
                "F": .draw,
                "-": .turnLeft(angle: 90),
                "+": .turnRight(angle: 90),
            ]
        ),
        gradient: .orange,
        startingAngle: .angle(0),
        startGeneration: 0,
        maxGeneration: 4
    )

    /// A nested pentagon structure.
    public static let pentagon = LSystemEvolutionDrawingDescription(
        system: LSystem(
            startString: "F++F++F++F++F",
            productionRules: [
                "F" ~> "F++F++F|F-F++F"
            ],
            drawingRules: [
                "F": .draw,
                "|": .turnLeft(angle: 180),
                "+": .turnRight(angle: 36),
                "-": .turnLeft(angle: 36),
            ]
        ),
        gradient: .orange,
        startingAngle: .angle(180),
        startGeneration: 0,
        maxGeneration: 4,
        lineWidthRange: 1.5 ..< 2.5
    )


    /// The Lévy C curve.
    public static var levyCurve = LSystemEvolutionDrawingDescription(
        system: LSystem(
            startString: "F",
            productionRules: [
                "F" ~> "-F++F-"
            ],
            drawingRules: [
                "F": .draw,
                "+": .turnRight(angle: 45),
                "-": .turnLeft(angle: 45),
            ]
        ),
        gradient: .orange,
        startingAngle: .angle(180),
        startGeneration: 0,
        maxGeneration: 12
    )
}
