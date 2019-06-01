sendDialogResponse(dialogID, buttonID, listIndex := 0xFFFF, inputResponse := "") {
if ((inputLen := StrLen(inputResponse)) > 128 || !checkHandles())
return false
VarSetCapacity(buf, (bufLen := 0x17 + inputLen), 0)
NumPut(48 + inputLen * 8, buf, 0, "UInt")
NumPut(2048, buf, 4, "UInt")
NumPut(pMemory + 1024 + 0x11, buf, 0xC, "UInt")
NumPut(1, buf, 0x10, "UChar")
NumPut(dialogID, buf, 0x11, "UShort")
NumPut(buttonID, buf, 0x13, "UChar")
NumPut(listIndex, buf, 0x14, "UShort")
NumPut(inputLen, buf, 0x16, "UChar")
if (inputLen > 0)
StrPut(inputResponse, &buf + 0x17, inputLen, "")
if (!__WRITERAW(hGTA, pMemory + 1024, &buf, bufLen))
return false
return __CALL(hGTA, dwSAMP + 0x30B30, [["i", __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_RAKCLIENT])], ["i", dwSAMP + 0xD7FA8], ["i", pMemory + 1024], ["i", 1]
, ["i", 9], ["i", 0], ["i", 0]], false, true)
}
closeDialog() {
return checkHandles() && __CALL(hGTA, dwSAMP + 0x6B210, [["i", __DWORD(hGTA, dwSAMP, [SAMP_DIALOG_INFO_PTR])]], false, true)
}
isDialogOpen() {
return checkHandles() && __DWORD(hGTA, dwSAMP, [SAMP_DIALOG_INFO_PTR, 0x28])
}
getDialogTextPos() {
return !checkHandles() ? false : [__DWORD(hGTA, dwSAMP, [SAMP_DIALOG_INFO_PTR, 0x4]), __DWORD(hGTA, dwSAMP, [SAMP_DIALOG_INFO_PTR, 0x8])]
}
getDialogStyle() {
return !checkHandles() ? false : __DWORD(hGTA, dwSAMP, [SAMP_DIALOG_INFO_PTR, 0x2C])
}
getDialogID() {
return !checkHandles() ? false : __DWORD(hGTA, dwSAMP, [SAMP_DIALOG_INFO_PTR, 0x30])
}
setDialogID(id) {
return checkHandles() && __WRITEMEM(hGTA, dwSAMP, [SAMP_DIALOG_INFO_PTR, 0x30], id, "UInt")
}
getDialogIndex() {
return !checkHandles() ? false : __DWORD(hGTA, dwSAMP, [0x12E350, 0x143]) + 1
}
getDialogCaption() {
return !checkHandles() ? "" : __READSTRING(hGTA, dwSAMP, [SAMP_DIALOG_INFO_PTR, 0x40], 64)
}
getDialogText() {
return !checkHandles() ? "" : ((dialogText := __READSTRING(hGTA, (dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_DIALOG_INFO_PTR, 0x34])), [0x0], 4096)) == "" ? __READSTRING(hGTA, dwAddress, [0x0], getDialogTextSize(dwAddress)) : dialogText)
}
getDialogTextSize(dwAddress) {
Loop, 4096 {
if (!__READBYTE(hGTA, dwAddress + (i := A_Index - 1)))
break
}
return i
}
getDialogLine(index) {
return index > (lines := getDialogLineCount()).Length() ? "" : lines[getDialogStyle() == DIALOG_STYLE_TABLIST_HEADERS ? ++index : index]
}
getDialogLineCount() {
return (text := getDialogText()) == "" ? -1 : StrSplit(text, "`n")
}
getDialogSelectedUI() {
if (!checkHandles() || !(uiAddress := __DWORD(hGTA, (dwAddress := __DWORD(hGTA, dwSAMP, [0x21A190])), [0xF])))
return 0
dwAddress := __DWORD(hGTA, dwAddress, [0x15E])
Loop, 3 {
if (__DWORD(hGTA, dwAddress, [(A_Index - 1) * 4]) == uiAddress)
return A_Index
}
return 0
}
showDialog(style, caption, text, button1, button2 := "", id := 1) {
if (id < 0 || id > 32767 || style < 0 || style > 5 || StrLen(caption) > 64 || StrLen(text) > 4095 || StrLen(button1) > 10 || StrLen(button2) > 10 || !checkHandles())
return false
return __CALL(hGTA, dwSAMP + 0x6B9C0, [["i", __DWORD(hGTA, dwSAMP, [SAMP_DIALOG_INFO_PTR])], ["i", id], ["i", style], ["s", caption], ["s", text], ["s", button1], ["s", button2], ["i", 0]], false, true)
}
pressDialogButton(button) {
return !checkHandles() || button < 0 || button > 1 ? false : __CALL(hGTA, dwSAMP + 0x6C040, [["i", __DWORD(hGTA, dwSAMP, [SAMP_DIALOG_INFO_PTR])], ["i", button]], false, true)
}
/*
blockDialog() {
return NOP(hGTA, dwSAMP + 0x6C014, 7)
}
unblockDialog() {
return checkHandles() && __WRITEBYTES(hGTA, dwSAMP + 0x6C014, [0xC7, 0x46, 0x28, 0x1, 0x0, 0x0, 0x0])
}
*/
blockDialog() {
    if (!checkHandles()) {
        ErrorLevel := ERROR_INVALID_HANDLE
        return false
    }
    VarSetCapacity(injectBytecode, 7, 0)
    Loop, 7 {
        NumPut(0x90, injectBytecode, A_Index - 1, "UChar")
    }
    return writeRaw(hGTA, dwSAMP + 0x6C014, &injectBytecode, 7)
}
unblockDialog() {
    if (!checkHandles()) {
        ErrorLevel := ERROR_INVALID_HANDLE
        return false
    }
    bytecodes := [0xC7, 0x46, 0x28, 0x1, 0x0, 0x0, 0x0]
    VarSetCapacity(injectBytecode, 7, 0)
    for i, o in bytecodes
        NumPut(o, injectBytecode, i - 1, "UChar")
    return writeRaw(hGTA, dwSAMP + 0x6C014, &injectBytecode, 7)
}
setVehicleLightStatus(frontLeft, frontRight, rearBoth) {
return !checkHandles() || !isPlayerDriver() || getVehicleType() != 1 ? false : __WRITEMEM(hGTA, GTA_VEHICLE_PTR, [0x0, 0x5B0]
, (~frontLeft & 1) + ((~frontRight & 1) << 2) + ((~rearBoth & 1) << 6), "UChar")
}
isChatOpen() {
return checkHandles() && __READMEM(hGTA, dwSAMP, [SAMP_INPUT_INFO_PTR, 0x8, 0x4], "UChar")
}
isInMenu() {
return checkHandles() && __READMEM(hGTA, 0xB6B964, [0x0], "UChar")
}
isScoreboardOpen() {
return checkHandles() && __READMEM(hGTA, dwSAMP, [SAMP_SCOREBOARD_INFO_PTR, 0x0], "UChar")
}
sendChat(text) {
return checkHandles() && __CALL(hGTA, dwSAMP + (SubStr(text, 1, 1) == "/" ? FUNC_SAMP_SEND_CMD : FUNC_SAMP_SEND_SAY), [["s", text]], false)
}
addChatMessage(text, color := 0xFFFFFFFF, timestamp := true) {
return checkHandles() && __CALL(hGTA, dwSAMP + 0x64010, [["i", __DWORD(hGTA, dwSAMP, [SAMP_CHAT_INFO_PTR])], ["i", timestamp ? 4 : 2], ["s", text], ["i", 0], ["i", color], ["i", 0]], false, true)
}
addChatMessages(text, color := 0xFFFFFFFF, timestamp := true, count := 1) {
if (StrLen(text) > 128 || !checkHandles())
return false
dwFunc := dwSAMP + 0x64010
dwLen := 46
VarSetCapacity(injectData, dwLen, 0)
NumPut(0xB9, injectData, 0, "UChar")
NumPut(count, injectData, 1, "UInt")
NumPut(0x51, injectData, 5, "UChar")
NumPut(0x68, injectData, 6, "UChar")
NumPut(0, injectData, 7, "UInt")
NumPut(0x68, injectData, 11, "UChar")
NumPut(color, injectData, 12, "UInt")
NumPut(0x68, injectData, 16, "UChar")
NumPut(0, injectData, 17, "UInt")
__WRITESTRING(hGTA, pMemory, [0x0], text)
NumPut(0x68, injectData, 21, "UChar")
NumPut(pMemory, injectData, 22, "UInt")
NumPut(0x68, injectData, 26, "UChar")
NumPut(timestamp ? 4 : 2, injectData, 27, "UInt")
NumPut(0xB9, injectData, 31, "UChar")
NumPut(__DWORD(hGTA, dwSAMP, [SAMP_CHAT_INFO_PTR]), injectData, 32, "UInt")
NumPut(0xE8, injectData, 36, "UChar")
offset := dwFunc - (pInjectFunc + 41)
NumPut(offset, injectData, 37, "Int")
NumPut(0x59, injectData, 41, "UChar")
NumPut(0x49, injectData, 42, "UChar")
NumPut(0x75, injectData, 43, "UChar")
NumPut(0xD8, injectData, 44, "UChar")
NumPut(0xC3, injectData, 45, "UChar")
__WRITERAW(hGTA, pInjectFunc, &injectData, dwLen)
if (ErrorLevel)
return false
hThread := createRemoteThread(hGTA, 0, 0, pInjectFunc, 0, 0, 0)
if (ErrorLevel)
return false
waitForSingleObject(hThread, 0xFFFFFFFF)
closeProcess(hThread)
return true
}
getPageSize() {
return !checkHandles() ? false : __READMEM(hGTA, dwSAMP, [SAMP_CHAT_INFO_PTR, 0x0], "UChar")
}
setPageSize(pageSize) {
return checkHandles() && __CALL(hGTA, dwSAMP + 0x636D0, [["i", __DWORD(hGTA, dwSAMP, [SAMP_CHAT_INFO_PTR])], ["i", pageSize]], false, true)
}
getMoney() {
return !checkHandles() ? "" : __READMEM(hGTA, 0xB7CE50, [0x0], "Int")
}
getPlayerAnim() {
return !checkHandles() ? false : __READMEM(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, SAMP_LOCALPLAYER, 0x4], "Short")
}
getPing() {
if (!checkHandles() || !__CALL(hGTA, dwSAMP + 0x8A10, [["i", __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR])]], false, true))
return 0
return  __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, 0x26])
}
getScore() {
return !checkHandles() ? "" : __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, 0x2A])
}
getVehicleIDByNumberPlate(numberPlate) {
if (!checkHandles() || (len := StrLen(numberPlate)) <= 0 || len > 32 || !(dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_VEHICLE])))
return false
count := __DWORD(hGTA, dwAddress, [0x0])
Loop % SAMP_MAX_VEHICLES {
if (!__DWORD(hGTA, dwAddress, [(A_Index - 1) * 4 + 0x3074]))
continue
if (numberPlate == __READSTRING(hGTA, dwAddress, [(A_Index - 1) * 4 + 0x1134, 0x93], len))
return A_Index - 1
if (--count <= 0)
break
}
return false
}
getVehicleNumberPlates() {
if (!checkHandles() || !(dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_VEHICLE])))
return ""
vehicles := []
count := __DWORD(hGTA, dwAddress, [0x0])
Loop % SAMP_MAX_VEHICLES {
if (!__DWORD(hGTA, dwAddress, [(A_Index - 1) * 4 + 0x3074]))
continue
vehicles[A_Index - 1] := __READSTRING(hGTA, dwAddress, [(A_Index - 1) * 4 + 0x1134, 0x93], 32)
if (--count <= 0)
break
}
return vehicles
}
getVehicleIDsByNumberPlate(numberPlate) {
if (!checkHandles() || (len := StrLen(numberPlate)) <= 0 || len > 32 || !(dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_VEHICLE])))
return ""
vehicles := []
count := __DWORD(hGTA, dwAddress, [0x0])
Loop % SAMP_MAX_VEHICLES {
if (!__DWORD(hGTA, dwAddress, [(A_Index - 1) * 4 + 0x3074]))
continue
if (InStr(__READSTRING(hGTA, dwAddress, [(A_Index - 1) * 4 + 0x1134, 0x93], 32), numberPlate))
vehicles.Push(A_Index - 1)
if (--count <= 0)
break
}
return vehicles
}
getVehiclePosition(vehicleID) {
return !checkHandles() || vehicleID < 1 || vehicleID > SAMP_MAX_VEHICLES ? "" : [__READMEM(hGTA, (dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_VEHICLE, vehicleID * 4 + 0x1134, 0x40, 0x14])), [0x30], "Float"), __READMEM(hGTA, dwAddress, [0x34], "Float"), __READMEM(hGTA, dwAddress, [0x38], "Float")]
}
getVehicleNumberPlate(vehicleID) {
return !checkHandles() || vehicleID < 1 || vehicleID > SAMP_MAX_VEHICLES ? "" : __READSTRING(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_VEHICLE, vehicleID * 4 + 0x1134, 0x93], 32)
}
getVehicleID() {
if (!checkHandles() || !isPlayerInAnyVehicle())
return false
return __READMEM(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, SAMP_LOCALPLAYER, isPlayerDriver() ? 0xAA : 0x5C], "UShort")
}
getPlayerScore(playerID) {
return playerID < 0 || playerID >= SAMP_MAX_PLAYERS || !checkHandles() ? "" : __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, SAMP_REMOTEPLAYERS + playerID * 4, 0x24])
}
isPlayerUsingCell(playerID) {
return playerID < 0 || playerID >= SAMP_MAX_PLAYERS || !checkHandles() ? "" : __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, SAMP_REMOTEPLAYERS + playerID * 4, 0x0, 0x0])
}
isPlayerUrinating(playerID) {
return playerID < 0 || playerID >= SAMP_MAX_PLAYERS || !checkHandles() ? "" : __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, SAMP_REMOTEPLAYERS + playerID * 4, 0x0, 0x2B6])
}
isPlayerDancing(playerID) {
return playerID < 0 || playerID >= SAMP_MAX_PLAYERS || !checkHandles() ? "" : __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, SAMP_REMOTEPLAYERS + playerID * 4, 0x0, 0x28A])
}
getPlayerDanceStyle(playerID) {
return playerID < 0 || playerID >= SAMP_MAX_PLAYERS || !checkHandles() ? "" : __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, SAMP_REMOTEPLAYERS + playerID * 4, 0x0, 0x28E])
}
getPlayerDanceMove(playerID) {
return playerID < 0 || playerID >= SAMP_MAX_PLAYERS || !checkHandles() ? "" : __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, SAMP_REMOTEPLAYERS + playerID * 4, 0x0, 0x292])
}
getPlayerDrunkLevel(playerID) {
return playerID < 0 || playerID >= SAMP_MAX_PLAYERS || !checkHandles() ? "" : __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, SAMP_REMOTEPLAYERS + playerID * 4, 0x0, 0x281])
}
getPlayerSpecialAction(playerID) {
return playerID < 0 || playerID >= SAMP_MAX_PLAYERS || !checkHandles() ? "" : __READMEM(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, SAMP_REMOTEPLAYERS + playerID * 4, 0x0, 0xBB], "UChar")
}
getPlayerVehicleID(playerID) {
return playerID < 0 || playerID >= SAMP_MAX_PLAYERS || !checkHandles() ? "" : __READMEM(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, SAMP_REMOTEPLAYERS + playerID * 4, 0x0, 0xAD], "UShort")
}
getPlayerVehiclePos(playerID) {
return playerID < 0 || playerID >= SAMP_MAX_PLAYERS || !checkHandles() ? "" : [__READMEM(hGTA, (dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, SAMP_REMOTEPLAYERS + playerID * 4, 0x0])), [0x93], "Float"), __READMEM(hGTA, dwAddress, [0x97], "Float"), __READMEM(hGTA, dwAddress, [0x9B], "Float")]
}
getPlayerTeamID(playerID) {
return playerID < 0 || playerID >= SAMP_MAX_PLAYERS || !checkHandles() ? "" : __READMEM(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, SAMP_REMOTEPLAYERS + playerID * 4, 0x0, 0x8], "UChar")
}
getPlayerState(playerID) {
return playerID < 0 || playerID >= SAMP_MAX_PLAYERS || !checkHandles() ? "" : __READMEM(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, SAMP_REMOTEPLAYERS + playerID * 4, 0x0, 0x9], "UChar")
}
getPlayerSeatID(playerID) {
return playerID < 0 || playerID >= SAMP_MAX_PLAYERS || !checkHandles() ? "" : __READMEM(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, SAMP_REMOTEPLAYERS + playerID * 4, 0x0, 0xA], "UChar")
}
getPlayerPing(playerID) {
return playerID < 0 || playerID >= SAMP_MAX_PLAYERS || !checkHandles() ? "" : __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, SAMP_REMOTEPLAYERS + playerID * 4, 0x28])
}
isNPC(playerID) {
return playerID < 0 || playerID >= SAMP_MAX_PLAYERS || !checkHandles() ? "" : __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, SAMP_REMOTEPLAYERS + playerID * 4, 0x4])
}
getAFKState(playerID) {
return !checkHandles() || playerID < 0 || playerID >= SAMP_MAX_PLAYERS ? "" : __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, SAMP_REMOTEPLAYERS + playerID * 4, 0x0, 0x1D1])
}
getPlayerWeaponID(playerID, slot) {
return (slot < 0 || slot > 12 || playerID < 0 || playerID >= SAMP_MAX_PLAYERS || !checkHandles()) ? "" : __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, SAMP_REMOTEPLAYERS + playerID * 4, 0x0, 0x0, 0x2A4, 0x5A0 + slot * 0x1C])
}
getPlayerAmmo(playerID, slot) {
return (slot < 0 || slot > 12 || playerID < 0 || playerID >= SAMP_MAX_PLAYERS || !checkHandles()) ? "" : __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, SAMP_REMOTEPLAYERS + playerID * 4, 0x0, 0x0, 0x2A4, 0x5AC + slot * 0x1C])
}
getPlayerColor(playerID) {
return !checkHandles() ? -1 : (((color := __DWORD(hGTA, dwSAMP, [0x216378 + playerID * 4])) >> 8) & 0xFF) + ((color >> 16) & 0xFF) * 0x100 + ((color >> 24) & 0xFF) * 0x10000
}
getPlayerColor1(playerID) {
return !checkHandles() ? "" : __DWORD(hGTA, dwSAMP, [0x103078 + playerID * 4])
}
getChatBubbleText(playerID) {
return playerID < 0 || playerID > SAMP_MAX_PLAYERS - 1 || !checkHandles() ? "" : __READSTRING(hGTA, dwSAMP, [0x21A0DC, playerID * 0x118 + 0x4], 256)
}
isChatBubbleShown(playerID) {
return playerID < 0 || playerID > SAMP_MAX_PLAYERS - 1 || !checkHandles() ? "" : __READMEM(hGTA, dwSAMP, [0x21A0DC, playerID * 0x118], "Int")
}
getPlayerID(playerName, exact := 0) {
	if (!updatePlayers())
		return ""
	for i, o in oPlayers {
		if (exact) {
			if (o = playerName)
				return i
		}
		else {
			if (InStr(o, playerName) == 1)
				return i
		}
	}
	return ""
}
getPlayerName(playerID) {
if (playerID < 0 || playerID >= SAMP_MAX_PLAYERS || !checkHandles() || getPlayerScore(playerID) == "")
return ""
if (__DWORD(hGTA, (dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, SAMP_REMOTEPLAYERS + playerID * 4])), [0x1C]) > 15)
return __READSTRING(hGTA, dwAddress, [0xC, 0x0], 25)
return __READSTRING(hGTA, dwAddress, [0xC], 16)
}
getUsername() {
return !checkHandles() ? "" : __READSTRING(hGTA, dwSAMP, [0x219A6F], 25)
}
getArmor() {
return !checkHandles() ? "" : __READMEM(hGTA, GTA_CPED_PTR, [0x0, 0x548], "Float")
}
getID() {
return !checkHandles() ? -1 : __READMEM(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, 0x4], "UShort")
}
getChatlogPath() {
return !checkHandles() ? "" : __READSTRING(hGTA, dwSAMP, [SAMP_CHAT_INFO_PTR, 0x11], 256)
}
showGameText(text, time, style) {
return checkHandles() && __CALL(hGTA, dwSAMP + 0x9C2C0, [["s", text], ["i", time], ["i", style]], false)
}
getGameText_() {
return !checkHandles() ? "" : __READSTRING(hGTA, dwSAMP, [0x13BEFC], 128)
}
getGameTextByStyle(style) {
return !checkHandles() ? "" : __READSTRING(hGTA, 0xBAACC0, [style * 0x80], 128)
}
toggleChatShown(shown := true) {
return !checkHandles() ? -1 : __WRITEMEM(hGTA, dwSAMP, [0x64230], shown ? 0x56 : 0xC3, "UChar")
}
isChatShown() {
return checkHandles() && __READMEM(hGTA, dwSAMP, [0x64230], "UChar") == 0x56
}
isCheckpointSet() {
return checkHandles() && __READMEM(hGTA, dwSAMP, [SAMP_MISC_INFO_PTR, 0x24], "UChar")
}
toggleCheckpoint(toggle := true) {
return checkHandles() && __WRITEMEM(hGTA, dwSAMP, [SAMP_MISC_INFO_PTR, 0x24], toggle ? 1 : 0 ,"UChar")
}
getCheckpointSize() {
return !checkHandles() ? false : __READMEM(hGTA, dwSAMP, [SAMP_MISC_INFO_PTR, 0x18], "Float")
}
getCheckpointPos() {
if (!checkhandles())
return ""
dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_MISC_INFO_PTR])
for i, o in [0xC, 0x10, 0x14]
pos%i% := __READMEM(hGTA, dwAddress, [o], "Float")
return [pos1, pos2, pos3]
}
getDistanceToCheckpoint(){
    checkpointpos := getCheckpointPos()
    playerpos := getCoordinates()
    return getDistance(checkpointpos, playerpos)
}
setCheckpointPos(cpPos) {
if (!checkhandles())
return ""
dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_MISC_INFO_PTR])
for i, o in [0xC, 0x10, 0x14]
pos%i% := __WRITEMEM(hGTA, dwAddress, [o], cpPos[A_Index], "Float")
return [pos1, pos2, pos3]
}
setCheckpoint(fX, fY, fZ, fSize := 3.0) {
if (!checkHandles())
return false
VarSetCapacity(buf, 16, 0)
NumPut(fX, buf, 0, "Float")
NumPut(fY, buf, 4, "Float")
NumPut(fZ, buf, 8, "Float")
NumPut(fSize, buf, 12, "Float")
if (!__WRITERAW(hGTA, pMemory + 20, &buf, 16))
return false
return __CALL(hGTA, dwSAMP + 0x9D340, [["i", __DWORD(hGTA, dwSAMP, [SAMP_MISC_INFO_PTR])], ["i", pMemory + 20], ["i", pMemory + 32]], false, true) && toggleCheckpoint()
}
isRaceCheckpointSet() {
return checkHandles() && __READMEM(hGTA, dwSAMP, [SAMP_MISC_INFO_PTR, 0x49], "UChar")
}
toggleRaceCheckpoint(toggle := true) {
return checkHandles() && __WRITEMEM(hGTA, dwSAMP, [SAMP_MISC_INFO_PTR, 0x49], toggle ? 1 : 0 ,"UChar")
}
getRaceCheckpointType() {
return !checkHandles() ? false : __READMEM(hGTA, dwSAMP, [SAMP_MISC_INFO_PTR, 0x48], "UChar")
}
getRaceCheckpointSize() {
return !checkHandles() ? false : __READMEM(hGTA, dwSAMP, [SAMP_MISC_INFO_PTR, 0x44], "Float")
}
getRaceCheckpointPos() {
if (!checkhandles())
return ""
dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_MISC_INFO_PTR])
Loop, 6
pos%A_Index% := __READMEM(hGTA, dwAddress, [0x2C + (A_Index - 1) * 4], "Float")
return [pos1, pos2, pos3, pos4, pos5, pos6]
}
setRaceCheckpoint(type, fX, fY, fZ, fXNext, fYNext, fZNext, fSize := 3.0) {
if (!checkHandles())
return false
VarSetCapacity(buf, 28, 0)
NumPut(fX, buf, 0, "Float")
NumPut(fY, buf, 4, "Float")
NumPut(fZ, buf, 8, "Float")
NumPut(fXNext, buf, 12, "Float")
NumPut(fYNext, buf, 16, "Float")
NumPut(fZNext, buf, 20, "Float")
if (!__WRITERAW(hGTA, pMemory + 24, &buf, 28))
return false
return __CALL(hGTA, dwSAMP + 0x9D660, [["i", __DWORD(hGTA, dwSAMP, [SAMP_MISC_INFO_PTR])], ["i", type], ["i", pMemory + 24], ["i", pMemory + 36]
, ["f", fSize]], false, true) && toggleRaceCheckpoint()
}
getLastSentMsg() {
return !checkHandles() ? "" : __READSTRING(hGTA, dwSAMP, [SAMP_INPUT_INFO_PTR, 0x1565], 128)
}
setLastSentMsg(text) {
return checkHandles() && __WRITESTRING(hGTA, dwSAMP, [SAMP_INPUT_INFO_PTR, 0x1565], text)
}
pushSentMsg(text) {
return checkHandles() && __CALL(hGTA, dwSAMP + 0x65930, [["i", __DWORD(hGTA, dwSAMP, [SAMP_INPUT_INFO_PTR])], ["s", text]], false, true)
}
patchWanteds() {
return !checkHandles() ? false : __WRITEBYTES(hGTA, dwSAMP + 0x9C9C0, [0xC2, 0x04, 0x0, 0x0])
}
unpatchWanteds() {
return !checkHandles() ? false : __WRITEBYTES(hGTA, dwSAMP + 0x9C9C0, [0x8A, 0x44, 0x24,04])
}
checkSendCMDNOP() {
return checkHandles() && NOP(hGTA, dwSAMP + 0x65DF8, 5) && NOP(hGTA, dwSAMP + 0x65E45, 5)
}
patchSendSay(toggle := true) {
return !checkHandles() ? false : (toggle ? __WRITEBYTES(hGTA, dwSAMP + 0x64915, [0xC3, 0x90]) : __WRITEBYTES(hGTA, dwSAMP + 0x64915, [0x85, 0xC0]))
}
unpatchSendCMD() {
return !checkHandles() ? false : __WRITEBYTES(hGTA, dwSAMP + 0x65DF8, [0xE8, 0x63, 0xFE, 0xFF, 0xFF]) && __WRITEBYTES(hGTA, dwSAMP + 0x65E45, [0xE8, 0x16, 0xFE, 0xFF, 0xFF])
}
getChatRenderMode() {
return !checkHandles() ? -1 : __READMEM(hGTA, [SAMP_CHAT_INFO_PTR, 0x8], "UChar")
}
toggleScoreboard(toggle) {
return checkHandles() && (toggle ? __CALL(hGTA, dwSAMP + 0x6AD30, [["i", __DWORD(hGTA, dwSAMP, [SAMP_SCOREBOARD_INFO_PTR])]], false, true) : __CALL(hGTA, dwSAMP + 0x6A320, [["i", __DWORD(hGTA, dwSAMP, [SAMP_SCOREBOARD_INFO_PTR])], ["i", 1]], false, true))
}
toggleChatInput(toggle) {
return checkHandles() && __CALL(hGTA, dwSAMP + (toggle ? 0x657E0 : 0x658E0), [["i", __DWORD(hGTA, dwSAMP, [SAMP_INPUT_INFO_PTR])]], false, true)
}
setGameState(state) {
return !checkHandles() ? false : __WRITEMEM(hGTA, dwSAMP, [SAMP_INFO_PTR, 0x3BD], state)
}
getGameState() {
return !checkHandles() ? false : __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, 0x3BD])
}
isLineOfSightClear(fX1, fY1, fZ1, fX2, fY2, fZ2) {
if (!checkHandles())
return false
__WRITEMEM(hGTA, pMemory, [0x0], fX1, "Float")
__WRITEMEM(hGTA, pMemory + 4, [0x0], fY1, "Float")
__WRITEMEM(hGTA, pMemory + 8, [0x0], fZ1, "Float")
__WRITEMEM(hGTA, pMemory + 12, [0x0], fX2, "Float")
__WRITEMEM(hGTA, pMemory + 16, [0x0], fY2, "Float")
__WRITEMEM(hGTA, pMemory + 20, [0x0], fZ2, "Float")
return __CALL(hGTA, 0x56A490, [["i", pMemory], ["i", pMemory + 12], ["i", 1], ["i", 0], ["i", 0], ["i", 1], ["i", 0], ["i", 0], ["i", 0]], true, false, true)
}
takeScreenshot() {
return checkHandles() && __WRITEMEM(hGTA, dwSAMP, [0x119CBC], 1, "UChar")
}
getPlayerFightingStyle() {
return !checkHandles() ? false : __READMEM(hGTA, GTA_CPED_PTR, [0x0, 0x72D], "UChar")
}
getMaxPlayerID() {
return !checkHandles() ? false : __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, 0x0])
}
getWeatherID() {
return !checkHandles() ? "" : __READMEM(hGTA, 0xC81320, [0x0], "UShort")
}
getAmmo(slot) {
return (slot < 0 || slot > 12 || !checkHandles()) ? "" : __DWORD(hGTA, GTA_CPED_PTR, [0x0, 0x5AC + slot * 0x1C])
}
getWeaponID(slot) {
return (slot < 0 || slot > 12 || !checkHandles()) ? "" : __DWORD(hGTA, GTA_CPED_PTR, [0x0, 0x5A0 + slot * 0x1C])
}
getActiveWeaponSlot() {
return !checkHandles() ? -1 : __READMEM(hGTA, 0xB7CDBC, [0x0], "UChar")
}
cameraRestoreWithJumpcut() {
return checkHandles() && __CALL(hGTA, 0x50BAB0, [["i", 0xB6F028]], false, true)
}
calcAngle(xActor, yActor, xPoint, yPoint) {
fX := xActor - xPoint
fY := yActor - yPoint
return atan2(fX, fY)
}
atan2(x, y) {
return DllCall("msvcrt\atan2", "Double", y, "Double", x, "CDECL Double")
}
getPlayerZAngle() {
return !checkHandles() ? "" : __READMEM(hGTA, 0xB6F5F0, [0x0, 0x558], "Float")
}
setCameraPosX(fAngle) {
return checkHandles() && __WRITEMEM(hGTA, 0xB6F258, [0x0], "Float")
}
isPlayerFrozen() {
return checkHandles() && __READMEM(hGTA, GTA_CPED_PTR, [0x0, 0x42], "UChar")
}
isPlayerInRangeOfPoint(fX, fY, fZ, r) {
return checkHandles() && getDistance(getPlayerPos(), [fX, fY, fZ]) <= r
}
getMapQuadrant(pos) {
return pos[1] <= 0 ? (pos[2] <= 0 ? 3 : 1) : (pos[2] <= 0 ? 4 : 2)
}
getWeaponIDByName(weaponName) {
for i, o in oWeaponNames {
if (o = weaponName)
return i - 1
}
return -1
}
getWeaponName(weaponID) {
return weaponID < 0 || weaponID > oWeaponNames.MaxIndex() ? "" : oWeaponNames[weaponID + 1]
}
getPlayerPed(playerID) {
return playerID < 0 || playerID >= SAMP_MAX_PLAYERS || !checkHandles() ? 0x0 : __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, SAMP_REMOTEPLAYERS + playerID * 4, 0x0, 0x0, 0x2A4])
}
getIFPAnimationName1(playerID) {
if (!(ped := getPlayerPed(playerID)))
return ""
if (!(dwAddress := isTaskActive(ped, 401)))
dwAddress := __DWORD(hGTA, ped, [0x47C])
return __READSTRING(hGTA, dwAddress, [0x28], 10) . " , " . __READSTRING(hGTA, dwAddress, [0x10], 20)
}
getIFPAnimationName(playerID) {
if (!(ped := getPlayerPed(playerID)))
return ""
if (!(dwAddress := isTaskActive(ped, 401)))
dwAddress := __DWORD(hGTA, ped, [0x47C])
return __READSTRING(hGTA, dwAddress, [0x10], 20)
}
isTaskActive(ped, taskID) {
return !checkHandles() ? false : __CALL(hGTA, 0x681740, [["i", __DWORD(hGTA, ped, [0x47C]) + 0x4], ["i", taskID]], false, true, true, "UInt")
}
getVehicleColor1() {
return !checkHandles() ? false : __READMEM(hGTA, GTA_VEHICLE_PTR, [0x0, 0x434], "UChar")
}
getVehicleColor2() {
return !checkHandles() ? false : __READMEM(hGTA, GTA_VEHICLE_PTR, [0x0, 0x435], "UChar")
}
getVehicleSpeed() {
return !checkHandles() || !isPlayerInAnyVehicle() ? "" : sqrt(((fSpeedX := __READMEM(hGTA, (dwAddress := __DWORD(hGTA, GTA_VEHICLE_PTR, [0x0])), [0x44], "Float")) * fSpeedX) + ((fSpeedY := __READMEM(hGTA, dwAddress, [0x48], "Float")) * fSpeedY) + ((fSpeedZ := __READMEM(hGTA, dwAddress, [0x4C], "Float")) * fSpeedZ)) * 100 * SERVER_SPEED_KOEFF
}
getVehicleMaxSpeed(modelID) {
if (!checkHandles())
return false
return __READMEM(hGTA, 0xC2BA60, [(modelID - 400) * 0xE0], "Float")
}
getVehicleBootAngle() {
return !checkHandles() || !isPlayerInAnyVehicle() ? "" : __READMEM(hGTA, GTA_VEHICLE_PTR, [0x5DC], "Float")
}
getVehicleBonnetAngle() {
return !checkHandles() || !isPlayerInAnyVehicle() ? "" : __READMEM(hGTA, GTA_VEHICLE_PTR, [0x5C4], "Float")
}
getVehicleType() {
return !checkHandles() || !isPlayerInAnyVehicle() ? false : __CALL(hGTA, 0x6D1080, [["i", __DWORD(hGTA, GTA_VEHICLE_PTR, [0x0])]], false, true, true, "Char")
}
getInteriorID() {
return !checkHandles() ? false : __DWORD(hGTA, 0xA4ACE8, [0x0])
}
isPlayerInAnyVehicle() {
return checkHandles() && __DWORD(hGTA, GTA_VEHICLE_PTR, [0x0]) > 0
}
isPlayerDriver() {
return checkHandles() && __DWORD(hGTA, GTA_VEHICLE_PTR, [0x0, 0x460]) == __DWORD(hGTA, GTA_CPED_PTR, [0x0])
}
getPlayerHealth() {
return !checkHandles() ? -1 : Round(__READMEM(hGTA, GTA_CPED_PTR, [0x0, 0x540], "Float"))
}
getPlayerArmor() {
return !checkHandles() ? -1 : Round(__READMEM(hGTA, GTA_CPED_PTR, [0x0, 0x548], "Float"))
}
getRemotePlayerHealth(playerID) {
return playerID < 0 || playerID > 1004 || !checkHandles() ? -1 : Round(__READMEM(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, SAMP_REMOTEPLAYERS + playerID * 0x4, 0x0, 0x1BC], "Float"))
}
getVehicleHealth() {
return !checkHandles() || !isPlayerInAnyVehicle() ? "" : Round(__READMEM(hGTA, GTA_VEHICLE_PTR, [0x0, 0x4C0], "Float"))
}
getVehicleRotation() {
return !checkHandles() || !isPlayerInAnyVehicle() ? "" : [__READMEM(hGTA, (dwAddress := __DWORD(hGTA, GTA_VEHICLE_PTR, [0x0, 0x14])), [0x0], "Float"), __READMEM(hGTA, dwAddress, [0x4], "Float"), __READMEM(hGTA, dwAddress, [0x8], "Float")]
}
getVehiclePos() {
return !checkHandles() || !isPlayerInAnyVehicle() ? "" : [__READMEM(hGTA, (dwAddress := __DWORD(hGTA, GTA_VEHICLE_PTR, [0x0, 0x14])), [0x30], "Float"), __READMEM(hGTA, dwAddress, [0x34], "Float"), __READMEM(hGTA, dwAddress, [0x38], "Float")]
}
getPlayerVehicleModelID() {
return !checkHandles() || !isPlayerInAnyVehicle() ? "" : __READMEM(hGTA, GTA_VEHICLE_PTR, [0x0, 0x22], "UShort")
}
getVehicleModelName(modelID) {
return modelID < 400 || modelID > 611 ? "" : oVehicleNames[modelID - 399]
}
getPlayerVehicleEngineState() {
return !checkHandles() || !isPlayerInAnyVehicle() ? "" : (__READMEM(hGTA, GTA_VEHICLE_PTR, [0x0, 0x428], "UChar") & 16 ? true : false)
}
getPlayerVehicleLightState() {
return !checkHandles() || !isPlayerInAnyVehicle() ? "" : (__READMEM(hGTA, GTA_VEHICLE_PTR, [0x0, 0x428], "UChar") & 64 ? true : false)
}
getPlayerVehicleLockState() {
return !checkHandles() || !isPlayerInAnyVehicle() ? "" : (__DWORD(hGTA, GTA_VEHICLE_PTR, [0x0, 0x4F8]) == 2)
}
getPlayerVehicleSirenState() {
return !checkHandles() || !isPlayerInAnyVehicle() ? "" : __DWORD(hGTA, GTA_VEHICLE_PTR, [0x0, 0x1F7])
}
setVehicleSirenState(toggle := true) {
return !checkHandles() || !isPlayerInAnyVehicle() ? "" : __WRITEMEM(hGTA, GTA_VEHICLE_PTR, [0x0, 0x42D], toggle ? 208 : 80, "UChar")
}
toggleVision(type, toggle := true) {
return (type != 0 && type != 1) || !checkHandles() ? false : __WRITEMEM(hGTA, 0xC402B8, [type], toggle, "UChar")
}
toggleCursor(toggle) {
return checkHandles() && __WRITEMEM(hGTA, __DWORD(hGTA, dwSAMP + 0x21A0CC, [0x0]), [0x0], toggle ? true : false, "UChar") && __CALL(hGTA, dwSAMP + 0x9BD30, [["i", (dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_MISC_INFO_PTR]))], ["i", 0], ["i", 0]], false, true) && (toggle ? __CALL(hGTA, dwSAMP + 0x9BC10, [["i", dwAddress]], false, true) : true)
}
getDrunkLevel() {
return !checkHandles() ? "" : __DWORD(hGTA, dwSAMP, [SAMP_MISC_INFO_PTR, 0x8, 0x2C9])
}
setPlayerAttachedObject(slot, modelID, bone, xPos, yPos, zPos, xRot, yRot, zRot, xScale := 1, yScale := 1, zScale := 1, color1 := 0x0, color2 := 0x0) {
if (!checkHandles() || !(dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_MISC_INFO_PTR, 0x8])))
return false
VarSetCapacity(struct, 52, 0)
NumPut(modelID, &struct, 0, "UInt")
NumPut(bone, &struct, 4, "UInt")
NumPut(xPos, &struct, 8, "Float")
NumPut(yPos, &struct, 12, "Float")
NumPut(zPos, &struct, 16, "Float")
NumPut(xRot, &struct, 20, "Float")
NumPut(yRot, &struct, 24, "Float")
NumPut(zRot, &struct, 28, "Float")
NumPut(xScale, &struct, 32, "Float")
NumPut(yScale, &struct, 36, "Float")
NumPut(zScale, &struct, 40, "Float")
NumPut(color1, &struct, 44, "UInt")
NumPut(color2, &struct, 48, "UInt")
return !__WRITERAW(hGTA, pMemory + 1024, &struct, 52) ? false : __CALL(hGTA, dwSAMP + 0xAB3E0, [["i", dwAddress], ["i", slot], ["i", pMemory + 1024]], false, true)
}
setRemotePlayerAttachedObject(playerID, slot, modelID, bone, xPos, yPos, zPos, xRot, yRot, zRot, xScale := 1, yScale := 1, zScale := 1, color1 := 0x0, color2 := 0x0) {
if (!checkHandles() || !(dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, SAMP_REMOTEPLAYERS + playerID * 4, 0x0])))
return false
if (!(dwAddress := __DWORD(hGTA, dwAddress, [0x0])))
return false
VarSetCapacity(struct, 52, 0)
NumPut(modelID, &struct, 0, "UInt")
NumPut(bone, &struct, 4, "UInt")
NumPut(xPos, &struct, 8, "Float")
NumPut(yPos, &struct, 12, "Float")
NumPut(zPos, &struct, 16, "Float")
NumPut(xRot, &struct, 20, "Float")
NumPut(yRot, &struct, 24, "Float")
NumPut(zRot, &struct, 28, "Float")
NumPut(xScale, &struct, 32, "Float")
NumPut(yScale, &struct, 36, "Float")
NumPut(zScale, &struct, 40, "Float")
NumPut(color1, &struct, 44, "UInt")
NumPut(color2, &struct, 48, "UInt")
return !__WRITERAW(hGTA, pMemory + 1024, &struct, 52) ? false : __CALL(hGTA, dwSAMP + 0xAB3E0, [["i", dwAddress], ["i", slot], ["i", pMemory + 1024]], false, true)
}
printRemotePlayerAttachedObjects(playerID) {
if (!checkHandles() || !(dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, SAMP_REMOTEPLAYERS + playerID * 4, 0x0])))
return false
if (!(dwAddress := __DWORD(hGTA, dwAddress, [0x0])))
return false
Loop, 10 {
if (!(objectID := __DWORD(hGTA, dwAddress, [0x74 + (A_Index - 1) * 0x34])))
continue
AddChatMessage("SLOT: " A_Index - 1 ", OBJECTID: " objectID)
}
return true
}
getPlayerAttachedObjects() {
if (!checkHandles() || !(dwLocalPlayerPED := __DWORD(hGTA, dwSAMP, [SAMP_MISC_INFO_PTR, 0x8])))
return ""
oPlayerObjects := []
Loop, 10 {
if (!(objectID := __DWORD(hGTA, dwLocalPlayerPED, [0x74 + (A_Index - 1) * 0x34])))
continue
oPlayerObjects.Push(Object("SLOT", A_Index - 1, "OBJECTID", objectID))
}
return oPlayerObjects
}
getPlayerAttachedObjectPos(slot) {
if (!checkHandles() || !(dwLocalPlayerPED := __DWORD(hGTA, dwSAMP, [SAMP_MISC_INFO_PTR, 0x8])))
return ""
posMatrix := []
Loop, 9
posMatrix[A_Index] := __READMEM(hGTA, dwLocalPlayerPED, [0x7C + slot * 0x34 + (A_Index - 1) * 0x4], "Float")
return posMatrix
}
printPlayerAttachedObjectPos(slot) {
if ((posMatrix := getPlayerAttachedObjectPos(slot)) == "")
return AddChatMessage("Slot not in use.")
string := ""
for i, o in posMatrix
string .= o ", "
StringTrimRight, string, string, 2
return AddChatMessage("Slot " slot ": " string)
}
printPlayerAttachedObjects() {
if (!checkHandles() || !(dwLocalPlayerPED := __DWORD(hGTA, dwSAMP, [SAMP_MISC_INFO_PTR, 0x8])))
return ""
oPlayerObjects := []
Loop, 10 {
if (!(objectID := __DWORD(hGTA, dwLocalPlayerPED, [0x74 + (A_Index - 1) * 0x34])))
continue
AddChatMessage("SLOT: " A_Index - 1 ", OBJECTID: " objectID)
}
return oPlayerObjects
}
clearPlayerAttachedObject(slot) {
return checkHandles() && __CALL(hGTA, dwSAMP + 0xA96F0, [["i", __DWORD(hGTA, dwSAMP, [SAMP_MISC_INFO_PTR, 0x8])], ["i", slot]], false, true)
}
quitGame() {
return checkHandles() && __CALL(hGTA, 0x619B60, [["i", 0x1E], ["i", 0]])
}
getServerName() {
return !checkHandles() ? "" : __READSTRING(hGTA, dwSAMP, [SAMP_INFO_PTR, 0x121], 259)
}
getServerIP() {
return !checkHandles() ? "" : __READSTRING(hGTA, dwSAMP, [SAMP_INFO_PTR, 0x20], 257)
}
getServerPort() {
return !checkHandles() ? "" : __READMEM(hGTA, dwSAMP, [SAMP_INFO_PTR, 0x225], "UInt")
}
isPlayerSwimming() {
return !checkHandles() ? "" : __CALL(hGTA, 0x601070, [["i", __DWORD(hGTA, GTA_CPED_PTR, [0x0, 0x47C])]], false, true, true, "UInt") > 0
}
getTargetPlayerID() {
return !checkHandles() ? 0xFFFF : __READMEM(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, SAMP_LOCALPLAYER, 0x161], "UShort")
}
isPlayerSpawned() {
return checkHandles() && __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, SAMP_LOCALPLAYER, 0x136])
}
updatePlayers() {
	if (!checkHandles())
		return false
	if (playerTick + 1000 > A_TickCount)
		return true
	oPlayers := []
	dwPlayers := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER])
	Loop, % getMaxPlayerID() + 1
	{
		if (!(dwRemoteplayer := __DWORD(hGTA, dwPlayers, [SAMP_REMOTEPLAYERS + (A_Index - 1) * 4])))
			continue
		oPlayers[A_Index - 1] := (__DWORD(hGTA, dwRemoteplayer, [0x1C]) > 15 ? __READSTRING(hGTA, dwRemoteplayer, [0xC, 0x0], 25) : __READSTRING(hGTA, dwRemoteplayer, [0xC], 16))
	}
	playerTick := A_TickCount
	return true
}
printPlayers() {
if (!updatePlayers())
return false
playerCount := 1
for i, o in oPlayers {
playerCount++
addChatMessage("ID: " i ", Name: " o)
}
addChatMessage("Player Count: " playerCount)
return true
}
getPlayerCount() {
if (!updatePlayers())
return false
playerCount := 1
for i, o in oPlayers
playerCount++
return playerCount
}
updateGangzones() {
if (!checkHandles())
return false
if (gangZoneTick + 1000 > A_TickCount)
return true
oGangzones := []
if (!(dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_GANGZONE])))
return false
Loop % SAMP_MAX_GANGZONES {
if (!__DWORD(hGTA, dwAddress, [(A_Index - 1) * 4 + 4 * SAMP_MAX_GANGZONES]))
continue
oGangzones.Push(Object("ID", A_Index - 1, "XMIN", __READMEM(hGTA, (dwGangzone := __DWORD(hGTA, dwAddress, [(A_Index - 1) * 4])), [0x0], "Float"), "YMIN", __READMEM(hGTA, dwGangzone, [0x4], "Float"), "XMAX", __READMEM(hGTA, dwGangzone, [0x8], "Float"), "YMAX", __READMEM(hGTA, dwGangzone, [0xC], "Float"), "COLOR1", __DWORD(hGTA, dwGangzone, [0x10]), "COLOR2", __DWORD(hGTA, dwGangzone, [0x14])))
}
gangZoneTick := A_TickCount
return true
}
printGangzones() {
if (!updateGangzones())
return false
for i, o in oGangzones
AddChatMessage("ID: " o.ID ", X: " o.XMIN " - " o.XMAX ", Y: " o.YMIN " - " o.YMAX ", Colors: " intToHex(o.COLOR1) " - " intToHex(o.COLOR2))
return true
}
updateTextDraws() {
if (!checkHandles())
return false
if (textDrawTick + 1000 > A_TickCount)
return true
oTextDraws := []
if (!(dwTextDraws := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_TEXTDRAW])))
return false
Loop, % SAMP_MAX_TEXTDRAWS {
if (!__DWORD(hGTA, dwTextDraws, [(A_Index - 1) * 4]) || !(dwAddress := __DWORD(hGTA, dwTextDraws, [(A_Index - 1) * 4 + (4 * (SAMP_MAX_PLAYERTEXTDRAWS + SAMP_MAX_TEXTDRAWS))])))
continue
oTextDraws.Push(Object("TYPE", "Global", "ID", A_Index - 1, "TEXT", __READSTRING(hGTA, dwAddress, [0x0], 800)))
}
Loop, % SAMP_MAX_PLAYERTEXTDRAWS {
if (!__DWORD(hGTA, dwTextDraws, [(A_Index - 1) * 4 + SAMP_MAX_TEXTDRAWS * 4]) || !(dwAddress := __DWORD(hGTA, dwTextDraws, [(A_Index - 1) * 4 + (4 * (SAMP_MAX_PLAYERTEXTDRAWS + SAMP_MAX_TEXTDRAWS * 2))])))
continue
oTextDraws.Push(Object("TYPE", "Player", "ID", A_Index - 1, "TEXT", __READSTRING(hGTA, dwAddress, [0x0], 800)))
}
textDrawTick := A_TickCount
return true
}
printTextDraws() {
if (!updateTextDraws())
return false
for i, o in oTextDraws
AddChatMessage("Type: " o.TYPE ", ID: " o.ID ", Text: " o.TEXT)
AddChatMessage("TextDraw Count: " i)
return true
}
printPlayerTextdraws(){
    if (!updateTextDraws())
        return false
    for i, o in oTextDraws
    {
        TDID := % o.ID
        TDTEXT := % o.TEXT
        TDTYP := % o.TYPE
        FileAppend, %TDID%`t%TDTEXT%`t%TDTYP%`n, %A_AppData%\prawler\temp\textdraws.txt
    }
    FileRead, Textdraws, %A_AppData%\prawler\temp\textdraws.txt
    FileDelete, %A_AppData%\prawler\temp\textdraws.txt
    showDialog(DIALOG_STYLE_TABLIST_HEADERS, prefix . "Textdraws", "ID`tText`tTyp`n" Textdraws "`n `nGesamte Textdraws: " i, "Schlieﬂen")
    return true
}
getTextDrawBySubstring(substring) {
if (!updateTextDraws())
return ""
for i, o in oTextDraws {
if (InStr(o.TEXT, substring))
return o.TEXT
}
return ""
}
deleteTextDraw(ByRef textDrawID) {
if (textDrawID < 0 || textDrawID > SAMP_MAX_TEXTDRAWS - 1 || !checkHandles()) {
textDrawID := -1
return -1
}
if (__CALL(hGTA, dwSAMP + 0x1AD00, [["i", __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_TEXTDRAW])], ["i", textDrawID]], false, true)) {
textDrawID := -1
return -1
}
AddChatMessage("Could not be deleted: " textDrawID)
return textDrawID
}
createTextDraw(text, xPos, yPos, letterColor := 0xFFFFFFFF, font := 3, letterWidth := 0.4, letterHeight := 1, shadowSize := 0, outline := 1
, shadowColor := 0xFF000000, box := 0, boxColor := 0xFFFFFFFF, boxSizeX := 0.0, boxSizeY := 0.0, left := 0, right := 0, center := 1
, proportional := 1, modelID := 0, xRot := 0.0, yRot := 0.0, zRot := 0.0, zoom := 1.0, color1 := 0xFFFF, color2 := 0xFFFF) {
if (font > 5 || StrLen(text) > 800 || !checkHandles() || !(dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_TEXTDRAW])))
return -1
Loop, 2048 {
i := 2048 - A_Index
if (__DWORD(hGTA, dwAddress, [i * 4]))
continue
VarSetCapacity(struct, 63, 0)
NumPut((box ? 1 : 0) + (left ? 2 : 0) + (right ? 4 : 0) + (center ? 8 : 0) + (proportional ? 16 : 0), &struct, 0, "UChar")
NumPut(letterWidth, &struct, 1, "Float")
NumPut(letterHeight, &struct, 5, "Float")
NumPut(letterColor, &struct, 9, "UInt")
NumPut(boxSizeX, &struct, 0xD, "Float")
NumPut(boxSizeY, &struct, 0x11, "Float")
NumPut(boxColor, &struct, 0x15, "UInt")
NumPut(shadowSize, &struct, 0x19, "UChar")
NumPut(outline, &struct, 0x1A, "UChar")
NumPut(shadowColor, &struct, 0x1B, "UInt")
NumPut(font, &struct, 0x1F, "UChar")
NumPut(1, &struct, 0x20, "UChar")
NumPut(xPos, &struct, 0x21, "Float")
NumPut(yPos, &struct, 0x25, "Float")
NumPut(modelID, &struct, 0x29, "Short")
NumPut(xRot, &struct, 0x2B, "Float")
NumPut(yRot, &struct, 0x2F, "Float")
NumPut(zRot, &struct, 0x33, "Float")
NumPut(zoom, &struct, 0x37, "Float")
NumPut(color1, &struct, 0x3B, "Short")
NumPut(color2, &struct, 0x3D, "Short")
return !__WRITERAW(hGTA, pMemory + 1024, &struct, 63) ? -1 : __CALL(hGTA, dwSAMP + 0x1AE20, [["i", dwAddress], ["i", i], ["i", pMemory + 1024], ["s", text]], false, true) ? i : -1
}
return -1
}
getTextDrawPos(textDrawID) {
return textDrawID < 0 || textDrawID > 2047 || !checkHandles() ? "" : [__READMEM(hGTA, (dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_TEXTDRAW, textDrawID * 4 + 4 * (SAMP_MAX_PLAYERTEXTDRAWS + SAMP_MAX_TEXTDRAWS)])), [0x98B], "Float"), __READMEM(hGTA, dwAddress, [0x98F], "Float")]
}
moveTextDraw(textDrawID, xPos, yPos) {
return textDrawID < 0 || textDrawID > 2047 || checkHandles() && __WRITEMEM(hGTA, (dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_TEXTDRAW, textDrawID * 4 + 4 * (SAMP_MAX_PLAYERTEXTDRAWS + SAMP_MAX_TEXTDRAWS)])), [0x98B], xPos, "Float") && __WRITEMEM(hGTA, dwAddress, [0x98F], yPos, "Float")
}
resizeTextDraw(textDrawID, letterWidth, letterHeight) {
return return textDrawID < 0 || textDrawID > 2047 || checkHandles()
&& __WRITEMEM(hGTA, (dwAddress := __DWORD(hGTA, dwSAMP
, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_TEXTDRAW, textDrawID * 4 + 4 * (SAMP_MAX_PLAYERTEXTDRAWS + SAMP_MAX_TEXTDRAWS)])), [0x963], letterWidth
, "Float") && __WRITEMEM(hGTA, dwAddress, [0x967], letterHeight, "Float")
}
setTextDrawAlignment(textDrawID, align) {
if (textDrawID < 0 || textDrawID > 2047 || !checkHandles())
return false
__WRITEMEM(hGTA, (dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_TEXTDRAW, textDrawID * 4 + 4 * (SAMP_MAX_PLAYERTEXTDRAWS + SAMP_MAX_TEXTDRAWS)])), [0x970], align == "CENTER", "UChar")
__WRITEMEM(hGTA, dwAddress, [0x985], align == "LEFT", "UChar")
return __WRITEMEM(hGTA, dwAddress, [0x986], align == "RIGHT", "UChar")
}
setTextDrawFont(textDrawID, tdFont) {
return textDrawID < 0 || textDrawID > 2047 || checkHandles() && __WRITEMEM(hGTA, (dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_TEXTDRAW, textDrawID * 4 + 4 * (SAMP_MAX_PLAYERTEXTDRAWS + SAMP_MAX_TEXTDRAWS)])), [0x987], tdFont, "UChar")
}
updateTextDraw(textDrawID, text) {
if (textDrawID < 0 || textDrawID > 2047 || StrLen(text) > 800 || !checkHandles())
return false
dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_TEXTDRAW, textDrawID * 4 + 4 * (SAMP_MAX_PLAYERTEXTDRAWS + SAMP_MAX_TEXTDRAWS)])
return __WRITESTRING(hGTA, dwAddress, [0x0], text)
}
destroyObject(ByRef objectID) {
if (objectID < 0 || objectID > SAMP_MAX_OBJECTS - 1 || !checkHandles()) {
objectID := -1
return false
}
if (__CALL(hGTA, dwSAMP + 0xF3F0, [["i", __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_OBJECT])], ["i", objectID]], false, true)) {
objectID := -1
return true
}
return false
}
attachObjectToPlayerVehicle(objectID) {
if (!checkHandles())
return false
vehPtr := __DWORD(hGTA, GTA_VEHICLE_PTR, [0x0])
if (vehPtr == "" || !vehPtr)
return false
dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_OBJECT])
if (!dwAddress)
return false
if (!__DWORD(hGTA, dwAddress, [objectID * 4 + 0x4]))
return false
if (__WRITEMEM(hGTA, dwAddress, [objectID * 0x4 + 0xFA4, 0x40, 0xFC], vehPtr, "UInt"))
return true
return false
}
createObject(modelID, xPos, yPos, zPos, xRot, yRot, zRot, drawDistance := 0) {
if (!(dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_OBJECT])) || __DWORD(hGTA, dwAddress, [0x0]) == SAMP_MAX_OBJECTS)
return -1
Loop, % SAMP_MAX_OBJECTS - 1 {
i := SAMP_MAX_OBJECTS - A_Index
if (__DWORD(hGTA, dwAddress, [i * 4 + 0x4]))
continue
return __CALL(hGTA, dwSAMP + 0xF470, [["i", dwAddress], ["i", i], ["i", modelID], ["f", xPos], ["f", yPos], ["f", zPos], ["f", xRot]
, ["f", yRot], ["f", zRot], ["f", drawDistance]], false, true) ? i : -1
}
return -1
}
setObjectMaterialText(objectID, text, matIndex := 0, matSize := 90, font := "Arial", fontSize := 24, bold := 1, fontColor := 0xFFFFFFFF, backColor := 0xFF000000, align := 1) {
if (!checkHandles() || !(dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_OBJECT])) || !__DWORD(hGTA, dwAddress, [objectID * 4 + 0x4]))
return false
return __CALL(hGTA, dwSAMP + 0xA3050, [["i", __DWORD(hGTA, dwAddress, [objectID * 0x4 + 0xFA4])], ["i", matIndex], ["s", text], ["i", matSize], ["s", font]
, ["i", fontSize], ["i", bold], ["i", fontColor], ["i", backColor], ["i", align]], false, true)
}
editObject(objectID) {
return __CALL(hGTA, dwSAMP + 0x6DE40, [["i", __DWORD(hGTA, dwSAMP, [0x21A0C4])], ["i", objectID], ["i", 1]], false, true)
}
editAttachedObject(slot) {
return __CALL(hGTA, dwSAMP + 0x6DF00, [["i", __DWORD(hGTA, dwSAMP, [0x21A0C4])], ["i", slot]], false, true)
}
getObjectPos(objectID) {
if (!checkHandles() || !(dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_OBJECT])) || !__DWORD(hGTA, dwAddress, [objectID * 4 + 0x4]))
return false
dwAddress := __DWORD(hGTA, dwAddress, [objectID * 0x4 + 0xFA4])
xPos := __READMEM(hGTA, dwAddress, [0x10B], "Float")
yPos := __READMEM(hGTA, dwAddress, [0x10F], "Float")
zPos := __READMEM(hGTA, dwAddress, [0x113], "Float")
xRot := __READMEM(hGTA, dwAddress, [0xAD], "Float")
yRot := __READMEM(hGTA, dwAddress, [0xB1], "Float")
zRot := __READMEM(hGTA, dwAddress, [0xB5], "Float")
return [xPos, yPos, zPos, xRot, yRot, zRot]
}
printObjectPos(objectID) {
pos := getObjectPos(objectID)
if (pos == false)
return AddChatMessage("Object not found.")
AddChatMessage(pos[1] ", " pos[2] ", " pos[3] ", " pos[4] ", " pos[5] ", " pos[6])
return true
}
getClosestObjectByModel(modelID) {
if (!updateObjects())
return ""
dist := -1
obj := ""
pPos := getPlayerPos()
for i, o in oObjects {
if (o.MODELID != modelID)
continue
if ((newDist := getDistance([o.XPOS, o.YPOS, o.ZPOS], pPos)) < dist || dist == -1) {
obj := o
dist := newDist
}
}
return obj
}
getClosestObjectModel() {
if (!updateObjects())
return ""
dist := -1
model := ""
pPos := getPlayerPos()
for i, o in oObjects {
if ((newDist := getDistance([o.XPOS, o.YPOS, o.ZPOS], pPos)) < dist || dist == -1) {
dist := newDist
model := o.MODELID
}
}
return model
}
printObjects() {
if (!updateObjects())
return false
for i, o in oObjects
AddChatMessage("Index: " o.ID ", Model: " o.MODELID ", xPos: " o.XPOS ", yPos: " o.YPOS ", zPos: " o.ZPOS)
AddChatMessage("Object Count: " i)
return true
}
printObjectsByModelID(modelID) {
if (!updateObjects())
return false
count := 0
for i, o in oObjects {
if (o.MODELID == modelID) {
count++
AddChatMessage("ID: " o.ID ", Model: " o.MODELID ", xPos: " o.XPOS ", yPos: " o.YPOS ", zPos: " o.ZPOS)
}
}
AddChatMessage("Object Count: " count)
return true
}
isSirenAttached() {
if (!checkHandles())
return false
vehPtr := __DWORD(hGTA, GTA_VEHICLE_PTR, [0x0])
if (vehPtr == "" || !vehPtr)
return false
dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_OBJECT])
if (!dwAddress)
return false
count := __DWORD(hGTA, dwAddress, [0x0])
Loop, % SAMP_MAX_OBJECTS {
i := A_Index - 1
if (!__DWORD(hGTA, dwAddress, [i * 4 + 0x4]))
continue
dwObject := __DWORD(hGTA, dwAddress, [i * 0x4 + 0xFA4])
if (__DWORD(hGTA, dwObject, [0x4E]) == 18646 && __DWORD(hGTA, dwObject, [0x40, 0xFC]) == vehPtr)
return true
count--
if (count <= 0)
break
}
return false
}
createPickup(modelID, type, xPos, yPos, zPos) {
if (!checkHandles() || !(dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PICKUP])))
return -1
Loop, % SAMP_MAX_PICKUPS {
if (__READMEM(hGTA, dwAddress, [(A_Index - 1) * 4 + 0x4004], "Int") > 0)
continue
VarSetCapacity(struct, 20, 0)
NumPut(modelID, &struct, 0, "UInt")
NumPut(type, &struct, 4, "UInt")
NumPut(xPos, &struct, 8, "Float")
NumPut(yPos, &struct, 12, "Float")
NumPut(zPos, &struct, 16, "Float")
return !__WRITERAW(hGTA, pMemory + 1024, &struct, 20) ? -1 : __CALL(hGTA, dwSAMP + 0xFDC0, [["i", dwAddress], ["i", pMemory + 1024], ["i", A_Index - 1]] , false, true) ? A_Index - 1 : -1
}
return -1
}
getConnectionTicks() {
return !checkHandles() ? 0 : DllCall("GetTickCount") - __READMEM(hGTA, dwSAMP, [SAMP_INFO_PTR, 0x3C1], "UInt")
}
getRunningTime() {
return !checkHandles() ? 0 : __READMEM(hGTA, 0xB610E1, [0x0], "UInt") / 4
}
deletePickup(ByRef pickupID) {
if (pickupID < 0 || pickupID > SAMP_MAX_PICKUPS - 1 || !checkHandles())
return false
if (__CALL(hGTA, dwSAMP + 0xFE70, [["i", __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PICKUP])], ["i", pickupID]], false, true)) {
pickupID := -1
return true
}
return false
}
getPickupModel(modelID) {
if (!updatePickups())
return ""
for i, o in oPickups {
if (o.MODELID == modelID)
return o
}
return ""
}
getClosestPickupModel() {
if (!updatePickups())
return -1
dist := -1
model := 0
pPos := getPlayerPos()
for i, o in oPickups {
if ((newDist := getDistance([o.XPOS, o.YPOS, o.ZPOS], pPos)) < dist || dist == -1) {
dist := newDist
model := o.MODELID
}
}
return model
}
getPickupModelsInDistance(distance) {
if (!updatePickups())
return ""
array := []
pPos := getPlayerPos()
for i, o in oPickups {
if (getDistance([o.XPOS, o.YPOS, o.ZPOS], pPos) < distance)
array.Push(o.MODELID)
}
return array
}
isPlayerDead(playerID) {
if (!checkHandles())
return false
dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER])
dwAddress2 := __DWORD(hGTA, dwAddress, [SAMP_REMOTEPLAYERS + playerID * 4, 0x0, 0x0, 0x2A4])
if (!dwAddress2 || dwAddress2 == "")
return false
if (!(dwAddress3 := isTaskActive(dwAddress2, 401)))
dwAddress3 := __DWORD(hGTA, dwAddress2, [0x47C])
if (__READSTRING(hGTA, dwAddress3, [0x10], 20) == "crckdeth2")
return true
return false
}
getClosestDeadPlayer() {
if (!checkHandles())
return [-1, 0]
dist := 0
playerID := -1
pos1 := getPlayerPos()
dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER])
Loop % getMaxPlayerID() + 1 {
dwAddress2 := __DWORD(hGTA, dwAddress, [SAMP_REMOTEPLAYERS + (A_Index - 1) * 4, 0x0, 0x0, 0x2A4])
if (!dwAddress2 || dwAddress2 == "")
continue
if (!(dwAddress3 := isTaskActive(dwAddress2, 401)))
dwAddress3 := __DWORD(hGTA, dwAddress2, [0x47C])
if (__READSTRING(hGTA, dwAddress3, [0x10], 20) != "crckdeth2")
continue
dwAddress2 := __DWORD(hGTA, dwAddress2, [0x14])
dist2 := getDistance([__READMEM(hGTA, dwAddress2, [0x30], "Float"), __READMEM(hGTA, dwAddress2, [0x34], "Float"), __READMEM(hGTA, dwAddress2, [0x38], "Float")], pos1)
if (dist == 0 || dist2 < dist) {
playerID := A_Index - 1
dist := dist2
}
}
return [playerID, dist]
}
getClosestPlayer() {
if (!checkHandles())
return [-1, 0]
dist := 0
playerID := -1
pos1 := getPlayerPos()
dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER])
Loop % getMaxPlayerID() + 1 {
dwAddress2 := __DWORD(hGTA, dwAddress, [SAMP_REMOTEPLAYERS + (A_Index - 1) * 4, 0x0, 0x0])
if (!dwAddress2 || dwAddress2 == "")
continue
dwAddress2 := __DWORD(hGTA, dwAddress2, [0x2A4, 0x14])
if (!dwAddress2 || dwAddress2 == "")
continue
dist2 := getDistance([__READMEM(hGTA, dwAddress2, [0x30], "Float"), __READMEM(hGTA, dwAddress2, [0x34], "Float"), __READMEM(hGTA, dwAddress2, [0x38], "Float")], pos1)
if (dist == 0 || dist2 < dist) {
playerID := A_Index - 1
dist := dist2
}
}
return [playerID, dist]
}
saveGTASettings() {
return checkHandles() && __CALL(hGTA, 0x57C660, [["i", 0xBA6748]], false, true)
}
setRadioVolume(volume) {
return (volume < 0 || volume > 16 || !checkHandles()) ? false : __CALL(hGTA, 0x506DE0, [["i", 0xB6BC90], ["i", volume * 4]], false, true) && __WRITEMEM(hGTA, 0xBA6798, [0x0], volume * 4, "UChar") && saveGTASettings()
}
getRadioVolume() {
return !checkHandles() ? false : __READMEM(hGTA, 0xBA6798, [0x0], "UChar")
}
setSFXVolume(volume) {
return (volume < 0 || volume > 16 || !checkHandles()) ? false : __CALL(hGTA, 0x506E10, [["i", 0xB6BC90], ["i", volume * 4]], false, true) && __WRITEMEM(hGTA, 0xBA6797, [0x0], volume * 4, "UChar") && saveGTASettings()
}
getSFXVolume() {
return !checkHandles() ? false : __READMEM(hGTA, 0xBA6797, [0x0], "UChar")
}
getDistanceToPickup(modelID) {
if (!updatePickups())
return -1
dist := -1
pPos := getPlayerPos()
for i, o in oPickups {
if (o.MODELID != modelID)
continue
if ((newDist := getDistance([o.XPOS, o.YPOS, o.ZPOS], pPos)) < dist || dist == -1)
dist := newDist
}
return dist
}
printPickups() {
if (!updatePickups())
return false
for i, o in oPickups
AddChatMessage("ID: " o.ID ", Model: " o.MODELID ", Type: " o.TYPE ", xPos: " o.XPOS ", yPos: " o.YPOS ", zPos: " o.ZPOS)
AddChatMessage("Pickup Count: " i)
return true
}
updatePickups() {
if (pickupTick + 200 > A_TickCount)
return true
if (!checkHandles() || !(dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PICKUP])) || (pickupCount := __DWORD(hGTA, dwAddress, [0x0])) <= 0)
return false
oPickups := []
Loop, % SAMP_MAX_PICKUPS {
pickupID := __READMEM(hGTA, dwAddress, [(i := A_Index - 1) * 4 + 0x4004], "Int")
if (pickupID < 0)
continue
pickupCount--
oPickups.Push(Object("ID", pickupID, "MODELID", __READMEM(hGTA, dwAddress, [i * 0x14 + 0xF004], "Int"), "TYPE", __READMEM(hGTA, dwAddress, [i * 0x14 + 0xF008], "Int"), "XPOS", __READMEM(hGTA, dwAddress, [i * 0x14 + 0xF00C], "Float"), "YPOS", __READMEM(hGTA, dwAddress, [i * 0x14 + 0xF010], "Float"), "ZPOS", __READMEM(hGTA, dwAddress, [i * 0x14 + 0xF014], "Float")))
if (pickupCount <= 0)
break
}
pickupTick := A_TickCount
return true
}
updateObjects() {
if (!checkHandles())
return false
if (objectTick + 1000 > A_TickCount)
return true
oObjects := []
objectTick := A_TickCount
dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_OBJECT])
if (!dwAddress)
return false
count := __DWORD(hGTA, dwAddress, [0x0])
Loop, % SAMP_MAX_OBJECTS {
i := A_Index - 1
if (!__DWORD(hGTA, dwAddress, [i * 4 + 0x4]))
continue
dwObject := __DWORD(hGTA, dwAddress, [i * 0x4 + 0xFA4])
oObjects.Push(Object("ID", i, "MODELID", __DWORD(hGTA, dwObject, [0x4E]), "XPOS", __READMEM(hGTA, dwObject, [0x5C], "Float"), "YPOS"
, __READMEM(hGTA, dwObject, [0x60], "Float"), "ZPOS", __READMEM(hGTA, dwObject, [0x64], "Float")))
count--
if (count <= 0)
break
}
return true
}
_getChatline(dwIndex) {
if (dwIndex < 0 || dwIndex > 99 || !checkHandles())
return false
return __READSTRING(hGTA, dwSAMP, [SAMP_CHAT_INFO_PTR, 0x152 + 0xFC * (99 - dwIndex)], 144)
}
printObjectTexts() {
if (!checkHandles())
return false
dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_OBJECT])
if (!dwAddress)
return false
count := __DWORD(hGTA, dwAddress, [0x0])
Loop, % SAMP_MAX_OBJECTS {
i := A_Index - 1
if (!__DWORD(hGTA, dwAddress, [i * 4 + 0x4]))
continue
dwObject := __DWORD(hGTA, dwAddress, [i * 0x4 + 0xFA4])
string := __READSTRING(hGTA, dwObject, [0x10CB, 0x0], 256)
if (string != "")
AddChatMessage("ID: " i ", " string ", X: " __READMEM(hGTA, dwObject, [0x5C], "Float") ", Y: " __READMEM(hGTA, dwObject, [0x60], "Float"))
count--
if (count <= 0)
break
}
return true
}
getTextLabelBySubstring(string) {
if (!updateTextLabels())
return ""
for i, o in oTextLabels {
if (InStr(o.TEXT, string))
return o.TEXT
}
return ""
}
updateTextLabels() {
if (!checkHandles())
return false
if (textLabelTick + 200 > A_TickCount)
return true
oTextLabels := []
dwTextLabels := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_TEXTLABEL])
if (!dwTextLabels)
return false
Loop, % SAMP_MAX_TEXTLABELS {
i := A_Index - 1
if (!__DWORD(hGTA, dwTextLabels, [0xE800 + i * 4]))
continue
dwAddress := __DWORD(hGTA, dwTextLabels, [i * 0x1D])
if (!dwAddress)
continue
fX := __READMEM(hGTA, dwTextLabels, [i * 0x1D + 0x8], "Float")
fY := __READMEM(hGTA, dwTextLabels, [i * 0x1D + 0xC], "Float")
fZ := __READMEM(hGTA, dwTextLabels, [i * 0x1D + 0x10], "Float")
wVehicleID := __READMEM(hGTA, dwTextLabels, [i * 0x1D + 0x1B], "UShort")
wPlayerID := __READMEM(hGTA, dwTextLabels, [i * 0x1D + 0x19], "UShort")
oTextLabels.Push(Object("ID", i, "TEXT", __READSTRING(hGTA, dwAddress, [0x0], 256), "XPOS", fX, "YPOS", fY, "ZPOS", fZ, "VEHICLEID", wVehicleID, "PLAYERID"
, wPlayerID, "VISIBLE", __READMEM(hGTA, dwTextLabels, [i * 0x1D + 0x18], "UChar"), "DISTANCE", __READMEM(hGTA, dwTextLabels, [i * 0x1D + 0x14], "Float")))
}
textLabelTick := A_TickCount
return true
}
updateTextLabel(textLabelID, text) {
if (textLabelID < 0 || textLabelID > 2047 || !checkHandles())
return false
return __WRITESTRING(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_TEXTLABEL, textLabelID * 0x1D, 0x0], text)
}
createTextLabel(text, color, xPos, yPos, zPos, drawDistance := 46.0, testLOS := 0, playerID := 0xFFFF, vehicleID := 0xFFFF) {
if (!checkHandles() || !(dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_TEXTLABEL])))
return -1
Loop, % SAMP_MAX_TEXTLABELS {
if (__DWORD(hGTA, dwAddress, [0xE800 + (SAMP_MAX_TEXTLABELS - A_Index) * 4]))
continue
return __CALL(hGTA, dwSAMP + 0x11C0, [["i", dwAddress], ["i", SAMP_MAX_TEXTLABELS - A_Index], ["s", text], ["i", color], ["f", xPos], ["f", yPos], ["f", zPos]
, ["f", drawDistance], ["i", testLOS], ["i", playerID], ["i", vehicleID]], false, true) ? SAMP_MAX_TEXTLABELS - A_Index : -1
}
return -1
}
deleteTextLabel(ByRef textLabelID) {
if (textLabelID < 0 || !checkHandles()) {
textLabelID := -1
return -1
}
if (__CALL(hGTA, dwSAMP + 0x12D0, [["i", __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_TEXTLABEL])], ["i", textLabelID]], false, true)) {
textLabelID := -1
return -1
}
return textLabelID
}
printPlayerTextLabels() {
if (!updateTextLabels())
return false
for i, o in oTextLabels {
if (o.TEXT != "" && o.TEXT != " " && o.PLAYERID != 0xFFFF)
addChatMessage("{FFFF00}ID: " o.ID ", Text: " o.TEXT ", " o.PLAYERID)
}
return true
}
printTextLabels() {
if (!updateTextLabels())
return false
for i, o in oTextLabels
AddChatMessage("{FFFF00}ID: " o.ID ", Text: " o.TEXT ", " o.XPOS ", " o.YPOS ", " o.ZPOS ", ")
AddChatMessage("TextLabel Count: " i)
return true
}

