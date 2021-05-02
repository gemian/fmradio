/*
 * Copyright (C) 2020 venji10 <bennisteinir@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


#include <stdio.h>

#include <sys/ioctl.h>
#include <linux/ioctl.h>
#include <string.h>
#include <iostream>
#include <thread>

#include "MediatekRadio.h"
#include "common.cpp"

#define FM_DEV_NAME "/dev/fm"

#define FM_BAND_UE      1 // US/Europe band  87.5MHz ~ 108MHz (DEFAULT)
#define FM_BAND_JAPAN   2 // Japan band      76MHz   ~ 90MHz
#define FM_BAND_JAPANW  3 // Japan wideband  76MHZ   ~ 108MHz
#define FM_BAND_SPECIAL 4 // special   band  between 76MHZ   and  108MHz

static const char *const outputWiredHeadset = "output-wired_headset";
static const char *const outputWiredHeadphone = "output-wired_headphone";
static const char *const outputSpeaker = "output-speaker";
static const char *const outputSpeakerAndHeadphone = "output-speaker+wired_headphone";
static const char *const outputEarpiece = "output-earpiece";
static const char *const outputBluetoothSco = "output-bluetooth_sco";
static const char *const outputScoHeadset = "output-sco_headset";
static const char *const outputScoCarkit = "output-sco_carkit";

MediatekRadio::MediatekRadio() {

}

// check if headset/headphones are connected, they are act as antenna
bool MediatekRadio::isHeadsetAvailable() {
	FILE *fp;
	char path[255];
	bool ret = false;

	fp = popen("/usr/bin/pactl list sinks | /bin/grep \"output-\\|Sink #\\|Active Port:\"", "r");

	if(fp == nullptr) {
		printf("error checking for headset");
		return false;
	}

	while (fgets(path, sizeof(path), fp) != nullptr) {
		if (strstr(path, "Sink #")) {
			if (ret) {
				break;
			}
			char *number = &path[6];
			outputSink = atoi(number);
			_earpieceAvailable = false;
			_speakerAvailable = false;
			_wiredHeadsetAvailable = false;
			_wiredHeadphoneAvailable = false;
			_bluetoothScoAvailable = false;
			_scoHeadsetAvailable = false;
			_scoCarKitAvailable = false;
			_speakerAndHeadphoneAvailable = false;
		}
		if (strstr(path, "Active Port:")) {
			if (strstr(path, outputEarpiece)) {
				_outputDevice = OutputEarpiece;
			}
			if (strstr(path, outputSpeaker)) {
				_outputDevice = OutputSpeaker;
			}
			if (strstr(path, outputWiredHeadset)) {
				_outputDevice = OutputHeadset;
			}
			if (strstr(path, outputWiredHeadphone)) {
				_outputDevice = OutputHeadphone;
			}
			if (strstr(path, outputBluetoothSco)) {
				_outputDevice = OutputBluetoothSco;
			}
			if (strstr(path, outputScoHeadset)) {
				_outputDevice = OutputScoHeadset;
			}
			if (strstr(path, outputScoCarkit)) {
				_outputDevice = OutputScoCarKit;
			}
			if (strstr(path, outputSpeakerAndHeadphone)) {
				_outputDevice = OutputSpeakerAndHeadphone;
			}
		}
		if (strstr(path, ", available")) {
			if (strstr(path, outputEarpiece)) {
				printf("earpiece available\n");
				_earpieceAvailable = true;
			}
			if (strstr(path, outputSpeaker)) {
				printf("speaker available\n");
				_speakerAvailable = true;
			}
			if (strstr(path, outputWiredHeadset)) {
				printf("headset available\n");
				_wiredHeadsetAvailable = true;
				ret = true;
			}
			if (strstr(path, outputWiredHeadphone)) {
				printf("headphone available\n");
				_wiredHeadphoneAvailable = true;
				ret = true;
			}
			if (strstr(path, outputBluetoothSco)) {
				printf("bluetooth sco available\n");
				_bluetoothScoAvailable = true;
			}
			if (strstr(path, outputScoHeadset)) {
				printf("sco headset available\n");
				_scoHeadsetAvailable = true;
			}
			if (strstr(path, outputScoCarkit)) {
				printf("sco car kit available\n");
				_scoCarKitAvailable = true;
			}
			if (strstr(path, outputSpeakerAndHeadphone)) {
				printf("speaker and headphone available\n");
				_speakerAndHeadphoneAvailable = true;
			}
		}
	}

	emit outputDeviceChanged();
	emit outputAvailabilityChanged();

	pclose(fp);
	return ret;
}

void MediatekRadio::findFMSource() {
	FILE *fp;
	char path[255];

	fp = popen("/usr/bin/pactl list sources | /bin/grep \"input-fm_tuner\\|Source #\"", "r");

	if(fp == nullptr) {
		printf("error checking for fm source");
		return;
	}

	while (fgets(path, sizeof(path), fp) != nullptr) {
		if (strstr(path, "Source #")) {
			char *number = &path[8];
			fmSource = atoi(number);
		}
		if (strstr(path, ", available")) {
			if (strstr(path, "input-fm_tuner")) {
				printf(" - found tuner\n");
				pclose(fp);
				return;
			}
		}
	}

	pclose(fp);
}

// This is needed to route the FM input to the headphones
void MediatekRadio::preparePulseAudio() {
	int ret;
	char buf[255];

	if (fmSource == -1) {
		findFMSource();
	}

	snprintf(buf, sizeof buf, "pacmd set-source-port %d input-fm_tuner", fmSource);
	ret = system(buf);
	printf("set fm-tuner %d\n",ret);
	snprintf(buf, sizeof buf, "pactl load-module module-loopback source=%d sink=%d", fmSource, outputSink);
	ret = system(buf);
	printf("loaded loopback %d\n",ret);
}

bool MediatekRadio::isRadioRunning() {
	return _radioRunning;
}

// Volume is always at 100% without this
void MediatekRadio::startVolumeUpdater() {

//	system("touch ~/.radioRunning");
//	system("while ( test -f ~/.radioRunning) do $(pactl set-source-volume 1 $(printf \"%.*f\\n\" 0 $(echo print $(dbus-send --session --type=method_call --print-reply --dest=com.canonical.indicator.sound /com/canonical/indicator/sound org.gtk.Actions.DescribeAll | grep -n5 \"string \\\"volume\\\"\" | grep double | cut -b 53-56)*65536 | perl))); done &");

}

void MediatekRadio::stopVolumeUpdater() {

//	system("rm ~/.radioRunning");
//	system("pactl set-source-volume 1 65536");

}

// Start the radio
QByteArray MediatekRadio::startRadio(int freq) {

	if(isHeadsetAvailable()) {

		int ret = 0;

		if((ret = COM_open_dev(FM_DEV_NAME, &idx)) < 0) {
			printf("error opening device: %d\n", ret);
			return "Error";
		}

		if((ret = COM_pwr_up(idx, FM_BAND_UE, freq)) < 0) {
			printf("error powering up: %d\n", ret);
			return "Error";
		}

		preparePulseAudio();

		_radioRunning = true;
		emit radioRunningChanged();
		startVolumeUpdater();

		return "Stop radio";
	} else {
		return "Headset not available";
	}

}

// Stop the radio
QByteArray MediatekRadio::stopRadio() {
	char buf[255];
	int ret = 0;

	if (!isRadioRunning()) {
		return "Start radio";
	}

	if((ret = COM_pwr_down(idx, 0)) < 0) {
		printf("error powering down: %d\n", ret);
		return "Error";
	}

	if((ret = COM_close_dev(idx)) < 0) {
		printf("error closing device; %d\n", ret);
		return "Error";
	}

	ret = system("pactl unload-module module-loopback");
	printf("unloaded loopback %d\n",ret);

	if (_wiredHeadsetAvailable) {
		snprintf(buf, sizeof buf, "pacmd set-source-port %d input-wired_headset", fmSource);
		ret = system(buf);
		printf("set source to headset %d\n",ret);
		snprintf(buf, sizeof buf, "pacmd set-sink-port %d output-wired_headset", outputSink);
		ret = system(buf);
		printf("set out to headset %d\n",ret);
	} else {
		snprintf(buf, sizeof buf, "pacmd set-source-port %d input-builtin_mic", fmSource);
		ret = system(buf);
		printf("set source to builtin_mic %d\n",ret);
		snprintf(buf, sizeof buf, "pacmd set-sink-port %d output-wired_headphone", outputSink);
		ret = system(buf);
		printf("set out to headphone %d\n",ret);
	}

	stopVolumeUpdater();

	_radioRunning = false;
	emit radioRunningChanged();

	return "Start radio";

}

// Tune to different frequency
void MediatekRadio::tune(int freq) {

	if(isRadioRunning()) {
		int ret;

		if((ret = COM_tune(idx, freq, FM_BAND_UE)) < 0) {
			printf("error tuning: %d\n", ret);
		}
	} else {
		printf("tune: radio not running\n");
	}

	frequency = freq;

}

void MediatekRadio::mute() {

	int ret;

	if((ret = COM_set_mute(idx, 1)) < 0) {
		printf("error muting: %d\n", ret);
	}

}

void MediatekRadio::unmute() {

	int ret;

	if((ret = COM_set_mute(idx, 0)) < 0) {
		printf("error unmuting: %d\n", ret);
	}


}

int MediatekRadio::getRssi() {

	int ret;
	int rssi;

	if((ret = COM_get_rssi(idx, &rssi)) < 0) {
		printf("error getting rssi: %d\n", ret);
		return -100;
	}

	return rssi;

}

int MediatekRadio::seekUp() {

	if(isRadioRunning()) {

		mute();

		bool foundStation = false;
		int tmp = frequency;

		for(int i = frequency + 10; i < 10800; i += 10) {
			tune(i);
			if(getRssi() > -75) {
				foundStation = true;
				break;
			}
		}

		if(!foundStation) {
			tune(tmp);
		}
		unmute();

	}

	return frequency;

}

int MediatekRadio::seekDown() {

	if(isRadioRunning()) {

		mute();

		bool foundStation = false;
		int tmp = frequency;

		for(int i = frequency - 10; i > 8750; i -= 10) {
			tune(i);
			if(getRssi() > -75) {
				foundStation = true;
				break;
			}
		}

		if(!foundStation) {
			tune(tmp);
		}
		unmute();

//		setOutputDevice(1+((double)rand()/RAND_MAX)*5);
//		emit outputDeviceChanged();
	}

	return frequency;

}

int MediatekRadio::getFrequency() {

	return frequency;

}

int MediatekRadio::outputDevice() const {
	printf("getOutputDevice: %d\n",_outputDevice);
	return _outputDevice;
}

void MediatekRadio::setOutputDevice(const int outputValue) {
	char buf[255];
	const char *outputName;
	printf("setOutputDevice: %d\n", outputValue);

	_outputDevice = outputValue;
	switch (outputValue) {
		case OutputHeadset:
			outputName = outputWiredHeadset;
			break;
		case OutputHeadphone:
			outputName = outputWiredHeadphone;
			break;
		case OutputSpeaker:
			outputName = outputSpeaker;
			break;
		case OutputSpeakerAndHeadphone:
			outputName = outputSpeakerAndHeadphone;
			break;
		case OutputEarpiece:
			outputName = outputEarpiece;
			break;
		case OutputBluetoothSco:
			outputName = outputBluetoothSco;
			break;
		case OutputScoHeadset:
			outputName = outputScoHeadset;
			break;
		case OutputScoCarKit:
			outputName = outputScoCarkit;
			break;
		default:
			break;
	}

	snprintf(buf, sizeof buf, "pacmd set-sink-port %d %s", outputSink, outputName);
	int ret = system(buf);
	printf("set out to %s %d\n", outputName, ret);
}

//    emit outputDeviceChanged();

//void MediatekRadio::outputDeviceChanged()
//{
//	QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
//}


MediatekRadio::~MediatekRadio() {

	stopRadio();

}

bool MediatekRadio::earpieceAvailable() {
	return _earpieceAvailable;
}

bool MediatekRadio::speakerAvailable() {
	return _speakerAvailable;
}

bool MediatekRadio::wiredHeadsetAvailable() {
	return _wiredHeadsetAvailable;
}

bool MediatekRadio::wiredHeadphoneAvailable() {
	return _wiredHeadphoneAvailable;
}

bool MediatekRadio::bluetoothScoAvailable() {
	return _bluetoothScoAvailable;
}

bool MediatekRadio::scoHeadsetAvailable() {
	return _scoHeadsetAvailable;
}

bool MediatekRadio::scoCarKitAvailable() {
	return _scoCarKitAvailable;
}

bool MediatekRadio::speakerAndHeadphoneAvailable() {
	return _speakerAndHeadphoneAvailable;
}

