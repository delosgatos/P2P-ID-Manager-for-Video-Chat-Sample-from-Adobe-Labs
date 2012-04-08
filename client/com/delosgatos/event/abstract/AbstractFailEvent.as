/**
 @class AbstractFailEvent
 @project Beach Romance
 @author Lego <delosgatos@gmail.com>
 @date Dec 7, 2011
 */
package com.delosgatos.event.abstract
{
	

	public class AbstractFailEvent extends AbstractDataEvent
	{
		public static const WARNING:String 	= "WarningEvent";
		public static const ERROR:String 	= "ErrorEvent";
		public static const FATAL:String 	= "FatalErrorEvent";
		
		public function get message():String 
		{
			return String(_eventData);
		} 
		
		public function AbstractFailEvent(type:String, errorText:String)
		{
			super(type, errorText);
		}
		
		override public function garbage():void
		{
			super.garbage();
		}
	}
}