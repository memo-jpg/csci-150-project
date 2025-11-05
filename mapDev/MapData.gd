extends Node

var mapInfo = {}

func getNodeInfo(argNodeId : int):
	return mapInfo.get(argNodeId)
	
func setNodeActive(argNodeId: int, argIsActive: bool):
		if mapInfo.has(argNodeId):
			mapInfo[argNodeId]['isActive'] = argIsActive
