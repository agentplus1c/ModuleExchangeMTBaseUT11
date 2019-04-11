﻿
#Область ГлобальныеПеременные

&НаКлиенте
Перем МодульКарты;  // общий клиентский модуль работы с картами

// ГлобальныеПеременные
#КонецОбласти

#Область СовместимостьСПлатформой_8_3_5

// Разбивает строку на несколько строк по разделителю. Разделитель может иметь любую длину.
//
// Параметры:
//  Строка                 - Строка - текст с разделителями;
//  Разделитель            - Строка - разделитель строк текста, минимум 1 символ;
//  ПропускатьПустыеСтроки - Булево - признак необходимости включения в результат пустых строк.
//    Если параметр не задан, то функция работает в режиме совместимости со своей предыдущей версией:
//     - для разделителя-пробела пустые строки не включаются в результат, для остальных разделителей пустые строки
//       включаются в результат.
//     Е если параметр Строка не содержит значащих символов или не содержит ни одного символа (пустая строка), то в
//       случае разделителя-пробела результатом функции будет массив, содержащий одно значение "" (пустая строка), а
//       при других разделителях результатом функции будет пустой массив.
//  СокращатьНепечатаемыеСимволы - Булево - сокращать непечатаемые символы по краям каждой из найденных подстрок.
//
// Возвращаемое значение:
//  Массив - массив строк.
&НаКлиентеНаСервереБезКонтекста 
Функция СтрРазделить_(Знач Строка, Знач Разделитель = ",", Знач ПропускатьПустыеСтроки = Неопределено, СокращатьНепечатаемыеСимволы = Ложь)
	
	Результат = Новый Массив;
	
	// Для обеспечения обратной совместимости.
	Если ПропускатьПустыеСтроки = Неопределено Тогда
		ПропускатьПустыеСтроки = ?(Разделитель = " ", Истина, Ложь);
		Если ПустаяСтрока(Строка) Тогда 
			Если Разделитель = " " Тогда
				Результат.Добавить("");
			КонецЕсли;
			Возврат Результат;
		КонецЕсли;
	КонецЕсли;
	//
	
	Позиция = Найти(Строка, Разделитель);
	Пока Позиция > 0 Цикл
		Подстрока = Лев(Строка, Позиция - 1);
		Если Не ПропускатьПустыеСтроки Или Не ПустаяСтрока(Подстрока) Тогда
			Если СокращатьНепечатаемыеСимволы Тогда
				Результат.Добавить(СокрЛП(Подстрока));
			Иначе
				Результат.Добавить(Подстрока);
			КонецЕсли;
		КонецЕсли;
		Строка = Сред(Строка, Позиция + СтрДлина(Разделитель));
		Позиция = Найти(Строка, Разделитель);
	КонецЦикла;
	
	Если Не ПропускатьПустыеСтроки Или Не ПустаяСтрока(Строка) Тогда
		Если СокращатьНепечатаемыеСимволы Тогда
			Результат.Добавить(СокрЛП(Строка));
		Иначе
			Результат.Добавить(Строка);
		КонецЕсли;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// СовместимостьСПлатформой_8_3_5
#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	СтррКонтекст = Новый Структура("Ключ,Реквизиты,Автокоординаты");
	ТекОбъект = РеквизитФормыВЗначение("Объект");		
	ТекОбъект.КонтекстФормыИнициализировать(СтррКонтекст, Параметры);
	
	стррРеквизиты = Новый Структура; // пары значений - "<Реквизит формы>, <Имя элемента формы>"
	стррРеквизиты.Вставить("СпособАвтоопределение", "Автоадрес");
	стррРеквизиты.Вставить("СпособПоАдресу", 		"АдресПоиска");
	стррРеквизиты.Вставить("СпособУказатьНаКарте",  "ДекорацияУказатьНаКарте");
	
	СтррКонтекст.Реквизиты = стррРеквизиты;	

КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	МодульКарты	= ПолучитьФорму(СтррКонтекст.ПутьКФорме + "МодульКарты", СтррКонтекст, ЭтаФорма, "АгентПлюсМодульКартыКлиент");
	стррКоординаты = МодульКарты.ПолучитьКоординатыПользователя();
	
	// Определяем первый доступный способ указания центра карты и запоминаем его в переменной Способ
	
	Если стррКоординаты <> Неопределено Тогда
		Автоадрес = стррКоординаты.Город + ", " + стррКоординаты.Регион;
		СтррКонтекст.Автокоординаты = стррКоординаты; // запоминаем координаты, возвращенные сервисом по ip-адресу
		Способ = "СпособАвтоопределение";		
	Иначе // веб-сервис определения координат недоступен
		Автоадрес = НСтр("ru = '<Сервис недоступен>'");
		Элементы.СпособАвтоопределение.Доступность = Ложь;
		Способ = "СпособУказатьНаКарте";
	КонецЕсли; 
	
	// Если есть сохраненное значение способа, устанавливаем его, но при условии, что значение не "СпособАвтоопределение" -
	// в этом случае используем первый доступный способ.
	
	Если ЗначениеСпособаСохраняемое <> "СпособАвтоопределение" И Не ПустаяСтрока(ЗначениеСпособаСохраняемое) Тогда
		Способ = ЗначениеСпособаСохраняемое; // Если ЗначениеСпособаСохраняемое = "СпособАвтоопределение" и сервис недоступен, то
	КонецЕсли; 
	
	ПриИзмененииСпособа(Способ);
	
