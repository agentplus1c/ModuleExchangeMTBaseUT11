﻿
#Область ГлобальныеПеременные

&НаКлиенте
Перем гМодульК;  // общий клиентский модуль

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

///  Объединяет строки из массива в строку с разделителями.
//
// Параметры:
//  Массив      - Массив - массив строк которые необходимо объединить в одну строку;
//  Разделитель - Строка - любой набор символов, который будет использован в качестве разделителя.
//
// Возвращаемое значение:
//  Строка - строка с разделителями.
// 
&НаКлиентеНаСервереБезКонтекста 
Функция СтрСоединить_(Массив, Разделитель = ",", СокращатьНепечатаемыеСимволы = Ложь)

	Результат = "";
	ТекРазделитель = "";
	
	Для Индекс = 0 По Массив.ВГраница() Цикл
		
		Подстрока = Массив[Индекс];
		
		Если СокращатьНепечатаемыеСимволы Тогда
			Подстрока = СокрЛП(Подстрока);
		КонецЕсли;
		
		Если ТипЗнч(Подстрока) <> Тип("Строка") Тогда
			Подстрока = Строка(Подстрока);
		КонецЕсли;
		
		Результат = Результат + ТекРазделитель + Подстрока;
		
		Если Индекс = 0 Тогда
			ТекРазделитель = Разделитель;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Результат;

КонецФункции

// СовместимостьСПлатформой_8_3_5
#КонецОбласти


