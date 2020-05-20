/*:
 # 🌟 Welcome to Fractals!
 In this playground you will learn two things:
 - Fractals are beautiful and incredibly simple to create!
 - You learn the methods that video games use to create 3-dimensionals plants and trees.

 What I'm gonna show you in the next few pages (and hopefully within 5 minutes) is an actual established technique that is used in real-world game programming. But before just talking big words, let's look at an example.
 
 Maybe you've already heard of **fractals**? Well, *now* you definitely have. A fractal is an object which is self-similar, meaning it recursively contains smaller versions of itself.

 Now, **run the code** to see how such a fractal is created.
*/

/*:
You've just seen a snowflake whose border is refined step by step. On the [next page](@next) you're gonna see how to do this systematically!
*/

/*:
 # 🕓 What Awaits You:
 ![img](WhatAwaitsYou.png)
 */

//#-hidden-code
import PlaygroundSupport
PlaygroundPage.current.liveView = EvolutionView(drawing: Fractals.snowflake)
//#-end-hidden-code
