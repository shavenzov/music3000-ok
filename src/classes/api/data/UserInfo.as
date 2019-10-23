package classes.api.data
{
	import com.utils.DateUtils;

	public class UserInfo
	{
		/**
		 * Идентификатор сессии 
		 */		
		public var session_id  : String;
		
		/**
		 * Идентификатор пользователя в системе 
		 */		
		public var id : int;
		
		/**
		 * Дата регистрации 
		 */		
		public var registered  : Date;
		/**
		 * Дата последнего входа 
		 */		
		public var loged_in    : Date;
		/**
		 * Флаг означающий истекло ли действие про аккаунта или нет?
		 */		
		public var pro : Boolean;
		/**
		 * Количество денег на счету 
		 */		
		public var money : Number;
		/**
		 * Общее количество секунд которое провел пользователь за программой 
		 */		
		public var time : int;
		
		/**
		 * Стоимость в монетах, одной публикации 
		 */		
		public var publicationPrice : Number;
		
		/**
		 *Коэффициент для определения бонуса в процентах 
		 */		
		public var bonusPercent : Number;
		
		/**
		 * Бонус за приглашенного друга в монетах 
		 */		
		public var inviteUserBonus : Number;
		
		public function clone() : UserInfo
		{
			var u : UserInfo  = new UserInfo();
			    u.session_id  = session_id;
				u.id          = id;
				u.registered  = new Date( registered.time );
				u.loged_in    = new Date( loged_in.time );
				u.pro         = pro;
				u.money       = money;
				u.time        = time;
				
				u.publicationPrice = publicationPrice;
				u.bonusPercent = bonusPercent;
				u.inviteUserBonus = inviteUserBonus;
				
				
			return u;	
		}
		
		public function toString():String
		{
			var str : String = '';
			    str += 'session_id = ' + session_id + '\n';
				str += 'id = ' + id + '\n';
				str += 'registered = ' + DateUtils.format( registered ) + '\n';
				str += 'loged_in = ' + DateUtils.format( loged_in ) + '\n';
				str += 'pro = ' + pro + '\n';
				str += 'money = ' + money + '\n';
				str += 'time = ' + time + '\n';
				
				str += 'publicationPrice = ' + publicationPrice + '\n';
				str += 'bonusPercent = ' + bonusPercent + '\n';
				str += 'inviteUserBonus = ' + inviteUserBonus + '\n';
			
			return str;	
		}
	}
}