КонецПроцедуры

// ОбработчикиСобытийФормы
#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура КомандаОК(Команда)
	
	Если СпособАвтоопределение Тогда
		
		ЗакрытьФормуИВернутьРезультат(СтррКонтекст.Автокоординаты, "СпособАвтоопределение");
		
	ИначеЕсли СпособПоАдресу Тогда // нужно получить координаты по адресу
		
		Если ПустаяСтрока(АдресПоиска) Тогда
			Текст = НСтр("ru = 'Укажите название города или адрес'");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Текст,, "АдресПоиска");
		Иначе // ищем координаты по указанному адресу
			списКоординаты = МодульКарты.ПолучтьКоординатыОтВебСервиса(АдресПоиска, Ложь);
			Если списКоординаты = Неопределено Тогда // сервис недоступен, МодульКарты об этом сообщил.
			ИначеЕсли списКоординаты.Количество() = 1 Тогда
				ЗакрытьФормуИВернутьРезультат(ПолучитьКоординатыИзЭлементаСписка(списКоординаты[0]), "СпособПоАдресу");
			Иначе
				Оповещение = Новый ОписаниеОповещения("КоординатыОбработкаВыбораИзСписка", ЭтотОбъект);
				списКоординаты.ПоказатьВыборЭлемента(Оповещение, Нстр("ru = 'Выберите координаты по адресу'"));
			КонецЕсли; 
		КонецЕсли; 
		
	ИначеЕсли СпособУказатьНаКарте Тогда // выбор координат на карте
		
		ЗакрытьФормуИВернутьРезультат("ВыбратьНаКарте", "СпособУказатьНаКарте");
		
	Иначе
		
		ВызватьИсключение("Неизвестный способ указания центра карты!");
		
	КонецЕсли; 

КонецПроцедуры

// ОбработчикиКомандФормы
#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура СпособПриИзменении(Элемент)
	
	ПриИзмененииСпособа(Элемент.Имя);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриИзмененииСпособа(Имя)
	
	стррРеквизиты = СтррКонтекст.Реквизиты;
	Для Каждого Реквизит Из стррРеквизиты Цикл
		ЭтотОбъект[Реквизит.Ключ] = (Реквизит.Ключ = Имя);
		Если Реквизит.Значение <> Неопределено Тогда
			Элементы[Реквизит.Значение].Доступность = ЭтотОбъект[Реквизит.Ключ];
		КонецЕсли; 
	КонецЦикла; 
	
КонецПроцедуры

// ОбработчикиСобытийЭлементовФормы
#КонецОбласти 

#Область СлужебныеПроцедурыИФункции

// Процедура закрывает форму с возвратом результата выбора.
// 
// Параметры:
// 		Результат - Строка, Структура - результат выбора - зависит от выбранного пользователем способа указания центра карты.
// 		СпособВыбораЦентраКарты - Строка - сохраняемый способ выбора центра карты при закрытии формы.
&НаКлиенте
Процедура ЗакрытьФормуИВернутьРезультат(Результат, СпособВыбораЦентраКарты)
	
	ЗначениеСпособаСохраняемое = СпособВыбораЦентраКарты;
	Закрыть(Результат);
	
КонецПроцедуры

&НаКлиенте
Процедура КоординатыОбработкаВыбораИзСписка(ЭлементСписка, ДополнительныеПараметры) Экспорт
	
	Если ЭлементСписка <> Неопределено Тогда
		ЗакрытьФормуИВернутьРезультат(ПолучитьКоординатыИзЭлементаСписка(ЭлементСписка), "СпособПоАдресу");
	КонецЕсли;

КонецПроцедуры	

&НаКлиенте
Функция ПолучитьКоординатыИзЭлементаСписка(ЭлементСписка)
	
	СтррРезультат = Новый Структура("Широта,Долгота,Город");
	СтррРезультат.Город = СтрЗаменить(ЭлементСписка.Представление, "*", "");
	мКоординаты = СтрРазделить_(ЭлементСписка.Значение, " ");
	СтррРезультат.Широта   = Число(СтрЗаменить(мКоординаты[0], " ", ""));
	СтррРезультат.Долгота  = Число(СтрЗаменить(мКоординаты[1], " ", ""));
	
	Возврат СтррРезультат;
	
КонецФункции

// СлужебныеПроцедурыИФункции
#КонецОбласти 
