﻿&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ВостановитьСпискиЗначений(); // Востановление настроек отчета
	флДиаграмма = Ложь; 		 // Вкладка Таблица при открытии всегда выбрана поумолчанию.
	ОтображениеЭлементовФормы(); // Отображение видемости элементов формы
	
	СобытиеПриИзмененииНастроек(ЭтаФорма.Элементы.Результат); //vd_190618
	
КонецПроцедуры

&НаКлиенте
Процедура ВостановитьСпискиЗначений()
	//Если в форме не заполнены основные поля ,то заполним значениями поумолчанию. Предположительно первый запуск отчета.
	Если Детализация.Количество() = 0 Тогда
		Детализация	= ПолучитьОтмеченыеЗначенияСписка(СписокДетализация());
	Иначе
		ВостановитьСписокЗначений("Детализация");	
	КонецЕсли;
	
	Если ДетализацияДиаграммы.Количество() = 0 И ВариантДиаграммы.Количество() = 0 Тогда  
		ДетализацияДиаграммы = ПолучитьОтмеченыеЗначенияСписка(СписокДетализацияДиаграммы());
		ВариантДиаграммы 	 = ПолучитьОтмеченыеЗначенияСписка(СписокВариантДиаграммы());
	Иначе
		ВостановитьСписокЗначений("ДетализацияДиаграммы");
		ВостановитьСписокЗначений("ВариантДиаграммы");
	КонецЕсли;
Конецпроцедуры

// Процедура - Востанавливает список значений по представлениям.
//При сохранении форма не сохраняет значения СпискаЗначений реквизитов формы, сохраняются только представления.
//
// Параметры:
//  стрИмяСписка - Строка - Имя реквизита списка значений.
//
&НаКлиенте
Процедура ВостановитьСписокЗначений(стрИмяСписка)
	
	Если стрИмяСписка = "Детализация" Тогда
		сзСравнения = СписокДетализация();
	ИначеЕсли стрИмяСписка = "ДетализацияДиаграммы" Тогда
		сзСравнения = СписокДетализацияДиаграммы();	
	ИначеЕсли стрИмяСписка = "ВариантДиаграммы" Тогда
		сзСравнения = СписокВариантДиаграммы();	
	Иначе 
		Возврат;
	КонецЕсли;
	
	сзТекущий = ЭтаФорма[стрИмяСписка].Скопировать();
	ЭтаФорма[стрИмяСписка] = Новый СписокЗначений; 
	
	Для каждого ЭлементТекущий Из сзТекущий Цикл
		Для Каждого ЭлементСравнения Из сзСравнения Цикл
			Если ЭлементТекущий.Представление = ЭлементСравнения.Представление Тогда
				ЭтаФорма[стрИмяСписка].Добавить(ЭлементСравнения.Значение, ЭлементСравнения.Представление);
				Прервать;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла; 

КонецПроцедуры

&НаКлиенте
Процедура КомандаДиаграмма(Команда)
	 
	Если Команда.Имя = "КнопкаТаблица" Тогда
		флДиаграмма = Ложь;	
	ИначеЕсли Команда.Имя = "КнопкаДиаграмма" Тогда
		флДиаграмма = Истина;		
	КонецЕсли;
	
	ОтображениеЭлементовФормы();
	
	СобытиеПриИзмененииНастроек(ЭтаФорма.Элементы.Результат); //vd_190618
	
КонецПроцедуры

&НаКлиенте
Процедура ОтображениеЭлементовФормы()
	//Видимость
	Элементы.ПланированиеПоСумме.Видимость 	= НЕ флДиаграмма;
	Элементы.ВариантДиаграммы.Видимость 	= флДиаграмма;
	Элементы.ДетализацияДиаграммы.Видимость = флДиаграмма;
	Элементы.Детализация.Доступность		= НЕ флДиаграмма;
	
	//Шрифты
	Если флДиаграмма Тогда
		Элементы.КнопкаТаблица.Шрифт   		= Новый Шрифт(Элементы.КнопкаТаблица.Шрифт  , , ,Ложь);
		Элементы.КнопкаДиаграмма.Шрифт 	 	= Новый Шрифт(Элементы.КнопкаДиаграмма.Шрифт, , ,Истина);
	Иначе
		Элементы.КнопкаТаблица.Шрифт   = Новый Шрифт(Элементы.КнопкаТаблица.Шрифт  , , ,Истина);
		Элементы.КнопкаДиаграмма.Шрифт = Новый Шрифт(Элементы.КнопкаДиаграмма.Шрифт, , ,Ложь);
	КонецЕсли;		
	
