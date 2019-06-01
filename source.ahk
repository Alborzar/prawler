/*	prawler
 *	Version 1.3.1
 *	Entwickelt von Alborzar
 */


Info("prawler")
Credits("Entwickelt von Alborzar")

Menu, Tray, NoStandard
Menu, Tray, Add, Nach Update suchen, Update
Menu, Tray, Add
Menu, Tray, Add, Beenden, GuiClose

;Adminpermissions
if (!A_IsAdmin) {
	Run *RunAs "%A_ScriptFullPath%",, UseErrorLevel
	if (ErrorLevel) {
		MsgBox, 262453, prawler (SA:MP 0.3.7-R1), % "Bitte starte prawler als Administrator, damit das Programm komplett funktionsfähig ist"
		IfMsgBox, Retry
			Reload
		else
			ExitApp
	}
	return
}

URLDownloadToFile, https://www.dl.alborzar.eu/prawler/res/titel.png, %A_MyDocuments%\prawler_loading_screen.png
SplashImage, %A_MyDocuments%\prawler_loading_screen.png, B, prawler wird gestartet. Bitte warten..., , prawler

;Presettings
#IfWinActive, GTA:SA:MP
#NoEnv
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
#SingleInstance Force
OnExit, GuiClose
ListLines Off
Process, Priority, , A
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
SendMode Input

;Globals
global projectname 				:= "prawler"
global version 					:= "1.3.1"
global mainURL 					:= "https://www.dl.alborzar.eu/prawler"
global MainColor				:= "{4286f4}"
global SecColor					:= "{FFFFFF}"
global prefix 					:= "" MainColor "prawler {C0C0C0}• " SecColor ""
global authkey 					:= "isKhZTagu3JropUq"
global PasswordShown 			:= true
global oTextDraws 				:= []
global passengers				:= []
global RainbowActivated 		:= 0
global CheckpointTDEnabled 		:= 0
global hudred 					:= 0
global hudblue 					:= 0
global hudgreen 				:= 255
global inVehicle 				:= 0 
global HealCounter 				:= 0
global DeathtimerEnabled 		:= false
global DeathCounter 			:= 0
global TanktextdrawHidden 		:= false
global userStatus 				:= "n/A"
global inVehicle 				:= 0
global CarShowName 				:= 0
global timeout 					:= 1
global timeout 					:= true
global CustomTimeout 			:= 0
global stateInVehicle 			:= false
global PaydayZeit				:= 0
global RouteAktiv				:= 0
global MaterialsDelivered		:= 1
global Materials				:= 0
global FischTimerStatus			:= false
global fishNumber				:= 0
global isDead					:= false
global gameactive				:= false
global checkpointEntered		:= 0
global oldPlayerStatus			:= ""
global connectedToChat			:= 0
global fishTime					:= 0
global loaded					:= 0
global alreadyRobbing			:= 0
global SpendenaufrufActive		:= 0
global collectedMoney			:= 0
global Fraktion					:= "Zivilist"
global CPActive					:= 0
global WDPartner				:= "none"
global DrugsPlanted				:= 0
global DrugsSec					:= 0
global subcounter				:= 0
global afishactive				:= 0
global WortsalatAktiv			:= 0
global originalesWort			:= ""
global attemp					:= 0
global PilotAktiv				:= 0
global Tempomat					:= 0
global TachoStatus				:= 0

