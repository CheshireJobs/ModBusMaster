/**
 *******************************************************************************
 * @file    app_defs.h
 * @author  Максим Егоров
 * @version V1.2.0
 * @date    25 Марта 2018
 * @brief   Общие типы и константы для приложения (выделено в отдельный файл
 *			для меньшей зависимости от платформы)
 *******************************************************************************
 *
 * <h2><center>&copy; COPYRIGHT(c) 2018-2019 Max Egorov</center></h2>
 *
 * @attention Not to be copied/redistributed without author's permission
 *
 * История изменений:
 * ------------------
 *
 * Дата       |Версия | Изменения                                | Автор
 * -----------|-------|------------------------------------------|--------------
 * 28.07.2018 | 1.0.0 | Начальная версия                         | Максим Егоров
 * 25.03.2019 | 1.1.0 | Доработка форматирования                 | Максим Егоров
 * 28.08.2019 | 1.2.0 | Доработка app_port                       | Максим Егоров
 *
 *******************************************************************************
 */

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __APP_DEFS_H_
#define __APP_DEFS_H_

#ifdef __cplusplus
extern "C" {
#endif

/** @addtogroup App
  * @brief		Общие функции и коды ошибок для приложения
  * @{
  */

/* Conditional compilation settings ------------------------------------------*/
/** @defgroup	App_Conditional_Compilation_Settings
  *				Conditional Compilation Settings
  * @brief		Параметры условной компиляции
  * @{
  */

/**
  * @}
  */

/* Includes ------------------------------------------------------------------*/
/* Стандартные и обязательные библиотеки */
#include <string.h>
#include <stdint.h>

/* Exported macro ------------------------------------------------------------*/
/** @defgroup	App_Exported_Macro
  *				Exported Macro
  * @brief		Экспортируемые макросы
  * @{
  */

/** @defgroup	App_Exported_Macro_Group1
  *				Exported Macro Group 1
  * @brief		Работа с частями целочисленных переменных
  * @{
  */
#define App_LowByte(var16)		((uint8_t) (var16))				/*!< Младший байт двух- и более-байтовой переменной */
#define App_HighByte(var16)		((uint8_t) (((var16) >> 8) & 0xFF))		/*!< Старший байт двухбайтовой переменной */
#define App_GetByte(var,byte)	((uint8_t) (((var) >> 8 * (byte)) & 0xFF))	/*!< Получение байта #byte (0 - младший) многобайтовой переменной */
#define App_LowHalf(var16)		((uint16_t) (var16))					/*!< Младшие 2 байта 4-байтовой переменной */
#define App_HighHalf(var32)		((uint16_t) (((var32) >> 16) & 0xFFFF))	/*!< Старшие 2 байта 4-байтовой переменной */
#define App_LSB_MSB_16(var16)		(App_HighByte(var16) | (App_LowByte(var16) << 8))	/*!< LSB->MSB для 16-битной переменной */
#define App_LSB_MSB_32(var32)		((((var32) & 0xFF000000) >> 24) | (((var32) & 0x00FF0000) >> 8) | (((var32) & 0x0000FF00) << 8) | ((var32) << 24))	/*!< LSB->MSB для 32-битной переменной */
#define App_Bits_To_Bytes(BitCount)	(((BitCount) % 8) ? (((BitCount) / 8) + 1) : ((BitCount) / 8))	/*!< Количество байт занимаемых BitCount битами */
#define App_Bits_To_Bytes_N(BitCount, Bits)	(((BitCount) % (Bits)) ? (((BitCount) / (Bits)) + 1) : ((BitCount) / (Bits)))	/*!< Количество байт, занимаемых BitCount битами (исходя из количество бит в условном байте) */
#define App_Bits_To_Bytes_Round(BitCount)	((BitCount) / 8)	/*!< Количество байт занимаемых BitCount битами (округленное) */
#define App_CircBuff_Inc(position, buffersize)	(position = (position + 1) % (buffersize))	/*!< Получение следующей позиции в кольцевом буфере */
#define App_CircBuff_Inc_Bytes(position, buffersize, bytecount)	(position = (position + bytecount) % (buffersize))	/*!< Получение позиции, сдвинутой на incbytes в кольцевом буфере */
#define App_CircBuff_Dec(position, buffersize)	(position = (position + buffersize - 1) % (buffersize))	/*!< Получение предыдущей позиции в кольцевом буфере */
#define App_CircBuff_Dec_Bytes(position, buffersize, bytecount)	(position = (position + buffersize - bytecount) % (buffersize))	/*!< Получение предыдущей позиции в кольцевом буфере */
#define App_CircBuff_GetDataSize(start, end, buffersize)	((end >= start) ? (end - start) : (buffersize - start + end))	/*!< Получение размера данных по началу и концу данных в буфере */
#define App_Interval_Intersection(int1start, int1end, int2start, int2end)	((((int1start) >= (int2start)) && ((int1start) <= (int2end)))\
																				|| (((int1end) >= (int2start)) && ((int1end) <= (int2end)))\
																				|| (((int1start) < (int2start)) && ((int1end) > (int2end))))	/*!< Определение пересечения интервалов */
