#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#UseHook ; https://autohotkey.com/docs/commands/_UseHook.htm
#InstallKeybdHook
#SingleInstance force

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

SetTitleMatchMode 2

SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

SetCapsLockState, AlwaysOff ; Disable Capslock, always

; --------------------------------------------------------------
; Window groups
; --------------------------------------------------------------
GroupAdd, ChromeGroup, ahk_exe brave.exe
GroupAdd, ExcelGroup, ahk_exe EXCEL.EXE
GroupAdd, OutlookGroup, ahk_exe OUTLOOK.EXE
GroupAdd, TeamsGroup, ahk_exe Teams.exe

; --------------------------------------------------------------
; Natural scrolling
; --------------------------------------------------------------
#MaxHotkeysPerInterval 400
; WheelDown::WheelUp
; WheelUp::WheelDown

; --------------------------------------------------------------
; NOTES
; --------------------------------------------------------------
; ! = ALT
; ^ = CTRL
; + = SHIFT
; # = WIN

; --------------------------------------------------------------
; ' as control when held down
; --------------------------------------------------------------
; left
' UP::Send '
' & q::Send ^q
' & w::Send ^w
' & e::Send ^e
' & r::Send ^r
' & t::Send ^t
' & a::Send ^a
' & s::Send ^s
' & d::Send ^d
' & f::Send ^f
' & g::Send ^g
' & z::Send ^z
' & x::Send ^x
' & c::Send ^c
' & v::Send ^v
; right
' & y::Send ^y
' & u::Send ^u
' & i::Send ^i
' & o::Send ^o
' & p::Send ^p
' & [::Send ^[
' & ]::Send ^]
' & h::Send ^h
' & j::Send ^j
' & k::Send ^k
' & l::Send ^l
' & b::Send ^b
' & n::Send ^n
' & m::Send ^m

; --------------------------------------------------------------
; Capslock as esc when tapped, and Ctrl when held down
; --------------------------------------------------------------
; left
Capslock UP::Send {Escape}
Capslock & q::Send ^q
Capslock & w::Send ^w
Capslock & e::Send ^e
Capslock & r::Send ^r
Capslock & t::Send ^t
Capslock & a::Send ^a
Capslock & s::Send ^s
Capslock & d::Send ^d
Capslock & f::Send ^f
Capslock & g::Send ^g
Capslock & z::Send ^z
Capslock & x::Send ^x
Capslock & c::Send ^c
Capslock & v::Send ^v
; right
Capslock & y::Send ^y
Capslock & u::Send ^u
Capslock & i::Send ^i
Capslock & o::Send ^o
Capslock & p::Send ^p
Capslock & [::Send ^[
Capslock & ]::Send ^]
Capslock & h::Send ^h
Capslock & j::Send ^j
Capslock & k::Send ^k
Capslock & l::Send ^l
Capslock & b::Send ^b
Capslock & n::Send ^n
Capslock & m::Send ^m
Capslock & Enter::Send ^{Enter}

; --------------------------------------------------------------
; Tab as modifier
; --------------------------------------------------------------
Tab UP::Send {Tab}
Tab & h::Send {Left}
Tab & j::Send {Down}
Tab & k::Send {Up}
Tab & l::Send {Right}
Tab & p::Send ^+v

