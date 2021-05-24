/**
 *******************************************************************************
 * @file    stand_defs.h
 * @author  Максим Егоров
 * @version V1.0.0
 * @date    19 Декабря 2019
 * @brief   Общие типы и константы для тестового стенда
 *******************************************************************************
 *
 * <h2><center>&copy; COPYRIGHT(c) 2019 Max Egorov</center></h2>
 *
 * @attention Not to be copied/redistributed without author's permission
 *
 * Описание работы
 * ---------------
 *   Данное устройство предназначено для тестирования аналоговых, дискретных
 * входов и входов таймеров на платах АС КРСПС, работа с устройством
 * осуществляется с использованием протокола ModBus RTU.
 *   Информация об устройстве (количество выходов, параметры аналоговых выходов,
 * длина последовательности установки значений, текущее состояние выходов) могут быть
 * прочитаны из регистров Input Registers (см. далее подробнее), а параметры
 * тестирования и устанавливыемые состояния выходов записываются в Holding Registers.
 *   При тестировании возможны выбор из трех режимов работы:
 * 1. STAND_MODE_DISABLE_OUTPUTS - все выходы отключены
 * 2. STAND_MODE_SET_VALUE - Единичная установка значений (устанавливаются значения
 *    на выходах, значения после этого не изменяются до тех пор, пока не будут
 *    изменены соответствующие регистры или пока не изменится режим работы).
 * 3. STAND_MODE_SEQUENCE - Установка последовательности значений (значения на
 *    выходах изменяются через определенные временные интервалы, последовательность
 *    может повторяться). При установке этого режима начинает устанавливаться заданная
 *    заранее последовательность значений (если она была записана).
 *
 *   Последовательность работы с устройством:
 * 1. Подключение к устройству (запрос параметров устройства)
 * 2. Установка требуемых параметров (длина последовательности установки значений,
 *    пауза, сама последовательность установки значений и т.п.)
 * 2. Выбор режима работы
 * 4. При необходимости отключение выходов, измение режимов работы и т.п.
 *
 *  При этом записанные значения проверяются устройством на правильность,
 * устанавливаются и после этого текущее состояние выходов записывается в регистры
 * Input Registers.
 *
 * Параметры стенда
 * ----------------
 * Все используемые значения - в LSB.
 *
 *   Параметры одинаковы как для платы с аналоговыми выходами, так и для платы
 * с дискретными выходами + таймерами. Количество и параметры доступных выходов
 * могут быть прочитаны из структуры Stand_Outputs_Info_t, расположенной по
 * адресу STAND_MODBUS_ADDRESS_IR_OUTPUTS_INFO (Input Registers).
 * Устанавливаемые параметры задаются в структуре Stand_Outputs_Config_t,
 * расположенной по адресу STAND_MODBUS_ADDRESS_HR_OUTPUTS_CONFIG (Holding
 * Registers). В случае отсутствия тех или иных выходов соответствующие им
 * регистры установки значений или последовательности установки значений не
 * будут доступны (т.е., например, при отсутствии аналоговых выходов регистры
 * по адресу STAND_MODBUS_ADDRESS_HR_AO и далее будут недоступны).
 *
 *   При нулевых значениях (состояние дискретных выходов, напряжение для
 * аналоговых выходов, частота для выходов таймера) соответствующие выходы
 * отключаются. При изменении значения со стороны стенда (уменьшение количество
 * циклов последовательности, значения выходов) значения в соответствующих
 * регистрах должны изменяться.
 *
 * Чтение текущих значений и установка значений
 * --------------------------------------------
 * Текущие значения могут быть прочитаны из регистров Input Registers по
 * адресам:
 * STAND_MODBUS_ADDRESS_IR_DO - для дискретных выходов
 * STAND_MODBUS_ADDRESS_IR_AO - для аналоговых выходов
 * STAND_MODBUS_ADDRESS_IR_TIM - для выходов таймеров
 *
 * В режиме STAND_MODE_SET_VALUE устанавливаемые значения записываются
 * в регистры Holding Registers по адресам:
 * STAND_MODBUS_ADDRESS_HR_DO - для дискретных выходов
 * STAND_MODBUS_ADDRESS_HR_AO - для аналоговых выходов
 * STAND_MODBUS_ADDRESS_HR_TIM - для выходов таймеров
 *
 * Формат значений:
 *
 * 1. Для дискретных выходов:
 * <n*MODBUS_BASE_TYPE_SIZE>
 * Где n может быть рассчитано макросом App_Bits_To_Bytes_N(OutputCountDiscrete, 16)
 * MODBUS_BASE_TYPE_SIZE = sizeof(uint16_t) - т.е. размер одного регистра
 * типа (Analogue) Input или Holding.
 *
 * 1 выход = 1 биту (начиная с младшего бита), при этом значения занимают
 * не меньше 1 регистра (т.е. при 1-16 выходах используется один регистр,
 * при 17-32 - два регистра (во втором регистре - значения выходов 17-32)
 * и т.д., значения, не соответствующие выходам, игнорируются - т.е. при 1
 * выходе используется только первый бит, остальные игнорируются).
 *
 * Например, для 16 выходов:
 * <0xFFFF>
 * Т.е. все выходы включены.
 *
 * 2. Для аналоговых выходов:
 * <OutputCountAnalogue*STAND_VOLTAGE_VALUE_SIZE>
 *
 * Например, для 2 выходов:
 * <0x3333><0x5340><0x0000><0x2041>
 *
 * Т.е. 3.3 В на первом канале, 10 В - на втором канале.
 *
 * 3. Для выходов таймеров:
 * <OutputCountTimer*(STAND_TIMER_FREQUENCY_VALUE_SIZE + STAND_TIMER_DUTY_VALUE_SIZE)>
 *
 * Например, для 2 выходов:
 * <0x03E8><0x1388><0x03E8><0x1388>
 *
 * Т.е. частота 1000 Гц, D = 50% на обоих выходах.
 *
 * Формат последовательности установки значений
 * --------------------------------------------
 * Общий формат - <массив значений (размер = количество выходов)><задержка>
 * (повторяется далее SequenceLen раз)
 *
 * Формат значений:
 *
 * 1. Для дискретных выходов:
 * <n*MODBUS_BASE_TYPE_SIZE><STAND_DELAY_VALUE_SIZE>
 * Где n может быть рассчитано макросом App_Bits_To_Bytes_N(OutputCountDiscrete, 16)
 *
 * Например, для 16 выходов последовательность длиной = 3 может быть такой:
 * <0xFFFF><0x03E8><0x0000><0x0000><0x03E8><0x0000><0xFFFF><0x03E8><0x0000>
 * Т.е. включить 16 выходов, пауза 1 сек, выключить 16 выходов, пауза 1 сек
 *
 * 2. Для аналоговых выходов:
 * <OutputCountAnalogue*STAND_VOLTAGE_VALUE_SIZE><STAND_DELAY_VALUE_SIZE>
 *
 * Например, для 2 выходов последовательность длиной = 2 может быть такой:
 * <0x0000><0x2041><0x0000><0x2041><0x03E8><0x0000><0x3333><0x5340><0x3333><0x5340><0x03E8><0x0000>
 *
 * Т.е. установить сначала 10 В на обоих каналах, а затем через 1 сек 3.3 В
 * на обоих каналах.
 *
 * 3. Для выходов таймеров:
 * <OutputCountTimer*(STAND_TIMER_FREQUENCY_VALUE_SIZE + STAND_TIMER_DUTY_VALUE_SIZE)><STAND_DELAY_VALUE_SIZE>
 *
 * Например, для 2 выходов последовательность длиной = 2:
 * <0x05DC><0x1388><0x05DC><0x1388><0x7530><0x0000><0x0320><0x1388><0x0320><0x1388><0x7530><0x0000>
 *
 * Т.е. установить сначала частоту 1500 Гц, D = 50% на обоих выходах, пауза 30 сек,
 * установить частоту 800 Гц, D = 50% на обоих выходах.
 *
 *
 * История изменений:
 * ------------------
 *
 * Дата       |Версия | Изменения                                | Автор
 * -----------|-------|------------------------------------------|--------------
 * 19.12.2019 | 1.0.0 | Начальная версия                         | Максим Егоров
 *
 *******************************************************************************
 */

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __STAND_DEFS_H_
#define __STAND_DEFS_H_