#define App_Is_Digit(x)							(((x >= APP_PRINT_CHAR_0) && (x <= APP_PRINT_CHAR_9)) ? APP_TRUE : APP_FALSE)	/*!< Является ли символ цифрой */
#define App_Is_Digit_Or_Neg_Sign(x)				((((x >= APP_PRINT_CHAR_0) && (x <= APP_PRINT_CHAR_9)) || (x == APP_PRINT_CHAR_MINUS)) ? APP_TRUE : APP_FALSE)	/*!< Является ли символ цифрой или знаком "-" */
#define App_Is_Digit_Or_Pos_Sign(x)				((((x >= APP_PRINT_CHAR_0) && (x <= APP_PRINT_CHAR_9)) || (x == APP_PRINT_CHAR_PLUS)) ? APP_TRUE : APP_FALSE)	/*!< Является ли символ цифрой или знаком "+" */
#define App_Is_Digit_Or_Sign(x)					((((x >= APP_PRINT_CHAR_0) && (x <= APP_PRINT_CHAR_9)) || (x == APP_PRINT_CHAR_MINUS) || (x == APP_PRINT_CHAR_PLUS)) ? APP_TRUE : APP_FALSE)	/*!< Является ли символ цифрой или знаками "+", "-" */
/**
  * @}
  */

/** @defgroup	App_Exported_Macro_Group2
  *				Exported Macro Group 2
  * @brief		Прочие макросы
  * @{
  */
#define App_UpdateWakeUpTime(CurrentTime, LastActionTime, ActionInterval, NextTaskTime, NextWakeupTime) ({\
			NextTaskTime = LastActionTime + ActionInterval;\
			if ((NextTaskTime > CurrentTime) && (NextTaskTime < NextWakeupTime)) NextWakeupTime = uwNextTaskTime;\
		   })
/**
  * @}
  */

/**
  * @}
  */

/* Exported constants --------------------------------------------------------*/
/** @defgroup	App_Exported_Constants
  *				Exported Constants
  * @brief		Экспортируемые константы
  * @{
  */

/** @defgroup	App_Exported_Constants_Group1
  *				Exported Constants Group 1
  * @brief		Основные константы
  * @{
  */
#define APP_TRUE								1		/*!< True */
#define APP_FALSE								0		/*!< False */
/**
  * @}
  */

/** @defgroup	App_Exported_Constants_Group2
  *				Exported Constants Group 2
  * @brief		Формат вывода сообщений отладки
  * @{
  */
