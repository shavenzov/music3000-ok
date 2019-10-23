package com.thread
{
	import flash.events.Event;
	
	public class ProcessEvent extends Event
	{
		public static const PROCESS_COMPLETE : String = 'PROCESS_COMPLETE';
		public static const PROCESS_START    : String = 'PROCESS_START';
		
		public var process : IRunnable;
		public var processNumber : int;
		
		public function ProcessEvent(type:String, process : IRunnable, processNumber : int )
		{
			super(type);
			this.process = process;
			this.processNumber = processNumber;
		}
		
		override public function clone():Event
		{
			return new ProcessEvent( type, process, processNumber );
		}
	}
}