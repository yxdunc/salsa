# salsa
Simple ALSA. This repository is a set of tools that ease the configuration of ALSA

## Usage

### Main script:

`sh get_usage.sh`

or

`watch -n1 "sh get_usage.sh"` (will show the output of the script continuously with a refresh every second)


# ALSA

## I. Concepts:

### What is the difference between `pcm.!default` and `ctl.!default` ?

The answer is pretty simple yet not easy to find online...

`pcm.!default` will define the default card used for playback and capture. It's refered to as the **PCM card.**

`ctl.!default` will define the default card that is affected when changing the sound level or tuning any settings via for example: `alsamixer`. It's refered to as the **Control card.**

## II. Useful tools:

## Multiple read microphone (DSNOOP)

When several processes need to access the same microphone.

## Single read speaker (Loopback device)

The loopback device lets you play some audio that can then be captured by another devices **as if it was a microphone**.

⚠️ Your loopback device can be loaded as any card index. (card 0/card 1/...)

### Correspondance:

Given that the loopback device is loaded on card 1 (`hw:1`)

Any sound that will be played to `hw:1,0,1` can be recorded here `hw:1,1,1`.

`hw:1,0,0` —> `hw:1,1,0`

`hw:1,0,1` —> `hw:1,1,1`

`hw:1,0,2` —> `hw:1,1,2`

...

When you want to access the output of a speaker as if it was a microphone.

## Multiple write speaker (DMIX)

When multiple processes need to send audio to the same speaker.


## III. Example configs:

### Use different cards for capture and playback

Inside `pcm.!default` you can use the module `asym` and set a different card for playback and capture.

```
    pcm.!default {
        type asym
        playback.pcm "plughw:0"
        capture.pcm  "plughw:1"
    }
```

⚠️ This is not possible to do something like this for the control device (`ctl`).

### Enable multiple input / output on default device.

source :[https://stackoverflow.com/a/14398926/5530191](https://stackoverflow.com/a/14398926/5530191)

```
    pcm.dmixed {
        type dmix
        ipc_key 1024
        ipc_key_add_uid 0
        slave.pcm "hw:0,0"
    }
    pcm.dsnooped {
        type dsnoop
        ipc_key 1025
        slave.pcm "hw:0,0"
    }
    
    pcm.duplex {
        type asym
        playback.pcm "dmixed"
        capture.pcm "dsnooped"
    }
    
    # Instruct ALSA to use pcm.duplex as the default device
    pcm.!default {
        type plug
        slave.pcm "duplex"
    }
    ctl.!default {
        type hw
        card 0
    }
```

This does the following:

- creates a new device using the `dmix` plugin, which allows multiple apps to share the output stream
- creates another using `dsnoop` which does the same thing for the input stream
- merges these into a new `duplex` device that will support input and output using the `asym` plugin
- tell ALSA to use the new `duplex` device as the default device
- tell ALSA to use `hw:0` to control the default device (alsamixer and so on)

Stick this in either `~/.asoundrc` or `/etc/asound.conf` and you should be good to go.
