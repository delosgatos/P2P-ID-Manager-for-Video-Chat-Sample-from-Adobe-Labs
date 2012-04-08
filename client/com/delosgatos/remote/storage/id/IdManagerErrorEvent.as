/**
 @class IdManagerErrorEvent
 @author Lego <delosgatos@gmail.com>
 @date Mar 30, 2012
 */
package com.delosgatos.remote.storage.id
{	
	import com.delosgatos.event.abstract.AbstractFailEvent;
	
	public class IdManagerErrorEvent extends AbstractFailEvent
	{
		public function IdManagerErrorEvent(type:String, errorText:String)
		{
			super(type, errorText);
		}
	}
}