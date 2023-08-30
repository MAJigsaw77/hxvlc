package;

import flixel.FlxState;
import hxvlc.flixel.FlxVideo;

class PlayState extends FlxState
{
	override public function create():Void
	{
		var video:FlxVideo = new FlxVideo();
		video.onEndReached.add(function()
		{
			trace('video ended');

			video.dispose();
		});
		video.play('assets/video.mp4');

		super.create();
	}
}
