package components.library.project
{
	import classes.PaletteSample;
	
	import components.library.SampleItemRenderer;
	
	public class PaletteItemRenderer extends SampleItemRenderer
	{
		public function PaletteItemRenderer()
		{
			super();
		}
		
		override public function set data( value : Object ) : void
		{
			if ( value )
			{
				super.data = value.description;	
			}
		}
	}
}