#define APP_PRINT_VERBOSITY_MASK				0xFF	/*!< Маска подробности вывода сообщений отладки */
#define APP_PRINT_FORMAT_MSG					"%lu\t%s\r\n"	/*!< Формат вывода сообщений отладки */
#define APP_PRINT_FORMAT_MSG_NOTIME				"%s\r\n"	/*!< Формат вывода сообщений отладки */
#define APP_PRINT_FORMAT_MSG_START				"%lu\t"		/*!< Формат вывода начала сообщений отладки */
#define APP_PRINT_FORMAT_START_SOURCE			"%lu\t%s\t"	/*!< Формат вывода начала сообщений отладки с указанием источника */
#define APP_PRINT_FORMAT_MSG_SOURCE				"%lu\t%s\t%s\r\n"	/*!< Формат вывода сообщений отладки с указанием источника */
#define APP_PRINT_FORMAT_MSG_SOURCE_STR			"%lu\t%s\t%s %s\r\n"	/*!< Формат вывода сообщений отладки с указанием источника и значения */
#define APP_PRINT_FORMAT_MSG_ERROR				"%lu\tError @ file\t%s\tline\t%u\r\n"	/*!< Формат вывода сообщений об ошибке */
#define APP_PRINT_FORMAT_MSG_ERROR_BARE			"Error @ file\t%s\tline\t%u"	/*!< Формат вывода сообщений об ошибке без оформления */
#define APP_PRINT_FORMAT_REQ_RESP				"%s %s"		/*!< Формат сообщения запроса/ответа */
#define APP_PRINT_FORMAT_RESTART				"%lu\tRestarting in %hu seconds...\r\n"	/*!< Перезапуск через x секунд */
#define APP_PRINT_FORMAT_HEX					"0x%02hX "	/*!< Формат вывода данных в HEX */
#define APP_PRINT_FORMAT_DATE					"%02hu/%02hu/%04hd"	/*!< Формат вывода даты */
#define APP_PRINT_FORMAT_TIME					"%02hu:%02hu:%02hu"	/*!< Формат вывода времени */
#define APP_PRINT_FORMAT_GEO					"Lat:\t%lu\tLon:\t%lu"	/*!< Формат вывода координат, float */
#define APP_PRINT_FORMAT_GEO_F					"Lat:\t%.3f\tLon:\t%.3f"	/*!< Формат вывода координат, float */
/**
  * @}
  */

/** @defgroup	App_Exported_Constants_Group3
  *				Exported Constants Group 3
  * @brief		Стандартные сообщения отладки
  * @{
  */
