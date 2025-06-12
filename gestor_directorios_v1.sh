#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#----------------COLORES PARA DISEÑO BONITO----------------------------------------------------------------------------------------------------------------
verde='\e[32m'
rojo='\e[31m'
azul='\e[34m'
amarillo='\e[33m'
reset='\e[0m'


#==================FUNCIONES DE NUESTRO SUPER MEGA GESTOR DE DIRECTORIOS===================================================================================
#detectar entorno en el que estamos trabajando-------------------------------------------------------------------------------------------------------------
if grep -qi microsoft /proc/version; then
	entorno="WSL"
else
	entorno="Linux Nativo"
fi

#mostrar ayuda y que hace el script------------------------------------------------------------------------------------------------------------------------
function mostrar_ayuda() {
	echo -e "${azul}¿Que es lo que puede hacer este gestor de directorios?${reset}"
	echo "\nTodo esto:"
	echo " --menu"
	echo "          Inicia el menu interactivo para que puedas elegir entre las opciones"
	echo " --listar <ruta>"
	echo "          Lista los contenidos del directorio que especifiques"
	echo " --crear <ruta>"
	echo "          Crea un directorio o una estructura que ingreses manualmente"
	echo " --plantilla <tipo> <ruta>"
	echo "          Crea una estructura del tipo que selecciones en la ruta que ingreses"
	echo " --crear-plantilla"
	echo "          Crea una nueva plantilla personalizada"
	echo " --borrar <ruta>"
	echo "          Mueve el directorio a una papelera interna, por si acaso"
	echo " --backup <ruta>"
	echo "          Crea un backup .tar.gz con la fecha"
	echo " --restaurar <archivo>"
	echo "          Restaura el backup indicado"
	echo " --renombrar <nombre actual> <nombre nuevo>"
	echo "          Cambia el nombre del directorio seleccionado por el nuevo ingresado"
	echo " --buscar <nombre> <ruta>"
	echo "          Busca un archivo o carpeta dentro de la ruta que especificaste"
	echo " --limpiar <ruta>"
	echo "          Elimina las carpetas vacías en la ruta"
	echo " --clonar <origen> <destino>"
	echo "          Replica la estructura de directorios del origen, en el destino ingresado"
	echo " --stats <ruta>"
	echo "          Muestra estadísticas de la estructura, como cantidad de archivos y de carpetas"
	echo " --help"
	echo "          Ya estas acá, esta es la ayuda"
}

#plantillas predefinidas por nosotros-------------------------------------------------------------------------------------------------------------------------
declarar_plantillas() {
	plantilla_software=(src bin docs tests)
	plantilla_estudio=(apuntes tps examenes resumenes)
	plantilla_playlists=(house techno rock rocknacional metal folklore)

	if [ -f "$HOME/.plantilla_personal.txt" ]; then
		mapfile -t plantilla_personal < "$HOME/.plantilla_personal.txt"
	else
		plantilla_personal=()
	fi
}

#validacion de ruta-------------------------------------------------------------------------------------------------------------------------------------
validar_ruta() {
	if [ ! -d "$1" ]; then
		echo -e "${rojo}EY EY, ERROR, LA RUTA '$1' NO EXISTE${reset}"
		return 1
	else
		echo -e "${verde}excelente corazón la ruta '$1' es validísima${reset}"
		return 0
	fi
}

#crear papelera interna si no existe-------------------------------------------------------------------------------------------------------------------
[ ! -d "$HOME/.gestor_papelera" ] && mkdir -p "$HOME/.gestor_papelera"

#crear plantilla personalizada ----------------------------------------------------------------------------------------------------------------------------
crear_plantilla_pers() {
	echo -e "${azul} Creando plantillas a tu gusto${reset}"
	echo "Ingresa los nombres de las carpetas (una por linea)"
	echo "Cuando termines, finaliza con una linea vacia"
	> "$HOME/.plantilla_personal.txt
	while true; do
		read -p "->" nombre
		[[ -z "$nombre" ]] && break
		echo "$nombre" >> "$HOME/.plantilla_personal.txt"
	done
	echo -e "${verde}felicitaciones! ya guardaste esta plantilla como 'personal'${reset}"
}

