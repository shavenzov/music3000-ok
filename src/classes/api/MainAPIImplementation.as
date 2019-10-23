package classes.api
{
	import classes.api.data.ProjectInfo;
	import classes.api.data.UserInfo;
	import classes.api.errors.APIError;
	import classes.api.events.BrowseProjectEvent;
	import classes.api.events.GetProjectEvent;
	import classes.api.events.InviteFriendsEvent;
	import classes.api.events.LimitationsEvent;
	import classes.api.events.OrderUserListEvent;
	import classes.api.events.ProjectNameEvent;
	import classes.api.events.PublishEvent;
	import classes.api.events.RemoveProjectEvent;
	import classes.api.events.SaveProjectEvent;
	
	import com.serialization.Serialize;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	import handler.NetErrorHandler;
	
	import mx.core.mx_internal;
	
	use namespace mx_internal;
	
	public class MainAPIImplementation extends SynchroAPI
	{
		/**
		 * Результат последней операции browse Examples 
		 */		
		private var _examples : Array;
		
		public function MainAPIImplementation()
		{
			super();
			processErrorFunction = NetErrorHandler.processError;
			
			Settings.notifier.addListener( Event.CHANGE, onSettingsChanged, this );
			
			if ( Settings.loaded )
			{
				onSettingsChanged( null );
			}
		}
		
		/**
		 * Если настройки были изменены 
		 * @param e
		 * 
		 */		
		private function onSettingsChanged( e : Event ) : void
		{
			nc.connect( Settings.AMF_HOST );
		}
		
		public function get examples() : Array
		{
			return _examples;
		}
		/*
		public function get numProjects() : int
		{
			return _userInfo.numProjects;
		}
		
		public function get maxProjects() : int
		{
			return _userInfo.pro ? int.MAX_VALUE : _userInfo.maxProjects;
		}
		*/
		public function get userInfo() : UserInfo
		{
			return _userInfo;
		}
		
		private function parseProjects( responds : Object, eventType : String, updateExamples : Boolean = false, updateProjects : Boolean = false ) : void
		{
			var data     : Array = responds.data as Array;
			var projects : Array = new Array( data.length );
			
				for ( var i : int = 0; i < data.length; i ++ )
				{
					projects[ i ] = new ProjectInfo();
					projects[ i ].name = data[ i ].name;
					projects[ i ].updated = Serialize.timeStampToDate( data[ i ].updated );
					projects[ i ].created = Serialize.timeStampToDate( data[ i ].created );
					projects[ i ].userGenre = Serialize.toBoolean( data[ i ].userGenre );
					projects[ i ].genre = data[ i ].genre;
					projects[ i ].id = parseInt( data[ i ].id );
					projects[ i ].owner = parseInt( data[ i ].owner );
					projects[ i ].tempo = parseInt( data[ i ].tempo );
					projects[ i ].duration = parseInt( data[ i ].duration );
					projects[ i ].description = data[ i ].description;
					projects[ i ].access = data[ i ].access;
					projects[ i ].readonly = Serialize.toBoolean( data[ i ].readonly );
				}
			
			
			/*if ( updateProjects )
			{
				_userInfo.numProjects = int( responds.count );
			}
			else*/
			if ( updateExamples )
			{
			  _examples = projects;	
			}
			
			dispatchEvent( new BrowseProjectEvent( eventType, projects ) );
		}
		
		private function onBrowseProjects( responds : Object ) : void
		{
		   parseProjects( responds, BrowseProjectEvent.BROWSE_PROJECTS, false, true ); 	
		}
		
		public function browseProjects( user_id : int = -1,  offset : int = -1, limit : int = -1 ) : void
		{
			call( 'API.browseProjects', onBrowseProjects, user_id == -1 ? _userInfo.id : user_id, offset, limit );
		}
		
		public function browseProjectsByNetUserID( netUserID : String, offset : int = -1, limit : int = -1 ) : void
		{
			call( 'API.browseProjectsByNetUserID', onBrowseProjects, netUserID, offset, limit );
		}
		
		private function onBrowseExamples( responds : Object ) : void
		{
			parseProjects( responds, BrowseProjectEvent.BROWSE_EXAMPLES, true );	
		}
		
		public function browseExamples( offset : int = -1, limit : int = -1 ) : void
		{
			call( 'API.browseExamples', onBrowseExamples, offset, limit );
		}
		
		private function onProjectRemoved( responds : Object ) : void
		{
			//_userInfo.numProjects --;
			dispatchEvent( new RemoveProjectEvent( RemoveProjectEvent.REMOVE ) );
		}
		
		public function removeProject( projectID : int ) : void
		{
			call( 'API.removeProject', onProjectRemoved, projectID );
		}
		
		private function onSaveProject( responds : Object ) : void
		{
			if ( responds != null )
			{	
				dispatchEvent( new SaveProjectEvent( SaveProjectEvent.SAVE, int( responds ) ) );
				return;
			}
			
			dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, 'При попытке сохранить микс произошла ошибка.' ) );
		}
		
		private function onUpdateProject( responds : Object ) : void
		{
			if ( responds != null )
			{
				dispatchEvent( new SaveProjectEvent( SaveProjectEvent.UPDATE, int( responds ) ) );
				return;
			}
			
			dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, 'При попытке обновить микс произошла ошибка.' ) );
		}
		
		public function saveProject( info : Object, data : String ) : void
		{
			call( 'API.saveProject', onSaveProject, info, data );
		}
		
		public function updateProject( info : Object, data : String ) : void
		{
			call( 'API.updateProject', onUpdateProject, info, data );
		}
		
		private function onGetProject( responds : Object ) : void
		{
			dispatchEvent( new GetProjectEvent( GetProjectEvent.GET_PROJECT, String( responds ) ) );
		}
		
		public function getProject( projectID : int, source : int = ProjectSource.PROJECTS ) : void
		{
			call( 'API.getProject', onGetProject, projectID, source );
		}
		
		private function sendNameEvent( responds : Object, eventType : String ) : void
		{
			var error : Boolean = false;
			var name  : String;
			
			if ( responds is Number )
			{
				error = true;
			}
			else
			{
				name = String( responds );
			}
			
			dispatchEvent( new ProjectNameEvent( eventType, error ? null : name, error ? int( responds ) : APIError.OK ) );
		}
		
		private function onGetDefaultProjectName( responds : Object ) : void
		{
			sendNameEvent( responds, ProjectNameEvent.DEFAULT_PROJECT_NAME );
		}
		
		private function onNameResolved( responds : Object ) : void
		{
			sendNameEvent( responds, ProjectNameEvent.RESOLVE_NAME );
		}
		
		public function getDefaultProjectName() : void
		{
			call( 'API.getDefaultProjectName', onGetDefaultProjectName );
		}
		
		public function resolveName( projectName : String ) : void
		{
			call( 'API.resolveName', onNameResolved, projectName ); 
		}
		
		private function onGotLimitations( responds : Object ) : void
		{
			if ( responds != null )
			{
				if ( responds.projects != undefined )
				{
					dispatchEvent( new LimitationsEvent( LimitationsEvent.GOT_LIMITATIONS, responds.projects ) );
					return;
				}
			}
			
			dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, 'При вызове GOT_LIMITATIONS произошла ошибка.' ) );
		}
		
		public function getLimitations() : void
		{
			call( 'API.getLimitations', onGotLimitations );
		}
		
		private function onPublished( responds : Object ) : void
		{
			if ( responds != null )
			{
				dispatchEvent( new PublishEvent( PublishEvent.PUBLISH, int( responds ) ) );
			    return;
			}
			
			dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, 'При вызове publish произошла ошибка.' ) );
		}
		
		public function publish( project_id : int ) : void
		{
			call( 'API.publish', onPublished, project_id );
		}
		
		private function onFriendsInvited( responds : Object ) : void
		{
			if ( responds != null )
			{
				dispatchEvent( new InviteFriendsEvent( InviteFriendsEvent.INVITE_FRIENDS, int( responds ) ) );
				return;
			}
			
			dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, 'При вызове inviteFriends произошла ошибка.' ) );
		}
		
		public function inviteFriends( uids : Array ) : void
		{
			call( 'API.inviteFriends', onFriendsInvited, uids );
		}
		
		private function onDoUserInvitedAction( responds : Object ) : void
		{
			if ( responds != null )
			{
				dispatchEvent( new InviteFriendsEvent( InviteFriendsEvent.DO_USER_INVITED, int( responds ) ) );
				return;
			}
			
			dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, 'При вызове doUserInvitedAction произошла ошибка.' ) );
		}
		
		public function doUserInvitedAction( uid : String, inviter_id : int ) : void
		{
			trace( '--',uid, inviter_id, '--' );
			call( 'API.doUserInvitedAction', onDoUserInvitedAction, uid, inviter_id );
		}
		
		private function onOrderedUserList( responds : Object ) : void
		{
			if ( responds != null )
			{
				dispatchEvent( new OrderUserListEvent( OrderUserListEvent.ORDER_USER_LIST, responds as Array ) );
				return;
			}
			
			dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, 'При вызове orderUserList произошла ошибка.' ) );
		}
		
		public function orderUserList( net_user_ids : Array ) : void
		{
			call( 'API.orderUserList', onOrderedUserList, net_user_ids );
		}
	}
}