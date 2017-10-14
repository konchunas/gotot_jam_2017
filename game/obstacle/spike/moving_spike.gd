extends "../Obstacle.gd"

# Member variables
export var speed = 0.4
var accum = 0.0
var orig_pos

func _fixed_process(delta):
	accum += speed*delta*PI*2.0
	accum = fmod(accum, PI*2.0)
	var d = (1.0+sin(accum))*0.5
	var pos = get_pos()
	var size = get_node("spike").get_item_rect().size * get_node("spike").get_scale() * get_scale()
	set_pos(Vector2(orig_pos.x, orig_pos.y+size.y*d))


func _ready():
	orig_pos = get_pos()
	set_fixed_process(true)