#ifdef __cplusplus
extern "C" {
#endif

/* Includes ------------------------------------------------------------------*/
#include <stdint.h>

/** @addtogroup Stand
  * @brief		Общие типы и константы для тестового стенда
  * @{
  */

/* Exported macro ------------------------------------------------------------*/
/** @defgroup	Stand_Exported_Macro
  *				Exported Macro
  * @brief		Экспортируемые макросы
  * @{
  */

/**
  * @}
  */

/* Exported constants --------------------------------------------------------*/
/** @defgroup	Stand_Exported_Constants
  *				Exported Constants
  * @brief		Экспортируемые константы
  * @{
  */

/** @defgroup	Stand_Exported_Constants_Group1
  *				Exported Constants Group 1
  * @brief		Настройки тестирования
  * @{
  */
#define STAND_DISCRETE_SEQ_LEN_DEFAULT			256			/*!< Длина последовательности изменения дискретных выходов по умолчанию */
#define STAND_ANALOGUE_SEQ_LEN_DEFAULT			256			/*!< Длина последовательности изменения аналоговых выходов по умолчанию */
#define STAND_TIMER_SEQ_LEN_DEFAULT				256			/*!< Длина последовательности изменения выходов таймеров по умолчанию */
#define STAND_VOLTAGE_VALUE_SIZE				(sizeof(float))	/*!< Размер значения напряжения */
#define STAND_TIMER_FREQUENCY_VALUE_SIZE		(sizeof(uint16_t))	/*!< Размер значения частоты таймера */
#define STAND_TIMER_DUTY_VALUE_SIZE				(sizeof(uint16_t))	/*!< Размер значения коэффициента заполнения таймера (в 0.01%, т.е. 1% = 100) */
#define STAND_DELAY_VALUE_SIZE					(sizeof(uint32_t))	/*!< Размер значения задержки */
#define STAND_TIMER_COUNT_VALUE_SIZE			(sizeof(uint16_t))	/*!< Размер значения количества таймеров */

/// changed by Iurinova O.M.

#define MODBUS_BASE_TYPE_SIZE sizeof(uint16_t)
#define Set_Bit(value, bitNum)  value |= (1 << bitNum)
#define UnSet_Bit(value, bitNum)  value &= ~(1 << bitNum)
#define Check_Bit(value, bitNum)  (value & (1 << bitNum)? true : false)
#include "time.h"

///end of changes
/**
  * @}
  */

/** @defgroup	Stand_Exported_Constants_Group2
  *				Exported Constants Group 2
  * @brief		Параметры ModBus
  * @{
  */
#define STAND_MODBUS_ADDRESS_IR_OUTPUTS_INFO	0x2000		/*!< IR Начальный адрес информации о выходах */
#define STAND_MODBUS_ADDRESS_IR_DO				0x2100		/*!< IR Начальный адрес состояния дискретных выходов */
#define STAND_MODBUS_ADDRESS_IR_AO				0x2200		/*!< IR Начальный адрес состояния аналоговых выходов */
#define STAND_MODBUS_ADDRESS_IR_TIM				0x2300		/*!< IR Начальный адрес состояния выходов таймеров */
// chasynged 03.06.2020
#define STAND_MODBUS_ADDRESS_HR_OUTPUTS_CONFIG_DO	0x1900		/*!< HR Начальный адрес конфигурации дискретных выходов */
#define STAND_MODBUS_ADDRESS_HR_OUTPUTS_CONFIG_AO	0x1907		/*!< HR Начальный адрес конфигурации аналоговых выходов */
//
#define STAND_MODBUS_ADDRESS_HR_TIMER_OUTPUTS_CONFIG	0x190E		/*!< HR Начальный адрес конфигурации выходов ТАЙМЕРА   */
#define STAND_MODBUS_ADDRESS_OFFSET_SEQ			0x0100		/*!< HR Смещение последовательности установки значений дискретных выходов */
#define STAND_MODBUS_ADDRESS_HR_DO				0x2000		/*!< HR Начальный адрес значений для дискретных выходов */
#define STAND_MODBUS_ADDRESS_HR_AO				0x3000		/*!< HR Начальный адрес значений для аналоговых выходов */
#define STAND_MODBUS_ADDRESS_HR_TIM				0x4000		/*!< HR Начальный адрес значений для выходов таймеров */
#define STAND_MODBUS_ADDRESS_HR_SEQ_DO			(STAND_MODBUS_ADDRESS_HR_DO + STAND_MODBUS_ADDRESS_OFFSET_SEQ)		/*!< HR Начальный адрес последовательности установки значений для дискретных выходов */
#define STAND_MODBUS_ADDRESS_HR_SEQ_AO			(STAND_MODBUS_ADDRESS_HR_AO + STAND_MODBUS_ADDRESS_OFFSET_SEQ)		/*!< HR Начальный адрес последовательности установки значений для дискретных выходов */
#define STAND_MODBUS_ADDRESS_HR_SEQ_TIM			(STAND_MODBUS_ADDRESS_HR_TIM + STAND_MODBUS_ADDRESS_OFFSET_SEQ)		/*!< HR Начальный адрес последовательности установки значений для выходов таймеров */
/**
  * @}
  */

/** @defgroup	Stand_Exported_Constants_Group3
  *				Exported Constants Group 3
  * @brief		Настройки тестирования
  * @{
  */
#define STAND_DISCRETE_OUTPUTS_COUNT			32			/*!< Количество дискретных выходов на стенде */
#define STAND_DISCRETE_OUTPUTS_DATA_SIZE		(STAND_DISCRETE_OUTPUTS_COUNT / 8)	/*!< Длина данных дискретных выходов (NB: кратно 8 или исправляем вручную) */
#define STAND_ANALOGUE_OUTPUTS_COUNT			12			/*!< Количество аналоговых выходов на стенде */
#define STAND_TIMER_OUTPUTS_COUNT				4			/*!< Количество выходов таймера на стенде */
/**
  * @}
  */

/**
  * @}
  */

/* Exported types ------------------------------------------------------------*/
/** @defgroup	Stand_Exported_Types
  *				Exported Types
  * @brief		Экспортируемые типы
  * @{
  */

/** @defgroup	Stand_Exported_Function_Types
  *				Exported Function Types
  * @brief		Экспортируемые типы функций
  * @{
  */

/**
  * @}
  */

/** @defgroup	Stand_Exported_Enumerated_Types
  *				Exported Enumerated Types
  * @brief		Экспортируемые перечисляемые типы
  * @{
  */

/** @defgroup	Stand_Mode_Param_Enum_Definition
  * 			Test Mode Param Enum Definition
  * @brief		Режим тестирования
  * @{
  */
typedef enum Stand_Mode_Enum {
	STAND_MODE_DISABLE_OUTPUTS					= 0x0000,	/*!< Выходы отключены (по умолчанию) */
	STAND_MODE_SET_VALUE						= 0x0001,	/*!< Установка значения */
	STAND_MODE_SEQUENCE							= 0x0002,	/*!< Последовательность установки значений */
} Stand_Mode_t;
/**
  * @}
  */

/**
  * @}
  */

/** @defgroup	Stand_Exported_Structures
  * 			Exported Structures
  * @brief		Экспортируемые структуры
  * @{
  */

/** @defgroup	Stand_Outputs_Mode_Config_Structure_Definition
  *				Outputs Mode Config Structure Definition
  * @brief		Конфигурация работы выходов стенда
  * @{
  */
typedef struct __attribute__ ((__packed__)) Stand_Outputs_Mode_Config_Struct {
	uint16_t Mode;											/*!< Режим работы (STAND_MODE_t) */
	uint16_t SequenceLen;									/*!< Длина последовательности (для режима STAND_MODE_SEQUENCE) */
	uint16_t SequenceRepeat;								/*!< Количество повторов (для режима STAND_MODE_SEQUENCE) */
	uint32_t SequencePause;									/*!< Пауза между повторами (для режима STAND_MODE_SEQUENCE) */
} Stand_Outputs_Mode_Config_t;
/**
  * @}
  */

/** @defgroup	Stand_Outputs_Info_Structure_Definition
  *				Outputs Info Structure Definition
  * @brief		Информация о доступных выходах
  * @{
  */
typedef struct __attribute__ ((__packed__)) Stand_Outputs_Info_Struct {
	uint16_t OutputCountDiscrete;							/*!< Количество дискретных выходов */
	uint16_t OutputCountAnalogue;							/*!< Количество аналоговых выходов */
	uint16_t OutputCountTimer;								/*!< Количество выходов таймеров */
	uint16_t SequenceLenDiscrete;							/*!< Максимальная длина последовательности для дискретных выходов */
	uint16_t SequenceLenAnalogue;							/*!< Максимальная длина последовательности для аналоговых выходов */
	uint16_t SequenceLenTimer;								/*!< Максимальная длина последовательности для выходов таймеров */
	float AnalogueRangeMin;									/*!< Минимальное значение напряжения */
	float AnalogueRangeMax;									/*!< Максимальное значение напряжения */
} Stand_Outputs_Info_t;
/**
  * @}
  */

/** @defgroup	Stand_Outputs_Config_Structure_Definition
  *				Outputs Config Structure Definition
  * @brief		Конфигурация выходов
  * @{
  */
typedef struct __attribute__ ((__packed__)) Stand_Outputs_Config_Struct {
	Stand_Outputs_Mode_Config_t Discrete;					/*!< Конфигурация дискретных выходов */
	Stand_Outputs_Mode_Config_t Analogue;					/*!< Конфигурация аналоговых выходов */
	Stand_Outputs_Mode_Config_t Timer;						/*!< Конфигурация выходов таймеров */
} Stand_Outputs_Config_t;
/**
  * @}
  */

/** @defgroup	Stand_Dicrete_Seq_Structure_Definition
  *				Discrete Seq Structure Definition
  * @brief		Элемент массива последовательности установки значений дискретных выходов
  * @{
  */
typedef struct __attribute__ ((__packed__)) Stand_Discrete_Seq_Item_Struct {
    uint32_t OutputsState;	/*!< Состояние выходов */ ///Changed by Iuriova O.M.
	uint32_t Delay;											/*!< Задержка, мс */
} Stand_Discrete_Seq_Item_t;
/**
  * @}
  */

/** @defgroup	Stand_Analogue_Seq_Structure_Definition
  *				Analogue Seq Structure Definition
  * @brief		Элемент массива последовательности установки значений на аналоговых выходах
  * @{
  */
typedef struct __attribute__ ((__packed__)) Stand_Analogue_Seq_Item_Struct {
	float OutputsState[STAND_ANALOGUE_OUTPUTS_COUNT];		/*!< Состояние выходов */
	uint32_t Delay;											/*!< Задержка, мс */
} Stand_Analogue_Seq_Item_t;
/**
  * @}
  */

/** @defgroup	Stand_Timer_Item_Data_Structure_Definition
  *				Timer Item Data Structure Definition
  * @brief		Параметры канала таймера
  * @{
  */
typedef struct __attribute__ ((__packed__)) Stand_Timer_Item_Data_Struct {
	uint16_t Frequency;										/*!< Частота, Гц */
	uint16_t Duty;											/*!< Коэффициент заполнения (в 0.01%, т.е. 1% = 100) */
} Stand_Timer_Item_Data_t;
/**
  * @}
  */

/** @defgroup	Stand_Timer_Seq_Structure_Definition
  *				Timer Seq Structure Definition
  * @brief		Элемент массива последовательности установки значений на выходах таймеров
  * @{
  */
typedef struct __attribute__ ((__packed__)) Stand_Timer_Seq_Item_Struct {
	Stand_Timer_Item_Data_t OutputsState[STAND_TIMER_OUTPUTS_COUNT];	/*!< Состояние выходов */
	uint32_t Delay;											/*!< Задержка, мс */
} Stand_Timer_Seq_Item_t;
/**
  * @}
  */

/**
  * @}
  */

/**
  * @}
  */

/* Exported variables --------------------------------------------------------*/
/** @addtogroup Stand_Exported_Variables
  *				Exported Variables
  * @brief		Экспортируемые переменные
  * @{
  */

/**
  * @}
  */

/* Exported functions --------------------------------------------------------*/
/** @addtogroup Stand_Exported_Functions
  * 			Exported Functions
  * @brief		Экспортируемые функции
  * @{
  */


/**
  * @}
  */

/**
  * @}
  */


/// changed by Yurinova O.M.

//1. Общие для всех плат данные (адреса в дальнейшем будут изменены)

#define ASKRSPS_MODBUS_SLAVE_BASEDATA_TYPE		MODBUS_REGISTER_TYPE_INPUT	/*!< Тип регистров для основных данных платы */
#define ASKRSPS_MODBUS_SLAVE_STATUS_TYPE		MODBUS_REGISTER_TYPE_INPUT	/*!< Тип регистров для текущего состояния данных платы */
#define ASKRSPS_MODBUS_SLAVE_RUNTIME_CFG_TYPE	MODBUS_REGISTER_TYPE_HOLDING	/*!< Тип регистров для текущей конфигурации платы */
#define ASKRSPS_MODBUS_SLAVE_STORED_CFG_TYPE	MODBUS_REGISTER_TYPE_HOLDING	/*!< Тип регистров для сохраняемой конфигурации платы */

#define ASKRSPS_MODBUS_SLAVE_BASEDATA_ADDR		0x1000		/*!< Стартовый адрес для основных данных платы */
#define ASKRSPS_MODBUS_SLAVE_STATUS_ADDR		0x1100		/*!< Стартовый адрес текущего состояния платы */
#define ASKRSPS_MODBUS_SLAVE_RUNTIME_CFG_ADDR	0x1100		/*!< Стартовый адрес текущей конфигурации платы */
#define ASKRSPS_MODBUS_SLAVE_STORED_CFG_ADDR	0x1200		/*!< Стартовый адрес сохраняемой конфигурации платы */

//(Т.е. можем изменять данные в регистрах хранения (holding), input - только чтение)

#define APPSTRUCT_PARSIZE_BASE_VENDOR			32		/*!< Производитель платы - char[32] */
#define APPSTRUCT_PARSIZE_BASE_PRODUCT_NAME		16		/*!< Название продукта - char[16]  */
#define APPSTRUCT_PARSIZE_BASE_MODEL_NAME		16		/*!< Название модели - char[16]  */
#define APPSTRUCT_PARSIZE_BASE_URL				32		/*!< URL - char[32]  */

/** @defgroup	AppStruct_Base_Params_Structure_Definition
  *				Base Params Structure Definition
  * @brief		Базовая информация о плате
  * @{
  */
typedef struct AppStruct_Base_Params_Struct {
    uint32_t ID;											/*!< Идентификатор платы */
    uint32_t Version;										/*!< Версия платы */
    uint32_t FWVerMajorMinor;								/*!< Версия прошивки - старшая и младшая */
    uint32_t FWVerRelease;									/*!< Версия прошивки - дата релиза */
    char Vendor[APPSTRUCT_PARSIZE_BASE_VENDOR];				/*!< Производитель платы */
    char ProductName[APPSTRUCT_PARSIZE_BASE_PRODUCT_NAME];	/*!< Название продукта */
    char ModelName[APPSTRUCT_PARSIZE_BASE_MODEL_NAME];		/*!< Название модели */
    char URL[APPSTRUCT_PARSIZE_BASE_URL];					/*!< URL */
    uint16_t CommVersion;									/*!< Версия протокола связи */
    uint16_t InterfaceCount;								/*!< Количество интерфейсов */
    uint16_t AnalogueInputsCount;							/*!< Количество аналоговых входов */
    uint16_t DiscreteInputsCount;							/*!< Количество дискретных входов */
    uint16_t AnalogueOutputsCount;							/*!< Количество аналоговых выходов */
    uint16_t DiscreteOutputsCount;							/*!< Количество дискретных выходов */
//	uint16_t Reserved;										/*!< Зарезервировано - для выравнивания */
} AppStruct_Base_Params_t;
/**
  * @}
  */

//Пример данных с платы датчиков ЩОМ:

//=== cut ===
#define APPSTRUCT_PARAM_VENDOR					"NIAC AO \"VNIIZHT\""	/*!< Производитель платы - char[32] */
#define APPSTRUCT_PARAM_PRODUCT_NAME			"AS KRSPS"	/*!< Название продукта - char[16]  */
#define APPSTRUCT_PARAM_MODEL_NAME				"SensorBoard"	/*!< Название платы - char[16]  */
#define APPSTRUCT_PARAM_URL						"http://www.vniizht.ru/"	/*!< URL - char[32] */
#define APPSTRUCT_PARAM_DEVDATE					"2018-2019"	/*!< Дата разработки (только для логов) */
#define APPSTRUCT_PARAM_ID						ASKRSPS_BOARD_ID_SCHOM_SENSOR	/*!< Идентификатор платы - uint32_t */
#define APPSTRUCT_PARAM_VERSION					0x00000002U	/*!< Версия платы - uint32_t */
#define APPSTRUCT_PARAM_FW_VER_MAJOR			0x00000001U	/*!< Версия прошивки - старшая - uint16_t */
#define APPSTRUCT_PARAM_FW_VER_MINOR			0x00000000U	/*!< Версия прошивки - младшая - uint16_t */
#define APPSTRUCT_PARAM_FW_VER_MAJOR_MINOR		((APPSTRUCT_PARAM_FW_VER_MAJOR << 16) | APPSTRUCT_PARAM_FW_VER_MINOR)	/*!< Версия прошивки - старшая и младшая - uint32_t */
#define APPSTRUCT_PARAM_FW_VER_RELEASE			20190626	/*!< Версия прошивки - дата релиза - uint32_t */
#define APPSTRUCT_PARAM_COMM_VERSION			0x01	/*!< Версия протокола связи - uint16_t */
#define APPSTRUCT_PARAM_INTERFACE_COUNT			9		/*!< Количество интерфейсов - uint16_t */
#define APPSTRUCT_PARAM_ANALOGUE_INPUTS_COUNT	1		/*!< Количество аналоговых входов - uint16_t */
#define APPSTRUCT_PARAM_DISCRETE_INPUTS_COUNT	0		/*!< Количество дискретных входов - uint16_t */
#define APPSTRUCT_PARAM_DISCRETE_OUTPUTS_COUNT	2		/*!< Количество дискретных выходов - uint16_t */
#define APPSTRUCT_PARAM_ANALOGUE_OUTPUTS_COUNT	0		/*!< Количество аналоговых выходов - uint16_t */

/* Инициализация структуры с данными */
#define APPSTRUCT_BASE_PARAMS_INIT				{	.Vendor = APPSTRUCT_PARAM_VENDOR,\
                                                    .ProductName = APPSTRUCT_PARAM_PRODUCT_NAME,\
                                                    .ModelName = APPSTRUCT_PARAM_MODEL_NAME,\
                                                    .URL = APPSTRUCT_PARAM_URL,\
                                                    .ID = APPSTRUCT_PARAM_ID,\
                                                    .Version = APPSTRUCT_PARAM_VERSION,\
                                                    .FWVerMajorMinor = APPSTRUCT_PARAM_FW_VER_MAJOR_MINOR,\
                                                    .FWVerRelease = APPSTRUCT_PARAM_FW_VER_RELEASE,\
                                                    .CommVersion = APPSTRUCT_PARAM_COMM_VERSION,\
                                                    .InterfaceCount = APPSTRUCT_PARAM_INTERFACE_COUNT,\
                                                    .AnalogueInputsCount = APPSTRUCT_PARAM_ANALOGUE_INPUTS_COUNT,\
                                                    .DiscreteInputsCount = APPSTRUCT_PARAM_DISCRETE_INPUTS_COUNT,\
                                                    .AnalogueOutputsCount = APPSTRUCT_PARAM_ANALOGUE_OUTPUTS_COUNT,\
                                                    .DiscreteOutputsCount = APPSTRUCT_PARAM_DISCRETE_OUTPUTS_COUNT\
                                                }
