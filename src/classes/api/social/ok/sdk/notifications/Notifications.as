package classes.api.social.ok.sdk.notifications
{
	import classes.api.social.ok.OKApi;
	/**
	 * ...
	 * @author Igor Nemenonok
	 */
	public class Notifications 
	{
		/**
		 * Sends a simple Application-to-user notification.
		 * This method returns a boolean value that indicates whether the notification was sent successfully or not.
		 * http://dev.odnoklassniki.ru/wiki/display/ok/REST+API+-+notifications.sendSimple
		 * @param	uid - Recepient's ID 
		 * @param	text - Message that will be sent as a notification to the user, whose ID is specified in the "uid" parameter 
		 * @param	callback
		 */
		public static function sendSimple(uid:String, text:String, callback:Function):void 
		{
			OKApi.callRestApi("notifications.sendSimple", callback, { uid:uid, text:text } );
		}
		
	}

}