КонецПроцедуры

&НаКлиенте
Процедура Сформировать(Команда)

	ОбщегоНазначенияКлиентСервер.УстановитьСостояниеПоляТабличногоДокумента(ЭтаФорма.Элементы.Результат, "ФормированиеОтчета"); //vd_190618 Анимация формирования отчета
	
	//Проверка заполнения обязательных полей
	Если (флДиаграмма = Ложь И Детализация.Количество() = 0) ИЛИ (флДиаграмма = Истина И (ДетализацияДиаграммы.Количество() = 0 ИЛИ ВариантДиаграммы.Количество() = 0)) Тогда
		Оповещение =  Новый ОписаниеОповещения("ПослеЗакрытияВопросаПроверки", ЭтотОбъект);
		ТекстПредупреждения = ?(флДиаграмма, Элементы.ДетализацияДиаграммы.Заголовок + " "" или "" " + Элементы.ВариантДиаграммы.Заголовок ,Элементы.Детализация.Заголовок);
		ТекстПредупреждения = """" + ТекстПредупреждения + """";
		ТекстПредупреждения = "Не заполена настройка отчета: " + ТекстПредупреждения + ", заполнить настройку по умолчанию ?";
		ПоказатьВопрос(Оповещение, ТекстПредупреждения, РежимДиалогаВопрос.ДаНет,, КодВозвратаДиалога.Да, "Не заполнены обязательные поля настроек");
		Возврат;
	КонецЕсли;
		
	СформироватьНаСервере();
	
	ОбщегоНазначенияКлиентСервер.УстановитьСостояниеПоляТабличногоДокумента(ЭтаФорма.Элементы.Результат, "НеИспользовать"); //vd_190618 Анимация формирования отчета

КонецПроцедуры

&НаКлиенте
Процедура ПослеЗакрытияВопросаПроверки(Результат, Параметры) Экспорт
	
	Если Результат <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;
	
	Если флДиаграмма = Ложь Тогда
		Детализация	= ПолучитьОтмеченыеЗначенияСписка(СписокДетализация());
	Иначе
		ДетализацияДиаграммы	= ПолучитьОтмеченыеЗначенияСписка(СписокДетализацияДиаграммы());
		ВариантДиаграммы 		= ПолучитьОтмеченыеЗначенияСписка(СписокВариантДиаграммы());	
	КонецЕсли;
	
	СформироватьНаСервере();		
	
КОнецПроцедуры

