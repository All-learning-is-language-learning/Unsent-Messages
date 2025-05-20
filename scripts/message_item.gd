extends Control

# Store the data
var author_text = ""
var content_text = ""
var time_text = ""

# Flag to track if data has been set
var data_set = false

func _ready():
	# Make sure this control expands properly
	size_flags_horizontal = SIZE_EXPAND_FILL
	
	# Call _process once to update the UI
	_process(0)

func _process(delta):
	# This will run every frame until the labels are properly set
	if data_set:
		# Get references to the labels each frame until successful
		var author_label = find_child("AuthorLabel", true, false)
		var content_label = find_child("ContentLabel", true, false)
		var time_label = find_child("TimeLabel", true, false)
		
		# If we found the labels, set their text
		if author_label and content_label and time_label:
			author_label.text = author_text
			content_label.text = content_text
			time_label.text = time_text
			
			# Log success
			print("Successfully set text for message: ", author_text)
			
			# Stop processing once labels are set
			set_process(false)

func set_data(author: String, content: String, time: String):
	# Store the data
	author_text = author
	content_text = content
	time_text = time + " "
	data_set = true
	
	print("Data set: Author=", author, ", Time=", time)
	
	# Try to immediately set the text
	var author_label = find_child("AuthorLabel", true, false)
	var content_label = find_child("ContentLabel", true, false)
	var time_label = find_child("TimeLabel", true, false)
	
	if author_label and content_label and time_label:
		author_label.text = author_text
		content_label.text = content_text
		time_label.text = time_text
		print("Immediately set text for labels")
		set_process(false)  # No need to process anymore
	else:
		print("Labels not found yet, will try again in _process")