hotkeylist=
(
[F2]`tHilfemenü
[F9]`tMembers Liste
[Entf]`tPanickey (Direktes Beenden)
[Ä]`tLetzte Chateingabe wiederholen
[M]`tFahrzeug starten/stoppen
[Y]`t/Lock
[X]`tSchnelltaste
[,]`t/Carkey
[#]`tStatistiken anzeigen
[2]`tFische essen
[3]`tErstehilfepaket benutzen
[4]`tDrogen nehmen
[STRG] + [R]`tStorerob starten
)

premiumfeatures=
(
/Add`tFreund hinzufügen
/Del`tFreund entfernen
/Delall`tAlle Freunde entfernen
/Freunde`tFreunde anzeigen
/Fpslock`tFPS locken
/Fpsunlock`tFPS freigeben
)

commandslist=
(
/Prawlerhelp`tHilfemenü
/Settings`tEinstellungen öffnen
/Taschenrechner(/Tr)`tTaschenrechner
/Chatclear`tChat leeren
/Link`tLetzten Link kopieren
/Rainbow`tRainbow Mode
/Textdraws`tAlle Textdraws anzeigen (Dialog)
/Profil`tInformationen zum Benutzerkonto
/Finanzen(/Fin)`tFinanzen anzeigen
/Savestats`tStatistiken speichern
/Alotto`tZufälliges Lotto spielen
/Resms(/Re)`tAuf letzte SMS antworten
/Afish`tAutomatisches Fischen
/Asell`tAutomatisches Verkaufen der Fische
/Acook`tAutomatisches Kochen der Fische
/P`tAnruf annehmen
/H`tAnruf beenden
/Countdown(/Cd)`tCountdown starten
/Tempomat(/Temp)`tTempomat aktivieren
/Pc`tPrawler Chat
/Togpc`tPrawler Chat ein-/ausschalten
/Admins`tModifizierter Serverbefehl
/Time`tModifizierter Serverbefehl
/Delivery`tModifizierter Serverbefehl
/C`t/Crew
/Cm`t/Crewmembers
/Ck`t/Crewkasse
)

nrcommands=
(
/Spendenaufruf`tSpendenaufruf starten / beenden
/Wortsalat`TWortsalat starten / beenden
/W1`tErstes Wort ausgeben
/W1Stop`tErstes Wort abschließen
/W2`tZweites Wort ausgeben
/W2Stop`tZweites Wort abschließen
/W3`tDrittes Wort ausgeben
/W3Stop`tDrittes Wort abschließen
)

;Textdraws
global TD_brandmark := New textdraw
global TD_position := New textdraw
global TD_fps := New textdraw
global TD_checkpoint := New textdraw
global TD_health := New textdraw
global TD_armor := New textdraw
global TD_schaden := New textdraw
global TD_payday := New textdraw
global TD_online := New textdraw
global TD_fisch := New textdraw
global TD_drugs := New textdraw
global TD_tacho := New textdraw
global STD_reallife := New textdraw
global STD_gtacity := New textdraw
global STD_url := New textdraw
global STD_time := New textdraw
global STD_tachobox1 := New textdraw
global STD_tachobox2 := New textdraw
global STD_tachotext := New textdraw

;Textlabels
global TL_jobtime := New textlabel
global TL_grotti_alpha := New textlabel
global TL_grotti_banshee := New textlabel
global TL_grotti_buffalo := New textlabel
global TL_grotti_infernus := New textlabel
global TL_grotti_cheetah := New textlabel
global TL_grotti_turismo := New textlabel
global TL_grotti_bullet := New textlabel
global TL_grotti_jester := New textlabel
global TL_grotti_sultan := New textlabel
global TL_grotti_supergt := New textlabel
global TL_cas_pcj600 := New textlabel
global TL_cas_freeway := New textlabel
global TL_cas_sanchez := New textlabel
global TL_cas_wayfarer := New textlabel
global TL_cas_bf400 := New textlabel
global TL_cas_nrg500 := New textlabel
global TL_cas_bmx := New textlabel
global TL_cas_fcr900 := New textlabel

;Einstellungen
StandortEnabled := ReadSettings("Textdraws", "Standort")
FPSEnabled := ReadSettings("Textdraws", "FPS")
Schadensanzeige := ReadSettings("Textdraws", "Schadensanzeige")
CheckpointTDEnabled := ReadSettings("Textdraws", "Checkpoint")
DigiHPEnabled := ReadSettings("Textdraws", "DigiHP")
Paydayenabled := ReadSettings("Textdraws", "PayDay")
OnlinezeitEnabled := ReadSettings("Textdraws", "Onlinezeit")
FischtimerEnabled := ReadSettings("Textdraws", "Fischtimer")
DrogenEnabled := ReadSettings("Textdraws", "Drogen")

JobtimerEnabled := ReadSettings("Textlabels", "Jobtimer")

Fahrzeuganzeige := ReadSettings("Weiteres", "Fahrzeuganzeige")
AutoMotorLicht := ReadSettings("Weiteres", "AutoMotorLicht")
FormattedAd := ReadSettings("Weiteres", "FormattedAd")
FreundeBenachrichtigung := ReadSettings("Weiteres", "FreundeBenachrichtigung")
Killcounter := ReadSettings("Weiteres", "Killcounter")
PrawlerChat := ReadSettings("Weiteres", "PrawlerChat")
FischGesamt := ReadSettings("Weiteres", "Fisch Gesamtverdienst")
DeathspruchInFraktion := ReadSettings("Weiteres", "DeathspruchInFraktion")
DeathspruchInCrew := ReadSettings("Weiteres", "DeathspruchInCrew")
KillspruchInFraktion := ReadSettings("Weiteres", "KillspruchInFraktion")
KillspruchInCrew := ReadSettings("Weiteres", "KillspruchInCrew")
Tacho := ReadSettings("Weiteres", "Tacho")
ServerTextdraws := ReadSettings("Weiteres", "ServerTextdraws")

if(StandortEnabled != 1 && StandortEnabled != 0)
	WriteSettings(1, "Textdraws", "Standort")
if(FPSEnabled != 1 && FPSEnabled != 0)
	WriteSettings(1, "Textdraws", "FPS")
if(Schadensanzeige != 1 && Schadensanzeige != 0)
	WriteSettings(1, "Textdraws", "Schadensanzeige")
if(CheckpointTDEnabled != 1 && CheckpointTDEnabled != 0)
	WriteSettings(1, "Textdraws", "Checkpoint")
if(DigiHPEnabled != 1 && DigiHPEnabled != 0)
	WriteSettings(1, "Textdraws", "DigiHP")
if(Paydayenabled != 1 && Paydayenabled != 0)
	WriteSettings(1, "Textdraws", "PayDay")
if(OnlinezeitEnabled != 1 && OnlinezeitEnabled != 0)
	WriteSettings(1, "Textdraws", "Onlinezeit")
if(FischtimerEnabled != 1 && FischtimerEnabled != 0)
	WriteSettings(1, "Textdraws", "Fischtimer")
if(DrogenEnabled != 1 && DrogenEnabled != 0)
	WriteSettings(1, "Textdraws", "Drogen")

if(JobtimerEnabled != 1 && JobtimerEnabled != 0)
	WriteSettings(1, "Textlabels", "Jobtimer")

if(AutoMotorLicht != 1 && AutoMotorLicht != 0)
	WriteSettings(1, "Weiteres", "AutoMotorLicht")
if(Fahrzeuganzeige != 1 && Fahrzeuganzeige != 0)
	WriteSettings(1, "Weiteres", "Fahrzeuganzeige")
if(FormattedAd != 1 && FormattedAd != 0)
	WriteSettings(1, "Weiteres", "FormattedAd")
if(FreundeBenachrichtigung != 1 && FreundeBenachrichtigung != 0)
	WriteSettings(1, "Weiteres", "FreundeBenachrichtigung")
if(Killcounter != 1 && Killcounter != 0)
	WriteSettings(1, "Weiteres", "Killcounter")
if(PrawlerChat != 1 && PrawlerChat != 0)
	WriteSettings(1, "Weiteres", "PrawlerChat")
if(FischGesamt != 1 && FischGesamt != 0)
	WriteSettings(1, "Weiteres", "FischGesamt")
if(DeathspruchInFraktion != 1 && DeathspruchInFraktion != 0)
	WriteSettings(1, "Weiteres", "DeathspruchInFraktion")
if(DeathspruchInCrew != 1 && DeathspruchInCrew != 0)
	WriteSettings(1, "Weiteres", "DeathspruchInCrew")
if(KillspruchInFraktion != 1 && KillspruchInFraktion != 0)
	WriteSettings(1, "Weiteres", "KillspruchInFraktion")
if(KillspruchInCrew != 1 && KillspruchInCrew != 0)
	WriteSettings(1, "Weiteres", "KillspruchInCrew")
if(Tacho != 1 && Tacho != 0)
	WriteSettings(1, "Weiteres", "Tacho")
if(ServerTextdraws != 1 && ServerTextdraws != 0)
	WriteSettings(1, "Weiteres", "ServerTextdraws")

;Hotkeys
Loop, 20
{
	ownHotkeyActive := ReadHotkey("Hotkey_" A_Index, "Active")
	ownHotkeyText := ReadHotkey("Hotkey_" A_Index, "Text")
	ownHotkeyKey := ReadHotkey("Hotkey_" A_Index, "Key")
	if(ownHotkeyText == "ERROR")
		WriteHotkey("", "Hotkey_" A_Index, "Text")
	if(ownHotkeyKey == "ERROR")
		WriteHotkey("", "Hotkey_" A_Index, "Key")
	if(ownHotkeyKey != "" && ownHotkeyText != "")
		WriteHotkey("1", "Hotkey_" A_Index, "Active")
	else 
		WriteHotkey("0", "Hotkey_" A_Index, "Active")
	if(ownHotkeyKey != "" && ownHotkeyKey != "ERROR"){
		Hotkey, %ownHotkeyKey%, ownHotkeyLabel_%A_Index%
	}
}

Old_Version := ReadSettings("prawler", "Old_Version")

if(Old_Version < Version){
	FileRemoveDir, %A_AppData%\prawler\res, 1
	WriteSettings(version, "prawler", "Old_Version")
}else{
	WriteSettings(version, "prawler", "Old_Version")
}

;Checks
SplashImage, %A_MyDocuments%\prawler_loading_screen.png, B, Datenüberprüfung`nAlle Dateien werden überprüft..., , prawler
Sleep 500
IfNotExist, %A_AppData%\prawler
{
	FileCreateDir, %A_AppData%\prawler
	SplashImage, %A_MyDocuments%\prawler_loading_screen.png, B, Datenüberprüfung`nVerzeichnis erstellt (AppData/prawler), , prawler
	Random, waitMS, 100, 1000
	Sleep %waitMS%
}
IfNotExist, %A_AppData%\prawler\res
{
	FileCreateDir, %A_AppData%\prawler\res
	SplashImage, %A_MyDocuments%\prawler_loading_screen.png, B, Datenüberprüfung`nVerzeichnis erstellt (AppData/prawler/res), , prawler
	Random, waitMS, 100, 1000
	Sleep %waitMS%
}
IfNotExist, %A_AppData%\prawler\temp
{
	FileCreateDir, %A_AppData%\prawler\temp
	SplashImage, %A_MyDocuments%\prawler_loading_screen.png, B, Datenüberprüfung`nVerzeichnis erstellt (AppData/prawler/temp), , prawler
	Random, waitMS, 100, 1000
	Sleep %waitMS%
}
IfNotExist, %A_AppData%\prawler\res\titel.png
{
	URLDownloadToFile, %mainURL%/res/titel.png, %A_AppData%\prawler\res\titel.png
	SplashImage, %A_MyDocuments%\prawler_loading_screen.png, B, Datenüberprüfung`nDatei heruntergeladen (AppData/prawler/res/titel.png), , prawler
	Random, waitMS, 100, 1000
	Sleep %waitMS%
}
IfNotExist, %A_AppData%\prawler\res\ingameinfo.png
{
	URLDownloadToFile, %mainURL%/res/ingameinfo.png, %A_AppData%\prawler\res\ingameinfo.png
	SplashImage, %A_MyDocuments%\prawler_loading_screen.png, B, Datenüberprüfung`nDatei heruntergeladen (AppData/prawler/res/ingameinfo.png), , prawler
	Random, waitMS, 100, 1000
	Sleep %waitMS%
}
IfNotExist, %A_AppData%\prawler\res\button-changelog.png
{
	URLDownloadToFile, %mainURL%/res/button-changelog.png, %A_AppData%\prawler\res\button-changelog.png
	SplashImage, %A_MyDocuments%\prawler_loading_screen.png, B, Datenüberprüfung`nDatei heruntergeladen (AppData/prawler/res/button-changelog.png), , prawler
	Random, waitMS, 100, 1000
	Sleep %waitMS%
}
IfNotExist, %A_AppData%\prawler\res\button-samp.png
{
	URLDownloadToFile, %mainURL%/res/button-samp.png, %A_AppData%\prawler\res\button-samp.png
	SplashImage, %A_MyDocuments%\prawler_loading_screen.png, B, Datenüberprüfung`nDatei heruntergeladen (AppData/prawler/res/button-samp.png), , prawler
	Random, waitMS, 100, 1000
	Sleep %waitMS%
}
IfNotExist, %A_AppData%\prawler\res\button-teamspeak.png
{
	URLDownloadToFile, %mainURL%/res/button-teamspeak.png, %A_AppData%\prawler\res\button-teamspeak.png
	SplashImage, %A_MyDocuments%\prawler_loading_screen.png, B, Datenüberprüfung`nDatei heruntergeladen (AppData/prawler/res/button-teamspeak.png), , prawler
	Random, waitMS, 100, 1000
	Sleep %waitMS%
}
IfNotExist, %A_AppData%\prawler\res\willkommenstext.png
{
	URLDownloadToFile, %mainURL%/res/willkommenstext.png, %A_AppData%\prawler\res\willkommenstext.png
	SplashImage, %A_MyDocuments%\prawler_loading_screen.png, B, Datenüberprüfung`nDatei heruntergeladen (AppData/prawler/res/willkommenstext.png), , prawler
	Random, waitMS, 100, 1000
	Sleep %waitMS%
}
IfNotExist, %A_AppData%\prawler\res\button-back.png
{
	URLDownloadToFile, %mainURL%/res/button-back.png, %A_AppData%\prawler\res\button-back.png
	SplashImage, %A_MyDocuments%\prawler_loading_screen.png, B, Datenüberprüfung`nDatei heruntergeladen (AppData/prawler/res/button-back.png), , prawler
	Random, waitMS, 100, 1000
	Sleep %waitMS%
}
IfNotExist, %A_AppData%\prawler\res\titel-information.png
{
	URLDownloadToFile, %mainURL%/res/titel-information.png, %A_AppData%\prawler\res\titel-information.png
	SplashImage, %A_MyDocuments%\prawler_loading_screen.png, B, Datenüberprüfung`nDatei heruntergeladen (AppData/prawler/res/titel-information.png), , prawler
	Random, waitMS, 100, 1000
	Sleep %waitMS%
}
IfNotExist, %A_AppData%\prawler\res\informationstext.png
{
	URLDownloadToFile, %mainURL%/res/informationstext.png, %A_AppData%\prawler\res\informationstext.png
	SplashImage, %A_MyDocuments%\prawler_loading_screen.png, B, Datenüberprüfung`nDatei heruntergeladen (AppData/prawler/res/informationstext.png), , prawler
	Random, waitMS, 100, 1000
	Sleep %waitMS%
}
IfNotExist, %A_AppData%\prawler\res\titel-changelog.png
{
	URLDownloadToFile, %mainURL%/res/titel-changelog.png, %A_AppData%\prawler\res\titel-changelog.png
	SplashImage, %A_MyDocuments%\prawler_loading_screen.png, B, Datenüberprüfung`nDatei heruntergeladen (AppData/prawler/res/titel-changelog.png), , prawler
	Random, waitMS, 100, 1000
	Sleep %waitMS%
}
IfNotExist, %A_AppData%\prawler\res\button-beenden.png
{
	URLDownloadToFile, %mainURL%/res/button-beenden.png, %A_AppData%\prawler\res\button-beenden.png
	SplashImage, %A_MyDocuments%\prawler_loading_screen.png, B, Datenüberprüfung`nDatei heruntergeladen (AppData/prawler/res/button-beenden.png), , prawler
	Random, waitMS, 100, 1000
	Sleep %waitMS%
}
IfNotExist, %A_AppData%\prawler\res\gui-einstellungen.png
{
	URLDownloadToFile, %mainURL%/res/gui-einstellungen.png, %A_AppData%\prawler\res\gui-einstellungen.png
	SplashImage, %A_MyDocuments%\prawler_loading_screen.png, B, Datenüberprüfung`nDatei heruntergeladen (AppData/prawler/res/gui-einstellungen.png), , prawler
	Random, waitMS, 100, 1000
	Sleep %waitMS%
}
IfNotExist, %A_AppData%\prawler\res\gui-hotkeys.png
{
	URLDownloadToFile, %mainURL%/res/gui-hotkeys.png, %A_AppData%\prawler\res\gui-hotkeys.png
	SplashImage, %A_MyDocuments%\prawler_loading_screen.png, B, Datenüberprüfung`nDatei heruntergeladen (AppData/prawler/res/gui-hotkeys.png), , prawler
	Random, waitMS, 100, 1000
	Sleep %waitMS%
}
IfNotExist, %A_AppData%\prawler\res\button-hotkeys.png
{
	URLDownloadToFile, %mainURL%/res/button-hotkeys.png, %A_AppData%\prawler\res\button-hotkeys.png
	SplashImage, %A_MyDocuments%\prawler_loading_screen.png, B, Datenüberprüfung`nDatei heruntergeladen (AppData/prawler/res/button-hotkeys.png), , prawler
	Random, waitMS, 100, 1000
	Sleep %waitMS%
}
IfNotExist, %A_AppData%\prawler\res\button-variabeln.png
{
	URLDownloadToFile, %mainURL%/res/button-variabeln.png, %A_AppData%\prawler\res\button-variabeln.png
	SplashImage, %A_MyDocuments%\prawler_loading_screen.png, B, Datenüberprüfung`nDatei heruntergeladen (AppData/prawler/res/button-variabeln.png), , prawler
	Random, waitMS, 100, 1000
	Sleep %waitMS%
}

IfExist, update.bat
	FileDelete, update.bat

SplashImage, %A_MyDocuments%\prawler_loading_screen.png, B, Datenüberprüfung`nAbgeschlossen, , prawler
Sleep 1000
SplashImage, %A_MyDocuments%\prawler_loading_screen.png, B, Interface wird generiert, , prawler

;Includes
#Include src/includes/globals.ahk
#Include src/includes/Memory.ahk
#Include src/includes/SAMP-API.ahk
#Include src/includes/Extra-API.ahk
#Include src/includes/private_funcs.ahk
#Include src/includes/Toolbar.ahk

SplashImage, Off
SetTimer, checkGTA, 1000
gosub checkUpdate
SetTimer, checkUpdate, 30000

Gui -MaximizeBox -DPIScale
Gui Color, 0xC0C0C0
Gui Add, Picture, x0 y24 w449 h33, %A_AppData%\prawler\res\titel.png
Gui Add, Picture, x64 y152 w315 h161, %A_AppData%\prawler\res\ingameinfo.png
Gui Add, Picture, x1 y328 w142 h25 gshowChangelogs, %A_AppData%\prawler\res\button-changelog.png
Gui Add, Picture, x153 y328 w142 h25 gconnectToServer, %A_AppData%\prawler\res\button-samp.png
Gui Add, Picture, x305 y328 w142 h25 gconnectToTeamspeak, %A_AppData%\prawler\res\button-teamspeak.png
Gui Add, Picture, x24 y64 w401 h74, %A_AppData%\prawler\res\willkommenstext.png
Gui Show, w449 h361, prawler (SA:MP 0.3.7-R1)
hToolbar := CreateToolBar()
Return
	
CreateToolbar() {
    ImageList := IL_Create(15)
    IL_Add(ImageList, "shell32.dll", 278)
    IL_Add(ImageList, "shell32.dll", 73)
    IL_Add(ImageList, "shell32.dll", 123)
    IL_Add(ImageList, "shell32.dll", 51)

    Buttons = 
    (LTrim
        Informationen
        Einstellungen
        Update suchen
		-
		-
        v %version%,, DISABLED
    )

    Return ToolbarCreate("OnToolbar", Buttons, ImageList, "List ShowText Tooltips")
}

OnToolbar(hWnd, Event, Text, Pos, Id) {
    If (Event != "Click") {
        Return
    }

    If (Text == "Informationen") {
		Gui Informationen: -MinimizeBox -MaximizeBox -SysMenu +AlwaysOnTop -DPIScale
		Gui Informationen: Color, 0xC0C0C0
		Gui Informationen: Add, Picture, x0 y34 w142 h25 gInformationenGuiClose, %A_AppData%\prawler\res\button-back.png
		Gui Informationen: Add, Picture, x0 y0 w542 h33, %A_AppData%\prawler\res\titel-information.png
		Gui Informationen: Add, Picture, x11 y64 w518 h131, %A_AppData%\prawler\res\informationstext.png
		Gui Informationen: Show, w542 h205, prawler (SA:MP 0.3.7-R1)
    } Else If (Text == "Einstellungen") {
		StandortEnabled := ReadSettings("Textdraws", "Standort")
		FPSEnabled := ReadSettings("Textdraws", "FPS")
		Schadensanzeige := ReadSettings("Textdraws", "Schadensanzeige")
		CheckpointTDEnabled := ReadSettings("Textdraws", "Checkpoint")
		DigiHPEnabled := ReadSettings("Textdraws", "DigiHP")
		Paydayenabled := ReadSettings("Textdraws", "PayDay")
		OnlinezeitEnabled := ReadSettings("Textdraws", "Onlinezeit")
		FischtimerEnabled := ReadSettings("Textdraws", "Fischtimer")
		DrogenEnabled := ReadSettings("Textdraws", "Drogen")
		JobtimerEnabled := ReadSettings("Textlabels", "Jobtimer")
		Fahrzeuganzeige := ReadSettings("Weiteres", "Fahrzeuganzeige")
		AutoMotorLicht := ReadSettings("Weiteres", "AutoMotorLicht")
		FormattedAd := ReadSettings("Weiteres", "FormattedAd")
		FreundeBenachrichtigung := ReadSettings("Weiteres", "FreundeBenachrichtigung")
		Gui Einstellungen: -MinimizeBox -MaximizeBox -SysMenu +AlwaysOnTop -DPIScale
		Gui Einstellungen: Color, 0xC0C0C0
		Gui Einstellungen: Add, Picture, x0 y0, %A_AppData%\prawler\res\gui-einstellungen.png
		Gui Einstellungen: Add, Picture, x0 y34 gEinstellungenGuiClose, %A_AppData%\prawler\res\button-back.png
		Gui Einstellungen: Add, Picture, x400 y34 gopenOwnHotkeys, %A_AppData%\prawler\res\button-hotkeys.png
		
		;Textdraws
		Gui Einstellungen: Add, Checkbox, vCB_standort x48 y97 w16 h16 Checked%StandortEnabled%
		Gui Einstellungen: Add, Checkbox, vCB_fps x265 y97 w16 h16 Checked%FPSEnabled%
		Gui Einstellungen: Add, Checkbox, vCB_payday x48 y157 w16 h16 Checked%Paydayenabled%
		Gui Einstellungen: Add, Checkbox, vCB_fisch x48 y127 w16 h16 Checked%FischtimerEnabled%
		Gui Einstellungen: Add, Checkbox, vCB_checkpoint x265 y127 w16 h16 Checked%CheckpointTDEnabled%
		Gui Einstellungen: Add, Checkbox, vCB_onlinezeit x265 y157 w16 h16 Checked%OnlinezeitEnabled%
		Gui Einstellungen: Add, Checkbox, vCB_drogen x435 y157 w16 h16 Checked%DrogenEnabled%
		Gui Einstellungen: Add, Checkbox, vCB_schaden x435 y97 w16 h16 Checked%Schadensanzeige%
		Gui Einstellungen: Add, Checkbox, vCB_digihp x435 y127 w16 h16 Checked%DigiHPEnabled%
		
		;Textlabels
		Gui Einstellungen: Add, Checkbox, vCB_jobtimer x48 y220 w16 h16 Checked%JobtimerEnabled%
		
		;Automatische Funktionen
		Gui Einstellungen: Add, Checkbox, vCB_automfahrzeug x48 y286 w16 h16 Checked%AutoMotorLicht%
		Gui Einstellungen: Add, Checkbox, vCB_formattedad x265 y286 w16 h16 Checked%FormattedAd%
		Gui Einstellungen: Add, Checkbox, vCB_freundenachricht x48 y316 w16 h16 Checked%FreundeBenachrichtigung%
		
		Gui Einstellungen: Show, w600 h384, prawler (SA:MP 0.3.7-R1)
    } Else If (Text == "Update suchen") {
		gosub, Update
    }
}

;Sections
checkUpdate:
{
	URLDownloadToVar_(mainURL . "/version.txt", newestVersion)
	if(newestVersion > version){
		if(WinActive("GTA:SA:MP")){
			URLDownloadToVar_(mainURL . "/latest_changelog.txt", changelog)
			MsgBox, 68, prawler, Es wurde eine neue Version von prawler veröffentlicht!`nMöchtest du diese herunterladen?`n`nVersion: %newestVersion%`n`nChangelog:`n%changelog%
			IfMsgBox, Yes
			{
				UrlDownloadToFile, %mainURL%/prawler.exe, prawler.new.exe
				Sleep, 500
				updateBat =
				(LTrim
				ping 127.0.0.1 -n 2 > nul
				Del "prawler.exe"
				Rename "prawler.new.exe" "prawler.exe"
				"prawler.exe"
				)
				FileAppend, %updateBat%, update.bat
				Run, update.bat, , hide
				ExitApp
			}
		}else{
			ChatMessage("Es ist ein Update vorhanden! Update prawler im Interface via 'Update suchen'")
		}
	}
}
return

openOwnHotkeys:
{
	Loop, 20
	{
		ownHotkeyText_%A_Index% := ReadHotkey("Hotkey_" A_Index, "Text")
		ownHotkeyKey_%A_Index% := ReadHotkey("Hotkey_" A_Index, "Key")
	}
	Gui Hotkeys: -MinimizeBox -MaximizeBox -SysMenu +AlwaysOnTop -DPIScale
	Gui Hotkeys: Color, 0xC0C0C0
	Gui Hotkeys: Add, Picture, x0 y0, %A_AppData%\prawler\res\gui-hotkeys.png
	Gui Hotkeys: Add, Picture, x0 y34 gHotkeysGuiClose, %A_AppData%\prawler\res\button-back.png
	Gui Hotkeys: Add, Picture, x844 y34 gShowVariables, %A_AppData%\prawler\res\button-variabeln.png
	Gui Hotkeys: Add, Hotkey, v_ownHotkeyKey_1 x24 y67 w120 h21, %ownHotkeyKey_1%
	Gui Hotkeys: Add, Edit, v_ownHotkeyText_1 x160 y67 w304 h21, %ownHotkeyText_1%
	Gui Hotkeys: Add, Hotkey, v_ownHotkeyKey_2 x24 y98 w120 h21, %ownHotkeyKey_2%
	Gui Hotkeys: Add, Hotkey, v_ownHotkeyKey_3 x24 y130 w120 h21, %ownHotkeyKey_3%
	Gui Hotkeys: Add, Hotkey, v_ownHotkeyKey_4 x24 y162 w120 h21, %ownHotkeyKey_4%
	Gui Hotkeys: Add, Hotkey, v_ownHotkeyKey_5 x24 y194 w120 h21, %ownHotkeyKey_5%
	Gui Hotkeys: Add, Hotkey, v_ownHotkeyKey_6 x24 y226 w120 h21, %ownHotkeyKey_6%
	Gui Hotkeys: Add, Hotkey, v_ownHotkeyKey_7 x24 y258 w120 h21, %ownHotkeyKey_7%
	Gui Hotkeys: Add, Hotkey, v_ownHotkeyKey_8 x24 y290 w120 h21, %ownHotkeyKey_8%
	Gui Hotkeys: Add, Hotkey, v_ownHotkeyKey_9 x24 y322 w120 h21, %ownHotkeyKey_9%
	Gui Hotkeys: Add, Hotkey, v_ownHotkeyKey_10 x24 y354 w120 h21, %ownHotkeyKey_10%
	Gui Hotkeys: Add, Edit, v_ownHotkeyText_2 x160 y98 w304 h21, %ownHotkeyText_2%
	Gui Hotkeys: Add, Edit, v_ownHotkeyText_3 x160 y130 w304 h21, %ownHotkeyText_3%
	Gui Hotkeys: Add, Edit, v_ownHotkeyText_4 x160 y162 w304 h21, %ownHotkeyText_4%
	Gui Hotkeys: Add, Edit, v_ownHotkeyText_5 x160 y194 w304 h21, %ownHotkeyText_5%
	Gui Hotkeys: Add, Edit, v_ownHotkeyText_6 x160 y226 w304 h21, %ownHotkeyText_6%
	Gui Hotkeys: Add, Edit, v_ownHotkeyText_7 x160 y258 w304 h21, %ownHotkeyText_7%
	Gui Hotkeys: Add, Edit, v_ownHotkeyText_8 x160 y290 w304 h21, %ownHotkeyText_8%
	Gui Hotkeys: Add, Edit, v_ownHotkeyText_9 x160 y322 w304 h21, %ownHotkeyText_9%
	Gui Hotkeys: Add, Edit, v_ownHotkeyText_10 x160 y354 w304 h21, %ownHotkeyText_10%
	Gui Hotkeys: Add, Hotkey, v_ownHotkeyKey_11 x520 y67 w120 h21, %ownHotkeyKey_11%
	Gui Hotkeys: Add, Edit, v_ownHotkeyText_11 x656 y67 w304 h21, %ownHotkeyText_11%
	Gui Hotkeys: Add, Edit, v_ownHotkeyText_12 x656 y98 w304 h21, %ownHotkeyText_12%
	Gui Hotkeys: Add, Edit, v_ownHotkeyText_13 x656 y130 w304 h21, %ownHotkeyText_13%
	Gui Hotkeys: Add, Edit, v_ownHotkeyText_14 x656 y162 w304 h21, %ownHotkeyText_14%
	Gui Hotkeys: Add, Edit, v_ownHotkeyText_15 x656 y194 w304 h21, %ownHotkeyText_15%
	Gui Hotkeys: Add, Edit, v_ownHotkeyText_16 x656 y226 w304 h21, %ownHotkeyText_16%
	Gui Hotkeys: Add, Edit, v_ownHotkeyText_17 x656 y258 w304 h21, %ownHotkeyText_17%
	Gui Hotkeys: Add, Edit, v_ownHotkeyText_18 x656 y290 w304 h21, %ownHotkeyText_18%
	Gui Hotkeys: Add, Edit, v_ownHotkeyText_19 x656 y322 w304 h21, %ownHotkeyText_19%
	Gui Hotkeys: Add, Edit, v_ownHotkeyText_20 x656 y354 w304 h21, %ownHotkeyText_20%
	Gui Hotkeys: Add, Hotkey, v_ownHotkeyKey_12 x520 y98 w120 h21, %ownHotkeyKey_12%
	Gui Hotkeys: Add, Hotkey, v_ownHotkeyKey_13 x520 y130 w120 h21, %ownHotkeyKey_13%
	Gui Hotkeys: Add, Hotkey, v_ownHotkeyKey_14 x520 y162 w120 h21, %ownHotkeyKey_14%
	Gui Hotkeys: Add, Hotkey, v_ownHotkeyKey_15 x520 y194 w120 h21, %ownHotkeyKey_15%
	Gui Hotkeys: Add, Hotkey, v_ownHotkeyKey_16 x520 y226 w120 h21, %ownHotkeyKey_16%
	Gui Hotkeys: Add, Hotkey, v_ownHotkeyKey_17 x520 y258 w120 h21, %ownHotkeyKey_17%
	Gui Hotkeys: Add, Hotkey, v_ownHotkeyKey_18 x520 y290 w120 h21, %ownHotkeyKey_18%
	Gui Hotkeys: Add, Hotkey, v_ownHotkeyKey_19 x520 y322 w120 h21, %ownHotkeyKey_19%
	Gui Hotkeys: Add, Hotkey, v_ownHotkeyKey_20 x520 y354 w120 h21, %ownHotkeyKey_20%
	Gui Hotkeys: Show, w986 h400, prawler (SA:MP 0.3.7-R1)
}
return

ShowVariables:
{
	MsgBox, 262144, prawler (SA:MP 0.3.7-R1), Verfügbare Variabeln`n`n[username] [id] [ping] [fps] [zone] [city] [health] [armour] [money] [bankmoney] [fixmoney] [skinid] [weaponid] [weaponname] [freezed] [vhealth] [vspeed] [fishtime] [fraction] [fractionrank] [kills] [job] [crew] [crewrank] [wdealerrank] [fishmoney] [number] [sleep (MS)]
	
}
return

HotkeysGuiClose:
{
	Gui Hotkeys: Submit, NoHide
	Loop, 20
	{
		GuiControlGet, ownHotkeyText_%A_Index%, , _ownHotkeyText_%A_Index%
		GuiControlGet, ownHotkeyKey_%A_Index%, , _ownHotkeyKey_%A_Index%
		WriteHotkey(ownHotkeyText_%A_Index% ,"Hotkey_" A_Index, "Text")
		WriteHotkey(ownHotkeyKey_%A_Index% ,"Hotkey_" A_Index, "Key")
		if(ownHotkeyKey_%A_Index% != "" && ownHotkeyText_%A_Index% != "")
			WriteHotkey("1", "Hotkey_" A_Index, "Active")
		else 
			WriteHotkey("0", "Hotkey_" A_Index, "Active")
		if(ownHotkeyKey_%A_Index% != "" && ownHotkeyKey_%A_Index% != "ERROR"){
			ownHotKey := ownHotkeyKey_%A_Index%
			Hotkey, %ownHotKey%, ownHotkeyLabel_%A_Index%
		}
	}
	Gui Hotkeys: Destroy
}
return

EinstellungenGuiClose:
{
	Gui Einstellungen: Submit, NoHide
	
	GuiControlGet, CB_standort, , CB_standort
	GuiControlGet, CB_fps, , CB_fps
	GuiControlGet, CB_payday, , CB_payday
	GuiControlGet, CB_fisch, , CB_fisch
	GuiControlGet, CB_checkpoint, , CB_checkpoint
	GuiControlGet, CB_digihp, , CB_digihp
	GuiControlGet, CB_schaden, , CB_schaden
	GuiControlGet, CB_onlinezeit, , CB_onlinezeit
	GuiControlGet, CB_drogen, , CB_drogen
	
	GuiControlGet, CB_jobtimer, , CB_jobtimer
	
	GuiControlGet, CB_automfahrzeug, , CB_automfahrzeug
	GuiControlGet, CB_formattedad, , CB_formattedad
	GuiControlGet, CB_freundenachricht, , CB_freundenachricht
	
	WriteSettings(CB_standort, "Textdraws", "Standort")
	WriteSettings(CB_fps, "Textdraws", "FPS")
	WriteSettings(CB_payday, "Textdraws", "PayDay")
	WriteSettings(CB_fisch, "Textdraws", "Fischtimer")
	WriteSettings(CB_checkpoint, "Textdraws", "Checkpoint")
	WriteSettings(CB_digihp, "Textdraws", "DigiHP")
	WriteSettings(CB_schaden, "Textdraws", "Schadensanzeige")
	WriteSettings(CB_onlinezeit, "Textdraws", "Onlinezeit")
	WriteSettings(CB_drogen, "Textdraws", "Drogen")
	
	WriteSettings(CB_jobtimer, "Textlabels", "Jobtimer")
	
	WriteSettings(CB_automfahrzeug, "Weiteres", "AutoMotorLicht")
	WriteSettings(CB_formattedad, "Weiteres", "FormattedAd")
	WriteSettings(CB_freundenachricht, "Weiteres", "FreundeBenachrichtigung")
	
	Gui Einstellungen: Destroy
	
	TrayTip, prawler (SA:MP 0.3.7-R1), Einstellungen wurden übernommen, 2000
	
	restartOverlay()
}
return

showChangelogs:
{
	Gui Changelog: -MinimizeBox -MaximizeBox -SysMenu +AlwaysOnTop -DPIScale
	Gui Changelog: Color, 0xC0C0C0
	Gui Changelog: Add, Picture, x0 y34 w142 h25 gChangelogGuiClose, %A_AppData%\prawler\res\button-back.png
	Gui Changelog: Add, Picture, x0 y0 w542 h33, %A_AppData%\prawler\res\titel-changelog.png
	Gui Changelog: Add, Edit, x5 y64 w532 h136 +ReadOnly, % HTTPData(mainURL . "/changelog.txt")
	Gui Changelog: Show, w542 h205, prawler (SA:MP 0.3.7-R1)
}
return

connectToServer:
{
	RegRead, GTA_SA_EXE, HKEY_CURRENT_USER, Software\SAMP, GTA_SA_EXE
	SplitPath, GTA_SA_EXE,, path
	Run, %path%\samp.exe samp.rpg-city.de:7777
	TrayTip, prawler (SA:MP 0.3.7-R1), Verbindung zum SA:MP Server wird aufgebaut..., 3000, 1
	if(loaded == 1){
		Reload
	}
}
return

connectToTeamspeak:
{
	Run, ts3server://ts.rpg-city.de
}
return

PaydayTimer:
{
	PaydayZeit++
	if(PaydayZeit >= 60 || PaydayZeit < 0 || PayDayZeit is not number){
		PaydayZeit := "n/A"
		SetTimer, PDTimeCheck, 10000
	}
	TD_payday.update("Payday in ~w~" (60-PaydayZeit) " Minuten")
}
return

SaveStats:
{
	if(WinActive("GTA:SA:MP")){
		if(!isDialogOpen() && !isChatOpen())
			savestats()
	}
}
return

PDTimeCheck:
{
	blockDialog()
	Sleep 250
	SendChat("/Stats")
	Sleep 250
	SendInput, {Esc}
	DialogText := getdialogline(6)
	RegExMatch(DialogText, "Payday\: (.*)\/60 Minuten", var_)
	if(var_1 >= 0 or var_1 < 61){
		TD_payday.update("Payday in ~w~" (60-var_1) " Minuten")
		PaydayZeit := var_1
		SetTimer, PDTimeCheck, Off
	}
	if(isDialogOpen())
		SendInput, {Esc}
	unblockDialog()
}
return

FischTimeoutCheck:
{
	SendChat("/Fish")
	Sleep 150
	GetChatLine(0, fishing)
	if (RegExMatch(fishing, "Du kannst erst in ([0-9]+) Minuten wieder angeln\.", fishtime_)) {
		ChatMessage("Fischzeit wurde ausgelesen")
		timeoutsek := fishtime_1*60
		WriteSettings(timeoutsek, "Weiteres", "Fisch Timeout")
		if(!FischTimerStatus){
			SetTimer, FischTimeout, 1000
			FischTimerStatus := true
		}
	}else if (RegExMatch(fishing, "Du kannst erst in ([0-9]+) Sekunden wieder angeln\.", fishtime_)) {
		ChatMessage("Fischzeit wurde ausgelesen")
		timeoutsek := fishtime_1
		WriteSettings(timeoutsek, "Weiteres", "Fisch Timeout")
		if(!FischTimerStatus){
			SetTimer, FischTimeout, 1000
			FischTimerStatus := true
		}
	}else if(RegExMatch(fishing, "Du bist an keinem Angelplatz \(Big Wheel Rods\) oder an einem Fischerboot\!")){
		WriteSettings(0, "Weiteres", "Fisch Timeout")
	}else if(RegExMatch(fishing, "Du kannst nur 5 Fische bei dir tragen\.")){
		ChatMessage("Zu viele Fische dabei! (5)")
		WriteSettings(0, "Weiteres", "Fisch Timeout")
	}
	SetTimer, FischTimeoutCheck, Off
}
return

RobTimer:
{
	showGameText("~r~" robCounter, 1100, 3)
	robCounter--
	if(robCounter == 0 || getInteriorID() == 0){
		SetTimer, RobTimer, Off
		alreadyRobbing := 0
		Sleep 1000
		GetChatLine(0, Chat0)
		GetChatLine(1, Chat1)
		if(RegExMatch(Chat0, "Du hast diesen Store erfolgreich überfallen, die Hälfte der Beute wurde der Crew Kasse gutgeschrieben.")){
			RegExMatch(Chat1, "\*\* (.*) hat ein Store im GK (.*) erfolgreich überfallen\. Beute\: ([0-9]+)\$", rob_)
			ShowGameText("~g~+" FormatNumber(rob_3) "$", 2000, 3)
		}
	}
}
return

autofuncs:
{	
	Killcounter := ReadSettings("Weiteres", "Killcounter")
	Fahrzeuganzeige := ReadSettings("Weiteres", "Fahrzeuganzeige")
	Schadensanzeige := ReadSettings("Textdraws", "Schadensanzeige")
	AutoMotorLicht := ReadSettings("Weiteres", "AutoMotorLicht")
	FormattedAd := ReadSettings("Weiteres", "FormattedAd")
	FreundeBenachrichtigung := ReadSettings("Weiteres", "FreundeBenachrichtigung")
	PrawlerChat := ReadSettings("Weiteres", "PrawlerChat")
	DrogenEnabled := ReadSettings("Textdraws", "Drogen")
	
	GetChatLine(0, Chat0)
	GetChatLine(1, Chat1)
	GetChatLine(2, Chat2)
	GetChatLine(3, Chat3)
	GetChatLine(4, Chat4)
	GetChatLine(5, Chat5)
	GetChatLine(6, Chat6)
	
	adtimeout--
	
	if(GetTargetPed() > 0){
		pedID := GetIdByPed(GetTargetPed())
		pedNAME := getPlayerNameByID(pedID)
		pedSCORE := GetPlayerScoreById(pedID)
		pedPING := GetPlayerPingById(pedID)
	}
	
	if(ReadSettings("Weiteres", "Tacho") && !TachoStatus && isPlayerInAnyVehicle()){
		if(STD_tachotext.ident != -1){
			TachoStatus := 1
			STD_tachobox2.hide()
			STD_tachotext.hide()
			TD_tacho.show()
		}
	}else if(ReadSettings("Weiteres", "Tacho") && TachoStatus && !isPlayerInAnyVehicle()){
		TachoStatus := 0
		TD_tacho.hide()
		STD_tachobox2.show()
	}
	
	if(!ReadSettings("Weiteres", "ServerTextdraws")){
		hideSTD()
	}else if(ReadSettings("Weiteres", "ServerTextdraws")){
		showSTD()
	}
	
	if(PrawlerChat == 0 && connectedToChat == 1){
		connectedToChat := 0
	}else if(PrawlerChat != 0 && connectedToChat == 0){
		connectedToChat := 1
	}
	
	if(CheckpointTDEnabled == 0 && isCheckpointSet()){
		TD_checkpoint.show()
		CheckpointTDEnabled := 1
	} else if(CheckpointTDEnabled == 1 && !isCheckpointSet()){
		CheckpointTDEnabled := 0
		TD_checkpoint.hide()
	}
	
	if(RegExMatch(Chat0, "Dein Marihuana benötigt noch ([0-9]+) Minuten\.", plant_) && DrugsPlanted == 0){
		DrugsSec := plant_1*60
		DrugsPlanted := 1
		if(DrogenEnabled != 0){
			TD_drugs.show()
		}
		ShowGameText("~g~Drogenpflanze angebaut", 2500, 3)
	}else if(RegExMatch(Chat0, "Inklusive Zeitbonus in Höhe von ([0-9]+)g hast du insgesamt ([0-9]+)g Marihuana aus deinen ([0-9]+) Samen geerntet\.", ernte_) && DrugsPlanted == 1){
		DrugsPlanted := 0
		DrugsSec := 0
		TD_drugs.hide()
	}else if(RegExMatch(Chat1, "Du hast ([0-9]+) Samen gepflanzt\. Mit \'\/seed harvest\' kannst du den aktuellen Stand sowie die Position einsehen\.", drug_) && DrugsPlanted == 0){
		RegExMatch(Chat0, "Der Mindestertrag an Drogen ist abhängig von der Zeit\, mindestens jedoch werden ([0-9]+) Minuten benötigt\.", drugs2_)
		if(drugs2_1 > 0){
			DrugsSec := drugs2_1*60
			DrugsPlanted := 1
			if(DrogenEnabled){
				TD_drugs.show()
			}
			ShowGameText("~g~Drogenpflanze angebaut", 2500, 3)
		}
	}
	
	if(RegExMatch(Chat0, "\[Waffendealer\]\: (.*) hat dein Angebot angenommen\. Der Checkpoint deines Partners wird bei \/materials get automatisch angepasst\.", wdpartner_) && WDPartner == "none"){
		WDPartner := wdpartner_1
		ShowGameText("~y~WD Partner~n~~p~" WDPartner, 2000, 3)
	}else if(RegExMatch(Chat0, "\[Waffendealer\]\: (.*) und du können nun gemeinsam farmen\. Der Checkpoint deines Partners wird bei \/materials get automatisch angepasst\.", wdpartner_) && WDPartner == "none"){
		WDPartner := wdpartner_1
		ShowGameText("~y~WD Partner~n~~p~" WDPartner, 2000, 3)
	}else if(RegExMatch(Chat0, "\[Waffendealer\]\: Du farmst nun nicht mehr mit (.*)\.")){
		WDPartner := "none"
		ShowGameText("~y~Kein WD Partner mehr", 2000, 3)
	}
	
	if(RegExMatch(Chat0, "Du raubst nun diesen Store aus, beim verlassen des Stores bricht der Raubzug ab.")){
		robCounter := 88
		SetTimer, RobTimer, Off
		SetTimer, RobTimer, 1000
		alreadyRobbing := 1
		ChatMessage("Storerob Countdown gestartet! Zeit: 90 Sekunden")
	}else if(RegExMatch(Chat0, "Du hast diesen Store erfolgreich überfallen, die Hälfte der Beute wurde der Crew Kasse gutgeschrieben.")){
		robCounter := 1
	}
	
	if(SpendenaufrufActive == 1 && RegExMatch(Chat1, "Du hast (.*)\$ von (.*)\(([0-9]+)\) erhalten\.", spende_)){
		if(spende_2 != old_spender){
			collectedMoney := collectedMoney + spende_1
			showGameText("~y~Spendengeld~n~~g~" FormatNumber(collectedMoney), 1000, 3)
		}
		old_spender := spende_2
	}
	
	if(RegExMatch(Chat0, "\* (.*) hat den Channel (.*)\.", var_) && connectedToChat == 1){
		SetChatLine(0, prefix "[Chat] " var_1 " hat den Chat " var_2)
	}

	if(connectedToChat == 1){
		if(RegExMatch(Chat0, "\*\* IRC (.*)\: (.*) \*\*", chat_)){
			if(InStr(chat_2, "*^*")){
				StringReplace, chat_2, chat_2, *^*,
				SetChatLine(0, prefix . "[Chat] {FFBF00}" chat_1 "{FFFFFF}: " chat_2)
			}else{
				SetChatLine(0, prefix . "[Chat] " chat_1 ": " chat_2)
			}
		}else if(RegExMatch(Chat0, "\.\.\.(.*) \*\*", chat_0_)){
			if(RegExMatch(Chat1, "\*\* IRC (.*)\: (.*)\.\.\.", chat_1_)){
				if(InStr(chat_1_2, "*^*")){
					StringReplace, chat_1_2, chat_1_2, *^*,
					SetChatLine(1, prefix . "[Chat] {FFBF00}" chat_1_1 "{FFFFFF}: " chat_1_2 "...")
				}else{
					SetChatLine(1, prefix . "[Chat] " chat_1_1 "{FFFFFF}: " chat_1_2 "...")
				}
				SetChatLine(0, prefix . "..." chat_0_1)
			}
		}
	}
	
	if(RegExMatch(Chat0, "\* Busfahrer (.*)\: hat Linie (.*) für (.*)\$ und (.*) EXP beendet in (.*) Minuten\, over \*", var_)){
		SetChatLine(0, "[Busfahrer] " var_1 " hat Linie " var_2 " für " var_3 "$ & " var_4 " EXP beendet. Zeit: " var_5 " Minuten")
	}else if(RegExMatch(Chat1, "\* Busfahrer (.*)\: hat Linie (.*) für (.*)\$ und (.*) EXP beendet in (.*) Minuten\, over \*", var_)){
		SetChatLine(1, "[Busfahrer] " var_1 " hat Linie " var_2 " für " var_3 "$ & " var_4 " EXP beendet. Zeit: " var_5 " Minuten")
	}
	
	if(RegExMatch(Chat0, "Du bist an keinem Angelplatz \(Big Wheel Rods\) oder an einem Fischerboot\!") || RegExMatch(Chat0, "\*\* Du kanst nun wieder am Angelsteg angeln\.")){
		if(afishactive == 0){
			SetTimer, FischTimeout, Off
			FischTimerStatus := false
			ChatMessage("Du kannst nun wieder Fischen gehen!")
			WriteSettings(0, "Weiteres", "Fisch Timeout")
			TD_fisch.update("Du kannst Fischen!")
		}
	}

	if (RegExMatch(Chat0, "Du kannst erst in ([0-9]+) Minuten wieder angeln\.", fishtime_)) {
		if(fishtime_1 >= 0 && afishactive == 0){
			ChatMessage("Fischzeit ausgelesen!")
			timeoutsek := fishtime_1*60
			WriteSettings(timeoutsek, "Weiteres", "Fisch Timeout")
			if(!FischTimerStatus){
				SetTimer, FischTimeout, 1000
				FischTimerStatus := true
			}
		}
	}
	
	if(AutoMotorLicht != 0)
	{
		if(inVehicle == 1 && !IsPlayerInAnyVehicle()){
			inVehicle := 0
			Lockcarlock := 0
		}else if(inVehicle == 0 && IsPlayerInAnyVehicle() && IsPlayerDriver()){
			sleep, 100
			carlock := getPlayerVehicleLockState()
			if(!carlock && !Lockcarlock)
			{
				mID := getPlayerVehicleModelID()
				if(mID != 431 && mID != 437)
				{
					SendChat("/Lock")
					Sleep 150
					if(!carlock)
						Lockcarlock := 1
				}
			}
			engine := GetVehicleEngineState(getVehicleID())
			if(!engine){
				SendChat("/motor")
				if(!GetVehicleLightState(getVehicleID()))
					SetTimer, lights, 100
			}
			inVehicle := 1
		}
	}
	
	if(FreundeBenachrichtigung != 0)
	{
		if(StrLen(printFreunde()) > 10)
		{
			AddChatMessage(printFreunde())
		}
	}
	
	if(Fahrzeuganzeige != 0)
	{
		if(CarShowName == 0)
		{
			If(IsPlayerInAnyVehicle())
			{
				ShowGameText("~n~~n~~n~~n~~n~~n~~n~~n~~g~~h~~h~" . GetVehicleModelName(getPlayerVehicleModelID()), 3000, 3)
				CarShowName := 1
			}
		}
		else if(CarShowName == 1)
			if(!IsPlayerInAnyVehicle())
				CarShowName := 0
	}

	if(RegExMatch(Chat0, "WARNUNG\: Hör auf zu Spamen\, sonst wirst du gekickt\!"))
		SetChatLine(0, prefix "Spamwarunung")
	else if(RegExMatch(Chat1, "WARNUNG\: Hör auf zu Spamen\, sonst wirst du gekickt\!"))
		SetChatLine(1, prefix "Spamwarunung")

	if(FormattedAd != 0 && adtimeout <= 0)
	{
		if(RegExMatch(Chat0, "\[Werbung\] (.*)\, (.*) \((.*)\)", werbung_)){
			if(InStr(werbung_1, "..."))
				if(RegExMatch(Chat1, "\[Werbung\] (.*)\.\.\.", werbung2_))
					SetChatLine(1, MainColor "[Werbung] {FFFFFF}" werbung2_1 MainColor "...")
			playerid := getPlayerID(werbung_2, 1)
			if(playerid >= 0 && playerid < 500)
				SetChatLine(0, MainColor "[Werbung] {FFFFFF}" werbung_1 MainColor " • {FFFFFF}" werbung_2 MainColor " (ID: {FFFFFF}" playerid MainColor ") (Tel.:{FFFFFF} " werbung_3 MainColor ")")
			else
				SetChatLine(0, MainColor "[Werbung] {FFFFFF}" werbung_1 MainColor " • {FFFFFF}" werbung_2 MainColor " (Tel.:{FFFFFF} " werbung_3 MainColor ")")
			adtimeout := 100
		}
	}
	
	if(Schadensanzeige != 0)
	{
		NewHP := GetPlayerHealth()
		if(NewHP < OldHP)
		{
			healthlost := OldHP-NewHP
			TD_schaden.show()
			TD_schaden.update("~r~-" healthlost)
			SetTimer, schadenTDdel, 1500
		}
		else if(OldHP < NewHP)
		{
			healthlost := NewHP-OldHP
			TD_schaden.show()
			TD_schaden.update("~g~+" healthlost)
			SetTimer, schadenTDdel, 1500
		}
		OldHP := NewHP
	}

	if(Killcounter != 0)
	{
		if(!isDead){
			data := getKills()
			if (data && isConnected()) {
				For index, object in data
				{
					Kills := ReadStats("Kills")
					Tode := ReadStats("Tode")
					if (object.victim.local) {
						Sleep, 100
						chat0 := readChatLine(0)
						chat1 := readChatLine(1)
						chat2 := readChatLine(2)
						if (RegExMatch(chat0 . chat1 . chat2, "Paintball: (\S+) wurde von (\S+) getötet\.")) {
						}else{
							attackerID := getAttacker(true)
							attackerName := getPlayerNameById(attackerID)
							Fraktion := ReadStats("Fraktion")
							if(Fraktion != "Zivilist"){
								if(attackerID >= 0 && attackerID < 376){
									if(ReadSettings("Weiteres", "DeathspruchInCrew"))
										SendChat("/crew Ich bin in " getPlayerZone() " - " getPlayerCity() " gestorben!")
									if(ReadSettings("Weiteres", "DeathspruchInFraktion"))
										SendChat("/f Ich bin in " getPlayerZone() " - " getPlayerCity() " gestorben!")
								}else{
									if(ReadSettings("Weiteres", "DeathspruchInCrew"))
										SendChat("/crew Ich bin in " getPlayerZone() " - " getPlayerCity() " gestorben!")
									if(ReadSettings("Weiteres", "DeathspruchInFraktion"))
										SendChat("/f Ich bin in " getPlayerZone() " - " getPlayerCity() " gestorben!")
								}
							}else{
								if(attackerID >= 0 && attackerID < 376){
									if(ReadSettings("Weiteres", "DeathspruchInCrew"))
										SendChat("/Crew +1 Tot in " getPlayerZone() " - " getPlayerCity())
									else
										ChatMessage("+1 Tot in " getPlayerZone() " - " getPlayerCity())
								}else{
									if(ReadSettings("Weiteres", "DeathspruchInCrew"))
										SendChat("/Crew +1 Tot in " getPlayerZone() " - " getPlayerCity())
									else
										ChatMessage("+1 Tot in " getPlayerZone() " - " getPlayerCity())
								}
							}
							isDead := true
							SetTimer, DeadCooldown, 5000
						}
					}
				}
			}
		}
		chat := readChatLine(0) . readChatLine(1) . readChatLine(2)
		gameText := getGameText(3, 28)
		if (InStr(chat, "( Mord ). Zeuge: ") || InStr(gameText, "~g~Gang") || InStr(gameText, "~g~Team")) {
			if (InStr(chat, "Kills: ")) {
			}else{
				Kills++
				Fraktion := ReadStats("Fraktion")
				if(Fraktion != "Zivilist"){
					if(ReadSettings("Weiteres", "KillspruchInFraktion"))
						SendChat("/f +1 Kill in " getPlayerZone() " - " getPlayerCity() " - Kills: " Kills)
					
					if(ReadSettings("Weiteres", "KillspruchInCrew"))
						SendChat("/crew +1 Kill in " getPlayerZone() " - " getPlayerCity() " - Kills: " Kills)
				}else{
					if(ReadSettings("Weiteres", "KillspruchInCrew"))
						SendChat("/crew +1 Kill in " getPlayerZone() " - " getPlayerCity() " - Kills: " Kills)
					else
						ChatMessage("+1 Kill in " getPlayerZone() " - " getPlayerCity() " - Kills: " Kills)
				}
			}
		}
	}
	
	if(isPlayerInAnyVehicle() && STD_tachobox1.ident == -1){
		if (updateTextDraws()){
			for i, o in oTextDraws
			{
				if(o.TEXT == "~n~~n~~n~~n~~n~~n~~n~"){
					STD_tachobox1.ident := o.ID
					STD_tachobox2.ident := o.ID + 1
					STD_tachotext.ident := o.ID + 2
					break
				}
			}
		}
	}
	
	if(timeout)
	{
		if(IsPlayerInRangeOfPoint(362.0880,173.5538,1008.3828,4)) ;Stadthalle
		{
			ChatMessage("Möchtest du das Stadthallen Menü öffnen? [X-Taste zum Bestätigen]")
			KeyWait, X, D, T10
			if (!ErrorLevel) {
				timeout := false
				SendChat("/Job")
				SetTimer, CustomTimeout, 5000
			}else
				timeout := true
		}else if (isPlayerInRangeOfPoint(1733.47, 546.37, 26, 10) ;Zoll
			|| isPlayerInRangeOfPoint(1741.11, 543.47, 26, 10)
			|| isPlayerInRangeOfPoint(1744.03, 523.63, 27, 10)
			|| isPlayerInRangeOfPoint(1752.71, 521.69, 27, 10)
			|| isPlayerInRangeOfPoint(512.54, 476.62, 18, 10)
			|| isPlayerInRangeOfPoint(529.22, 467.21, 18, 10)
			|| isPlayerInRangeOfPoint(-159.79, 414.18, 11, 10)
			|| isPlayerInRangeOfPoint(-157.44, 392.24, 11, 10)
			|| isPlayerInRangeOfPoint(-1408.23, 824.19, 47, 10)
			|| isPlayerInRangeOfPoint(-1414.77, 803.59, 47, 10)
			|| isPlayerInRangeOfPoint(-2695.05, 1284.63, 55, 10)
			|| isPlayerInRangeOfPoint(-2686.34, 1284.24, 55, 10)
			|| isPlayerInRangeOfPoint(-2676.62, 1265.37, 55, 10)
			|| isPlayerInRangeOfPoint(-2668.18, 1264.91, 55, 10)
			|| isPlayerInRangeOfPoint(-963.08, -343.05, 36, 10)
			|| isPlayerInRangeOfPoint(-968.00, -322.33, 36, 10)
			|| isPlayerInRangeOfPoint(-71.76, -892.47, 15, 10)
			|| isPlayerInRangeOfPoint(-68.74, -867.96, 15, 10)
			|| isPlayerInRangeOfPoint(100.20, -1284.37, 14, 10)
			|| isPlayerInRangeOfPoint(94.40, -1277.82, 14, 10)
			|| isPlayerInRangeOfPoint(97.19, -1254.11, 14, 10)
			|| isPlayerInRangeOfPoint(94.69, -1245.59, 14, 10)
			|| isPlayerInRangeOfPoint(42.71, -1537.98, 5, 10)
			|| isPlayerInRangeOfPoint(58.02, -1524.93, 5, 10)) {
				ChatMessage("Möchtest du den Zoll öffnen? [X-Taste zum Bestätigen]")
				KeyWait, X, D, T10
				if (!ErrorLevel) {
					timeout := false
					SendChat("/zoll")
					Sleep 150
					GetChatLine(0, chat)
					if (InStr(chat, "Es ist keine Zollstation in deiner Nähe.")) {
						Sleep, 800
						SendChat("/zoll")
					}
					SetTimer, CustomTimeout, 5000
				}else
					timeout := true
		}else if(isPlayerInRangeOfPoint(330.7327,-40.1807,2.2255, 3) && DrugsPlanted == 0){ ;Drogen
			ChatMessage("Möchtest du Drogensamen kaufen? [X-Taste zum Bestätigen]")
			KeyWait, X, D, T10
			if (!ErrorLevel) {
				timeout := false
				SendChat("/seed buy")
				Sleep, 150
				GetChatLine(0, Chat0)
				if(!RegExMatch(Chat0, "in der Luft, auf Objekte/Bäume/Häuser, auf einer unrealistischen Stelle (keine Grünfläche).")){
					Sleep 800
					SendChat("/seed buy")
				}
				SetTimer, CustomTimeout, 5000
			}else
				timeout := true
		}else if(InStr(Chat0, "Sichere jetzt dein Lotto Ticket mit /lotto für nur $2000!")) ;Lotto
		{
			ChatMessage("Möchtest du ein Lotto Ticket kaufen? [X-Taste zum Bestätigen]")
			KeyWait, X, D, T10
			if (!ErrorLevel) {
				timeout := false
				Random, LottoNummer, 1, 100
				SendChat("/lotto " . LottoNummer)
				SetTimer, CustomTimeout, 5000
			}else
				timeout := true
		}else if (isPlayerInAnyVehicle() && isPlayerDriver()) { ;Tanken
			if (isPlayerInRangeOfPoint(700, -1930, 0, 10)
			|| isPlayerInRangeOfPoint(1833, -2431, 14, 10)
			|| isPlayerInRangeOfPoint(615, 1689, 7, 10)
			|| isPlayerInRangeOfPoint(-1328, 2677, 40, 10)
			|| isPlayerInRangeOfPoint(1596, 2199, 11, 10)
			|| isPlayerInRangeOfPoint(2202, 2474, 11, 10)
			|| isPlayerInRangeOfPoint(2114, 920, 11, 10)
			|| isPlayerInRangeOfPoint(-2408, 976, 45, 10)
			|| isPlayerInRangeOfPoint(-2029, 156, 29, 10)
			|| isPlayerInRangeOfPoint(-1676, 414, 7, 10)
			|| isPlayerInRangeOfPoint(1004, -939, 43, 10)
			|| isPlayerInRangeOfPoint(1944, -1773, 14, 10)
			|| isPlayerInRangeOfPoint(-90, -1169, 3, 10)
			|| isPlayerInRangeOfPoint(-1605, -2714, 49, 10)
			|| isPlayerInRangeOfPoint(-2243, -2560, 32, 10)
			|| isPlayerInRangeOfPoint(1381, 457, 20, 10)
			|| isPlayerInRangeOfPoint(70, 1218, 19, 10)) {
				ChatMessage("Möchtest du dein Fahrzeug betanken? [X-Taste zum bestätigen]")
				KeyWait, X, D, T10
				if (!ErrorLevel) {
					timeout := false
					if (GetVehicleEngineState(getVehicleID())) {
						SendChat("/motor")
					}
					SendChat("/fill")
					Sleep, 10000
					SendChat("/motor")
					SetTimer, CustomTimeout, 5000
				}else
					timeout := true
			}
		}
	}
}
return

CustomTimeout:
{
	CustomTimeout++
	if(CustomTimeout >= 4)
	{
		SetTimer, CustomTimeout, Off
		timeout := true
		CustomTimeout := 0
	}
}
return

JobTimer:
{
	JobSeconds++
	inVehicle := isPlayerInAnyVehicle()
	if(inVehicle && TL_jobtime.ident == -1){
		JobtimerEnabled := ReadSettings("Textlabels", "Jobtimer")
		TL_jobtime.vehicleID := getVehicleID()
		if(JobtimerEnabled != 0)
			TL_jobtime.create()
	}
	if (inVehicle && TL_jobtime.ident != -1)
		TL_jobtime.update("- {00CED1}Jobzeit: {FFFFFF}" FormatTime(JobSeconds) "{FFFFFF} -")
	else
		TL_jobtime.delete()
}
return

schadenTDdel:
{
	TD_schaden.update("")
	TD_schaden.hide()
}
return

lights:
if(IsPlayerInAnyVehicle() && IsPlayerDriver()){
	if(GetVehicleEngineState(getVehicleID()) && !GetVehicleLightState(getVehicleID())){
		if(A_Hour > 19 || A_Hour < 7)
		{
			SendChat("/licht")
			SetTimer, lights, Off
		}
	}
}else
	SetTimer, lights, Off
return

GuiClose:
{
	unpatchSendCMD()
	deleteTextdraws()
	if(ReadSettings("Weiteres", "PrawlerChat") == 1)
		leaveIRC()
    ExitApp
}
return

InformationenGuiClose:
{
	Gui Informationen: Destroy
}
return
	
ChangelogGuiClose:
{
	Gui Changelog: Destroy
}
return

checkGTA:
{
	if(WinActive("GTA:SA:MP") && isPlayerSpawned()){
		if(!checkSAMPCompatibility()){
			MsgBox, 262160, prawler (SA:MP 0.3.7-R1), Deine SA:MP Version ist nicht mit prawler kompatibel! Bitte benutze die SA:MP Version 0.3.7 bzw. 0.3.7-R1, 6
		}
		if(!isDialogOpen()){
			AntiCrash()
			SetTimer, checkGTA, Off
			createTextdraws()
			SetTimer, autofuncs, 250
			SetTimer, initAllTextdraws, 500
			SetTimer, BerufTimer, 250
			SetTimer, PaydayTimer, 60000
			SetTimer, updatePlayerStatus, 30000
			SetTimer, SaveStats, 300000
			oldPlayerStatus := DB_GetStatus()
			loaded := 1
			if(ReadSettings("Weiteres", "PrawlerChat") == 1)
				connectIRC()
			saveStats()
			CreateObject(19168, 2320.43726, -125.31603, 28.37990,   90.00000, 90.00000, 90.06001)
			CreateObject(1594, 2317.26587, -123.84621, 27.62029,   0.00000, 0.00000, 0.00000)
			CreateObject(2921, 2321.28564, -125.38143, 29.10367,   0.00000, 0.00000, -92.94006)
			CreateObject(2924, 2323.02661, -125.36324, 28.33208,   0.00000, 0.00000, 0.00000)
			CreateObject(371, 2317.29175, -123.78420, 28.06090,   -90.00000, 0.00000, 90.00000)
			CreateObject(3287, 2336.31055, -131.08531, 30.16654,   0.00000, 0.00000, 0.00000)
			CreateObject(18726, 2317.40259, -128.79932, 32.16161,   0.00000, 0.00000, 0.00000)
			CreateObject(1577, 2318.62915, -125.15678, 27.15300,   0.00000, 0.00000, 0.00000)
			CreateObject(1577, 2318.08838, -125.16422, 27.15300,   0.00000, 0.00000, 0.00000)
			CreateObject(1577, 2318.36865, -125.14037, 27.31839,   0.00000, 0.00000, 0.00000)
			CreateObject(7073, 2323.68994, -128.47340, 49.29515,   0.00000, 0.00000, 90.00003)
			CreateObject(3092, 2323.44849, -122.38039, 28.34191,   0.00000, 0.00000, 0.00000)
			CreateObject(919, 2332.09570, -126.10917, 29.29827,   0.00000, 90.00000, 0.00000)
			CreateObject(19122, 2323.73096, -108.51581, 26.03473,   0.00000, 0.00000, 0.00000)
			CreateObject(11700, 2323.54395, -108.49770, 25.42852,   0.00000, 0.00000, 180.00000)
			CreateObject(19123, 2319.05884, -108.46281, 26.01166,   0.00000, 0.00000, 0.00000)
			CreateObject(19124, 2332.26147, -108.51142, 26.00782,   0.00000, 0.00000, 0.00000)
		}
	}
}
return

updatePlayerStatus:
{
	newStatus := DB_GetStatus()
	if(oldPlayerStatus != newStatus && (newStatus == "Normal" || newStatus == "Premium")){
		ChatMessage("Dein Benutzerstatus hat sich geändert! Dein neuer Status: " newStatus)
	}
	oldPlayerStatus := newStatus
}
return

FischTimeout:
{
	FischTimeoutSek := ReadSettings("Weiteres", "Fisch Timeout")
	FischTimeoutSek--
	WriteSettings(FischTimeoutSek, "Weiteres", "Fisch Timeout")
	if(FischTimeoutSek <= 0)
	{
		SetTimer, FischTimeout, Off
		FischTimerStatus := false
		GetChatLine(0, Chat0)
		if(RegExMatch(Chat0, "\*\* Du kannst nun wieder am Angelsteg angeln\.")){
			SetChatLine(0, prefix "Du kannst nun wieder Fischen gehen!")
		}else{
			if(!InStr(Chat0, "Du kannst nun wieder Fischen gehen!"))
				ChatMessage("Du kannst nun wieder Fischen gehen!")
		}
		WriteSettings(0, "Weiteres", "Fisch Timeout")
		TD_fisch.update("Du kannst Fischen!")
	}
	else
	{
		TD_fisch.update("Fischen in: ~w~" FormatTime(FischTimeoutSek))
	}
}
return

changeIRCNotification:
{
	GetChatLine(0, Chat0)
	GetChatLine(1, Chat1)
	if(RegExMatch(Chat0, "\* " getUsername() " hat den Channel betreten\.")){
		SetChatLine(0, prefix . "Benutze /Pc [Nachricht] um zu chatten")
		SetChatLine(1, prefix . Chat1)
		SetChatLine(2, prefix . "Du hast den Chat von prawler betreten")
		SetTimer, changeIRCNotification, Off
	}
}
return

initAllTextdraws:
{
	initTextdraws()
}
return

DeadCooldown:
{
	isDead := false
}
return

BerufTimer:
{
	GetChatLine(0, Chat0)
	GetChatLine(1, Chat1)
	GetChatLine(2, Chat2)
	GetChatLine(3, Chat3)
	GetChatLine(4, Chat4)
	GetChatLine(5, Chat5)
	GetChatLine(6, Chat6)
	
	;Businfos
	activLinie := GetBusLinie()
	mID := getPlayerVehicleModelID()
	
	;Trucker
	if(RegExMatch(Chat1, "Du hast den Auftrag ([0-9]+) \((.*)\) abgeschlossen und erhälst am nächsten Payday ([0-9]+)\$\.", trucker_)){
		SendChat("/j hat den Auftrag " trucker_1 " für " FormatNumber(trucker_3) "$ beendet. Zeit: " FormatTime(JobSeconds))
		JobSeconds := 0
		SetTimer, JobTimer, Off
		TL_jobtime.delete()
	}
	
	;Pilot
	if(RegExMatch(Chat0, "Das Flugzeug hat die Startfreigabe erhalten.") && PilotAktiv == 0){
		PilotAktiv := 1
		ChatMessage("Fluglinie wurde erkannt")
		JobtimerEnabled := ReadSettings("Textlabels", "Jobtimer")
		JobSeconds := 0
		if(TL_jobtime.ident == -1 && isPlayerInAnyVehicle() && JobtimerEnabled != 0){
			TL_jobtime.vehicleID := getVehicleID()
			TL_jobtime.create()
		}
		SetTimer, JobTimer, 1000
	}else if(RegExMatch(Chat3, "\* (.*)\$ werden am nächsten Payday Gutgeschrieben\.", pilot_) && PilotAktiv == 1){
		PilotAktiv := 0
		SetTimer, JobTimer, Off
		TL_jobtime.delete()
		SendChat("/j hat seine Fluglinie für " pilot_1 "$ beendet. Zeit: " FormatTime(JobSeconds))
	}else if(RegExMatch(Chat0, "Du bist nicht im Flugzeug\, mit dem du den Dienst begonnen hast\. Dienst Beendet\!") && PilotAktiv == 1){
		PilotAktiv := 0
		SetTimer, JobTimer, Off
		TL_jobtime.delete()
		ChatMessage("Deine Fluglinie wurde beendet!")
	}
	
	;Waffendealer
	secLeft := getConnectionTicks() / 1000
	if (secLeft < 0)
		secLeft := getRunningTime()
	min := Floor(secLeft / 60)
	if(isPlayerInRangeOfPoint(597.0938,-1248.5940,18.2710,3) && !isPlayerInAnyVehicle() && min >= 6) {
		WaffendealerRang := ReadStats("WaffendealerRang")
		MaxPakets := WaffendealerRang * 5
		if(WDPartner != "none"){
			WDPartnerID := getPlayerIdByName(WDPartner)
			WDPartnerPos := GetTargetPosById(WDPartnerID)
			DistanzZuWDPartner := getDistance(getCoordinates(), WDPartnerPos)
			if(DistanzZuWDPartner > 5){
				ShowGameText("Warte auf Partner", 2000, 3)
			}else{
				if(attemp == 3){
					Sleep 2000
					attemp := 0
				}
				if(!RouteAktiv && MaxPakets >= 5) {
					SendChat("/Materials Get " MaxPakets)
					Sleep 150
					GetChatLine(0, Chat0)
					if(InStr(Chat0, "Gebe /materials deliver ein, sobald du dein Ziel erreicht hast.")) {
						RouteAktiv := 1
						JobSeconds := 0
						VorMats := MaxPakets*80
						SetTimer, JobTimer, 1000
						inVehicle := isPlayerInAnyVehicle()
						JobtimerEnabled := ReadSettings("Textlabels", "Jobtimer")
						if(TL_jobtime.ident == -1 && inVehicle && JobtimerEnabled != 0){
							TL_jobtime.vehicleID := getVehicleID()
							TL_jobtime.create()
						}
						SetChatLine(2, prefix "Du hast " MaxPakets " Pakete für " FormatNumber(MaxPakets*200) "$ gekauft! Voraussichtliche Materialien: " VorMats)
						ChatMessage("Route wurde gestartet!")
					}
					attemp++
				}
			}
		}else{
			if(!RouteAktiv && MaxPakets >= 5) {
				SendChat("/Materials Get " MaxPakets)
				Sleep 150
				GetChatLine(0, Chat0)
				if(InStr(Chat0, "Gebe /materials deliver ein, sobald du dein Ziel erreicht hast.")) {
					RouteAktiv := 1
					JobSeconds := 0
					VorMats := MaxPakets*80
					SetTimer, JobTimer, 1000
					inVehicle := isPlayerInAnyVehicle()
					JobtimerEnabled := ReadSettings("Textlabels", "Jobtimer")
					if(TL_jobtime.ident == -1 && inVehicle && JobtimerEnabled != 0){
						TL_jobtime.vehicleID := getVehicleID()
						TL_jobtime.create()
					}
					SetChatLine(2, prefix "Du hast " MaxPakets " Pakete für " FormatNumber(MaxPakets*200) "$ gekauft! Voraussichtliche Materialien: " VorMats)
					ChatMessage("Route wurde gestartet!")
				}
			}
		}
	}
	else if(isPlayerInRangeOfPoint(597.0938,-1248.5940,18.2710,3) && min < 6 && RouteAktiv == 0)
	{
		ShowGameText("~r~bitte warten", 1000, 3)
	}
	else if(isPlayerInRangeOfPoint(597.0938,-1248.5940,18.2710,3) && min > 6 && isPlayerInAnyVehicle() && RouteAktiv == 0)
	{
		ShowGameText("~r~Aussteigen", 1000, 3)
	}
	DistToCP := getDistance(getCoordinates(), getCheckpointPos())
	if(DistToCP < 2 || checkpointEntered == 1) {
		if((RouteAktiv && !isPlayerInAnyVehicle())) {
			SendChat("/Materials Deliver")
			Sleep 100
			GetChatLine(0, Chat0)
			if(RegExMatch(Chat0, "Du hast ([0-9]+) Materialien für deine ([0-9]+) Pakete erhalten \(\+([0-9]+) XP\)\.", var_)) {
				SetTimer, JobTimer, Off
				SetChatLine(0, "Du hast deine Route in " FormatTime(JobSeconds) " Min beendet und " var_1 " Materialien (+" var_3 " XP) erhalten")
				ChatMessage("Route wurde erfolgreich beendet! Vergiss nicht deine Materialien zu sichern! (Safebox)")
				if(ReadStats("Crew") != "Keine"){
					SendChat("/Crew hat seine Tour beendet und " var_1 " Mats (+" var_3 " XP) erhalten. Zeit: " FormatTime(JobSeconds) " Min")
				}
				MaterialsDelivered := 0
				Materials += var_1
				checkpointEntered := 0
				TL_jobtime.delete()
			}
		}else if(RouteAktiv && isPlayerInAnyVehicle()){
			ShowGameText("~r~Aussteigen zum abgeben", 1000, 3)
			checkpointEntered := 1
		}
	}
	if(IsPlayerInRangeOfPoint(2737.1714,-2465.6287,13.6484, 3) && RouteAktiv == 1){
		RouteAktiv := 0
		SendChat("/materials warehouse")
	}
	if(isPlayerInRangeOfPoint(834.9356,-1853.6016,8.3939,2) or isPlayerInRangeOfPoint(1297.3384,-984.3235,32.6953,2) or isPlayerInRangeOfPoint(-1480.0327,324.1333,7.1875,2)) {
		if(!MaterialsDelivered) {
			if(Materials != 0)
			{
				SendChat("/Put Mats " Materials)
				Sleep 150
				GetChatLine(0, Chat0)
				if(RegExMatch(Chat0, "Du hast (.*) Material in die Safebox gelegt\.", var_)) {
					SetChatLine(0, prefix "Es wurden " FormatNumber(var_1) " Materialien gesichert!")
					MaterialsDelivered := 1
					Materials := 0
				}
			}
		}
	}
	
	;Busfahrer
	if(mID == 431 || mID == 437){	
		if(InStr(Chat0, "Nächste Haltestelle:")) {
			if(!LinieAktiv) {
				LinieAktiv := 1
				JobSeconds := 0
				SetTimer, JobTimer, 1000
				SetChatLine(0, prefix "Du hast Linie " activLinie " gestartet!")
			}
		} else if(InStr(Chat0, "Leerfahrt")) {
			if(LinieAktiv) {
				SetTimer, JobTimer, Off
				JobSeconds := 0
				LinieAktiv := 0
				TL_jobtime.delete()
				SetChatLine(0, prefix "Du hast deine Linie abgebrochen!")
			}
		} else if(InStr(Chat0, "Du erhältst auf deine nächste Tour innerhalb")) {
			RegExMatch(Chat1, "\* Du erhälst am nächsten Payday (.*)\$ gutgeschrieben\. Erhaltene Exp\: ([0-9]+)", bus_)
			if(LinieAktiv) {
				SetTimer, JobTimer, Off
				SendChat("/j hat Linie " activLinie " für " FormatNumber(bus_1) "$ und " bus_2 " EXP beendet in " FormatTime(JobSeconds) " Minuten")
				JobSeconds := 0
				LinieAktiv := 0
				TL_jobtime.delete()
				if(activLinie != -1){
					startLinie(activLinie)
				}
			} else {
				SendChat("/j hat Linie " activLinie " für " FormatNumber(bus_1) "$ und " bus_2 "EXP beendet")
			}
		} else if(InStr(Chat0, "Du erhältst auf deine nächste Tour innerhalb")) {
			GetChatLine(1, Chat0)
			RegExMatch(Chat0, "\* Du erhälst am nächsten Payday (.*)\$ gutgeschrieben\. Erhaltene Exp\: ([0-9]+)", bus_)
			if(LinieAktiv) {
				SetTimer, JobTimer, Off
				SendChat("/j hat Linie " activLinie " für " FormatNumber(bus_1) "$ und " bus_2 " EXP beendet in " FormatTime(JobSeconds) " Minuten")
				JobSeconds := 0
				LinieAktiv := 0
				TL_jobtime.delete()
				if(activLinie != -1){
					startLinie(activLinie)
				}
			} else {
				SendChat("/j hat Linie " activLinie " für " FormatNumber(bus_1) "$ und " bus_2 " EXP beendet")
			}
		}
	}
	if(LinieAktiv && TL_jobtime.ident == -1 && mID != 431 && mID != 437){
		TL_jobtime.delete()
	}
}
return

Rainbow:
{
	if(hudred > 0 && hudblue == 0) {
		hudred--
		hudgreen++
	}
	if(hudgreen > 0 && hudred == 0) {
		hudgreen--
		hudblue++
	}
	if(hudblue > 0 && hudgreen == 0) {
		hudred++
		hudblue--
	}
	color := ARGB(255, hudred, hudblue, hudgreen)
	Loop, 32
	{
		i := A_Index -1
		__WRITEMEM(hGTA, (0xBAB22C + (4 * i)), [0x0], color, "int")
	}		
}
return

Tempomat:
{
	GetKeyState, Status, s, P
	if Status = D
	{
		ChatMessage("Der Tempomat wurde ausgeschaltet")
		Tempo := -1
		Tempomat := 0
		SendInput, {w Up}
		SetTimer, Tempomat, Off
		return
	}
	GetKeyState, Status, w, P
	if Status = D
	{
		ChatMessage("Der Tempomat wurde ausgeschaltet")
		Tempo := -1
		Tempomat := 0
		SendInput, {w Up}
		SetTimer, Tempomat, Off
		return
	}
	GetKeyState, Status, t, P
	if Status = D
	{
		ChatMessage("Der Tempomat wurde ausgeschaltet")
		Tempo := -1
		Tempomat := 0
		SendInput, {w Up}
		SetTimer, Tempomat, Off
		return
	}
	if(Tempomat == 0){
		SetTimer, Tempomat, Off
		Tempo := -1
		SendInput, {w Up}
		return
	}else{
		if(GetVehicleSpeed()<Tempo){
			SendInput, {w Down}
		}else{
			SendInput, {w Up}
		}
	}	
}
return

Update:
{
	URLDownloadToVar_(mainURL . "/version.txt", newestVersion)
	if(newestVersion > version){
		URLDownloadToVar_(mainURL . "/latest_changelog.txt", changelog)
		MsgBox, 68, prawler, Es wurde eine neue Version von prawler veröffentlicht!`nMöchtest du diese herunterladen?`n`nVersion: %newestVersion%`n`nChangelog:`n%changelog%
		IfMsgBox, Yes
		{
			UrlDownloadToFile, %mainURL%/prawler.exe, prawler.new.exe
			Sleep, 500
			updateBat =
			(LTrim
			ping 127.0.0.1 -n 2 > nul
			Del "prawler.exe"
			Rename "prawler.new.exe" "prawler.exe"
			"prawler.exe"
			)
			FileAppend, %updateBat%, update.bat
			Run, update.bat, , hide
			ExitApp
		}
	}else{
		MsgBox, 64, prawler, Es ist keine neue Version von prawler vorhanden!
	}
}
return

ToggleLights:
{
	lightcounter++
	if(lightcounter == 1)
		setVehicleLightStatus(1, 1, 1)
	if(lightcounter == 2)
		setVehicleLightStatus(0, 0, 0)
	if(lightcounter == 3)
		SetTimer, ToggleLights, Off
}
return

Siren:
if(!SirenSite){
	SirenSite := 1
	setVehicleLightStatus(1, 0, 1)
}else{
	SirenSite := 0
	setVehicleLightStatus(0, 1, 0)
}
return

;OwnHotkeys
ownHotkeyLabel_1:
SendOwnHotkey(1)
return

ownHotkeyLabel_2:
SendOwnHotkey(2)
return

ownHotkeyLabel_3:
SendOwnHotkey(3)
return

ownHotkeyLabel_4:
SendOwnHotkey(4)
return

ownHotkeyLabel_5:
SendOwnHotkey(5)
return

ownHotkeyLabel_6:
SendOwnHotkey(6)
return

ownHotkeyLabel_7:
SendOwnHotkey(7)
return

ownHotkeyLabel_8:
SendOwnHotkey(8)
return

ownHotkeyLabel_9:
SendOwnHotkey(9)
return

ownHotkeyLabel_10:
SendOwnHotkey(10)
return

ownHotkeyLabel_11:
SendOwnHotkey(11)
return

ownHotkeyLabel_12:
SendOwnHotkey(12)
return

ownHotkeyLabel_13:
SendOwnHotkey(13)
return

ownHotkeyLabel_14:
SendOwnHotkey(14)
return

ownHotkeyLabel_15:
SendOwnHotkey(15)
return

ownHotkeyLabel_16:
SendOwnHotkey(16)
return

ownHotkeyLabel_17:
SendOwnHotkey(17)
return

ownHotkeyLabel_18:
SendOwnHotkey(18)
return

ownHotkeyLabel_19:
SendOwnHotkey(19)
return

ownHotkeyLabel_20:
SendOwnHotkey(20)
return

;Hotkeys
~LButton::
{
	If (A_TimeSincePriorHotkey<400) and (A_TimeSincePriorHotkey<>-1){
		if(isDialogOpen()){
			OnDialogResponse(true)
		}
	}
}
return

F2::
{
	CMD_prawlerhelp()
}
return

F9::
{
	SendChat("/members")
}
return

~ä::
{
	if(IsChatOpen())
		return
	SendInput t{up}{enter}
}
return

~$f::
{
	inVehicle := isPlayerInAnyVehicle()
	if(!inVehicle || !IsPlayerDriver() || IsChatOpen())
		return
	if(GetVehicleEngineState(getVehicleID()))
	{
		SendChat("/motor")
	}
}
return

~$m::
{
	inVehicle := isPlayerInAnyVehicle()
	if(!inVehicle || !IsPlayerDriver() || IsChatOpen())
		return
	if(GetVehicleEngineState(getVehicleID()))
	{
		SendChat("/motor")
	}
	else
	{
		SendChat("/motor")
		SetTimer, lights, On
	}
}
return

,::
{
	if(IsChatOpen())
	{
		SendInput, {%A_ThisHotkey%}
		return
	}
	SendChat("/Carkey")
}
return

y::
{
	if(IsChatOpen() or isDialogOpen())
	{
		SendInput, {%A_ThisHotkey%}
		return
	}
	setVehicleLightStatus(0, 0, 0)
	SendChat("/Lock")
	lightcounter := 0
	SetTimer, ToggleLights, 350
}
return

~2::
{
	if(IsChatOpen() or isDialogOpen())
	{
		SendInput, {%A_ThisHotkey%}
		return
	}
	if(getVehicleModelID(getVehicleID()) == 553 || getVehicleModelID(getVehicleID()) == 577)
		return
	fishNumber++
	if(fishNumber > 5)
		fishNumber := 1
	SendChat("/Eat " fishNumber)
}
return

3::
{
	if(IsChatOpen() or isDialogOpen())
	{
		SendInput, {%A_ThisHotkey%}
		return
	}
	SendChat("/Erstehilfe")
}
return

4::
{
	if(IsChatOpen() or isDialogOpen())
	{
		SendInput, {%A_ThisHotkey%}
		return
	}
	SendChat("/Usedrugs")
}
return

#::
{
	if(IsChatOpen() or isDialogOpen())
	{
		SendInput, {%A_ThisHotkey%}
		return
	}
	CMD_Stats()
}
return

Delete::
{
	goto GuiClose
}
return

;Commands
#If WinActive("GTA:SA:MP")
*Enter::
if(IsChatOpen()){
	checkSendCMDNOP()
	clip := ClipboardAll
	Clipboard := ""
	SendInput, {Right}A{BackSpace}^A^C{Enter}
	Loop, 100 {
		sleep, 5
		if (Clipboard != "")
			break
	}
	chatText := Clipboard
	Clipboard := clip
	if (chatText == -1 || chatText == "")
		return
	if (SubStr(chatText, 1, 1) == "/") {
		if (!OnPlayerCommand(chatText))
			SendChat(chatText)
	}
}else if(isDialogOpen()){
	OnDialogResponse(true)
}
return

CMD_Stats(){
	userStatus := DB_GetStatus()
	if(userStatus == "Premium" || userStatus == "Administrator") {
		showFormattedStats()
	} else if(userStatus == "Normal") {
		SendChat("/Stats")
		saveOpenstats()
	}
	return true
}

CMD_Savestats() {
	Sleep 250
	SendChat("/Time")
	SendChat("/stats")
	Sleep 250
	takeScreenshot()
	Sleep 100
	SendInput, {Escape}
	savestats()
	ShowGameText("Statistiken wurden gespeichert", 2000, 3)
	return true
}

CMD_Alotto() {
	Random, LottoNummer, 1, 100
	SendChat("/lotto " . LottoNummer)
	return true
}

CMD_Re(params := "") {
	CMD_Resms(params)
	return true
}

CMD_Resms(params := "") {
	if(params == "")
	{
		ChatMessage("Verwendung: /Resms [Nachricht]")
		return true
	}
	distanceSMS := 0
	Loop, Read, %A_MyDocuments%\GTA San Andreas User Files\SAMP\chatlog.txt
	{
		if (RegExMatch(A_LoopReadLine, "SMS: (.+), Sender: (\S+) \((\d+)\)", preSMS_)) {
			if (preSMS_2 != getUsername()) {
				RegExMatch(A_LoopReadLine, "SMS: (.+), Sender: (\S+) \((\d+)\)", sms_)
			}
		} else if (RegExMatch(A_LoopReadLine, "SMS: (.+)\.\.\.", preSMS_1_)) {
			distanceSMS := 0
			RegExMatch(A_LoopReadLine, "SMS: (.+)\.\.\.", sms_)
		} else if (RegExMatch(A_LoopReadLine, "\.\.\.(.*), Sender: (\S+) \((\d+)\)", preSMS_2_)) {
			if (distanceSMS == 2) {
				if (preSMS_2_2 != getUsername()) {
					sms_2 := preSMS_2_2
					sms_3 := preSMS_2_3
				}
			}
		}
		distanceSMS++
	}
	if (sms_2 != "") {
		ChatMessage("Letzte SMS (von " sms_2 "):")
		ChatMessage(sms_1)
		params := "conf " params
		SendChat("/Sms " sms_3 params)
	} else {
		ChatMessage("Keine SMS vorhanden!")
	}
	return true
}

CMD_Admins() {
	SendChat("/admins")
	sleep, 150
	Line := 0
	teamCounter := 0
	Loop, 100
	{
		GetChatLine(Line, Chatline)
		if(InStr(Chatline, "Teammitglieder online:")){
			break
		}else if(InStr(Chatline, "Supporter:")){
			RegExMatch(Chatline, "(.*)\: (.*)", params)
			id := getPlayerIdByName(params2)
			teamCounter++
			SetChatLine(Line, "{33CCFF}" params1 ": {B4B4B4}" params2)
		}else if(InStr(Chatline, "Projektleitung:") || InStr(Chatline, "Head Admin:")){
			RegExMatch(Chatline, "(.*)\: (.*)", params)
			id := getPlayerIdByName(params2)
			teamCounter++
			SetChatLine(Line, "{AA3333}" params1 ": {B4B4B4}" params2)
		}else if(InStr(Chatline, "Admin:")){
			RegExMatch(Chatline, "(.*)\: (.*)", params)
			id := getPlayerIdByName(params2)
			teamCounter++
			SetChatLine(Line, "{0000BB}" params1 ": {B4B4B4}" params2)
		}else if(InStr(Chatline, "Moderator:")){
			RegExMatch(Chatline, "(.*)\: (.*)", params)
			id := getPlayerIdByName(params2)
			teamCounter++
			SetChatLine(Line, "{6495ED}" params1 ": {B4B4B4}" params2)
		}
		Line++
	}
	return true
}

CMD_FPSLock() {
	if (!isPremium())
		return true
	if (fpsLock()) {
		ChatMessage("Deine FPS wurden eingeschränkt")
	} else {
		ChatMessage("Es ist ein Fehler aufgetreten! Versuche es erneut!")
	}
	return true
}

CMD_FPSUnlock() {
	if (!isPremium())
		return true
	if (fpsUnlock()) {
		ChatMessage("Deine FPS wurden freigegeben")
	} else {
		ChatMessage("Es ist ein Fehler aufgetreten! Versuche es erneut!")
	}
	return true
}

CMD_Asell() {
	if(getInteriorID() == 10)
	{
		OldMoney := GetPlayerMoney()
		throwbackall := 0
		ChatMessage("Automatisches Fischeverkaufen gestartet!")
		Loop, 5
		{
			SendChat("/Sell fish " A_Index)
			Sleep 250
			GetChatLine(0, Chat)
			if(InStr(Chat, "Du kannst nur Fische verkaufen, die 20 LBS oder mehr wiegen.")){
				throwbackall := 1
			}
			Sleep 250
		}
		if(throwbackall){
			SendChat("/Throwbackall")
			Sleep 100
			SetChatLine(0, prefix "Die unverkaufbaren Fische wurden weggeschmissen!")
		}
		NewMoney := GetPlayerMoney()
		Diff := NewMoney-OldMoney
		FischGesamt := ReadSettings("Weiteres", "Fisch Gesamtverdienst")
		if(FischGesamt >= 0 && FischGesamt < 9999999){
			FischGesamtNeu := FischGesamt + Diff
		}else{
			FischGesamtNeu := Diff
		}
		ChatMessage("Du hast " FormatNumber(Diff) "$ durch das Fischeverkaufen verdient! Gesamt Verdienst: " FormatNumber(FischGesamtNeu) "$")
		WriteSettings(FischGesamtNeu, "Weiteres", "Fisch Gesamtverdienst")
	}else{
		ChatMessage("Du befindest dich in keinem 24/7 Laden!")
	}
	return true
}

CMD_ACook() {
	if(getInteriorID() == 10 or getInteriorID() == 9 or getInteriorID() == 5)
	{
		fish := 0
		Loop 5,
		{
			fish++
			SendChat("/Cook fish " fish)
			Sleep 500
		}
		ChatMessage("Es wurden alle deine Fische gekocht!")
	}
	return true
}

CMD_Afish() {
	fishNumber := 0
	aFishMoney := 0
	aFishHP := 0
	cheapestFish := -1
	cheapestFishName := ""
	cheapestFishValue := 100000
	cheapestFishMoney := 100000
	cheapestFishHP := 100000
	thrownAway := false
	attempt := 1
	afishactive := 1
	Loop {
		SendChat("/fish")
		Sleep, 200
		fishing := readChatLine(0)
		if (RegExMatch(fishing, "Du hast ein\/e (.+) mit (\d+) LBS gefangen.", fishing_)) {
			fishNumber++
			currentFishMoney := getFishPrice(fishing_1, fishing_2)
			fishValue := currentFishMoney
			setChatLine(0, PREFIX . "#" . fishNumber . " > " . fishing_1 . " mit " . fishing_2 . " LBS | Wert: " . FormatNumber(currentFishMoney) . "$")
			aFishMoney += currentFishMoney
			aFishHP += fishing_2
			if (cheapestFishValue > fishValue) {
				cheapestFish := fishNumber
				cheapestFishName := fishing_1
				cheapestFishValue := fishValue
				cheapestFishMoney := currentFishMoney
				cheapestFishHP := fishing_2
			}
		} else if (RegExMatch(fishing, "Du kannst nur 5 Fische bei dir tragen.")) {
			if (cheapestFish == -1) {
				ChatMessage("Du musst deine Fische erst verkaufen!")
				afishactive := 0
				break
			}
			if (thrownAway){
				afishactive := 0
				break
			}
			aFishMoney -= cheapestFishMoney
			aFishHP -= cheapestFishHP
			SendChat("/releasefish " . cheapestFish)
			Sleep, 200
			setChatLine(0, PREFIX . "#" . cheapestFish . " > " . cheapestFishName . " {FFFFFF}mit einem Wert von " . FormatNumber(cheapestFishValue) . "$ {FFFFFF}wurde weggeworfen!")
			thrownAway := true
		} else if (RegExMatch(fishing, "Du bist an keinem Angelplatz \(Big Wheel Rods\) oder an einem Fischerboot!")) {
			if (attempt == 3) {
				ChatMessage("Du kannst hier nicht angeln!")
				afishactive := 0
				break
			}
			attempt++
		} else if (RegExMatch(fishing, "Du hast eine Geldtasche mit (.*)$ gefangen\.", fishing_)) {
			setChatline(0, prefix . "Du hast eine Geldtasche mit " MainColor fishing_1 "{FFFFFF}$ gefangen.")
		} else if (RegExMatch(fishing, "Du kannst erst in (.*) Minuten wieder angeln\.", fishing_)) {
			if (aFishMoney + aFishHP > 0) {
				ChatMessage("Gesamtwert: " . SECCOL . FormatNumber(aFishMoney) . "$ {FFFFFF}- " . SECCOL . FormatNumber(aFishHP) . " LBS")
				fishTime := fishing_1*60
				WriteSettings(fishTime, "Weiteres", "Fisch Timeout")
				afishactive := 0
				SetTimer, FischTimeout, Off
				SetTimer, FischTimeout, 1000
				FischTimerStatus := true
				break
			} else {
				fishTime := fishing_1*60
				WriteSettings(fishTime, "Weiteres", "Fisch Timeout")
				ChatMessage("Du kannst noch nicht angeln!")
				afishactive := 0
				SetTimer, FischTimeout, Off
				SetTimer, FischTimeout, 1000
				FischTimerStatus := true
				break
			}
		} else if (RegExMatch(fishing, "Du kannst erst in (.*) Sekunden wieder angeln\.", fishing_)) {
			fishTime := fishing_1
			WriteSettings(fishTime, "Weiteres", "Fisch Timeout")
			ChatMessage("Du kannst noch nicht angeln!")
			afishactive := 0
			break
		} else if(InStr(fishing, "weggeworfen")){
			setChatLine(0, prefix . "" . fishing)
		}
		Sleep, 700
	}
	return true
}

CMD_Time() {
	SendChat("/time")
	Sleep, 100
	adrGTA2 := getModuleBaseAddress("gta_sa.exe", hGTA)
	cText := readString(hGTA, adrGTA2 + 0x7AAD43, 512)
	if (RegExMatch(cText, "(.+)In Behandlung: (\d+)", cText_)) {
		time := formatTime(cText_2)
		writeString(hGTA, adrGTA2 + 0x7AAD43, cText_1 . "Noch " . time . " im KH")
	} else if (RegExMatch(cText, "(.+)Knastzeit: (\d+)", cText_)) {
		time := formatTime(cText_2)
		if (getPlayerInteriorId() == 1) {
			writeString(hGTA, adrGTA2 + 0x7AAD43, cText_1 . "Noch " . time . " im Prison")
		} else {
			writeString(hGTA, adrGTA2 + 0x7AAD43, cText_1 . "Noch " . time . " im Knast")
		}
	}
	return true
}

CMD_P() {
	SendChat("/Pickup")
	Sleep 100
	SendChat("Guten Tag! Wie kann ich helfen?")
	return true
}

CMD_H() {
	SendChat("Auf wiedersehen!")
	Sleep 100
	SendChat("/Hangup")
	return true
}

CMD_Cd(params := "") {
	CMD_Countdown(params)
	return true
}

CMD_Countdown(params := "") {
	if(params == ""){
		ChatMessage("Verwendung: /Countdown [Sekunden]")
		return true
	}
	if params is not number
	{
		ChatMessage("Bitte gib eine Sekundenanzahl zwischen 3 und 15 Sekunden an!")
		return true
	}
	if(params < 3 or params > 15){
		ChatMessage("Bitte gib eine Sekundenanzahl zwischen 3 und 15 Sekunden an!")
		return true
	}
	SendChat("Es folgt nun ein Countdown!")
	Loop, %params%
	{
		SendChat(">> " params " <<")
		params--
		Sleep 1000
		if(params == 0){
			SendChat("Der Countdown ist abgelaufen!")
			break
		}
	}
	return true
}

CMD_Temp(params := ""){
	CMD_Tempomat(params)
	return true
}

CMD_Tempomat(params := "") {
	if(params == ""){
		ChatMessage("Verwendung: /Tempomat [Geschwindigkeit]")
		return true
	}
	if params is not number
	{
		ChatMessage("Bitte gib eine gültige Geschwindigkeit an!")
		return true
	}
	if(params < 5 or params > 200){
		ChatMessage("Bitte gib eine gültige Geschwindigkeit an!")
		return true
	}
	if(IsPlayerDriver()){
		if(Tempomat == 0){
			ChatMessage("Der Tempomat wurde angeschaltet! KM/h: ~ " . params)
			params += 1
			Tempomat := 1
			Tempo := params
			SetTimer, Tempomat, 100
		}
	}else{
		ChatMessage("Du bist nicht der Fahrer eines Fahrzeuges!")
	}
	return true
}

CMD_Fin(){
	CMD_Finanzen()
	return true
}

CMD_Finanzen(){
	blockDialog()
	Sleep 250
	SendChat("/Stats")
	Sleep 250
	SendInput, {Esc}
	Dialogline := getdialogline(12)
	RegExMatch(Dialogline, "Finanzen\:	Bargeld\: (.*)\$", line12_)
	WriteStats("Bargeld", line12_1)
	Dialogline := getdialogline(13)
	RegExMatch(Dialogline, "Konto\: (.*)\$", line13_)
	WriteStats("Bank", line13_1)
	Dialogline := getdialogline(14)
	RegExMatch(Dialogline, "Festgeld\: (.*)\$	Zinssatz\: (.*)", line14_)
	WriteStats("Festgeld", line14_1)
	if(isDialogOpen())
		SendInput, {Esc}
	unblockDialog()
	Sleep 150
	showDialog(DIALOG_STYLE_TABLIST_HEADERS, "Finanzen", "Beschreibung`tWert`nBargeld`t" FormatNumber(line12_1) "$`nBank`t" FormatNumber(line13_1) "$`nFestgeld`t" FormatNumber(line14_1) "$`n`t`nGesamtvermögen`t" FormatNumber((line12_1+line13_1+line14_1))"$", "Schließen")
	return true
}

CMD_prawlerhelp(){
	if(isDialogOpen()){
		SendInput {Esc}
		Sleep 100
	}
	Fraktion := ReadStats("Fraktion")
	if(Fraktion != "Zivilist" && Fraktion == "ERROR"){
		StringReplace, FraktionDialog, Fraktion, %A_Space%, _
	} else {
		Fraktion := ""
	}
	showDialog(DIALOG_STYLE_LIST, prefix . "Hilfemenü", "Einstellungen`nHotkeys`nBefehle`n{FFBF00}Premium Features`n" Fraktion, "Auswählen", "Schließen")
}

CMD_Chatclear() {
	Loop, 25 {
		AddChatMessage("")
	}
	ChatMessage("Der Chat wurde erfolgreich gecleart!")
	return true
}

CMD_Link() {
	Loop, 50
	{
		GetChatLine(A_Index - 1, Chatline)
		if(InStr(Chatline, "http://")){
			RegExMatch(Chatline, "http\:\/\/(\S+)", params)
			clipboard = http://%params1%
			ChatMessage("Link wurde in die Zwischenablage kopiert")
			return true
		}else if(InStr(Chatline, "https://")){
			RegExMatch(Chatline, "https\:\/\/(\S+)", params)
			clipboard = https://%params1%
			ChatMessage("Link wurde in die Zwischenablage kopiert")
			return true
		}else if(InStr(Chatline, "www.")){
			RegExMatch(Chatline, "www\.(\S+)", params)
			clipboard = www.%params1%
			ChatMessage("Link wurde in die Zwischenablage kopiert")
			return true
		}
	}
	ChatMessage("Es wurde kein Link im Chat gefunden")
	return true
}

CMD_Tr(params := "") {
	CMD_Taschenrechner(params)
	return true
}

CMD_Taschenrechner(params := "") {
	if(params == "")
	{
		ChatMessage("Benutze: /Taschenrechner [Berechnung]")
		return true
	}
	Ergebnis := stringMath(params)
	if(Ergebnis != "ERROR") {
		ChatMessage(params " = " formatNumber(Ergebnis))
	}else {
		ChatMessage("Ungültige Eingabe")
	}
	return true
}

CMD_Rainbow() {
	if(!RainbowActivated) {
		RainbowActivated := 1
		SetTimer, Rainbow, 5
		ShowGameText("Rainbow An", 3000, 3)
	} else {
		RainbowActivated := 0
		SetTimer, Rainbow, Off
		__WRITEMEM(hGTA, 0xBAB22C, [4 * 0], 0xFF1F1FE0, "UInt")
		__WRITEMEM(hGTA, 0xBAB22C, [4 * 1], 0xFF009933, "UInt")
		__WRITEMEM(hGTA, 0xBAB22C, [4 * 2], 0xFFFF901E, "UInt")
		__WRITEMEM(hGTA, 0xBAB22C, [4 * 4], 0xFFFFFFFF, "UInt")
		__WRITEMEM(hGTA, 0xBAB22C, [4 * 6], 0xFF00D7FF, "UInt")
		__WRITEMEM(hGTA, 0xBAB22C, [4 * 11], 0xFF00D7FF, "UInt")
		ShowGameText("~b~Rainbow ~r~Aus", 3000, 3)
	}
	return true
}

CMD_Textdraws(){
	printPlayerTextdraws()
	return true
}

CMD_Profil(){
	showDialog(DIALOG_STYLE_TABLIST, prefix . "Informationen zum Benutzerkonto", "Benutzername`t" getUsername() "`nStatus`t" DB_GetStatus(), "Schließen")
	return true
}

CMD_Add(params := "") {
	if (!isPremium())
		return true
	if(params == "")
	{
		ChatMessage("Verwendung: /Add [Spieler ID]")
		return true
	}
	if(params == "" || params == " " || params == ERROR || params == GetUserName())
	{
		ChatMessage("Es ist ein Fehler aufgetreten! Versuche es erneut!")
		return true
	}
	if params is number
	{
		Username := getPlayerNameById(params)
		if(Username == "" && Username != GetUserName())
		{
			ChatMessage("Es ist ein Fehler aufgetreten! Versuche es erneut!")
			return true
		}
		else
		{
			Zeile := 0
			Existiert := 0
			Loop, read, %A_AppData%\prawler\Freunde.txt
			{
				If (Zeile >= A_Index)
				{
					Continue
				}
				else
				{
					if instr(A_Loopreadline,Username)
					{
						Existiert := 1
					}
					Zeile := A_Index
				}
			}
			if(Existiert == 0)
			{
				FileAppend, %Username%`n, %A_AppData%\prawler\Freunde.txt
				ChatMessage(Username . " (ID: " params ") wurde als Freund hinzugefügt!")
				return true
			}
			else
			{
				ChatMessage(Username " ist bereits auf deiner Freundesliste")
				return true
			}
		}
	}
	else
	{
		ChatMessage("Es ist ein Fehler aufgetreten! Versuche es erneut!")
		return true
	}
	return true
}

CMD_Del(params := "") {
	if (!isPremium())
		return true
	if(params == "")
	{
		ChatMessage("Verwendung: /Del [Spielername]")
		return true
	}
	if(params == "" || params == " " || params == ERROR)
	{
		ChatMessage("Es ist ein Fehler aufgetreten! Versuche es erneut!")
		return true
	}
	if params is number
	{
		ChatMessage("Bitte gib einen Spielernamen ein!")
		return true
	}
	else
	{
		Zeile := 0
		Existiert := 0
		Loop, read, %A_AppData%\prawler\Freunde.txt
		{
			If (Zeile >= A_Index)
			{
				Continue
			}
			else
			{
				if instr(A_Loopreadline,params)
				{
					Existiert := 1
				}
				Zeile := A_Index
			}
		}
		if(Existiert == 1)
		{
			FileRead, FreundeslisterText, %A_AppData%\prawler\Freunde.txt
			StringReplace, FreundeslisterText, FreundeslisterText, %params%, , All
			FileDelete, %A_AppData%\prawler\Freunde.txt
			FileAppend, %FreundeslisterText%, %A_AppData%\prawler\Freunde.txt
			ChatMessage(params " wurde erfolgreich von deiner Freundesliste entfernt!")
			return true
		}
		else
		{
			ChatMessage(params " existiert nicht auf deiner Freundesliste!")
			return true
		}
	}
	return true
}

CMD_Freunde() {
	if (!isPremium())
		return true
	IfExist, %A_AppData%\prawler\Temp.txt
	{
		FileDelete, %A_AppData%\prawler\Temp.txt
	}
	Zeile := 0
	Online := 0
	Loop, read, %A_AppData%\prawler\Freunde.txt
	{
		if(Zeile >= A_Index)
		{
			Continue
		}
		else
		{
			StringTrimRight, GegnerName, A_Loopreadline, 0
			Onlinecheck := GetPlayerIdByName(GegnerName)
			if(GegnerName == "" || GegnerName == " " || GegnerName == ERROR)
			{
			}
			else
			{
				if(Onlinecheck == 65535 || Onlinecheck == -1 || Onlinecheck < 0 || Onlinecheck > 1000)
				{
					FileAppend, `n%GegnerName%`t-`t{FF0000}Offline, %A_AppData%\prawler\Temp.txt
				}
				else
				{
					Online++
					FileAppend, `n%GegnerName%`t%Onlinecheck%`t{00FF00}Online, %A_AppData%\prawler\Temp.txt
				}
			}
			Zeile := A_Index
		}
	}
	if(Online > 1)
	{
		FileAppend, `n{8B8989}Es sind %Online% Freunde online, %A_AppData%\prawler\Temp.txt
	}
	if(Online == 0)
	{
		FileAppend, `n{8B8989}Es sind keine Freunde online, %A_AppData%\prawler\Temp.txt
	}
	if(Online == 1)
	{
		FileAppend, `n{8B8989}Es ist %Online% Freund online, %A_AppData%\prawler\Temp.txt
	}
	FileRead, TempFreunde, %A_AppData%\prawler\Temp.txt
	showDialog(DIALOG_STYLE_TABLIST_HEADERS, prefix "Freunde", "Name`tID`tStatus" . TempFreunde, "Schließen")
	FileDelete, %A_AppData%\prawler\Temp.txt
	return true
}

CMD_DelAll() {
	if (!isPremium())
		return true
	FileDelete, %A_AppData%\prawler\Freunde.txt
	ChatMessage("Alle deine Freunde wurden aus deiner Freundesliste gelöscht")
	return true
}

CMD_Pc(params := ""){
	if(params == ""){
		ChatMessage("Verwendung: /Pc [Nachricht]")
		return true
	}
	if(StrLen(params) > 90){
		ChatMessage("Error: Nachricht zu lang!")
		return true
	}
	if(DB_GetStatus() != "Normal"){
		SendChat("/i *^*" params)
	}else{
		SendChat("/i " params)
	}
	return true
}

CMD_I(params := ""){
	if(params == ""){
		ChatMessage("Verwendung: /Pc [Nachricht]")
		return true
	}
	if(connectedToChat == 1){
		CMD_Pc(params)
	}else{
		SendChat("/i " params)
	}
	return true
}

CMD_TogPC(){
	PrawlerChat := ReadSettings("Weiteres", "PrawlerChat")
	if(PrawlerChat == 0){
		WriteSettings(1, "Weiteres", "PrawlerChat")
		showGametext("~b~Prawler Chat~n~~g~angeschaltet", 2000, 3)
		connectIRC()
	}else if(PrawlerChat == 1){
		WriteSettings(0, "Weiteres", "PrawlerChat")
		showGametext("~b~Prawler Chat~n~~r~ausgeschaltet", 2000, 3)
		leaveIRC()
	}
	return true
}

CMD_Settings(){
	showDialog(DIALOG_STYLE_LIST, prefix "Einstellungen", "Killcounter`nDeathcounter`nEigene Hotkeys`nWeiteres`nNeustarten", "Auswählen", "Schließen")
	return true
}

;News Reporter
CMD_Spendenaufruf(params := ""){
	if(ReadStats("Fraktion") == "News Reporter"){
		if(!isPlayerInAnyVehicle()){
			ChatMessage("Du sitzt in keinem San News Fahrzeug!")
			return true
		}
		if(SpendenaufrufActive == 0){
			if(params == ""){
				ChatMessage("Verwendung: /Spendenaufruf [Standort]")
				return true
			}
			SendChat("/News .: San News - Spendenaufruf :.")
			Sleep 650
			SendChat("/News Wir als San News starten einen Spendenaufruf, wo jede Person freiwilling")
			Sleep 650
			SendChat("/News einen Betrag an uns Spenden kann, damit wir weiterhin unsere Events")
			Sleep 650
			SendChat("/News veranstalten können! Standort: " params)
			Sleep 650
			SendChat("/News Die San News bedankt sich im voraus für alle Spenden!")
			collectedMoney := 0
			SpendenaufrufActive := 1
		}else if(SpendenaufrufActive == 1){
			SendChat("/News .: San News- Spendenaufruf :.")
		Sleep 650
			SendChat("/News Der Spendenaufruf wird nun beendet.")
			Sleep 650
			SendChat("/News Vielen Dank an alle Spender! Durch euch können wir die kommenden")
			Sleep 650
			SendChat("/News Events veranstalten! Wir wünschen euch weiterhin viel Spaß beim")
			Sleep 650
			SendChat("/News Spielen! ~ eure San News")
			collectedMoney := 0
			SpendenaufrufActive := 0
		}else{
			ChatMessage("Es ist ein Fehler aufgetreten! Versuche es erneut...")
		}
		return true
	}
	return false
}

CMD_Wortsalat(params := ""){
	if(ReadStats("Fraktion") == "News Reporter"){
		if(!isPlayerInAnyVehicle()){
			ChatMessage("Du sitzt in keinem San News Fahrzeug!")
			return true
		}
		if(WortsalatAktiv == 0){
			if(params == ""){
				ChatMessage("Verwendung: /Wortsalat [Gewinn pro Rundee]")
				ChatMessage("Bitte gib an, wie viel pro Runde gewonnen werden kann!")
				return true
			}
			WortsalatAktiv := 1
			T := %A_Now%
			T += 5, Minutes
			FormatTime, Time, %T%, HH:mm
			telefonnummer := ReadStats("Telefonnummer")
			SendChat("/News  .: Event - Wortsalat :.")
			Sleep 650
			SendChat("/News  Wir veranstalten in Kürze ein Event names Wortsalat! Dabei")
			Sleep 650
			SendChat("/News  geht es darum ein vemischtes Wort zu erraten und mir das")
			Sleep 650
			SendChat("/News  richtige Wort per SMS zukommen zu lassen. Es werden 3 Runden")
			Sleep 650
			SendChat("/News  Durchgeführt und die Gewinne betragen " FormatNumber(params) "$ pro Runde!")
			Sleep 650
			SendChat("/News  Wir staten um " Time " Uhr | Tel.-Nr.: " telefonnummer)
			return true
		}else if(WortsalatAktiv == 1){
			if(params == ""){
				ChatMessage("Verwendung: /Wortsalat [Ort]")
				ChatMessage("Bitte gib an, wo die Gewinner die Gewinne abholen können!")
				return true
			}
			WortsalatAktiv := 0
			SendChat("/News  .: Event - Wortsalat - ENDE :.")
			Sleep 650
			SendChat("/News  Wir bedanken uns bei euch für die zahlreichen Teilnahmen!")
			Sleep 650
			SendChat("/News  Die Gewinner können ihren Gewinn hier abholen: " params)
			Sleep 650
			SendChat("/News  Wir wünschen euch noch einen angenehmen Tag!")
			return true
		}
	}
	return false
}

CMD_W1(params := ""){
	if(WortsalatAktiv == 1){
		if(params == ""){
			ChatMessage("Verwendung: /W1 [Wort]")
			return true
		}
		gemischtesWort := mixWord(params)
		originalesWort := params
		telefonnummer := ReadStats("Telefonnummer")
		SendChat("/News Das erste Wort lautet: " gemischtesWort)
		SendChat("/News Schicke mir das korrekte Wort per SMS (Tel.: " telefonnummer ")")
		return true
	}
	return false
}

CMD_W1Stop(params := ""){
	if(WortsalatAktiv == 1){
		if(params == ""){
			ChatMessage("Verwendung: /W1Stop [Gewinner]")
			return true
		}
		SendChat("/News STOP - Wort wurde erraten - STOP")
		SendChat("/News Das Wort wurde von " params " erraten! Wort: " originalesWort)
		return true
	}
	return false
}

CMD_W2(params := ""){
	if(WortsalatAktiv == 1){
		if(params == ""){
			ChatMessage("Verwendung: /W2 [Wort]")
			return true
		}
		gemischtesWort := mixWord(params)
		originalesWort := params
		telefonnummer := ReadStats("Telefonnummer")
		SendChat("/News Das zweite Wort lautet: " gemischtesWort)
		SendChat("/News Schicke mir das korrekte Wort per SMS (Tel.: " telefonnummer ")")
		return true
	}
	return false
}

CMD_W2Stop(params := ""){
	if(WortsalatAktiv == 1){
		if(params == ""){
			ChatMessage("Verwendung: /W2Stop [Gewinner]")
			return true
		}
		SendChat("/News STOP - Wort wurde erraten - STOP")
		SendChat("/News Das Wort wurde von " params " erraten! Wort: " originalesWort)
		return true
	}
	return false
}

CMD_W3(params := ""){
	if(WortsalatAktiv == 1){
		if(params == ""){
			ChatMessage("Verwendung: /W3 [Wort]")
			return true
		}
		gemischtesWort := mixWord(params)
		originalesWort := params
		telefonnummer := ReadStats("Telefonnummer")
		SendChat("/News Das letzte Wort lautet: " gemischtesWort)
		SendChat("/News Schicke mir das korrekte Wort per SMS (Tel.: " telefonnummer ")")
		return true
	}
	return false
}

CMD_W3Stop(params := ""){
	if(WortsalatAktiv == 1){
		if(params == ""){
			ChatMessage("Verwendung: /W3Stop [Gewinner]")
			return true
		}
		SendChat("/News STOP - Wort wurde erraten - STOP")
		SendChat("/News Das Wort wurde von " params " erraten! Wort: " originalesWort)
		return true
	}
	return false
}

;Crew - Bandidos
^R::
{
	if(ReadStats("Crew") == "Bandidos"){
		SendChat("/Robstore")
	}
}
return

CMD_Cm(){
	SendChat("/Crewmembers")
	return true
}

CMD_C(params := ""){
	if(params == ""){
		ChatMessage("Verwendung: /C [Nachricht]")
		return true
	}
	SendChat("/Crew " params)
	return true
}

CMD_Ck(params := ""){
	CMD_Crewkasse(params)
	return true
}

CMD_Crewkasse(params := ""){
	SendChat("/Crewkasse " params)
	Sleep 100
	GetChatLine(0, Chat0)
	if(RegExMatch(Chat0, "Es befinden sich (.*)\$ in der Crew Kasse\.", kasse_)){
		SetChatLine(0, "Es befinden sich " FormatNumber(kasse_1) "$ in der Crew Kasse.")
	}
	return true
}

CMD_Delivery(params := ""){
	if(params == ""){
		blockDialog()
		Sleep 100
		SendChat("/Delivery")
		Sleep 100
		line := 4
		newdialogtext := "Auftrag`tWare`tRoute`tGehalt`n"
		Loop
		{
			line++
			DialogLine := GetDialogLine(line)
			if(!InStr(DialogLine, "Auftrag"))
				break
			RegExMatch(DialogLine, "Auftrag ([0-9]+)\: (.*) \(von (.*) nach (.*)\)\, Gehalt\: ([0-9]+)\$\, noch ([0-9]+) Minuten verfügbar\.", contract_)
			newdialogtext .= "" contract_1 "`t" contract_2 "`t" contract_3 " > " contract_4 "`t" FormatNumber(contract_5) "$`n"
		}
		unblockDialog()
		Sleep 100
		ShowDialog(DIALOG_STYLE_TABLIST_HEADERS, prefix . "Truckermissionen", newdialogtext, "Schließen")
	}else{
		SendChat("/Delivery " params)
	}
	return true
}

CMD_Lock(){
	if(isPlayerDriver()){
		setVehicleLightStatus(0, 0, 0)
		SendChat("/Lock")
		lightcounter := 0
		SetTimer, ToggleLights, 350
	}
	return true
}

CMD_Sirene(params := ""){
	if(params == ""){
		ChatMessage("Verwendung: /Sirene [AN/AUS]")
	}
	if(params == "An" || params == "an"){
		SetTimer, Siren, 200
	}else if(params == "Aus" || params == "aus"){
		SetTimer, Siren, Off
	}
}

/*
CMD_move(params := ""){
	RegExMatch(params, "([0-9]+) ([0-9]+) ([0-9]+)", param_)
	movetextdraw(param_1, param_2, param_3)
}
*/

;Funktionen und Klassen
class textlabel{
	ident := -1
	text := "NOTEXT"
	color := "0xFFFF90FF"
	xPos := 0
	yPos := 0
	zPos := 0
	drawDistance := 46
	testLOS := 0
	playerID := 0xFFFF
	vehicleID := 0xFFFF

	create(){
		if(This.ident == -1)
			This.ident := createTextLabel(This.text, This.color, This.xPos, This.yPos, This.zPos, This.drawDistance, This.testLOS, This.playerID, This.vehicleID)
		Else
			ChatMessage("3DTextlabel " This.text " existiert bereits!")
	}

	delete(){
		This.ident := deleteTextLabel(This.ident)
	}

	update(labeltext){
		updateTextLabel(This.ident, labeltext)
	}
}

class textdraw{
	ident := -1
	text := "NOTEXT"
	xpos := 0
	ypos := 0
	letterColor := "0xFFFF901E"
	font := 3
	letterWidth := 0.28
	letterHeight := 1.0
	shadowSize := 0
	outline := 1
	shadowColor := 0xFF000000
	box := 0
	boxColor := 0xFFFFFFFF
	boxSizeX := 1280.0
	boxSizeY := 1280.0
	left := 0
	right := 0
	center := 1
	proportional := 1
	modelID := 0
	xRot := 0.0
	yRot := 0.0
	zRot := 0.0
	zoom := 1.0
	color1 := 0xFFFF
	color2 := 0xFFFF
	testtext := "-"

	create(){
		if(This.ident == -1)
			This.ident := createTextDraw(This.text, This.xpos, This.ypos, This.letterColor, This.font, This.letterWidth, This.letterHeight, This.shadowSize, This.outline, This.shadowColor, This.box, This.boxColor, This.boxSizeX, This.boxSizeY, This.left, This.right, This.center, This.proportional, This.modelID, This.xRot, This.yRot, This.zRot, This.zoom, This.color1, This.color2)
	}

	delete(){
		This.ident := deleteTextDraw(This.ident)
	}

	update(newtext){
		if(This.ident != -1){
			updateTextDraw(This.ident, newtext)
			This.text := "" newtext ""
		}
	}

	move(xpos, ypos){
		if(This.ident != -1)
			moveTextDraw(This.ident, xpos, ypos)
	}

	hide(){
		if(This.ident != -1)
			This.move(700, 700)
	}

	show(){
		if(This.ident != -1)
			This.move(This.xpos, This.ypos)
	}
}

mixWord(inVar) {
	S := RegExReplace(inVar,"(.)","$1|")
	Sort, S, Random D|
	Return, RegExReplace(S,"\|")
}

savestats() {
	blockDialog()
	Sleep 100
	SendChat("/Stats")
	Sleep 100
	Dialogline := getdialogline(8)
	RegExMatch(Dialogline, "Berufe\:		Fraktion\: (.*)	Rang\: (.*)", line8_)
	Dialogline := getdialogline(9)
	RegExMatch(Dialogline, "Nebenjob\: (.*)", line9_)
	Dialogline := getdialogline(10)
	RegExMatch(Dialogline, "Crew\: (.*)	Rang\: ([0-9]+)", line10_)
	Dialogline := getdialogline(12)
	RegExMatch(Dialogline, "Finanzen\:	Bargeld\: (.*)\$", line12_)
	Dialogline := getdialogline(13)
	RegExMatch(Dialogline, "Konto\: (.*)\$", line13_)
	Dialogline := getdialogline(14)
	RegExMatch(Dialogline, "Festgeld\: (.*)\$	Zinssatz\: (.*)", line14_)
	Dialogline := getdialogline(16)
	RegExMatch(Dialogline, "Statistik\:	Morde\: (.*)", line16_)
	Dialogline := getdialogline(26)
	RegExMatch(Dialogline, "Handy \(Nr\. (.*)\)", line26_)
	Dialogline := getdialogline(28)
	RegExMatch(Dialogline, "Skills\:`t`tWaffendealer\: (.*) \((.*)\)", line28_)
	if(line28_1 > 0 && line_28_1 < 6){
		WriteStats("WaffendealerRang", line28_1)
	}else{
		Dialogline := getdialogline(29)
		RegExMatch(Dialogline, "Skills\:`t`tWaffendealer\: (.*) \((.*)\)", line28_)
		if(line28_1 > 0 && line_28_1 < 6){
			WriteStats("WaffendealerRang", line28_1)
		}else{
			Dialogline := getdialogline(30)
			RegExMatch(Dialogline, "Skills\:`t`tWaffendealer\: (.*) \((.*)\)", line28_)
			if(line28_1 > 0 && line_28_1 < 6){
				WriteStats("WaffendealerRang", line28_1)
			}
		}
	}
	WriteStats("Telefonnummer", line26_1)
	WriteStats("Kills", line16_1)
	WriteStats("Fraktion", line8_1)
	WriteStats("Rang", line8_2)
	WriteStats("Beruf", line9_1)	
	WriteStats("Bargeld", line12_1)
	WriteStats("Bank", line13_1)
	WriteStats("Festgeld", line14_1)
	WriteStats("Crew", line10_1)
	WriteStats("Crew Rang", line10_2)
	unblockDialog()
	if(isDialogOpen())
		SendInput, {Esc}
}

saveOpenstats() {
	if(InStr(getDialogCaption(), getUsername()) && isDialogOpen()){
		Dialogline := getdialogline(8)
		RegExMatch(Dialogline, "Berufe\:		Fraktion\: (.*)	Rang\: (.*)", line8_)
		Dialogline := getdialogline(9)
		RegExMatch(Dialogline, "Nebenjob\: (.*)", line9_)
		Dialogline := getdialogline(10)
		RegExMatch(Dialogline, "Crew\: (.*)	Rang\: ([0-9]+)", line10_)
		Dialogline := getdialogline(12)
		RegExMatch(Dialogline, "Finanzen\:	Bargeld\: (.*)\$", line12_)
		Dialogline := getdialogline(13)
		RegExMatch(Dialogline, "Konto\: (.*)\$", line13_)
		Dialogline := getdialogline(14)
		RegExMatch(Dialogline, "Festgeld\: (.*)\$	Zinssatz\: (.*)", line14_)
		Dialogline := getdialogline(16)
		RegExMatch(Dialogline, "Statistik\:	Morde\: (.*)", line16_)
		Dialogline := getdialogline(26)
		RegExMatch(Dialogline, "Handy \(Nr\. (.*)\)", line26_)
		Dialogline := getdialogline(28)
		RegExMatch(Dialogline, "Skills\:`t`tWaffendealer\: (.*) \((.*)\)", line28_)
		if(line28_1 > 0 && line_28_1 < 6){
			WriteStats("WaffendealerRang", line28_1)
		}else{
			Dialogline := getdialogline(29)
			RegExMatch(Dialogline, "Skills\:`t`tWaffendealer\: (.*) \((.*)\)", line28_)
			if(line28_1 > 0 && line_28_1 < 6){
				WriteStats("WaffendealerRang", line28_1)
			}else{
				Dialogline := getdialogline(30)
				RegExMatch(Dialogline, "Skills\:`t`tWaffendealer\: (.*) \((.*)\)", line28_)
				if(line28_1 > 0 && line_28_1 < 6){
					WriteStats("WaffendealerRang", line28_1)
				}
			}
		}
		WriteStats("Telefonnummer", line26_1)
		WriteStats("Kills", line16_1)
		WriteStats("Fraktion", line8_1)
		WriteStats("Rang", line8_2)
		WriteStats("Beruf", line9_1)	
		WriteStats("Bargeld", line12_1)
		WriteStats("Bank", line13_1)
		WriteStats("Festgeld", line14_1)
		WriteStats("Crew", line10_1)
		WriteStats("Crew Rang", line10_2)
	}
}

Info(string){
}

Credits(string){
}

ChatMessage(text){
	AddChatMessage(prefix . text)
}

ReadSettings(Section, Key) {
	IniRead, var, %A_AppData%\prawler\Einstellungen.ini, %Section%, %Key%
	return %var%
}

WriteSettings(Value, Section, Key) {
	IniWrite, %Value%, %A_AppData%\prawler\Einstellungen.ini, %Section%, %Key%
}

OnDialogResponse(response) {
	global
	caption := getDialogCaption()
	if (response) {
		if(ReadSettings("Weiteres", "DeathspruchInFraktion"))
			DSFrak := "{00FF00}AN{FFFFFF}"
		else
			DSFrak := "{FF0000}AUS{FFFFFF}"
		
		if(ReadSettings("Weiteres", "DeathspruchInCrew"))
			DSCrew := "{00FF00}AN{FFFFFF}"
		else
			DSCrew := "{FF0000}AUS{FFFFFF}"
		
		if(ReadSettings("Weiteres", "KillspruchInFraktion"))
			KSFrak := "{00FF00}AN{FFFFFF}"
		else
			KSFrak := "{FF0000}AUS{FFFFFF}"
		
		if(ReadSettings("Weiteres", "KillspruchInCrew"))
			KSCrew := "{00FF00}AN{FFFFFF}"
		else
			KSCrew := "{FF0000}AUS{FFFFFF}"
		
		if(ReadSettings("Weiteres", "Tacho"))
			Tacho := "{00FF00}AN{FFFFFF}"
		else
			Tacho := "{FF0000}AUS{FFFFFF}"
		
		if(ReadSettings("Weiteres", "ServerTextdraws"))
			STStatus := "{00FF00}AN{FFFFFF}"
		else
			STStatus := "{FF0000}AUS{FFFFFF}"
		if (caption == prefix . "Hilfemenü") {
			if (getDialogLine(getDialogIndex()) == "Hotkeys"){
				SendInput {Esc}
				Sleep 100
				ShowDialog(DIALOG_STYLE_TABLIST_HEADERS, prefix . "Hilfemenü -> Hotkeys", "Taste`tFunktion`n" hotkeylist "", "Schließen")
			} else if (getDialogLine(getDialogIndex()) == "Befehle"){
				SendInput {Esc}
				Sleep 100
				ShowDialog(DIALOG_STYLE_TABLIST_HEADERS, prefix . "Hilfemenü -> Befehle", "Befehl`tFunktion`n" commandslist "", "Schließen")
			} else if (getDialogLine(getDialogIndex()) == "{FFBF00}Premium Features"){
				if(DB_GetStatus() == "Normal"){
					SendInput {Esc}
					Sleep 100
					ShowDialog(DIALOG_STYLE_MSGBOX, prefix . "{FFBF00}Premium Features", "{FF0000}Du besitzt nicht den Premium Status!`n`n{FFFFFF}Du kannst dir den Premium Status bei Alborzar erwerben für`n{ACACAC}7.500$", "Schließen")
				}else{
					SendInput {Esc}
					Sleep 100
					ShowDialog(DIALOG_STYLE_TABLIST_HEADERS, prefix . "{FFBF00}Premium Features", "Befehl`tFunktion`n" premiumfeatures "", "Schließen")
				}
			} else if (getDialogLine(getDialogIndex()) == "News Reporter"){
				SendInput {Esc}
				Sleep 100
				ShowDialog(DIALOG_STYLE_TABLIST_HEADERS, prefix . "Hilfemenü -> News Reporter", "Ausführung`tFunktion`n" nrcommands "", "Schließen")
			} else if (getDialogLine(getDialogIndex()) == "Einstellungen"){
				SendInput {Esc}
				Sleep 100
				CMD_settings()
			}
		}else if(caption == "Linien Auswahl"){
			RegExMatch(getDialogLine(getDialogIndex()), "Linie ([0-9]+)\: (.*)\((.*)\)\, ab Skill ([0-9]+)", linie_)
			activLinie := linie_1
			SendInput, {Enter}
		}else if(caption == prefix "Einstellungen"){
			if (getDialogLine(getDialogIndex()) == "Killcounter"){
				SendInput {Esc}
				Sleep 100
				ShowDialog(DIALOG_STYLE_TABLIST_HEADERS, prefix . "Einstellungen -> Killcounter", "Einstellung`tStatus`nSenden im /F`t" KSFrak "`nSenden im /Crew`t" KSCrew, "Schließen")
			} else if (getDialogLine(getDialogIndex()) == "Deathcounter"){
				SendInput {Esc}
				Sleep 100
				ShowDialog(DIALOG_STYLE_TABLIST_HEADERS, prefix . "Einstellungen -> Deathcounter", "Einstellung`tStatus`nSenden im /F`t" DSFrak "`nSenden im /Crew`t" DSCrew, "Schließen")
			} else if (getDialogLine(getDialogIndex()) == "Eigene Hotkeys"){
				SendInput {Esc}
				counter := 0
				ownHotkeyList := ""
				Loop, 20
				{
					counter++
					if(counter >= 20)
						break
					ownHotkeyActive := ReadHotkey("Hotkey_" counter, "Active")
					ownHotkeyText := ReadHotkey("Hotkey_" counter, "Text")
					ownHotkeyKey := ReadHotkey("Hotkey_" counter, "Key")
					ownHotkeyList .= "" (ownHotkeyKey ? ownHotkeyKey : "-") "`t" (ownHotkeyText ? ownHotkeyText : "-") "`t" (ownHotkeyActive ? "{00FF00}AN{FFFFFF}" : "{FF0000}AUS{FFFFFF}") "`n"
				}
				Sleep 100
				ShowDialog(DIALOG_STYLE_TABLIST_HEADERS, prefix . "Eigene Hotkeys", "Hotkey`tText`tStatus`n" ownHotkeyList, "Schließen")
			} else if (getDialogLine(getDialogIndex()) == "Weiteres"){
				SendInput {Esc}
				Sleep 100
				ShowDialog(DIALOG_STYLE_TABLIST_HEADERS, prefix . "Weiteres", "Einstellung`tTacho`nprawler Tacho`t" Tacho "`nServer Textdraws`t" STStatus, "Schließen")
			} else if (getDialogLine(getDialogIndex()) == "Neustarten"){
				SendInput {Esc}
				Reload
			}
		}else if(caption == prefix . "Einstellungen -> Deathcounter"){ ;--- Deathcounter
			if (getDialogLine(getDialogIndex()) == "Senden im /F`t" DSFrak){
				if(!ReadSettings("Weiteres", "DeathspruchInFraktion")){
					WriteSettings(1, "Weiteres", "DeathspruchInFraktion")
				}else{
					WriteSettings(0, "Weiteres", "DeathspruchInFraktion")
				}
				
				if(ReadSettings("Weiteres", "DeathspruchInFraktion"))
					DSFrak := "{00FF00}AN{FFFFFF}"
				else
					DSFrak := "{FF0000}AUS{FFFFFF}"
				SendInput {Esc}
				Sleep 100
				ShowDialog(DIALOG_STYLE_TABLIST_HEADERS, prefix . "Einstellungen -> Deathcounter", "Einstellung`tStatus`nSenden im /F`t" DSFrak "`nSenden im /Crew`t" DSCrew, "Schließen")
			}else if (getDialogLine(getDialogIndex()) == "Senden im /Crew`t" DSCrew){
				if(!ReadSettings("Weiteres", "DeathspruchInCrew")){
					WriteSettings(1, "Weiteres", "DeathspruchInCrew")
				}else{
					WriteSettings(0, "Weiteres", "DeathspruchInCrew")
				}
				
				if(ReadSettings("Weiteres", "DeathspruchInCrew"))
					DSCrew := "{00FF00}AN{FFFFFF}"
				else
					DSCrew := "{FF0000}AUS{FFFFFF}"
				SendInput {Esc}
				Sleep 100
				ShowDialog(DIALOG_STYLE_TABLIST_HEADERS, prefix . "Einstellungen -> Deathcounter", "Einstellung`tStatus`nSenden im /F`t" DSFrak "`nSenden im /Crew`t" DSCrew, "Schließen")
			}
		}else if(caption == prefix . "Einstellungen -> Killcounter"){ ;--- Killcounter
			if (getDialogLine(getDialogIndex()) == "Senden im /F`t" KSFrak){
				if(!ReadSettings("Weiteres", "KillspruchInFraktion")){
					WriteSettings(1, "Weiteres", "KillspruchInFraktion")
				}else{
					WriteSettings(0, "Weiteres", "KillspruchInFraktion")
				}
				
				if(ReadSettings("Weiteres", "KillspruchInFraktion"))
					KSFrak := "{00FF00}AN{FFFFFF}"
				else
					KSFrak := "{FF0000}AUS{FFFFFF}"
				SendInput {Esc}
				Sleep 100
				ShowDialog(DIALOG_STYLE_TABLIST_HEADERS, prefix . "Einstellungen -> Killcounter", "Einstellung`tStatus`nSenden im /F`t" KSFrak "`nSenden im /Crew`t" KSCrew, "Schließen")
			}else if (getDialogLine(getDialogIndex()) == "Senden im /Crew`t" KSCrew){
				if(!ReadSettings("Weiteres", "KillspruchInCrew")){
					WriteSettings(1, "Weiteres", "KillspruchInCrew")
				}else{
					WriteSettings(0, "Weiteres", "KillspruchInCrew")
				}
				
				if(ReadSettings("Weiteres", "KillspruchInCrew"))
					KSCrew := "{00FF00}AN{FFFFFF}"
				else
					KSCrew := "{FF0000}AUS{FFFFFF}"
				SendInput {Esc}
				Sleep 100
				ShowDialog(DIALOG_STYLE_TABLIST_HEADERS, prefix . "Einstellungen -> Killcounter", "Einstellung`tStatus`nSenden im /F`t" KSFrak "`nSenden im /Crew`t" KSCrew, "Schließen")
			}
		}else if(caption == prefix . "Truckermissionen"){
			SendInput {Esc}
			Sleep 100
			DialogLine := getDialogLine(getDialogIndex())
			RegExMatch(DialogLine, "([0-9]+)\(([0-9]+)\)(.*)", contract_)
			SendChat("/Delivery " contract_1)
			Sleep 100
			GetChatLine(1, Chat1)
			RegExMatch(Chat1, "Du hast den Auftrag ([0-9]+) \((.*)\) angenommen\.", contract_)
			SendChat("/j hat den Auftrag " contract_1 " angenommen. Ware: " contract_2)
			JobSeconds := 0
			SetTimer, JobTimer, 1000
			JobtimerEnabled := ReadSettings("Textlabels", "Jobtimer")
			if(TL_jobtime.ident == -1 && inVehicle && JobtimerEnabled != 0){
				TL_jobtime.vehicleID := getVehicleID()
				TL_jobtime.create()
			}
		}else if(caption == prefix . "Weiteres"){
			SendInput {Esc}
			Sleep 100
			if(getDialogLine(getDialogIndex()) == "prawler Tacho`t" Tacho){
				if(!ReadSettings("Weiteres", "Tacho")){
					WriteSettings(1, "Weiteres", "Tacho")
					if(isPlayerInAnyVehicle())
						changeTacho()
				}else{
					WriteSettings(0, "Weiteres", "Tacho")
					resetTacho()
				}
				
				if(ReadSettings("Weiteres", "Tacho"))
					Tacho := "{00FF00}AN{FFFFFF}"
				else
					Tacho := "{FF0000}AUS{FFFFFF}"
				ShowDialog(DIALOG_STYLE_TABLIST_HEADERS, prefix . "Weiteres", "Einstellung`tTacho`nprawler Tacho`t" Tacho "`nServer Textdraws`t" STStatus, "Schließen")
			}else if(getDialogLine(getDialogIndex()) == "Server Textdraws`t" STStatus){
				if(!ReadSettings("Weiteres", "ServerTextdraws")){
					WriteSettings(1, "Weiteres", "ServerTextdraws")
					hideSTD()
				}else{
					WriteSettings(0, "Weiteres", "ServerTextdraws")
					showSTD()
				}
				
				if(ReadSettings("Weiteres", "ServerTextdraws"))
					STStatus := "{00FF00}AN{FFFFFF}"
				else
					STStatus := "{FF0000}AUS{FFFFFF}"
				ShowDialog(DIALOG_STYLE_TABLIST_HEADERS, prefix . "Weiteres", "Einstellung`tTacho`nprawler Tacho`t" Tacho "`nServer Textdraws`t" STStatus, "Schließen")
			}
		}else{
			SendInput, {Enter}
		}
	}else{
		SendInput, {Esc}
	}
}

createTextdraws(){
	StandortEnabled := ReadSettings("Textdraws", "Standort")
	FPSEnabled := ReadSettings("Textdraws", "FPS")
	Schadensanzeige := ReadSettings("Textdraws", "Schadensanzeige")
	CheckpointTDEnabled := ReadSettings("Textdraws", "Checkpoint")
	DigiHPEnabled := ReadSettings("Textdraws", "DigiHP")
	Paydayenabled := ReadSettings("Textdraws", "PayDay")
	OnlinezeitEnabled := ReadSettings("Textdraws", "Onlinezeit")
	FischtimerEnabled := ReadSettings("Textdraws", "Fischtimer")

	changeTextDrawColors()
	changeServerTextdraws()

	TD_brandmark.text := "prawler v-.-.-"
	TD_brandmark.xpos := 583
	TD_brandmark.ypos := 437
	TD_brandmark.font := 1
	TD_brandmark.letterWidth := 0.44
	TD_brandmark.letterHeight := 1.1
	TD_brandmark.create()
 
	TD_position.text := "-, -"
	TD_position.xpos := 330
	TD_position.ypos := 2
	TD_position.font := 3
	TD_position.letterWidth := 0.45
	TD_position.letterHeight := 1.4
	TD_position.letterColor := 0xFF00D7FF
	TD_position.create()
	if(StandortEnabled == 0)
		TD_position.hide()

	TD_fps.text := "--"
	TD_fps.xpos := 130
	TD_fps.ypos := 376
	TD_fps.font := 3
	TD_fps.letterWidth := 0.4
	TD_fps.letterHeight := 0.4 * 3
	TD_fps.letterColor := 0xFFFFFFFF
	TD_fps.create()
	if(FPSEnabled == 0)
		TD_fps.hide()
	
	TD_health.text := "---"
	TD_health.xpos := 576
	TD_health.ypos := 66.5
	TD_health.font := 1
	TD_health.letterColor := 0xFFFFFFFF
	TD_health.create()
	if(DigiHPEnabled == 0)
		TD_health.hide()
	
	TD_armor.text := "---"
	TD_armor.xpos := 576
	TD_armor.ypos := 44.5
	TD_armor.font := 1
	TD_armor.letterColor := 0xFFFFFFFF
	TD_armor.create()
	if(DigiHPEnabled == 0)
		TD_armor.hide()

	TD_checkpoint.text := "~r~Checkpoint~n~~w~-m"
	TD_checkpoint.xpos := 62
	TD_checkpoint.ypos := 320
	TD_checkpoint.font := 1
	TD_checkpoint.letterWidth := 0.2
	TD_checkpoint.letterHeight := 1
	TD_checkpoint.create()
	TD_checkpoint.hide()
	
	TD_schaden.text := ""
	TD_schaden.xpos := 608
	TD_schaden.ypos := 66.5
	TD_schaden.font := 1
	TD_schaden.letterColor := 0xFF00FFFF
	TD_schaden.letterWidth := 0.4
	TD_schaden.letterHeight := 0.3 * 3
	TD_schaden.center := 0
	TD_schaden.left := 1
	TD_schaden.create()
	if(Schadensanzeige == 0)
		TD_schaden.hide()
	
	TD_payday.text := "Payday auslesen..."
	TD_payday.xpos := 552
	TD_payday.ypos := 120
	TD_payday.font := 1
	TD_payday.letterColor := 0xFFFF901E
	TD_payday.letterWidth := 0.41
	TD_payday.letterHeight := 1.1
	TD_payday.create()
	SetTimer, PDTimeCheck, 10000
	if(Paydayenabled == 0)
		TD_payday.hide()
	
	TD_online.text := "Online: --:--.--"
	TD_online.xpos := 330
	TD_online.ypos := 435
	TD_online.font := 2
	TD_online.letterColor := 0xFFFF901E
	TD_online.letterWidth := 0.40
	TD_online.letterHeight := 1.085
	TD_online.create()
	if(OnlinezeitEnabled == 0)
		TD_online.hide()
	
	TD_fisch.text := "Du kannst Fischen!"
	TD_fisch.xpos := 552
	TD_fisch.ypos := 130
	TD_fisch.font := 1
	TD_fisch.letterColor := 0xFFFF901E
	TD_fisch.letterWidth := 0.40
	TD_fisch.letterHeight := 1.085
	TD_fisch.create()
	SetTimer, FischTimeoutCheck, 10000
	if(FischtimerEnabled == 0)
		TD_fisch.hide()
	
	TD_drugs.text := "Ernte in: --:--"
	TD_drugs.xpos := 552
	TD_drugs.ypos := 140
	TD_drugs.font := 1
	TD_drugs.letterColor := 0xFFFF901E
	TD_drugs.letterWidth := 0.40
	TD_drugs.letterHeight := 1.085
	TD_drugs.create()
	TD_drugs.hide()
	
	TD_tacho.text := "Bitte warten..."
	TD_tacho.xpos := 150
	TD_tacho.ypos := 350
	TD_tacho.font := 1
	TD_tacho.letterColor := 0xFFFF901E
	TD_tacho.letterWidth := 0.25
	TD_tacho.letterHeight := 0.8
	TD_tacho.center := 0
	TD_tacho.left := 1
	TD_tacho.create()
	TD_tacho.hide()
	
	STD_reallife.ident := 17
	STD_reallife.xpos := 550
	STD_reallife.ypos := 22
	
	STD_gtacity.ident := 18
	STD_gtacity.xpos := 550
	STD_gtacity.ypos := 2
	
	STD_url.ident := 1539
	STD_url.xpos := 10
	STD_url.ypos := 430
	
	STD_time.ident := 1541
	STD_time.xpos := 565
	STD_time.ypos := 103
	
	STD_tachobox1.xpos := 147
	STD_tachobox1.ypos := 350
	
	STD_tachobox2.xpos := 148
	STD_tachobox2.ypos := 351
	
	STD_tachotext.xpos := 153
	STD_tachotext.ypos := 354
	
	TL_jobtime.text := "- {00CED1}Fahrtzeit: {FFFFFF}00:00{FFFFFF} -"
	
	;Grotti
	TL_grotti_alpha.text := "Alpha`nPreis: 250.000$"
	TL_grotti_alpha.vehicleID := 23
	TL_grotti_alpha.drawDistance := 20
	TL_grotti_alpha.create()
	
	TL_grotti_banshee.text := "Banshee`nPreis: 200.000$"
	TL_grotti_banshee.vehicleID := 14
	TL_grotti_banshee.drawDistance := 20
	TL_grotti_banshee.create()
	
	TL_grotti_buffalo.text := "Buffalo`nPreis: 225.000$"
	TL_grotti_buffalo.vehicleID := 15
	TL_grotti_buffalo.drawDistance := 20
	TL_grotti_buffalo.create()
	
	TL_grotti_infernus.text := "Infernus`nPreis: 375.000$"
	TL_grotti_infernus.vehicleID := 16
	TL_grotti_infernus.drawDistance := 20
	TL_grotti_infernus.create()
	
	TL_grotti_cheetah.text := "Cheetah`nPreis: 250.000$"
	TL_grotti_cheetah.vehicleID := 17
	TL_grotti_cheetah.drawDistance := 20
	TL_grotti_cheetah.create()
	
	TL_grotti_turismo.text := "Turismo`nPreis: 350.000$"
	TL_grotti_turismo.vehicleID := 18
	TL_grotti_turismo.drawDistance := 20
	TL_grotti_turismo.create()
	
	TL_grotti_bullet.text := "Bullet`nPreis: 225.000$"
	TL_grotti_bullet.vehicleID := 19
	TL_grotti_bullet.drawDistance := 20
	TL_grotti_bullet.create()
	
	TL_grotti_jester.text := "Jester`nPreis: 195.000$"
	TL_grotti_jester.vehicleID := 20
	TL_grotti_jester.drawDistance := 20
	TL_grotti_jester.create()
	
	TL_grotti_sultan.text := "Sultan`nPreis: 75.000$"
	TL_grotti_sultan.vehicleID := 21
	TL_grotti_sultan.drawDistance := 20
	TL_grotti_sultan.create()
	
	TL_grotti_supergt.text := "Super GT`nPreis: 250.000$"
	TL_grotti_supergt.vehicleID := 22
	TL_grotti_supergt.drawDistance := 20
	TL_grotti_supergt.create()
	
	;Coutt and Schutz
	TL_cas_pcj600.text := "PCJ-600`nPreis: 15.000$"
	TL_cas_pcj600.vehicleID := 24
	TL_cas_pcj600.drawDistance := 20
	TL_cas_pcj600.create()
	
	TL_cas_freeway.text := "Freeway`nPreis: 20.000$"
	TL_cas_freeway.vehicleID := 26
	TL_cas_freeway.drawDistance := 20
	TL_cas_freeway.create()
	
	TL_cas_sanchez.text := "Sanchez`nPreis: 17.500$"
	TL_cas_sanchez.vehicleID := 27
	TL_cas_sanchez.drawDistance := 20
	TL_cas_sanchez.create()
	
	TL_cas_wayfarer.text := "Wayfarer`nPreis: 5.000$"
	TL_cas_wayfarer.vehicleID := 32
	TL_cas_wayfarer.drawDistance := 20
	TL_cas_wayfarer.create()
	
	TL_cas_bf400.text := "BF-400`nPreis: 15.000$"
	TL_cas_bf400.vehicleID := 31
	TL_cas_bf400.drawDistance := 20
	TL_cas_bf400.create()
	
	TL_cas_nrg500.text := "NRG-500`nPreis: 150.000$"
	TL_cas_nrg500.vehicleID := 30
	TL_cas_nrg500.drawDistance := 20
	TL_cas_nrg500.create()
	
	TL_cas_bmx.text := "BMX`nPreis: 2.000$"
	TL_cas_bmx.vehicleID := 29
	TL_cas_bmx.drawDistance := 20
	TL_cas_bmx.create()
	
	TL_cas_fcr900.text := "FCR-900`nPreis: 15.000$"
	TL_cas_fcr900.vehicleID := 28
	TL_cas_fcr900.drawDistance := 20
	TL_cas_fcr900.create()
	
	icon_nsls := createBlip(56, 1761.232422, -1895.840454)
	icon_bbf := createBlip(51, 1143.765747, -1721.484009)
	icon_lspd := createBlip(30, 1544.338867, -1676.646240)
	icon_sh := createBlip(38, 1473.216309, -1799.096802)
	icon_fs := createBlip(53, 1362.528320, -1657.733765)
	icon_pns1 := createBlip(63, 487.505890, -1739.709839)
	icon_pns2 := createBlip(63, 1024.872437, -1038.916138)
	icon_pns3 := createBlip(63, 2060.691406, -1831.031128)
	icon_angelsteg_ls := createBlip(9, 383.450928, -2087.235840)
	icon_angelsteg_lv := createBlip(9, 1634.4009, 622.3037)
	icon_alhambra := createBlip(48, 1831.672729, -1684.279907)
	icon_intercars := createBlip(55, 757.338745, -1363.898682)
	icon_coutandschutz := createBlip(55, 2129.332031, -1143.435059)
	icon_cb1 := createBlip(14, 925.498108, -1367.130737)
	icon_cb2 := createBlip(14, 2113.146484, -1805.979126)
	icon_cb3 := createBlip(14, 2412.226807, -1508.508911)
	icon_cb4 := createBlip(14, 2383.017334, -1894.493652)
	icon_bs1 := createBlip(10, 1203.662598, -920.804382)
	icon_shop1 := createBlip(25, 1315.268921, -901.808472)
	icon_shop2 := createBlip(25, 1828.137085, -1843.888306)
	icon_ammu1 := createBlip(6, 1362.002563, -1275.543945)
	icon_safebox1 := createBlip(35, 834.9356,-1853.6016)
	icon_safebox2 := createBlip(35, 1297.3384,-984.3235)
	icon_safebox3 := createBlip(35, -1480.0327,324.1333)
}

initTextdraws(){
	TD_brandmark.update("prawler v~w~" version)
	if ((interior := getInteriorID()) > 0) {
		if (interior == 6)
			text := "Los Santos Police Department"
		else if (interior == 17)
			text := "Alhambra Disco"
		else if (interior == 10)
			text := "Burgershot"
		else if (interior == 9)
			text := "24/7 Shop"
		else
			text := "Interior"
	}
	else {
		pos := getPlayerPos()
		text := getZone(pos[1], pos[2], pos[3]) " - " getCity(pos[1], pos[2], pos[3])
	}
	TD_position.update(text)
	TD_fps.update(getFPS())
	TD_health.update(getPlayerHealth())
	if(getPlayerArmor() == 0){
		TD_armor.update("")
	}else{
		TD_armor.update(getPlayerArmor())
	}
	if(CheckpointTDEnabled)
		TD_checkpoint.update("~r~Checkpoint~n~~w~" Round(getDistanceToCheckpoint(), 1) "m")
	secLeft := getConnectionTicks() / 1000
	if (secLeft < 0)
		secLeft := getRunningTime()
	hour := Floor(secLeft / 3600)
	secLeft -= hour * 3600
	min := Floor(secLeft / 60)
	sec := Round(Mod(secLeft, 60))
	hour := StrLen(hour) > 1 ? hour : "0" hour
	min := StrLen(min) > 1 ? min : "0" min
	sec := StrLen(sec) > 1 ? sec : "0" sec
	TD_online.update("Online:~w~ " hour ":" min "." sec)
	FischTimeout := ReadSettings("Weiteres", "Fisch Timeout")
	if(FischTimeout > 0 && FischTimeout != "" && FischTimeout != "ERROR" && FischTimerStatus){
		TD_fisch.update("Fischen in: ~w~" FormatTime(FischTimeout))
	}
	if(DrugsPlanted == 1 && DrugsSec > 0){
		subcounter++
		if(subcounter == 2){
			DrugsSec--
			subcounter := 0
		}
		TD_drugs.update("Ernte in: ~w~" FormatTime(DrugsSec))
		if(DrugsSec == 0){
			TD_drugs.hide()
			ChatMessage("Dein Ernte ist reif! /Seed Harvest")
			ShowGameText("~g~Reife Ernte", 2500, 3)
		}
	}
	If(ReadSettings("Weiteres", "Tacho") && TachoStatus){
		STD_tachobox2.hide()
		STD_tachotext.hide()
		
		if(getVehicleEngineState(getVehicleID()))
			Motor := "~g~Motor~w~"
		else
			Motor := "~r~Motor~w~"
		
		if(getVehicleLockState(getVehicleID()))
			Locked := "~g~Tueren~w~"
		else
			Locked := "~r~Tueren~w~"
		
		if(getVehicleLightState(getVehicleID()))
			Licht := "~g~Licht~w~"
		else
			Licht := "~r~Licht~w~"
		
		updateTextDraws()
		for i, o in oTextDraws
		{
			TDText := o.TEXT
			if(InStr(TDText, "Tank"))
				break
		}
		
		getMyVehiclePassengers()
		counter := 0
		for i, o in passengers
		{
			counter++
			name := o.NAME
			if(counter == 1){
				if(name != "")
					beifahrer .= "" name ""
			}else if(counter == 2){
				if(name != "")
					beifahrer .= "," name ""
			}else if(counter == 3){
				if(name != "")
					beifahrer .= "~n~" name ""
			}else if(counter == 4){
				if(name != "")
					beifahrer .= "," name ""
			}
		}
		
		RegExMatch(TDText, "\~b\~Tank\:\~w\~ (.*)\/(.*)\~b\~ L\~n\~\~n\~\~b\~KM\-Stand\:\~w\~ (.*)\~n\~\~n\~\~b\~(.*)\:\~w\~(.*)\%\~n\~\~n\~\~w\~(.*) km\/h", params_)
		TD_tacho.update("~b~Tank:~w~ " params_1 "/" params_2 "~b~ L~n~~b~KM-Stand:~w~ " params_3 "~n~~b~" getVehicleModelName(getPlayerVehicleModelID()) ":~w~ " Round(getVehicleHealth() / 10) "%~n~~w~" Round(getVehicleSpeed()) " km/h~n~~b~Insassen~w~~n~" beifahrer "~n~~n~" Motor " " Locked " " Licht)
	}
}

deleteTextdraws(){
	TD_brandmark.delete()
	TD_position.delete()
	TD_fps.delete()
	TD_checkpoint.delete()
	TD_health.delete()
	TD_armor.delete()
	TD_schaden.delete()
	TD_payday.delete()
	TD_online.delete()
	TD_fisch.delete()
	TD_drugs.delete()
	TD_tacho.delete()
	STD_reallife.show()
	STD_gtacity.show()
	STD_url.show()
	STD_time.show()
	STD_tachobox1.show()
	STD_tachobox2.show()
	STD_tachotext.show()
	
	resetTextDrawColors()
	resetServerTextdraws()
	showSTD()
	
	clearBlip(icon_nsls)
	clearBlip(icon_bbf)
	clearBlip(icon_lspd)
	clearBlip(icon_sh)
	clearBlip(icon_fs)
	clearBlip(icon_pns1)
	clearBlip(icon_pns2)
	clearBlip(icon_pns3)
	clearBlip(icon_angelsteg_ls)
	clearBlip(icon_angelsteg_lv)
	clearBlip(icon_intercars)
	clearBlip(icon_coutandschutz)
	clearBlip(icon_cb1)
	clearBlip(icon_cb2)
	clearBlip(icon_bs1)
	clearBlip(icon_shop1)
	clearBlip(icon_ammu1)
	clearBlip(icon_shop2)
	clearBlip(icon_alhambra)
	clearBlip(icon_cb3)
	clearBlip(icon_cb4)
	
	TL_jobtime.delete()
	TL_grotti_alpha.delete()
	TL_grotti_banshee.delete()
	TL_grotti_buffalo.delete()
	TL_grotti_infernus.delete()
	TL_grotti_cheetah.delete()
	TL_grotti_turismo.delete()
	TL_grotti_bullet.delete()
	TL_grotti_jester.delete()
	TL_grotti_sultan.delete()
	TL_grotti_supergt.delete()
	
	TL_cas_pcj600.delete()
	TL_cas_freeway.delete()
	TL_cas_sanchez.delete()
	TL_cas_wayfarer.delete()
	TL_cas_bf400.delete()
	TL_cas_nrg500.delete()
	TL_cas_bmx.delete()
	TL_cas_fcr900.delete()
}

isPremium() {
	userStatus := DB_GetStatus()
	if(userStatus == "Premium" || userStatus == "Administrator") {
		return true
	} else if(userStatus == "Normal") {
		ChatMessage("Diese Funktion ist für dich nicht Verfügbar! Du besitzt keinen Premium Status")
		return false
	}
}

DB_GetStatus(){
	userStatus := _DownloadToString("https://alborzar.eu/panel/getstatus.php?auth=" authkey "&username=" getUsername())
	return userStatus
}

WriteStats(Key, Value) {
	IniWrite, %Value%, %A_AppData%\prawler\Einstellungen.ini, Weiteres, %Key%
}

ReadStats(Key) {
	IniRead, value, %A_AppData%\prawler\Einstellungen.ini, Weiteres, %Key%
	return %value%
}

ReadHotkey(Key, Value) {
	IniRead, output, %A_AppData%\prawler\ownHotkeys.ini, %Key%, %Value%
	return %output%
}

WriteHotkey(param, Key, Value) {
	IniWrite, %param%, %A_AppData%\prawler\ownHotkeys.ini, %Key%, %Value%
}

startLinie(linie = 1){
	global
	if(linie < 1 || linie > 11)
		return
	Suspend On
	actLine := -1
	if(IsPlayerInAnyVehicle()) {
		mID := getPlayerVehicleModelID()
		if(mID == 431 || mID == 437) {
			JobSeconds := 0
			sleep, 200
			actLine := linie
			inputString := ""
			linieLoops := linie - 1
			loop, %linieLoops%
			{
				inputString = %inputString%{down}
			}
			inputString = %inputString%{enter}
			SendChat("/linie")
			sleep, 250
			SendInput, %inputString%
			sleep, 100
			GetChatLine(0, Chatline)
			if(InStr(Chatline, "Leerfahrt")){
				SetTimer, JobTimer, Off
				SetChatLine(0, prefix "Du hast die Linie abgebrochen!")
				LinieAktiv := 0
				TL_jobtime.vehicleID := 0xFFFF
				TL_jobtime.delete()
			}else if(InStr(Chatline, "Nächste Haltestelle: ")){
				JobSeconds := 0
				SetTimer, JobTimer, 1000
				SetChatLine(0, prefix "Du hast eine Linie gestartet!")
				LinieAktiv := 1
				inVehicle := isPlayerInAnyVehicle()
				JobtimerEnabled := ReadSettings("Textlabels", "Jobtimer")
				if(TL_jobtime.ident == -1 && inVehicle && JobtimerEnabled != 0){
					TL_jobtime.vehicleID := getVehicleID()
					TL_jobtime.create()
				}
			}
		}else{
			ChatMessage("Du bist in keinem Bus!")
		}
	}else{
		ChatMessage("Du bist in keinem Bus!")
	}
	Suspend Off
	return
}

checkSAMPCompatibility() {
	dwSAMP := getModuleBaseAddress("samp.dll", hGTA)
	if (!dwSAMP)
		return false
	if (__READMEM(hGTA, dwSAMP, [0x1036], "UChar") != 0xD8) {
		return false
	}else{
		return true
	}
}

connectIRC(){
	SendChat("/irc join #prawler-channel")
	Sleep 100
	GetChatLine(0, Chat0)
	GetChatLine(1, Chat1)
	if(RegExMatch(Chat0, "\* " getUsername() " hat den Channel betreten\.")){
		SetChatLine(0, prefix . "Benutze /Pc [Nachricht] um zu chatten")
		SetChatLine(1, prefix . Chat1)
		SetChatLine(2, prefix . "Du hast den Chat von prawler betreten")
	}else{
		SetTimer, changeIRCNotification, 1000
	}
	connectedToChat := 1
}

leaveIRC(){
	SendChat("/irc leave #prawler-channel")
	Sleep 100
	SetChatLine(0, prefix . "Du hast den Chat von prawler verlassen")
	connectedToChat := 0
}

showFormattedStats() {
	parseStats()
}

parseStats() {
    global
    
    FormatTime, time,, dd.MM.yyyy - HH:mm:ss
    blockDialog()
    Sleep, 50
    
    SendChat("/stats")
    
    Sleep, 100
    if(GetDialogId() != 16) {
        return
    }
	
	saveOpenstats()
    
    caption := getDialogCaption()
    text := getDialogText()
    
    sleep 50
    unblockDialog()
    sleep 100
    
    larray := StrSplit(text, "`n")
    
    string := "{FFFFFF}"
    
    for i in larray {
        if (inStr(larray[i], "Respekt")) {
            RegExMatch(larray[i], "Respekt: (.*)\/(.*)", respekt)
            prozent := respekt1/respekt2 * 100
            string := string . larray[i] . " (" . round(prozent,0) . "%)" . "`n"
        } else if(inStr(larray[i], "Payday")) {
            RegExMatch(larray[i], "Payday: (.*)\/(.*) Min", pd)
            prozent2 := pd1/pd2 * 100
            string := string . larray[i] . " (" . round(prozent2,0) . "%)" . "`n"
        } else if (inStr(larray[i], "Morde")) {
            RegExMatch(larray[i], "Morde: (.*)", morde)
            RegExMatch(larray[i+1], "Gestorben: (.*)", tode)
            kd := morde1/tode1
            string := string . larray[i] . "`t`tK/D: " . round(kd,3) . "`n"
        } else if (inStr(larray[i], "Verbrechen")) {
            RegExMatch(larray[i], "Verbrechen: (.*)", verbrechen)
            RegExMatch(larray[i+2], "Knast: (.*)", knast)
            vb := verbrechen1/knast1
            string := string . larray[i] . "`tV/K: " . round(vb,3) . "`n"
        } else if (inStr(larray[i], "Bargeld")) {
            RegExMatch(larray[i], "Bargeld: (.*)\$", bargeld)
            RegExMatch(larray[i+1], "Konto: (.*)\$", konto)
            RegExMatch(larray[i+2], "Festgeld: (.*)\$", festgeld)
            gesamt := bargeld1 + konto1 + festgeld1
            string := string . larray[i] . "`tGesamt: " . round(gesamt,0) . "$`n"
        } else if (inStr(larray[i], "Spielzeit")) {
            RegExMatch(larray[i], "Spielzeit: (.*)h", sz)
            daysz := sz1/24
            string := string . larray[i] . " (" . round(daysz,0) . " Tage)" . "`n"
        } else if (inStr(larray[i], "Erste-Hilfe") || inStr(larray[i], "Benzin")) {
            string := string . "{FFFF00}" . larray[i] . "{FFFFFF}`n"
        } else  {
            string := string . larray[i] . "`n"
        }
    }
	
	if(DB_GetStatus() != "Normal")
		string .= "`n`n{FFBF00}Prawler Premium Status"
   
    ShowDialog(0, "{80FF00}" caption " - " time, string, "Schließen", "")
	Sleep 100
}

restartOverlay(){
	deleteTextdraws()
	createTextdraws()
}

SendOwnHotkey(ownhotkey) {
	if(!ReadHotkey("Hotkey_" ownhotkey, "Active"))
		return
	if(ReadHotkey("Hotkey_" ownhotkey, "Text") == "" || ReadHotkey("Hotkey_" ownhotkey, "Text") == "ERROR")
		return
	If(IsChaTOpen() || IsDialogOpen()){
		key := ReadHotkey("Hotkey_" ownhotkey, "Key")
		SendInput, %key%
		return
	}
	SendHotkey(ReadHotkey("Hotkey_" ownhotkey, "Text"))
}

SendHotkey(line, local := false) {
	line := StrReplace(line, "[username]", getUsername())
	line := StrReplace(line, "[id]", getId())
	line := StrReplace(line, "[ping]", getPlayerPingById(getId()))
	line := StrReplace(line, "[fps]", getFPS())
	line := StrReplace(line, "[zone]", getPlayerZone())
	line := StrReplace(line, "[city]", getPlayerCity())
	line := StrReplace(line, "[health]", getPlayerHealth())
	line := StrReplace(line, "[armour]", getPlayerArmor())
	line := StrReplace(line, "[money]", FormatNumber(getPlayerMoney()))
	line := StrReplace(line, "[skinid]", getPlayerSkinId())
	line := StrReplace(line, "[weaponid]", getPlayerWeaponId(getID(), 1))
	line := StrReplace(line, "[weaponname]", getPlayerWeaponName())
	line := StrReplace(line, "[freezed]", (IsPlayerFreezed() ? "ja" : "nein"))
	line := StrReplace(line, "[vhealth]", getVehicleHealth())
	line := StrReplace(line, "[vmodelid]", getVehicleModelId(getVehicleID()))
	line := StrReplace(line, "[vmodel]", getVehicleModelName(getVehicleID()))
	line := StrReplace(line, "[vspeed]", round(getVehicleSpeed()))
	line := StrReplace(line, "[fishtime]", formatTime(ReadSettings("Weiteres", "Fisch Timeout")))
	line := StrReplace(line, "[fraction]", ReadSettings("Weiteres", "Fraktion"))
	line := StrReplace(line, "[fractionrank]", ReadSettings("Weiteres", "Rang"))
	line := StrReplace(line, "[kills]", ReadSettings("Weiteres", "Kills"))
	line := StrReplace(line, "[job]", ReadSettings("Weiteres", "Beruf"))
	line := StrReplace(line, "[bankmoney]", ReadSettings("Weiteres", "Bank"))
	line := StrReplace(line, "[fixmoney]", ReadSettings("Weiteres", "Festgeld"))
	line := StrReplace(line, "[crew]", ReadSettings("Weiteres", "Crew"))
	line := StrReplace(line, "[crewrank]", ReadSettings("Weiteres", "Crew Rang"))
	line := StrReplace(line, "[wdealerrank]", ReadSettings("Weiteres", "WaffendealerRang"))
	line := StrReplace(line, "[fishmoney]", ReadSettings("Weiteres", "Fisch Gesamtverdienst"))
	line := StrReplace(line, "[number]", ReadSettings("Weiteres", "Telefonnummer"))
	if (RegExMatch(line, "(.*)\[sleep (\d+)\](.*)", line_)) {
		if (line_1 != "")
			SendHotkey(line_1, false)
		Sleep, %line_2%
		if (line_3 != "")
			SendHotkey(line_3, false)
	}else{
		if(local)
			ChatMessage(line)
		else
			SendChat(line)
	}
}

changeTacho(){
	STD_tachobox2.hide()
	STD_tachotext.hide()
	TD_tacho.show()
}

resetTacho(){
	STD_tachobox2.show()
	STD_tachotext.show()
	TD_tacho.hide()
}

hideSTD(){
	STD_reallife.hide()
	STD_gtacity.hide()
	STD_url.hide()
}

showSTD(){
	STD_reallife.show()
	STD_gtacity.show()
	STD_url.show()
}