#define APP_PRINT_CHAR_NULL						'\0'	/*!< Окончание строки */
#define APP_PRINT_CHAR_MINUS					'-'		/*!< Минус */
#define APP_PRINT_CHAR_PLUS						'+'		/*!< Плюс */
#define APP_PRINT_CHAR_SPACE					' '		/*!< Пробел */
#define APP_PRINT_CHAR_0						'0'		/*!< 0 */
#define APP_PRINT_CHAR_9						'9'		/*!< 9 */
#define APP_PRINT_LINE_DELIMITER				"\r\n"	/*!< Разделитель строк */
#define APP_PRINT_CR							"\r"	/*!< CR */
#define APP_PRINT_LF							"\n"	/*!< LF */
#define APP_PRINT_TAB							"\t"	/*!< Tab */
#define APP_PRINT_SPACE							" "		/*!< Space */
#define APP_PRINT_ARROW							"->"	/*!< -> */
#define APP_PRINT_MSG_ENABLED					"Enabled"	/*!< Enabled */
#define APP_PRINT_MSG_DISABLED					"Disabled"	/*!< Enabled */
#define APP_PRINT_MSG_TASK_STARTED				"Task started"	/*!< Сообщение о запуске задачи */
#define APP_PRINT_MSG_TASK_SUSPENDED			"Task suspended"	/*!< Сообщение об остановке задачи */
#define APP_PRINT_MSG_REQUEST					"Request"	/*!< Запрос */
#define APP_PRINT_MSG_RESPONSE					"Response"	/*!< Ответ */
#define APP_PRINT_MSG_COMMAND					"Command"	/*!< Команда */
#define APP_PRINT_MSG_SENT						"Sent"		/*!< Отправлен */
#define APP_PRINT_MSG_SENDING					"Sending"	/*!< Отправка */
#define APP_PRINT_MSG_RESENT					"Resent"	/*!< Повторная отправка */
#define APP_PRINT_MSG_RECEIVED					"Received"	/*!< Получен */
#define APP_PRINT_MSG_ERROR						"Error"		/*!< Ошибка */
#define APP_PRINT_MSG_COMM_OK					"Comm OK"	/*!< Есть связь */
#define APP_PRINT_MSG_COMM_CHECK				"Comm check..."	/*!< Проверка связи */
#define APP_PRINT_MSG_COMM_ERROR				"Comm error"	/*!< Ошибка связи */
#define APP_PRINT_MSG_COMM_ERROR_RESTART		"Comm error limit -> restart interface & board..."	/*!< Ошибка связи с платой -> перезапуск интерфейса и платы */
#define APP_PRINT_MSG_COMM_FAILURE				"Comm failure"	/*!< Связь как-то не задалась... */
#define APP_PRINT_MSG_REQUEST_TIMEOUT			"Request timeout"	/*!< Таймаут запроса */
#define APP_PRINT_MSG_SLEEP						"Sleep"		/*!< Сон */
#define APP_PRINT_MSG_COMM_NO_RESP				"No/bad response"	/*!< Нет ответа */
#define APP_PRINT_MSG_COMM_RESP_PROC_ERROR		"Error processing response"	/*!< Ошибка при обработке ответа */
#define APP_PRINT_MSG_INTERFACE					"Interface"	/*!< Интерфейс */
#define APP_PRINT_MSG_INTERFACE_ERROR			"Interface error"	/*!< Ошибка интерфейса */
#define APP_PRINT_MSG_INTERFACE_TIMEOUT			"Interface timeout"	/*!< Таймаут интерфейса */
#define APP_PRINT_MSG_INTERFACE_FIFO_FULL		"Interface FIFO full"	/*!< Переполнение буфера FIFO интерфейса */
#define APP_PRINT_MSG_INTERFACE_ERROR_LIMIT		"Interface error limit"	/*!< Ошибка интерфейса -> перезапуск */
#define APP_PRINT_MSG_INTERFACE_RESTART			"Restart interface"
#define APP_PRINT_MSG_INTERFACE_RESTARTED		"Interface restarted"	/*!< Перезапуск интерфейса */
#define APP_PRINT_MSG_INTERFACE_FORCE_RESTART	"Interface forced restart"	/*!< Принудительный перезапуск интерфейса */
#define APP_PRINT_MSG_UNKNOWN					"Unknown"	/*!< Unkwnown */
#define APP_PRINT_MSG_OK						"OK"	/*!< OK */
#define APP_PRINT_MSG_NOK						"NOK"	/*!< NOK (= NOT OK) */
#define APP_PRINT_MSG_FAILED					"FAILED"	/*!< FAILED */
#define APP_PRINT_MSG_ON						"ON"	/*!< ON */
#define APP_PRINT_MSG_OFF						"OFF"	/*!< OFF */
#define APP_PRINT_MSG_LOW						"LOW"	/*!< LOW */
#define APP_PRINT_MSG_HIGH						"HIGH"	/*!< HIGH */
#define APP_PRINT_MSG_TX						"TX"	/*!< TX */
#define APP_PRINT_MSG_RX						"RX"	/*!< RX */
#define APP_PRINT_MSG_REQ						"REQ"	/*!< Запрос */
#define APP_PRINT_MSG_RESP						"RESP"	/*!< Ответ */
#define APP_PRINT_MSG_PACKET					"Packet"	/*!< Пакет */
#define APP_PRINT_MSG_WRONG_PACKET_SIZE			"Wrong packet size: %hu"	/*!< Неправильный размер пакета */
#define APP_PRINT_MSG_RTC						"RTC"	/*!< RTC */
#define APP_PRINT_MSG_SYS_TIME					"Sys time"	/*!< System time */
#define APP_PRINT_MSG_TIME_SYNC					"time sync"	/*!< Time sync */
#define APP_PRINT_MSG_UTC						"UTC"	/*!< UTC */
#define APP_PRINT_MSG_CURRENT					"Current"	/*!< Current */
#define APP_PRINT_MSG_NEW						"New"	/*!< New */
#define APP_PRINT_MSG_DEV_CFG					"dev cfg"	/*!< dev cfg */
/**
  * @}
  */

