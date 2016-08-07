# SNDraw

SNDraw is a lightweigt library for iOS, which turns a series of touch events into a series of path elements, performing smoothing (to reduce the number of elements) as well as detecting sharp-turns. 

## struct SNPath

*SNPath* is an abstruct struct, which offers static functions to converts series of path elements (represented in an array of *SNPathElement*) into a CGPath. 

```
static func pathFrom(elements:[SNPathElement]) -> CGPath
```
This function converts a series of path elements into a CGPath 

```
static func polyPathFrom(elements:[SNPathElement]) -> CGPath
```
This function converts a series of path elements into a CGPath, by turning curves into polylines by drawing lines between control points and anchor points. 

## protocol SNPathElement

*SNPathElement* is a protocol, which represents a path element. It has two methods to be implemented by the concrete structs. 

```
func addToPath(path:CGMutablePath) -> CGMutablePath
```

This functions add the element to CGMutablePath. 

```
func addToPathAsPolygon(path:CGMutablePath) -> CGMutablePath
```
This functions add the element to CGMutablePath, by turning curves into polylines by drawing lines between control points and anchor points. 

## struct SNMove, SNLine, SNQuadCurve, SNBezierCurve

Those structs are concrete structs of SNPathElement protocol, representing move, line, quadratic curve, and bezier curve element respectively.

## struct SNPathBuilder

*SNPathBuilder* builds a series of path elements from a series of CGPoints, by performing smoothing (to reduce the number of elements) as well as detecting sharp-turns. 

Typically, the user of this struct is a subclass of *UIView* or *UIViewController*, which receives a series of touch events. 

```
public mutating func start(pt:CGPoint) -> CGPath
```
It indicates the beginning of touch events. The user of this struct typically calls this method when the user touches the view (from the *touchesBegan* method). 

```
public mutating func move(pt:CGPoint) -> CGPath?
```
It indicates of a touch move event. The user of this struct typically calls this method when the user moves a finger on the view (from the *touchesMove* method). 

```
public mutating func end() -> CGPath
```
It indicates the end of touch events. The user of this struct typically calls this method when the user release the finger from the view (from the *touchesEnded* method). 


## SNDrawView
