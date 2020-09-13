Procedure drw_DrawPlus(_x_.d, _y_.d, _half_.d, _w_.d, color.l)
	; _x_, _y_: coordinates of the center of the plus sign
	; _half_  : half of size (width and height) of the plus sign
	; _w_     : width of the line used for drawing the plus sign
	; [by Little John]
	
	VectorSourceColor(color)
	MovePathCursor(_x_-_half_, _y_)
	AddPathLine   (_x_+_half_, _y_)
	MovePathCursor(_x_, _y_-_half_)
	AddPathLine   (_x_, _y_+_half_)
	StrokePath(_w_)
EndProcedure

Procedure drw_ZoomOutCoordinates(zoom.d, size.i)
	Protected.i newsize
	Protected.d offsetX, offsetY
	
	newsize = size * zoom
	If newsize < size
		offsetX = (size - newsize) / 2
		offsetY = offsetX
		
  	TranslateCoordinates(offsetX, offsetY)
  	ScaleCoordinates(zoom, zoom)
	EndIf 
EndProcedure

Procedure drw_DrawArrow(size.i, rotation.d, color.l)
	Protected.d half, x1, x2, y
	Protected.i w
	
	half = size / 2.0
	x1 = 0.1   * size
	x2 = 0.9   * size
	y  = 0.875 * half
	
	w = Int(size / 3.0) - (size % 3)

	VectorSourceColor(color)
	RotateCoordinates(half, half, rotation)
	
	MovePathCursor(half, 0)
	AddPathLine(x1, y)
	AddPathLine(x2, y)
	ClosePath()
	FillPath()
	
	MovePathCursor(half, y)
	AddPathLine(half, size)
	StrokePath(w)
EndProcedure

Procedure drw_DrawRefreshArrow(size.i, hw.d, half.d, third.d, color.l)
	VectorSourceColor(color)

	MovePathCursor(hw, half-hw)
	AddPathCurve(third, hw, size-third, hw, size-1.75*hw, half-2.0*hw)
	StrokePath(2.0 * hw)
	
	MovePathCursor(size, half-hw)
	AddPathLine(size-hw-third, half-0.5*hw)
	AddPathLine(size-1.5*hw, 0)
	ClosePath()
	FillPath()
EndProcedure