&НаСервере
Процедура СформироватьНаСервере()

	Об = РеквизитФормыВЗначение("Объект");
	Схема = Об.ПолучитьМакет("СКДПланыПродажНоменклатура");
	Настройки = Схема.НастройкиПоУмолчанию;
	КомпоновщикНастроекДанных = Новый КомпоновщикНастроекКомпоновкиДанных;
	КомпоновщикНастроекДанных.Инициализировать(Новый ИсточникДоступныхНастроекКомпоновкиДанных(Схема));
	КомпоновщикНастроекДанных.ЗагрузитьНастройки(Схема.НастройкиПоУмолчанию);
	
	КомпоновщикНастроекДанных.Настройки.Структура.Очистить();
	
	НастройкиСКД = КомпоновщикНастроекДанных.Настройки;
	
	Если флДиаграмма = Ложь Тогда
	
		//++ ДЕТАЛИЗАЦИЯ Таблица
		ГрупировкаТекущая 	= НастройкиСКД;
		Для Каждого Элемент Из Детализация Цикл
			//ГРУППИРОВКА
			ГруппировкаНовая = ГрупировкаТекущая.Структура.Добавить(Тип("ГруппировкаКомпоновкиДанных"));
			ГруппировкаНовая.Имя = Элемент.Значение;
			ГруппировкаНовая.Использование = Истина;
			
			//СОРТРОВКА
			ПолеСортировки = ГруппировкаНовая.Порядок.Элементы.Добавить(Тип("ЭлементПорядкаКомпоновкиДанных"));
			ПолеСортировки.Поле = Новый ПолеКомпоновкиДанных(Элемент.Значение);
			ПолеСортировки.Использование = Истина;
			
			//ПОЛЕ ГРУППИРОВКИ
			ПолеГруппировки = ГруппировкаНовая.ПоляГруппировки.Элементы.Добавить(Тип("ПолеГруппировкиКомпоновкиДанных"));
			ПолеГруппировки.Использование = Истина;
			ПолеГруппировки.Поле = Новый ПолеКомпоновкиДанных(Элемент.Значение);
			ПолеГруппировки.ТипГруппировки	= ТипГруппировкиКомпоновкиДанных.Элементы;
			ПолеГруппировки.ТипДополнения   = ТипДополненияПериодаКомпоновкиДанных.БезДополнения;
			
			//ВЫБРАННЫЕ ПОЛЯ Признак использования выбраных полей. Если ложь или не задано, то поле текущей группировки (ПолеГруппировки) на форме пустое. Для того что бы система сама определила какие поля нужно выводить   
			ВыбранныеПоля = ГруппировкаНовая.Выбор.Элементы.Добавить(Тип("АвтоВыбранноеПолеКомпоновкиДанных"));
			ВыбранныеПоля.Использование = Истина;
		
			ГрупировкаТекущая = ГруппировкаНовая;
		КонецЦикла;
		
		//ВЫБРАННЫЕ ПОЛЯ
		//Колонка Запланирвано
		ВыбранныеПоля = НастройкиСКД.Выбор.Элементы.Добавить(Тип("ВыбранноеПолеКомпоновкиДанных"));
		ВыбранныеПоля.Использование = Истина;
		ВыбранныеПоля.Заголовок = "Запланированное количество";
		ВыбранныеПоля.Поле = Новый ПолеКомпоновкиДанных("ЗапланированноеКоличество");
		
		//Колонка ФактическиеПродажи
		ВыбранныеПоляГруппировка = НастройкиСКД.Выбор.Элементы.Добавить(Тип("ГруппаВыбранныхПолейКомпоновкиДанных"));
		ВыбранныеПоляГруппировка.Заголовок = "Фактические продажи"; 

		ВыбранныеПоля = ВыбранныеПоляГруппировка.Элементы.добавить(тип("ВыбранноеПолеКомпоновкиДанных"));
		ВыбранныеПоля.Использование = Истина;
		ВыбранныеПоля.Заголовок = "%";
		ВыбранныеПоля.Поле = Новый ПолеКомпоновкиДанных("ВыполнениеФактическиеПродажи");
		
		ВыбранныеПоля = ВыбранныеПоляГруппировка.Элементы.добавить(тип("ВыбранноеПолеКомпоновкиДанных"));
		ВыбранныеПоля.Использование = Истина;
		ВыбранныеПоля.Заголовок = "Кол-во";
		ВыбранныеПоля.Поле = Новый ПолеКомпоновкиДанных("ФактПоПродажам");
		
		//Колонка Продажи по документам агента
		ВыбранныеПоляГруппировка = НастройкиСКД.Выбор.Элементы.Добавить(Тип("ГруппаВыбранныхПолейКомпоновкиДанных"));
		ВыбранныеПоляГруппировка.Заголовок = "Продажи по документам агента"; 

		ВыбранныеПоля = ВыбранныеПоляГруппировка.Элементы.добавить(тип("ВыбранноеПолеКомпоновкиДанных"));
		ВыбранныеПоля.Использование = Истина;
		ВыбранныеПоля.Заголовок = "%";
		ВыбранныеПоля.Поле = Новый ПолеКомпоновкиДанных("ВыполнениеПоДокументамПродажи");
		
		ВыбранныеПоля = ВыбранныеПоляГруппировка.Элементы.добавить(тип("ВыбранноеПолеКомпоновкиДанных"));
		ВыбранныеПоля.Использование = Истина;
		ВыбранныеПоля.Заголовок = "Кол-во";
		ВыбранныеПоля.Поле = Новый ПолеКомпоновкиДанных("ФактПоДокументамИзМУ");
		
		//Колонка планирование по сумме
		Если ПланированиеПоСумме Тогда
			ВыбранныеПоляГруппировка1 = НастройкиСКД.Выбор.Элементы.Добавить(Тип("ГруппаВыбранныхПолейКомпоновкиДанных"));
			ВыбранныеПоляГруппировка1.Заголовок = "Планирование по сумме";
			
			//Колонка Запланирвано
			ВыбранныеПоля = ВыбранныеПоляГруппировка1.Элементы.Добавить(Тип("ВыбранноеПолеКомпоновкиДанных"));
			ВыбранныеПоля.Использование = Истина;
			ВыбранныеПоля.Заголовок = "Запланированная сумма";
			ВыбранныеПоля.Поле = Новый ПолеКомпоновкиДанных("ЗапланированнаяСумма");

			//Колонка Фактические продаж
			ВыбранныеПоляГруппировка = ВыбранныеПоляГруппировка1.Элементы.Добавить(Тип("ГруппаВыбранныхПолейКомпоновкиДанных"));
			ВыбранныеПоляГруппировка.Заголовок = "Фактические продажи";
			
			ВыбранныеПоля = ВыбранныеПоляГруппировка.Элементы.Добавить(тип("ВыбранноеПолеКомпоновкиДанных"));
			ВыбранныеПоля.Использование = Истина;
			ВыбранныеПоля.Заголовок = "%";
			ВыбранныеПоля.Поле = Новый ПолеКомпоновкиДанных("ВыполнениеСуммаФактическиеПродажи");
			
			ВыбранныеПоля = ВыбранныеПоляГруппировка.Элементы.Добавить(тип("ВыбранноеПолеКомпоновкиДанных"));
			ВыбранныеПоля.Использование = Истина;
			ВыбранныеПоля.Заголовок = "Сумма";
			ВыбранныеПоля.Поле = Новый ПолеКомпоновкиДанных("СуммаФактПоПродажам");
			
			//Колонка Фактических продажи в валюте рег. учета
			ВыбранныеПоляГруппировка = ВыбранныеПоляГруппировка1.Элементы.Добавить(Тип("ГруппаВыбранныхПолейКомпоновкиДанных"));
			ВыбранныеПоляГруппировка.Заголовок = "Фактических продажи в валюте рег. учета";
			
			ВыбранныеПоля = ВыбранныеПоляГруппировка.Элементы.Добавить(тип("ВыбранноеПолеКомпоновкиДанных"));
			ВыбранныеПоля.Использование = Истина;
			ВыбранныеПоля.Заголовок = "%";
			ВыбранныеПоля.Поле = Новый ПолеКомпоновкиДанных("ВыполнениеСуммаФактическиеПродажиРегУчета");
			
			ВыбранныеПоля = ВыбранныеПоляГруппировка.Элементы.Добавить(тип("ВыбранноеПолеКомпоновкиДанных"));
			ВыбранныеПоля.Использование = Истина;
			ВыбранныеПоля.Заголовок = "Сумма";
			ВыбранныеПоля.Поле = Новый ПолеКомпоновкиДанных("СуммаФактПоПродажамВалютпРегУчета");
		КонецЕсли;
		
		//-- ДЕТАЛИЗАЦИЯ Таблица
		
	Иначе
		
		//++ ДЕТАЛИЗАЦИЯ Диаграмма
		
		флСерии = ?(ВариантДиаграммы.Количество() = 1, Истина, Ложь);
		
		// Добавим в отчет диаграмму.
		Диаграмма = НастройкиСКД.Структура.Добавить(Тип("ДиаграммаКомпоновкиДанных"));
		
		// Установим заголовок диаграммы
		ПараметрВывода = Диаграмма.ПараметрыВывода.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("Заголовок"));
		ПараметрВывода.Значение = "Диаграмма"; //?(флСерии, ВариантДиаграммы[0].Представление, "");
		ПараметрВывода.Использование = Истина;
		 
		// Укажем, какой ресурс нужно выводить в диаграмме
    	Для Каждого Элемент Из ВариантДиаграммы Цикл
   			ВыбранноеПоле = Диаграмма.Выбор.Элементы.Добавить(Тип("ВыбранноеПолеКомпоновкиДанных"));
    	 	ВыбранноеПоле.Поле = Новый ПолеКомпоновкиДанных(Элемент.Значение);
    	 	ВыбранноеПоле.Заголовок = Элемент.Представление;
    	КонецЦикла;
 
		 
		// Добавим в диаграмму Точки.
		ГрупировкаТекущая = Неопределено;
		Для Каждого Элемент Из ДетализацияДиаграммы Цикл
			//Добавим точку
			Если ГрупировкаТекущая = Неопределено Тогда
				ГрупировкаТекущая = ?(флСерии, Диаграмма.Серии.Добавить(), Диаграмма.Точки.Добавить());
			Иначе
				ГрупировкаТекущая = ГрупировкаТекущая.Структура.Добавить();
			КонецЕсли;
			
			// Укажем, что система сама должна определять, какие поля нужно выводить в точку.
			ГрупировкаТекущая.Выбор.Элементы.Добавить(Тип("АвтоВыбранноеПолеКомпоновкиДанных"));
			
			// Укажем каким образом нужно упорядочивать данные точки
			ЭлементПорядка = ГрупировкаТекущая.Порядок.Элементы.Добавить(Тип("ЭлементПорядкаКомпоновкиДанных"));
	 		ЭлементПорядка.Поле = Новый ПолеКомпоновкиДанных(Элемент.Значение);	
			
			// Укажем, по какому полю нужно группировать в точке.
			ПолеГруппировки = ГрупировкаТекущая.ПоляГруппировки.Элементы.Добавить(Тип("ПолеГруппировкиКомпоновкиДанных"));
			ПолеГруппировки.Поле = Новый ПолеКомпоновкиДанных(Элемент.Значение); 				
		КонецЦикла; 
		
		//-- ДЕТАЛИЗАЦИЯ Диаграмма
		
	КонецЕсли;
	
	//ПАРАМЕТРЫ
	Если ДатаНачало <> '00010101' Тогда
		Параметр = КомпоновщикНастроекДанных.Настройки.ПараметрыДанных.Элементы.Найти("ПараметрДатаНачало");
		Параметр.Использование = Истина;
		Параметр.Значение = ДатаНачало;
	КонецЕсли;
	Если ДатаКонец <> '00010101' Тогда
		Параметр = КомпоновщикНастроекДанных.Настройки.ПараметрыДанных.Элементы.Найти("ПараметрДатаКонец");
		Параметр.Использование = Истина;
		Параметр.Значение = ДатаКонец;
	КонецЕсли;
	Если Агент.Количество() > 0 Тогда
		Параметр = КомпоновщикНастроекДанных.Настройки.ПараметрыДанных.Элементы.Найти("ПараметрАгент");
		Параметр.Использование = Истина;
		Параметр.Значение = Агент;
	КонецЕсли;
	Если ПланПродаж.Количество() > 0 Тогда
		Параметр = КомпоновщикНастроекДанных.Настройки.ПараметрыДанных.Элементы.Найти("ПараметрПланПродаж");
		Параметр.Использование = Истина;
		Параметр.Значение = ПланПродаж;
	КонецЕсли;
	
	//ФОРМИРОВАНИЕ данных
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	//МакетОформления = Н ПолучитьМакет("Основной");
	Макет = КомпоновщикМакета.Выполнить(Схема, КомпоновщикНастроекДанных.ПолучитьНастройки(),,);
	ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновки.Инициализировать(Макет);
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;

	Результат.Очистить();
	ПроцессорВывода.УстановитьДокумент(Результат);
	ПроцессорВывода.Вывести(ПроцессорКомпоновки);
	
	//СВЕРНУТЬ группировки
	Результат.ПоказатьУровеньГруппировокСтрок(0);

