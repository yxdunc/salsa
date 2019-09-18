for x in /proc/asound/card*/pcm*/sub*/status; do
	state=$(cat $x)
	alsa_device=$(dirname ${x#*/asound/})
	io=$(cat "$(dirname ${x})/info" | grep stream | cut -d ':' -f 2 | xargs)
	if [ "$state" != "closed" ]; then
		owner_pid=$(cat $x | grep owner_pid | sed -r "s/owner_pid +: +*([0-9]*).*/\1/")
		owner_name=$(ps | grep ${owner_pid} | grep -v grep)
		echo "[RUNNING] ${alsa_device} ( ${io} )"
		echo "	owner: $owner_name"
	else
		echo "[X] ${alsa_device} ( ${io} )"
	fi
done
