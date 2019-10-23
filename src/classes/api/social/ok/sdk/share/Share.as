package classes.api.social.ok.sdk.share
{
	import classes.api.social.ok.OKApi;
	/**
	 * ...
	 * @author Igor Nemenonok
	 */
	public class Share 
	{
		
		/**
		 * Add share with link URL and optional commentary. URL must be accessible by odnoklassniki server.
		 * http://dev.odnoklassniki.ru/wiki/display/ok/REST+API+-+share.addLink
		 * @param	linkUrl - Shared resource URL 
		 * @param	callback
		 * @param	comment - First comment attached to shared resource link 
		 */
		public static function addLink(linkUrl:String, callback:Function, comment:String = ""):void {
			OKApi.callRestApi("share.addLink", callback, OKApi.getSendObject({linkUrl:linkUrl, comment:comment }) );
		}
		
	}

}