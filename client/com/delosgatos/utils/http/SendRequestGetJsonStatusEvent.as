package com.delosgatos.utils.http
{
	import flash.events.Event;

	public class SendRequestGetJsonStatusEvent extends Event
	{
		public var code:int;
		
		public function SendRequestGetJsonStatusEvent(type:String, code:int)
		{
			super(type);
			this.code = code;
		}
		
		override public function clone():Event
		{
			return new SendRequestGetJsonStatusEvent(type, code);
		}
	}
}