/** @defgroup	App_Exported_Constants_Group4
  *				Exported Constants Group 4
  * @brief		Настройки выделения памяти
  * @{
  */
#define APP_BUFFER_FILL_CHAR					0x00		/*!< Символ для заполнения (стирания) буфера */
#define APP_BUFFER_ALIGN_SIZE					8			/*!< Выравнивание буферов, байт */
/**
  * @}
  */

/** @defgroup	App_Exported_Constants_Group5
  *				Exported Constants Group 5
  * @brief		Настройки операционной системы
  * @{
  */
#define APP_OS_STRUCT_SIZE_QUEUE				76			/*!< Размер структуры очереди (приблизительный) */
#define APP_OS_STRUCT_SIZE_TASK					96			/*!< Размер структуры задачи (приблизительный) */
#define APP_OS_TIMEOUT_TASK_SHORT				1			/*!< Минимальный таймаут задачи */
#define APP_OS_TIMEOUT_TASK_MEDIUM				10			/*!< Средний таймаут задачи */
#define APP_OS_TIMEOUT_TASK_LONG				100			/*!< Длинный таймаут задачи */
#define APP_OS_TIMEOUT_TASK_SLEEP				1000		/*!< Таймаут простаивающей задачи */
#define APP_OS_TIMEOUT_TRANSFER_ABORT			100			/*!< Таймаут отмены обмена данными */
#define APP_OS_FLAG_WAIT_STEP					APP_OS_TIMEOUT_TASK_SHORT	/*!< Шаг ожидания изменения флага (в отсчетах системного счетчика) */
#define APP_OS_TIMEOUT_TRANSFER_BASE			10			/*!< Базовый таймаут обмена данными */
#define APP_OS_TIMEOUT_TRANSFER_MAX				1000		/*!< Таймаут передачи данных */
#define APP_OS_TASK_ARRAY_RESIZE_STEP			2			/*!< Шаг изменения массива списка задач */
/**
  * @}
  */

/**
  * @}
  */

/* Exported types ------------------------------------------------------------*/
/** @defgroup	App_Exported_Types
  *				Exported Types
  * @brief		Экспортируемые типы
  * @{
  */

/** @defgroup	App_Exported_Enumerated_Types
  *				Exported Enumerated Types
  * @brief		Экспортируемые перечисляемые типы
  * @{
  */

/** @defgroup	App_Status_Enum_Definition
  *				Status Enum Definition
  * @brief		Список возвращаемых кодов (клон статуса ошибок STM32 HAL/Component)
  * @{
  */
typedef enum AppStatus_Enum {
	APP_OK										= 0x00U,	/*!< Нет ошибок */
	APP_ERROR									= 0x01U,	/*!< Есть ошибка(-и) */
	APP_BUSY									= 0x02U,	/*!< Приложение занято */
	APP_TIMEOUT									= 0x03U,	/*!< Таймаут */
	APP_NOT_IMPLEMENTED							= 0x04U,	/*!< Функция не поддерживается */
} AppStatus_t;
/**
  * @}
  */

/** @defgroup	App_State_List_Enum_Definition
  * 			State List Enum Definition
  * @brief		Список состояний элементов приложения
  * @{
  */
