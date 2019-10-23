package classes.api.social.ok
{
	import classes.api.CustomEventDispatcher;
	import classes.api.social.ok.core.OdnoklassnikiSession;
	import classes.api.social.ok.events.ApiServerEvent;
	import classes.api.social.ok.net.OdnoklassnikiRequest;
	
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.utils.Dictionary;

	/**
	 * ...
	 * @author Igor Nemenonok
	 */
	public class OKApi extends CustomEventDispatcher
	{
		/**
		 * Информация о текущем пользователе 
		 */		
		public static var userInfo : Object;
		
		/**
		 * Список пользователей установивших приложение 
		 */		
		public static var appUsers : Array;
		
		private static const SECRET_KEY : String = 'F3251E431E9D63B73995F49E';
		
		protected static var _instance:OKApi;
		
		public var session:OdnoklassnikiSession;
		
		protected static var _can_initiate:Boolean = false; 
		
		protected var openRequests:Dictionary;
		
		public static var API_SERVER:String;
		
		public function OKApi() 
		{
			if (_can_initiate == false) {
				throw new Error('Odnoklassniki is an singleton! Call Odnoklassniki.getInstace() instead.');
			}else {
				openRequests = new Dictionary();
			}
		}
		
		/**
		 * Параметры инициализации API 
		 */		
		public static var params : Object;
		
		/**
		 * 
		 * @param	base - reference to application container
		 * @param	secretKey - secret key of your application
		 */
		public static function initialize(base:DisplayObject, secretKey:String = SECRET_KEY ):void 
		{
			params = getFlashVars(base);
			getInstance().session = new OdnoklassnikiSession(params.apiconnection);
			getInstance().session.sessionKey = params.session_key;
			getInstance().session.sessionSecretKey = params.session_secret_key;
			getInstance().session.uid = params.logged_user_id;
			getInstance().session.applicationKey = params.application_key;
			getInstance().session.secretKey = secretKey;
			API_SERVER = params.api_server;
		}
		
		public static function getInstance():OKApi {
			if (_instance == null) {
				_can_initiate = true;
				_instance = new OKApi();
				_can_initiate = false;
			}
			return _instance;
		}
		
		/**
		 * @param	method - name of the method in odnoklassniki API
		 * @param	params - array of parameters passed to method
		 */
		public static function call(method:String,
									params:Array = null):void {
			getInstance().send(method, params);
		}
		
		private function send(method:String, params:Array):void 
		{
			if (getInstance().session.is_connected)
			{
				getInstance().session.connection.send.apply(getInstance().session.connection, ["_proxy_" + getInstance().session.connectionName, method].concat(params));
			}
			else {
				dispatchEvent(new ApiServerEvent(ApiServerEvent.NOT_YET_CONNECTED));
			}
		}
		
		/**
		 * @param	method - Method from Odnoklassniki Rest API
		 * @param	callback - Callback function
		 * @param	params - parameters to send
		 * @param	requestMethod - request method GET/POST
		 */
		public static function callRestApi(method:String, 
										callback:Function, 
										params:Object = null, 
										format:String = 'JSON',
										requestMethod:String = "GET",
										url:String = null):void {
			getInstance().doCallRestApi(method, callback, params, format, requestMethod, url);
		}
		
		private function doCallRestApi(method:String, 
										callback:Function, 
										params:Object = null, 
										format:String = 'JSON',
										requestMethod:String = "GET",
										url:String = null):void {
			var req:OdnoklassnikiRequest = new OdnoklassnikiRequest(API_SERVER, requestMethod);
			req.call(method, params, handleRequestLoad, format, url);
			
			openRequests[req] = callback;
		}
		
		private function handleRequestLoad(rq:OdnoklassnikiRequest):void 
		{
			var resultCallback:Function = openRequests[rq];
			if (resultCallback === null) {
                delete openRequests[rq];
            }
			
			if (rq.success) {
				var data:Object = rq.data;
				resultCallback(data);
			}
			
			delete openRequests[rq];
			
		}
		
		/**
		 * 
		 * @param	data - parameters object
		 * @param	exception
		 * @param	format
		 * @return	MD5.hash of data object
		 */
		public static function getSignature(data:Object, exception:Boolean = false, format:String = "JSON"):Object {
			return getInstance().session.getSignature(data, exception, format);
		}

		/**
		 * Current session
		 */
		public static function get session():OdnoklassnikiSession {
			return getInstance().session;
		}
		
		
		// PUBLIC METHODS
		public static function showPermissions(... permissions ) : void
		{
			getInstance().send("showPermissions", [JSON.stringify(permissions)]);
		}
		
		public static function showInvite(text : String = null, params : String = null) : void
		{
			getInstance().send("showInvite", [text, params]);
		}
		
		public static function showNotification(text : String, params : String = null) : void
		{
			getInstance().send("showNotification", [text, params]);
		}
		
		public static function showPayment(name : String, description : String, code : String, price : int = -1, options : String = null, attributes : String = null, currency: String = null, callback : String = 'false') : void
		{
			getInstance().send("showPayment", [name, description, code, price, options, attributes, currency, callback]);
		}
		
		public static function showConfirmation(method : String, userText : String, signature : String) : void
		{
			getInstance().send("showConfirmation", [method, userText, signature]);
		}
		
		public static function setWindowSize(width : int, height : int) : void
		{
			getInstance().send("setWindowSize", [width.toString(), height.toString()]);
		}
		
		public static function getPageInfo() : void
		{
			getInstance().send("getPageInfo",[]);
		}
		
		private static function getFlashVars(base:DisplayObject):Object {
			return Object( LoaderInfo( base.loaderInfo ).parameters );
		}
		
		public static function getSendObject(d:Object):Object {
			var send_obj:Object = { };
			for (var s:String in d) {
				if (d[s])
					send_obj[s] = d[s];
			}
			return send_obj;
		}
		
	}

}