package components.controls
{
	import com.utils.ImageUtil;
	
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	
	import mx.utils.GraphicsUtil;

	public class UserFace extends CachedImage
	{
		public function UserFace()
		{
			super();
		}
		
		override protected function getDummyImage() : DisplayObject
		{
			var s : DisplayObject = new Assets.FRIEND_INVITED_ICON();
			
			ImageUtil.resizeTo( s, 50.0 );
			
			return s;
		}
	}
}