;OleIdl.pbi

#IID_IDropTarget$ = "{00000122-0000-0000-C000-000000000046}"

Structure IDropTargetVtbl Extends IUnknownVtbl
	DragEnter.i
	DragOver.i
	DragLeave.i
	Drop.i
EndStructure

#IID_IOleInPlaceActiveObject$ = "{00000117-0000-0000-C000-000000000046}"

#IID_IOleObject$ = "{00000112-0000-0000-C000-000000000046}"

