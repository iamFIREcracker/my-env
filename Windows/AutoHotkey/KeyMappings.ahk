#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#UseHook ; https://autohotkey.com/docs/commands/_UseHook.htm
#InstallKeybdHook
#SingleInstance force

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

SetTitleMatchMode 2

SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; --------------------------------------------------------------
; Window groups
; --------------------------------------------------------------
GroupAdd, ChromeGroup, ahk_exe chrome.exe
GroupAdd, ExcelGroup, ahk_exe EXCEL.EXE
GroupAdd, OutlookGroup, ahk_exe OUTLOOK.EXE
GroupAdd, TeamsGroup, ahk_exe Teams.exe

; --------------------------------------------------------------
; Natural scrolling
; --------------------------------------------------------------
#MaxHotkeysPerInterval 400
WheelDown::WheelUp
WheelUp::WheelDown


; --------------------------------------------------------------
; Control as esc
; --------------------------------------------------------------
Ctrl UP::Send {Escape}
Ctrl & F13::return

; --------------------------------------------------------------
; Shifts as parents
; --------------------------------------------------------------
LShift UP::Send (
LShift & F13::return
RShift UP::Send )
RShift & F13::return

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
; Vim mode
; --------------------------------------------------------------
F14 UP::Send {Tab}
F14 & h::Send {Left}
F14 & j::Send {Down}
F14 & k::Send {Up}
F14 & l::Send {Right}
F14 & b::Send ^{Left}
F14 & w::Send ^{Right}
F14 & p::Send ^+v
;F14 & p::Send +{Insert}
;  ClipSaved := ClipboardAll  ;save original clipboard contents
;  clipboard = %clipboard%  ;remove formatting
;  Send   ^+v
;  Clipboard := ClipSaved  ;restore the original clipboard contents
;  ClipSaved =  ;clear the variable
;Return

; --------------------------------------------------------------
; Sane pasting
; --------------------------------------------------------------
;^v::Send  ^+v ;Send Ctrl+Shift+v -- unformatted paste
;^+v::Send ^v  ;Send Ctrl+v -- regular paste command (should you ever need it)


; --------------------------------------------------------------
; Application shortcuts -- my left ctrl has been remapped to F15
; --------------------------------------------------------------
F15 & d::WinActivate ahk_exe WINWORD.EXE
F15 & e::GroupActivate, ExcelGroup, R
F15 & h::WinActivate ahk_class mintty_scratchpad
F15 & i::GroupActivate, TeamsGroup, R
F15 & j::WinActivate ahk_class mintty_fullscreen
F15 & k::GroupActivate, ChromeGroup, R
;F15 & m::
;    WinActivate ahk_class mintty_mail
;    Send ^f1
;    return
F15 & m::GroupActivate, OutlookGroup, R
F15 & n::WinActivate Evernote
; WinActivate does not work with spotify.exe anymore; the window is
; focused but then pressing <space> does not triggere Play/Pause as
; expected.  Why would WinActivateBottom work instead?  No idea..
F15 & o::WinActivateBottom ahk_exe spotify.exe
;F15 & p::
;    WinActivate ahk_class mintty_mail
;    Send ^f2
;    return
F15 & p::WinActivate ahk_class mintty_mail
F15 & u::WinActivate ahk_exe idea64.exe
F15 & y::WinActivate ahk_class mintty_workstation
F15 & Up::Send {Volume_Up}
F15 & Down::Send {Volume_Down}
F15 & Delete::Send {Volume_Mute}


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

^+y::ResizePct(0, 0, 1/4, 1)
^+o::ResizePct(1/4, 0, 3/4, 1)

^+i::ResizePct(0, 0, 1, 1/2)
^+m::ResizePct(0, 1/2, 1, 1/2)

^+u::ResizePct(1/8, 0, 3/4, 1)
^+n::ResizePct(1/6, 0, 2/3, 1)

; -------------------
; Die in hell, stupid applications!
; -------------------
#IfWinActive Intellij
    ^h::Send {Backspace}

#IfWinActive Evernote
    ^h::Send {Backspace}
    ^w::Send ^{Backspace}
    ^k::Send +{End}{Backspace}

#IfWinActive ahk_class MozillaWindowClass
    ^h::Send {Backspace}
    ^w::Send ^{Backspace}

#IfWinActive ahk_exe chrome.exe
    ^a::Send {Home}
    ^h::Send {Backspace}
    ^k::Send +{End}{Backspace}
    ^w::Send ^{Backspace}
    !b::Send ^{Left}
    !f::Send ^{Right}
    ^e::Send {End}
    ^u::Send +{Home}{Backspace}

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

#IfWinActive ahk_exe Teams.exe
    ^a::Send {Home}
    ^e::Send {End}
    ^h::Send {Backspace}
    ^w::Send ^{Backspace}
    ^k::Send +{End}{Backspace}
    ^u::Send +{Home}{Backspace}

#IfWinActive Word
    ^h::Send {Backspace}
    ^w::Send ^{Backspace}

#IfWinActive ahk_exe mintty.exe
    ; Send ◊ on <C-CR> -- Vim uses it
    ^Return::Send {U+25CA}
    ; Send Ø on <S-CR> -- Vim uses it
    +Return::Send {U+00F8}
    ;; Reset ^v behavior -- we use ^V with vim
    ;^v::Send ^v
    F14 & p::Send +{Insert}

#IfWinActive ahk_exe SearchUI.exe
    ^w::Send ^{Backspace}

#IfWinActive ahk_exe OUTLOOK.EXE
    ^a::Send {Home}
    ^e::Send {End}
    ^h::Send {Backspace}
    ^w::Send ^{Backspace}
    ^SPACE::Send ^k
    ^k::Send +{End}{Backspace}
    F14 & p::
        Send ^v
        sleep, 100
        Send ^k
        sleep, 100
        Send t
        return

#IfWinActive ahk_exe WINWORD.EXE
    ^a::Send {Home}
    ^e::Send {End}
    ^h::Send {Backspace}
    ^w::Send ^{Backspace}
    ^k::Send +{End}{Backspace}

#IfWinActive ahk_exe POWERPNT.EXE
    ^a::Send {Home}
    ^e::Send {End}
    ^h::Send {Backspace}
    ^w::Send ^{Backspace}
    ^k::Send +{End}{Backspace}

#IfWinActive ahk_exe Discord.exe
    ^w::Send ^{Backspace}
