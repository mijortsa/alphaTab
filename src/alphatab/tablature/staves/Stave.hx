/*
 * This file is part of alphaTab.
 *
 *  alphaTab is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  alphaTab is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with alphaTab.  If not, see <http://www.gnu.org/licenses/>.
 */
package alphatab.tablature.staves;

import alphatab.tablature.drawing.DrawingContext;
import alphatab.tablature.drawing.DrawingLayer;
import alphatab.tablature.drawing.DrawingLayers;
import alphatab.tablature.drawing.DrawingResources;
import alphatab.tablature.drawing.MusicFont;
import alphatab.tablature.model.MeasureDrawing;
import alphatab.tablature.ViewLayout;

/**
 * Represents  the base class for a stave implementation 
 * which renders a line of measures. 
 */
class Stave 
{
    private static inline var TS_NUMBER_WIDTH:Int = 10;
    private static inline var TS_NUMBER_HEIGHT:Int = 15;

    // the stave index within a stave line
    public var index(default,default):Int;
    public var line(default,default):StaveLine;
    public var spacing(default,default):StaveSpacing;
    public var layout(default,default):ViewLayout;
    
    public function new(line:StaveLine, layout:ViewLayout)
    {
        this.index = 0;
        this.line = line;
        this.layout = layout;
    }
    
    public function getStaveId() : String
    {
        // set in implementation 
        return ""; 
    }
    
    // gets the spacing index used for grouping staves with a bar
    public function getBarTopSpacing() : Int
    {
        return 0;
    }
    
    // gets the spacing index used for grouping staves with a bar
    public function getBarBottomSpacing() : Int
    {
        return 0;
    }    
    
    // gets the spacing index used for grouping staves with a line
    public function getLineTopSpacing() : Int
    {
        return 0;
    }
    
    // gets the spacing index used for grouping staves with a line
    public function getLineBottomSpacing() : Int
    {
        return 0;
    }    
    
    public function prepare(measure:MeasureDrawing)
    {
        // for layouting requirements
    }
    
    public function paintStave(layout:ViewLayout, context:DrawingContext, x:Int, y:Int)
    {
    }
    
      
    public function paintMeasure(layout:ViewLayout, context:DrawingContext, measure:MeasureDrawing, x:Int, y:Int)
    {
        // for layouting requirements
    }
    
    // paint division lines, measure numbers and repeat bars/endings
    public function paintDivisions(layout:ViewLayout, context:DrawingContext, measure:MeasureDrawing, x:Int, y:Int, dotSize:Int, offset:Int, staveHeight:Int)
    {
        var x2:Int; // variable for additional calculations
        var number:String = Std.string(measure.header.number); 
        var fill:DrawingLayer = context.get(DrawingLayers.MainComponents);
        var draw:DrawingLayer = context.get(DrawingLayers.MainComponentsDraw);
        
        var lineWidthBig:Int = cast Math.max(1, Math.round(3.0 * layout.scale));
        
        var startY = y;
        
        
        var bottomY:Int;
        
        if (index == 0) // the first stave will get the infos and won't draw any upper offset
        { 
            context.get(DrawingLayers.Red).addString(number, DrawingResources.defaultFont, x + Math.round(layout.scale*2), y + offset - DrawingResources.defaultFontHeight);
        }
        y += offset;
        bottomY = y + staveHeight;      
        
        dotSize = cast Math.max(1, (dotSize * layout.scale));   

        // RepeatEndings
        if (measure.header.isRepeatOpen)
        {
            // add a rect and a line
            fill.addRect(x, y, lineWidthBig, bottomY - y);
            draw.startFigure();            
            x2 = Math.floor(x + lineWidthBig + (3 * layout.scale));
            draw.addLine(x2, y, x2, bottomY);
        
            // two dots 
            x2 += Math.floor(2 * layout.scale);     
            
            var centerY = y + ((bottomY - y) / 2);            
            var yMove:Float = 6 * layout.scale;         
            
            fill.addCircle(x2, centerY - yMove - dotSize, dotSize);
            fill.addCircle(x2, centerY + yMove, dotSize);
        }
        else
        {
            // a simple line
            draw.startFigure();
            draw.addLine(x, y, x, bottomY);
        }
        
        // Repeat Closings
        x += measure.width + measure.spacing;
        if (measure.header.repeatClose > 0 || measure.header.number == measure.track.measureCount())
        {
            // add a rect and a line
            x2 = Math.floor(x - (lineWidthBig + (3 * layout.scale)));

            draw.startFigure();            
            draw.addLine(x2, y, x2, bottomY);            
            fill.addRect(x - lineWidthBig, y, lineWidthBig, bottomY - y);

            if (measure.header.repeatClose > 0)
            {
                // two dots  
                x2 -= (Math.floor(2 * layout.scale) + dotSize);     
                
                var centerY = y + ((bottomY - y) / 2);            
                var yMove:Float = 6 * layout.scale;         
                
                fill.addCircle(x2, centerY - yMove - dotSize, dotSize);
                fill.addCircle(x2, centerY + yMove, dotSize);

                if (index == 0)
                {
                    var repetitions:String = ("x" + (measure.header.repeatClose + 1));
                    var numberSize = context.graphics.measureText(repetitions);
                    fill.addString(repetitions, DrawingResources.defaultFont, x2 - dotSize, 
                    y - DrawingResources.defaultFontHeight);
                }
            }
        }
        else
        {
            draw.startFigure();
            draw.addLine(x, y, x, bottomY);
        }
    }
        
    private function paintTimeSignatureNumber(layout:ViewLayout, context:DrawingContext, number:Int, x:Int, y:Int, scale:Float)
    {
        if(number < 10)
        {
            var symbol = this.getTimeSignatureSymbol(number);
            if (symbol != null) 
                context.get(DrawingLayers.MainComponents).addMusicSymbol(symbol, x, y, scale);
        }
        else
        {
            var firstDigit = Math.floor(number / 10);
            var secondDigit = number - (firstDigit * 10); 
            
            var symbol = this.getTimeSignatureSymbol(firstDigit);
            if (symbol != null) 
                context.get(DrawingLayers.MainComponents).addMusicSymbol(symbol, x, y, scale);
            symbol = this.getTimeSignatureSymbol(secondDigit);
            if (symbol != null) 
                context.get(DrawingLayers.MainComponents).addMusicSymbol(symbol, x + TS_NUMBER_WIDTH * scale, y, scale);
        }
    }
    
    private function getTimeSignatureSymbol(number:Int)
    {
        switch(number) 
        {
            case 0:  
                return MusicFont.Num0;
            case 1:  
                return MusicFont.Num1;
            case 2: 
                return MusicFont.Num2;
            case 3: 
                return MusicFont.Num3;
            case 4: 
                return MusicFont.Num4;
            case 5: 
                return MusicFont.Num5;
            case 6: 
                return MusicFont.Num6;
            case 7: 
                return MusicFont.Num7;
            case 8: 
                return MusicFont.Num8;
            case 9: 
                return MusicFont.Num9;
        }
        return null;
    }
}