//=== cut ===

//Состояния платы:

/** @defgroup	App_Port_DateTime_Structure_Definition
  *				DateTime Structure Definition
  * @brief		Развернутая структура даты и времени
  *				(потому что tm больно жирная)
  * @{
  */
typedef struct App_Port_DateTime_Struct {
    int16_t Year;											/*!< Год (т.к. все равно 16-бит, то почему бы и не до Р.Х.? */
    uint16_t Milliseconds;									/*!< Миллисекунды (понадобятся ли?) */
    uint8_t Month;											/*!< Месяц */
    uint8_t Date;											/*!< День месяца */
    uint8_t WeekDay;										/*!< День недели */
    uint8_t Hours;											/*!< Часы */
    uint8_t Minutes;										/*!< Минуты */
    uint8_t Seconds;										/*!< Секунды */
} App_Port_DateTime_t;
/**
  * @}
  */

/** @defgroup	AppStruct_Status_Structure_Definition
  *				Status Structure Definition
  * @brief		Состояние приложения (платы)
  * @{
  */
typedef struct AppStruct_Status_Struct {
    volatile time_t UnixTime;								/*!< Время UNIX (32-bit?) */
    volatile uint32_t Time;									/*!< Время (счетчик) */
    uint32_t PowerMode;										/*!< Режим энергосбережения */
    uint32_t Latitude;										/*!< Широта */
    uint32_t Longitude;										/*!< Долгота */
    float Temperature;										/*!< Температура контроллера */
    App_Port_DateTime_t DateTime;							/*!< Дата и время (TODO: проверить совместимость по регистрам) */
} AppStruct_Status_t;
/**
  * @}
  */