; --------------------------------------------------------------
; [ as modifier
; --------------------------------------------------------------
[ UP::Send [
[ & b::Send ^{Left}
[ & w::Send ^{Right}

!h::Send {Left}
!j::Send {Down}
!k::Send {Up}
!l::Send {Right}
!p::Send ^+v
!b::Send ^{Left}
!w::Send ^{Right}

; --------------------------------------------------------------
; Shifts as parents
; --------------------------------------------------------------
LShift UP::Send (
LShift & F13::return
RShift UP::Send )
RShift & F13::return

; --------------------------------------------------------------
; Left Ctrl as hyper (switch between apps, reload this file..)
; --------------------------------------------------------------
<^Backspace::Reload
<^d::WinActivate ahk_exe WINWORD.EXE
<^e::GroupActivate, ExcelGroup, R
<^h::WinActivate ahk_class mintty_scratchpad
<^i::GroupActivate, TeamsGroup, R
<^j::WinActivate ahk_class mintty_fullscreen
<^k::GroupActivate, ChromeGroup, R
;<^m::
;    WinActivate ahk_class mintty_mail
;    Send ^f1
;    return
<^m::GroupActivate, OutlookGroup, R
<^n::WinActivate Evernote
; WinActivate does not work with spotify.exe anymore; the window is
; focused but then pressing <space> does not triggere Play/Pause as
; expected.  Why would WinActivateBottom work instead?  No idea..
<^o::WinActivateBottom ahk_exe spotify.exe
;<^p::
;    WinActivate ahk_class mintty_mail
;    Send ^f2
;    return
<^p::WinActivate ahk_class mintty_mail
<^u::WinActivate ahk_exe idea64.exe
<^y::WinActivate ahk_class mintty_workstation

<^Up::Send {Volume_Up}
<^Down::Send {Volume_Down}
<^Delete::Send {Volume_Mute}


;-----------------------
; Mac OS alike shortcuts
;-----------------------
^!4::
IfWinExist Snip & Sketch
{
    WinActivate
    WinWait,  Snip & Sketch,,2
    Send ^n
}
else
{
    Run "C:\WinStoreAppLinks\Snip & Sketch.lnk"
    sleep, 500
    send, ^n
}

; ---------------------
; Resize windows like there is no tomorrow
; ---------------------
GetCurrentMonitor()
{
  SysGet, numberOfMonitors, MonitorCount
  WinGetPos, winX, winY, winWidth, winHeight, A
  winMidX := winX + winWidth / 2
  winMidY := winY + winHeight / 2
  Loop %numberOfMonitors%
  {
    SysGet, monArea, Monitor, %A_Index%
    if (winMidX > monAreaLeft && winMidX < monAreaRight && winMidY < monAreaBottom && winMidY > monAreaTop) {
        return A_Index
    }
  }
  SysGet, primaryMonitor, MonitorPrimary
  return 1 ;return "No Monitor Found"
}

ResizePct(x_offset_pct, y_offset_pct, width_pct, height_pct)
{

    CurrentMonitor := GetCurrentMonitor()
    SysGet, WorkArea, MonitorWorkArea, %CurrentMonitor%
    WorkAreaWidth := WorkAreaRight - WorkAreaLeft
    WorkAreaHeight := WorkAreaBottom - WorkAreaTop

    x := WorkAreaLeft + (WorkAreaWidth * x_offset_pct)
    y := WorkAreaTop + (WorkAreaHeight * y_offset_pct)
    width := WorkAreaWidth * width_pct
    height := WorkAreaHeight * height_pct

    WinMove,A,,%x%,%y%,%width%,%height%
}

#If GetKeyState("Shift", "P") = 1
    Capslock & k::ResizePct(0, 0, 1, 1)
    Capslock & j::ResizePct(1/5, 1/10, 3/5, 8/10)

    Capslock & h::ResizePct(0, 0, 1/2, 1)
    Capslock & l::ResizePct(1/2, 0, 1/2, 1)

    Capslock & y::ResizePct(0, 0, 1/4, 1)
    Capslock & o::ResizePct(1/4, 0, 3/4, 1)

    Capslock & i::ResizePct(0, 0, 1, 1/2)
    Capslock & m::ResizePct(0, 1/2, 1, 1/2)

    Capslock & u::ResizePct(1/8, 0, 3/4, 1)
    Capslock & n::ResizePct(1/6, 0, 2/3, 1)

; -------------------
; Die in hell, stupid applications!
; -------------------
#IfWinActive Intellij
    Capslock & h::Send {Backspace}

#IfWinActive Evernote
    Capslock & h::Send {Backspace}
    Capslock & w::Send ^{Backspace}
    Capslock & k::Send +{End}{Backspace}

#IfWinActive ahk_class MozillaWindowClass
    Capslock & h::Send {Backspace}
    Capslock & w::Send ^{Backspace}

#IfWinActive ahk_exe brave.exe
    Capslock & a::Send {Home}
    Capslock & d::Send {Delete}
    Capslock & e::Send {End}
    Capslock & h::Send {Backspace}
    Capslock & k::Send +{End}{Backspace}
    Capslock & w::Send ^{Backspace}
    Capslock & j::Send ^{Enter}
    !b::Send ^{Left}
    !f::Send ^{Right}
    ^u::Send +{Home}{Backspace}
    ' & w::Send ^{Backspace}

#IfWinActive Mail
    Capslock & h::Send {Backspace}
    Capslock & w::Send ^{Backspace}
    Capslock & k::Send +{End}{Backspace}

#IfWinActive Monitor
    j::Send {Down}
    k::Send {Up}
    ^B::Send {PgUp}
    ^F::Send {PgDn}

#IfWinActive ahk_exe Teams.exe
    Capslock & a::Send {Home}
    Capslock & d::Send {Delete}
    Capslock & e::Send {End}
    Capslock & h::Send {Backspace}
    Capslock & k::Send +{End}{Backspace}
    Capslock & w::Send ^{Backspace}
    Capslock & u::Send +{Home}{Backspace}
    Capslock & j::Send ^{Enter}
    ' & w::Send ^{Backspace}

#IfWinActive Word
    Capslock & h::Send {Backspace}
    Capslock & w::Send ^{Backspace}

#IfWinActive ahk_exe mintty.exe
    ; Send ◊ on <C-CR> -- Vim uses it
    Capslock & Enter::Send {U+25CA}
    ; Send Ø on <S-CR> -- Vim uses it
    +Return::Send {U+00F8}
    ;; Reset ^v behavior -- we use ^V with vim
    ;^v::Send ^v
    Tab & p::Send +{Insert}

#IfWinActive ahk_exe SearchUI.exe
    Capslock & w::Send ^{Backspace}

#IfWinActive ahk_exe OUTLOOK.EXE
    Capslock & a::Send {Home}
    Capslock & e::Send {End}
    Capslock & h::Send {Backspace}
    Capslock & w::Send ^{Backspace}
    ^SPACE::Send ^k
    Capslock & k::Send +{End}{Backspace}
    ; Tab & p::
    ;     Send ^v
    ;     sleep, 100
    ;     Send ^k
    ;     sleep, 100
    ;     Send t
    ;     return

#IfWinActive ahk_exe WINWORD.EXE
    Capslock & a::Send {Home}
    Capslock & e::Send {End}
    Capslock & h::Send {Backspace}
    Capslock & w::Send ^{Backspace}
    Capslock & k::Send +{End}{Backspace}

#IfWinActive ahk_exe POWERPNT.EXE
    Capslock & a::Send {Home}
    Capslock & e::Send {End}
    Capslock & h::Send {Backspace}
    Capslock & w::Send ^{Backspace}
    Capslock & k::Send +{End}{Backspace}

#IfWinActive ahk_exe Discord.exe
    Capslock & w::Send ^{Backspace}

#IfWinActive ahk_exe spotify.exe
    Capslock & w::Send ^{Backspace}
    Capslock & h::Send {Backspace}
