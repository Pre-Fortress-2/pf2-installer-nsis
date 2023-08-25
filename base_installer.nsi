; NSIS Modern User Interface
; Start Menu Folder Selection Example Script
; Written by Joost Verburg

; --------------------------------
; Include Modern UI

!include "MUI2.nsh"
!include "strreplace.nsh"
!include "strcontains.nsh"

; --------------------------------
; General
!if ${INCLUDE_GAME} == 1
	!define ARCHIVENAME "${GAMEDIR}_full_${VERSION}.7z"
	Name "${GAMENAME} ${VERSION}"
	OutFile "${GAMEDIR}-${VERSION}-full-game.exe"
!endif
;!if ${UPDATER} == 1
;
;	!if ${VERSION} == 0.7.2
;		!define PART01 ".001"
;		!define PART02 ".002"
;	!endif
;	!define ARCHIVENAME "${GAMEDIR}_patch_${PREVERSION}_to_${VERSION}.7z"
;	Name "${GAMENAME} ${VERSION} Update"
;	OutFile "${GAMEDIR}-${PREVERSION}-to-${VERSION}-updater.exe"
;!endif
;!if ${UPDATER} == 0
!if ${INCLUDE_GAME} == 0
	!if ${VERSION} == 0.7.2
		!define PART01 ".001"
		!define PART02 ".002"
	!endif
	!define ARCHIVENAME "${GAMEDIR}_full_${VERSION}.7z"
	
	
	!if ${UPDATER} == 1
		OutFile "${GAMEDIR}-${VERSION}-updater.exe"
		Name "${GAMENAME} ${VERSION} Updater"
	!else
		OutFile "${GAMEDIR}-${VERSION}-full-installer.exe"
		Name "${GAMENAME} ${VERSION}"
	!endif
	
!endif
;!endif

Unicode True

; Get installation folder from registry if available
InstallDirRegKey HKCU "SOFTWARE\${COMPANYNAME}" "InstallationDirectory"

; Request application privileges for Windows Vista
RequestExecutionLevel user

; --------------------------------
; Variables

Var StartMenuFolder
Var STEAMEXE

; --------------------------------
; Interface Settings

!define MUI_ABORTWARNING

; --------------------------------
; Customizations

!define MUI_ICON "assets\game.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "assets\banner.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "assets\side.bmp"

; --------------------------------
; Pages
!if ${UPDATER} == 1
!define MUI_PAGE_HEADER_TEXT "${GAMENAME} ${VERSION}"
!define MUI_WELCOMEPAGE_TITLE "Welcome to the ${GAMENAME} ${VERSION} Updater"
!define MUI_WELCOMEPAGE_TEXT  "This setup will guide you with updating your Pre-Fortress 2 ${PREVERSION} build to ${VERSION}.$\r$\n$\r$\nClick Next to continue."
!define MUI_DIRECTORYPAGE_TEXT_TOP "This setup will update your ${GAMENAME} ${PREVERSION} build in the following folder. If your ${GAMENAME} ${PREVERSION} build is in another directory, click Browse and select another folder. Click Next to continue."
!define MUI_PAGE_HEADER_SUBTEXT "Choose the folder where your ${GAMENAME} ${PREVERSION} build is located."

!else
!define MUI_WELCOMEPAGE_TEXT  "This setup will guide you with installing the Pre-Fortress 2 ${VERSION} build.$\r$\n$\r$\nClick Next to continue."
!define MUI_DIRECTORYPAGE_TEXT_TOP "This setup will install the Pre-Fortress ${VERSION} build in the following folder. If you wish to install into another folder, click Browse and select another folder. Click Next to continue."
!define MUI_PAGE_HEADER_SUBTEXT "Choose the folder where your ${GAMENAME} ${VERSION} build will be located."
!endif

!insertmacro MUI_PAGE_WELCOME

!insertmacro MUI_PAGE_LICENSE "license.txt"
; !insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY

; Start Menu Folder Page Configuration
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "${GAMENAME}"
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKCU"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "SOFTWARE\${COMPANYNAME}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"

!insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder

!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

; --------------------------------
; Languages

!insertmacro MUI_LANGUAGE "English"

; --------------------------------
; Misc things
!include "FileFunc.nsh"
!insertmacro GetParent

