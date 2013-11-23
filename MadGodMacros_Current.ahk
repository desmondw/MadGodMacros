;Some useful hotkeys for Realm of the Mad God
;Coded by Kino aka KinoftheFlames

;Changelog v1.1
;Swapped binds for Mouse4 and Mouse5

;Changelog v1.2
;Changed chat hotkeys

SetKeyDelay 0
SetTitleMatchMode 2

Suspend On
GroupAdd rotmg, Realm of the Mad God
GroupAdd rotmg, realmofthemadgod
GroupAdd rotmg, AGCLoader1312577255
WinNotActive()

WinActive()
{
	Suspend Off
	WinWaitNotActive ahk_group rotmg
	{
		WinNotActive()
	}
}
WinNotActive()
{
	Suspend On
	WinWaitActive ahk_group rotmg
	{
		WinActive()
	}
}

+Enter:: Send {Enter}/trade{Space}
+NumpadEnter:: Send {Enter}/trade{Space}
!Enter:: Send {Enter}/yell{Space}
!NumpadEnter:: Send {Enter}/yell{Space}
^Enter:: Send {Enter}/teleport{Space}
^NumpadEnter:: Send {Enter}/teleport{Space}
!a:: Send {Enter}^v{Enter}
F1:: Send {Enter}^v{Enter}
^r:: Reload
Up::w
Left::a
Right::d
Down::s

^q:: ExitApp
`::
	Send {Enter}/pause
	Sleep 1 
	Send {Enter}
return
RButton:: RightClick()
	RightClick()
	{
		;assures calibration
		global calibrated
		if calibrated != 1
			CalibrateLoot()
		
		global invX1
		global invY1
		global invX2
		global invY2
		
		INV_LOOT_OFFSET = 100
		MouseGetPos x, y
		
		;msgbox % invX1 ", " x ", " invX2 " ... " invY1 ", " y ", " invY2 ;%
		
		;if mouse inside loot area, loot. else, Shift+LeftClick
		if (invX1 < x && x < invX2) && (invY1 + INV_LOOT_OFFSET < y && y < invY2 + INV_LOOT_OFFSET)
			SingleLoot()
		else
		{
			Send +{LButton}
			GetKeyState, LB, LButton, P
			if LB = D
				Send {LButton down}
		}
	}
MButton:: QuickLoot()
XButton1:: F5
XButton2::
	Send {Enter}hp
	Sleep 1 
	Send {Enter}
return














;AUTO LOOTING BELOW
CalibrateLoot()
{
	global
	
	INV_OFFSET_X = -15
	INV_OFFSET_Y = 99
	
	SLOT_GAP = 44
	HALF_SLOT = 20
	LOOT_GAP = 12
	
	local INV_WIDTH = 172
	local INV_HEIGHT = 84
	
	;find coordinates for ATT
	WinGetActiveStats winTitle, winWidth, winHeight, winX, winY
	local winX2 := winX + winWidth
	local winY2 := winY + winHeight
	ImageSearch img1x, img1y, winX, winY, winX2, winY2, img1.png ;searches active window for ATT img
	
	;notifies loot functions of successful calibration
	calibrated = 1
	if errorlevel != 0
	{
		ImageSearch img1x, img1y, winX, winY, winX2, winY2, img1_STEAM.png ;searches active window for ATT img
		
		if errorlevel != 0
		{
			calibrated = 0
			msgbox Failed to calibrate! (is there a tooltip over "ATT" in the stats?)
		}
	}
	
	;calculate and store coordinates for top-left and bottom-right of inventory
	invX1 := img1x + INV_OFFSET_X
	invY1 := img1y + INV_OFFSET_Y
	invX2 := invX1 + INV_WIDTH
	invY2 := invY1 + INV_HEIGHT
}

SingleLoot()
{
	MouseGetPos x, y
	y2 := y - 56
	ClickDrag(x, y, x, y2, 0, 0)
	MouseMove x, y, 0
}

QuickLoot()
{
	;assures calibration
	global calibrated
	if calibrated != 1
		CalibrateLoot()
	
	MouseGetPos x, y
	MoveItem(9, 5, 0, 0)
	MouseMove x, y, 0
}

MoveItem(startSlot, endSlot, mouseSpeed, sleepTime)
{
	x1 := GetSlotX(startSlot)
	y1 := GetSlotY(startSlot)
	x2 := GetSlotX(endSlot)
	y2 := GetSlotY(endSlot)
	
	;MouseClickDrag from start slot to end slot
	ClickDrag(x1, y1, x2, y2, mouseSpeed, sleepTime)
}

GetSlotX(slot)
{
	global invX1
	global SLOT_GAP
	global HALF_SLOT
	
	slot := Mod(slot, 4)
	
	if slot = 1
		return invX1 + HALF_SLOT
	else if slot = 2
		return invX1 + HALF_SLOT + SLOT_GAP 
	else if slot = 3
		return invX1 + HALF_SLOT + SLOT_GAP * 2
	else if slot = 0
		return invX1 + HALF_SLOT + SLOT_GAP * 3
}

GetSlotY(slot)
{
	global invY1
	global SLOT_GAP
	global HALF_SLOT
	global LOOT_GAP
	
	if slot < 5
		return invY1 + HALF_SLOT
	else if slot < 9
		return invY1 + HALF_SLOT + SLOT_GAP
	else if slot < 13
		return invY1 + HALF_SLOT + SLOT_GAP * 2 + LOOT_GAP
	else
		return invY1 + HALF_SLOT + SLOT_GAP * 3 + LOOT_GAP
}

ClickDrag(x1, y1, x2, y2, mouseSpeed, sleepTime)
{
	MouseMove x1, y1, 0
	Click down
	MouseMove x2, y2, mouseSpeed
	Sleep sleepTime
	Click up
}










CheckSlotEmpty(slot)
{
	global invX1
	global invY1
	global invX2
	global invY2
	
	;retuns 1 if the slot is empty, 0 if it is not
	ImageSearch slotX, slotY, invX1, invY1, invX2, invY2, slot%slot%.png
	
	if ErrorLevel = 0
		return 1
	else
	{
		return 0
	}
}

AutoLoot()
{
	CalibrateLoot()
	Loop 8
	{
		MoveItem(A_Index+8, A_Index, 7, 225)
	}
}

SafeAutoLoot()
{
	CalibrateLoot()
	ArrayCount = 0
	
	;identifies which inventory slots are free and puts their slot numbers in an array
	Loop 8
	{
		isEmpty := CheckSlotEmpty(A_Index)
		
		if isEmpty = 1
		{
			;MsgBox % "hi" ;%
			;MsgBox % A_Index ;%
			ArrayCount++
			FreeSlots%ArrayCount% := A_Index
		}
	}
	
	;moves items from ground (even if they don't exist) into empty inventory slots until inventory is full
	Loop %ArrayCount%
	{
		MoveItem(A_Index+8, FreeSlots%A_Index%, 7, 225)
	}
}