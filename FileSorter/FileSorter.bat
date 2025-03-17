@echo off
title Kramaka FileSorter V1.7 by GlyphCutter
REM Установка UTF-8 кодировки
CHCP 65001 >nul
REM Установка размера окна консоли
MODE 58,30 >nul
REM Цветовая схема (желтый на черном)
color 0E
cls

setlocal enabledelayedexpansion


REM ========================================================
REM НАСТРОЙКИ
REM ========================================================

REM Определение категорий для сортировки по расширениям. Удаление либо расширение списка делается здесь.
REM Образец: set "CATEGORIES=VAR где VAR определяет категорию и название подпапки для нее, категории разделяются пробелом.

REM Категории для сортировки
set "CATEGORIES=ARX DOX EXE FNT HTM IMG ISO LIB SND TOR VID"
REM Категории в которых будут создаваться персональные подпапки (более 4 не рекомендуется)
set "PERSONAL_SUBFOLDERS="

REM Папка для файлов не подпадающих в категории (если не задана - используется корневая)
set "UNCATEGORIZED_FOLDER=ETC"
REM Создать подпапки для файлов не подпадающих в категории (0/1)
set "CREATE_UNCATEGORIZED_SUBFOLDERS=1"

REM Создавать лог-файл (0/1)
set "SAVE_LOG=1"
REM Лог-файл
set "LOG_FILE=filesort.log"

REM Основная (корневая) папка для отсортированного
set "ROOT_FOLDER=_SORTED"
REM Префикс для безымянных файлов
set "UNNAMED_PREFIX=UNNAMED"

REM Создавать descript.ion (0/1)
set "CREATE_DESCRIPTION=0"
REM Определение и имя файла описания
set "DESCRIPTION_FILE=descript.ion"

REM Длина прогресс-баров в символах
set "BAR_LENGTH=45"
REM Символ заполнения на прогресс-барах
set "FILL_CHAR=▓"
REM Символ пустоты на прогресс-барах
set "EMPTY_CHAR=░"


REM Расширения для категорий сортировки (проверка без учета регистра)
REM Образец для добавления: 
REM set "VAR=,.res1,.res2,.res3," 
REM где VAR определение категории (должно совпадать со списком выше) а .res1/2/3 - расширения файлов которые в нее попадут.

set "ARX=,.7z,.gz,.rar,.tar,.zip,"                                & REM Архивы
set "DOX=,.txt,.rtf,.docx,.md,.doc,.xls,.xlsx,"                   & REM Документы
set "EXE=,.cmd,.ps1,.bat,.msi,.exe,.jar,"                         & REM Исполняемые файлы
set "FNT=,.cff,.otf,.ttf,"                                        & REM Шрифты
set "HTM=,.mhtml,.htm,.mht,.html,"                                & REM Сохраненные веб-страницы
set "IMG=,.png,.bmp,.jpeg,.gif,.jpg,.webp,.dds,.tga,.psd,"        & REM Изображения
set "ISO=,.mds,.bin,.mdf,.mdx,.iso,.cue,.nrg,"                    & REM Образы дисков
set "LIB=,.djvu,.epub,.pdf,.fb2,"                                 & REM Книги
set "SND=,.flac,.aac,.wav,.ogg,.mp3,.mid,"                        & REM Звуки
set "TOR=,.torrent,"                                              & REM Торрент-файлы
set "VID=,.mkv,.wmv,.avi,.mov,.mp4,"                              & REM Видео


REM ========================================================
REM ВЫВОД ТЕКУЩИХ НАСТРОЕК
REM ========================================================

REM Создание отображения маркера создания персональных подпапок для файлов вне категорий на основе настройки (CREATE_UNCATEGORIZED_SUBFOLDERS)
set "DISPLAY_PER_UNCAT_FLAG=▌OFF▐░░" & if %CREATE_UNCATEGORIZED_SUBFOLDERS% equ 1 set "DISPLAY_PER_UNCAT_FLAG=▓▓▓▌ON▐"

