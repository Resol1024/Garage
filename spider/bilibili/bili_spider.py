#!/usr/python3
import sys
import requests 
from lxml import etree
import json

class BiliSpider:	

	'''
	return structure:
	result = {
		title     : "",
		video_url : "",
		audio_url : ""
	}
	
	profile page html structure:
	<html>
	|-<head>
	| |-<script>
	| | |-windows.__playinfo(json)
	| |   |-data(normal case)
	| |   . |-dash
	| |   .   |-video([])
	| |   .   | |-{}
	| |   .   |   |-baseUrl(straight download url)
	| |   .   |-audio([])
	| |   .   	|-{}
	| |   .       |-baseUrl(straight download url)
	| |   |-data(old case)
	| |     |-durl([])  
	| |       |-{}
	| |         |-url(.flv in most case)
	| |-<script>(can't be seen in browser)
	|   |-window.__INITIAL_STATE__(normal case)
	|   . |-videoData
	|   .   |-title
	|   .   |-pages([])
	|   .     |-{}
	|   .       |-page(parameter p)
	|   .       |-part(title)
	|	.
	|   |-window.__INITIAL_STATE__(path like:/bangumi/play/ep307622)
	|     |-h1Title

	'''
	def profile(url:str)->dict:
		result = {}

		#by set CURRENT_FNVAL=16,can get a normal __playinfo__ 
		petree = etree.HTML(requests.get(url,headers={"cookie":"CURRENT_FNVAL=16"}).text)

		#window.__playinfo__
		playinfo_text = petree.xpath("//script[contains(text(),'window.__playinfo__={')]")[0].text
		playinfo_text = playinfo_text[playinfo_text.find("{"):]
		playinfo = json.loads(playinfo_text)["data"]["dash"]
	
		#window.__initial_state__
		initial_state = {}
		initial_state_text = petree.xpath("//script[contains(text(),'window.__INITIAL_STATE__={')]")[0].text
		initial_state_text = initial_state_text[initial_state_text.find("{"):initial_state_text.find(";(function()")]
		initial_state = json.loads(initial_state_text)

		#title
		if "?p=" in url:
			for e in initial_state["videoData"]["pages"]:
				if e["page"] == int(url.split("?p=")[1]):
					result["title"] = e["part"]			
					break
		elif "h1Title" in initial_state:
			result["title"] = initial_state["h1Title"]
		else:
			result["title"] = initial_state["videoData"]["title"]
		#remove invalid character in title
		result["title"] = result["title"].replace("\\","-")
		result["title"] = result["title"].replace("/","-")

		#set video_url & audio_url 
		if isinstance(playinfo["video"][0]["baseUrl"],list):
			result["video_url"] = playinfo["video"][0]["baseUrl"][0]
		else:
			result["video_url"] = playinfo["video"][0]["baseUrl"]
		
		if isinstance(playinfo["audio"][0]["baseUrl"],list):
			result["audio_url"] = playinfo["audio"][0]["baseUrl"][0]
		else:
			result["audio_url"] = playinfo["audio"][0]["baseUrl"]

		#replace http with https if necessary
		if "https" not in result["video_url"]:
			result["video_url"] = result["video_url"].replace("http","https",1)
		if "https" not in result["audio_url"]:
			result["audio_url"] = result["audio_url"].replace("http","https",1)

		return result

	#indispensable attr in download url:expires,ssig,oi,bfc,nfb
	def download_audio(url:str,store_path:str="./")->bool:
		profile = BiliSpider.profile(url)		
		
		header={
			"Host": "upos-sz-mirrorcos.bilivideo.com",
			"Connection": "keep-alive",
			"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36(KHTML, like Gecko) Chrome/83.0.4103.97 Safari/537.36",
			"Accept": "*/*",
			"Origin": "https://www.bilibili.com",
			"Sec-Fetch-Site": "cross-site",
			"Sec-Fetch-Mode": "cors",
			"Sec-Fetch-Dest": "empty",

			"Referer":"https://www.bilibili.com/",
			"Accept-Encoding": "identity",
			"Accept-Language": "zh-CN,zh;q=0.9",
			"Range": "bytes=0-2000000000"
		}
		header["Referer"]=url
		header["Host"]=profile["audio_url"].split("/")[2]

		with open(store_path + profile["title"] + ".mp3","wb") as f:
			response = requests.get(profile["audio_url"],headers=header,verify=False)
			if ( response.status_code != 206 ) : 
				return False
			f.write(response.content)
			return True
		
'''
	example:
		bili_spider https://www.bilibili.com/video/BV1BJ411b7Pk ~/music/
'''		
if __name__ == "__main__":
	#BiliSpider.download_audio("https://www.bilibili.com/video/BV1BJ411b7Pk","/mnt/hgfs/shared/music/")
		
	url = sys.argv[1]
	path= "./"
	if ( len(sys.argv) > 2 ) :
		path = sys.argv[2]
	result = BiliSpider.download_audio(url,path)
	if ( result ) :
		print("Download success")
	else : 
		print("Download failed")
