import classes.SamplePlayer;
import classes.api.MainAPI;
import classes.api.MainAPIImplementation;
import classes.api.data.ProjectInfo;
import classes.api.events.LimitationsEvent;
import classes.api.events.MessageEvent;
import classes.api.events.ServerSyncEvent;
import classes.api.events.UserEvent;
import classes.api.social.ok.OKApi;
import classes.api.social.ok.events.ApiCallbackEvent;
import classes.events.CreateTrackEvent;
import classes.tasks.mixdown.MixdownTask;
import classes.tasks.project.BrowseProjectsTask;
import classes.tasks.project.OpenProjectTask;
import classes.tasks.project.ProjectTask;

import com.audioengine.sequencer.events.SequencerEvent;
import com.thread.events.TaskEvent;
import com.utils.ConjugationUtils;

import components.controls.tips.MoneyToolTipV;
import components.managers.HintManager;
import components.managers.PopUpManager;
import components.sequencer.VisualSequencer;
import components.sequencer.clipboard.Clipboard;
import components.sequencer.timeline.events.SelectionSampleEvent;
import components.welcome.Slides;
import components.welcome.WelcomeDialog;
import components.welcome.events.BrowseProjectsEvent;
import components.welcome.events.OpenProjectEvent;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.filters.BevelFilter;
import flash.filters.DropShadowFilter;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.core.UIComponent;
import mx.events.CloseEvent;
import mx.events.ToolTipEvent;
import mx.managers.history.History;

private var _vs : VisualSequencer;

private var project : ProjectTask;

private var api : MainAPIImplementation;

/**
 * При всплывании подсказки на кнопке "Опубликовать Микс" 
 * @param e
 * 
 */
private function onMixdownTooltipCreate( e : ToolTipEvent ) : void
{
	var tip : MoneyToolTipV = new MoneyToolTipV();
	    //tip.text = UIComponent( e.currentTarget ).toolTip;
		tip.price = api.userInfo.publicationPrice.toString();
	
	e.toolTip = tip;	
}

private function onInit() : void
{
	api = MainAPI.impl;
	OKApi.getInstance().addListener( ApiCallbackEvent.CALL_BACK, onOrderResult, this );
    History.listener.addEventListener( Event.CHANGE, onHistoryChanged );
}

private function onAddedToStage() : void
{
	Clipboard.impl.addEventListener( Event.CHANGE, onClipboardChange );
	creationComplete();
}

private function onRemovedFromStage() : void
{
	Clipboard.impl.removeEventListener( Event.CHANGE, onClipboardChange );
}

public function get vs() : VisualSequencer
{
	return _vs;
}

public function set vs( value : VisualSequencer ) : void
{
	if ( _vs != value )
	{	
		_vs = value;
		
		if ( _vs )
		{
			_vs.removeEventListener( SelectionSampleEvent.CHANGE, updateButtons );
			_vs.removeEventListener( CreateTrackEvent.CREATE_TRACK, updateButtons );
			_vs.removeEventListener( SequencerEvent.ADD_SAMPLE, updateButtons );
			_vs.removeEventListener( SequencerEvent.REMOVE_SAMPLE, updateButtons );
			_vs.removeEventListener( SequencerEvent.CLEAR, updateButtons );
			_vs.removeEventListener( SequencerEvent.PROJECT_CHANGED, updateButtons );
		}
		
		_vs.addEventListener( SelectionSampleEvent.CHANGE, updateButtons );
		_vs.addEventListener( CreateTrackEvent.CREATE_TRACK, updateButtons );
		_vs.addEventListener( SequencerEvent.ADD_SAMPLE, updateButtons );
		_vs.addEventListener( SequencerEvent.REMOVE_SAMPLE, updateButtons );
		_vs.addEventListener( SequencerEvent.CLEAR, updateButtons );
		_vs.addEventListener( SequencerEvent.PROJECT_CHANGED, updateButtons );
	}
}

private function onClipboardChange( e : Event ) : void
{
	var numSamples : int = 0;
	
	if ( Clipboard.impl.dataType == Clipboard.SAMPLES )
	{
		numSamples = Clipboard.impl.data.length;
	}
	
	paste_button.enabled = numSamples > 0;
}

private function updateButtons( e : Event ) : void
{
	var numSamples : int = _vs.numVisualSamples;
	var selectedSamples : int = _vs.selectedSamples;
	var actualSamples : int = _vs.actualSamples;
	//trace( _vs.actualSamples, _vs.numSamples, _vs.numVisualSamples );
	select_all_button.enabled = ( numSamples > 0 ) && ( numSamples != selectedSamples );
	
	var sel : Boolean = ( selectedSamples > 0 ) && ( numSamples > 0 );
	
	copy_button.enabled = sel;
	cut_button.enabled = sel;
	delete_button.enabled = sel;
	
	mixdown_button.visible = mixdown_button.includeInLayout = actualSamples > 0;
	updateProjectButton();
}

