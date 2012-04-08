package com.delosgatos.utils.http
{
	import flash.events.Event;

	public class SendRequestGetJsonErrorEvent extends Event
	{
		public var text:String;
		
		public function SendRequestGetJsonErrorEvent(type:String, text:String)
		{
			super(type);
			this.text = text;
		}
		
		override public function clone():Event
		{
			return new SendRequestGetJsonErrorEvent(type, text);
		}
	}
}