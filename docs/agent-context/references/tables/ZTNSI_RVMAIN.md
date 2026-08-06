# Таблица ZTNSI_RVMAIN

| Поле | Элемент данных | Тип | Длина | Десятичные | Описание |
|---|---|---|---|---|---|
| MANDT | MANDT | CLNT | 3 | 0 | Мандант |
| Z_EKMTR | ZEEKMTR | CHAR | 30 | 0 | Код ЕК МТР |
| WERKS | WERKS_D | CHAR | 4 | 0 | Завод |
| Z_EKMTR_NAME | ZEEKMTR_NAME | CHAR | 255 | 0 | Наименование ЕК МТР |
| EKGRP | ZEEKGRP_UPPER | CHAR | 40 | 0 | Группа закупок |
| MATNR | MATNR | CHAR | 18 | 0 | Номер материала |
| Z_CPUR | ZECPUR | CHAR | 3 | 0 | Централизованная закупка |
| Z_TECHDOC | ZETECHDOC | CHAR | 30 | 0 | Тех документация |
| PLIFZ | ZEPLIFZ_CHAR | CHAR | 40 | 0 | Плановый срок поставки в днях |
| ZZPLIFZ | ZEPLIFZ_TP | DEC | 3 | 0 | ПлановСрокТП |
| ZUPDATED | XFELD | CHAR | 1 | 0 | Независимая кнопка |
| ZRV1 | ZERV1 | DEC | 3 | 0 | 1. Деблокирование заявки |
| ZRV2 | ZERV2 | DEC | 3 | 0 | 2. Подготовка  закупочной процедуры |
| ZRV3 | ZERV3 | DEC | 3 | 0 | 3. Сбор ТКП |
| ZRV4 | ZERV4 | DEC | 3 | 0 | 4. Тех. согласование |
| ZRV5 | ZERV5 | DEC | 3 | 0 | 5. Выбор поставщика |
| ZRV6 | ZERV6 | DEC | 3 | 0 | 6. Заключение договора |
| ZRV7 | ZERV7 | DEC | 3 | 0 | 7. Срок поставки от даты размещения заказа до поступл на скл |