КонецПроцедуры

&НаКлиенте
Процедура СписокЗначенийНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	//Получаем весь список с отмеченными полями по умолчанию
	Если Элемент.Имя = "Детализация" ИЛИ Элемент.Имя = "ДетализацияДиаграммы" Тогда
		сзСписок = СписокДетализация();
	ИначеЕсли Элемент.Имя = "ВариантДиаграммы" Тогда    
		сзСписок = СписокВариантДиаграммы();	
	Иначе
		Возврат;	
	КонецЕсли;

	//Очечаем элементы списка в соответствии с уже отмеченными элементами на форме 
	Для Каждого ЭлементСписка Из сзСписок Цикл
		Если ЭтаФорма[Элемент.Имя].НайтиПоЗначению(ЭлементСписка.Значение) <> Неопределено Тогда
			ЭлементСписка.Пометка = Истина;
		Иначе
			ЭлементСписка.Пометка = Ложь;
		КонецЕсли;		
	КонецЦикла; 
			
	ОповещениеПослеОтметкиЭлементов = Новый ОписаниеОповещения("СписокЗначенийПослеОтметкиЭлементов", ЭтотОбъект, Элемент.Имя);	
	сзСписок.ПоказатьОтметкуЭлементов(ОповещениеПослеОтметкиЭлементов, "Детализация");
	
