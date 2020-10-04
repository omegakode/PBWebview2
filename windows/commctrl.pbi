;- commctrl.pbi

; XIncludeFile "lib.pb"

;- Imports
; CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
; 	Import "lib\64\comctl32.lib"
; CompilerElse
; 	Import "lib\32\comctl32.lib"
; CompilerEndIf
; 
; 	SetWindowSubclass_(hwnd.i, pfnSubclass.i, uIdSubclass.i, dwRefData.i) As lib::IMP_NAME(SetWindowSubclass, 16)
; 	DefSubclassProc_(hwnd.i, msg.i, wparam.i, lparam.i) As lib::IMP_NAME(DefSubclassProc, 16)
; 	RemoveWindowSubclass_(hwnd.i, pfnSubclass.i, uIdSubclass.i) As lib::IMP_NAME(RemoveWindowSubclass, 12)
; 	GetWindowSubclass_(hWnd.i, pfnSubclass.i, uIdSubclass.i, pdwRefData.i) As lib::IMP_NAME(GetWindowSubclass, 16)
; EndImport

;- REBAR CONTROL
#RBBS_USECHEVRON 	   = $00000200
#RBBS_HIDETITLE      = $00000400
#RBBS_TOPALIGN       = $00000800         

;- TOOLBAR CONTROL
#TBCDRF_NOEDGES              = $00010000
#TBCDRF_HILITEHOTTRACK       = $00020000
#TBCDRF_NOOFFSET             = $00040000
#TBCDRF_NOMARK               = $00080000
#TBCDRF_NOETCHEDEFFECT       = $00100000
#TBCDRF_BLENDICON            = $00200000
#TBCDRF_NOBACKGROUND         = $00400000
#TBCDRF_USECDCOLORS          = $00800000

#TBMF_PAD                = $00000001
#TBMF_BARPAD             = $00000002
#TBMF_BUTTONSPACING      = $00000004

Structure TBMETRICS Align #PB_Structure_AlignC 
	cbSize.l
	dwMask.l
	cxPad.l
	cyPad.l
	cxBarPad.l
	cyBarPad.l
	cxButtonSpacing.l
	cyButtonSpacing.l
EndStructure

#TB_GETMETRICS           = (#WM_USER + 101)
#TB_SETMETRICS           = (#WM_USER + 102)
#TB_MARKBUTTON = (#WM_USER + 6)

#TB_SETHOTITEM2          = (#WM_USER + 94)
#TB_SETLISTGAP           = (#WM_USER + 96)
#TB_GETIMAGELISTCOUNT    = (#WM_USER + 98)
#TB_GETIDEALSIZE         = (#WM_USER + 99)

#TBN_HOTITEMCHANGE = (#TBN_FIRST - 13)

#TBN_RESTORE             = (#TBN_FIRST - 21)
#TBN_SAVE                = (#TBN_FIRST - 22)
#TBN_INITCUSTOMIZE       = (#TBN_FIRST - 23)
#TBNRF_HIDEHELP       = $00000001
#TBNRF_ENDCUSTOMIZE   = $00000002
#TBN_WRAPHOTITEM         = (#TBN_FIRST - 24)
#TBN_DUPACCELERATOR      = (#TBN_FIRST - 25)
#TBN_WRAPACCELERATOR     = (#TBN_FIRST - 26)
#TBN_DRAGOVER            = (#TBN_FIRST - 27)
#TBN_MAPACCELERATOR      = (#TBN_FIRST - 28)

#TBMF_PAD               = $00000001
#TBMF_BARPAD            = $00000002
#TBMF_BUTTONSPACING     = $00000004

#TBDDRET_DEFAULT         = 0
#TBDDRET_NODEFAULT       = 1
#TBDDRET_TREATPRESSED    = 2   

#HICF_OTHER          = $00000000
#HICF_MOUSE          = $00000001          
#HICF_ARROWKEYS      = $00000002          
#HICF_ACCELERATOR    = $00000004          
#HICF_DUPACCEL       = $00000008          
#HICF_ENTERING       = $00000010          
#HICF_LEAVING        = $00000020          
#HICF_RESELECT       = $00000040          
#HICF_LMOUSE         = $00000080          
#HICF_TOGGLEDROPDOWN = $00000100 

;- TAB CONTROL
Structure TCITEM Align #PB_Structure_AlignC
	mask.l
	dwState.l
	dwStateMask.l
	pszText.i
	cchTextMax.l
	iImage.l
	lParam.i
EndStructure

Structure TCHITTESTINFO Align #PB_Structure_AlignC
	pt.POINT
	flags.l
EndStructure

Structure TCITEMHEADER Align #PB_Structure_AlignC
	mask.l
	lpReserved1.l
	lpReserved2.l
	pszText.i
	cchTextMax.l
	iImage.l
EndStructure

;- TOOLTIP CONTROL
#TTF_TRACK  = $0020

;- UPDOWN CONTROL
Structure NMUPDOWN Align #PB_Structure_AlignC
	hdr.NMHDR
	iPos.l
	iDelta.l
EndStructure



