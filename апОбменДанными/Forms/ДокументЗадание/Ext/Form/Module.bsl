﻿
#Область ГлобальныеПеременные

&НаКлиенте
Перем МодульМТ;  // Общий клиентский модуль со спецификой мобильной торговли

&НаКлиенте
Перем гМодульК;  // общий клиентский модуль. 

&НаКлиенте
Перем КэшированныеЗначения; //используется механизмом обработки изменения реквизитов ТЧ

// ГлобальныеПеременные
#КонецОбласти


#Область СовместимостьСПлатформой_8_3_5

// Подставляет параметры в строку. Максимально возможное число параметров - 5.
// Параметры в строке задаются как %<номер параметра>. Нумерация параметров начинается с единицы.
//
// Параметры:
//  СтрокаПодстановки  - Строка - шаблон строки с параметрами (вхождениями вида "%ИмяПараметра");
//  Параметр<n>        - Строка - подставляемый параметр.
//
// Возвращаемое значение:
//  Строка   - текстовая строка с подставленными параметрами.
//
&НаКлиентеНаСервереБезКонтекста
Функция СтрШаблон_(СтрокаПодстановки,
	Параметр1, Параметр2 = Неопределено, Параметр3 = Неопределено, Параметр4 = Неопределено, Параметр5 = Неопределено)
	
	Результат = СтрЗаменить(СтрокаПодстановки, "%1", Параметр1);
	Результат = СтрЗаменить(Результат, "%2", Параметр2);
	Результат = СтрЗаменить(Результат, "%3", Параметр3);
	Результат = СтрЗаменить(Результат, "%4", Параметр4);
	Результат = СтрЗаменить(Результат, "%5", Параметр5);
	
	Возврат Результат;
	
КонецФункции

// СовместимостьСПлатформой_8_3_5
#КонецОбласти


#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ТекОбъект = РеквизитФормыВЗначение("Объект");			
	
	ТекОбъект.КонтекстФормыИнициализировать(СтррКонтекст, Параметры, "ID");	
	ТекОбъект.ВОКонтекстФормыДополнить(СтррКонтекст, "_Задание", Ложь);
		
	ТипЗадачиСписок = ТекОбъект.ТипыЗадач(); //Заполнить типы задач
	ЗаполнитьВидЗадачиСписок(ТекОбъект);     //Заполнить виды задач
	
	ПрочестьОбъектИзХранилища(Параметры.ID);
	
	ТекОбъект.ВОПриСозданииФормыЭлемента(ЭтотОбъект);  
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	// Загружаем общий клиентский модуль "МодульОбщийМТ". В параметре "Параметры" важно передавать структуру с заполненным
	// свойством "ВХОбщиеПараметры" - оно используется для предотвращения повторной загрузки текущей обработки.
	МодульМТ = ПолучитьФорму(СтррКонтекст.ПутьКФорме + "МодульОбщийМТ", СтррКонтекст, ЭтаФорма, "АгентПлюсМодульОбщийМТ"); // в СтррКонтекст есть заполненное свойство "ВХОбщиеПараметры"
	МодульМТ.ВОПриОткрытии(ЭтотОбъект);
	
	ЗаполнитьСписокВыбораВидовЗадач();
	
	ФормаОбновитьВидимостьЭлементов();
	
	СозданВЦБД = Истина;
	Элементы.СозданВЦБД.Доступность = Ложь;
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Если ЭтаФорма.Модифицированность Тогда
		Отказ = Истина;
		Оповещение = Новый ОписаниеОповещения("СохранитьПродолжить", ЭтотОбъект);
		ПоказатьВопрос(Оповещение, НСтр("ru = 'Данные были изменены. Сохранить изменения?'"), РежимДиалогаВопрос.ДаНетОтмена);
	КонецЕсли;
	
КонецПроцедуры

// ОбработчикиСобытийФормы
#КонецОбласти


