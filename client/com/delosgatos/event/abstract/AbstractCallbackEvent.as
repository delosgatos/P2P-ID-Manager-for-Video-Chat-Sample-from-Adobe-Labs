/**
 @class AbstractCallbackEvent
 @author Lego <delosgatos@gmail.com>
 @date Dec 7, 2011
 */
 package com.delosgatos.event.abstract
{
	
	public class AbstractCallbackEvent extends AbstractDataEvent
	{
		public function get callback():Function{return _eventArguments[0] as Function;}
		override protected function get _eventData():*{return _eventArguments[1];}
		override protected function set _eventData(value:*):void{_eventArguments[1] = value;}
		
		public function AbstractCallbackEvent(type:String, callback:Function, eventData:* = null)
		{
			super(type, callback, eventData);
		}
	}
}