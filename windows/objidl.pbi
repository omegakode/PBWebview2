﻿;objidl.pbi

XIncludeFile "unknwn.pbi"

;- IDataObject
#IID_IDataObject$ = "{0000010e-0000-0000-C000-000000000046}"

;- IStream
#IID_IStream$ = "{0000000c-0000-0000-C000-000000000046}"

Structure STATSTG Align #PB_Structure_AlignC
	pwcsName.i
	type.l
	cbSize.q
	mtime.FILETIME
	ctime.FILETIME
	atime.FILETIME
	grfMode.l
	grfLocksSupported.l
	clsid.CLSID
	grfStateBits.l
	reserved.l
EndStructure