/** @defgroup	AppStruct_Runtime_Config_Structure_Definition
  *				Runtime Config Structure Definition
  * @brief		Изменяемые текущие параметры платы
  * @{
  */
typedef struct AppStruct_Runtime_Config_Struct {
    time_t UnixTime;										/*!< Время UNIX (32-bit?) */
    uint32_t Time;											/*!< Время (счетчик) */
    uint32_t PowerMode;										/*!< Режим энергосбережения */
    uint32_t Latitude;										/*!< Широта */
    uint32_t Longitude;										/*!< Долгота */
} AppStruct_Runtime_Config_t;
/**
  * @}
  */

//Сохраняемые параметры платы:

/** @defgroup	AppStruct_Stored_Config_Structure_Definition
  *				Stored Config Structure Definition
  * @brief		Изменяемые сохраняемые параметры платы
  * @{
  */
typedef struct AppStruct_Stored_Config_Struct {
    uint32_t ConfigPreset;									/*!< Настройка конфигурации */
    uint32_t AnalogueInputsEnable;							/*!< Включение аналоговых входов */
    uint32_t AnalogueInputsActionEnable;					/*!< Включить действие при срабатывании аналоговых входов */
    uint32_t AnalogueInputsMask;							/*!< Маска вывода аналоговых входов */
    uint32_t AnalogueInputsDebounceEnable;					/*!< Включить антидребезг на аналоговых входах */
    uint32_t DiscreteInputsEnable;							/*!< Включение дискретных входов */
    uint32_t DiscreteInputsActionEnable;					/*!< Включить действие при срабатывании дискретных входов */
    uint32_t DiscreteInputsImpulseCntEnable;				/*!< Включить счетчик импульсов на дискретных входах (упрощенная обработка в прерывании) */
    uint32_t DiscreteInputsMask;							/*!< Маска вывода дискретных входов */
    uint32_t DiscreteInputsDebounceEnable;					/*!< Включить антидребезг на дискретных входах */
    uint32_t AnalogueOutputsEnable;							/*!< Включение аналоговых выходов */
    uint32_t DiscreteOutputsEnable;							/*!< Включение дискретных выходов */
    uint32_t PowerMode;										/*!< Режим энергосбережения */
    /* Далее под вопросом - как это оформлять, т.к. желательно делать массивы */
    uint32_t QueuesEnable;									/*!< Включение очередей данных */
    uint32_t ModulesEnable;									/*!< Включение модулей */
    uint32_t InterfacesEnable;								/*!< Включение интерфейсов */
    uint32_t LPWakeUpInterval;								/*!< Интервал просыпания в режиме энергосбережения */
    uint32_t LPADCInterval;									/*!< Интервал включения АЦП в режиме энергосбережения */
} AppStruct_Stored_Config_t;
/**
  * @}
  */