#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура КомандаВыполнить(Команда)
	
	//(av_270818
	Если Команда.Имя = "ПрикрепленныеФотографии" Тогда
		Если Модифицированность	Или Не ЗначениеЗаполнено(ID) Тогда
			Сообщить("Документ нужно записать перед выполнением команды");
			Возврат;
		КонецЕсли;
	КонецЕсли;
	//)av_270818
		
	МодульМТ.КомандаВыполнить(Команда, ЭтотОбъект)
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаСохранить(Команда)
	
	Если НЕ ПроверитьЗаполнениеПолей() Тогда //0 сохранен, 1 проведен
		Возврат;
	КонецЕсли;
	
	СохранитьОбъектВХранилищеКлиент();
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаПровестиИЗакрыть(Команда)
	
	Если НЕ ПроверитьЗаполнениеПолей() Тогда
		Возврат;
	КонецЕсли;
	
	СохранитьОбъектВХранилищеКлиент(1); // признак Проведен
	Закрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаПровести(Команда)
	
	Если НЕ ПроверитьЗаполнениеПолей() Тогда
		Возврат;
	КонецЕсли;
	
	СохранитьОбъектВХранилищеКлиент(1); // признак Проведен
	
КонецПроцедуры

// ОбработчикиКомандФормы
#КонецОбласти


#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура ЗадачиПриИзменении(Элемент)
	УстановитьМодифицированостьФормы();
КонецПроцедуры

