HTTPData(url, default="", encoding="cp1250", brton=0){
	global DownloadMode
	static useragent := "AutoHotkey/" A_AhkVersion
	if(DownloadMode = 0){
		if(!out := DownloadToString(url, encoding))
			return default " [Error 0-1]"
		if(brton)
			StringReplace, out, out, <br>, `n, All
		return out
	}
	else if(DownloadMode = 1){
		URLDownloadToFile, %url%, %A_Temp%\sBinder\sbinder.tmp
		if(ErrorLevel)
			return default " [Error 1-1]"
		FileRead, out, %A_Temp%\sBinder\sbinder.tmp
		if(ErrorLevel)
			return default " [Error 1-2]"
		FileDelete, %A_Temp%\sBinder\sbinder.tmp
		if(brton)
			StringReplace, out, out, <br>, `n, All
		return (out ? out : default " [Error 1-0]")
	}
	else{
		static WebRequest
		if(!WebRequest AND !WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1"))
			return default " [Error 2-1]"
		try{
			WebRequest.Open("GET", url)
			WebRequest.setRequestHeader("User-Agent", useragent)
			WebRequest.setRequestHeader("Cache-Control", "no-cache, no-store")
			WebRequest.Send()
		}
		catch
			return default " [Error 2-2]"
		out := WebRequest.ResponseText
		if(DownloadMode = "GetHeaders")
			MsgBox, % WebRequest.GetAllResponseHeaders()
		if(brton)
			StringReplace, out, out, <br>, `n, All
		return (out != "" ? out : default " [Error 2-0]")
	}
	return default " [Error X]"
}

_DownloadToString(url, encoding="cp1250"){
	static a := "AutoHotkey/" A_AhkVersion
	if(!DllCall("LoadLibrary", "str", "wininet") || !(h := DllCall("wininet\InternetOpen", "str", a, "uint", 1, "ptr", 0, "ptr", 0, "uint", 0, "ptr")))
		return 0
	c := s := 0, o := ""
	if(f := DllCall("wininet\InternetOpenUrl", "ptr", h, "str", url, "ptr", 0, "uint", 0, "uint", 0x80003000, "ptr", 0, "ptr")){
		to := 0
		while(DllCall("wininet\InternetQueryDataAvailable", "ptr", f, "uint*", s, "uint", 0, "ptr", 0) && s>0){
			VarSetCapacity(b, s, 0)
			DllCall("wininet\InternetReadFile", "ptr", f, "ptr", &b, "uint", s, "uint*", r)
			o .= StrGet(&b, r>>(encoding="utf-16"||encoding="cp1200"), encoding)
		}
		DllCall("wininet\InternetCloseHandle", "ptr", f)
	}
	DllCall("wininet\InternetCloseHandle", "ptr", h)
	return o
}

InfoProgress(text="", title="", windowName=""){
	global GUIs
	Gui, InfoProgress:Destroy
	if(text OR subtitle OR windowName){
		Gui, InfoProgress:Color, FFFFFF
		Gui, InfoProgress:-caption +border +Hwndtemp2
		GUIs["InfoProgress"] := temp2
		Gui, InfoProgress:Font, s13 bold
		Gui, InfoProgress:Add, Text,, %title%
		Gui, InfoProgress:Font
		Gui, InfoProgress:Font, s10
		Gui, InfoProgress:Add, Text,, %text%
		Gui, InfoProgress:Font
		Gui, InfoProgress:Show, NA, %windowName%
	}
	else
		GUIs.Delete("InfoProgress")
}