private function updateProjectButton() : void
{
	new_project_button.visible = new_project_button.includeInLayout = ! project.isNewProject && ( _vs.numTracks > 0 );
}

private function creationComplete() : void
{
	navigator.client = _vs.timeline;
	project = new ProjectTask( _vs, saveLabel );
	project.addEventListener( TaskEvent.START, onStartOperation );
	project.addEventListener( TaskEvent.COMPLETE, onCompleteOperation );
	
	ApplicationModel.topPanel = this;
	ApplicationModel.project  = project;
	ApplicationModel.vs = _vs;
	
	api.addListener( MessageEvent.MESSAGE, onNewMessage, this );
	
	if ( api.firstTime ) //Пользователь зашел впервые
	{
		showWelcomeDialog( 0 );	
	}
	else 
	{
		//Мгновенно забираем последние сообщения
		initCheck = true;
		PopUpManager.showLoading();
		api.addListener( ServerSyncEvent.SYNC, onTouched, this );
		api.touch();
	}
}

private function onNewMessage( e : MessageEvent ) : void
{
	if ( initCheck )
	{
		showWelcomeDialog( Slides.BONUS_MESSAGE, null, Slides.WELCOME, null, e.messages );
	}
	else
	{
		showWelcomeDialog( Slides.BONUS_MESSAGE, null, -2, null, e.messages );	
	}
}

//Первая проверка для определении в методе 'onProExpired' приложение запускается
private var initCheck : Boolean;

private function onTouched( e : ServerSyncEvent ) : void
{
	initCheck = false;
	api.removeListener( ServerSyncEvent.SYNC, onTouched );
	PopUpManager.hideLoading();
	
	if ( ! welcomeDialog )
	{
		showWelcomeDialog( Slides.WELCOME );
	}
}

private function onStartOperation( e : Event ) : void
{
	projects_button.enabled = 
	new_project_button.enabled = ! project.loading;
}

private function onCompleteOperation( e : Event ) : void
{
	onStartOperation( null );
	updateProjectButton();
}

private var welcomeDialog : WelcomeDialog;
private var runPlayAfterClose : Boolean; //Возобновить воспроизведение после закрытия диалога Welcome

public function showWelcomeDialog( viewIndex : int, viewState : String = null, fromViewIndex : int = -2, fromViewState : * = -2, other : * = null ) : void
{
	if ( ! welcomeDialog )
	{
		_vs.showDragAndDropTip = false;
		
		welcomeDialog = new WelcomeDialog();
		
		welcomeDialog.addEventListener( 'newProject', onNewProject );
		welcomeDialog.addEventListener( BrowseProjectsEvent.BROWSE_PROJECTS, onBrowseProjects );
		welcomeDialog.addEventListener( OpenProjectEvent.OPEN, onOpenProject );
		welcomeDialog.addEventListener( CloseEvent.CLOSE, onWelcomeDialogClose );
		
		welcomeDialog.viewIndex = viewIndex;
		welcomeDialog.viewState = viewState;
		welcomeDialog.fromIndex = fromViewIndex == -2 ? -1 : fromViewIndex;
		welcomeDialog.fromState = fromViewState;
		welcomeDialog.other = other;
		
		PopUpManager.addPopUp( welcomeDialog, DisplayObject( FlexGlobals.topLevelApplication ), true );
		PopUpManager.centerAndResizePopUp( welcomeDialog );
		
		SamplePlayer.impl.stop();
		runPlayAfterClose = _vs.playing;
		
		if ( runPlayAfterClose )
		{
			_vs.stop();
		}
	}
	else
	{
		welcomeDialog.go( viewIndex, viewState, fromViewIndex, fromViewState, other );
	}
}

private function hideWelcomeDialog() : void
{
	if ( welcomeDialog )
	{
		PopUpManager.removePopUp( welcomeDialog );
		welcomeDialog.removeEventListener( 'newProject', onNewProject );
		welcomeDialog.removeEventListener( BrowseProjectsEvent.BROWSE_PROJECTS, onBrowseProjects );
		welcomeDialog.removeEventListener( OpenProjectEvent.OPEN, onOpenProject );
		welcomeDialog.removeEventListener( CloseEvent.CLOSE, onWelcomeDialogClose );
		welcomeDialog = null;
		_vs.showDragAndDropTip = true;
	}
}

private function onWelcomeDialogClose( e : CloseEvent ) : void
{
	hideWelcomeDialog();
	
	if ( runPlayAfterClose )
	{
		_vs.play();
	}
}