&НаКлиенте
Процедура ЗадачиВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	Если Поле.Имя = "ЗадачиРезультатПредставление" И ЗначениеЗаполнено(Элемент.ТекущиеДанные.Результат) Тогда
		
		СтандартнаяОбработка = Ложь;
		
		Если НЕ ЗначениеЗаполнено(Элемент.ТекущиеДанные.Результат) Тогда
			Возврат;
		КонецЕсли;
		
		типРезультат = ТипЗнч(Элемент.ТекущиеДанные.Результат);
		
		//ЭтоДокумент = Документы.ТипВсеСсылки().СодержитТип(типРезультат);

		Если типРезультат = Тип("Строка") ИЛИ типРезультат = Тип("Число") ИЛИ типРезультат = Тип("Булево") ИЛИ типРезультат = Тип("Булево") Тогда	
			Оповещение = Новый ОписаниеОповещения("ЗадачиВыборПослеЗакрытияОповещения", ЭтотОбъект); 
			ПоказатьПредупреждение(Оповещение, Элемент.ТекущиеДанные.РезультатПредставление,0 , "Результат");
			
		ИначеЕсли типРезультат = Тип("УникальныйИдентификатор") Тогда
			
			ПоискТипЗадачи = ВидыЗадач.НайтиСтроки(Новый Структура("ID", Элемент.ТекущиеДанные.ВидЗадачи));
			Если ПоискТипЗадачи.Количество() > 0 Тогда
				ИдТипЗадачи = ПоискТипЗадачи[0].ТипЗадачи;
			Иначе
				ИдТипЗадачи = Неопределено;
			КонецЕсли;
			
			Если ИдТипЗадачи = Новый УникальныйИдентификатор("544B81FD-49DA-453E-9B9C-EEC549CBEF10") Тогда
				//Мерчендайзинг
				МодульК().ВООткрытьФорму("_Мерчендайзинг", Элемент.ТекущиеДанные.Результат);
				
			ИначеЕсли ИдТипЗадачи = Новый УникальныйИдентификатор("2F7826F4-2665-49FA-95E7-E7C8CC6EBF0E") Тогда
				//Посещение			
				МодульК().ВООткрытьФорму("_Посещение", Элемент.ТекущиеДанные.Результат);
			
			ИначеЕсли ИдТипЗадачи = Новый УникальныйИдентификатор("B483E5F9-95E6-4E2D-B6B2-D5954FCC25AE") Тогда 
				//Фото
				Оповещение = Новый ОписаниеОповещения("ЗадачиВыборПослеЗакрытияОповещения", ЭтотОбъект); 
				ПоказатьПредупреждение(Оповещение, "В разработке."); //Этой ситуации не должно быть, фото не реализовано.
				
			Иначе
				Оповещение = Новый ОписаниеОповещения("ЗадачиВыборПослеЗакрытияОповещения", ЭтотОбъект); 
				ПоказатьПредупреждение(Оповещение, "Неизвестный тип документа.");
				
			КонецЕсли;
			
		ИначеЕсли типРезультат = Тип("ДокументСсылка.ЗаказКлиента") Тогда
			ОткрытьФормуПоСсылке("ЗаказКлиента", Элемент.ТекущиеДанные.Результат)
			
		ИначеЕсли типРезультат = Тип("ДокументСсылка.РеализацияТоваровУслуг") Тогда
			ОткрытьФормуПоСсылке("РеализацияТоваровУслуг", Элемент.ТекущиеДанные.Результат)

		ИначеЕсли типРезультат = Тип("ДокументСсылка.ПеремещениеТоваров") Тогда
			ОткрытьФормуПоСсылке("ПеремещениеТоваров", Элемент.ТекущиеДанные.Результат)

		ИначеЕсли типРезультат = Тип("ДокументСсылка.ПоступлениеТоваров") Тогда
			ОткрытьФормуПоСсылке("ПоступлениеТоваров", Элемент.ТекущиеДанные.Результат)

		ИначеЕсли типРезультат = Тип("ДокументСсылка.ВозвратТоваровОтКлиента") Тогда
			ОткрытьФормуПоСсылке("ВозвратТоваровОтКлиента", Элемент.ТекущиеДанные.Результат)

		ИначеЕсли типРезультат = Тип("ДокументСсылка.ПриходныйКассовыйОрдер") Тогда
			ОткрытьФормуПоСсылке("ПриходныйКассовыйОрдер", Элемент.ТекущиеДанные.Результат)

		ИначеЕсли типРезультат = Тип("ДокументСсылка.РасходныйКассовыйОрдер") Тогда
			ОткрытьФормуПоСсылке("РасходныйКассовыйОрдер", Элемент.ТекущиеДанные.Результат)

		ИначеЕсли типРезультат = Тип("ДокументСсылка.ЗаказКлиента") Тогда
			ОткрытьФормуПоСсылке("ЗаказКлиента", Элемент.ТекущиеДанные.Результат)
			
		ИначеЕсли типРезультат = Тип("ДокументСсылка.ЗаказКлиента") Тогда
			ОткрытьФормуПоСсылке("ЗаказКлиента", Элемент.ТекущиеДанные.Результат)
			
		ИначеЕсли типРезультат = Тип("ДокументСсылка.ЗаказКлиента") Тогда
			ОткрытьФормуПоСсылке("ЗаказКлиента", Элемент.ТекущиеДанные.Результат)
			
		Иначе
			//Нет действий
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗадачиВыборПослеЗакрытияОповещения(Параметры) Экспорт
	//Процедура для немодального выода результата, без обработки.
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьФормуПоСсылке(стрДокумент, ДокументСсылка)
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("Ключ", ДокументСсылка);
	ОткрытьФорму("Документ." + стрДокумент + ".Форма.ФормаДокумента", ПараметрыФормы);
Конецпроцедуры

