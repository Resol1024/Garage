#!/usr/python3
import sys
import requests 
from lxml import etree
import json

class BiliSpider:	

	'''
	profile_info:
	{
		title     : "",
		video_url : "",
		audio_url : ""
	}
	
	profile page html structure:
	<html>
	|-<head>
	| |-<script>
	|   |-windows.__playinfo(json)
	|     |-data
	|       |-dash
	|         |-video([])
	|         | |-{}
	|         |   |-baseUrl(straight download url)
	|         |-audio([])
	|         	|-{}
	|             |-baseUrl(straight download url)
	|
	|-<body>
	| |-<div id="app">
	|   |-<div class="v-wrap">
	|     |-<div class="l-con">
	|       |-<div id="viebox_report">
	|         |-<h1 title="$title">
	'''
	def profile(url:str)->dict:
		result = {}

		petree = etree.HTML(requests.get(url).text)
		result["title"] = petree.xpath("/html/body//div[@id='viewbox_report']/h1/@title")[0]

		for t in petree.xpath("/html/head/script/text()"):
			if "window.__playinfo__" not in t:
				continue

			playinfo = json.loads(t[t.find("{"):])["data"]["dash"]
			#Though we got http protocol url there,but real request is using https protocal url
			result["video_url"] = playinfo["video"][0]["baseUrl"].replace("http","https",1)
			result["audio_url"] = playinfo["audio"][0]["baseUrl"].replace("http","https",1)
			break;

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
