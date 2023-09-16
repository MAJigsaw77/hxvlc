package;

import flixel.FlxState;
import hxvlc.flixel.FlxVideo;

class PlayState extends FlxState
{
	override function create():Void
	{
		var video:FlxVideo = new FlxVideo();
		video.onEndReached.add(video.dispose);

		#if android
		video.play('https://github.com/MAJigsaw77/hxvlc/raw/main/samples/flixel/assets/video.mp4');
		#else
		video.play('assets/video.mp4');
		#end

		super.create();
	}
}