; --------------------------------
; check for SourceModInstallPath
Function getRegKeys
	ClearErrors
	ReadRegStr $0 HKCU "Software\Valve\Steam\" "SteamExe"
	ReadRegStr $1 HKCU "Software\Valve\Steam\" "SourceModInstallPath"
	${If} ${Errors}
		MessageBox MB_OK "Installation cancelled! Steam is not detected on this machine."
		Abort
	${Else}
		${StrRep} '$STEAMEXE' '$0' '/' '\'
		${If} ${UPDATER} == 1
			StrCpy $INSTDIR "$1\pf2"
		${Else}
			StrCpy $INSTDIR "$1\"
		${EndIf}
	${EndIf}
	;MessageBox MB_OK $INSTDIR
FunctionEnd

Section "Updater" secUpdater
!if ${UPDATER} == 1
	; --------------------------------
	; Assume that this is 0.7 hotfix version. Delete all of the vpk files as our structure has changed
	; Expect the pf2 folder to be the actual install dir
	!define PF2Folder ""
	
	!if ${VERSION} == 0.7.2
		; Look if this folder is a pf2 build folder. If not, cancel the update.
		Push "$INSTDIR"
		Push "\pf2"
		Call StrContains
		Pop $0 
		StrCmp $0 "" PF2BuildNotFound
			
		MessageBox MB_OK "Warning! This updater will delete files. Be sure to back up any files in case anything happens!"	
		IfFileExists "$INSTDIR" PreUpdateDelete UpdateError
	
		PreUpdateDelete:
			RMDir /r $INSTDIR\scenes
			Delete $INSTDIR\maps\cp_powerhouse.bsp
			Delete $INSTDIR\pf2_misc_*.vpk
			Delete $INSTDIR\custom\07hotfix_patch_*.vpk
			Delete $INSTDIR\gameinfo.txt
			goto FinishedUpdating
				
		UpdateError:
			MessageBox MB_OK "${GAMENAME} is not installed in this folder.$\nPlease use the $\"full$\" installer"
			Abort	
		
		PF2BuildNotFound:
			MessageBox MB_OK "This directory is not a pf2 build folder! Relaunch the updater again and select a pf2 folder to update!"
			Abort
			
		FinishedUpdating:
	
	!endif
!endif
SectionEnd

; --------------------------------
; verify the 7z archive exists
Function checkGameArchiveExists
!if ${INCLUDE_GAME} == 0
	!if ${VERSION} == 0.7.2
		IfFileExists "$EXEDIR\${ARCHIVENAME}${PART01}" part02
	part02:
		IfFileExists "$EXEDIR\${ARCHIVENAME}${PART02}" ArchiveExists
	!endif
	!if ${VERSION} == 0.6 
		
		IfFileExists "$EXEDIR\PF2-v06.7z" ArchiveExists
	!endif		
				!if ${VERSION} == 0.7.2
					MessageBox MB_OK "Either ${ARCHIVENAME}${PART01} or ${ARCHIVENAME}${PART02} is missing. Please download them from ${WEBSITE}."
				!else
					MessageBox MB_OK "${ARCHIVENAME} is missing. Please download it from ${WEBSITE}."
				!endif
				Abort
		ArchiveExists:
!endif

FunctionEnd

; --------------------------------
; OnInit
Function .onInit
	ClearErrors
	Call checkGameArchiveExists
!if ${UPDATER} == 1
	ReadRegStr $0 HKCU "SOFTWARE\${COMPANYNAME}\" ""
	${If} ${Errors}
		; Didn't find the registry key, maybe they're updating ontop of an existing install
		Call getRegKeys
		; Look for version.txt in game directory
		;Call checkVer
	${Else}
		StrCpy $INSTDIR "$0\"
	${EndIf}
!else
	Call getRegKeys
!endif

FunctionEnd

; --------------------------------
; Installer Sections

Section "Global Install Settings" SecGlobeSet

	; Set game size
	AddSize ${GAMESIZE}

	; Store installation folder
	WriteRegStr HKCU "SOFTWARE\${COMPANYNAME}" "InstallationDirectory" $INSTDIR

SectionEnd

!if ${INCLUDE_GAME} == 1
	Section "Full Game" SecFull
		SetOutPath "$TEMP\PF2-Installer"
		File "assets\${ARCHIVENAME}"
		SetOutPath "$INSTDIR"
		Nsis7z::ExtractWithDetails "$TEMP\PF2-Installer\${ARCHIVENAME}" "Extracting files %s..."
		RMDir /r "$TEMP\PF2-Installer"
	SectionEnd
