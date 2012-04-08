package com.delosgatos.utils.http
{
	import flash.events.Event;

	public class SendRequestGetJsonResultEvent extends Event
	{
		public var result:Object;
		
		public function SendRequestGetJsonResultEvent(type:String, result:Object)
		{
			super(type);
			this.result = result;
		}
		
		override public function clone():Event
		{
			return new SendRequestGetJsonResultEvent(type, result);
		}
	}
}