REM Создание отображения маркера создания для персональных подпапок для файлов сортируемых в категории на основе списка (PERSONAL_SUBFOLDERS)
set "DISPLAY_PER_CAT_FLAG=▌OFF▐░░" & if defined PERSONAL_SUBFOLDERS set "DISPLAY_PER_CAT_FLAG=▓▓▓▌ON▐"
REM Создание отображения категорий в которых будут создаваться персональные подпапки на основе списка (PERSONAL_SUBFOLDERS)
set "DISPLAY_PER_CAT_DIR=" & if defined PERSONAL_SUBFOLDERS set "DISPLAY_PER_CAT_DIR=▌%PERSONAL_SUBFOLDERS%"

REM Создание отображения маркера создания файлов описаний на основе настройки (CREATE_DESCRIPTION)
set "DISPLAY_DESCRIPTION_FLAG=▌OFF▐░░" & if %CREATE_DESCRIPTION% equ 1 set "DISPLAY_DESCRIPTION_FLAG=▓▓▓▌ON▐"
REM Создание отображения имени создаваемых файлов описаний на основе переменной (DESCRIPTION_FILE)
set "DISPLAY_DESCRIPTION_FILE=" & if %CREATE_DESCRIPTION% equ 1 set "DISPLAY_DESCRIPTION_FILE=▌%DESCRIPTION_FILE%"

REM Создание отображения маркера создания файла лога на основе настройки (SAVE_LOG)
set "DISPLAY_LOG_FLAG=▌OFF▐░░" & if %SAVE_LOG% equ 1 set "DISPLAY_LOG_FLAG=▓▓▓▌ON▐"
REM Создание отображения имени создаваемого лог-файла на основе переменной (LOG_FILE)
set "DISPLAY_LOG_FILE=" & if %SAVE_LOG% equ 1 set "DISPLAY_LOG_FILE=▌%LOG_FILE%"

:DISPLAY_MENU
cls
echo   ╔═════════════════════════╦═════════════════════════╗
echo   ║ Kramaka FileSorter V1.7 ║    Current settings:    ║
echo   ╚═════════════════════════╩═════════════════════════╝
echo     ▌Source▐ %cd%
echo.
echo     ▌Target▐ ..\%ROOT_FOLDER%
echo.
echo     ▌Create the▐
echo     • Log file:              %DISPLAY_LOG_FLAG%  %DISPLAY_LOG_FILE%
echo     • Descriptions:          %DISPLAY_DESCRIPTION_FLAG%  %DISPLAY_DESCRIPTION_FILE%
echo     ▌Personal Dir▐
echo     • In Category:           %DISPLAY_PER_CAT_FLAG%  %DISPLAY_PER_CAT_DIR%
echo     • Uncategorized:         %DISPLAY_PER_UNCAT_FLAG%  %DISPLAY_UNCATEGORIZED_FOLDER%
echo.
echo     Categories:
echo   ╔═════════════════════════╦═════════════════════════╗
echo   ║• ARX - Archives         ║• ISO - Disc Images      ║
echo   ║• DOX - Documents        ║• LIB - E-Books          ║
echo   ║• EXE - Executables      ║• SND - Audio            ║
echo   ║• FNT - Fonts            ║• TOR - Torrent Files    ║
echo   ║• HTM - Web Pages        ║• VID - Video Files      ║
echo   ║• IMG - Images           ║                         ║
echo   ╚═════════════════════════╩═════════════════════════╝
REM Отображение назначения для файлов не попавших в какую либо из категорий на основе настройки (UNCATEGORIZED_FOLDER)
echo     ▌Other files will be moved to:    ▌%UNCATEGORIZED_FOLDER%
echo     -------------------------
echo.
REM Здесь и далее используется такая конструкция вместо обычной паузы чтобы можно было отрисовать любой текст
echo     ▌Press any key...
timeout /T -1 >nul
      
      
REM ========================================================
REM ОЖИДАНИЕ ПОДТВЕРЖДЕНИя С ТАЙМЕРОМ
REM ========================================================

