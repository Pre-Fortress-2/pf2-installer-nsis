; --------------------------------
; defines
!define UPDATER 1 ; Are we an updater or an installer

!define VERSION "2.0.2" ; Installer version
!define COMPANYNAME "Eminoma" ;  Used as the registry folder
!define GAMENAME "Team Fortress 2 Classic" ; Installer game
!define GAMEDIR "tf2classic"

!define GAMESIZE 6753078 ; size of extracted archive in kb

; --------------------------------
; updater defines
!define PREVERSION "2.0.1" ; Previous version
!define BASEREV 47 ; Minimum revision we can install onto
!define UPDATEREV 84 ; Current revision

; --------------------------------
; Actual installer

!include "base_installer.nsi"