getPID(windowName) {
WinGet, processID, PID, %windowName%
return processID
}
openProcess(processID, privileges := 0x1F0FFF) {
return DllCall("OpenProcess", "UInt", privileges, "UInt", 0, "UInt", processID, "UInt")
}
closeProcess(process) {
return !process ? false : DllCall("CloseHandle", "UInt", process, "UInt")
}
getModuleBaseAddress(sModule, hProcess) {
if (!sModule || !hProcess)
return false
dwSize = 4096
VarSetCapacity(hMods, dwSize)
VarSetCapacity(cbNeeded, 4)
dwRet := DllCall("Psapi.dll\EnumProcessModules", "UInt", hProcess, "UInt", &hMods, "UInt", dwSize, "UInt*", cbNeeded, "UInt")
if (!dwRet)
return false
dwMods := cbNeeded / 4
i := 0
VarSetCapacity(hModule, 4)
dwNameSize := 260 * (A_IsUnicode ? 2 : 1)
VarSetCapacity(sCurModule, dwNameSize)
while (i < dwMods) {
hModule := NumGet(hMods, i * 4)
DllCall("Psapi.dll\GetModuleFileNameEx", "UInt", hProcess, "UInt", hModule, "Str", sCurModule, "UInt", dwNameSize)
SplitPath, sCurModule, sFilename
if (sModule == sFilename)
return hModule
i += 1
}
return false
}
__READSTRING(hProcess, dwAddress, oOffsets, dwLen) {
if (!hProcess || !dwAddress)
return ""
VarSetCapacity(dwRead, dwLen)
for i, o in oOffsets {
if (i == oOffsets.MaxIndex()) {
dwRet := DllCall("ReadProcessMemory", "UInt", hProcess, "UInt", dwAddress + o, "Str", dwRead, "UInt", dwLen, "UInt*", 0, "UInt")
return !dwRet ? "" : (A_IsUnicode ? __ansiToUnicode(dwRead) : dwRead)
}
dwRet := DllCall("ReadProcessMemory", "UInt", hProcess, "UInt", dwAddress + o, "Str", dwRead, "UInt", 4, "UInt*", 0)
if (!dwRet)
return ""
dwAddress := NumGet(dwRead, 0, "UInt")
}
}
__DWORD(hProcess, dwAddress, offsets) {
if (!hProcess || !dwAddress)
return ""
VarSetCapacity(dwRead, 4)
for i, o in offsets {
dwRet := DllCall("ReadProcessMemory", "UInt", hProcess, "UInt", dwAddress + o, "Str", dwRead, "UInt", 4, "UInt*", 0)
if (!dwRet)
return ""
dwAddress := NumGet(dwRead, 0, "UInt")
}
return dwAddress
}
readDWORD(hProcess, dwAddress) {
if(!hProcess) {
ErrorLevel := ERROR_INVALID_HANDLE
return 0
}
VarSetCapacity(dwRead, 4)
dwRet := DllCall(    "ReadProcessMemory"
, "UInt",  hProcess
, "UInt",  dwAddress
, "Str",   dwRead
, "UInt",  4
, "UInt*", 0)
if(dwRet == 0) {
ErrorLevel := ERROR_READ_MEMORY
return 0
}
ErrorLevel := ERROR_OK
return NumGet(dwRead, 0, "UInt")
}
readMem(hProcess, dwAddress, dwLen=4, type="UInt") {
if(!hProcess) {
ErrorLevel := ERROR_INVALID_HANDLE
return 0
}
VarSetCapacity(dwRead, dwLen)
dwRet := DllCall(    "ReadProcessMemory"
, "UInt",  hProcess
, "UInt",  dwAddress
, "Str",   dwRead
, "UInt",  dwLen
, "UInt*", 0)
if(dwRet == 0) {
ErrorLevel := ERROR_READ_MEMORY
return 0
}
ErrorLevel := ERROR_OK
return NumGet(dwRead, 0, type)
}
__READMEM(hProcess, dwAddress, oOffsets, sDatatype = "Int") {
if (!hProcess || !dwAddress)
return ""
VarSetCapacity(dwRead, 4)
for i, o in oOffsets {
dwRet := DllCall("ReadProcessMemory", "UInt", hProcess, "UInt", dwAddress + o, "Str", dwRead, "UInt", 4, "UInt*", 0)
if (!dwRet)
return ""
if (i == oOffsets.MaxIndex())
return NumGet(dwRead, 0, sDatatype)
dwAddress := NumGet(dwRead, 0, "UInt")
}
}
__WRITESTRING(hProcess, dwAddress, oOffsets, wString) {
if (!hProcess || !dwAddress)
return false
if A_IsUnicode
wString := __unicodeToAnsi(wString)
requiredSize := StrPut(wString)
VarSetCapacity(buffer, requiredSize)
for i, o in oOffsets {
if (i == oOffsets.MaxIndex()) {
StrPut(wString, &buffer, StrLen(wString) + 1)
return DllCall("WriteProcessMemory", "UInt", hProcess, "UInt", dwAddress + o, "Str", buffer, "UInt", requiredSize, "UInt", 0, "UInt")
}
dwRet := DllCall("ReadProcessMemory", "UInt", hProcess, "UInt", dwAddress + o, "Str", buffer, "UInt", 4, "UInt*", 0)
if (!dwRet)
return false
dwAddress := NumGet(buffer, 0, "UInt")
}
}
__WRITEMEM(hProcess, dwAddress, oOffsets, value, sDatatype = "Int") {
dwLen := datatypes[sDatatype]
if (dwLen < 1 || !hProcess || !dwAddress)
return false
VarSetCapacity(dwRead, 4)
for i, o in oOffsets {
if (i == oOffsets.MaxIndex()) {
NumPut(value, dwRead, 0, sDatatype)
return DllCall("WriteProcessMemory", "UInt", hProcess, "UInt", dwAddress + o, "UInt", &dwRead, "UInt", dwLen, "UInt", 0)
}
dwRet := DllCall("ReadProcessMemory", "UInt", hProcess, "UInt", dwAddress + o, "Str", dwRead, "UInt", 4, "UInt*", 0)
if (!dwRet)
return false
dwAddress := NumGet(dwRead, 0, "UInt")
}
}
__WRITERAW(hProcess, dwAddress, pBuffer, dwLen) {
return (!hProcess || !dwAddress || !pBuffer || dwLen < 1) ? false : DllCall("WriteProcessMemory", "UInt", hProcess, "UInt", dwAddress, "UInt", pBuffer, "UInt", dwLen, "UInt", 0, "UInt")
}
__CALL(hProcess, dwFunc, aParams, bCleanupStack = true, bThisCall = false, bReturn = false, sDatatype = "Char") {
if (!hProcess || !dwFunc)
return ""
dataOffset := 0
i := aParams.MaxIndex()
bytesUsed := 0
bytesMax := 5120
dwLen := i * 5 + bCleanupStack * 3 + bReturn * 5 + 6
VarSetCapacity(injectData, dwLen, 0)
while (i > 0) {
if (aParams[i][1] == "i" || aParams[i][1] == "p" || aParams[i][1] == "f")
value := aParams[i][2]
else if (aParams[i][1] == "s") {
if (bytesMax - bytesUsed < StrLen(aParams[i][2]))
return ""
value := pMemory + bytesUsed
__WRITESTRING(hProcess, value, [0x0], aParams[i][2])
bytesUsed += StrLen(aParams[i][2]) + 1
if (ErrorLevel)
return ""
}
else
return ""
NumPut((bThisCall && i == 1 ? 0xB9 : 0x68), injectData, dataOffset, "UChar")
NumPut(value, injectData, ++dataOffset, aParams[i][1] == "f" ? "Float" : "Int")
dataOffset += 4
i--
}
offset := dwFunc - (pInjectFunc + dataOffset + 5)
NumPut(0xE8, injectData, dataOffset, "UChar")
NumPut(offset, injectData, ++dataOffset, "Int")
dataOffset += 4
if (bReturn) {
NumPut(sDatatype = "Char" || sDatatype = "UChar" ? 0xA2 : 0xA3, injectData, dataOffset, "UChar")
NumPut(pMemory, injectData, ++dataOffset, "UInt")
dataOffset += 4
}
if (bCleanupStack) {
NumPut(0xC483, injectData, dataOffset, "UShort")
dataOffset += 2
NumPut((aParams.MaxIndex() - bThisCall) * 4, injectData, dataOffset, "UChar")
dataOffset++
}
NumPut(0xC3, injectData, dataOffset, "UChar")
__WRITERAW(hGTA, pInjectFunc, &injectData, dwLen)
if (ErrorLevel)
return ""
hThread := createRemoteThread(hGTA, 0, 0, pInjectFunc, 0, 0, 0)
if (ErrorLevel)
return ""
waitForSingleObject(hThread, 0xFFFFFFFF)
closeProcess(hThread)
if (bReturn)
return __READMEM(hGTA, pMemory, [0x0], sDatatype)
return true
}
virtualAllocEx(hProcess, dwSize, flAllocationType, flProtect) {
return (!hProcess || !dwSize) ? false : DllCall("VirtualAllocEx", "UInt", hProcess, "UInt", 0, "UInt", dwSize, "UInt", flAllocationType, "UInt", flProtect, "UInt")
}
virtualFreeEx(hProcess, lpAddress, dwSize, dwFreeType) {
return (!hProcess || !lpAddress || !dwSize) ? false : DllCall("VirtualFreeEx", "UInt", hProcess, "UInt", lpAddress, "UInt", dwSize, "UInt", dwFreeType, "UInt")
}
createRemoteThread(hProcess, lpThreadAttributes, dwStackSize, lpStartAddress, lpParameter, dwCreationFlags, lpThreadId) {
return (!hProcess) ? false : DllCall("CreateRemoteThread", "UInt", hProcess, "UInt", lpThreadAttributes, "UInt", dwStackSize, "UInt", lpStartAddress, "UInt"
, lpParameter, "UInt", dwCreationFlags, "UInt", lpThreadId, "UInt")
}
waitForSingleObject(hThread, dwMilliseconds) {
return !hThread ? false : !(DllCall("WaitForSingleObject", "UInt", hThread, "UInt", dwMilliseconds, "UInt") == 0xFFFFFFFF)
}
__ansiToUnicode(sString, nLen = 0) {
if (!nLen)
nLen := DllCall("MultiByteToWideChar", "UInt", 0, "UInt", 0, "UInt", &sString, "Int",  -1, "UInt", 0, "Int",  0)
VarSetCapacity(wString, nLen * 2)
DllCall("MultiByteToWideChar", "UInt", 0, "UInt", 0, "UInt", &sString, "Int",  -1, "UInt", &wString, "Int",  nLen)
return wString
}
__ansiToGTA(sString) {
VarSetCapacity(newString, (len := StrLen(sString)))
Loop, % len
{
char := NumGet(sString, A_Index - 1, "UChar")
msgbox % char
NumPut((char == 252 ? 168 : char), &newString, A_Index - 1, "UChar")
StringTrimLeft, sString, sString, 1
}
return newString
}
__unicodeToAnsi(wString, nLen = 0) {
pString := wString + 1 > 65536 ? wString : &wString
if (!nLen)
nLen := DllCall("WideCharToMultiByte", "UInt", 0, "UInt", 0, "UInt", pString, "Int",  -1, "UInt", 0, "Int",  0, "UInt", 0, "UInt", 0)
VarSetCapacity(sString, nLen)
DllCall("WideCharToMultiByte", "UInt", 0, "UInt", 0, "UInt", pString, "Int",  -1, "Str",  sString, "Int",  nLen, "UInt", 0, "UInt", 0)
return sString
}
IntToHex(value, prefix := true) {
	CurrentFormat := A_FormatInteger
	SetFormat, Integer, hex
	value += 0
	SetFormat, Integer, %CurrentFormat%
	Int2 := SubStr(value, 3)
	StringUpper value, Int2
	return (prefix ? "0x" : "") . value
}
NOP(hProcess, dwAddress, dwLen) {
	if (dwLen < 1 || !hProcess || !dwAddress)
		return false
	VarSetCapacity(byteCode, dwLen)
	Loop % dwLen
		NumPut(0x90, &byteCode, A_Index - 1, "UChar")
	return __WRITERAW(hProcess, dwAddress, &byteCode, dwLen)
}
__WRITEBYTES(hProcess, dwAddress, byteArray) {
if (!hProcess || !dwAddress || !byteArray)
return false
dwLen := byteArray.MaxIndex()
VarSetCapacity(byteCode, dwLen)
for i, o in byteArray
NumPut(o, &byteCode, i - 1, "UChar")
return __WRITERAW(hProcess, dwAddress, &byteCode, dwLen)
}
__READBYTE(hProcess, dwAddress) {
if (!checkHandles())
return false
VarSetCapacity(value, 1, 0)
DllCall("ReadProcessMemory", "UInt", hProcess, "UInt", dwAddress, "Str", value, "UInt", 1, "UInt *", 0)
return NumGet(value, 0, "Byte")
}
increaseValue(dwAddress, value, sDatatype := "UInt") {
return !checkHandles() ? false : __WRITEMEM(hGTA, dwAddress, [0x0], __READMEM(hGTA, dwAddress, [0x0], sDatatype) + value, sDatatype)
}
isInteger(arg) {
if arg is integer
return true
return false
}
isFloat(arg) {
if arg is float
return true
return false
}
fileCountLines(path) {
FileRead, text, % path
StringReplace, text, text, `r, `n, All UseErrorLevel
return ErrorLevel + 1
}
evaluateString(string) {
static sc := ComObjCreate("ScriptControl")
sc.Language := "JScript"
string := "a = " string ";"
try {
sc.ExecuteStatement(string)
new := sc.Eval("a")
}
catch e
return "ERROR"
return new
}
getByteSize(number) {
return number <= 0xFF ? 1 : number <= 0xFFFF ? 2 : 4
}
__INJECT(hProcess, aInstructions) {
aOpcodes := { "mov edi" : 0x3D8B, "NOP" : 0x90, "mov ecx" : 0xB9, "mov dword" : 0x05C7, "push" : 0x68, "call" : 0xE8, "mov byte" : 0x05C6
, "ret" : 0xC3, "add esp" : 0xC483, "xor edi, edi" : 0xFF33, "xor eax, eax" : 0xC033, "mov edi, eax" : 0xF88B, "push edi" : 0x57, "push eax" : 0x50
, "mov address, eax" : 0xA3, "mov [address], eax" : 0x0589, "test eax, eax" : 0xC085, "jz" : 0x74, "mov ecx, eax" : 0xC88B, "jmp" : 0xEB
, "mov edx" : 0xBA, "fstp" : 0x1DD9}
dwLen := 0
for i, o in aInstructions
dwLen += getByteSize(aOpcodes[o[1]]) + ((datatypes[o[2][2]] == null) ? 0 : datatypes[o[2][2]]) + ((datatypes[o[3][2]] == null ? 0 : datatypes[o[3][2]]))
VarSetCapacity(injectData, dwLen, 0)
dwDataOffset := 0
for i, o in aInstructions {
NumPut(aOpcodes[o[1]], injectData, dwDataOffset, getByteSize(aOpcodes[o[1]]) == 1 ? "UChar" : "UShort")
dwDataOffset += getByteSize(aOpcodes[o[1]])
if (o[2][1] != null) {
NumPut(o[2][1] - (o[1] = "call" ? (pInjectFunc + 4 + dwDataOffset) : 0), injectData, dwDataOffset, o[2][2])
dwDataOffset += datatypes[o[2][2]]
}
else
continue
if (o[3][1] != null) {
NumPut(o[3][1], injectData, dwDataOffset, o[3][2])
dwDataOffset += datatypes[o[3][2]]
}
}
__WRITERAW(hGTA, pInjectFunc, &injectData, dwLen)
hThread := createRemoteThread(hGTA, 0, 0, pInjectFunc, 0, 0, 0)
if (ErrorLevel)
return false
waitForSingleObject(hThread, 0xFFFFFFFF)
closeProcess(hThread)
return ErrorLevel ? false : __READMEM(hGTA, pMemory, [0x0], "Int")
}