!endif
!if ${INCLUDE_GAME} == 0
	Section "Dummy Section" SecDummy
	; Go back one as the pf2 folder was selected for the updater.

		!if ${UPDATER} == 1
			${GetParent} "$INSTDIR" $INSTDIR
		!endif 
		SetOutPath "$INSTDIR"
		; Extract the archive found in the same directory as the installer.
		!if ${VERSION} == 0.7.2
			Delete $INSTDIR\custom\07hotfix_patch_*.vpk
			Nsis7z::ExtractWithDetails "$EXEDIR\${ARCHIVENAME}${PART01}" "Extracting files %s..."
		!else
			Nsis7z::ExtractWithDetails "$EXEDIR\${ARCHIVENAME}" "Extracting files %s..."
		!endif

	SectionEnd
!endif

Section "Uninstaller and Shortcuts" SecShort
	; Create uninstaller
	WriteUninstaller "$INSTDIR\${GAMEDIR}\Uninstall.exe"
	
	!insertmacro MUI_STARTMENU_WRITE_BEGIN Application
	; Create shortcuts
	CreateDirectory "$SMPROGRAMS\${GAMENAME}"
	CreateShortcut "$SMPROGRAMS\${GAMENAME}\Uninstall PF2.lnk" "$INSTDIR\${GAMEDIR}\Uninstall.exe"
	; TODO; Need to instead go to the steam directory. Go to steamapps. Read libraryfolders.vdf. Find the folder with 243750
	; Construct a path to the install. Then make the shortcut include -steam. Because fuck valve
	CreateShortcut "$SMPROGRAMS\${GAMENAME}\${GAMENAME}.lnk" "$STEAMEXE" "-applaunch 243750 -game $INSTDIR\${GAMEDIR} "$INSTDIR\${GAMEDIR}\resource\game.ico" 0
	!insertmacro MUI_STARTMENU_WRITE_END
	
		; Add uninstall information to Add/Remove Programs
	WriteRegStr HKCU  "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GAMEDIR}" \
				"DisplayName" "${GAMENAME}"
	WriteRegStr HKCU  "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GAMEDIR}" \
				"UninstallString" "$\"$INSTDIR\${GAMEDIR}\Uninstall.exe$\""
SectionEnd

Section "Remind to restart steam" SecRestartSteam
!if ${UPDATER} == 1
	MessageBox MB_OK "Thank you for updating Pre-Fortress 2.$\nEnjoy!"
!else
	MessageBox MB_OK "Thank you for installing Pre-Fortress 2.$\nPlease restart Steam."
!endif
	
SectionEnd

; --------------------------------
; Descriptions

; Language strings
LangString DESC_SecDummy ${LANG_ENGLISH} "A test section."

; Assign language strings to sections
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${SecDummy} $(DESC_SecDummy)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; --------------------------------
; Uninstaller Section

Section "Uninstall"

	Delete "$INSTDIR\Uninstall.exe"
	; Delete only installer created files, leave user ones
	;!include "uninstall_list_${GAMEDIR}.txt"

	!insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
	Delete "$SMPROGRAMS\$StartMenuFolder\${GAMEDIR}.lnk"
	Delete "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk"
	RMDir "$SMPROGRAMS\$StartMenuFolder"

	DeleteRegKey HKCU "SOFTWARE\${COMPANYNAME}\"
	DeleteRegKey HKCU  "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GAMEDIR}"
	
	IfFileExists "$INSTDIR" 0 DeleteModFolderNotCFG
		MessageBox MB_YESNO|MB_ICONQUESTION "Would you like to leave your config files and custom folder?" IDYES DeleteModFolderNotCFG
			RMDir /r "$INSTDIR"
			goto FinishedDeletion
	DeleteModFolderNotCFG:
			RMDir /r "$INSTDIR\bin"
			RMDir /r "$INSTDIR\maps"
			RMDir /r "$INSTDIR\media"
			RMDir /r "$INSTDIR\resource"
			RMDir /r "$INSTDIR\scenes"
			RMDir /r "$INSTDIR\scripts"
			Delete "$INSTDIR\pf2_misc_*"
			Delete "$INSTDIR\pf2_models_*"
			Delete "$INSTDIR\pf2_scripts_*"
			Delete "$INSTDIR\pf2_sound_*"
			Delete "$INSTDIR\pf2_textures_*"
			Delete "$INSTDIR\steam.inf"
			Delete "$INSTDIR\pf2.fgd"
			Delete "$INSTDIR\gameinfo.txt"
	FinishedDeletion:
SectionEnd