&НаКлиенте
Процедура ЗадачиПередНачаломИзменения(Элемент, Отказ)
	
	Если Элемент.ТекущийЭлемент.Имя = "ЗадачиВидЗадачиПредставление" И (ЗначениеЗаполнено(Элемент.ТекущиеДанные.Результат) ИЛИ НЕ ПустаяСтрока(Элемент.ТекущиеДанные.РезультатПредставление)) Тогда 
		ТекстОшибки = НСтр("ru = 'Поле результат заполнено, редактирование поля не доступно.'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки,,);
		Отказ = Истина;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ЗадачиПриОкончанииРедактирования(Элемент, НоваяСтрока, ОтменаРедактирования)
	
	Если Элемент.ТекущийЭлемент.Имя = "ЗадачиВидЗадачиПредставление" Тогда
		Если ЗначениеЗаполнено(Элемент.ТекущиеДанные.ВидЗадачиПредставление) Тогда
			идВидЗадачи = Новый УникальныйИдентификатор(Элемент.ТекущиеДанные.ВидЗадачиПредставление);
			Элементы.Задачи.ТекущиеДанные.ВидЗадачи 	= идВидЗадачи;
			Элемент.ТекущиеДанные.ВидЗадачиПредставление = ПолучитьПредставление(Новый УникальныйИдентификатор(Элемент.ТекущиеДанные.ВидЗадачиПредставление));
		Иначе
			Элемент.ТекущиеДанные.ВидЗадачи				 = Новый УникальныйИдентификатор("00000000-0000-0000-0000-000000000000");
			Элемент.ТекущиеДанные.ВидЗадачиПредставление = "";
		КонецЕсли;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Элемент.ТекущиеДанные.GUID) Тогда
		Элемент.ТекущиеДанные.GUID = Новый УникальныйИдентификатор();		
	КонецЕсли;
		
КонецПроцедуры      

&НаКлиенте
Процедура ЗадачиПриАктивизацииПоля(Элемент)
	
	Если НЕ Элемент.ТекущийЭлемент.Имя = "ЗадачиВидЗадачиПредставление" Тогда	
		Если ЗначениеЗаполнено(Элемент.ТекущиеДанные.ВидЗадачиПредставление) Тогда
			Если Элемент.ТекущиеДанные.ВидЗадачиПредставление = Строка(Элемент.ТекущиеДанные.ВидЗадачи) Тогда
				идВидЗадачи = Новый УникальныйИдентификатор(Элемент.ТекущиеДанные.ВидЗадачиПредставление);
				Элементы.Задачи.ТекущиеДанные.ВидЗадачи 	= идВидЗадачи;
				Элемент.ТекущиеДанные.ВидЗадачиПредставление = ПолучитьПредставление(Новый УникальныйИдентификатор(Элемент.ТекущиеДанные.ВидЗадачиПредставление));
			КонецЕсли;			
		Иначе
			Элемент.ТекущиеДанные.ВидЗадачи				 = Новый УникальныйИдентификатор("00000000-0000-0000-0000-000000000000");
			Элемент.ТекущиеДанные.ВидЗадачиПредставление = "";
		КонецЕсли;		    		
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ЗадачиВидЗадачиПредставлениеНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Элементы.Задачи.ТекущиеДанные.ВидЗадачиПредставление = Строка(Элементы.Задачи.ТекущиеДанные.ВидЗадачи);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗадачиВидЗадачиПредставлениеОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
		Если ЗначениеЗаполнено(ВыбранноеЗначение) Тогда
			идВидЗадачи = Новый УникальныйИдентификатор(ВыбранноеЗначение);
			Элементы.Задачи.ТекущиеДанные.ВидЗадачи 	= идВидЗадачи;
			Элементы.Задачи.ТекущиеДанные.ВидЗадачиПредставление = ПолучитьПредставление(идВидЗадачи);
		Иначе
			Элементы.Задачи.ТекущиеДанные.ВидЗадачи				 = Новый УникальныйИдентификатор("00000000-0000-0000-0000-000000000000");
			Элементы.Задачи.ТекущиеДанные.ВидЗадачиПредставление = "";
		КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПартнерПриИзменении(Элемент)
	
	МодульМТ.ПартнерПриИзменении(ЭтотОбъект, Элемент);
	
КонецПроцедуры

&НаКлиенте
Процедура КонтрагентПриИзменении(Элемент)
	
	МодульМТ.КонтрагентПриИзменении(ЭтотОбъект, Элемент);	
	
КонецПроцедуры

&НаКлиенте
Процедура ДатаПриИзменении(Элемент)
	
	УстановитьМодифицированостьФормы();
	
КонецПроцедуры

