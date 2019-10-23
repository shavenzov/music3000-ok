package classes.api.errors
{
	public class APIError
	{
		public static const ERROR                                : int = -1;   //Неизвестная ошибка
		
		public static const PROJECT_WITH_THIS_NAME_ALREADY_EXISTS : int = -2; //Проект с таким именем уже существует
		public static const NOT_CORRECT_PROJECT_DATA : int = -3; //Данные проекта не корректные или содержат ошибку
		
		public static const SESSION_NOT_FOUND                     : int = -100; //Идентификатор сессии не верен или сессия истекла
		
		public static const OK                                    : int = 0; //Все хорошо
		
		public static const MAX_PROJECTS_PER_DAY_EXCEEDED         : int = -10;   //Исчерпано максимальное количество проектов в день
		public static const MAX_PROJECTS_FOR_BASIC_MODE_EXCEEDED  : int = -5;    //Максимальное количество миксов, для базового аккаунта исчерпано
		
		public static const NOT_ENOUGH_MONEY                     : int = -15; //Недостаточно монет для выполнения операции
		public static const PRICE_INDEX_NOT_EXISTS               : int = -20; //Указан неверный индекс операции
		
		public static const USER_NOT_REGISTERED                  : int = -98; //Пользователь ещё не зарегистрирован
		public static const USER_ALREADY_REGISTERED              : int = - 100; //Пользователь уже зарегистрирован 
	}
}