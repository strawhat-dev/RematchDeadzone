#SingleInstance Force
#Requires AutoHotkey v2-
#Include Lib\AutoHotInterception.ahk

; alt+f4 to exit the ahk tray instance as well along with the game
~<!F4::EXITAPP()

; #region CONFIG
; - use "Custom" preset with "Use modifier" disabled for in-game settings
; - adjust below to match in-game settings where applicable

; use Monitor.ahk to find and copy mouse IDs
mouse_ids := [0x046D, 0xC53A]

; adjust & test in-game to preference
mouse_deadzone := 1600

; apply deadzone to mouse movement while pressing the below (taps & lobs)
tap_key := 'f'
lob_key := 'r'
lob_light_key := 'e'

; use shift as dash while in stance (can't sprint while holding stance anyway)
stance_key := 'rbutton' ; rbutton (right-click) recommended!
dash_key := 'c' ; set dribble in-game to same key as dash also dribble with shift (allowed)

; #endregion

press(key, release_after := key) {
  send('{' key ' down}')
  keywait(release_after)
  send('{' key ' up}')
}

accumulateMouseMove(dx, dy) {
  global mouse_move
  x := mouse_move.dx += dx
  y := mouse_move.dy += dy
  return floor(sqrt((x ** 2) + (y ** 2)))
}

#HotIf WinActive('ahk_exe RuntimeClient-WinGDK-Shipping.exe')
InstallKeybdHook(1, 1)
InstallMouseHook(1, 1)
AHI := AutoHotInterception()
if (!(MOUSE_ID := AHI.GetMouseId(mouse_ids*))) {
  MsgBox('ERROR: Mouse with provided IDs not found!')
  ExitApp()
}

releaseMouseMove(*) {
  AHI.UnsubscribeMouseMove(MOUSE_ID)
  global mouse_move := { dx: 0, dy: 0 }
}

blockMouseMove(*) {
  global mouse_move := { dx: 0, dy: 0 }
  AHI.SubscribeMouseMove(MOUSE_ID, 1, (dx, dy) {
    if (!dx && !dy) {
      return
    }

    if (accumulateMouseMove(dx, dy) > mouse_deadzone) {
      releaseMouseMove()
    }
  })
}

Hotkey('*$' tap_key, (*) {
  blockMouseMove()
  press(tap_key)
  releaseMouseMove()
})

Hotkey('*$' lob_key, (*) {
  blockMouseMove()
  press(lob_key)
  releaseMouseMove()
})

Hotkey('*$' lob_light_key, (*) {
  blockMouseMove()
  press(lob_light_key)
  releaseMouseMove()
})
#HotIf

#HotIf WinActive('ahk_exe RuntimeClient-WinGDK-Shipping.exe') && GetKeyState(stance_key, 'P')
~*lshift::press(dash_key, 'LShift')
#HotIf

OnExit(releaseMouseMove)