//2. Данные платы датчиков ЩОМ (Sensor Board V2)


//Адрес устройства
#define ASKRSPS_MODBUS_DEV_ADDRESS_SCHOM_IMU	0x0B		/*!< Адрес устройства платы датчиков ЩОМ */

//Настройки связи
#define ASKRSPS_MODBUS_SLAVE_UART_CONFIG_SCHIM	{	.BaudRate = APP_PORT_PERIPH_UART_BAUD_RATE_115200,\
                                                    .DataBits = 8,\
                                                    .Parity = APP_PORT_PERIPH_UART_PARITY_NONE,\
                                                    .StopBits = 1,\
                                                    .TransferDirection = (APP_PORT_PERIPH_TRANSFER_DIRECTION_RX | APP_PORT_PERIPH_TRANSFER_DIRECTION_TX),\
                                                    .FlowControl = APP_PORT_PERIPH_UART_FLOW_CONTROL_NONE,\
                                                    .OverSampling = APP_PORT_PERIPH_UART_OVERSAMPLING_16,\
                                                }	/*!< Параметры UART для ModBus RTU Master */

//Начало данных датчиков
#define ASKRSPS_MODBUS_REG_START_SCHOM_IMU		0x4E49		/*!< Начальный адрес регистров платы датчиков ЩОМ */

