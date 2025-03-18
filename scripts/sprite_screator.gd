@tool
extends SubViewport

@export_tool_button("Create Sprite")
var create_sprite = func():
    get_texture().get_image().save_png("user://sprite.png")
