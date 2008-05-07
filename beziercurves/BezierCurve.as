/** * BezierCurve *  * lets you create bezier curves of degree n * not quadratic and cubic specific *  * add as many anchor and control points as you need *  *  * syntax: *  * var b:BezierCurve = new BezierCurve(); * addChild(b); * b.addAnchor(x, y); * b.addControl(x, y); * b.addPath(p_0, p_1, p_2...); // with p_i anchor or control points * * @author nicolas levavasseur * @version 0.9a *//* * Licensed under the MIT License *  * Copyright (c) 2008 Nicolas Levavasseur *  * Permission is hereby granted, free of charge, to any person obtaining a copy of * this software and associated documentation files (the "Software"), to deal in * the Software without restriction, including without limitation the rights to * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of * the Software, and to permit persons to whom the Software is furnished to do so, * subject to the following conditions: *  * The above copyright notice and this permission notice shall be included in all * copies or substantial portions of the Software. *  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. *  * http://code.google.com/p/beziercurve/ *  */package beziercurves {	import beziercurves.curves.NBezierCurve;	import beziercurves.events.BezierEvent;	import flash.events.MouseEvent;	import beziercurves.display.BezierEditor;	import beziercurves.display.ControlPoint;	import beziercurves.display.AnchorPoint;	import beziercurves.utils.PointArray;	import flash.geom.Point;	import flash.display.Sprite;		/**	 * Copyright (c) 2008 nicolas levavasseur	 * nicolas.levavasseur@gmail.com	 * 	 * @author nicolas levavasseur	 */	public class BezierCurve extends Sprite {		public static var verbose:Boolean = false;				private var pArray:PointArray = new PointArray();		private var thickness:int;		private var color:Number;		private var transparency:Number;		private var _editable:Boolean;		private var editor:BezierEditor;		private var curve:Sprite = new Sprite();		private var precision:int;		private var bArray:Array = [];						public function BezierCurve(thickness:int = 5, color:Number = 0x000000, transparency:Number = 1, editable:Boolean = false, precision:int = 50) {			lineStyle(thickness, color, transparency);			this.editable = editable;			this.precision = precision;						addChild(curve);		}				/**		 * add an anchor point to the actual path		 * 		 * @param x:Number position x of the anchor point		 * @param y:Number position y of the anchor point		 */		public function addAnchor(x:Number, y:Number):void {			pArray.push(new AnchorPoint(x, y));			draw();		}				/**		 * add a control point to the actual path		 * 		 * @param x:Number position x of the control point		 * @param y:Number position y of the control point		 */		public function addControl(x:Number, y:Number):void {			pArray.push(new ControlPoint(x, y));			draw();		}				/**		 * extends the actual path with this new one		 * the new path is a serie of anchor and control points		 * 		 * @param args:... list of anchor/control points that extend the actual path		 */		public function addPath(... args):void {			pArray.push.apply(null, args);			draw();		}				/**		 * set the style of the curve to display		 * 		 * @param thickness:int = 5 thickness of the curve		 * @param color:Number = 0x000000 color of the curve		 * @param transparency:Number = 1 transparency of the curve, between 0 and 1		 */		public function lineStyle(thickness:int = 5, color:Number = 0x000000, transparency:Number = 1):void {			this.thickness = thickness;			this.color = color;			this.transparency = transparency;		}				/**		 * draw curve on screen		 */		private function draw():void {			var p0:Point = null;			var p1:Point;			var controls:Array = [];						var b:NBezierCurve;						for each(var p:Object in pArray){				switch( p.constructor ){					case AnchorPoint:						if( !p0 ){							p0 = Point(p);						} else {							p1 = Point(p);														b = new NBezierCurve(p0, p1, controls, thickness, color, transparency, precision);							curve.addChild(b);							bArray.push(b);														p0 = p1;							controls = [];						}						break;					case ControlPoint:						controls.push(p);						break;				}			}		}				/**		 * redraw the curve		 */		public function redraw():void {			for each(var b:NBezierCurve in bArray) {				b.draw();			}						if( editor ) editor.update();		}				/**		 * lets edit or not the curve		 * if yes, shows details (anchor/control points) and lets move them with redraw of the curve		 * 		 * @param editable:Boolean determines wether the curve is editable or not		 */		public function set editable(editable:Boolean):void {			_editable = editable;			if( editable ) curve.addEventListener(MouseEvent.MOUSE_DOWN, editorHandler);			else curve.removeEventListener(MouseEvent.MOUSE_DOWN, editorHandler);		}				private function editorHandler(e:MouseEvent = null):void {			if( !editor ){				dispatchEvent(new BezierEvent(BezierEvent.START_EDITING));				editor = new BezierEditor(pArray);				addChild(editor);				editor.draw();			} else {				dispatchEvent(new BezierEvent(BezierEvent.END_EDITING));				removeChild(editor);				editor = null;								if( verbose ) pArray.export();			}		}				public function get editable():Boolean {			return _editable;		}				/**		 * closes the editor of the curve		 */		public function closeEditor():void {			if( editor ){				removeChild(editor);				editor = null;			}		}				/**		 * shows/hides the editor of the curve if this one is editable		 */		public function set showEditor(show:Boolean):void {			if( editable ){				if( show ) editorHandler();				else closeEditor();			}		}				/**		 * lets you apply filters to the curve only		 * without affecting the editor		 * 		 * @param value:Array array of filters you want to apply		 */		public override function set filters(value:Array):void {			curve.filters = value;		}	}}