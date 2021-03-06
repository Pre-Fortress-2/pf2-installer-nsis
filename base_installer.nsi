; NSIS Modern User Interface
; Start Menu Folder Selection Example Script
; Written by Joost Verburg

; --------------------------------
; Include Modern UI

!include "MUI2.nsh"
!include "strreplace.nsh"

; --------------------------------
; General
!if ${INCLUDE_GAME} == 1
	!define ARCHIVENAME "${GAMEDIR}_full_${VERSION}.7z"
	Name "${GAMENAME} ${VERSION}"
	OutFile "${GAMEDIR}-${VERSION}-full-game.exe"
!endif
!if ${UPDATER} == 1
	!define ARCHIVENAME "${GAMEDIR}_patch_${PREVERSION}_to_${VERSION}.7z"
	Name "${GAMENAME} ${VERSION} Update"
	OutFile "${GAMEDIR}-${PREVERSION}-to-${VERSION}-updater.exe"
!endif
!if ${UPDATER} == 0
	!if ${INCLUDE_GAME} == 0
		!define ARCHIVENAME "${GAMEDIR}_full_${VERSION}.7z"
		Name "${GAMENAME} ${VERSION}"
		OutFile "${GAMEDIR}-${VERSION}-full-installer.exe"
	!endif
!endif

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

!insertmacro MUI_PAGE_WELCOME
; !insertmacro MUI_PAGE_LICENSE "license.txt"
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
		StrCpy $INSTDIR "$1\"
	${EndIf}
	;MessageBox MB_OK $INSTDIR
FunctionEnd

; TODO cyanide fix this shit i cannot even compile this
!if ${UPDATER} == 1
	; --------------------------------
	; try read version.txt in the game folder
	Function checkVer
		IfFileExists $INSTDIR\${GAMENAME}\rev.txt VerExists
			MessageBox MB_OK "${GAMENAME} is not currently installed on this machine.$\nPlease use the $\"full$\" installer"
			Abort
		VerExists:
		;Read rev
		FileOpen $4 "$INSTDIR\${GAMENAME}\rev.txt" r
		FileRead $4 $1
		FileClose $4 ; and close the file
		${if} $1 < ${BASEREV}
			MessageBox MB_OK "The version of ${GAMENAME} installed is too low.$\nPlease update to ${PREVERSION} before using this installer."
			Abort
		${elseif} $1 == ${UPDATEREV}
			MessageBox MB_OK "This version of ${GAMENAME} already installed."
		${endif}
	FunctionEnd
!endif

; --------------------------------
; verify the 7z archive exists
Function checkGameArchiveExists
!if ${INCLUDE_GAME} == 0
	IfFileExists "$EXEDIR\${ARCHIVENAME}" ArchiveExists
	!if ${VERSION} == 0.6 
		
		IfFileExists "$EXEDIR\PF2-v06.7z" ArchiveExists
	!endif		
				MessageBox MB_OK "${ARCHIVENAME} is missing. Please download it from ${WEBSITE}."
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
		Call checkVer
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
		
		SetOutPath "$INSTDIR"
		
		; Extract the archive found in the same directory as the installer
		Nsis7z::ExtractWithDetails "$EXEDIR\${ARCHIVENAME}" "Extracting files %s..."
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
	CreateShortcut "$SMPROGRAMS\${GAMENAME}\${GAMENAME}.lnk" "$STEAMEXE" "-applaunch 243750 -game $\"C:\Program Files (x86)\Steam\steamapps\sourcemods\pf2$\"" "$INSTDIR\${GAMEDIR}\resource\game.ico" 0
	!insertmacro MUI_STARTMENU_WRITE_END
	
		; Add uninstall information to Add/Remove Programs
	WriteRegStr HKCU  "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GAMEDIR}" \
				"DisplayName" "${GAMENAME}"
	WriteRegStr HKCU  "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GAMEDIR}" \
				"UninstallString" "$\"$INSTDIR\${GAMEDIR}\Uninstall.exe$\""
SectionEnd

Section "Remind to restart steam" SecRestartSteam
	MessageBox MB_OK "Thank you for installing Pre-Fortress 2.$\nPlease restart Steam if you haven't already"
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
	!include "uninstall_list_${GAMEDIR}.txt"

	!insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
	Delete "$SMPROGRAMS\$StartMenuFolder\${GAMEDIR}.lnk"
	Delete "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk"
	RMDir "$SMPROGRAMS\$StartMenuFolder"

	DeleteRegKey HKCU "SOFTWARE\${COMPANYNAME}\"
	DeleteRegKey HKCU  "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GAMEDIR}"
	
	IfFileExists "$INSTDIR" 0 NoDelete
		MessageBox MB_YESNO|MB_ICONQUESTION "Would you like to remove the mod folder and all user generated files such as demos and screenshots?" IDNO NoDelete
			RMDir /r "$INSTDIR"
	NoDelete:

SectionEnd