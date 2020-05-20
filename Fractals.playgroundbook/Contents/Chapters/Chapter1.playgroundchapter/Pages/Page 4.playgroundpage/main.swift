//#-hidden-code
import PlaygroundSupport
var plant: LSystemEvolutionDrawingDescription
//#-end-hidden-code

/*:
 # 🌱 Plants & Trees
 Now we come to the *video games* part. Well, we already have – you've seen L-Systems, and this is *exactly* what plants use.

 Because plants are more complex than the fractals we've seen before, we need to introduce some more drawing rules. For example, `.saveState` and `.restoreState`, which save or restore the current **drawing state** (i.e. the arrow position and its direction) onto or from a stack.

 This allows us to generate simple plants and trees. Look at the following four plants (by **running the code**) and see how you like them!
 */
//#-editable-code
plant = Plants.weed
// plant = Plants.farn1
// plant = Plants.farn2
// plant = Plants.binaryTree
//#-end-editable-code
//: ![img](Plants.png)
/*:
 Of course, they do not yet look like realistic plants or trees, which is because they're 2-dimensional. L-Systems also provide a way to draw 3-dimensional fractals. Therefore, we add rules to *rotate around different axes* in the 3D coordinate system.

 Generating actual 3-dimensional plants is far beyond the scope (and time limit) of this playground. But, video games **do** actually use L-Systems under the hood for generating them – just more complex ones than the ones having been showcased here.
 */

/*:
 ### Example Plant
 Here you see the code for one of these plants (`Plants.weed`). It is still really simple – there are plants with **way** more complex L-Systems!

 Go to the [next page](@next) to finish this playground.
 ```
 weed = LSystem(
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
 )
 ```
 */

//#-hidden-code
PlaygroundPage.current.liveView = EvolutionView(drawing: plant)
//#-end-hidden-code