typedef enum App_State_List_Enum {
	APP_STATE_NONE								= 0x00000000U,		/*!< Состояние не определено */
	APP_STATE_INITIALIZED						= 0x00000001U,		/*!< Элемент инициализирован */
	APP_STATE_ACTIVE							= 0x00000002U,		/*!< Элемент активен */
	APP_STATE_ENABLED							= 0x00000004U,		/*!< Элемент включен */
	APP_STATE_CHANGED							= 0x00000008U,		/*!< Элемент изменился */
	APP_STATE_UPDATED							= 0x00000010U,		/*!< Элемент обновился */
	APP_STATE_BUSY								= 0x00000020U,		/*!< Элемент занят :) */
	APP_STATE_ERROR								= 0x00008000U,		/*!< Ошибка */
} App_State_List_t;
/**
  * @}
  */

/** @defgroup	App_Print_Verbosity_List_Enum_Definition
  *				Print Verbosity List Enum Definition
  * @brief		Список уровней подробности вывода сообщений отладки
  * @{
  */
typedef enum App_Print_Verbosity_List_Enum {
	APP_PRINT_VERBOSITY_LEVEL_CRITICAL			= 0x01,		/*!< Всегда выводить сообщения (например, ошибки) */
	APP_PRINT_VERBOSITY_LEVEL_NORMAL			= 0x02,		/*!< Обычные сообщения */
	APP_PRINT_VERBOSITY_LEVEL_INFO				= 0x04,		/*!< Информационные сообщения */
	APP_PRINT_VERBOSITY_LEVEL_MISC_INFO			= 0x08,		/*!< Прочие информационные сообщения */
	APP_PRINT_VERBOSITY_LEVEL_SPAM				= 0x10,		/*!< Спам */
} App_Print_Verbosity_List_t;
/**
  * @}
  */

/** @defgroup	App_Print_Param_List_Enum_Definition
  *				App Print Param List Enum Definition
  * @brief		Параметры вывода сообщений отладки
  * @{
  */
typedef enum App_Print_Param_List_Enum {
	APP_PRINT_PARAM_NONE						= 0x0000,	/*!< Параметры не установлены */
	APP_PRINT_PARAM_RAW							= 0x0100,	/*!< Прямой вывод (без дополнительной обработки) */
	APP_PRINT_PARAM_HEX							= 0x0200,	/*!< Выводить данные в HEX */
	APP_PRINT_PARAM_NO_DELIM					= 0x0400,	/*!< Не выводить разделитель строк */
} App_Print_Param_t;
/**
  * @}
  */

/** @defgroup	App_Module_Mode_List_Enum_Definition
  *				Module Mode List Enum Definition
  * @brief		Список режимов работы частей приложения
  * @{
  */
typedef enum App_Module_Mode_List_Enum {
	APP_MODULE_MODE_AUTONOMOUS					= 0,		/*!< Автономный режим */
	APP_MODULE_MODE_COMPONENT,								/*!< Элемент структуры */
} App_Module_Mode_t;
/**
  * @}
  */

/** @defgroup	App_OS_Signal_List_Enum_Definition
  *				OS Signal List Enum definition
  * @brief		Список сигналов ОС
  * @{
  */
