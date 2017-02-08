#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#InstallKeybdHook
#SingleInstance force
SetTitleMatchMode 2
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


; Natural scrolling
#MaxHotkeysPerInterval 400
WheelDown::WheelUp
WheelUp::WheelDown

F15 & Backspace::Reload
F15 & space::
    device = 3 ; https://autohotkey.com/docs/commands/SoundSet.htm#Ex
    SoundSet, +1, Master, Mute, %device%
    SoundGet, mute, Master, Mute, %device%

    if mute = On
        mute = Off
    Else
        mute = On

    TrayTip, Toggle mic, Microphone[%device%] is %mute%, 3
return

; --------------------------------------------------------------
; Application shortcuts -- my left ctrl has been remapped to F15
; --------------------------------------------------------------
F15 & y::WinActivate TweetDeck
F15 & i::WinActivate ahk_exe Teams.exe
F15 & h::WinActivate ahk_class mintty_scratchpad
F15 & j::WinActivate ahk_class mintty
F15 & k::WinActivate ahk_class MozillaWindowClass
F15 & m::WinActivate ahk_exe OUTLOOK.EXE
F15 & n::WinActivate Evernote
F15 & u::WinActivate ahk_exe idea64.exe
F15 & o::WinActivate ahk_class SpotifyMainWindow
F15 & p::WinActivate ahk_class tSkMainForm ;Skype
F15 & b::WinActivate Board
F15 & s::WinActivate SysAdmin
F15 & d::WinActivate ION.NET
F15 & c::WinActivate Google Chrome
F15 & w::WinActivate WhatsApp
F15 & l::DllCall("LockWorkStation")
F15 & Up::Send {Volume_Up} 
F15 & Down::Send {Volume_Down} 
F15 & Delete::Send {Volume_Mute}


;-----------------------
; Mac OS alike shortcuts
;-----------------------
^!4::run "c:\windows\system32\SnippingTool.exe"

; --------------------------------------------------------------
; Control as esc
; --------------------------------------------------------------
Ctrl UP::Send {Escape}
Ctrl & F13::

; --------------------------------------------------------------
; Shifts as parents
; --------------------------------------------------------------
LShift UP::Send (
LShift & F13::return
RShift UP::Send )
RShift & F13::return


; --------------------------------------------------------------
; NOTES
; --------------------------------------------------------------
; ! = ALT
; ^ = CTRL
; + = SHIFT
; # = WIN

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

^+k::ResizePct(0, 0, 1, 1)
^+j::ResizePct(1/5, 1/10, 3/5, 8/10)

^+h::ResizePct(0, 0, 1/2, 1)
^+l::ResizePct(1/2, 0, 1/2, 1)

^+y::ResizePct(0, 0, 1/3, 1)

^+o::ResizePct(1/3, 0, 2/3, 1)

^+i::ResizePct(0, 0, 1, 1/2)
^+m::ResizePct(0, 1/2, 1, 1/2)

^+u::ResizePct(1/8, 0, 3/4, 1)
^+n::ResizePct(1/6, 0, 2/3, 1)

; -------------------
; Die in hell, stupid applications!
; -------------------
#IfWinActive Chrome
    ^h::Send {Backspace}
    ^w::Send !{Backspace}
    ^k::Send +{End}{Backspace}

#IfWinActive Intellij
    ^h::Send {Backspace}

#IfWinActive Evernote
    ^h::Send {Backspace}
    ^w::Send ^{Backspace}
    ^k::Send +{End}{Backspace}

#IfWinActive ahk_class MozillaWindowClass
    ^h::Send {Backspace}
    ^w::Send ^{Backspace}

#IfWinActive Mail
    ^h::Send {Backspace}
    ^w::Send ^{Backspace}
    ^k::Send +{End}{Backspace}

#IfWinActive Monitor
    j::Send {Down}
    k::Send {Up}
    ^B::Send {PgUp}
    ^F::Send {PgDn}

#IfWinActive RIDE
    ^h::Send {Backspace}

#IfWinActive ahk_class tSkMainForm
    ConversationUp()
    {
        Send, {AltDown}2{AltUp}
        Sleep, 100
        Send, {Up}{Enter}
        return
    }

    ConversationDown()
    {
        Send, {AltDown}2{AltUp}
        Sleep, 100
        Send, {Down}{Enter}
        return
    }
    ^j::ConversationDown()
    ^k::ConversationUp()
    CTRL UP::return
    ^h::Send {Backspace}
    ^w::Send !{Backspace}

#IfWinActive Slack
    ^h::Send {Backspace}
    ^w::Send ^{Backspace}
    ^k::Send +{End}{Backspace}
    
#IfWinActive SQuirreL 
    ^h::Send {Backspace}
    ^w::Send ^{Backspace}
    ^k::Send +{End}{Backspace}

#IfWinActive TortoiseSVN
    ^h::Send {Backspace}
    ^w::Send ^{Backspace}

#IfWinActive Word
    ^h::Send {Backspace}
    ^w::Send ^{Backspace}

#IfWinActive ahk_exe mintty.exe
    ; Send ✠ on <C-CR> -- Vim uses it
    ^Return::Send {U+2720}
    ; Send Ř on <C-S-P> -- Vim uses it
    ^+P::Send {U+0158}

