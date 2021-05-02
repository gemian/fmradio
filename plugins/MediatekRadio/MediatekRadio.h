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

#ifndef MEDIATEKRADIO_H
#define MEDIATEKRADIO_H

#include <QObject>
#include <QtQml>

enum OutputValue {
	OutputUnspecified,
	OutputEarpiece,
	OutputSpeaker,
	OutputHeadset,
	OutputHeadphone,
	OutputBluetoothSco,
	OutputScoHeadset,
	OutputScoCarKit,
	OutputSpeakerAndHeadphone,
};

class MediatekRadio : public QObject {
	Q_OBJECT
	Q_PROPERTY(int outputDevice READ outputDevice WRITE setOutputDevice NOTIFY outputDeviceChanged)
	Q_PROPERTY(bool earpieceAvailable READ earpieceAvailable NOTIFY outputAvailabilityChanged)
	Q_PROPERTY(bool speakerAvailable READ speakerAvailable NOTIFY outputAvailabilityChanged)
	Q_PROPERTY(bool wiredHeadsetAvailable READ wiredHeadsetAvailable NOTIFY outputAvailabilityChanged)
	Q_PROPERTY(bool wiredHeadphoneAvailable READ wiredHeadphoneAvailable NOTIFY outputAvailabilityChanged)
	Q_PROPERTY(bool bluetoothScoAvailable READ bluetoothScoAvailable NOTIFY outputAvailabilityChanged)
	Q_PROPERTY(bool scoHeadsetAvailable READ scoHeadsetAvailable NOTIFY outputAvailabilityChanged)
	Q_PROPERTY(bool scoCarKitAvailable READ scoCarKitAvailable NOTIFY outputAvailabilityChanged)
	Q_PROPERTY(bool speakerAndHeadphoneAvailable READ speakerAndHeadphoneAvailable NOTIFY outputAvailabilityChanged)
	Q_PROPERTY(bool radioRunning READ isRadioRunning NOTIFY radioRunningChanged)

private:
	bool _radioRunning = false;
	bool _earpieceAvailable = false;
	bool _speakerAvailable = false;
	bool _wiredHeadsetAvailable = false;
	bool _wiredHeadphoneAvailable = false;
	bool _bluetoothScoAvailable = false;
	bool _scoHeadsetAvailable = false;
	bool _scoCarKitAvailable = false;
	bool _speakerAndHeadphoneAvailable = false;
	int outputSink = -1;
	int fmSource = -1;
	int frequency = 10250;
	int idx = -1;
	int _outputDevice;

	void preparePulseAudio();
	void mute();
	void unmute();
	bool isHeadsetAvailable();
	int getRssi();
	void startVolumeUpdater();
	void stopVolumeUpdater();

public:
	MediatekRadio();
	~MediatekRadio() override /* = default*/;

	Q_INVOKABLE QByteArray startRadio(int);
	Q_INVOKABLE QByteArray stopRadio();
	Q_INVOKABLE void tune(int);
	Q_INVOKABLE int getFrequency();
	Q_INVOKABLE int seekUp();
	Q_INVOKABLE int seekDown();

	int outputDevice() const;
	void setOutputDevice(int outputValue);

	bool earpieceAvailable();
	bool speakerAvailable();
	bool wiredHeadsetAvailable();
	bool wiredHeadphoneAvailable();
	bool bluetoothScoAvailable();
	bool scoHeadsetAvailable();
	bool scoCarKitAvailable();
	bool speakerAndHeadphoneAvailable();

	bool isRadioRunning();

Q_SIGNALS:
	void outputDeviceChanged();
	void outputAvailabilityChanged();
	void radioRunningChanged();

private:
	void findFMSource();
};

QML_DECLARE_TYPE(MediatekRadio)

#endif