private function onOpenProject( e : OpenProjectEvent ) : void
{
	hideWelcomeDialog();
	showOpenProjectDialog( e.info, e.fromIndex, e.fromState );
}

private function onBrowseProjects( e : BrowseProjectsEvent ) : void
{
	showBrowserDialog( e.selectedUser );
}

private function onNewProject( e : Event ) : void
{
	hideWelcomeDialog();
	project.createNewMix();
	ApplicationModel.library.show( 0 );
}

private function newProjectClick() : void
{
	if ( project.projectsExceeded ) //Уже нельзя сохранять новые миксы
	{
		HintManager.show( LimitationsEvent.getErrorDescription( project.projectsErrorCode, true ), true, new_project_button, true );
	}
	else
	{
		checkLimitations();	
	}
}

private function onGotLimitations( e : LimitationsEvent ) : void
{
	api.removeListener( LimitationsEvent.GOT_LIMITATIONS, onGotLimitations );
	PopUpManager.hideLoading();
	
	if ( e.projectsExceeded )
	{
		HintManager.show( LimitationsEvent.getErrorDescription( e.projectsErrorCode, true ), true, new_project_button, true );
	}
	else
	{
		Alert.showConfirmation( 'Действительно создать новый микс?', alertCloseHandler );
	}
}

private function checkLimitations() : void
{
	PopUpManager.showLoading();
	
	api.addListener( LimitationsEvent.GOT_LIMITATIONS, onGotLimitations, this );
	api.getLimitations();
}

private function alertCloseHandler( e : CloseEvent ) : void
{
	if ( e.detail == Alert.YES )
	{
		project.createNewMix();	
	}
}

override protected function createChildren() : void
{
	super.createChildren();
	navigator.filters = [
		new DropShadowFilter( 3 ),
		new BevelFilter( 6, 248, 0xffffff, 1.0, 0x666666, 1.0, 32, 32, 0.32 )
	];
	/*
	tools1.filters = [ new BlurFilter( 2.0, 2.0 ),
		new DropShadowFilter( 3 ),
		new BevelFilter( 6, 248, 0xffffff, 1.0, 0x666666, 1.0, 32, 32, 0.32 ) ];
	
	tools2.filters = [ new BlurFilter( 2.0, 2.0 ),
		new DropShadowFilter( 3 ),
		new BevelFilter( 6, 248, 0xffffff, 1.0, 0x666666, 1.0, 32, 32, 0.32 ) ];*/
}

private function onHistoryChanged( e : Event ) : void
{
	redo_button.enabled = History.isCanRedo();
	//redo_button.toolTip = redo_button.enabled ? History.redoOpName() : null;	
	
	undo_button.enabled = History.isCanUndo();
	//undo_button.toolTip = undo_button.enabled ? History.undoOpName() : null;
}

private function undoClick( e : MouseEvent ) : void
{
	History.undo();
}

private function redoClick( e : MouseEvent ) : void
{
	History.redo();
}

private function helpClick() : void
{
	showWelcomeDialog( 2, 'normal' );
}

private function selectAllClick() : void
{
	_vs.selectAllSamples();
}

private function cutClick() : void
{
	_vs.cutSelectedSamples();
}

private function copyClick() : void
{
	_vs.copySelectedSamples();
}

private function pasteClick() : void
{
	_vs.pasteFromClipboard();
}

private function deleteClick() : void
{
	_vs.deleteSelectedSamples();
}

private var openDialog : OpenProjectTask;
private var cancelViewIndex : int;
private var cancelViewState : String;

private function showOpenProjectDialog( info : ProjectInfo, cancelViewIndex : int = 3, cancelViewState : String = null ) : void
{
	if ( ! openDialog )
	{
		this.cancelViewIndex = cancelViewIndex;
		this.cancelViewState = cancelViewState;
		
		openDialog = new OpenProjectTask( _vs, project, info );
		openDialog.addEventListener( CloseEvent.CLOSE, onOpenProjectDialogClosed );
		openDialog.show();
	}
}

private function onOpenProjectDialogClosed( e : CloseEvent ) : void
{
  	if ( openDialog )
	{
		openDialog.removeEventListener( CloseEvent.CLOSE, onOpenProjectDialogClosed );
		
		if ( e.detail == Alert.NO ) //Попытаться заново загрузить микс
		{
			project.clear();
			var pInfo : ProjectInfo = openDialog.info;
			openDialog = null;
			showOpenProjectDialog( pInfo );
		}
		else
		{
			openDialog = null;
			
			if ( e.detail == Alert.CANCEL )//Пользователь отменил операцию загрузки проекта
			{
				project.clear();
				showWelcomeDialog( cancelViewIndex, cancelViewState );
			}
			else
			{
				//Если этот микс нельзя сохранять, т.к. исчерпано максимальное количество миксов
				if ( ! project.isCanToSave )
				{
					showWelcomeDialog( Slides.MIX_OPENED_READ_ONLY );
				}
			}
		}
	}
}

