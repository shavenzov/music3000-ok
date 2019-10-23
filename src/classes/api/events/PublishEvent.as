package classes.api.events
{
	import classes.api.errors.APIError;
	
	import flash.events.Event;
	
	public class PublishEvent extends Event
	{
		public static const PUBLISH : String = 'PUBLISH';
		
		public var code : int;
		
		public function PublishEvent( type : String, code : int )
		{
			super(type);
			this.code = code;
		}
		
		public function get success() : Boolean
		{
			return code == APIError.OK;
		}
		
		override public function clone() : Event
		{
			return new PublishEvent( type, code );
		}
	}
}