REM Время на подтверждение в секундах
set "timeout_sec=45"
REM Установка оставшегося времени на заданное
set "remaining=%timeout_sec%"

REM Условный цикл таймера
:CONFIRMATION_LOOP
REM Расчет прогресс-бара с использованием настроек размера шкалы и заполнителей
set /a "filled=remaining*100/timeout_sec, bars=filled*BAR_LENGTH/100"
set "progress_bar="
for /l %%i in (1,1,!bars!) do set "progress_bar=!progress_bar!!FILL_CHAR!"
set /a "empty=BAR_LENGTH-bars"
for /l %%i in (1,1,!empty!) do set "progress_bar=!progress_bar!!EMPTY_CHAR!"

REM Отображение окна с таймером
:DISPLAY_CANCEL_TIMER
cls
echo     ▌PROCESSING...     PREPARE
echo.
echo     ▌!progress_bar!▐
echo               AUTOCANCEL IN !remaining! SECONDS
echo.                                                

REM Вывод предложение для ввода
echo     ▌Confirm files process?  ▌NO▐░░░

REM Выбор действия подтвердить либо отменить с подавлением ввода, нужно
REM для скрытия третьего варианта который используется по таймауту для уменьшения таймера
REM Сортировка вариантов в соответствии с мануалом по убыванию где:
choice /C YNT /T 1 /D T >nul
REM Вариант 3 - невидимое T используемое с таймаутом в 1сек для работы механизма таймера и прогресс-бара
if %errorlevel% equ 3 (
      set /a "remaining-=1"
      if !remaining! gtr 0 (
      REM Если не была нажата кнопка происходит возврат в начало условного цикла таймера
      goto confirmation_loop
REM Вариант 2 - обработка введенной N - что означает отмену и переход к соответствующей части кода
) else if %errorlevel% equ 2 (
      goto DISPLAY_CANCEL
      )
REM Вариант 1 - обработка введенного Y - что означает подтверждение и переход к дальнейшему исполнению скрипта
) else if %errorlevel% equ 1 (
      goto start_processing
      )
)

REM Отображение отмены операции (по таймеру либо в ручную)
:DISPLAY_CANCEL
cls
echo     ▌OPERATION        CANCELED
echo.
echo     -------------------------
echo     ▌Press any key...
timeout /T -1 >nul
exit /b

REM Отображение заглушки перед основным процессом (для минимизации пустого экрана)
:START_PROCESSING
cls
echo     ▌PROCESSING...     PREPARE
echo.
echo     -------------------------

REM ========================================================
REM ИНИЦИАЛИЗАЦИЯ
REM ========================================================

REM Установка установка переменных для работы прогресс-бара
set /a total=0, processed=0

REM Подсчет только релевантных файлов для обработки (исключая скрипт и лог)
for /f "delims=" %%F in ('dir /b /a-d ^| findstr /v /i "%~nx0 %LOG_FILE%"') do (
    set /a total+=1
)

REM Вывод заглушки, если файлы для обработки не обнаружены
:DISPLAY_NO_FILES
if !total! == 0 (
      cls
      echo     ▌NO FILES TO PROCESS!
      echo.
      echo     -------------------------
      echo     ▌Press any key...
      timeout /T -1 >nul
      exit /b
      )

REM Если файл лога существует к моменту выполнения скрипта то удалить
if exist "%LOG_FILE%" del "%LOG_FILE%"
REM Создать папку для результатов сортировки
mkdir "%ROOT_FOLDER%" 2>nul

REM Создание папки для файлов вне категории (если указано)
if defined UNCATEGORIZED_FOLDER (
      mkdir "%ROOT_FOLDER%\%UNCATEGORIZED_FOLDER%" 2>nul
      )


