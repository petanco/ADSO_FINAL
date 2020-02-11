#!/bin/bash

# Temp folder and variables
# Name some variables and create temporary folder and files to use
$(mkdir /tmp/parseador_ldif.$$)
OUTPUT=/tmp/parseador_ldif.$$/output.$$
INPUT=/tmp/parseador_ldif.$$/input.$$
let vUser
let vDirectorio
let vUID
vGrupo=2000
backtitle="Gestión de usuarios"

# Delete temp files if program is closed or closes
trap "rm -dr /tmp/parseador_ldif*; exit" SIGHUP SIGINT SIGTERM

# Functions to be used in the script will be put here

# User input dialog
function show_inputUserName(){
	dialog --title "[ U S E R N A M E ]" \
	--backtitle "$backtitle" \
	--inputbox "Escriba el nombre de usuario " 8 60 "$vUser" 2>$INPUT
	vUser=$(cat $INPUT)
	ITEM="Usuario"
}

# Group input dialog
function show_inputGrupo(){
	dialog --title "[ D O M I N I O ]" \
	--backtitle "$backtitle" \
	--inputbox "Escriba el GID del grupo al que quiere pertenecer (recomendable, '2000') " 8 60 "$vGrupo" 2>$INPUT
	vGrupo=$(cat $INPUT)
	ITEM="Grupo"
}

# Home directory input dialog
function show_inputDirectorio(){
	dialog --title "[ D I R E C T O R I O ]" \
	--backtitle "$backtitle" \
	--inputbox "Escriba el nombre del directorio home del usuario (ejemplo: '/home/pepe')" 8 60 "$vDirectorio" 2>$INPUT
	vDirectorio=$(cat $INPUT)
	ITEM="Directorio"
}

# UID input dialog
function show_inputUID(){
	dialog --title "[ U I D ]" \
	--backtitle "$backtitle" \
	--inputbox "Escriba un UID de usuario (recomendado mayor que 1000) " 8 60 "$vUID" 2>$INPUT
	vUID=$(cat $INPUT)
	ITEM="UID"
}

function show_datos(){	
	dialog  --clear \
			--title "[-- I N F O --]" \
			--backtitle "$backtitle" \
			--ok-label "Datos actuales en el fichero '/etc/passwd'" \
			--textbox /etc/passwd 10 40
}


# Checking dialog
function check(){
	dialog  --clear \
			--title "[-- I N F O --]" \
			--backtitle "$backtitle" \
			--ok-label "Datos a introducir" \
			--msgbox " Nombre de usuario: $vUser
			Grupo: $vGrupo
			UID: $vUID
			Directorio: $vDirectorio" 10 40
}

# What to do when every variable is set
# Check if they are set and double check it to user before adding it to the LDAP
function continuar(){
	ITEM="Salir"
	if [ -z "$vUser" ]
		then
			error_nenough
	elif [ -z "$vDirectorio" ]
		then
			error_nenough
	elif [ -z "$vUID" ]
		then
			error_nenough
	elif [ -z "$vGrupo" ]
		then
			error_nenough	
	else
		dialog  --clear \
			--title "[-- I N F O --]" \
			--backtitle "$backtitle" \
			--ok-label "Crear LDIF" \
			--msgbox " Nombre del admin: $vAdmin
			Dominio: $vDominio.$vExtension
			Ruta del CSV: $vCSV" 10 40
		exit_status=$?
		if [ $exit_status -eq 0 ]
			then
				dialog  --clear \
					--title "[ C O N F I R M A C I Ó N ]" \
					--backtitle "$backtitle" \
					--yes-label "Si" \
					--yesno "Confirme que desea continuar (no podrá deshacer cambios una vez añadido el LDIF)" 10 40
				answer_option=$?
				if  [ $answer_option -eq 0 ]
					then
						# Get last uidNumber to begin adding from that one
						getLast

						# Loop to create .ldif
						ldif_loop

						# Show first & last ldif entries
						ldifShowFL

						# Add entries to LDAP
						ldapadd -x -D cn=$vAdmin,dc=$vDominio,dc=$vExtension -W -f /tmp/parseador_ldif.$$/script_addUsers.ldif

						# Show last two added LDAP users
						slapcat | tail -44 > $OUTPUT
						dialog  --clear \
							--title "[ L A S T - C H E C K ]" \
							--backtitle "$backtitle" \
							--exit-label "Salir" \
							--textbox $OUTPUT 40 40
				fi
		fi
	fi
}

# If variables are not set and continuar happens, error return
function error_nenough() {
        dialog  --clear \
                --title "[-- I N F O --]" \
                --backtitle "$backtitle" \
                --msgbox "Falta información, comprueba las opciones" 7 40
}

# Main loop of the program
#------------------------------ MAIN MENU ------------------------------
while true; do
	dialog --backtitle "$backtitle" \
	--title "[ M E N U ]" \
	--default-item "$ITEM" \
	--menu "Seleccione las siguientes opciones:"	0 0 6 \
	Usuario "Indique nombre de usuario deseado" \
	Grupo "Indique el grupo del usuario" \
	Directorio "Indique directorio Home para el usuario" \
	UID "Indique un UID para el usuario" \
	Datos "Visualizar los datos de los usuarios actuales" \
	Comprobar "Haz click aqui para comprobar todo antes de continuar" \
	Añadir "Agregar el usuario al sistema" \
	Salir "Salir del programa" 2>$INPUT

	selection=$(cat $INPUT)

  case $selection in
	Usuario)
		show_inputUserName;;
	Grupo)
		show_inputGrupo;;
	Directorio)
		show_inputDirectorio;;
	UID)
    		show_inputUID;;
	Datos)
		show_datos;;
	Comprobar)
		check;;
	Añadir)
		add;;
	Salir)
		echo "Programa cerrado"; break;;
  esac
done
exit 0


vUser:x:vUID:vGrupo:vUser:vDirectorio:/bin/bash


/etc/passwd file:
	login name
	encrypted password (passwd username) /etc/shadow
	uid number
	gid number (groups in /etc/group)
	user info: name...
	home directory (mkdir /home/username | chown username:research /home/username | chmod 700 /home/username)
		cp /etc/skel/.[a-zA-Z]*~username
		chmod 644 ~username/.[a-zA-Z]*
		chown username:research ~username/.*
	login shell (/bin/bash)
	
/etc/group file:
	groupname
	password
	gid
	user-list

