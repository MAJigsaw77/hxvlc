package hxvlc.openfl.textures;

import lime.utils.UInt8Array;

import openfl.display.BitmapData;
import openfl.display3D.Context3D;
import openfl.display3D.textures.TextureBase;

#if HXVLC_ENABLE_EXPERIMENTAL_PBO
import lime.graphics.opengl.GLBuffer;
#end

/**
 * This class is a video texture that extends TextureBase for efficient video frame rendering.
 * 
 * @see https://github.com/openfl/openfl/blob/develop/src/openfl/display3D/textures/RectangleTexture.hx
 * @see https://github.com/openfl/openfl/blob/3f24568a1dec5d971e167836ea84846607a86e9c/lib/draft-api/src/openfl/media/_internal/NativeVideoBackend.cpp#L500
 */
@:access(openfl.display3D.Context3D)
class VideoTexture extends TextureBase
{
	#if HXVLC_ENABLE_EXPERIMENTAL_PBO
	@:noCompletion
	private static final PBO_BUFFERS:Int = 4;

	@:noCompletion
	private var __pboTarget:Int = 0;

	@:noCompletion
	private var __pbos:Null<haxe.ds.Vector<GLBuffer>>;

	@:noCompletion
	private var __index:Int = 0;
	#end

	@:noCompletion
	private var __frameSize:Int = 0;

	/**
	 * Initializes a VideoTexture object.
	 * 
	 * @param context The context to use for texture operations.
	 * @param bitmapData Initial bitmap data to populate the texture.
	 * @param frameSize The size in bytes of a single video frame, used for buffer allocation.
	 * @param optimizeForRenderToTexture Whether to optimize this texture for render-to-texture operations (used by default).
	 */
	public function new(context:Context3D, bitmapData:BitmapData, frameSize:Int, optimizeForRenderToTexture:Bool = true):Void
	{
		super(context);

		__width = bitmapData.width;
		__height = bitmapData.height;
		__optimizeForRenderToTexture = optimizeForRenderToTexture;
		__textureTarget = __context.gl.TEXTURE_2D;
		__frameSize = frameSize;

		#if HXVLC_ENABLE_EXPERIMENTAL_PBO
		if (__context.__context.type == WEBGL && Std.parseFloat(__context.__context.version) >= 2)
			__pboTarget = __context.__context.webgl2.PIXEL_UNPACK_BUFFER;
		else if (__context.__context.type == OPENGLES && Std.parseFloat(__context.__context.version) >= 3)
			__pboTarget = __context.__context.gles3.PIXEL_UNPACK_BUFFER;
		else if (__context.__context.type == OPENGL && Std.parseFloat(__context.__context.version) >= 2.1)
			__pboTarget = __context.__context.gl.PIXEL_UNPACK_BUFFER;
		#end

		@:nullSafety(Off)
		{
			__context.__bindGLTexture2D(__textureID);

			__context.gl.texImage2D(__textureTarget, 0, __internalFormat, __width, __height, 0, __format, __context.gl.UNSIGNED_BYTE, null);

			__context.__bindGLTexture2D(null);

			#if HXVLC_ENABLE_EXPERIMENTAL_PBO
			if (__pboTarget != 0)
			{
				__pbos = new haxe.ds.Vector<GLBuffer>(PBO_BUFFERS);

				for (i in 0...__pbos.length)
				{
					final pbo:GLBuffer = __context.gl.createBuffer();
					__context.gl.bindBuffer(__pboTarget, pbo);
					__context.gl.bufferData(__pboTarget, new UInt8Array(__frameSize), __context.gl.STREAM_DRAW);
					__context.gl.bindBuffer(__pboTarget, null);
					__pbos[i] = pbo;
				}
			}
			#end
		}

		if (optimizeForRenderToTexture)
			__getGLFramebuffer(true, 0, 0);
	}

	/**
	 * Updates the texture content with new data from a typed array.
	 * 
	 * This method is typically used for uploading new video frames efficiently.
	 * 
	 * @param data The new pixel data.
	 */
	public function uploadFromTypedArray(data:UInt8Array):Void
	{
		if (data.length != __frameSize)
			return;

		@:nullSafety(Off)
		{
			__context.__bindGLTexture2D(__textureID);

			#if HXVLC_ENABLE_EXPERIMENTAL_PBO
			if (__pboTarget != 0 && __pbos != null)
			{
				final pbo:GLBuffer = __pbos[__index];

				__context.gl.bindBuffer(__pboTarget, pbo);
				__context.gl.bufferSubData(__pboTarget, 0, data);
				__context.gl.texSubImage2D(__textureTarget, 0, 0, 0, __width, __height, __format, __context.gl.UNSIGNED_BYTE, cast 0);
				__context.gl.bindBuffer(__pboTarget, null);

				__index = (__index + 1) % __pbos.length;
			}
			else
			{
				__context.gl.texSubImage2D(__textureTarget, 0, 0, 0, __width, __height, __format, __context.gl.UNSIGNED_BYTE, data);
			}
			#else
			__context.gl.texSubImage2D(__textureTarget, 0, 0, 0, __width, __height, __format, __context.gl.UNSIGNED_BYTE, data);
			#end

			__context.__bindGLTexture2D(null);
		}
	}

	public override function dispose():Void
	{
		#if HXVLC_ENABLE_EXPERIMENTAL_PBO
		if (__pbos != null)
		{
			for (i in 0...__pbos.length)
				__context.gl.deleteBuffer(__pbos[i]);

			__pbos = null;
		}
		#end

		super.dispose();
	}

	@:noCompletion
	private override function __setSamplerState(state:openfl.display._internal.SamplerState):Bool
	{
		if (super.__setSamplerState(state))
		{
			if (Context3D.__glMaxTextureMaxAnisotropy != 0)
			{
				var aniso:Int = -1;

				if (state != null && state.filter != null)
				{
					switch (state.filter)
					{
						case ANISOTROPIC2X:
							aniso = 2;
						case ANISOTROPIC4X:
							aniso = 4;
						case ANISOTROPIC8X:
							aniso = 8;
						case ANISOTROPIC16X:
							aniso = 16;
						default:
							aniso = 1;
					}
				}

				if (aniso > Context3D.__glMaxTextureMaxAnisotropy)
					aniso = Context3D.__glMaxTextureMaxAnisotropy;

				__context.gl.texParameterf(__context.gl.TEXTURE_2D, Context3D.__glTextureMaxAnisotropy, aniso);
			}

			return true;
		}

		return false;
	}
}
