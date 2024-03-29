green () {
	text=$1
	echo "\e[32m${text}\033[39m"
}

red () {
	text=$1
	echo "\e[31m${text}\033[39m"
}

for x in /proc/asound/card*/pcm*/sub*/status; do
	state=$(cat $x)
	alsa_device=$(dirname ${x#*/asound/})
	io=$(cat "$(dirname ${x})/info" | grep stream | cut -d ':' -f 2 | xargs)
	if [ "$state" != "closed" ]; then
		owner_pid=$(cat $x | grep owner_pid | cut -d ":" -f 2 | xargs)
		owner_name=$(ps | grep ${owner_pid} | grep -v grep)
		if [ -z "$owner_name" ]; then
			owner_name=$owner_pid
		fi
		printf "[$(green RUNNING)] ${alsa_device} ( ${io} )\n"
		echo "	owner: $owner_name"
	else
		printf "[$(red X)] ${alsa_device} ( ${io} )\n"
	fi
done
