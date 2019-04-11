﻿#Область ГлобальныеПеременные

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
	
	ТекОбъект = РеквизитФормыВЗначение("Объект");
	ТекОбъект.КонтекстФормыИнициализировать(СтррКонтекст, Параметры);
	
	СтррКонтекст.Вставить("ИмяФайла", ТекОбъект.ИмяФайлаОбработки()); // имя файла обработки для установки отбора
	СтррКонтекст.Вставить("СправочникДополнительныеОтчетыИОбработкиСиноним", Метаданные.Справочники.ДополнительныеОтчетыИОбработки.Синоним);
	СтррКонтекст.Вставить("ИдентификаторЗадания"); // идентификатор регламентного задания, связанного с обработкой, проставляется в процедуре ПроверитьСтатусОбработки()
	
	стррИконкиСтатуса = Новый Структура("Пусто,ОК,Внимание", 0, 1, 2);
	стррКонтекст.Вставить("ИконкиСтатуса", стррИконкиСтатуса);
	
	Элементы.СправочникУТДополнительныеОтчетыИОбработки.Заголовок = 
		СтрШаблон_(НСтр("ru = 'Справочник ""%1""'"), СтррКонтекст.СправочникДополнительныеОтчетыИОбработкиСиноним);
	Элементы.ОбработкаУТРегламентныеИФоновыеЗадания.Заголовок = НСтр("ru = 'Регламентное задание'");		
	
	ПроверитьСтатусОбработки();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Элементы.ГруппаКоманднаяПанель.ЦветФона = СтррКонтекст.Цвета.ФонРаздела;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)

	Если ИмяСобытия = "Запись_РегламентныеЗадания" Тогда // оповещение от УТ о записи регламентного задания
		ПроверитьСтатусОбработки();
	КонецЕсли;
	
КонецПроцедуры

// ОбработчикиСобытийФормы
#КонецОбласти


#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура КомандаВыполнить(Команда)
	
	МодульК().КомандаВыполнить(Команда, ЭтотОбъект)
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаПоказатьНастройкиМодуля(Команда)
	
	МодульК().КомандаВыполнить(Команда, ЭтотОбъект);
	стррПараметры = Новый Структура("Закладка", "ГруппаДополнительно");
	Оповестить("АПНастройкиМодуля_ПоказатьНаФорме", стррПараметры);
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаОбновитьСтатусы(Команда)

	Попытка
		ПроверитьСтатусОбработки();
	Исключение
		ПоказатьПредупреждение(Неопределено, "Запущен второй экземпляр обработки в фоновом режиме. Закройте текущую обработку или ее фоновый сеанс (отмените регламентное задание).");		
	КонецПопытки;
	Оповестить("АПОбновленыНастройкиФоновогоЗадания");
	
КонецПроцедуры

// ОбработчикиКомандФормы
#КонецОбласти


#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура СправочникУТДополнительныеОтчетыИОбработкиНажатие(Элемент)
	
	стррПараметры = Новый Структура("Отбор", Новый Структура("ИмяФайла", СтррКонтекст.ИмяФайла));
	Форма = ПолучитьФорму("Справочник.ДополнительныеОтчетыИОбработки.Форма.ФормаСписка", стррПараметры,, "АПОтбор_ИмяФайла");
	Форма.Автозаголовок = Ложь;
	Форма.Заголовок = СтрШаблон_(НСтр("ru = '%1 (отбор ИмяФайла = ""%2"")'"),
		СтррКонтекст.СправочникДополнительныеОтчетыИОбработкиСиноним, СтррКонтекст.ИмяФайла);
	Форма.Открыть();
	ОчиститьСообщения();		
	Сообщить(СтрШаблон_(НСтр("ru = 'Включен отбор по условию: ИмяФайла = ""%1""'"), СтррКонтекст.ИмяФайла));
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаУТРегламентныеИФоновыеЗаданияНажатие(Элемент)
	
	Если ЗначениеЗаполнено(СтррКонтекст.ИдентификаторЗадания) Тогда
		стррПараметры = Новый Структура;
		стррПараметры.Вставить("Идентификатор", СтррКонтекст.ИдентификаторЗадания);
		стррПараметры.Вставить("Действие",      "Изменить");
		ОткрытьФорму("Обработка.РегламентныеИФоновыеЗадания.Форма.РегламентноеЗадание", стррПараметры, ЭтотОбъект);	
	Иначе
		ОткрытьФорму("Обработка.РегламентныеИФоновыеЗадания.Форма");
	КонецЕсли; 
	
КонецПроцедуры

// ОбработчикиСобытийЭлементовФормы
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

&НаСервере
Процедура ПроверитьСтатусОбработки()

	стррРезультат = РеквизитФормыВЗначение("Объект").ГотовностьФоновогоЗадания();
	
	СтатусДополнительныеОтчетыИОбработки = стррРезультат.РегистрацияОбработки.Иконка;
	Элементы.НадписьДополнительныеОтчетыИОбработки.Заголовок = стррРезультат.РегистрацияОбработки.Описание;
	Элементы.НадписьДополнительныеОтчетыИОбработки.ЦветТекста 
		= ?(стррРезультат.РегистрацияОбработки.Готово, СтррКонтекст.Цвета.ТекстПояснение, СтррКонтекст.Цвета.ТекстВнимание);
	
	СтатусРегламентныеИФоновыеЗадания = стррРезультат.РегламетноеЗадание.Иконка;
	Элементы.НадписьРегламентныеИФоновыеЗадания.Заголовок = стррРезультат.РегламетноеЗадание.Описание;
	Элементы.НадписьРегламентныеИФоновыеЗадания.ЦветТекста 
		= ?(стррРезультат.РегламетноеЗадание.Готово, СтррКонтекст.Цвета.ТекстПояснение, СтррКонтекст.Цвета.ТекстВнимание);
	СтррКонтекст.ИдентификаторЗадания = стррРезультат.РегламетноеЗадание.ИдентификаторЗадания;
			
КонецПроцедуры

// СлужебныеПроцедурыИФункции
#КонецОбласти
