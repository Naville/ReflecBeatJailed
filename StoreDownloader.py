import urllib2
import urllib
import json
import os
import sys
import random
import signal
import plistlib
import copy
Folder="MusicPacks"
import plistlib
Meh=list()
IDList=list()
TotalFetchedPackNum=1
def C0113ct0th3rInf0(path):
	print "Collecting SongInfo From: ",path
	for FolderName in os.listdir(path):
		if(os.path.isdir(path+"/"+FolderName)):
			Item=plistlib.readPlist(path+"/"+FolderName+"/"+FolderName+".plist")
			InfoDict=dict()
			InfoDict["Artist"]=Item["ArtistName"]
			InfoDict["ID"]=Item["MusicId"]#
			InfoDict["ItemURL"]="http://www.google.com"
			InfoDict["Name"]=Item["SongName"]
			InfoDict["iTunesURL"]="http://www.google.com"
			if (InfoDict not in Meh):
				Meh.append(InfoDict)
def signal_handler(signal, frame):
	C0113ct0th3rInf0("RbArcade")
	C0113ct0th3rInf0("RbCustom")
	for IDName in os.listdir(Folder):
		if(IDName==".DS_Store"):
			continue
		ID=int(IDName[:-3])
		#print "Examing ID:",str(ID)
		Outputpath=Folder+"/"+IDName
		if(ID not in IDList):
			TempDict=dict()
			TempDict["Artist"]="SaitoAsuka"
			TempDict["ID"]=int(ID)
			TempDict["ItemURL"]="navillezhang.me"
			TempDict["Name"]="WatanabeMayu"
			Meh.append(TempDict)
	print "There are "+str(len(Meh))+" Songs In Total"
	plistlib.writePlist(Meh,"Input.plist")
	sys.exit(0)
signal.signal(signal.SIGINT, signal_handler)

def id_generator(size=32, chars="1234abcdABCDEFGHIJKLMNOP"):
	#Thanks to http://stackoverflow.com/questions/2257441/random-string-generation-with-upper-case-letters-and-digits-in-python
	ret=''.join(random.choice(chars) for _ in range(size))
	return ''+ret#Make sure we load first
def Download(URL,ItemID):
	if not os.path.exists(Folder):
		os.makedirs(Folder)
	Outputpath=Folder+"/"+str(ItemID)+".rb"
	if(os.path.isfile(Outputpath)):
		return
	print "Downloading URL: ",URL
	urllib.urlretrieve(URL, Outputpath)
def Loop():
	#Download Campaign
	CampaignList=json.loads(open("campaignList.json","r").read())['List']
	for item in CampaignList:
		item=item["music"]
		Download(item["ItemURL"],int(item["ID"]))
		if (item["ID"] not in IDList):
			IDList.append(int(item["ID"]))
		if (item not in Meh):
			Meh.append(item)
	while True:
		URL="http://akx.s.konaminet.jp/akx/main/cgi/packlist/?target=JP&head="+str(TotalFetchedPackNum)+"&limit=15&genre=0&uuid="+id_generator()+"&version=4.3.0&device=iPad5,3&os=9.1&locale=en_JP"
		response = urllib2.urlopen(URL).read()
		DownloadRep(json.loads(response))

def DownloadRep(Response):
	for item in Response["PackList"]:
		global TotalFetchedPackNum
		TotalFetchedPackNum=TotalFetchedPackNum+1
		ID=item["ID"]
		URL1="http://akx.s.konaminet.jp/akx/main/cgi/packinfo/?target=JP&pack="+str(ID)
		JSONINFO=json.loads(urllib2.urlopen(URL1).read())
		print "Downloading Pack:\n"+JSONINFO["Name"]
		for x in JSONINFO["MusicList"]:
			DLURL=x["ItemURL"]
			NewDict=copy.deepcopy(x)
			del x["Level"]
			del x["SampleURL"]
			del x["ArtworkURL"]
			if (x not in Meh):
				Meh.append(x)
			if (x["ID"] not in IDList):
				IDList.append(int(x["ID"]))
			Download(DLURL,x["ID"])
	if Response["HasNext"]==False:
		signal_handler(None,None)	





Loop()