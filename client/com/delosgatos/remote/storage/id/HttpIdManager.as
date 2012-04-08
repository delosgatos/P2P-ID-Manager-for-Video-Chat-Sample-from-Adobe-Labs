/**
 * Protocol description. This is a very simple protocol for user registration 
 * (or unregistration) and lookup.
 * 
 * For registration, client sends following query string to web-service:
 * 
 * GET cgi-bin/reg.cgi?username=user&identity=peer_id_of_user
 * 
 * Server should respond 200 OK with message body:
 * {"update":"true"}
  * 
 * For unregistration, client sends following request:
 * 
 * GET cgi-bin/reg.cgi?username=user&identity=0 HTTP/1.1
 * 
 * Server response is same as for registration. Registration is refreshed 
 * every 30 minutes.
 * 
 * For user lookup, client sends following request (to avoid caching,
 * request is randomized using time, etc.):
 * 
 * GET cgi-bin/reg.cgi?friends=remote_user HTTP/1.1
 * 
 * If remote user is available, server responds 200 OK with following message body:
 * 
 * {"friend":[{
 *     "user":remote_user
 *     "identity":[peer_id_of_remote_user]
 *   }]
 * }
 * 
 * If remote user is not available, server responds with 200 OK with following 
 * message body:
 * {"friend":[{
 *     "user":remote_user
 *  }]
 * }
 */
 
package com.delosgatos.remote.storage.id
 {
 	import com.delosgatos.utils.http.SendRequestGetJson;
 	import com.delosgatos.utils.http.SendRequestGetJsonErrorEvent;
 	import com.delosgatos.utils.http.SendRequestGetJsonResultEvent;
 	import com.delosgatos.utils.http.SendRequestGetJsonStatusEvent;
 	
 	import flash.events.Event;
 	import flash.events.TimerEvent;
 	import flash.utils.Timer;
			
 	public class HttpIdManager extends AbstractIdManager
 	{	
		public static const ERROR:String			= "idManagerError";
		public static const REGISTER_SUCCESS:String	= "registerSuccess";
		public static const REGISTER_FAILURE:String	= "registerFailure";
		public static const LOOKUP_SUCCESS:String	= "lookupSuccess";
		public static const LOOKUP_FAILURE:String	= "lookupFailure";
		
 	 	private var mWebServiceUrl:String 			= "";
		private var mConnectionTimer:Timer;
		private var mUser:String;
		private var mId:String;
		private var jsonHttpService:SendRequestGetJson;
		
		override protected function doSetService(service:Object):void
		{
			mWebServiceUrl = service as String;
		}
 		
 		override protected function doRegister(user:String, id:String):void
 		{
 			if (mWebServiceUrl.length == 0 || user.length == 0 || id.length == 0)
 			{
				var e:Event = new IdManagerError(REGISTER_FAILURE, "Empty web service URL, user or id");
 				dispatchEvent(e);
 				return;		
 			}
 			
 			mUser = user;
 			mId = id;
			
            var request:Object = new Object();
            request.username = user
            request.identity = id;
			
			jsonHttpService = new SendRequestGetJson(mWebServiceUrl, SendRequestGetJson.METHOD_GET);
			jsonHttpService.addEventListener(SendRequestGetJson.LOADED, onJsonLoaded, false, 0, true);
			jsonHttpService.addEventListener(SendRequestGetJson.ERROR, onJsonError, false, 0, true);
			jsonHttpService.addEventListener(SendRequestGetJson.HTTP_STATUS, onJsonStatus, false, 0, true);
			jsonHttpService.doSend(request);
			
 			// register id to http service
			/*
            mHttpService = new HTTPService();
            mHttpService.url = mWebServiceUrl;
            mHttpService.addEventListener("result", httpResult);
            mHttpService.addEventListener("fault", httpFault);
                
            mHttpService.cancel();
            mHttpService.send(request);
            */
			
            // refresh registration with web service in every 30 minutes
			mConnectionTimer = new Timer(1000 * 60 * 30);
			mConnectionTimer.addEventListener(TimerEvent.TIMER, onConnectionTimer);
            mConnectionTimer.start();
 		}
 		
 		override protected function doLookup(user:String):void
 		{
 			if (jsonHttpService)
 			{
 				var request:Object = new Object();
				request.friends = user;
				// when making repeated calls to same user, it seemed that
				// we recived cached result. So add time, to it to make it unique.
				jsonHttpService.doSend(request);
 			}
 			else
 			{
 				var e:Event = new IdManagerError(LOOKUP_FAILURE, "HTTP service not created");
 				dispatchEvent(e);
 			}
 		}
 		
 		override protected function doUnregister():void
 		{
 			if (jsonHttpService)
			{
				var request:Object = new Object();
				request.username = mUser;
				request.identity = "0";
				jsonHttpService.doSend(request);
			}
					
			if (mConnectionTimer)
			{
 				mConnectionTimer.stop();
 				mConnectionTimer = null;
 			}	
 		}
 		
 		// we need to refresh regsitration with web service periodically
		private function onConnectionTimer(e:TimerEvent):void
		{		
			var request:Object = new Object();
            request.username = mUser;
           	request.identity = mId;
           	var now:Date = new Date();
			request.time = now.getTime();
			jsonHttpService.doSend(request);
		}

 		// process error from web service
		private function onJsonStatus(e:SendRequestGetJsonStatusEvent):void
		{
		}
		
		private function onJsonError(e:SendRequestGetJsonErrorEvent):void
		{	
			var d:IdManagerError = new IdManagerError(ERROR, "HTTP error: " + e.text);
 			dispatchEvent(d);
		}
		
		// process successful response from web service		
		private function onJsonLoaded(e:SendRequestGetJsonResultEvent):void
		{	
			var result:Object = e.result as Object;
			
//trace("[JSON LOADED] ==> "+result.toString());

			var remote:Object;
			if (result.hasOwnProperty("update"))
			{
				// registration response
				if (result.update == true)
				{
					var d:Event = new Event(REGISTER_SUCCESS);
 					dispatchEvent(d);
				}
				else
				{
					d = new IdManagerError(REGISTER_FAILURE, "HTTP update error");
 					dispatchEvent(d);
				}
			}
			else if (result.hasOwnProperty("friend"))
			{
				// party query response
				remote = result.friend as Object;
				if (remote.hasOwnProperty("user") && remote.hasOwnProperty("identity"))
				{
					var identityString:String = remote.identity
					var userString:String = remote.user;
					
					var r:IdManagerEvent = new IdManagerEvent(LOOKUP_SUCCESS, userString, identityString);
					dispatchEvent(r);
				}
				else if (remote.hasOwnProperty("user"))
				{
					userString = remote.user;
					r = new IdManagerEvent(LOOKUP_SUCCESS, userString, "");
					dispatchEvent(r);
				}
				else
				{
					d = new IdManagerError(LOOKUP_FAILURE, "HTTP response does not have user property");
 					dispatchEvent(d);
				}
			}
			else
			{
				d = new IdManagerError(ERROR, "Unhandeled HTTP response");
 				dispatchEvent(d);
			}

		}

 	}
 }
