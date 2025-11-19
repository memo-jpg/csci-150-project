extends Node2D


func _on_timer_timeout():
	if Global.prev_scene_path:
		get_tree().change_scene_to_file(Global.prev_scene_path)
		
		# Global.curNodeId += 1
