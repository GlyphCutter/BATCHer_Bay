@echo off
title FileSorter V1.6 by GlyphCutter
REM Установка UTF-8 кодировки
CHCP 65001 >nul
REM Установка размера окна консоли
MODE 50,30 >nul
REM Цветовая схема (желтый на черном)
color 0E
cls

setlocal enabledelayedexpansion


REM ========================================================
REM НАСТРОЙКИ
REM ========================================================

REM Определение категорий для сортировки по расширениям. Удаление либо расширение списка делается здесь.
REM Образец: set "CATEGORIES=VAR где VAR определяет категорию и название подпапки для нее, категории разделяются пробелом.

set "CATEGORIES=ARX DOX EXE FNT HTM IMG ISO LIB SND TOR VID"      & REM Категории для сортировки
set "PERSONAL_SUBFOLDERS="                                        & REM Категории в которых будут создаваться персональные подпапки

set "UNCATEGORIZED_FOLDER=ETC"                                    & REM Папка для файлов не подпадающих в категории (если не задана - используется корневая)
set "CREATE_UNCATEGORIZED_SUBFOLDERS=0"                           & REM Создать подпапки для файлов не подпадающих в категории (0/1)

set "LOG_FILE=FileSorter.log"                                     & REM Лог-файл
set "ROOT_FOLDER=_SORTED"                                         & REM Основная (корневая) папка для отсортированного
set "UNNAMED_PREFIX=UNNAMED"                                      & REM Префикс для безымянных файлов

set "CREATE_DESCRIPTION=0"                                        & REM Создавать descript.ion (0/1)
set "DESCRIPTION_FILE=descript.ion"                               & REM Определение и имя файла описания

set "BAR_LENGTH=30"                                               & REM Длина прогресс-бара в символах
set "FILL_CHAR=#"                                                 & REM Символ заполнения на прогресс-баре
set "EMPTY_CHAR=-"                                                & REM Символ пустоты на прогресс-баре


REM Расширения для категорий сортировки (проверка без учета регистра)
REM Образец для добавления: 
REM set "VAR=,.res1,.res2,.res3," 
REM где VAR определение категории (должно совпадать со списком выше) а .res1/2/3 - расширения файлов которые в нее попадут.

set "ARX=,.7z,.gz,.rar,.tar,.zip,"                                & REM Архивы
set "DOX=,.txt,.rtf,.docx,.md,.doc,.xls,.xlsx,"                   & REM Документы
set "EXE=,.cmd,.ps1,.bat,.msi,.exe,.jar,"                         & REM Исполняемые файлы
set "FNT=,.cff,.otf,.ttf,"                                         & REM Шрифты
set "HTM=,.mhtml,.htm,.mht,.html,"                                & REM Сохраненные веб-страницы
set "IMG=,.png,.bmp,.jpeg,.gif,.jpg,.webp,.dds,.tga,.psd,"        & REM Изображения
set "ISO=,.mds,.bin,.mdf,.mdx,.iso,.cue,.nrg,"                    & REM Образы дисков
set "LIB=,.djvu,.epub,.pdf,.fb2,"                                 & REM Книги
set "SND=,.flac,.aac,.wav,.ogg,.mp3,.mid,"                        & REM Звуки
set "TOR=,.torrent,"                                              & REM Торрент-файлы
set "VID=,.mkv,.wmv,.avi,.mov,.mp4,"                              & REM Видео


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
if !total! == 0 (
      cls
      echo NO FILES TO PROCESS!
      echo.
      echo ---------------------------
      pause
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

REM Визуализация прогресс-бара (файлов обработано/всего)
echo PROCESSING...
echo.
echo 0%% [!EMPTY_CHAR!] 0/!total!

REM Начало цикла обработки
for %%A in (*) do (

      REM Пропускаем сам скрипт и лог-файл
      if /i not "%%A"=="%~nx0" if /i not "%%A"=="%LOG_FILE%" (
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
                  echo [CAT-PERS] %%A moved to !target!\!folder_name! >> "%LOG_FILE%"
            ) else (
                  move "%%A" "%ROOT_FOLDER%\!target!\" >nul
                  REM Запись действия в лог-файл о переносе файла в категорию
                  echo [CAT] %%A moved to !target! >> "%LOG_FILE%"
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
                  echo [PERS] %%A moved to !folder_name! >> "%LOG_FILE%"
            ) else (
                  REM Если настройка создания подпапок для файлов без категории установлена в 0
                  REM Переместить сортируемый файл (без категории) в целевую папку в соответствии с настройками (корневая либо указанная)
                  move "%%A" "!dest_folder!\" >nul
                  REM Запись действия в лог-файл о переносе файла в целевую подпапку
                  echo [UNCAT] %%A moved to !dest_folder! >> "%LOG_FILE%"
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

      REM Обновление прогресс-бара по мере выполнения
      cls
      echo PROCESSING...
      echo.
      echo !percent!%% [!progress!] !processed!/!total!
      )
)
REM Конец цикла обработки


REM ========================================================
REM ЗАВЕРШЕНИЕ РАБОТЫ
REM ========================================================

cls
echo PROCESSING... DONE
echo.
echo Total processed: !processed!
echo ---------------------------
pause