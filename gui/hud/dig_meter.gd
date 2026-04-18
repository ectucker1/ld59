extends ProgressBar

func _ready() -> void:
	GlobalEvents.dig_usage.connect(dig_usage)

func dig_usage(remaining: int, max: int) -> void:
	set_value_no_signal((float(remaining) / float(max)) * 100.0)
