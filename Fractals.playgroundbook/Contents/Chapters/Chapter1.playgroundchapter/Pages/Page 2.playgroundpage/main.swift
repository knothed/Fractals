//#-hidden-code
import PlaygroundSupport
var string: String = "A--A--A"
//#-end-hidden-code

/*:
 # ↗️ L-Systems

 Before seeing more fractals and, finally, plants, we need to understand how this works – after this lession you can create your own fractals! Therefore, we take a quick look into **L-Systems**. An L-System describes two things: how to **draw** a fractal at a given stage, and how to **evolve** from one stage to the next.


# ✏️ Drawing
At any stage, an L-System is a string, consisting of different characters. Each of these characters corresponds to a specific action.

 Imagine an arrow starting at some point pointing in some direction. These actions can now either *rotate* the arrow, or *move along* the current arrow direction while drawing a line. For example, look at these actions:
```
actions = [
    "A": .draw,
    "-": .turnRight(angle: 60),
    "+": .turnLeft(angle: 60)
]
```
E.g. an `A` means to move along the arrow and draw a line, while `+` or `-` rotate the arrow by 60°.

Now, lets begin with the following simple string: `string = "A--A--A"`. **Run the code** to see what happens!
 */

/*:
 It is important to understand what happens here. You can **replay** the simulation and watch it again if you like to.

 Now, having seen this simple string, we can try longer, more complex ones. Try out both of the following strings! Uncomment the one you would like to see and **run the code**.
*/
//#-editable-code
// string = "A+A--A+A--A+A--A+A--A+A--A+A"
// string = "A+A--A+A+A+A--A+A--A+A--A+A+A+A--A+A--A+A--A+A+A+A--A+A--A+A--A+A+A+A--A+A--A+A--A+A+A+A--A+A--A+A--A+A+A+A--A+A"
//#-end-editable-code
/*:
 As you see, these strings correspond to different generations of the snowflake from the last page! The questions remains: how do we transform one string to get the next?

 # 👶 Evolving
 Therefore, we use *replacement rules*. To advance by one generation, we replace some characters in the string with longer strings. For example, we could replace each `A` (i.e. each straight line) with an `A+A--A+A` (a line with a spike). This would look like this:
 */
//:![img](Evolution.png)
/*:
 When applying this to **every** `A`, **each** line is replaced with a finer line with a spike.

 In code, we can express the rule as follows: `rule = "A" ~> "A+A--A+A"`.

 - Note:
 Exactly these components make a full L-System: the *drawing rules*, the *replacement* (or *production*) rules, and the *start string*.

 &nbsp;
 &nbsp;

 Enough theory! On the [next page](@next) you can relax while seeing some beautiful fractals, entirely generated by L-Systems.
*/


//#-hidden-code
PlaygroundPage.current.liveView = CharByCharDrawingView(
    string: string,
    drawingRules: Fractals.snowflake.system.drawingRules,
    gradient: .snow,
    startDirection: 60
)
//#-end-hidden-code
