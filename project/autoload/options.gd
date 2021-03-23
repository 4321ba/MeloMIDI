extends Node

var triangle_follows_cursor: bool = false
enum {JUMP_IF_PLAYING_OFFSCREEN, DONT_FOLLOW_PLAYBACK, SCREEN_FOLLOWS_PLAYBACK}
var screen_follows_cursor: int = JUMP_IF_PLAYING_OFFSCREEN