&НаКлиенте
Процедура КонтрагентНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	Оповещение = Новый ОписаниеОповещения("КонтрагентНачалоВыбораЗавершение", ЭтотОбъект);
	стррПараметры = ?(ЗначениеЗаполнено(Партнер), Новый Структура("Отбор", Новый Структура("Партнер", Партнер)), Неопределено);
	ОткрытьФорму("Справочник.Контрагенты.ФормаВыбора", стррПараметры,,,,, Оповещение, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	
КонецПроцедуры

&НаКлиенте
Процедура КонтрагентНачалоВыбораЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	МодульМТ.КонтрагентНачалоВыбораЗавершение(ЭтотОбъект, Результат, ДополнительныеПараметры);

КонецПроцедуры

&НаКлиенте
Процедура ОрганизацияПриИзменении(Элемент)
	
	МодульМТ.ОрганизацияПриИзменении(ЭтотОбъект, Элемент);
	
КонецПроцедуры

&НаКлиенте
Процедура ДоговорПриИзменении(Элемент)
	
	МодульМТ.ДоговорПриИзменении(ЭтотОбъект, Элемент);
	
КонецПроцедуры

&НаКлиенте
Процедура СоглашениеПриИзменении(Элемент)
	
	МодульМТ.СоглашениеПриИзменении(ЭтотОбъект, Элемент);
	
КонецПроцедуры

&НаКлиенте
Процедура СоглашениеНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)

	СтандартнаяОбработка = Ложь;
	
	Если Не ЗначениеЗаполнено(Партнер) Тогда
		ПоказатьПредупреждение(Неопределено, НСтр("ru = 'Сначала выберите клиента.'"));
		Возврат;
	КонецЕсли;
	
	Если МодульМТ.ПоколениеКонфигурации("<=УТ_11.1") Тогда
		
		ПродажиКлиент.НачалоВыбораСоглашенияСКлиентом(Элемент, СтандартнаяОбработка, Партнер, Соглашение, Дата);
		
	ИначеЕсли МодульМТ.ПоколениеКонфигурации("<=УТ_11.2") Тогда
		
		ПродажиКлиент.НачалоВыбораСоглашенияСКлиентом(Элемент, СтандартнаяОбработка, Партнер, Соглашение, Дата,,,,Объект);
	
	Иначе
		
		стррПараметры = ПродажиКлиент.ПараметрыНачалаВыбораСоглашенияСКлиентом();
		
		стррПараметры.Элемент                     = Элемент;
		стррПараметры.Партнер                     = Партнер;
		стррПараметры.Документ                    = Соглашение;
		стррПараметры.ДатаДокумента               = Дата;
		стррПараметры.ДанныеФормыСтруктура        = Объект;
		
		ПродажиКлиент.НачалоВыбораСоглашенияСКлиентом(стррПараметры, СтандартнаяОбработка);
		
	КонецЕсли; 
	
КонецПроцедуры

&НаКлиенте
Процедура ЭлементФормыПриИзменении(Элемент)
	
	УстановитьМодифицированостьФормы();
	
КонецПроцедуры

&НаКлиенте
Процедура ИнфоМТВремяСозданияНажатие(Элемент, СтандартнаяОбработка)
	
	МодульМТ.РеквизитМТПриНажатииСсылки(ЭтотОбъект, Элемент, СтандартнаяОбработка);
	
КонецПроцедуры

&НаКлиенте
Процедура ЭлементМТСведенияНажатие(Элемент)
	
	стррРезультат = МодульМТ.РеквизитМТПриНажатииСсылки(ЭтотОбъект, Элемент);
	Если ТипЗнч(стррРезультат) = Тип("Структура") Тогда // нужно показать выбор из меню
	  	ПоказатьВыборИзМеню(стррРезультат.Оповещение, стррРезультат.Меню, Элемент);
	КонецЕсли; 
	
КонецПроцедуры

&НаКлиенте
Процедура НеИзменятьВМУПриИзменении(Элемент)
	УстановитьМодифицированостьФормы();
КонецПроцедуры


// ОбработчикиСобытийЭлементовФормы
#КонецОбласти


