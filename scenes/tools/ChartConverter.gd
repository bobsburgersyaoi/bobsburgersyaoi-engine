extends Node2D

var formatFrom:int = 0
var ogChartData:Dictionary
var convertedChartData:Dictionary

func _process(delta: float):
	pass

func _on_load_btn_pressed():
	$UI/LoadChart.show()

func _on_save_btn_pressed():
	$UI/SaveChart.show()

func _on_convert_btn_pressed():
	convertChart()
	$UI/ConvertedChart.text = JSON.stringify(convertedChartData,"\t",false)

func _on_load_chart_file_selected(path: String):
	ogChartData = JSON.parse_string(FileAccess.get_file_as_string(path))
	$UI/OgChart.text = JSON.stringify(ogChartData,"\t",false)

func _on_save_chart_file_selected(path: String):
	pass # Replace with function body.

func convertChart(mode:int = 0):
	convertedChartData = ogChartData
	for i in convertedChartData["notes"]:
		for j in convertedChartData["notes"][i]:
			var nt = j["k"]
			j.erase("k")
			j.get_or_add("nt",nt)
	convertedChartData["generatedBy"] = "converted to bobsburgersyaoi engine's modded format"