typedef enum App_OS_Signal_List_Enum {
	APP_OS_SIGNAL_NONE							= 0x00000000U,	/*!< Пустой сигнал ОС (для пропуска очистки текущего состояния флагов) */
	APP_OS_SIGNAL_TRANSFER_START				= 0x00000001U,	/*!< Начало передачи данных по интерфейсу */
	APP_OS_SIGNAL_TRANSFER_STOP					= 0x00000002U,	/*!< Конец передачи данных по интерфейсу */
	APP_OS_SIGNAL_TRANSFER_RESTART				= 0x00000004U,	/*!< Перезапуск передачи данных по интерфейсу */
	APP_OS_SIGNAL_TRANSFER_ABORTED				= 0x00000008U,	/*!< Отправка/получение данных по интерфейсу отменена */
	APP_OS_SIGNAL_TRANSFER_ERROR				= 0x00000010U,	/*!< Ошибка передачи */
	APP_OS_SIGNAL_TRANSFER_TIMEOUT				= 0x00000020U,	/*!< Ошибка передачи */
	APP_OS_SIGNAL_TRANSFER_RX_COMPLETE			= 0x00000040U,	/*!< Получение данных по интерфейсу завершено */
	APP_OS_SIGNAL_TRANSFER_RX_HALFCOMPLETE		= 0x00000080U,	/*!< Получение половины данных по интерфейсу завершено */
	APP_OS_SIGNAL_TRANSFER_TX_COMPLETE			= 0x00000100U,	/*!< Отправка данных по интерфейсу завершена */
	APP_OS_SIGNAL_TRANSFER_TX_HALFCOMPLETE		= 0x00000200U,	/*!< Отправка половины данных по интерфейсу завершена */
	APP_OS_SIGNAL_TRANSFER_FIFO_FULL			= 0x00000400U,	/*!< Буфер FIFO заполнен */
	APP_OS_SIGNAL_INTERRUPT_TRIGGERED			= 0x00001000U,	/*!< Сработало прерывание */
	APP_OS_SIGNAL_TIMER_TRIGGERED				= 0x00002000U,	/*!< Сработал таймер */
	APP_OS_SIGNAL_ADC_CONV_COMPLETE				= 0x00004000U,	/*!< АЦП прочитал все данные */
	APP_OS_SIGNAL_ADC_CONV_HALFCOMPLETE			= 0x00008000U,	/*!< АЦП прочитал половину данных */
	APP_OS_SIGNAL_COMM_REQUEST_RECEIVED			= 0x00100000U,	/*!< Получен запрос */
	APP_OS_SIGNAL_COMM_RESPONSE_RECEIVED		= 0x00200000U,	/*!< Получен ответ */
	APP_OS_SIGNAL_COMM_NOTIFICATION_RECEIVED	= 0x00400000U,	/*!< Получено опоевещение (не требует ответа) */
	APP_OS_SIGNAL_COMM_NOTIFICATION_SENT		= 0x00800000U,	/*!< Отправлено опоевещение (не требует ответа) */
	APP_OS_SIGNAL_POWER_MODE_CHANGED			= 0x10000000U,	/*!< Изменился режим энергопотребления */
	APP_OS_SIGNAL_ALL							= 0xFFFFFFFFU,	/*!< Все сигналы */
} App_OS_Signal_List_t;
/**
  * @}
  */

/**
  * @}
  */

/** @defgroup	App_Exported_Function_Typedefs
  *				Exported Function Typedefs
  * @brief		Экспортируемые типы функций
  * @{
  */
typedef int32_t (*App_Base_Function_t)(void*);			/*!< Формат обычной функции приложения */
typedef int32_t (*App_Extended_Function_t)(void*, void*);	/*!< Формат расширенной функции приложения */
typedef void (*App_Task_Function_t)(void*);					/*!< Формат функции задачи (ОС) */
typedef void (*App_Scheduler_Task_Function_t)(void*, void*);	/*!< Формат функции задачи планировщика */
/**
  * @}
  */

/** @defgroup	App_Exported_Structures
  *				Exported Structures
  * @brief		Экспортируемые структуры
  * @{
  */

/**
  * @}
  */

/**
  * @}
  */

/* Exported variables --------------------------------------------------------*/
/** @addtogroup App_Exported_Variables
  *				Exported Variables
  * @brief		Экспортируемые переменные
  * @{
  */

/**
  * @}
  */

/* Exported functions --------------------------------------------------------*/
/** @addtogroup App_Exported_Functions
  *				Exported Functions
  * @brief		Экспортируемые функции
  * @{
  */

/**
  * @}
  */

/**
  * @}
  */

#ifdef __cplusplus
}
#endif

#endif /* __APP_DEFS_H_ */

/**************** (C) COPYRIGHT 2018-2019 Max Egorov ***********END OF FILE****/
