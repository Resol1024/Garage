CONF_FILE_PATH=".\configuration.txt"
CLIP_FILE_PATH="C:\Users\resol\Documents\Virtual Machines\shared\clipboard.txt"

STATUS_KEY="status"
STATUS_VALUE_RUNNING="running"
STATUS_VALUE_CLOSING="closing"
STATUS_VALUE_CLOSED="closed"

STATUS_CHECK_GAP_KEY="status_check_gap"
STATUS_CHECK_GAP_VALUE_60000  ="60000" 
STATUS_CHECK_GAP_VALUE_600000="600000"

CLIP_FLUSH_GAP_KEY="clip_flush_gap"
CLIP_FLUSH_GAP_VALUE_250MS  ="250"
CLIP_FLUSH_GAP_VALUE_500MS  ="500"
CLIP_FLUSH_GAP_VALUE_1000MS="1000"



FUNCTION ReadAllConf()
	Set file=CreateObject("Scripting.FileSystemObject").OpenTextFile(CONF_FILE_PATH,1,true)
	IF file.AtEndOfLine THEN 
		ReadAllConf=array()
		file.Close()
		EXIT FUNCTION
	END IF

	SET dic=CreateObject("Scripting.Dictionary")
	FOR EACH line in Split(file.ReadAll,Chr(10))		
		lKey=""
		lValue=""
		IF Ubound(Split(line,":"))=1 THEN 
			lKey=Split(line,":")(0)
			lValue=Split(line,":")(1)
		END IF
		IF NOT dic.Exists(lKey) AND lKey<>"" AND lValue<>"" THEN dic.Add lKEY,lValue
	NEXT

	REDIM lines(dic.Count-1)
	i=0
	FOR EACH key IN dic.Keys
		lines(i)=key & ":" & dic(key)
		i=i+1
	NEXT

	ReadAllConf=lines	
	file.close()
END FUNCTION

FUNCTION ReadConf(key)
	FOR EACH line IN ReadAllConf()
		IF  Ubound(Split(line,":"))>0 AND Split(line,":")(0)=key  THEN 
			ReadConf=Split(line,":")(1)
			EXIT FUNCTION
		END IF
	NEXT
	ReadConf=""
END FUNCTION

FUNCTION WriteConf(key,value)
	IF key="" OR value="" THEN
		EXIT FUNCTION
	END IF
	
	nConf=""
	isKeyChanged=False
	FOR EACH line in ReadAllConf()
		lKey=""
		IF Ubound(Split(line,":"))=1 THEN lKey=Split(line,":")(0)
		
		IF lKey=key THEN
			nConf = nConf&key & ":" & value & Chr(10)
			isKeyChanged=True
		ELSEIF lKEY<>"" AND lKEY<>key THEN
			nConf = nConf & line & Chr(10)
		END IF
	NEXT
	IF NOT isKeyChanged THEN
		nConf = nConf & key & ":"  & value
	END IF

	Set file=CreateObject("Scripting.FileSystemObject").openTextFile(CONF_FILE_PATH,2,true)
	file.write(nConf)
	file.Close()
END FUNCTION

'Initial
IF readConf(STATUS_KEY)="" THEN writeConf STATUS_KEY,STATUS_VALUE_CLOSED
IF readConf(STATUS_CHECK_GAP_KEY)="" THEN writeConf STATUS_CHECK_GAP_KEY,STATUS_CHECK_GAP_VALUE_600000
IF readConf(CLIP_FLUSH_GAP_KEY)="" THEN writeConf CLIP_FLUSH_GAP_KEY,CLIP_FLUSH_GAP_VALUE_1000MS
