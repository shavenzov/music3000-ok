package classes.api.events
{
	import flash.events.Event;
	
	public class GetProjectEvent extends Event
	{
		public static const GET_PROJECT : String = 'GET_PROJECT';
		
		public var data : String;
		
		public function GetProjectEvent(type:String, data : String)
		{
			super(type);
			this.data = data;
		}
		
		override public function clone():Event
		{
			return new GetProjectEvent( type, data );
		}
	}
}