КонецПроцедуры

&НаКлиенте
Процедура СписокЗначенийПослеОтметкиЭлементов(Список, ИмяЭлемента) Экспорт
	Если Список = Неопределено Тогда
		Возврат;
	КонецЕсли;  
	ЭтаФорма[ИмяЭлемента] = ПолучитьОтмеченыеЗначенияСписка(Список);
	
КОнецПроцедуры

&НаКлиенте
Функция ПолучитьОтмеченыеЗначенияСписка(Список)
	сзСписок = Новый СписокЗначений;	
	Для Каждого Элемент Из Список Цикл
		Если Элемент.Пометка Тогда
			сзСписок.Добавить(Элемент.Значение, Элемент.Представление);
		КонецЕсли;
	КонецЦикла;
	Возврат сзСписок;
КОнецФункции

&НаКлиенте
Функция СписокДетализация()
	сзСписок = Новый СписокЗначений;
	сзСписок.Добавить("Агент",				"Агент", 						Истина);
	сзСписок.Добавить("ПланПродаж",			"План продаж", 					Истина);
	сзСписок.Добавить("ПланПродажПериод", 	"План продаж по периодам", 		Ложь);
	сзСписок.Добавить("Номенклатура", 		"Номенклатура", 				Истина);
	//сзСписок.Добавить("Партнер", 			"Партнер из плана продаж", 		Ложь); //Редко используется
	
	Возврат сзСписок;
