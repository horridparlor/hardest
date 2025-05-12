extends Node
class_name BulletData

const DEFAULT_DATA : Dictionary = {
	"id": 1,
	"art_name": "regular-bullet",
	"sound": "gun-shot"
}

var id : int;
var art_name : String;
var sound_name : String;

static func from_json(data : Dictionary) -> BulletData:
	var bullet : BulletData = BulletData.new();
	data = System.Dictionaries.make_safe(data, DEFAULT_DATA);
	bullet.id = data.id;
	bullet.art_name = data.art;
	bullet.sound_name = data.sound;
	return bullet;