#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ЗаполнитьСписокВыбораВидовЗадач()
	
	Для Каждого Элемент Из ВидыЗадач Цикл
		Элементы.ЗадачиВидЗадачиПредставление.СписокВыбора.Добавить(Строка(Элемент.ID), Элемент.Наименование);
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Функция ПолучитьПредставление(идВидаЗадания)
	
	стррПоиск = Новый Структура("ID", идВидаЗадания);
	Результат = ВидыЗадач.НайтиСтроки(стррПоиск);
	
	Если Результат.Количество() = 0 Тогда
		Возврат "";
	Иначе
		Возврат Результат[0].Наименование; 
	КонецЕсли;
	
КонецФункции

&НаКлиенте
Функция ПроверитьЗаполнениеПолей()
	
	ОчиститьСообщения();
	
	Результат = Истина;
	
	Если НЕ ЗначениеЗаполнено(Номер) Тогда 
		Результат = Ложь;
		ТекстОшибки = НСтр("ru = 'Не заполнено поле ""Номер"".'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки,, "Номер");
	КонецЕсли;

	Если НЕ ЗначениеЗаполнено(Дата) Тогда 
		Результат = Ложь;
		ТекстОшибки = НСтр("ru = 'Не заполнено поле ""Дата"".'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки,, "Дата");
	КонецЕсли;
	
	
	Если НЕ ЗначениеЗаполнено(Организация) Тогда 
		Результат = Ложь;
		ТекстОшибки = НСтр("ru = 'Не заполнено поле ""Организация"".'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки,, "Организация");
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Партнер) Тогда 
		Результат = Ложь;
		ТекстОшибки = НСтр("ru = 'Не заполнено поле ""Клиент"".'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки,, "Партнер");
	КонецЕсли;
	
	Если ЭтаФорма.Задачи.Количество() = 0 Тогда 
		Результат = Ложь;
		ТекстОшибки = НСтр("ru = 'У документа не заполнены ""Задачи"".'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки,, "Задачи");
	КонецЕсли;
		
	Возврат Результат;

КонецФункции


#Область СлужебныеПроцедурыИФункции_Хранилище

&НаСервере
Процедура ЗаполнитьВидЗадачиСписок(ТекОбъект) 
	стррВидыЗадач = Новый Структура; // общие значения модуля формы
	ТекОбъект.ВОКонтекстФормыДополнить(стррВидыЗадач, "_ВидыЗадач", Истина);
	тзВидыЗадач = ТекОбъект.ВОТЗЗагрузить(стррВидыЗадач.ВО);
	Для каждого стзЭлемент Из тзВидыЗадач Цикл
		стзНовая = ВидыЗадач.Добавить();		
		ЗаполнитьЗначенияСвойств(стзНовая, стзЭлемент);	
	КонецЦикла;     	
конецпроцедуры

// Процедура считывает объект (документ) из хранилища значений.
&НаСервере
Процедура ПрочестьОбъектИзХранилища(КлючID) 
	
	ТекОбъект = РеквизитФормыВЗначение("Объект");
	
	ID = КлючID;
	стррОбъект = ТекОбъект.ВОЭлементЗагрузить(СтррКонтекст.ВО, ID);
	
	Если стррОбъект = Неопределено Тогда 
		// создание нового документа, заполняем документ значениями по умолчанию
	Иначе
		ТекОбъект.ЗаполнитьРеквизитыОбъектаИзСтруктуры(ЭтотОбъект, стррОбъект);
	КонецЕсли; 
	
КонецПроцедуры

&НаКлиенте
Функция СохранитьОбъектВХранилищеКлиент(НовыйСтатус = Неопределено)
	
	МодульМТ.ВОПередЗаписьюЭлемента(ЭтотОбъект, НовыйСтатус);
	
	СохранитьОбъектВХранилище();
	УстановитьМодифицированостьФормы(Ложь);
	Оповестить("АПДокументЗаписан_" + СтррКонтекст.ВО.ВидОбъекта, ID);
	
	Возврат Истина;
	
КонецФункции

// Процедура сохраняет объект (документ) в хранилище значений.
&НаСервере
Процедура СохранитьОбъектВХранилище()
	
	стрРеквизитыШапкиОсн = "Статус,Дата,Номер,ВремяНачала,ВремяОкончания,Широта,Долгота,АдресПоГеокодеру,Менеджер,Комментарий";
	стрРеквизитыШапкиДоп = "Партнер,Контрагент,Соглашение,Организация,Договор,Категория,НеИзменятьВМУ,СозданВЦБД,ДатаТочкиТрека";
	стрРеквизитыТЧ		 = "Задачи,СписокФото";
	стррОбъект = Новый Структура(стрРеквизитыШапкиОсн + "," + стрРеквизитыШапкиДоп + "," + стрРеквизитыТЧ); // сохраняемые реквизиты объекта
	ЗаполнитьЗначенияСвойств(СтррОбъект, ЭтаФорма,, стрРеквизитыТЧ);
	
	стррОбъект.Задачи 		= Задачи.Выгрузить();
	стррОбъект.СписокФото   = СписокФото.Выгрузить();
	
	РеквизитФормыВЗначение("Объект").ВОЭлементСохранить(СтррКонтекст.ВО, ID, стррОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура СохранитьПродолжить(РезультатОтвета, ДополнительныеПараметры) Экспорт
	
	Если РезультатОтвета = КодВозвратаДиалога.Да Тогда
		Если СохранитьОбъектВХранилищеКлиент() Тогда
			Закрыть();
		КонецЕсли; 
	ИначеЕсли РезультатОтвета = КодВозвратаДиалога.Нет Тогда
		УстановитьМодифицированостьФормы(Ложь);
		Закрыть();
	КонецЕсли;
	
КонецПроцедуры

// СлужебныеПроцедурыИФункции_Хранилище
#КонецОбласти 

#Область СлужебныеПроцедурыИФункции_РаботаСФормой

&НаКлиенте
Процедура ФормаОбновитьВидимостьЭлементов()
	
	МодульМТ.ФормаСведенияИзМТОбновить(ЭтотОбъект);
	ВидимостьДоговорСоглашение();
	
КонецПроцедуры

&НаСервере
Процедура ВидимостьДоговорСоглашение()
	
	Элементы.Договор.Видимость 		= Ложь;
	Элементы.Соглашение.Видимость 	= Ложь;
	
	ТекОбъект = РеквизитФормыВЗначение("Объект");
	ИспользоватьДоговорыИлиСоглашения = ТекОбъект.ПрочитатьЗначениеНастройки("ИспользоватьДоговорыИлиСоглашения");
	
	Если ИспользоватьДоговорыИлиСоглашения = "СОГЛАШЕНИЯ" И Константы.ИспользованиеСоглашенийСКлиентами.Получить() <> Перечисления.ИспользованиеСоглашенийСКлиентами.НеИспользовать Тогда
		Элементы.Соглашение.Видимость 	= Истина;
	ИначеЕсли ИспользоватьДоговорыИлиСоглашения = "ДОГОВОРЫ" И Константы.ИспользоватьДоговорыСКлиентами.Получить() Тогда
		Элементы.Договор.Видимость 		= Истина;
	КонецЕсли;
		
КонецПроцедуры	

&НаКлиенте
Процедура УстановитьМодифицированостьФормы(Режим = Истина) Экспорт
	
	ЭтаФорма.Модифицированность = Режим;
	Элементы.Сохранить.ЦветТекста = СтррКонтекст.Цвета[?(Режим, "ТекстВнимание", "Авто")];
	
КонецПроцедуры



// СлужебныеПроцедурыИФункции_РаботаСФормой
#КонецОбласти 

&НаКлиенте
Функция МодульК()

	Если гМодульК = Неопределено Тогда
	    гМодульК = ПолучитьФорму(СтррКонтекст.ПутьКФорме + "МодульОбщий", СтррКонтекст);
	КонецЕсли; 
	
	Возврат гМодульК;

КонецФункции 

// СлужебныеПроцедурыИФункции
#КонецОбласти 
