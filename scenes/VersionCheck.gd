extends Node2D

var version = float(ProjectSettings.get_setting("application/config/version",0.1))

func _ready():
	$HTTPRequest.request_completed.connect(_on_request_completed)
	$HTTPRequest.request("https://raw.githubusercontent.com/nullfreq/skibidi/refs/heads/main/versiontestthing.txt")

func _on_request_completed(result, response_code, headers, body):
	if version < float(body.get_string_from_utf8()):
		$HUD/Notification.text = "Your version ("+str(version)+") is outdated! Please update to "+body.get_string_from_utf8()
	else:
		$HUD/Notification.text = "Your version is up to date!"
