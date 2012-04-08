package com.delosgatos.remote.storage.id
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import com.delosgatos.event.abstract.AbstractFailEvent;
	
	public class IdManagerService extends EventDispatcher
	{
		public static const UPDATE_ERROR:String 			= "updateError";
		public static const REGISTER_SUCCESS:String 		= "registerSuccess";
		public static const REGISTER_ERROR:String 			= "registerError";
		public static const LOOKUP_SUCCESS:String 			= "lookupSuccess";
		public static const LOOKUP_ERROR:String 			= "lookupError";
		
		// ID management serice
		private var idManager:AbstractIdManager;
		
		private var _eventType:String;
		private var _lookupUser:String;
		private var _lookupId:String;
		
		public function get eventType():String{return _eventType;}
		public function get lookupUser():String{return _lookupUser;}
		public function get lookupId():String{return _lookupId;}

		public function init(idStoreUrl:String, userName:String, connectionId:String):void
		{
			// exchange peer id using web service
			idManager = new HttpIdManager();
			idManager.service = idStoreUrl;
			
			idManager.addEventListener(HttpIdManager.REGISTER_SUCCESS, 	idManagerEvent);
			idManager.addEventListener(HttpIdManager.LOOKUP_SUCCESS, 	idManagerEvent);
			idManager.addEventListener(HttpIdManager.REGISTER_FAILURE, 	idManagerEvent);
			idManager.addEventListener(HttpIdManager.LOOKUP_FAILURE, 	idManagerEvent);
			idManager.addEventListener(HttpIdManager.ERROR, 			idManagerEvent);
			
			idManager.register(userName, connectionId);
		}
		
		public function lookup(userName:String):void
		{
			idManager.lookup(userName);	
		}
		
		// process successful response from id manager
		
		private function idManagerEvent(e:Event):void
		{
			_eventType = e.type;
			if (e.type == HttpIdManager.REGISTER_SUCCESS)
			{
				dispatchEvent(new Event(REGISTER_SUCCESS));	
			}
			else if (e.type == HttpIdManager.REGISTER_FAILURE)
			{
				dispatchEvent(new IdManagerErrorEvent(REGISTER_ERROR, IdManagerError(e).description));
			}
			else if (e.type == HttpIdManager.LOOKUP_SUCCESS)
			{
				// party query response
				var i:IdManagerEvent = e as IdManagerEvent;
				_lookupUser = i.user;
				_lookupId = i.id;
				dispatchEvent(new Event(LOOKUP_SUCCESS));	
			}
			else if (e.type == HttpIdManager.LOOKUP_FAILURE)
			{
				dispatchEvent(new IdManagerErrorEvent(LOOKUP_ERROR, IdManagerError(e).description));
			}
			else
			{
				// all error messages ar IdManagerError type
				dispatchEvent(new IdManagerErrorEvent(AbstractFailEvent.ERROR, IdManagerError(e).description));
			}
		}
		
		public function IdManagerService(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function cleanUp():void{
			if(idManager){
				idManager.unregister();
				idManager = null;
			}
		}
	}
}