private var browserDialog : BrowseProjectsTask;

private function showBrowserDialog( selectedUser : Object = null ) : void
{
	if ( ! browserDialog )
	{
		browserDialog = new BrowseProjectsTask( project.info, selectedUser );
		browserDialog.addEventListener( CloseEvent.CLOSE, onCloseProjectsBrowser );
		browserDialog.show();	
	}
}

private function projectsClick() : void
{
  showBrowserDialog();
}

private function onCloseProjectsBrowser( e : CloseEvent ) : void
{
	if ( browserDialog.selectedProject )
	{
		hideWelcomeDialog();
		showOpenProjectDialog( browserDialog.selectedProject );
	}
	
	browserDialog.removeEventListener( CloseEvent.CLOSE, onCloseProjectsBrowser );
	browserDialog.destroy();
	browserDialog = null;
}

private var mixdownDialog : MixdownTask;

private function mixdownClick() : void
{
	var playingArea : Object = _vs.seq.getPlayingArea();
	
	if ( playingArea.length < Settings.MIN_PUBLICATION_LENGTH )
	{
		Alert.showConfirmation( 'Микс получается слишком коротким. Уверен что хочешь его опубликовать?', mixdownConfirmationCloseHandler );
	}
	else if ( _vs.actualSamples != _vs.numSamples )
	{
		Alert.showConfirmation( 'Не все сэмплы размещенные на дорожках были загружены до конца. Если начать сведение сейчас, то не загруженные сэмплы будут проигнорированы. Действительно начать публикацию?', mixdownConfirmationCloseHandler );
	}
	else
	{
		showMixdownDialog();	
	}
}

private function mixdownConfirmationCloseHandler( e : CloseEvent ) : void
{
	if ( e.detail == Alert.YES )
	{
		showMixdownDialog();
	}
}

private function onCloseMixdownDialog( e : CloseEvent ) : void
{
	hideMixdownDialog();
}

private var interval_id : int = -1;

private function tick() : void
{
	PopUpManager.hideLoading();
	interval_id = -1;
}

private function setTimer() : void
{
	stopTimer();
	interval_id = setTimeout( tick, 5000 ); 
}

private function stopTimer() : void
{
	if ( interval_id != -1 )
	{
		clearTimeout( interval_id );
		interval_id = -1;
	}
}

/**
 * Зачислены монеты для публикации микса 
 * @param e
 * 
 */
private function onInfoUpdated( e : UserEvent ) : void
{
	PopUpManager.hideLoading();
	showMixdownDialog();
	
	api.removeListener( UserEvent.UPDATE, onInfoUpdated );
}

private function onOrderResult( e : ApiCallbackEvent ) : void
{
	if ( e.method == 'showPayment' )
	{
		if ( e.result == 'ok' )
		{
			//Если монеты ещё не зачислились
			if ( api.userInfo.money < api.userInfo.publicationPrice )
			{
				PopUpManager.showLoading();
				api.addListener( UserEvent.UPDATE, onInfoUpdated, this );
			}
			else
			{
				PopUpManager.hideLoading();
				showMixdownDialog();
			}
		}	
	}	
}

/**
 * Проверяет достаточно ли у пользователя монет для публикации
 * Если не достаточно, то отображает диалог с предложением зачислить монеты 
 * @return 
 * 
 */
private function isEnoughMoneyForPublication() : Boolean
{
  if ( api.userInfo.money >= api.userInfo.publicationPrice )
  {
	  return true;
  }
  
  var needCoins : Number =  api.userInfo.publicationPrice - api.userInfo.money;
  var name : String = needCoins.toString() + ' ' + ConjugationUtils.formatCoins( needCoins ) + ' для публикации микса';
  	  
  ApplicationModel.exitFromFullScreen();
  OKApi.showPayment( name, 'Монеты для публикации микса', ConjugationUtils.getCoinsIndentifier( needCoins ), needCoins, null, JSON.stringify({bonus:false}), 'ok', 'true' );
  
  PopUpManager.showLoading();
  setTimer();
  
  return false;
}

private function showMixdownDialog() : void
{
	if ( ! mixdownDialog )
	{
		/*if ( isEnoughMoneyForPublication() )
		{*/
			mixdownDialog = new MixdownTask( project.info );
			mixdownDialog.addEventListener( CloseEvent.CLOSE, onCloseMixdownDialog );
			mixdownDialog.show();
		//}
	}
}

private function hideMixdownDialog() : void
{
	mixdownDialog = null;
}