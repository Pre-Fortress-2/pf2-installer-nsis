; --------------------------------
; defines
!define UPDATER 0 ; Are we an updater or an installer
!define INCLUDE_GAME 0 ; Are we including the game archive

!define VERSION "0.7.2" ; Installer version
!define COMPANYNAME "PF2Team" ;  Used as the registry folder
!define GAMENAME "Pre-Fortress 2" ; Installer game
!define GAMEDIR "pf2"
!define WEBSITE "prefortress.com"

!define GAMESIZE 5820000 ; size of extracted archive in kb

; --------------------------------
; updater defines
!define PREVERSION "0.7.1" ; Previous version
!define BASEREV 86 ; Minimum revision we can install onto
!define UPDATEREV 87 ; Current revision

; --------------------------------
; Actual installer

!include "base_installer.nsi"