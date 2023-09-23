<?xml version="1.0" encoding="UTF-8"?>
<project
	xmlns="http://lime.openfl.org/project/1.0.4"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://lime.openfl.org/project/1.0.4 http://lime.openfl.org/xsd/project-1.0.4.xsd">

	<!--Application Settings-->

	<meta title="hxVLC Sample (Flixel)" packageName="com.majigsaw77.hxvlc" package="com.majigsaw77.hxvlc" version="0.0.1" company="MAJigsaw77" />

	<app file="Sample" main="Main" path="export" preloader="flixel.system.FlxPreloader" />

	<!--Window Settings-->

	<window orientation="landscape" width="1280" height="720" fps="60" background="#FFA500" hardware="true" vsync="false" fullscreen="false" resizable="true" />

	<window allow-high-dpi="true" unless="web" />
	
	<window fullscreen="true" resizable="false" if="mobile" />

	<!--Path Settings-->

	<assets path="assets" />

	<source path="source" />

	<!--Libraries-->

	<haxelib name="flixel" />

	<section if="cpp">
		<haxelib name="hxvlc" if="desktop || android" />
	</section>

	<haxelib name="extension-androidtools" if="android" />

	<!--Libraries Settings-->

	<haxedef name="FLX_NO_MOUSE" if="mobile" />
	<haxedef name="FLX_NO_KEYBOARD" if="mobile" />
	<haxedef name="FLX_NO_TOUCH" if="desktop" />
	<haxedef name="FLX_NO_DEBUG" unless="debug" />

	<haxedef name="HXVLC_LOGGING" if="debug" />

	<!--DPI Awareness-->

	<haxedef name="openfl_dpi_aware" unless="web" />

	<!--Full Dead Code Elimination-->

	<haxeflag name="-dce" value="full" />

	<!--Platforms Config-->

	<section if="android">
		<config>
			<!--Gradle-->
			<android gradle-version="7.4.2" gradle-plugin="7.3.1" />

			<!--Target SDK-->
			<android target-sdk-version="29" if="${lime &lt; 8.1.0}" />
		</config>
	</section>
</project>
