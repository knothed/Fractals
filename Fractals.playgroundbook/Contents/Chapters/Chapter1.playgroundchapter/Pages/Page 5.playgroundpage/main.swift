//#-hidden-code
import PlaygroundSupport
//#-end-hidden-code

/*:
 # ✅ Thank You
 for participating and completing this playground!

 *There's one more thing.* To be honest, this is the sickest part. Just **run the code**, move the slider around and see what happens.

 - Important:
 **Definitely** use fullscreen mode for this one. Have fun!

 ![img](TheEnd.png)
 */

//#-hidden-code
PlaygroundPage.current.liveView = SliderSystemView(
    valueRange: 0 ..< 120,
    startValue: 70,
    labelFormat: "angle = %.1f°",
    gradient: .orange,
    startingAngleForDrawing: { angle in return 11 * angle / 2 },
    evolutions: 11,
    system: { angle in return Fractals.dragon(angle: angle).system }
)
//#-end-hidden-code
