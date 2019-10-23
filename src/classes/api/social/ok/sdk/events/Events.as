package classes.api.social.ok.sdk.events
{
	import classes.api.social.ok.OKApi;
	/**
	 * ...
	 * @author Igor Nemenonok
	 */
	public class Events 
	{
		/**
		 * Returns number of events need to be displayed for the logged user : messages, notifications, feeds, ...
		 * http://dev.odnoklassniki.ru/wiki/display/ok/REST+API+-+events.get
		 * @param	callback
		 * @param	types - Coma separated list of event types, for which information is requested. Information for all types will be returned, if this parameter is empty. 
		 */
		public static function get(callback:Function, types:String = ""):void 
		{
			OKApi.callRestApi("events.get", callback, { types:types } );
		}
		
		/**
		 * Returns display information about event types: name, icons, messages, ...
		 * http://dev.odnoklassniki.ru/wiki/display/ok/REST+API+-+events.getTypeInfo
		 * @param	callback
		 * @param	types - Coma separated list of event types, for which information is requested. Information for all types will be returned, if this parameter is empty
		 * @param	locale - Language. Return all , if empty 
		 */
		public static function getTypeInfo(callback:Function, types:String = "", locale:String = ""):void 
		{
			OKApi.callRestApi("events.getTypeInfo", callback, { types:types, locale:locale } );
		}
	}

}