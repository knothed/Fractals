//#-hidden-code
import PlaygroundSupport
var system: LSystemEvolutionDrawingDescription = Fractals.sierpinski
//#-end-hidden-code

/*:
 # 🎥 More Fractals
 ![img](Sierpinski.png)
 It's time for you to see some more fractals in action! I have some really juicy ones – it's definitely worth it.
 The first one is the *Sierpiński triangle*; you may have already heard of it. Just **run the code** to see it in action.

 - Note:
 Remember that the fractals are most impressive when shown in **fullscreen mode!**
 */

/*:
 Wasn't that nice?
 In case you want to know how it's generated, see the code at the bottom. But first, **try out the two remaining fractals!**
 */
//#-editable-code
// system = Fractals.pentagon
// system = Fractals.dragon
//#-end-editable-code
//: The dragon is generated with a 90° angle. It's really fun to mess around with the angle; especially values between 45° and 90° give really interesting results!
//#-editable-code
// system = Fractals.dragon(angle: 65)
//#-end-editable-code

/*:
 ### Example Code
 This is the code for the Sierpiński triangle from before – just in case you were wondering.
 Go to the [next page](@next) to see some plants!

```
sierpinski = LSystem(
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
)
```
*/



//#-hidden-code
PlaygroundPage.current.liveView = EvolutionView(drawing: system)
//#-end-hidden-code
