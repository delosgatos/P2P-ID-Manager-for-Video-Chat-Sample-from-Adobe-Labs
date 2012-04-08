/**
 @class AbstractEvent
 @author Lego <delosgatos@gmail.com>
 @date Dec 7, 2011
 */
 package com.delosgatos.event.abstract
{
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	
	public class AbstractDataEvent extends Event
	{
		/**
		 * For transfer data with event. 
		 * Need to do typed getter in ancestor
		 */
		protected function get _eventData():*
		{ 
			return _eventArguments && _eventArguments.hasOwnProperty(0)
				   ? _eventArguments[0]
				   : null 
		};
		
		protected function set _eventData(value:*):void
		{
			if(!_eventArguments) _eventArguments = new Array();
			_eventArguments[0] = value;
		};
		
		protected var _eventArguments:Array;
		
		public function AbstractDataEvent(type:String, ... args)
		{
			super(type);
			parseArguments(args);
		}
		
		protected function parseArguments(args:Array):void
		{
			_eventArguments = args;
		}
		
		override public function clone():Event
		{
			var eventClass:Class = Object(this).constructor;
			var event:AbstractDataEvent = new eventClass(type, null);
			event.parseArguments(_eventArguments);
			return event;
		}
		
		override public function toString():String
		{
			return formatToString(getQualifiedClassName(this), "type", "bubbles", "cancelable", "eventPhase");
		}
		
		public function garbage():void
		{
			_eventArguments.length = 0;
			_eventArguments = null;
		}
	}
}