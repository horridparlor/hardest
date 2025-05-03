extends Node
class_name Decklist

var main_deck : Dictionary;
var extra_deck : Dictionary;
var random_keywords : Array;
var random_cards : Dictionary

func _init(
	main_deck_ : Dictionary,
	extra_deck_ : Dictionary,
	random_keywords_ : Array,
	random_cards_ : Dictionary
) -> void:
	main_deck = main_deck_;
	extra_deck = extra_deck_;
	random_keywords = random_keywords_;
	random_cards = random_cards_;
