package components.controls
{
	import mx.controls.LinkButton;
	
	public class LinkButton extends mx.controls.LinkButton
	{
		public function LinkButton()
		{
			super();
			focusEnabled = false;
			tabEnabled = false;
			useHandCursor = false;
		}
		
		override public function set enabled( value : Boolean ) : void
		{
			super.enabled = value;
			alpha = value ? 1 : 0.1;
		}
	}
}