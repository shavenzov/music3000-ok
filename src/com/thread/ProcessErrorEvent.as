package com.thread
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	public class ProcessErrorEvent extends ErrorEvent
	{
		public static const PROCESS_ERROR : String = 'PROCESS_ERROR';
		
		public var process : IRunnable;
		public var processNumber : int;
		
		public function ProcessErrorEvent(type:String, process : IRunnable, processNumber : int,  text:String="", id:int=0 )
		{
			super(type, false, false, text, id);
			this.process = process;
			this.processNumber = processNumber;
		}
		
		override public function clone():Event
		{
			return new ProcessErrorEvent( type, process, processNumber, text, errorID );
		}
	}
}