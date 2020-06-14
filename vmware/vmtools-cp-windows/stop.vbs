SUB Include
	Set file=CreateObject("Scripting.FileSystemObject").OpenTextFile(".\configuration.vbs",1,true)
	ExecuteGlobal file.readAll
	file.close
END SUB
call include

writeConf STATUS_KEY,STATUS_VALUE_CLOSING