//Длина данных
#define ASKRSPS_PACKET_DATA_SCHOM_SENSOR_DATA_CNT	6		/*!< Количество полей в данных датчиков ЩОМ (2 датчика по 3*2 значений) */
#define ASKRSPS_PACKET_DATA_SCHOM_SENSOR_CNT	2			/*!< Количество датчиков */
#define ASKRSPS_MODBUS_REG_DATA_SIZE_SCHOM_IMU	(sizeof(int32_t) + (sizeof(int32_t) * ASKRSPS_PACKET_DATA_SCHOM_SENSOR_DATA_CNT * ASKRSPS_PACKET_DATA_SCHOM_SENSOR_CNT))			/*!< Размер данных датчиков ЩОМ */
#define ASKRSPS_MODBUS_REG_CNT_SCHOM_IMU		(ASKRSPS_MODBUS_REG_DATA_SIZE_SCHOM_IMU / MODBUS_BASE_TYPE_SIZE)			/*!< Количество считываемых с платы датчиков ЩОМ */

//Данные там массив int32_t:

/** @defgroup	ASKRSPS_Packet_Data_Schom_IMU_List_Enum_Definition
  *				Data Schom IMU List Enum Definition
  * @brief		Список данных в пакете датчиков ЩОМ
  * @{
  */