REM ========================================================
REM СОЗДАНИЕ КАТЕГОРИЙНЫХ ПАПОК
REM ========================================================

REM Создание подпапок для всех определенных категорий
for %%G in (%CATEGORIES%) do (
      mkdir "%ROOT_FOLDER%\%%G" 2>nul
      REM Если настройка создания файлов описаний установлена в 1...
      if !CREATE_DESCRIPTION! == 1 (
            REM ...И если файл описания отсутствует то он создается, если присутствует то пропускается c (чтобы не уничтожить содержащуюся в нем информацию)
            if not exist "%ROOT_FOLDER%\%%G\%DESCRIPTION_FILE%" (
            type nul > "%ROOT_FOLDER%\%%G\%DESCRIPTION_FILE%" 2>nul
            )
      )
)


REM ========================================================
REM ОСНОВНАЯ ОБРАБОТКА ФАЙЛОВ
REM ========================================================

:DISPLAY_PROGRESS_BAR_INITIALIZE
REM Визуализация прогресс-бара (файлов обработано/всего)
echo     ▌PROCESSING...
echo.
echo 0%% ▌!EMPTY_CHAR!▐ 0/!total!

REM Начало цикла обработки
for %%A in (*) do (

      REM Пропускаем сам скрипт и лог-файл
      if /i not "%%A"=="%~nx0" if /i not "%%A"=="%LOG_FILE%" (
      set "current_file=%%A"
      REM Принудительная очистка переменной назначения в начале цикла
      set "target="
      set "ext=%%~xA"
        
      REM Регистро-независимый поиск расширения (find /i)
      for %%G in (%CATEGORIES%) do (
            REM Если файл относится к определенной категории то ему устанавливается назначение
            echo !%%G! | find /i ",!ext!," >nul && set "target=%%G"
      )

      REM Если назначение установлено то переходим разбору файлов относящихся к установленным категориям, иначе переходим к разбору файлов вне категорий
      if defined target (
    
      REM *** Разбор файлов не подпадающих в категории ***
    
      REM Принудительно очищаем переменную персональной папки
      set "personal_subfolder="

            REM Проверяем нужно ли создавать персональные подпапки для этой категории
            REM Для этого ищем указана ли категория среди установленных к созданию персональных подпапок
            echo !PERSONAL_SUBFOLDERS! | find /i "!target!" >nul && set "personal_subfolder=1"
            REM Если маркер персональной подпапки истинный то
            if defined personal_subfolder (
                        REM Установить имя папки в соответствии с именем сортируемого файла
                        set "folder_name=%%~nA"
                  REM Если имя файла пустое - подставить имя-заглушку
                  if "!folder_name!"=="" (
                        set "folder_name=%UNNAMED_PREFIX%_!RANDOM!"
                  )
                  REM Создать персональную папку по установленному пути
                  mkdir "%ROOT_FOLDER%\!target!\!folder_name!" 2>nul
                  
                  REM Если настройка создания файлов описаний истинна и...
                  if !CREATE_DESCRIPTION! == 1 (
                        REM Если файл описания отсутствует то он создается, если присутствует то пропускается (чтобы не уничтожить содержащуюся в нем информацию)
                        if not exist "%ROOT_FOLDER%\!target!\!folder_name!\%DESCRIPTION_FILE%" (
                        echo %%A > "%ROOT_FOLDER%\!target!\!folder_name!\%DESCRIPTION_FILE%"
                        )
                  )
                  REM Переместить сортируемый файл в персональную папку в соответствующей категории
                  move "%%A" "%ROOT_FOLDER%\!target!\!folder_name!\" >nul
                  REM Запись действия в лог-файл о переносе файла в персональную подпапку в категории
                        if %SAVE_LOG% equ 1 (
                              echo [CAT-PERS] %%A moved to !target!\!folder_name! >> "%LOG_FILE%"
                        )
            ) else (
                  move "%%A" "%ROOT_FOLDER%\!target!\" >nul
                  REM Запись действия в лог-файл о переносе файла в категорию
                        if %SAVE_LOG% equ 1 (
                              echo [CAT] %%A moved to !target! >> "%LOG_FILE%"
                        )
            )
      ) else (

            REM *** Разбор файлов не подпадающих в категории ***

            REM По умолчанию назначается корневая папка
            set "dest_folder=%ROOT_FOLDER%"
            
            REM Если указана папка для файлов не подпадающих в категории то назначается она
            if defined UNCATEGORIZED_FOLDER (
                  set "dest_folder=%ROOT_FOLDER%\%UNCATEGORIZED_FOLDER%"
            )
            REM Если настройка создания подпапок для файлов без категории установлена в 1
            if !CREATE_UNCATEGORIZED_SUBFOLDERS! == 1 (
                  REM Установить имя папки в соответствии с именем файла
                  set "folder_name=%%~nA"
                  
                  REM Если имя файла пустое - подставить имя-заглушку
                  if "!folder_name!"=="" (
                        set "folder_name=%UNNAMED_PREFIX%_!RANDOM!"
                  )
                  REM Создать папку по установленному пути (корневая либо специальная)
                  mkdir "!dest_folder!\!folder_name!" 2>nul
                  
                  REM Если настройка создания файлов описаний установлена в 1 то
                  if !CREATE_DESCRIPTION! == 1 (
                        REM Если файл описания отсутствует то он создается, если присутствует то пропускается (чтобы не уничтожить содержащуюся в нем информацию)
                        if not exist "!dest_folder!\!folder_name!\%DESCRIPTION_FILE%" (
                              echo %%A > "!dest_folder!\!folder_name!\%DESCRIPTION_FILE%"
                        )
                  )
                  REM Переместить сортируемый файл (без категории) в персональную папку в соответствии с настройками (в корневой папке либо указанной подпапке)
                  move "%%A" "!dest_folder!\!folder_name!\" >nul
                  REM Запись действия в лог-файл о переносе файла в персональную подпапку
                        if %SAVE_LOG% equ 1 (
                              echo [PERS] %%A moved to !folder_name! >> "%LOG_FILE%"
                        )
            ) else (
                  REM Если настройка создания подпапок для файлов без категории установлена в 0
                  REM Переместить сортируемый файл (без категории) в целевую папку в соответствии с настройками (корневая либо указанная)
                  move "%%A" "!dest_folder!\" >nul
                  REM Запись действия в лог-файл о переносе файла в целевую подпапку
                        if %SAVE_LOG% equ 1 (
                              echo [UNCAT] %%A moved to !dest_folder! >> "%LOG_FILE%"
                        )
            )
      )

      REM Блок прогресс-бара: увеличение переменной на единицу, подсчет процентов, заполнения
      set /a processed+=1
      set /a percent=processed*100/total
      set /a filled=percent*BAR_LENGTH/100  & REM Пересчет заполненных символов
      set "progress="
      
      REM Вывод символов для визуализации работы прогресс-бара
      for /l %%i in (1,1,!filled!) do set "progress=!progress!%FILL_CHAR%"
      for /l %%i in (1,1,%BAR_LENGTH%) do if %%i gtr !filled! set "progress=!progress!%EMPTY_CHAR%"

:DISPLAY_PROGRESS_BAR_REFRESH
      REM Обновление прогресс-бара по мере выполнения
      cls
      echo     ▌PROCESSING...
      echo.
      echo !percent!%% ▌!progress!▐ !processed!/!total!
      echo.
      echo     ▌!current_file!
      )
)
REM Конец цикла обработки


REM ========================================================
REM ЗАВЕРШЕНИЕ РАБОТЫ
REM ========================================================

:DISPLAY_DONE
cls
echo     ▌OPERATION            DONE
echo.
echo     -------------------------
echo     ▌Total processed: !processed!
echo     ▌Press any key...
timeout /T -1 >nul
exit /b