#========================MENU INTERACTIVO============================================================================================================
menu() {
	declarar_plantillas
	while true; do
		echo -e "${amarillo}============ SUPER MEGA COOL GESTOR DE DIRECTORIOS ======================================${reset}"
		echo "1) Listar directorios"
		echo "2) Crear nuevo directorio"
		echo "3) Crear estructura desde plantilla"
		echo "4) Borrar directorio"
		echo "5) Crear backup"
		echo "6) Restaurar backup"
		echo "7) Renombrar directorio"
		echo "8) Buscar en estructura"
		echo "9) Limpiar carpetas vacías"
		echo "10) Clonar estructura"
		echo "11) Ver estadísticas de estructura"
		echo "12) Consultar entorno"
		echo "13) Crear nueva plantilla"
		echo "14) Salir"
		echo -e "${amarillo}=====================================================================================${reset}"
		read -p "Elegí una opción, dale: " opcion

		case $opcion in
			1) read -p "Ruta a listar: " r; ls -l "$r";;
			2) read -p "Ruta a crear: " r; mkdir -p "$r" && echo -e "${verde}Creado correctamente${reset}";;
			3) read -p "Tipo de plantilla (software/estudio/personalizada): " t; read -p "Ruta destino: " r; crear_plantilla_pers $t "$r";;
			4) read -p "Ruta a borrar: " r; mv "$r" "$HOME/.gestor_papelera/" && echo -e "${amarillo}Movido a la papelera${reset}";;
			5) read -p "Ruta a respaldar: " r; tar -czf "backup_$(date +%F_%H-%M-%S).tar.gz" "$r" && echo -e "${verde}Backup exitoso${reset}";;
			6) read -p "Archivo .tar.gz a recuperar :" f; tar -xzf "$f" && echo -e "${verde}Restaurado exitosamente${reset}";;
			7) read -p "Nombre de la ruta actual: " a; read -p "Nuevo nombre: " n; mv "$a" "$n" && echo -e "${verde}Ruta renombrada${reset}";;
			8) read -p "Nombre a buscar: " n; read -p "Ruta base: " r; find "$r" -iname "$n";;
			9) read -p "Ruta base: " r; find "$r" -type d -empty -delete && echo -e "${verde}Carpetas vacías eliminadas${reset}";;
		       10) read -p "Origen: " o, read -p "Destino: " d; clonar_estructura "$o" "$d";;
		       11) read -p "Ruta: " r; mostrar_stats "$r";;
		       12) echo -e "Te encuentras en ${amarillo}$entorno${reset}";;
		       13) crear_plantilla_pers;;
		       14) break;;
			*) echo -e "${rojo}Esta no es una opcion valida, intentalo de nuevo${reset}";;
		esac

		read -p "Presioná Enter para continuar..."
	done

}

#funciones de plantilla---------------------------------------------------------------------------------
crear_plantilla() {
	declarar_plantillas
	case $1 in
		software)
			for d in "${plantilla_software[@]}"; do mkdir -p "$2/$d"; done
			;;
		estudio)
			for d in "${plantilla_estudio[@]}"; do mkdir -p "$2/$d"; done
			;;
		personal)
			for d in "${plantilla_personal[@]}"; do mkdir -p "$2/$d"; done
			;;
		*) echo -e "${rojo}Tipo de plantilla no disponible${reset}";;
	esac
}

#clonar estructura---------------------------------------------------------------------------------------
clonar_estructura() {
	cd "$1"
	find . -type d -exec mkdir -p "$2/{}" \;
	echo -e "${verde}Estructura clonada${reset}"
}

#mostrar stats----------------------------------------------------------------------------------------------
mostrar_stats() {
	total=$(find "$1" -type d | wc -l)
	prof=$(find "$1" -type d | awk -F/ '{print NF} | sort -n | tail -1)
	echo -e "${azul}Estadisticas de '$1'${reset}"
	echo "Total de directorios: $total"
	echo "Profundidad maxima: $prof"
	echo "Subdirectorios por nivel:"
	find "$1" -type d | awk -F/ '{print NF-1}' | sort | uniq -c
}

#========================================================EJECUTAR CON ARGUMENTOS=====================================================================================
case "$1" in
	--menu) menu ;;
	--help) mostrar_ayuda ;;
	--entorno) echo -e "Te encuentras en ${amarillo}$entorno${reset}" ;;
	--listar) validar_ruta "$2" && ls -l "$2" ;;
	--crear) mkdir -p "$2" && echo -e "${verde}Creado correctamente${reset}" ;;
	--plantilla) crear_plantilla "$2" "$3" ;;
	--borrar) mv "$2" "$HOME/.gestor_papelera/" && echo -e "${amarillo}Movido a la papelera${reset}" ;;
	--backup) tar -czf "backup_$(date +%F_%H-%M-%S).tar.gz" "$2" && echo -e "${verde}Backup exitoso${reset}" ;;
	--restaurar) tar -xzf "$2" && echo -e "${verde}Backup recuperado${reset}" ;;
	--renombrar)mv "$2" "$3" && echo -e "${verde}Ruta renombrada${reset}" ;;
	--buscar) find "$3" -iname "$2" ;;
	--limpiar) find "$2" -type d -empty -delete && echo -e "${verde}Carpetas vacias eliminadas${reset}" ;;
	--clonar) clonar_estructura "$2" "$3" ;;
	--stats) mostrar_Stats "$2" ;;
	--crear-plantilla) crear_plantilla_pers ;;
	*) echo -e "${rojo}Este comando no es valido, usa '--help' para guiarte${reset}" ;;
esac





