typedef enum ASKRSPS_Packet_Data_Schom_IMU_List_Enum {
    ASKRSPS_PACKET_DATA_SCHOM_IMU_ACC_X			= 0,	/*!< Данные акселерометра X */
    ASKRSPS_PACKET_DATA_SCHOM_IMU_ACC_Y,				/*!< Данные акселерометра Y */
    ASKRSPS_PACKET_DATA_SCHOM_IMU_ACC_Z,				/*!< Данные акселерометра Z */
    ASKRSPS_PACKET_DATA_SCHOM_IMU_ACC_STDEV_X,			/*!< Данные акселерометра X - стандартное отклонение */
    ASKRSPS_PACKET_DATA_SCHOM_IMU_ACC_STDEV_Y,			/*!< Данные акселерометра Y - стандартное отклонение */
    ASKRSPS_PACKET_DATA_SCHOM_IMU_ACC_STDEV_Z,			/*!< Данные акселерометра Z - стандартное отклонение */
    ASKRSPS_PACKET_DATA_SCHOM_IMU_GYRO_X,				/*!< Данные гироскопа X */
    ASKRSPS_PACKET_DATA_SCHOM_IMU_GYRO_Y,				/*!< Данные гироскопа Y */
    ASKRSPS_PACKET_DATA_SCHOM_IMU_GYRO_Z,				/*!< Данные гироскопа Z */
    ASKRSPS_PACKET_DATA_SCHOM_IMU_GYRO_STDEV_X,			/*!< Данные гироскопа X - стандартное отклонение */
    ASKRSPS_PACKET_DATA_SCHOM_IMU_GYRO_STDEV_Y,			/*!< Данные гироскопа Y - стандартное отклонение */
    ASKRSPS_PACKET_DATA_SCHOM_IMU_GYRO_STDEV_Z,			/*!< Данные гироскопа Z - стандартное отклонение */
} ASKRSPS_Packet_Data_Schom_IMU_List_t;
/**
  * @}
  */

