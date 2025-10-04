#!/bin/bash
set -e



yellow=$(tput setaf 3)

white=$(tput sgr0)

magenta=$(tput setaf 5)

green=$(tput setaf 2)

export_script_path(){
  files=(.bashrc .zshrc .bash_profile)
  for f in ${files[@]}; do
    filename="$HOME/$f"

    if [ -f $filename  ]; then
      if ! $(grep 'rd/web/scripts' $filename &>/dev/null);
      then
        echo "Adding rd script to $f ..."

        echo >> $filename
        echo '# rd' >> $filename
        echo "export PATH=\"\$PATH:$(pwd)\"" >> $filename

        echo "Done!"
        echo
        echo "Now please run the command ${yellow}'source ~/$f'${white} manually and then try to use the ${yellow}'rd'${white} command"
      fi
    fi
  done
}

run(){
  echo "docker compose run --rm $args web $@"
  docker compose run --rm $args web $@
}


case $1 in
    setup)
        export_script_path
    ;;
    start)
        docker compose up
    ;;
    stop)
        docker compose stop
    ;;
    sh)
        run bash
    ;;
    run)
        run ${@:2}
    ;;
    console)
        run bundle exec rails c  ${@:2}
    ;;
    debug)
        if $(docker compose exec web /bin/true &>/dev/null); then
            start_back=true
            docker compose stop web
        else
            start_back=false
        fi

        docker compose run --service-ports --rm --use-aliases web

        if $start_back; then docker compose start web; fi
    ;;
    *)

    echo 'This is the RD STATION script you can use to run console, bash, test and other useful stuff.'
    echo
    echo "Usage: ${yellow}rd <option> <arguments>${white}"
    echo
    echo "Examples:${yellow}"
    echo '  rd start'
    echo '  rd run ls'
    echo
    echo "${white}Available options:"
    echo ""
    echo "GENERAL"
    echo "${yellow} start:${white} brings up rd-commerce"
    echo "${yellow} stop:${white} shutdown rd-commerce"
    echo "${yellow} sh:${white} brings up a bash session from rd-commerce container"
    echo "${yellow} run:${white} tuns a given command inside the container"
    echo "${yellow} console:${white} rails console"
    echo "${yellow} debug:${white} start a debug session"

    ;;
esac