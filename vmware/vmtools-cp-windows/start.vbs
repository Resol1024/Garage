SUB Include
	Set file=CreateObject("Scripting.FileSystemObject").OpenTextFile(".\configuration.vbs",1,true)
	ExecuteGlobal file.readAll
	file.close
END SUB
call include

SET ws=CreateObject("WScript.Shell")
SET cb=CreateObject("HTMLFile")
cfGap = int(readConf(CLIP_FLUSH_GAP_KEY))
scGap = int(readConf(STATUS_CHECK_GAP_KEY))

writeConf STATUS_KEY,STATUS_VALUE_RUNNING

scGapCount=0
cbText=cb.parentWindow.clipboardData.getData("text")
DO
	scGapCount = scGapCount + cfGap
	IF scGapCount > scGap THEN 
		IF readConf(STATUS_KEY)<>STATUS_VALUE_RUNNING THEN 
			writeConf STATUS_KEY,STATUS_VALUE_CLOSED
			Wscript.Quit
		END IF
		scGapCount=0	
	END IF
	
	IF cbText <> cb.parentWindow.clipboardData.getData("text") THEN
		cbText=cb.parentWindow.clipboardData.getData("text")
		ws.run "cmd /c powershell Get-Clipboard > " & Chr(34) & CLIP_FILE_PATH & Chr(34),vbhide
	END IF

	WScript.Sleep cfGap
LOOP UNTIL False