printTextLabelsInDialog(){
    if (!updateTextLabels())
        return false
    for i, o in oTextLabels
    {
        TLID := % o.ID
        TLTEXT := % o.TEXT
        XPOS := % o.XPOS
        YPOS := % o.YPOS
        ZPOS := % o.ZPOS
        FileAppend, %TLID%`t%TLTEXT%`t%XPOS%`t%YPOS%`t%ZPOS%`n, %A_AppData%\prawler\temp\textlabels.txt
    }
    FileRead, Textlabels, %A_AppData%\prawler\temp\textlabels.txt
    FileDelete, %A_AppData%\prawler\temp\textlabels.txt
    showDialog(DIALOG_STYLE_TABLIST_HEADERS, prefix . "Textlabels", "ID`tText`tX`tY`tZ`n" Textlabels "`n `nGesamte Textlabels: " i, "Schlieﬂen")
    return true
}

countLabels() {
return !updateTextLabels() ? -1 : oTextLabels.Length()
}
getPlayerAttachedTextLabel(playerID) {
if (!checkHandles() || !updateTextLabels())
return false
for i, o in oTextLabels {
if (playerID == o.PLAYERID)
return o
}
return false
}
getPlayerAttachedTextLabels(playerID) {
if (!checkHandles() || !updateTextLabels())
return false
labels := []
for i, o in oTextLabels {
if (playerID == o.PLAYERID)
labels.Push(o)
}
return labels
}
getLabelBySubstring(text := "") {
if (!updateTextLabels())
return 0
for i, o in oTextLabels {
if (text != "" && InStr(o.TEXT, text) == 0)
continue
return o
}
return ""
}
getNearestLabel2(text := "", pos1 := "") {
if (!updateTextLabels())
return 0
nearest := ""
dist := -1
if (pos1 == "")
pos1 := getPlayerPos()
for i, o in oTextLabels {
if (text != "" && !InStr(o.TEXT, text))
continue
newDist := getDistance(pos1, [o.XPOS, o.YPOS, o.ZPOS])
if (dist == -1 || newDist < dist) {
dist := newDist
nearest := o
}
}
return [nearest, dist]
}
getNearestLabel(text := "") {
if (!updateTextLabels())
return 0
nearest := 0
dist := -1
pos1 := getPlayerPos()
for i, o in oTextLabels {
if (text != "" && o.TEXT != text)
continue
newDist := getDistance(pos1, [o.XPOS, o.YPOS, o.ZPOS])
if (dist == -1 || newDist < dist) {
dist := newDist
nearest := o
}
}
return nearest
}
getNearestLabelDistance(text := "") {
if(!updateTextLabels())
return 0
nearest := 0
dist := 5000
pos1 := getPlayerPos()
For i, o in oTextLabels
{
if (text != "" && !InStr(o.TEXT, text))
continue
pos2 := [o.XPOS, o.YPOS, o.ZPOS]
dist2 := getDistance(pos1, pos2)
if (dist2 < dist) {
dist := dist2
nearest := o
}
}
return [nearest, dist]
}
createBlip(dwIcon, fX, fY) {
if (!checkHandles())
return ""
dwReturn := __INJECT(hGTA, [["NOP"]
, ["push", [3, "Int"]]
, ["push", [0, "Int"]]
, ["push", [0.0, "Float"]]
, ["push", [fY, "Float"]]
, ["push", [fX, "Float"]]
, ["push", [4, "Int"]]
, ["call", [0x583820, "Int"]]
, ["mov address, eax", [pMemory, "Int"]]
, ["push", [dwIcon, "Int"]]
, ["push eax"]
, ["call", [0x583D70, "Int"]]
, ["add esp", [0x20, "UChar"]]
, ["ret"]])
return dwReturn
}
clearBlip(dwBlip) {
if (!checkHandles() || !dwBlip)
return false
return __CALL(hGTA, 0x587CE0, [["i", dwBlip]])
}
getBlipPosByIconID(iconID) {
if (!checkHandles())
return Object("ID", -1)
Loop % GTA_BLIP_COUNT {
currentElement := GTA_BLIP_POOL + (A_Index - 1) * GTA_BLIP_ELEMENT_SIZE
if (__READMEM(hGTA, currentElement + GTA_BLIP_ID_OFFSET, [0x0], "UChar") != iconID)
continue
xPos := __READMEM(hGTA, currentElement + GTA_BLIP_X_OFFSET, [0x0], "Float")
yPos := __READMEM(hGTA, currentElement + GTA_BLIP_Y_OFFSET, [0x0], "Float")
zPos := __READMEM(hGTA, currentElement + GTA_BLIP_Z_OFFSET, [0x0], "Float")
return Object("ID", A_Index - 1, "XPOS", xpos, "YPOS", yPos, "ZPOS", zPos)
}
return Object("ID", -1)
}
printMapIcons() {
if (!checkHandles())
return false
Loop % GTA_BLIP_COUNT {
currentElement := GTA_BLIP_POOL + (A_Index - 1) * GTA_BLIP_ELEMENT_SIZE
style := __READMEM(hGTA, currentElement + GTA_BLIP_STYLE_OFFSET, [0x0], "UChar")
id := __READMEM(hGTA, currentElement + GTA_BLIP_ID_OFFSET, [0x0], "UChar")
xPos := __READMEM(hGTA, currentElement + GTA_BLIP_X_OFFSET, [0x0], "Float")
yPos := __READMEM(hGTA, currentElement + GTA_BLIP_Y_OFFSET, [0x0], "Float")
zPos := __READMEM(hGTA, currentElement + GTA_BLIP_Z_OFFSET, [0x0], "Float")
color := intToHex(__READMEM(hGTA, currentElement + GTA_BLIP_COLOR_OFFSET, [0x0], "UInt"))
if (id != 0)
AddChatMessage("Icon ID: " id ", Style: " style ", Pos: " xPos " " yPos " " zPos ", Color: " color)
}
return true
}
getVehicleAddress(vehicleID) {
return !checkHandles() || vehicleID < 1 || vehicleID > SAMP_MAX_VEHICLES ? "" : __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_VEHICLE, 0x4FB4 + vehicleID * 0x4])
}
getVehicleModelID(vehicleID) {
return !checkHandles() || vehicleID < 1 || vehicleID > SAMP_MAX_VEHICLES ? false : __READMEM(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_VEHICLE, 0x4FB4 + vehicleID * 0x4, 0x22], "UShort")
}
getVehicleLockState(vehicleID) {
return !checkHandles() || vehicleID < 1 || vehicleID > SAMP_MAX_VEHICLES ? "" : __READMEM(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_VEHICLE, 0x4FB4 + vehicleID * 0x4, 0x4F8], "UShort") == 2
}
getVehicleEngineState(vehicleID) {
return !checkHandles() || vehicleID < 1 || vehicleID > SAMP_MAX_VEHICLES ? "" : __READMEM(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_VEHICLE, 0x4FB4 + vehicleID * 0x4, 0x428], "UShort") & 16 ? true : false
}
getVehicleLightState(vehicleID) {
return !checkHandles() || vehicleID < 1 || vehicleID > SAMP_MAX_VEHICLES ? "" : __READMEM(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_VEHICLE, 0x4FB4 + vehicleID * 0x4, 0x428], "UShort") & 64 ? true : false
}
getVehicleSirenState(vehicleID) {
return !checkHandles() || vehicleID < 1 || vehicleID > SAMP_MAX_VEHICLES ? "" : __READMEM(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_VEHICLE, 0x4FB4 + vehicleID * 0x4, 0x1F7], "UShort")
}
getVehicleDriver(vehicleID) {
if (vehicleID < 1 || vehicleID > SAMP_MAX_VEHICLES || !checkHandles() || !updatePlayers())
return ""
dwPed := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_VEHICLE, 0x4FB4 + vehicleID * 0x4, 0x460])
if (dwPed == 0x0 || dwPed == "")
return ""
if (dwPed == __DWORD(hGTA, GTA_CPED_PTR, [0x0]))
return Object("ID", getID(), "NAME", getUserName())
dwPlayers := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER])
for i, o in oPlayers {
if (__DWORD(hGTA, dwPlayers, [SAMP_REMOTEPLAYERS + i * 4, 0x0, 0x0, 0x2A4]) == dwPed)
return Object("ID", i, "NAME", o)
}
return ""
}
getVehicleDriverByPtr(dwVehiclePtr) {
if (dwVehiclePtr == 0x0 || dwVehiclePtr == "" | !checkHandles() || !updatePlayers())
return ""
dwPed := __DWORD(hGTA, dwVehiclePtr, [0x460])
if (dwPed == 0x0 || dwPed == "")
return ""
if (dwPed == __DWORD(hGTA, GTA_CPED_PTR, [0x0]))
return Object("ID", getID(), "NAME", getUserName())
dwPlayers := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER])
for i, o in oPlayers {
if (__DWORD(hGTA, dwPlayers, [SAMP_REMOTEPLAYERS + i * 4, 0x0, 0x0, 0x2A4]) == dwPed)
return Object("ID", i, "NAME", o)
}
return ""
}
getPlayerPosition(playerID) {
if (playerID < 0 || !checkHandles() || playerID > getMaxPlayerID() || playerID == getID())
return ""
dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, SAMP_REMOTEPLAYERS + playerID * 4, 0x0, 0x0])
if (!dwAddress || dwAddress == "")
return ""
dwAddress := __DWORD(hGTA, dwAddress, [0x2A4, 0x14])
return [__READMEM(hGTA, dwAddress, [0x30], "Float"), __READMEM(hGTA, dwAddress, [0x34], "Float"), __READMEM(hGTA, dwAddress, [0x38], "Float")]
}
getClosestVehicleDriver(modelID := -1, skipOwn := 1) {
if ((modelID < 400 && modelID != -1) || modelID > 611 || !checkHandles() || !updateVehicles())
return ""
nearest := ""
dist := 10000.0
pos1 := getPlayerPos()
vehPTR := __DWORD(hGTA, GTA_VEHICLE_PTR, [0x0])
closestDriver := ""
playerID := getID()
for i, o in oVehicles {
if (modelID != -1 && modelID != o.MODELID || (skipOwn == 1 && o.PTR == vehPTR))
continue
dist2 := getDistance(pos1, getVehiclePosByPtr(o.PTR))
if (dist2 < dist && (driver := getVehicleDriverByPtr(o.PTR)) != "") {
if (skipOwn == 2 && driver.ID == playerID)
continue
dist := dist2
nearest := o
closestDriver := driver
}
}
return [closestDriver, dist]
}
getVehiclePassengers(vehicleID) {
if (vehicleID < 1 || vehicleID > SAMP_MAX_VEHICLES || !checkHandles() || !updatePlayers())
return ""
dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_VEHICLE, 0x4FB4 + vehicleID * 0x4])
if (dwAddress == 0x0 || dwAddress == "")
return ""
dwCPedPtr := __DWORD(hGTA, GTA_CPED_PTR, [0x0])
passengers := []
Loop, 10 {
if ((dwPED := __DWORD(hGTA, dwAddress + 0x45C, [4 * A_Index])) == 0x0)
continue
if (dwCPedPtr == dwPED)
passengers.Push(Object("SEAT", A_Index - 1, "PED", dwPED, "ID", getID(), "NAME", getUsername()))
else
passengers.Push(Object("SEAT", A_Index - 1, "PED", dwPED, "ID", 0xFFFF, "NAME", ""))
}
dwPlayers := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER])
for i, o in oPlayers {
for j, k in passengers {
if (__DWORD(hGTA, dwPlayers, [SAMP_REMOTEPLAYERS + i * 4, 0x0, 0x0, 0x2A4]) != k.PED)
continue
k.ID := i
k.NAME := o
}
}
return passengers
}
getMyVehiclePassengers() {
if (!checkHandles() || !updatePlayers())
return ""
dwAddress := __DWORD(hGTA, GTA_VEHICLE_PTR, [0x0])
if (!dwAddress)
return ""
dwCPedPtr := __DWORD(hGTA, GTA_CPED_PTR, [0x0])
passengers := []
Loop, 10 {
if ((dwPED := __DWORD(hGTA, dwAddress + 0x45C, [4 * A_Index])) == 0x0)
continue
if (dwCPedPtr == dwPED)
passengers.Push(Object("SEAT", A_Index - 1, "PED", dwPED, "ID", getID(), "NAME", getUsername()))
else
passengers.Push(Object("SEAT", A_Index - 1, "PED", dwPED, "ID", 0xFFFF, "NAME", ""))
}
dwPlayers := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER])
for i, o in oPlayers {
for j, k in passengers {
if (__DWORD(hGTA, dwPlayers, [SAMP_REMOTEPLAYERS + i * 4, 0x0, 0x0, 0x2A4]) != k.PED)
continue
k.ID := i
k.NAME := o
}
}
return passengers
}
updateVehicles() {
if (!checkHandles())
return false
if (vehicleTick + 1000 > A_TickCount)
return true
oVehicles := []
stVehiclePool := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_VEHICLE])
if (!stVehiclePool)
return false
vehicleCount := __DWORD(hGTA, stVehiclePool, [0x0])
Loop, % SAMP_MAX_VEHICLES {
if (!__DWORD(hGTA, stVehiclePool, [0x3074 + (A_Index - 1) * 0x4]))
continue
vehPtr := __DWORD(hGTA, stVehiclePool, [0x4FB4 + (A_Index - 1) * 0x4])
if (!vehPtr)
continue
oVehicles.Push(Object("ID", A_Index - 1, "PTR", vehPTR, "MODELID", __READMEM(hGTA, vehPtr, [0x22], "UShort")))
vehicleCount--
if (vehicleCount < 1)
break
}
vehicleTick := A_TickCount
return true
}
getVehiclePosByPtr(dwVehPtr) {
if (!dwVehPtr || !checkHandles())
return false
dwAddress := __DWORD(hGTA, dwVehPtr, [0x14])
if (!dwAddress)
return false
return [__READMEM(hGTA, dwAddress, [0x30], "Float"), __READMEM(hGTA, dwAddress, [0x34], "Float"), __READMEM(hGTA, dwAddress, [0x38], "Float")]
}
getClosestVehicle(modelID := -1, skipOwn := true) {
if ((modelID < 400 && modelID != -1) || modelID > 611 || !checkHandles() || !updateVehicles())
return ""
nearest := ""
dist := 10000.0
pos1 := getPlayerPos()
vehPTR := __DWORD(hGTA, GTA_VEHICLE_PTR, [0x0])
for i, o in oVehicles {
if (modelID != -1 && modelID != o.MODELID || (skipOwn && o.PTR == vehPTR))
continue
dist2 := getDistance(pos1, getVehiclePosByPtr(o.PTR))
if (dist2 < dist) {
dist := dist2
nearest := o
}
}
return nearest
}
getPlayerSkin() {
return !checkHandles() ? false : __READMEM(hGTA, GTA_CPED_PTR, [0x0, 0x22], "UShort")
}
getSkinID(dwID) {
if (!checkHandles() || dwID > SAMP_MAX_PLAYERS || dwID < 0)
return -1
dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER, SAMP_REMOTEPLAYERS + dwID * 4])
if (!dwAddress)
return -1
dwAddress := __DWORD(hGTA, dwAddress, [0x0])
if (!dwAddress)
return -1
dwAddress := __DWORD(hGTA, dwAddress, [0x0])
if (!dwAddress)
return -1
dwAddress := __DWORD(hGTA, dwAddress, [0x2A4])
if (!dwAddress)
return -1
skin := __READMEM(hGTA, dwAddress, [0x22], "UShort")
if (ErrorLevel)
return -1
return skin
}
setPlayerSkin(skinID) {
return checkHandles() && __CALL(hGTA, dwSAMP + 0x9A590, [["i", __DWORD(hGTA, dwSAMP, [SAMP_MISC_INFO_PTR, 0x8])], ["i", skinID]], false, true)
}
getPlayerPos() {
return !checkHandles() ? "" : [__READMEM(hGTA, 0xB6F2E4, [0x0], "Float"), __READMEM(hGTA, 0xB6F2E8, [0x0], "Float"), __READMEM(hGTA, 0xB6F2EC, [0x0], "Float")]
}
getDistance(pos1, pos2) {
return !pos1 || pos1 == "" || !pos2 || pos2 == "" ? -1 : Sqrt((pos1[1] - pos2[1]) * (pos1[1] - pos2[1]) + (pos1[2] - pos2[2]) * (pos1[2] - pos2[2]) + (pos1[3] - pos2[3]) * (pos1[3] - pos2[3]))
}
isKillInfoEnabled() {
return checkHandles() && __DWORD(hGTA, dwSAMP, [SAMP_KILL_INFO_PTR, 0x0])
}
toggleKillInfoEnabled(toggle := true) {
return checkHandles() && __WRITEMEM(hGTA, dwSAMP, [SAMP_KILL_INFO_PTR, 0x0], toggle ? 1 : 0, "UInt")
}
getKilledPlayers(bReset := false) {
if (!checkHandles())
return ""
kills := []
dwPlayers := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_PLAYER])
dwLocalPED := __DWORD(hGTA, GTA_CPED_PTR, [0x0])
Loop % getMaxPlayerID() + 1
{
dwRemoteplayer := __DWORD(hGTA, dwPlayers, [SAMP_REMOTEPLAYERS + (A_Index - 1) * 4])
if (!dwRemoteplayer)
continue
fHealth := __READMEM(hGTA, dwRemoteplayer, [0x0, 0x1BC], "Float")
if (fHealth > 0)
continue
dwSAMPActor := __DWORD(hGTA, dwRemoteplayer, [0x0, 0x0])
if (!dwSAMPActor)
continue
dwPED := __DWORD(hGTA, dwSAMPActor, [0x2A4])
if (!dwPED)
continue
dwMurderer := __DWORD(hGTA, dwPED, [0x764])
if (!dwMurderer || dwLocalPED != dwMurderer)
continue
if (bReset)
__WRITEMEM(hGTA, dwPED, [0x764], 0, "UInt")
kills.Push(Object("ID", A_Index - 1, "WEAPON", __DWORD(hGTA, dwPED, [0x760])))
}
return kills
}
getKillEntry(index) {
if (index < 0 || index > 4 || !checkHandles())
return false
dwAddress := __DWORD(hGTA, dwSAMP, [SAMP_KILL_INFO_PTR]) + 0x4
sVictim := __READSTRING(hGTA, dwAddress, [index * 0x3B], 25)
sKiller := __READSTRING(hGTA, dwAddress, [index * 0x3B + 0x19], 25)
dwVictimColor := __READMEM(hGTA, dwAddress, [index * 0x3B + 0x32], "UInt")
dwKillerColor := __READMEM(hGTA, dwAddress, [index * 0x3B + 0x36], "UInt")
bReason := __READMEM(hGTA, dwAddress, [index * 0x3B + 0x3A], "UChar")
return Object("VICTIM", sVictim, "KILLER", sKiller, "VCOLOR", dwVictimColor, "KCOLOR", dwKillerColor, "REASON", bReason)
}
addKillEntry(victimName := " ", killerName := " ", victimColor := 0xFFFFFFFF, killerColor := 0xFFFFFFFF, reason := 255) {
return checkHandles() && __CALL(hGTA, dwSAMP + 0x66930, [["i", __DWORD(hGTA, dwSAMP, [SAMP_KILL_INFO_PTR])], ["s", victimName], ["s", killerName], ["i", victimColor], ["i", killerColor], ["i", reason]], false, true)
}
playAudioStream(url) {
return checkHandles() && __CALL(hGTA, dwSAMP + 0x62DA0, [["s", url], ["i", 0], ["i", 0], ["i", 0], ["i", 0], ["i", 0]], false)
}
stopAudioStream() {
return checkHandles() && __CALL(hGTA, dwSAMP + 0x629A0, [["i", 1]], false)
}
playSound(soundID) {
return checkHandles() && __CALL(hGTA, 0x506EA0, [["i", 0xB6BC90], ["i", soundID], ["i", 0], ["f", 1.0]], false, true)
}
playAudioEvent(eventID) {
if (!checkHandles())
return false
VarSetCapacity(buf, 12, 0)
NumPut(0, buf, 0, "Float")
NumPut(0, buf, 4, "Float")
NumPut(0, buf, 8, "Float")
if (!__WRITERAW(hGTA, pMemory + 20, &buf, 12))
return false
return __CALL(hGTA, 0x507340, [["i", pMemory + 20], ["i", eventID]], false, false)
}
addDelimiters(value, delimiter := ".") {
return RegExReplace(Round(value), "\G\d+?(?=(\d{3})+(?:\D|$))", "$0" delimiter)
}
checkHandles() {
return !refreshGTA() || !refreshSAMP() || !refreshMemory() ? false : true
}
refreshGTA() {
if (!(newPID := getPID("GTA:SA:MP"))) {
if (hGTA) {
virtualFreeEx(hGTA, pMemory, 0, 0x8000)
closeProcess(hGTA)
}
dwGTAPID := 0, hGTA := 0x0, dwSAMP := 0x0, pMemory := 0x0
return false
}
if (!hGTA || dwGTAPID != newPID) {
if (!(hGTA := openProcess(newPID))) {
dwGTAPID := 0, hGTA := 0x0, dwSAMP := 0x0, pMemory := 0x0
return false
}
dwGTAPID := newPID, dwSAMP := 0x0, pMemory := 0x0
}
return true
}
refreshSAMP() {
if (dwSAMP)
return true
dwSAMP := getModuleBaseAddress("samp.dll", hGTA)
if (!dwSAMP)
return false
if (__READMEM(hGTA, dwSAMP, [0x1036], "UChar") != 0xD8) {
msgbox, 64, % "SA:MP Version nicht kompatibel", % "Die installierte SA:MP Version ist nicht mit dem Keybinder kompatibel.`nBitte installiere die Version 0.3.7 um den Keybinder nutzen zu kˆnnen."
ExitApp
}
return true
}
refreshMemory() {
if (!pMemory) {
pMemory := virtualAllocEx(hGTA, 6384, 0x1000 | 0x2000, 0x40)
if (ErrorLevel) {
pMemory := 0x0
return false
}
pInjectFunc := pMemory + 5120
pDetours	:= pInjectFunc + 1024
}
return true
}
queryPerformance() {
Static QPCLAST, QPCNOW, QPCFREQ
if not QPCFREQ
if not DllCall("QueryPerformanceFrequency", "Int64 *", QPCFREQ)
return "Fail QPF"
QPCLAST=%QPCNOW%
if not DllCall("QueryPerformanceCounter", "Int64 *", QPCNOW)
return "Fail QPC"
return (QPCNOW-QPCLAST)/QPCFREQ
}
getTownNumber() {
if (!checkHandles())
return false
pos := getPlayerPos()
VarSetCapacity(struct, 12, 0)
NumPut(pos[1], &struct, 0, "Float")
NumPut(pos[2], &struct, 4, "Float")
NumPut(pos[3], &struct, 8, "Float")
return !__WRITERAW(hGTA, pMemory + 1024, &struct, 63) ? -1 : __CALL(hGTA, 0x572300, [["i", pMemory + 1024]], true, false, true)
}
getCity(x, y, z) {
if (z > 900.0)
return "Interior"
for i, o in cities {
if (x >= o.X1 && y >= o.Y1 && x <= o.X2 && y <= o.Y2)
return o.NAME
}
return "Unbekannt"
}
getZone(x, y, z) {
if (z > 900.0)
return "Interior"
for i, o in zones {
if (x >= o.X1 && y >= o.Y1 && x <= o.X2 && y <= o.Y2)
return o.NAME
}
return "Unbekannt"
}
global aInterface := []
aInterface["HealthX"] 			:= Object("ADDRESSES", [0x58EE87], "DEFAULT_POINTER", 0x86535C, "DEFAULT_VALUE", 141.0, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["HealthY"] 			:= Object("ADDRESSES", [0x58EE68], "DEFAULT_POINTER", 0x866CA8, "DEFAULT_VALUE", 77.0, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["HealthWidth"] 		:= Object("ADDRESSES", [0x5892D8], "DEFAULT_POINTER", 0x866BB8, "DEFAULT_VALUE", 109.0, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["HealthHeight"] 		:= Object("ADDRESSES", [0x589358], "DEFAULT_POINTER", 0x85EED4, "DEFAULT_VALUE", 9.0, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["HealthColor"] 		:= Object("ADDRESSES", [0x58932A], "DEFAULT_POINTER", null, "DEFAULT_VALUE", 0, "VALUE_TYPE", "Byte", "DETOUR_ADDRESS", null)
aInterface["HealthBorder"] 		:= Object("ADDRESSES", [0x589353], "DEFAULT_POINTER", null, "DEFAULT_VALUE", 1, "VALUE_TYPE", "Byte", "DETOUR_ADDRESS", null)
aInterface["HealthPercentage"] 	:= Object("ADDRESSES", [0x589355], "DEFAULT_POINTER", null, "DEFAULT_VALUE", 0, "VALUE_TYPE", "Byte", "DETOUR_ADDRESS", null)
aInterface["ArmorX"] 			:= Object("ADDRESSES", [0x58EF59], "DEFAULT_POINTER", 0x866B78, "DEFAULT_VALUE", 94.0, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["ArmorY"] 			:= Object("ADDRESSES", [0x58EF3A], "DEFAULT_POINTER", 0x862D38, "DEFAULT_VALUE", 48.0, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["ArmorWidth"] 		:= Object("ADDRESSES", [0x58915D], "DEFAULT_POINTER", 0x86503C, "DEFAULT_VALUE", 62.0, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["ArmorHeight"] 		:= Object("ADDRESSES", [0x589146], "DEFAULT_POINTER", 0x85EED4, "DEFAULT_VALUE", 9.0, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["ArmorColor"] 		:= Object("ADDRESSES", [0x5890F5], "DEFAULT_POINTER", null, "DEFAULT_VALUE", 4, "VALUE_TYPE", "Byte", "DETOUR_ADDRESS", null)
aInterface["ArmorBorder"] 		:= Object("ADDRESSES", [0x589123], "DEFAULT_POINTER", null, "DEFAULT_VALUE", 1, "VALUE_TYPE", "Byte", "DETOUR_ADDRESS", null)
aInterface["ArmorPercentage"] 	:= Object("ADDRESSES", [0x589125], "DEFAULT_POINTER", null, "DEFAULT_VALUE", 0, "VALUE_TYPE", "Byte", "DETOUR_ADDRESS", null)
aInterface["BreathX"] 			:= Object("ADDRESSES", [0x58F11F], "DEFAULT_POINTER", 0x866B78, "DEFAULT_VALUE", 94.0, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["BreathY"] 			:= Object("ADDRESSES", [0x58F100], "DEFAULT_POINTER", 0x86503C, "DEFAULT_VALUE", 62.0, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["BreathWidth"] 		:= Object("ADDRESSES", [0x589235], "DEFAULT_POINTER", 0x86503C, "DEFAULT_VALUE", 62.0 ,"VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["BreathHeight"] 		:= Object("ADDRESSES", [0x58921E], "DEFAULT_POINTER", 0x85EED4, "DEFAULT_VALUE", 9.0, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["BreathColor"] 		:= Object("ADDRESSES", [0x5891E4], "DEFAULT_POINTER", null, "DEFAULT_VALUE", 3, "VALUE_TYPE", "Byte", "DETOUR_ADDRESS", null)
aInterface["BreathBorder"] 		:= Object("ADDRESSES", [0x589207], "DEFAULT_POINTER", null, "DEFAULT_VALUE", 1, "VALUE_TYPE", "Byte", "DETOUR_ADDRESS", null)
aInterface["BreathPercentage"] 	:= Object("ADDRESSES", [0x589209], "DEFAULT_POINTER", null, "DEFAULT_VALUE", 0, "VALUE_TYPE", "Byte", "DETOUR_ADDRESS", null)
aInterface["MoneyX"] 			:= Object("ADDRESSES", [0x58F5FC], "DEFAULT_POINTER", 0x85950C, "DEFAULT_VALUE", 32.0, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["MoneyY"] 			:= Object("ADDRESSES", [0x58F5DC], "DEFAULT_POINTER", 0x866C88, "DEFAULT_VALUE", 89.0, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["MoneyXScale"] 		:= Object("ADDRESSES", [0x58F564], "DEFAULT_POINTER", 0x866CAC, "DEFAULT_VALUE", 0.55 ,"VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["MoneyYScale"] 		:= Object("ADDRESSES", [0x58F54E], "DEFAULT_POINTER", 0x858F14, "DEFAULT_VALUE", 1.1, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["MoneyColor"] 		:= Object("ADDRESSES", [0x58F492], "DEFAULT_POINTER", null, "DEFAULT_VALUE", 1, "VALUE_TYPE", "Byte", "DETOUR_ADDRESS", null)
aInterface["MoneyColorDebt"] 	:= Object("ADDRESSES", [0x58F4D4], "DEFAULT_POINTER", null, "DEFAULT_VALUE", 0, "VALUE_TYPE", "Byte", "DETOUR_ADDRESS", null)
aInterface["WeaponX"] 			:= Object("ADDRESSES", [0x58F92F], "DEFAULT_POINTER", 0x866C84, "DEFAULT_VALUE", 0.17343046, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["WeaponIconX"] 		:= Object("ADDRESSES", [0x58F927], "DEFAULT_POINTER", 0x85950C, "DEFAULT_VALUE", 32.0, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["WeaponIconY"] 		:= Object("ADDRESSES", [0x58F913], "DEFAULT_POINTER", 0x858BA4, "DEFAULT_VALUE", 20.0, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["WeaponAmmoY"] 		:= Object("ADDRESSES", [0x58F9DC], "DEFAULT_POINTER", 0x858BA4, "DEFAULT_VALUE", 20.0, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["WeaponAmmoX"] 		:= Object("ADDRESSES", [0x58F9F7], "DEFAULT_POINTER", 0x866C84, "DEFAULT_VALUE", 0.17343046, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["WeaponIconWidth"] 	:= Object("ADDRESSES", [0x58FAAB], "DEFAULT_POINTER", 0x866C4C, "DEFAULT_VALUE", 47.0, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["WeaponAmmoHeight"]	:= Object("ADDRESSES", [0x5894B7], "DEFAULT_POINTER", 0x858CB0, "DEFAULT_VALUE", 0.7, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["WeaponAmmoWidth"]	:= Object("ADDRESSES", [0x5894CD], "DEFAULT_POINTER", 0x858C24, "DEFAULT_VALUE", 0.3, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["WantedX"] 			:= Object("ADDRESSES", [0x58DD0F], "DEFAULT_POINTER", 0x863210, "DEFAULT_VALUE", 29.0, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["WantedY"] 			:= Object("ADDRESSES", [0x58DDFC], "DEFAULT_POINTER", 0x866C5C, "DEFAULT_VALUE", 114.0, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["WantedEmptyY"] 		:= Object("ADDRESSES", [0x58DE27], "DEFAULT_POINTER", 0x858CCC, "DEFAULT_VALUE", 12.0, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["WantedXScale"] 		:= Object("ADDRESSES", [0x58DCC0], "DEFAULT_POINTER", 0x866C60, "DEFAULT_VALUE", 0.605, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["WantedYScale"] 		:= Object("ADDRESSES", [0x58DCAA], "DEFAULT_POINTER", 0x866C64, "DEFAULT_VALUE", 1.21, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["WantedColor"] 		:= Object("ADDRESSES", [0x58DDC9], "DEFAULT_POINTER", null, "DEFAULT_VALUE", 6, "VALUE_TYPE", "Byte", "DETOUR_ADDRESS", null)
aInterface["RadioY"] 			:= Object("ADDRESSES", [0x4E9FD8], "DEFAULT_POINTER", 0x858F8C, "DEFAULT_VALUE", 22.0, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["RadioXScale"] 		:= Object("ADDRESSES", [0x4E9F38], "DEFAULT_POINTER", 0x858CC8, "DEFAULT_VALUE", 0.6, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["RadioYScale"] 		:= Object("ADDRESSES", [0x4E9F22], "DEFAULT_POINTER", 0x858C20, "DEFAULT_VALUE", 0.9, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["RadioColor"] 		:= Object("ADDRESSES", [0x4E9F91], "DEFAULT_POINTER", null, "DEFAULT_VALUE", 6, "VALUE_TYPE", "Byte", "DETOUR_ADDRESS", null)
aInterface["RadarX"] 			:= Object("ADDRESSES", [0x58A79B, 0x5834D4, 0x58A836, 0x58A8E9, 0x58A98A, 0x58A469, 0x58A5E2, 0x58A6E6], "DEFAULT_POINTER", 0x858A10, "DEFAULT_VALUE", 40.0, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["RadarY"] 			:= Object("ADDRESSES", [0x58A7C7, 0x58A868, 0x58A913, 0x58A9C7, 0x583500, 0x58A499, 0x58A60E, 0x58A71E], "DEFAULT_POINTER", 0x866B70, "DEFAULT_VALUE", 104.0, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["RadarHeight"]		:= Object("ADDRESSES", [0x58A47D, 0x58A632, 0x58A6AB, 0x58A70E, 0x58A801, 0x58A8AB, 0x58A921, 0x58A9D5, 0x5834F6], "DEFAULT_POINTER", 0x866B74, "DEFAULT_VALUE", 76.0, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["RadarWidth"]		:= Object("ADDRESSES", [0x5834C2, 0x58A449, 0x58A7E9, 0x58A840, 0x58A943, 0x58A99D], "DEFAULT_POINTER", 0x866B78, "DEFAULT_VALUE", 94.0, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["RadarScaleWidth"]	:= Object("ADDRESSES", [0x5834EE, 0x58A475, 0x58A602, 0x58A706, 0x58A7BB, 0x58A85C, 0x58A90B, 0x58A9BF], "DEFAULT_POINTER", 0x859524, "DEFAULT_VALUE", 0.002232143, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["RadarScaleHeight"]	:= Object("ADDRESSES", [0x5834BC, 0x58A443, 0x58A5DA, 0x58A6E0, 0x58A793, 0x58A830, 0x58A8E1, 0x58A984], "DEFAULT_POINTER", 0x859520, "DEFAULT_VALUE", 0.0015625, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["Radar-Tilt-XPos"] 	:= Object("ADDRESSES", [0x58A469], "DEFAULT_POINTER", 0x858A10, "DEFAULT_VALUE", 40.0, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["Radar-Tilt-YPos"] 	:= Object("ADDRESSES", [0x58A499], "DEFAULT_POINTER", 0x866B70, "DEFAULT_VALUE", 104.0, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["Radar-Height-XPos"] := Object("ADDRESSES", [0x58A5E2, 0x58A6E6], "DEFAULT_POINTER", 0x858A10, "DEFAULT_VALUE", 40.0, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
aInterface["Radar-Height-YPos"] := Object("ADDRESSES", [0x58A60E, 0x58A71E], "DEFAULT_POINTER", 0x866B70, "DEFAULT_VALUE", 104.0, "VALUE_TYPE", "Float", "DETOUR_ADDRESS", null)
setHUDValue(sName, value) {
if (!aInterface.HasKey(sName) || !checkHandles())
return false
oKey := aInterface[sName]
dwAddress := oKey.DEFAULT_POINTER != null ? pDetours + (getKeyIndex(sName) - 1) * 4 : oKey.ADDRESSES[1]
if (value = "DEFAULT")
value := oKey.DEFAULT_VALUE
else if (value = "RESET")
{
if (oKey.DEFAULT_POINTER != null)
{
for i, o in oKey.ADDRESSES {
__WRITEMEM(hGTA, o, [0x0], oKey.DEFAULT_POINTER, "UInt")
if (ErrorLevel)
return false
}
return true
}
else
value := oKey.DEFAULT_VALUE
}
else if (oKey.DEFAULT_POINTER != null && (oKey.DETOUR_ADDRESS == null || __READMEM(hGTA, oKey.ADDRESSES[1], [0x0], "UInt") != oKey.DETOUR_ADDRESS))
{
__WRITEMEM(hGTA, dwAddress, [0x0], oKey.DEFAULT_VALUE, oKey.VALUE_TYPE)
if (ErrorLevel)
return false
oKey.DETOUR_ADDRESS := dwAddress
for i, o in oKey.ADDRESSES {
__WRITEMEM(hGTA, o, [0x0], dwAddress, "UInt")
if (ErrorLevel)
return false
}
}
__WRITEMEM(hGTA, dwAddress, [0x0], value, oKey.VALUE_TYPE)
if (ErrorLevel)
return false
return true
}
resetHUD() {
for i, o in aInterface
{
for k, v in o.ADDRESSES {
if (o.DEFAULT_POINTER != null)
__WRITEMEM(hGTA, v, [0x0], o.DEFAULT_POINTER, "UInt")
else
__WRITEMEM(hGTA, v, [0x0], o.DEFAULT_VALUE, o.VALUE_TYPE)
}
}
if (ErrorLevel)
return false
return true
}
getKeyIndex(sKey) {
for i, o in aInterface {
if (aInterface[sKey] == o)
return A_Index
}
return false
}
PlayerInput(text) {
s := A_IsSuspended
Suspend On
KeyWait Enter
;BlockChatInput()
SendInput t^a{backspace}%text%
Input, var, v, {enter}
SendInput ^a{backspace 100}{enter}
Sleep, 20
;unBlockChatInput()
if(!s)
Suspend Off
return var
}
getFPS() {
	if (!checkHandles())
		return 0
	static timev := A_TickCount
	static val   := readDWORD(hGTA, 0xB7CB4C)
	temp := readDWORD(hGTA, 0xB7CB4C)
	ret := (temp-val)/(A_TickCount-timev)*1000
	timev := A_TickCount
	val := temp
	return Round(ret)
}
OnPlayerCommand(command) {
	RegExMatch(command, "/(\S*)(\s*)(.*)", var)
	for i, o in aliases {
		if (o.ALIAS = var1) {
			var1 := o.COMMAND
			break
		}
	}
	if (!CMD_%var1%(var3) && !InStr("/q/quit/save/rs/interior/fpslimit/headmove/timestamp/dl/nametagstatus/mem/audiomsg/fontsize/ctd/rcon/", "/" . var1 . "/"))
		return false
	return true
}

sendDialogResponseWait(dialogID, buttonID, listIndex := 0xFFFF, inputResponse := "") {
	Loop, 100 {
		if (getDialogID() == dialogID) {
			sendDialogResponse(dialogID, buttonID, listIndex, inputResponse)
			return true
		}
		sleep, 20
	}
	unblockDialog()
	return false
}

waitForDialogID(dialogID) {
	Loop, 100 {
		if (getDialogID() == dialogID) {
			sleep, 300
			return true
		}
		sleep, 20
	}
	unblockDialog()
	return false
}

getMedicIdentifier(vehID) {
	for i, o in medicVehicles {
		if (vehID == o.ID)
			return o.TEXT
	}
	return medicRang " " getUsername()
}

getGender(playerID) {
	skin := getSkinID(playerID)
	if (skin < 1)
		return ""
	return SubStr(skinGender, skin + 1, 1) ? "Herr " : "Frau "
}

printFreunde() {
	static players := []
	static init := true
	if(init) {
		init := false
		Loop, % SAMP_PLAYER_MAX
		{
			players[A_Index-1] := getPlayerNameById(A_Index-1)
		}
		return
	}
	Loop, % SAMP_PLAYER_MAX
	{
		i := A_Index-1
		name := getPlayerNameById(i)
		if(name) {
			if(name != players[i]) {
				if(players[i]) {
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
							if instr(A_Loopreadline,players[i])
							{
								Existiert := 1
							}
							Zeile := A_Index
						}
					}
					if(Existiert == 1)
					{
						ChatMessage(players[i] " (ID: " i ") hat den Server verlassen")
					}
				}
				players[i] := name
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
						if instr(A_Loopreadline,players[i])
						{
							Existiert := 1
						}
						Zeile := A_Index
					}
				}
				if(Existiert == 1)
				{
					ChatMessage(players[i] " (ID: " i ") hat den Server betreten")
				}
			}
		}
		else {
			if(players[i]) {
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
						if instr(A_Loopreadline,players[i])
						{
							Existiert := 1
						}
						Zeile := A_Index
					}
				}
				if(Existiert == 1)
				{
					ChatMessage(players[i] " (ID: " i ") hat den Server verlassen")
					players[i] := ""
				}
			}
		}
	}
}

fpsUnlock() {
if (!checkHandles())
return 0
global instruction
instruction := readMem(hGTA, dwSAMP + 0x9D9D0, 4, "UInt")
return writeMemory(hGTA, dwSAMP + 0x9D9D0, 0x5051FF15, 4, "UChar")
}
fpsLock() {
if (!checkHandles())
return 0
global instruction
if (instruction) {
return writeMemory(hGTA, dwSAMP + 0x9D9D0, instruction, 4, "UInt")
} else {
return false
}
}

findLinie() {
	busLine := 0
	distance := 10000000
	coords := getCoordinates()
	global oTextLabelData
	if (!updateTextLabelData())
		return
	vehicleID := getVehicleID()
	for i, o in oTextLabelData {
		if (o.VEHICLEID == vehicleID) {
			FileAppend, % o.TEXT, textlabel.txt
			if (RegExMatch(o.TEXT, "Linie (\d+)\n(.+)", label_)) {
				busLine := label_1
			}
			break
		}
	}
	return busLine
}

getCoordinates() {
if(!checkHandles())
return ""
fX := readFloat(hGTA, ADDR_POSITION_X)
if(ErrorLevel) {
ErrorLevel := ERROR_READ_MEMORY
return ""
}
fY := readFloat(hGTA, ADDR_POSITION_Y)
if(ErrorLevel) {
ErrorLevel := ERROR_READ_MEMORY
return ""
}
fZ := readFloat(hGTA, ADDR_POSITION_Z)
if(ErrorLevel) {
ErrorLevel := ERROR_READ_MEMORY
return ""
}
ErrorLevel := ERROR_OK
return [fX, fY, fZ]
}

updateTextLabelData() {
if (!checkHandles())
return 0
if (iRefreshTL+iUpdateTickTL > A_TickCount)
return 1
oTextLabelData := []
iRefreshTL := A_TickCount
dwAddress := readDWORD(hGTA, dwSAMP + SAMP_INFO_OFFSET)
if (ErrorLevel || dwAddress==0) {
ErrorLevel := ERROR_READ_MEMORY
return 0
}
dwAddress := readDWORD(hGTA, dwAddress + SAMP_PPOOLS_OFFSET)
if (ErrorLevel || dwAddress==0) {
ErrorLevel := ERROR_READ_MEMORY
return 0
}
dwTextLabels := readDWORD(hGTA, dwAddress + 12)
if (ErrorLevel || dwTextDraws==0) {
ErrorLevel := ERROR_READ_MEMORY
return 0
}
Loop, % 2048
{
i := A_Index-1
dwIsActive := readDWORD(hGTA, dwTextLabels + 59392 + i*4)
if (ErrorLevel) {
ErrorLevel := ERROR_READ_MEMORY
return 0
}
if (dwIsActive==0)
continue
dwAddr := readDWORD(hGTA, dwTextLabels + i*29)
if (ErrorLevel) {
ErrorLevel := ERROR_READ_MEMORY
return 0
}
if (dwAddr==0)
continue
sText := readString(hGTA, dwAddr, 256)
if (ErrorLevel) {
ErrorLevel := ERROR_READ_MEMORY
return 0
}
fX := readFloat(hGTA, dwTextLabels + i*29 +8)
if (ErrorLevel) {
ErrorLevel := ERROR_READ_MEMORY
return 0
}
fY := readFloat(hGTA, dwTextLabels + i*29 +12)
if (ErrorLevel) {
ErrorLevel := ERROR_READ_MEMORY
return 0
}
fZ := readFloat(hGTA, dwTextLabels + i*29 +16)
if (ErrorLevel) {
ErrorLevel := ERROR_READ_MEMORY
return 0
}
wPlayerID := readMem(hGTA, dwTextLabels + i * 0x1D + 0x19, 2, "UShort")
wVehicleID := readMem(hGTA, dwTextLabels + i * 0x1D + 0x1B, 2, "UShort")
oTextLabelData[i] := Object("TEXT", sText, "XPOS", fX , "YPOS", fY , "ZPOS", fZ, "PLAYERID", wPlayerID, "VEHICLEID", wVehicleID)
}
ErrorLevel := ERROR_OK
return 1
}

getUnixTimestamp(time_orig) {
StringLeft, now_year, time_orig, 4
StringMid, now_month, time_orig, 5, 2
StringMid, now_day, time_orig, 7, 2
StringMid, now_hour, time_orig, 9, 2
StringMid, now_min, time_orig, 11, 2
StringRight, now_sec, time_orig, 2
year_sec := 31536000 * (now_year - 1970)
leap_days := (now_year - 1972) / 4 + 1
Transform, leap_days, Floor, %leap_days%
this_leap := now_year/4
Transform, this_leap_round, Floor, %this_leap%
if (this_leap = this_leap_round) {
if (now_month <= 2) {
leap_days--
}
}
leap_sec := leap_days * 86400
if (now_month == 01)
month_sec = 0
if (now_month == 02)
month_sec = 2678400
if (now_month == 03)
month_sec = 5097600
if (now_month == 04)
month_sec = 7776000
if (now_month == 05)
month_sec = 10368000
if (now_month == 06)
month_sec = 13046400
if (now_month == 07)
month_sec = 15638400
if (now_month == 08)
month_sec = 18316800
if (now_month == 09)
month_sec = 20995200
if (now_month == 10)
month_sec = 23587200
if (now_month == 11)
month_sec = 26265600
if (now_month == 12)
month_sec = 28857600
day_sec := (now_day - 1) * 86400
hour_sec := now_hour * 3600
min_sec := now_min * 60
date_sec := year_sec + month_sec + day_sec + leap_sec + hour_sec + min_sec + now_sec
return date_sec
}

formatTime(time) {
	hours := Floor(time / 60 / 60)
	minutes := Floor(time / 60) - hours * 60
	seconds := time - minutes * 60 - hours * 60 * 60
	time := ""
	if (hours > 0) {
		time .= hours
		if (minutes > 0) {
			time .= ":"
		} else if (seconds > 0) {
			time .= ":"
		}
	}
	if (minutes > 0) {
		if(Minutes < 10) {
			time .= "0" . minutes
		} else {
			time .= minutes
		}
		if (seconds > 0) {
			time .= ":"
		}
		else
		{
			time .= ":00"
		}
	}
	else
	{
		time .= "00:"
	}
	if (seconds > 0 || (minutes == 0 && hours == 0)) {
		if(Seconds < 10) {
			time .= "0" . seconds
		} else {
			time .= seconds
		}
	}
	return time
}

changeTextDrawColors() {
	if (!checkHandles())
		return false
	setHUDValue("ArmorColor", 11)
	setHUDValue("BreathColor", 14)
	__WRITEMEM(hGTA, 0xBAB22C, [4 * 0], 0xFF1F1FE0, "UInt")
	__WRITEMEM(hGTA, 0xBAB22C, [4 * 1], 0xFF009933, "UInt")
	__WRITEMEM(hGTA, 0xBAB22C, [4 * 2], 0xFFFF901E, "UInt")
	__WRITEMEM(hGTA, 0xBAB22C, [4 * 4], 0xFFFFFFFF, "UInt")
	__WRITEMEM(hGTA, 0xBAB22C, [4 * 6], 0xFF00D7FF, "UInt")
	__WRITEMEM(hGTA, 0xBAB22C, [4 * 11], 0xFF00D7FF, "UInt")
	return true
}

changeServerTextdraws() {
if (!checkHandles())
return false
dwSAMPTextDraws := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_TEXTDRAW])
dwAddress := __DWORD(hGTA, dwSAMPTextDraws, [0x4400])
__WRITEMEM(hGTA, dwAddress, [SAMP_TEXTDRAW_FONT], 3, "UInt")
__WRITEMEM(hGTA, dwAddress, [SAMP_TEXTDRAW_LETTERWIDTH], 0.28, "Float")
__WRITEMEM(hGTA, dwAddress, [SAMP_TEXTDRAW_LETTERHEIGHT], 1.0, "Float")
__WRITEMEM(hGTA, dwAddress, [SAMP_TEXTDRAW_XPOS], 15.0, "Float")
__WRITEMEM(hGTA, dwAddress, [SAMP_TEXTDRAW_YPOS], 315.0, "Float")
dwAddress := __DWORD(hGTA, dwSAMPTextDraws, [0x4450])
__WRITEMEM(hGTA, dwAddress, [SAMP_TEXTDRAW_FONT], 3, "UInt")
__WRITEMEM(hGTA, dwAddress, [SAMP_TEXTDRAW_LETTERWIDTH], 0.28, "Float")
__WRITEMEM(hGTA, dwAddress, [SAMP_TEXTDRAW_LETTERHEIGHT], 1.0, "Float")
__WRITEMEM(hGTA, dwAddress, [SAMP_TEXTDRAW_XPOS], 540.0, "Float")
__WRITEMEM(hGTA, dwAddress, [SAMP_TEXTDRAW_YPOS], 12.0, "Float")
__WRITEMEM(hGTA, dwAddress, [SAMP_TEXTDRAW_RIGHT], 1, "UChar")
dwAddress := __DWORD(hGTA, dwSAMPTextDraws, [0x2428])
__WRITEMEM(hGTA, dwAddress, [SAMP_TEXTDRAW_FONT], 3, "UInt")
__WRITEMEM(hGTA, dwAddress, [SAMP_TEXTDRAW_XPOS], 15.0, "Float")
setHUDValue("RadarX", 15.0)
setHUDValue("Radar-Height-XPos", 140.0)
return true
}

resetTextDrawColors() {
	if (!checkHandles())
		return false
	__WRITEMEM(hGTA, 0xBAB22C, [4 * 0], 0xFF1D19B4, "UInt")
	__WRITEMEM(hGTA, 0xBAB22C, [4 * 1], 0xFF2C6836, "UInt")
	__WRITEMEM(hGTA, 0xBAB22C, [4 * 2], 0xFF7F3C32, "UInt")
	__WRITEMEM(hGTA, 0xBAB22C, [4 * 4], 0xFFE1E1E1, "UInt")
	__WRITEMEM(hGTA, 0xBAB22C, [4 * 6], 0xFF106290, "UInt")
	__WRITEMEM(hGTA, 0xBAB22C, [4 * 11], 0xFF63C0E2, "UInt")
	return true
}

resetServerTextdraws() {
if (!checkHandles())
return false
resetHUD()
dwSAMPTextDraws := __DWORD(hGTA, dwSAMP, [SAMP_INFO_PTR, SAMP_POOLS, SAMP_POOL_TEXTDRAW])
dwAddress := __DWORD(hGTA, dwSAMPTextDraws, [0x4400])
__WRITEMEM(hGTA, dwAddress, [SAMP_TEXTDRAW_FONT], 1, "UInt")
__WRITEMEM(hGTA, dwAddress, [SAMP_TEXTDRAW_LETTERWIDTH], 0.31, "Float")
__WRITEMEM(hGTA, dwAddress, [SAMP_TEXTDRAW_LETTERHEIGHT], 1.085, "Float")
__WRITEMEM(hGTA, dwAddress, [SAMP_TEXTDRAW_XPOS], 35.0, "Float")
__WRITEMEM(hGTA, dwAddress, [SAMP_TEXTDRAW_YPOS], 321.0, "Float")
dwAddress := __DWORD(hGTA, dwSAMPTextDraws, [0x4450])
__WRITEMEM(hGTA, dwAddress, [SAMP_TEXTDRAW_FONT], 2, "UInt")
__WRITEMEM(hGTA, dwAddress, [SAMP_TEXTDRAW_LETTERWIDTH], 0.19, "Float")
__WRITEMEM(hGTA, dwAddress, [SAMP_TEXTDRAW_LETTERHEIGHT], 0.9, "Float")
__WRITEMEM(hGTA, dwAddress, [SAMP_TEXTDRAW_XPOS], 406.0, "Float")
__WRITEMEM(hGTA, dwAddress, [SAMP_TEXTDRAW_YPOS], 27.0, "Float")
__WRITEMEM(hGTA, dwAddress, [SAMP_TEXTDRAW_RIGHT], 0, "UChar")
dwAddress := __DWORD(hGTA, dwSAMPTextDraws, [0x2428])
__WRITEMEM(hGTA, dwAddress, [SAMP_TEXTDRAW_FONT], 2, "UInt")
__WRITEMEM(hGTA, dwAddress, [SAMP_TEXTDRAW_XPOS], 26.0, "Float")
return true
}


getFishPrice(fish, lbs) {
	global
	price := ""
	if(fish == "Thunfisch"){
		price := Floor(lbs*8)
	}else if(fish == "Hecht"){
		price := Floor(lbs*9)
	}else if(fish == "Schildkrˆte"){
		price := Floor(lbs*10)
	}else if(fish == "Forelle"){
		price := Floor(lbs*3)
	}else if(fish == "Makrele"){
		price := Floor(lbs*8)
	}else if(fish == "Delphin"){
		price := Floor(lbs*4)
	}else if(fish == "Zackenbarsch"){
		price := Floor(lbs*2)
	}else if(fish == "Katzenfisch"){
		price := Floor(lbs*4)
	}else if(fish == "Wolfbarsch"){
		price := Floor(lbs*8)
	}else if(fish == "Hai"){
		price := Floor(lbs*7)
	}else if(fish == "Bernfisch"){
		price := Floor(lbs*1)
	}else if(fish == "Aal"){
		price := Floor(lbs*6)
	}else if(fish == "Schwertfisch"){
		price := Floor(lbs*2)
	}else if(fish == "Roter Schnapper"){
		price := Floor(lbs*2)
	}else if(fish == "Blauer F‰cherfisch"){
		price := Floor(lbs*1)
	}else if(fish == "Segelfisch"){
		price := Floor(lbs*4)
	}else{
		price := 0
	}
	return price
}

replaceVariables(msg) {
Username := getUsername()
PlayerId := getID()
PlayerScore := getScore()
PlayerPing := getPing()
PlayerHealth := getPlayerHealth()
PlayerArmor := getPlayerArmor()
PlayerMoney := getMoney()
PlayerZone := getPlayerZone()
PlayerCity := getPlayerCity()
space := " "
FormatTime,h,,HH
FormatTime,m,,mm
StringReplace, msg, msg, {Leertaste}, %space%, All
StringReplace, msg, msg, {Spielername}, %Username%, All
StringReplace, msg, msg, {ID}, %PlayerId%  , All
StringReplace, msg, msg, {Level}, %PlayerScore%, All
StringReplace, msg, msg, {Ping}, %PlayerPing%, All
StringReplace, msg, msg, {Leben}, %PlayerHealth%, All
StringReplace, msg, msg, {Ruestung}, %PlayerArmor%, All
StringReplace, msg, msg, {Bargeld}, %PlayerMoney%, All
StringReplace, msg, msg, {Zone}, %PlayerZone%, All
StringReplace, msg, msg, {Stadt}, %PlayerCity%, All
StringReplace, msg, msg, {Uhrzeit}, %h%:%m%, All
return msg
}

sendKeybind(KeyText) {
	KeyText := replaceVariables(KeyText)
	if (InStr(KeyText,"&&")) {
		Loop, parse, KeyText, "&&",
		{
			msg = %A_LoopField%
			if(msg != "" && msg != " ") {
				IfInString, msg, {Return}
				{
					StringReplace, msg, msg, {Return}, , All
					SendChat(msg)
				} else {
					msg := replaceVariables(msg)
					SendInput, t%msg%
				}
			}
		}
	} else {
		SendChat(KeyText)
	}
	return
}

SendChatNoAPI(KeyText) {
	KeyText := replaceVariables(KeyText)
	if (InStr(KeyText,"&&")) {
		Loop, parse, KeyText, "&&",
		{
			msg = %A_LoopField%
			if(msg != "" && msg != " ") {
				IfInString, msg, {Return}
				{
					StringReplace, msg, msg, {Return}, , All
					SendChat(msg)
				} else {
					msg := replaceVariables(msg)
					SendInput, t%msg%
				}
			}
		}
	} else {
		msg := replaceVariables(KeyText)
		SendInput, t%msg%
	}
	return
}

getFishValue(fishName, fishWeight) {
if(fish == "Bernfisch" || fish == "Blauer F‰cherfisch"){
price := Floor(lbs * 1)
}else if(fish == "Schwertfisch" || fish == "Zackenbarsch" || fish == "Roter Schnapper"){
price := Floor(lbs * 2)
}else if(fish == "Katzenfisch" || fish == "Forelle"){
price := Floor(lbs * 3)
}else if(fish == "Delphin" || fish == "Hai" || fish == "Segelfisch"){
price := Floor(lbs * 4)
}else if(fish == "Makrele"){
price := Floor(lbs * 5)
}else if(fish == "Hecht" || fish == "Aal"){
price := Floor(lbs * 6)
}else if(fish == "Thunfisch" || fish == "Wolfbarsch" || fish == "Schildkrˆte"){
price := Floor(lbs * 8)
}else{
price := 0
}
return price
}

restartGameEx() {
if (!checkHandles())
return -1
dwAddress := readDWORD(hGTA, dwSAMP + SAMP_INFO_OFFSET)
if (ErrorLevel || dwAddress==0) {
ErrorLevel := ERROR_READ_MEMORY
return -1
}
dwFunc := dwSAMP + 0xA060
VarSetCapacity(injectData, 11, 0)
NumPut(0xB9, injectData, 0, "UChar")
NumPut(dwAddress, injectData, 1, "UInt")
NumPut(0xE8, injectData, 5, "UChar")
offset := dwFunc - (pInjectFunc + 10)
NumPut(offset, injectData, 6, "Int")
NumPut(0xC3, injectData, 10, "UChar")
writeRaw(hGTA, pInjectFunc, &injectData, 11)
if (ErrorLevel)
return false
hThread := createRemoteThread(hGTA, 0, 0, pInjectFunc, 0, 0, 0)
if (ErrorLevel)
return false
waitForSingleObject(hThread, 0xFFFFFFFF)
return true
}

disconnectEx() {
if (!checkHandles())
return 0
dwAddress := readDWORD(hGTA, dwSAMP + SAMP_INFO_OFFSET)
if (ErrorLevel || dwAddress==0) {
ErrorLevel := ERROR_READ_MEMORY
return 0
}
dwAddress := readDWORD(hGTA, dwAddress + 0x3c9)
if (ErrorLevel || dwAddress==0) {
ErrorLevel := ERROR_READ_MEMORY
return 0
}
ecx := dwAddress
dwAddress := readDWORD(hGTA, dwAddress)
if (ErrorLevel || dwAddress==0) {
ErrorLevel := ERROR_READ_MEMORY
return 0
}
VarSetCapacity(injectData, 24, 0)
NumPut(0xB9, injectData, 0, "UChar")
NumPut(ecx, injectData, 1, "UInt")
NumPut(0xB8, injectData, 5, "UChar")
NumPut(dwAddress, injectData, 6, "UInt")
NumPut(0x68, injectData, 10, "UChar")
NumPut(0, injectData, 11, "UInt")
NumPut(0x68, injectData, 15, "UChar")
NumPut(500, injectData, 16, "UInt")
NumPut(0x50FF, injectData, 20, "UShort")
NumPut(0x08, injectData, 22, "UChar")
NumPut(0xC3, injectData, 23, "UChar")
writeRaw(hGTA, pInjectFunc, &injectData, 24)
if (ErrorLevel)
return false
hThread := createRemoteThread(hGTA, 0, 0, pInjectFunc, 0, 0, 0)
if (ErrorLevel)
return false
waitForSingleObject(hThread, 0xFFFFFFFF)
return true
}

setRestart() {
VarSetCapacity(old, 4, 0)
dwAddress := readDWORD(hGTA, dwSAMP + SAMP_INFO_OFFSET)
if (ErrorLevel || dwAddress==0) {
ErrorLevel := ERROR_READ_MEMORY
return 0
}
NumPut(9,old,0,"Int")
writeRaw(hGTA, dwAddress + 957, &old, 4)
}

getCheckpointPos_(ByRef x, ByRef y, ByRef z) {
if(!checkHandles())
return 0
x := readFloat(hGTA, GTA_CHECKPOINT + GTA_CHECKPOINT_OFF_X)
y := readFloat(hGTA, GTA_CHECKPOINT + GTA_CHECKPOINT_OFF_Y)
z := readFloat(hGTA, GTA_CHECKPOINT + GTA_CHECKPOINT_OFF_Z)
return 1
}

getCheckpointDistance() {
getCheckpointPos_(x, y, z)
return getDistanceToPoint(x, y, z)
}

getDistanceToPoint(x, y, z = 0) {
GetPlayerPos_(_x, _y, _z)
if(z == 0)
return sqrt((_x-x)**2+(_y-y)**2)
else
return sqrt((_x-x)**2+(_y-y)**2+(_z-z)**2)
return 0
}

GetPlayerPos_(ByRef fX,ByRef fY,ByRef fZ) {
if(!checkHandles())
return 0
fX := readFloat(hGTA, ADDR_POSITION_X)
if(ErrorLevel) {
ErrorLevel := ERROR_READ_MEMORY
return 0
}
fY := readFloat(hGTA, ADDR_POSITION_Y)
if(ErrorLevel) {
ErrorLevel := ERROR_READ_MEMORY
return 0
}
fZ := readFloat(hGTA, ADDR_POSITION_Z)
if(ErrorLevel) {
ErrorLevel := ERROR_READ_MEMORY
return 0
}
ErrorLevel := ERROR_OK
}

GetBusLinie(){
	global
	3dText := getLabelText()
	if(InStr(3dText, "Linie") && !InStr(3dText, ":")){
		RegExMatch(3dText, "Linie ([0-9]+)", params)
		if(params1 > 0 && params1 < 22){
			BusLinie := params1
		}
	}
	return BusLinie
}

getLabelText() {
	if(!checkHandles())
		return 0
	
	ADDR_3DText := readDWORD(hGTA, dwSAMP + SAMP_3DTEXT)
	TEXT_3DTEXT := readString(hGTA, ADDR_3DText, 512)
	return TEXT_3DTEXT
}

URLDownloadToVar_(url,ByRef variable=""){
	hObject:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
	hObject.Open("GET",url)
	hObject.Send()
	return variable:=hObject.ResponseText
}

renderChat() {
if (!checkHandles())
return false
Sleep, 40
__WRITEMEM(hGTA, dwSAMP, [SAMP_CHAT_INFO_PTR, 0x63DA], 1, "UInt")
return true
}

ARGB(a, r, g, b){
	return (a << 24) | (r << 16) | (g << 8) | b
}

getDistanceBetween(posX, posY, posZ, _posX, _posY, _posZ, _posRadius) {
	X := posX -_posX
	Y := posY -_posY
	Z := posZ -_posZ
	if (((X < _posRadius) && (X > -_posRadius)) && ((Y < _posRadius) && (Y > -_posRadius)) && ((Z < _posRadius) && (Z > -_posRadius)))
		return true
	return false
}

getKills() {
	if (!checkHandles()) {
		return false
	}
	pedLocal := readDWORD(hGTA, 0xB6F5F0)
	if (!pedLocal) {
		return false
	}
	peds := getPeds()
	if (!peds) {
		return false
	}
	data := []
	For index, object in peds {
		state := readMem(hGTA, object.PED + 0x530, 4, "UInt")
		if ((pedStates[object.PED] == 55 || pedStates[object.PED] == 54) == (state == 55 || state == 54)) {
			Continue
		}
		pedStates[object.PED] := state
		if (object.PED && !object.ISNPC && (state == 55 || state == 54)) {
			pedMurderer := readDWORD(hGTA, object.PED + 0x764)
			murderer := false
			For index2, object2 in peds
			{
				if (object2.PED == pedMurderer) {
					murderer := object2
					Break
				}
			}
			weapon := readMem(hGTA, object.PED + 0x760, 4, "UInt")
			skin := readMem(hGTA, object.PED + 0x22, 2, "UShort")
			if (!murderer)
				data.Push({victim: object, weapon: weapon, skin: skin})
			else
				data.Push({victim: object, murderer: murderer, weapon: weapon, skin: skin})
		}
	}
	return data
}

isConnected() {
	coords := getCoordinates()
	if ((coords[1] == 384 && coords[2] == -1557 && coords[3] == 20) || (Round(coords[1]) == 1531 && Round(coords[2]) == -1734 && Round(coords[3]) == 13)) {
		return false
	}
	return true
}

getPeds() {
	if (!checkHandles()) {
		return false
	}
	if (!updateScoreboardDataEx()) {
		return false
	}
	dwAddress := readDWORD(hGTA, dwSAMP + 0x21A0F8)
	dwAddress := readDWORD(hGTA, dwAddress + 0x3CD)
	dwAddress := readDWORD(hGTA, dwAddress + 0x18)
	data := []
	wID := readMem(hGTA, dwAddress + 0x4, 2, "UShort")
	dwPed := readDWORD(hGTA, 0xB6F5F0)
	if (readDWORD(hGTA, dwAddress + 0x1A) <= 16) {
		sName := readString(hGTA, dwAddress + 0xA, 16)
	} else {
		sName := readString(hGTA, readDWORD(hGTA, dwAddress + 0xA), 20)
	}
	data.Push({LOCAL: true, ID: wID, PED: dwPed, ISNPC: false, NAME: sName})
	Loop % 1000
	{
		i := A_Index - 1
		dwRemotePlayer := readDWORD(hGTA, dwAddress + 0x2E + i*4)
		if (!dwRemotePlayer) {
			Continue
		}
		dwRemotePlayerData := readDWORD(hGTA, dwRemotePlayer)
		dwRemotePlayerData := readDWORD(hGTA, dwRemotePlayerData)
		dwPed := readDWORD(hGTA, dwRemotePlayerData + 0x2A4)
		if (!dwPed) {
			Continue
		}
		dwIsNPC := readDWORD(hGTA, dwRemotePlayer + 0x4)
		if (readMem(hGTA, dwRemotePlayer + 0x1C, 4, "Int") <= 16) {
			sName := readString(hGTA, dwRemotePlayer + 0xC, 16)
		} else {
			sName := readString(hGTA, readDWORD(hGTA, dwRemotePlayer + 0xC), 20)
		}
		data.Push({LOCAL: false, ID: i, PED: dwPed, ISNPC: dwIsNPC, NAME: sName})
	}
	return data
}

readChatLine(line, color = 0) {
	if (!checkHandles())
		return 0
	dwPTR := readDWORD(hGTA, dwSAMP + ADDR_SAMP_CHATMSG_PTR)
	chat := readString(hGTA, dwPTR + SAMP_CHAT_OFF + SIZE_SAMP_CHATMSG * (99 - line), SAMP_CHAT_SIZE)
	if (!color)
		chat := RegExReplace(chat, "\{[a-fA-F0-9]{6}\}")
	return chat
}

getGameText(type = 1, length = 12) {
	if (!checkHandles())
		return ""
	if (type == 1) {
		text := readString(hGTA, GAMETEXT_1, length)
	} else if (type == 2) {
		text := readString(hGTA, GAMETEXT_2, length)
	} else if (type == 3) {
		text := readString(hGTA, GAMETEXT_3, length)
	} else if (type == 4) {
		text := readString(hGTA, GAMETEXT_4, length)
	} else if (type == 5) {
		text := readString(hGTA, GAMETEXT_5, length)
	}
	return text
}

amk(o)
{
	global
	if(!o)
		return
	PlayerID:= o.ID
	PlayerSkin := getTargetPlayerSkinIdById(PlayerID)
	PlayerName := o.Name
	if(PlayerSkin == 105 or PlayerSkin == 106 or PlayerSkin == 107 or PlayerSkin == 269 or PlayerSkin == 271 or PlayerSkin == 65) {
		Fraktion := "Grove Street"
		Gegnerfound := 0
		Zeile := 0
		Loop, read, %A_AppData%\prawler\Fraktionen\%Fraktion%.txt
		{
			If (Zeile >= A_Index)
				Continue
			else{
				if(InStr(A_Loopreadline, PlayerName))
					Gegnerfound := 1
				Zeile := A_Index
			}
		}
		if(Gegnerfound == 0){
			FileAppend, %Playername%`n, %A_AppData%\prawler\Fraktionen\%Fraktion%.txt
			ChatMessage(Playername " wurde als " Fraktion " Member eingetragen!")
		}
	}else if(PlayerSkin == 163 or PlayerSkin == 164 or PlayerSkin == 265 or PlayerSkin == 266 or PlayerSkin == 267 or PlayerSkin == 280 or PlayerSkin == 281 or PlayerSkin == 283 or PlayerSkin == 284 or PlayerSkin == 288 or PlayerSkin == 194) {
		Fraktion := "LSPD"
		Gegnerfound := 0
		Zeile := 0
		Loop, read, %A_AppData%\prawler\Fraktionen\%Fraktion%.txt
		{
			If (Zeile >= A_Index)
				Continue
			else{
				if(InStr(A_Loopreadline, PlayerName))
					Gegnerfound := 1
				Zeile := A_Index
			}
		}
		if(Gegnerfound == 0){
			FileAppend, %Playername%`n, %A_AppData%\prawler\Fraktionen\%Fraktion%.txt
			ChatMessage(Playername " wurde als " Fraktion " Member eingetragen!")
		}
	}else if(PlayerSkin == 165 or PlayerSkin == 166 or PlayerSkin == 286 or PlayerSkin == 294 or PlayerSkin == 194) {
		Fraktion := "FBI"
		Gegnerfound := 0
		Zeile := 0
		Loop, read, %A_AppData%\prawler\Fraktionen\%Fraktion%.txt
		{
			If (Zeile >= A_Index)
				Continue
			else{
				if(InStr(A_Loopreadline, PlayerName))
					Gegnerfound := 1
				Zeile := A_Index
			}
		}
		if(Gegnerfound == 0){
			FileAppend, %Playername%`n, %A_AppData%\prawler\Fraktionen\%Fraktion%.txt
			ChatMessage(Playername " wurde als " Fraktion " Member eingetragen!")
		}
	}else if(PlayerSkin == 122 or PlayerSkin == 123 or PlayerSkin == 186 or PlayerSkin == 203 or PlayerSkin == 204 or PlayerSkin == 228 or PlayerSkin == 169 or PlayerSkin == 224 or PlayerSkin == 121) {
		Fraktion := "Yakuza"
		Gegnerfound := 0
		Zeile := 0
		Loop, read, %A_AppData%\prawler\Fraktionen\%Fraktion%.txt
		{
			If (Zeile >= A_Index)
				Continue
			else{
				if(InStr(A_Loopreadline, PlayerName))
					Gegnerfound := 1
				Zeile := A_Index
			}
		}
		if(Gegnerfound == 0){
			FileAppend, %Playername%`n, %A_AppData%\prawler\Fraktionen\%Fraktion%.txt
			ChatMessage(Playername " wurde als " Fraktion " Member eingetragen!")
		}
	}else if(PlayerSkin == 102 or PlayerSkin == 103 or PlayerSkin == 104 or PlayerSkin == 293 or PlayerSkin == 13) {
		Fraktion := "Ballas"
		Gegnerfound := 0
		Zeile := 0
		Loop, read, %A_AppData%\prawler\Fraktionen\%Fraktion%.txt
		{
			If (Zeile >= A_Index)
				Continue
			else{
				if(InStr(A_Loopreadline, PlayerName))
					Gegnerfound := 1
				Zeile := A_Index
			}
		}
		if(Gegnerfound == 0){
			FileAppend, %Playername%`n, %A_AppData%\prawler\Fraktionen\%Fraktion%.txt
			ChatMessage(Playername " wurde als " Fraktion " Member eingetragen!")
		}
	}else if(PlayerSkin == 117 or PlayerSkin == 118 or PlayerSkin == 120 or PlayerSkin == 208 or PlayerSkin == 263 or PlayerSkin == 49) {
		Fraktion := "Triaden"
		Gegnerfound := 0
		Zeile := 0
		Loop, read, %A_AppData%\prawler\Fraktionen\%Fraktion%.txt
		{
			If (Zeile >= A_Index)
				Continue
			else{
				if(InStr(A_Loopreadline, PlayerName))
					Gegnerfound := 1
				Zeile := A_Index
			}
		}
		if(Gegnerfound == 0){
			FileAppend, %Playername%`n, %A_AppData%\prawler\Fraktionen\%Fraktion%.txt
			ChatMessage(Playername " wurde als " Fraktion " Member eingetragen!")
		}
	}
}

IsPlayerInNoDM(x, y, z){
	result := ""
	if(x<1561.5 && x>1387.8 && y<-1727.6 && y>-1870){
		result := 1
	}else if(x>1688.8 && x<1820.8 && y<-1859.5 && y>-1961.2){
		result := 1
	}
	return result
}

getSkinFraction(id) {
	skins := {"LSPD": [163, 164, 265, 266, 267, 280, 281, 283, 284, 288, 194], "FBI": [165, 166, 286, 294, 194], "Sanit‰ter": [70, 274, 275, 276, 193], "Feuerwehr": [255, 277, 278, 279, 191], "Russen Mafia": [111, 112, 113, 124, 125, 126, 127, 272, 40, 43, 258], "Yakuza Mafia": [122, 123, 186, 203, 204, 228, 169, 224, 121], "Hitman": [], "Wheelman": [], "San News": [60, 170, 188, 227, 240, 250, 56, 226], "Grove Street": [105, 106, 107, 269, 269, 271, 65], "Ballas": [102, 103, 104, 293, 13], "Los Chickos Malos": [46, 47, 48, 98, 185, 223, 214, 30], "Ordnungsamt": [8, 50, 71, 233, 42], "Transport GmbH": [34, 44, 132, 133, 202, 206, 261, 31, 131], "San Fierro Rifa": [114, 115, 116, 173, 174, 175, 184, 273, 195, 198], "Los Santos Vagos": [108, 109, 110, 292, 91], "Triaden": [117, 118, 120, 208, 263, 49]}
	fraction := ""
	For key, array in skins
	{
		For index2, value2 in array
		{
			if(value2 == id) {
				fraction := key
				Break, 2
			}
		}
	}
	if(fraction) {
		return fraction
	}
	return "Zivilist"
}