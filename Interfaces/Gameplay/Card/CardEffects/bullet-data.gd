extends Node
class_name BulletData

const DEFAULT_DATA : Dictionary = {
	"id": 1,
	"art": "regular-bullet",
	"art2": "",
	"sound": "gun-shot"
}

var id : int;
var art_name : String;
var art_name_2 : String;
var sound_name : String;

static func from_json(data : Dictionary) -> BulletData:
	var bullet : BulletData = BulletData.new();
	data = System.Dictionaries.make_safe(data, DEFAULT_DATA);
	bullet.id = data.id;
	bullet.art_name = data.art;
	bullet.art_name_2 = data.art2;
	bullet.sound_name = data.sound;
	return bullet;