#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	//vd_180709 Добавлено свойство "Конфигурация" 
	СтррКонтекст = Новый Структура("НастройкиАгентовРедактируются,ID,ДляВыбора,Конфигурация", Ложь);	
	
	СтррКонтекст.Вставить("СпрТоргТочки");// KT2000_Alcohol_Trade признаки для получения свойств конфигурации и торговых точек
	
	ТекОбъект = РеквизитФормыВЗначение("Объект");		
	ТекОбъект.КонтекстФормыИнициализировать(СтррКонтекст, Параметры);
	
	Если СтррКонтекст.ДляВыбора = Истина Тогда
		Элементы.СпискиТТ.РежимВыбора = Истина;
		Элементы.СпискиТТ.МножественныйВыбор = Истина;
		Элементы.СпискиТТ.ТолькоПросмотр = Истина;
		ЭтаФорма.РежимОткрытияОкна = РежимОткрытияОкнаФормы.БлокироватьОкноВладельца;
	КонецЕсли;
	
	ПрочестьОбъектИзХранилища();
	
	КомандаФормы = Команды.Найти("ПоказатьПартнеров");
	КомандаФормы.Заголовок = СтррКонтекст.СпрТоргТочки.Синоним;
	КомандаФормы.Подсказка = "Показать """ + СтррКонтекст.СпрТоргТочки.Синоним + """";

КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Элементы.ГруппаКоманднаяПанель.ЦветФона = СтррКонтекст.Цвета.ФонРаздела;
	Если СтррКонтекст.ДляВыбора = Истина Тогда
		Элементы.ГруппаКоманднаяПанель.Видимость = Ложь;
		мСтроки = Объект.СпискиТорговыхТочек.НайтиСтроки(Новый Структура("ID", СтррКонтекст.ID));
		Если мСтроки.Количество() <> 0 Тогда
			Элементы.СпискиТТ.ТекущаяСтрока = мСтроки[0].ПолучитьИдентификатор();
		КонецЕсли; 
	КонецЕсли; 
	
	//{{vd_181126
	//vd_180709
	//Если СтррКонтекст.Конфигурация = "УТ_АКФ" Тогда
	//	Элементы.СпискиТТГруппа.Видимость = Истина;
	//Иначе
	//	Элементы.СпискиТТГруппа.Видимость = Ложь;		
	//КонецЕсли;
	Элементы.СпискиТТГруппа.Видимость = (СтррКонтекст.Конфигурация = "УТ_АКФ");
	//}}vd_181126
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)

	Если ИмяСобытия = "АПНастройкиСброшены" Тогда
		
		ЭтаФорма.Модифицированность = Ложь;
		Закрыть();
		
	ИначеЕсли ИмяСобытия = "АПСписокТорговыхТочекЗаписан" Тогда // записан новый элемент списка ТТ или обновлен существующий элемент
		
		ПрочестьОбъектИзХранилища();
		ЭлементСпискаВыделить(Параметр);
		
	ИначеЕсли ИмяСобытия = "АППроверкаУникальностиЗапускаОбработкиОбмена" Тогда
		
		Если Параметр <> СтррКонтекст.ВХОбщиеПараметры Тогда // второй экземпляр обработки справшивает - уже открыта обработка или нет
			Оповестить("АПЗакрытьОбработкуОбменДанными", Параметр); // шлем событие закрытия обработки с конкретным ключем сеанса
		КонецЕсли; 
		
	КонецЕсли;
	
КонецПроцедуры

// ОбработчикиСобытийФормы
#КонецОбласти


#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура КомандаВыполнить(Команда)
	
	МодульК().КомандаВыполнить(Команда, ЭтотОбъект)
	
КонецПроцедуры

// ОбработчикиКомандФормы
#КонецОбласти


#Область ОбработчикиТаблицыФормыСпискиТТ

&НаКлиенте
Процедура СпискиТТПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа, Параметр)
	
	Отказ = Истина;
	ID = ?(Копирование, ЭлементСпискаПолучитьIDТекущего(), Неопределено);
	ЭлементСпискаОткрытьФорму(ID, Копирование);
	
КонецПроцедуры

&НаКлиенте
Процедура СпискиТТВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;	
	
	Если СтррКонтекст.ДляВыбора = Истина Тогда
		СпискиТТВыбратьЗначения(ВыбраннаяСтрока);
	ИначеЕсли Элемент.ТекущиеДанные <> Неопределено Тогда
		ЭлементСпискаОткрытьФорму(ЭлементСпискаПолучитьIDТекущего());
	КонецЕсли;
	
КонецПроцедуры

// Событие вызывается при нажатию на кнопку "Выбор", когда форма открыта в режиме выбора.
&НаКлиенте
Процедура СпискиТТВыборЗначения(Элемент, Значение, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	СпискиТТВыбратьЗначения(Значение);

КонецПроцедуры

// Выбор значения и закрытие формы - когда форма открыта в режиме подбора.
&НаКлиенте
Процедура СпискиТТВыбратьЗначения(мСтроки)
	
	Элемент = Элементы.СпискиТТ;
	
	Если Элемент.ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	СтрокаТ = Элемент.ТекущиеДанные;
	СтррРезультат = Новый Структура("ID,Наименование", СтрокаТ.ID, СтрокаТ.Наименование);
	
	// учитываем, что может быть выбрано несколько значений
	Если ТипЗнч(мСтроки) = Тип("Массив") Тогда
		мЗначения = Новый Массив;
		ТЗ = Объект.СпискиТорговыхТочек;	
		Для Каждого ИдСтроки Из мСтроки Цикл
			СтрокаТ = ТЗ.НайтиПоИдентификатору(ИдСтроки);
			мЗначения.Добавить(Новый Структура("ID,Наименование", СтрокаТ.ID, СтрокаТ.Наименование));
		КонецЦикла;
		СтррРезультат.Вставить("мВыбранныеЗначения", мЗначения);
	КонецЕсли; 
	
	ЭтаФорма.Закрыть(СтррРезультат);

КонецПроцедуры

&НаКлиенте
Процедура СпискиТТПередУдалением(Элемент, Отказ)
	
	Отказ = Истина;
	
	// проверяем - редактируются ли сейчас настройки агентов?
	СтррКонтекст.НастройкиАгентовРедактируются = Ложь;
	Оповестить("АППроверкаРедактированияНастроекАгентов", СтррКонтекст);
	
	Если Элемент.ВыделенныеСтроки.Количество() > 1 Тогда
		Текст = НСтр("ru = 'Удалить выбранные списки торговых точек (выбрано: %1) ?'");
		Текст = СтрШаблон_(Текст, Элемент.ВыделенныеСтроки.Количество());
	Иначе
		Текст = НСтр("ru = 'Удалить список торговых точек?'");
	КонецЕсли;
	
	Оповещение = Новый ОписаниеОповещения("СпискиТТПередУдалениемЗавершение", ЭтотОбъект);
	ПоказатьВопрос(Оповещение, Текст, РежимДиалогаВопрос.ДаНетОтмена);
	
КонецПроцедуры

&НаКлиенте
Процедура СпискиТТПередУдалениемЗавершение(РезультатВопроса, ДополнительныеПараметры) Экспорт
	
	Если РезультатВопроса = КодВозвратаДиалога.Да Тогда
		
		Если СтррКонтекст.НастройкиАгентовРедактируются Тогда
			Текст = НСтр("ru = 'Настройки агентов сейчас редактируются, сохраните настройки агентов и повторите попытку.'");
			ПоказатьПредупреждение(, Текст);
			Возврат;
		КонецЕсли; 

		мСтроки = Элементы.СпискиТТ.ВыделенныеСтроки;
		мУдаляемыеID = Новый Массив;
		
		ТЗ = Объект.СпискиТорговыхТочек;	
		Для Каждого ИдСтроки Из мСтроки Цикл
			СтрокаТ = ТЗ.НайтиПоИдентификатору(ИдСтроки);
			мУдаляемыеID.Добавить(СтрокаТ.ID);
		КонецЦикла;
		
		ОчиститьСообщения();
		ЭлементСпискаУдалить(мУдаляемыеID);
		
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура СпискиТТПриИзменении(Элемент)
	
	// Внимание!!! На данной форме это событие происходит только при смене порядка строк. Если будет расширено поведение поля СпискаТТ
	// и это событие будет вызываться при других изменениях списка, то нужно сохранять объект в хранилище только после изменения порядка строк.
	СохранитьОбъектВХранилище(); 
	
КонецПроцедуры

// ОбработчикиТаблицыФормыСпискиТТ
#КонецОбласти


#Область СлужебныеПроцедурыИФункции

#Область СлужебныеПроцедурыИФункции_Прочие

&НаКлиенте
Функция МодульК()

	Если гМодульК = Неопределено Тогда
	    гМодульК = ПолучитьФорму(СтррКонтекст.ПутьКФорме + "МодульОбщий", СтррКонтекст);
	КонецЕсли; 
	
	Возврат гМодульК;

КонецФункции

// СлужебныеПроцедурыИФункции_Прочие
#КонецОбласти 

#Область СлужебныеПроцедурыИФункции_Хранилище

&НаСервере
Процедура ПрочестьОбъектИзХранилища()

	ТекОбъект = РеквизитФормыВЗначение("Объект");
	
	// проверяем - записывались ли вообще списки ТТ? если нет, записываем пустой список - чтобы в хранилище всегда была ТЗ правильной структуры.
	тзСТТ = ТекОбъект.ПрочитатьЗначениеНастройки("СпискиТорговыхТочек");
	Если ТипЗнч(тзСТТ) <> Тип("ТаблицаЗначений") Тогда
		ТекОбъект.СохранитьЗначениеНастройки("СпискиТорговыхТочек", Объект.СпискиТорговыхТочек.Выгрузить());
	КонецЕсли; 
	
	ТекОбъект.ВосстановитьЗначенияНастроекОбработки(НастройкиФормы());
	ЗначениеВРеквизитФормы(ТекОбъект, "Объект");

КонецПроцедуры

&НаСервере
Процедура СохранитьОбъектВХранилище()

	ТекОбъект = РеквизитФормыВЗначение("Объект");
	ТекОбъект.СохранитьЗначениеНастройки("СпискиТорговыхТочек", Объект.СпискиТорговыхТочек.Выгрузить());

КонецПроцедуры 

&НаКлиентеНаСервереБезКонтекста
Функция НастройкиФормы()

	Возврат "СпискиТорговыхТочек";
	
КонецФункции

// СлужебныеПроцедурыИФункции_Хранилище
#КонецОбласти 

#Область СлужебныеПроцедурыИФункции_ЭлементыСписка

&НаКлиенте
Процедура ЭлементСпискаОткрытьФорму(ID = Неопределено, Копирование = Ложь)
	
	Ключ = ?(ID = Неопределено Или Копирование, Новый УникальныйИдентификатор, ID);
	стррПараметры = Новый Структура("ID,Копирование,ВызовИзФормыСписка", ID, Копирование, Истина);
	МодульК().ОткрытьФормуОбработки("СписокТорговыхТочек", стррПараметры, Ключ);
	
КонецПроцедуры

&НаКлиенте
Функция ЭлементСпискаПолучитьIDТекущего()
	
	СтрокаТ = Элементы.СпискиТТ.ТекущиеДанные;
	Возврат ?(СтрокаТ <> Неопределено, СтрокаТ.ID, Неопределено);

КонецФункции
 
&НаКлиенте
Процедура ЭлементСпискаВыделить(ID)
	
	Если ТипЗнч(ID) = Тип("УникальныйИдентификатор") Тогда
		мСтроки = Объект.СпискиТорговыхТочек.НайтиСтроки(Новый Структура("ID", ID));
		Если мСтроки.Количество() <> 0 Тогда
			Элементы.СпискиТТ.ТекущаяСтрока = мСтроки[0].ПолучитьИдентификатор();
		КонецЕсли; 
	КонецЕсли; 
	
КонецПроцедуры

// Процедура удаляет списки торговых точек. Если список ТТ удалить нельзя, выводит сообщения.
// 
// Параметры:
//	мУдаляемыеID - Массив - массив идентификаторов ID удаляемых списков торговых точек.
//	
&НаСервере
Процедура ЭлементСпискаУдалить(мУдаляемыеID)
	
	стррПоискСТТ = Новый Структура("ID"); // структура для поиска списка торговых точек по реквизиту "ID"
	тзСТТ = Объект.СпискиТорговыхТочек;
	
	мУдаляемыеСтроки = Новый Массив; // массив удаляемых строк
	текОбъект = РеквизитФормыВЗначение("Объект");
	тзНА = текОбъект.ПрочитатьЗначениеНастройки("НастройкиАгентов");
	
	Если ТипЗнч(тзНА) = Тип("ТаблицаЗначений") Тогда // проверяем - используются ли удаляемые списки ТТ в настройках агентов?
		
		стррПоискНА = Новый Структура("СсылкаСписокТТ"); // структура для поиска настроек агентов по реквизиту "СсылкаСписокТТ"
		
		Для каждого ID Из мУдаляемыеID Цикл
			стррПоискСТТ.ID 			= ID;
			стррПоискНА.СсылкаСписокТТ	= ID;			
			мСтрокиСТТ = тзСТТ.НайтиСтроки(стррПоискСТТ); // массив найденных строк списков торговых точек (состоит из одного элемента)
			мСтрокиНА  = тзНА.НайтиСтроки(стррПоискНА);   // массив найденных строк настроек агентов
			Если мСтрокиНА.Количество() = 0 Тогда // можно удалить список торговых точек
				ОбщегоНазначенияКлиентСервер.ДополнитьМассив(мУдаляемыеСтроки, мСтрокиСТТ);
			ИначеЕсли мСтрокиНА.Количество() = 1 Тогда
				Текст = НСтр("ru = 'Нельзя удалить элемент ""%1"", т.к. он используется торговым агентом ""%2"".'");
				Текст = СтрШаблон_(Текст, мСтрокиСТТ[0].Наименование, мСтрокиНА[0].Пользователь);
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Текст);
			Иначе
				Текст = НСтр("ru = 'Нельзя удалить элемент ""%1"", т.к. он используется торговыми агентами:'");
				Текст = СтрШаблон_(Текст, мСтрокиСТТ[0].Наименование);
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Текст);
				Для Индекс = 0 По мСтрокиНА.ВГраница() Цикл
					Текст = СтрШаблон_(НСтр("ru = '    %1. %2'"), Индекс+1, мСтрокиНА[Индекс].Пользователь);
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Текст);
				КонецЦикла; 
			КонецЕсли; 
		КонецЦикла; 
		
	Иначе // настройки агентов отсутствуют, удаляем элементы без проверки использования
		
		Для каждого ID Из мУдаляемыеID Цикл
			стррПоискСТТ.ID = ID;
			ОбщегоНазначенияКлиентСервер.ДополнитьМассив(мУдаляемыеСтроки, тзСТТ.НайтиСтроки(стррПоискСТТ));
		КонецЦикла; 
		
	КонецЕсли; 
	
	Если мУдаляемыеСтроки.Количество() > 0 Тогда
		Для каждого СтрокаТ Из мУдаляемыеСтроки Цикл
			текОбъект.УдалитьОбъектИзХранилища("СпрСТТ", СтрокаТ.ID); // удаляем элемент списка торговых точек из хранилища
			тзСТТ.Удалить(тзСТТ.Индекс(СтрокаТ));
		КонецЦикла; 
		// записываем списки ТЗ списка торговых точек в хранилище
		СохранитьОбъектВХранилище();
	КонецЕсли; 
	
КонецПроцедуры

////vd_181210 Перенесна в модульо бъекта
//// vd_180704 Добавлена
////
//// Параметры:
////  мИзменения 				     		 - Массив	 -  массив сирок (тип строка), передается пустой а процедура заполняет его строками изменений и далее отображает их в сообщениях
////  ПодразделениеОтборПоПодразделению	 - ОприделяемыйТип.Подразделение - Если не равно Неопределено то 
////
//&НаСервере
//Процедура АКФ_ДобавитьТорговыеТочкиВСпискиНаСервере(мИзменения, ПодразделениеОтборПоПодразделению = Неопределено)
//	
//	ТекОбъект = РеквизитФормыВЗначение("Объект");
//			
//	//1. Создадим ТЗ связи СписокТорговыхТочек - Назначеные Агенты (агентов для ТТ может быть несколько, колонка СсылкаСписокТТ не уникальна)
//	тзСписокТТиАгентов = Новый ТаблицаЗначений;
//	тзСписокТТиАгентов.Колонки.Добавить("СсылкаСписокТТ", Новый ОписаниеТипов("УникальныйИдентификатор"));
//	тзСписокТТиАгентов.Колонки.Добавить("спрПользователь", Новый ОписаниеТипов("СправочникСсылка.Пользователи"));
//	
//	//2. Получим данные настроек агентов из хранилища
//	ТекОбъект.ВосстановитьЗначенияНастроекОбработки("НастройкиАгентов");
//	
//	//3. Заполним тзСписокТТиАгентов из НастройкиАгентов
//	Для Каждого Элемент Из ТекОбъект.НастройкиАгентов Цикл 
//		НоваяСтрока = тзСписокТТиАгентов.Добавить();
//		НоваяСтрока.СсылкаСписокТТ = Элемент.СсылкаСписокТТ;
//		НоваяСтрока.спрПользователь = Элемент.Пользователь;
//	КонецЦикла;
//	
//	//4. Оприделяем временные массивы для обработки данных
//	мСостав        = Новый Массив; // Массив торговых точек (тип Справочник.ТорговыеТочки) которые уже входят в список торговых точек
//	мСоставНовые   = Новый Массив; // Массив торговых точек (тип Справочник.ТорговыеТочки) которые требуется добавить в список торговых точек
//	мАгенты        = Новый Массив; // Массив агентов (тип Справочник.Пользователи) котрым назначен список торговых точек
//	стррОтбор      = Новый Структура("СсылкаСписокТТ"); // Структура для поиска значений в тзСписокТТиАгентов
//	
//	//5. Заполняем состав списков
//	Для Каждого ЭлементСписка Из Объект.СпискиТорговыхТочек Цикл
//		
//		мСостав.Очистить();
//		мСоставНовые.Очистить();
//		мАгенты.Очистить();
//		
//		стррОбъектСписокТТ = ТекОбъект.ПолучитьОбъектИзХранилища("СпрСТТ", ЭлементСписка.ID);
//		тзСостав = стррОбъектСписокТТ.Состав; // Текущая ТЗ Состав для списка ЭлементСписока

//		// 5.1 Оприделяем Агентов назначеной текущему списку торговых точек ЭлементСписока
//		стррОтбор.СсылкаСписокТТ = ЭлементСписка.ID;
//		мСтрокиТЗ = тзСписокТТиАгентов.НайтиСтроки(стррОтбор);
//		Для Каждого ЭлементМассиваСтрокиТЗ Из мСтрокиТЗ Цикл
//			//Если отбор происходит по Подразделению то не добовляем в мАгенты агентов не вошедших в это подразделение
//			Если ПодразделениеОтборПоПодразделению = Неопределено Тогда 
//				мАгенты.Добавить(ЭлементМассиваСтрокиТЗ.спрПользователь);
//			ИначеЕсли ПодразделениеОтборПоПодразделению = ЭлементМассиваСтрокиТЗ.спрПользователь.Подразделение Тогда 
//				мАгенты.Добавить(ЭлементМассиваСтрокиТЗ.спрПользователь);
//			КонецЕсли;			
//		КонецЦикла;   		
//		
//		//5.4 Удаляем из текущей тзСостав те торговые точки котрые больше не удовлетворяют условию из Справочник.ТорговыеТочки.ТорговыйПредставитель
//		КоличествоСоставУдаленные = 0;
//		АКФ_УдалитьТорговыеТочкиНеПривязанныеКАгентам(тзСостав, мАгенты, КоличествоСоставУдаленные);
//		
//		// 5.2 Оприделяем текущий Состав списка торговой точки (мСостав)
//		Для Каждого ЭлементCостава Из тзСостав Цикл      
//			мСостав.Добавить(ЭлементCостава.АКФ_СпрТТ);
//		КонецЦикла;
//		
//		// 5.4 Оприделяем торговые точки из Справочники.ТорговыеТочки, которые требуется добавить в текущий список торговых точек.
//		мСоставНовые = ТекОбъект.АКФ_ПодобратьТорговыеТочкиПоАгентам(мАгенты, мСостав);
//		
//		//5.5 Возврат если изменений в списке нет.
//		КоличествоСоставНовые = мСоставНовые.Количество();
//		Если КоличествоСоставНовые = 0 И КоличествоСоставУдаленные = 0 Тогда
//			Продолжить;
//		Конецесли;
//		
//		//5.6 Формирование массива сообщений р изменениях
//		Если КоличествоСоставНовые > 0 Тогда 
//			мИзменения.Добавить("Для списка торговых точек: " + ЭлементСписка.Наименование + " добавлено: " + КоличествоСоставНовые + " торговых точек.");
//		КонецЕсли;
//		Если КоличествоСоставУдаленные > 0 Тогда 
//			мИзменения.Добавить("Для списка торговых точек: " + ЭлементСписка.Наименование + " удалено: " + КоличествоСоставУдаленные + " торговых точек.") ;	
//		КонецЕсли;
//		
//		// 5.7 Заполняем и добавляем мСоставНовые в состав списка торговых точек в текущую тзСостав.
//		Для Каждого ЭлементНовые Из мСоставНовые Цикл
//			НоваяСтрокаТЗСостав = тзСостав.Добавить();
//			НоваяСтрокаТЗСостав.Партнер          = ЭлементНовые.Партнер;
//			НоваяСтрокаТЗСостав.ИдАдресаДоставки = Строка(ЭлементНовые.УникальныйИдентификатор()) + "000";
//			НоваяСтрокаТЗСостав.АКФ_СпрТТ        = ЭлементНовые;
//			НоваяСтрокаТЗСостав.Адрес            = ЭлементНовые.Адрес;
//		КонецЦикла;		
//		
//		//5.8 Сохраняем Состав в хранилище значений
//		стррОбъектСписокТТ.Состав = тзСостав;
//		ТекОбъект.СохранитьОбъектВХранилище("СпрСТТ", ЭлементСписка.ID, стррОбъектСписокТТ);
//		
//		//5.9 Записываем в сам список новое колличество торговых точек.
//		ЭлементСписка.ВсегоТочек = тзСостав.Количество();
//	
//	КонецЦикла;
//	
//	//6. Сохраняем списки в хранилище
//	Если мИзменения.Количество() > 0 тогда
//		СохранитьОбъектВХранилище();
//	Иначе
//		мИзменения.Добавить("Обновление списка торговых точек не требуется.");
//	Конецесли;	
//	
//КонецПроцедуры

//vd_180704 Добавлена
&НаКлиенте
Процедура АКФ_ДобавитьТорговыеТочкиВСписки(Команда)
	
	мИзменения = Новый Массив;
	АКФ_ДобавитьТорговыеТочкиВСписки_Сервер(мИзменения); //vd_181210 Перенесена в общий модуль АКФ_ДобавитьТорговыеТочкиВСпискиНаСервере(мИзменения)
	
	Для Каждого Элемент Из мИзменения Цикл
		Сообщить(Элемент);	
	КонецЦикла;	
	
КонецПроцедуры

//vd_181210 Добавлена
&НаСервере
Процедура АКФ_ДобавитьТорговыеТочкиВСписки_Сервер(мИзменения, Подразделение = Неопределено)
	ТекОбъект = РеквизитФормыВЗначение("Объект"); 
	ТекОбъект.АКФ_ДобавитьТорговыеТочкиВСпискиНаСервере(мИзменения, Подразделение);
	ПрочестьОбъектИзХранилища();	
КонецПроцедуры


//vd_180705 Добавлена
&НаСервере
Функция АКФ_ПолучитьТипПодразделения() 
	возврат Метаданные.ОпределяемыеТипы.Подразделение.Тип;
КонецФункции

//vd_180705 Добавлена
&НаКлиенте
Процедура АКФ_ДобавитьТорговыеТочкиВСпискиПоПодразделению(Команда)
	
	Оповещение = Новый ОписаниеОповещения("АКФ_ДобавитьТорговыеТочкиВСпискиПоПодразделениюОбработкаВыбора", ЭтотОбъект);
	ПоказатьВводЗначения(Оповещение, , "Выбор подразделения", АКФ_ПолучитьТипПодразделения());
	
КонецПроцедуры

//vd_180706 Добавлена
&НаКлиенте
Процедура АКФ_ДобавитьТорговыеТочкиВСпискиПоПодразделениюОбработкаВыбора(Результат, Параметры) Экспорт
	
	Если Результат = Неопределено Тогда
		Сообщить("Не выбрано подразделение.");
		Возврат;
	КонецЕсли;
	
	мИзменения = Новый Массив;
	АКФ_ДобавитьТорговыеТочкиВСписки_Сервер(мИзменения, Результат); //vd_181210 Перенесена в общий модуль АКФ_ДобавитьТорговыеТочкиВСпискиНаСервере(мИзменения, Результат);
	
	Для Каждого Элемент Из мИзменения Цикл
		Сообщить(Элемент);	
	КонецЦикла;
	
КонецПроцедуры

////vd_181210 Перенесна в модульо бъекта
////vd_180706 Добавлена
//&НаСервере
//Процедура АКФ_УдалитьТорговыеТочкиНеПривязанныеКАгентам(тзСостав, мАгенты , КоличествоУдаленныхЭлементов)
//	
//	Если тзСостав.Количество() = 0 или мАгенты.Количество() = 0 Тогда
//		Возврат;
//	Конецесли;
//	
//	флОставитьЭлемент = Ложь; //Признак удалять торговую точку из мСостав , или нет.	
//	Сч = 0;
//	
//	Пока Сч < тзСостав.Количество() Цикл  //vd_180730 Изменен Для Каждого Элемент Из тзСостав Цикл и добавлена переменная Сч
//					
//		СтрокаТаблицы     = тзСостав.Получить(Сч);
//		флОставитьЭлемент = Ложь;
//				
//		Для Каждого ЭлементАгент Из мАгенты Цикл   
//			Если ЭлементАгент.ФизическоеЛицо = СтрокаТаблицы.АКФ_СпрТТ.ТорговыйПредставитель Тогда 
//				флОставитьЭлемент = Истина;	
//			КонецЕсли;
//		КонецЦикла;
//		
//		//Удаление строки
//		Если НЕ флОставитьЭлемент Тогда
//			тзСостав.Удалить(СтрокаТаблицы);						
//			КоличествоУдаленныхЭлементов = КоличествоУдаленныхЭлементов + 1;
//		Иначе
//			Сч = Сч + 1;
//		КонецЕсли;		
//		
//	КонецЦикла;
//		
//КонецПроцедуры

// СлужебныеПроцедурыИФункции_ЭлементыСписка
#КонецОбласти 

// СлужебныеПроцедурыИФункции
#КонецОбласти