//Скорости порта UART:
/** @defgroup	App_Port_Periph_Baud_Rate_Enum_Definition
  * 			Baud Rate Enum Definition
  * @brief		Список стандартных скоростей передачи данных UART
  * @{
  */
typedef enum App_Port_Periph_UART_Baud_Rate_Enum {
    APP_PORT_PERIPH_UART_BAUD_RATE_300			= 300,		/*!< 300bps */
    APP_PORT_PERIPH_UART_BAUD_RATE_600			= 600,		/*!< 600bps */
    APP_PORT_PERIPH_UART_BAUD_RATE_1200			= 1200,		/*!< 1200bps */
    APP_PORT_PERIPH_UART_BAUD_RATE_2400			= 2400,		/*!< 2400bps */
    APP_PORT_PERIPH_UART_BAUD_RATE_4800			= 4800,		/*!< 4800bps */
    APP_PORT_PERIPH_UART_BAUD_RATE_9600			= 9600,		/*!< 9600bps */
    APP_PORT_PERIPH_UART_BAUD_RATE_19200		= 19200,	/*!< 19200bps */
    APP_PORT_PERIPH_UART_BAUD_RATE_38400		= 38400,	/*!< 38400bps */
    APP_PORT_PERIPH_UART_BAUD_RATE_57600		= 57600,	/*!< 57600bps */
    APP_PORT_PERIPH_UART_BAUD_RATE_115200		= 115200,	/*!< 115200bps */
    APP_PORT_PERIPH_UART_BAUD_RATE_230400		= 230400,	/*!< 230400bps */
    APP_PORT_PERIPH_UART_BAUD_RATE_460800		= 460800,	/*!< 460800bps */
    APP_PORT_PERIPH_UART_BAUD_RATE_921600		= 921600,	/*!< 921600bps */
} App_Port_Periph_UART_Baud_Rate_t;
/**
  * @}
  */

/// end of changes

#ifdef __cplusplus
}
#endif

#endif /* __STAND_DEFS_H_ */

/******************* (C) COPYRIGHT 2019 Max Egorov *************END OF FILE****/