КонецФункции

&НаКлиенте
Функция СписокДетализацияДиаграммы()
	сзСписок = Новый СписокЗначений;
	Для Каждого Элемент Из СписокДетализация() Цикл
		сзСписок.Добавить(Элемент.Значение, Элемент.Представление, ?(Элемент.Значение = "Агент", Истина, Ложь));
	КонецЦикла;
		
	Возврат сзСписок;
КонецФункции

&НаКлиенте
Функция СписокВариантДиаграммы()
	сзСписок = Новый СписокЗначений;
	сзСписок.Добавить("ВыполнениеФактическиеПродажи", "Выполнение по фактическим продажам, %",					Истина);
	сзСписок.Добавить("ВыполнениеПоДокументамПродажи", "Выполнение по документам продажи агента, %",			Ложь);
	сзСписок.Добавить("ВыполнениеСуммаФактическиеПродажиРегУчета", "Выполнение по сумме в валюте рег. учета, %",Ложь);
	сзСписок.Добавить("ЗапланированноеКоличество", "Количество запланированное", 								Ложь);
	сзСписок.Добавить("ФактПоПродажам", "Количество по фактическим продажам", 									Ложь);
	сзСписок.Добавить("ФактПоДокументамИзМУ", "Количество по документам продажи агента", 						Ложь);
	сзСписок.Добавить("ЗапланированнаяСумма", "Сумма запланированная", 											Ложь);
	сзСписок.Добавить("СуммаФактПоПродажам", "Сумма без учета валюты", 											Ложь);
	сзСписок.Добавить("СуммаФактПоПродажамВалютпРегУчета", "Сумма в валюте рег. учета", 						Ложь);
	
	Возврат сзСписок;
КонецФункции

&НаКлиенте
Процедура РезультатВыбор(Элемент, Область, СтандартнаяОбработка)
	// Вставить содержимое обработчика.
	а = 0;
КонецПроцедуры

&НаКлиенте
//vd_190618 Добавлена
Процедура СобытиеПриИзмененииНастроек(Элемент)
	ОбщегоНазначенияКлиентСервер.УстановитьСостояниеПоляТабличногоДокумента(ЭтаФорма.Элементы.Результат, "НеАктуальность");	
КонецПроцедуры













 
 

