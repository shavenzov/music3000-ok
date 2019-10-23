package classes.api.social.ok.sdk.errors
{
	/**
	 * ...
	 * @author Igor Nemenonok
	 */
	public class Errors 
	{
		
		public static function showError(s:String):void 
		{
			throw new Error(s);
		}
		
	}

}