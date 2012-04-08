/**
 *   May 20, 2010							
 *  ------------------------------------------------------------------
 *   public class SendRequestGetJson extends EventDispatcher
 * 	 -
 *  ------------------------------------------------------------------ 
 *   (C) 2010 <delosgatos@gmail.com>
 */

package com.delosgatos.utils.http
{
	import flash.events.*;
	import flash.net.*;
	
	public class SendRequestGetJson extends URLLoader
	{
		public static const METHOD_POST:String		= URLRequestMethod.POST;
		public static const METHOD_GET:String		= URLRequestMethod.GET;
		public static const START:String 			= "start_loading";
		public static const LOADING:String			= "answer_loading";
		public static const LOADED:String			= "answer_loaded";
		public static const ERROR:String			= "error";
		public static const HTTP_STATUS:String		= "http_status";
		
		private var _post:URLVariables;
		private var _code:int=0;
		private var _data:Object;
		private var _fullness:Number;
		private var _errorText:String;
		private var _url:String;
		private var _method:String;
		
		private var _request:URLRequest;
		private var _commandHasSent:Boolean;
		
		public function get fullness():Number{return _fullness;}
		public function get code():int{return _code;}
		public function get errorText():String{return _errorText;}

		public function doSend(sendData:Object = null):void
		{	
			cleanUp();
			_post = new URLVariables();
			_commandHasSent = true;
			setListeners(this);
			_request = new URLRequest(_url);
			var now:Date = new Date();
			if(sendData){
				for(var i:String in sendData){
					_post[i] = sendData[i];
				}
			}
			_post.timestamp = now.getDay()+'-'+now.getHours()+'-'+now.getMinutes()+'-'+now.getSeconds()+'-'+now.getMilliseconds();
			_request.data = _post;
			_request.method = _method;
			try
			{
				load(_request);
			}
			catch(e:Error)
			{
				_errorText = "Can't perform load operation";
				dispatchEvent(new SendRequestGetJsonErrorEvent(ERROR, _errorText));
			}
		}
		
		public function setListeners(dispatcher:IEventDispatcher):void
		{
			dispatcher.addEventListener(Event.COMPLETE, completeHandler);
			dispatcher.addEventListener(Event.OPEN, openHandler);
			dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		}
		
		public function unsetListeners(dispatcher:IEventDispatcher):void
		{
			if(dispatcher.hasEventListener(Event.COMPLETE)) 					
				dispatcher.removeEventListener(Event.COMPLETE, completeHandler);
			if(dispatcher.hasEventListener(Event.OPEN)) 						
				dispatcher.removeEventListener(Event.OPEN, openHandler);
			if(dispatcher.hasEventListener(ProgressEvent.PROGRESS)) 			
				dispatcher.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
			if(dispatcher.hasEventListener(SecurityErrorEvent.SECURITY_ERROR)) 	
				dispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			if(dispatcher.hasEventListener(HTTPStatusEvent.HTTP_STATUS)) 		
				dispatcher.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			if(dispatcher.hasEventListener(IOErrorEvent.IO_ERROR)) 				
				dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		}
		
		private function completeHandler(e:Event):void
		{
			try{
				_data = data ? JSON.parse(data) : null;
				dispatchEvent(new SendRequestGetJsonResultEvent(LOADED, _data));
			}catch(err:Error){
				_errorText = err.message + ": "+data;
				dispatchEvent(new SendRequestGetJsonErrorEvent(ERROR, _errorText));
			}
			cleanUp();
		}
		
		private function openHandler(e:Event):void
		{
			dispatchEvent(new Event(START));
		}
		
		private function progressHandler(e:ProgressEvent):void
		{
			if(e.bytesTotal) _fullness = e.bytesLoaded/e.bytesTotal; else _fullness = 1;
			dispatchEvent(new Event(LOADING));
		}
		
		private function httpStatusHandler(e:HTTPStatusEvent):void
		{
			_code = e.status;
			dispatchEvent(new SendRequestGetJsonStatusEvent(HTTP_STATUS, _code));
		}
		
		private function securityErrorHandler(e:SecurityErrorEvent):void
		{
			_errorText = e.text;
			dispatchEvent(new SendRequestGetJsonErrorEvent(ERROR, _errorText));
			cleanUp();
		}
		
		private function ioErrorHandler(e:IOErrorEvent):void
		{
			_errorText = e.text;
			dispatchEvent(new SendRequestGetJsonErrorEvent(ERROR, _errorText));
			cleanUp();
		}
		
		public function SendRequestGetJson(
			url:String,  
			method:String = METHOD_POST, 
			dataFormat:String = URLLoaderDataFormat.TEXT
		):void
		{
			super();
			_url = url;
			_method = method;
			this.dataFormat = dataFormat;
			_commandHasSent = false;
		}
		
		public function cleanUp():void{
			data = null;
			_data = null;
			_post = null;
			_commandHasSent = false;
			unsetListeners(this);
		}
	}
}