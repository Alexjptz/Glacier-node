#!/bin/bash

tput reset
tput civis

show_orange() {
    echo -e "\e[33m$1\e[0m"
}

show_blue() {
    echo -e "\e[34m$1\e[0m"
}

show_green() {
    echo -e "\e[32m$1\e[0m"
}

show_red() {
    echo -e "\e[31m$1\e[0m"
}

exit_script() {
    show_red "Скрипт остановлен (Script stopped)"
        echo
        exit 0
}

incorrect_option () {
    echo
    show_red "Неверная опция. Пожалуйста, выберите из тех, что есть."
    echo
    show_red "Invalid option. Please choose from the available options."
    echo
}

process_notification() {
    local message="$1"
    show_orange "$message"
    sleep 1
}

run_commands() {
    local commands="$*"

    if eval "$commands"; then
        sleep 1
        echo
        show_green "Успешно (Success)"
        echo
    else
        sleep 1
        echo
        show_red "Ошибка (Fail)"
        echo
    fi
}

run_commands_info() {
    local commands="$*"

    if eval "$commands"; then
        sleep 1
        echo
        show_green "Успешно (Success)"
        echo
    else
        sleep 1
        echo
        show_blue "Не найден (Not Found)"
        echo
    fi
}

run_node_command() {
    local commands="$*"

    if eval "$commands"; then
        sleep 1
        show_green "НОДА ЗАПУЩЕНА (NODE IS RUNNING)!"
        echo
    else
        show_red "НОДА НЕ ЗАПУЩЕНА (NODE ISN'T RUNNING)!"
        echo
    fi
}

print_logo () {
    echo
    show_orange "   _______  __           ___        ______  __   _______ .______ " && sleep 0.2
    show_orange "  /  _____||  |         /   \      /      ||  | |   ____||   _  \ " && sleep 0.2
    show_orange " |  |  __  |  |        /  ^  \    |  ,----'|  | |  |__   |  |_)  | " && sleep 0.2
    show_orange " |  | |_ | |  |       /  /_\  \   |  |     |  | |   __|  |      / " && sleep 0.2
    show_orange " |  |__| | |   ----. /  _____  \  |   ----.|  | |  |____ |  |\  \----. " && sleep 0.2
    show_orange "  \______| |_______|/__/     \__\  \______||__| |_______|| _|  ._____| " && sleep 0.2
    echo
    sleep 1
}

while true; do
    print_logo
    show_green "------ MAIN MENU ------ "
    echo "1. Подготовка (Preparation)"
    echo "2. Установка (Installation)"
    echo "3. Управление (Operational menu)"
    echo "4. Логи (Logs)"
    echo "5. Удаление (Delete)"
    echo "6. Выход (Exit)"
    echo
    read -p "Выберите опцию (Select option): " option

    case $option in
        1)
            #PREPARATION
            run_commands "cd $HOME && sudo apt update && sudo apt upgrade -y && apt install unzip screen"
            echo
            show_green "--- ПОГОТОВКА ЗАЕРШЕНА. PREPARATION COMPLETED ---"
            echo
            ;;
        2)
            # INSTALLATION
            process_notification "Установка (Installation)..."
            echo

            process_notification "Скачиваем (Downloading)..."
            mkdir $HOME/glacier && cd $HOME/glacier
            run_commands "wget https://github.com/Glacier-Labs/node-bootstrap/releases/download/v0.0.2-beta/verifier_linux_amd64"
            run_commands "wget https://glacier-labs.github.io/node-bootstrap/config.yaml"
            cd $HOME/glacier && sudo chmod +x verifier_linux_amd64

            process_notification "Настраиваем (Tunning)..."
            read -p "Введите (Enter) Private key :" PRIVATE_KEY

            FILE="$HOME/glacier/config.yaml"

            if [[ -f "$FILE" ]]; then
                sed -i "s|^\(\s*PrivateKey:\s*\).*|\1\"$PRIVATE_KEY\"|" "$FILE"
                show_green "FILE UPDATED"
            else
                show_red "FILE NOT FOUND"
            fi
            echo
            show_orange "---- CONF ----"
            cat $HOME/glacier/config.yaml
            show_orange "--------------"
            echo
            show_green "--- УСТАНОВЛЕНА. INSTALLED ---"
            echo
            ;;
        3)
            # OPERATING
            echo
            while true; do
                show_green "------ OPERATIONAL MENU ------ "
                echo "1. Зaпуск (Start)"
                echo "2. Остановка (Stop)"
                echo "3. Выход (Exit)"
                echo
                read -p "Выберите опцию (Select option): " option
                echo
                case $option in
                    1)
                        process_notification "Запускаем (Starting)..."
                        sleep 1
                        screen -dmS glacier bash -c "cd $HOME/glacier && exec ./verifier_linux_amd64" && screen -r glacier
                        ;;
                    2)
                        process_notification "Останавливаем (Stopping)..."
                        sleep 1
                        screen -r glacier -X quit
                        ;;
                    3)
                        break
                        ;;
                    *)
                        incorrect_option
                        ;;
                esac
            done
            ;;
        4)
            # LOGS
            process_notification "Подключаемся (Connecting)..." && sleep 2
            screen -r glacier
            ;;
        5)
            # DELETE
            process_notification "Удаление (Deleting)..."
            echo
            while true; do
                read -p "Удалить ноду? Delete node? (yes/no): " option

                case "$option" in
                    yes|y|Y|Yes|YES)
                        process_notification "Останавливаем (Stopping)..."
                        run_commands_info "screen -r glacier -X quit"

                        process_notification "Чистим (Cleaning)..."
                        run_commands "rm -rvf $HOME/glacier"

                        show_green "--- НОДА УДАЛЕНА. NODE DELETED. ---"
                        break
                        ;;
                    no|n|N|No|NO)
                        process_notification "Отмена (Cancel)"
                        echo ""
                        break
                        ;;
                    *)
                        incorrect_option
                        ;;
                esac
            done
            ;;
        6)
            exit_script
            ;;
        *)
            incorrect_option
            ;;
    esac
done
