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

import QtQuick 2.7
import Ubuntu.Components 1.3
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

import org.gemian.MediatekRadio 1.0

MainView {
	id: root
	objectName: 'mainView'
	applicationName: 'FM Radio'
	automaticOrientation: false

	//Fullscreen on device
	height: {
		if (Screen.height === 1080 && Screen.width === 2160) {
			Screen.height
		} else {
			432
		}
	}
	width: {
		if (Screen.height === 1080 && Screen.width === 2160) {
			Screen.width
		} else {
			864
		}
	}

	Shortcut {
	        sequence: StandardKey.Quit
	        context: Qt.ApplicationShortcut
	        onActivated: {
			MediatekRadio.stopRadio()
			Qt.quit()
		}
	}

	Page {

		anchors.fill: parent

		header: PageHeader {
			id: header
			title: i18n.tr('FM Radio')
		}

		GridLayout {
			columns: 4
			id: outputSelect

			anchors {
				top: parent.top
				margins: units.gu(2)
				left: parent.left
				right: parent.right
			}

			RadioButton {
				id: earpieceButton
				enabled: MediatekRadio.earpieceAvailable
				checked: MediatekRadio.outputDevice == 1
				text: qsTr("Earpiece")
				onClicked: MediatekRadio.outputDevice = 1
				Keys.onEnterPressed: MediatekRadio.outputDevice = 1
				Keys.onReturnPressed: MediatekRadio.outputDevice = 1
				KeyNavigation.left: seekDownButton
				KeyNavigation.right: speakerButton
				KeyNavigation.down: bluetoothScoButton
			}
			RadioButton {
				id: speakerButton
				enabled: MediatekRadio.speakerAvailable
				checked: MediatekRadio.outputDevice == 2
				text: qsTr("Speaker")
				onClicked: MediatekRadio.outputDevice = 2
				Keys.onEnterPressed: MediatekRadio.outputDevice = 2
				Keys.onReturnPressed: MediatekRadio.outputDevice = 2
				KeyNavigation.left: earpieceButton
				KeyNavigation.right: wiredHeadsetButton
				KeyNavigation.down: scoHeadsetButton
			}
			RadioButton {
				id: wiredHeadsetButton
				enabled: MediatekRadio.wiredHeadsetAvailable
				checked: MediatekRadio.outputDevice == 3
				text: qsTr("Headset")
				onClicked: MediatekRadio.outputDevice = 3
				Keys.onEnterPressed: MediatekRadio.outputDevice = 3
				Keys.onReturnPressed: MediatekRadio.outputDevice = 3
				KeyNavigation.left: speakerButton
				KeyNavigation.right: wiredHeadphoneButton
				KeyNavigation.down: scoCarKitButton
			}
			RadioButton {
				id: wiredHeadphoneButton
				enabled: MediatekRadio.wiredHeadphoneAvailable
				checked: MediatekRadio.outputDevice == 4
				text: qsTr("Headphone")
				onClicked: MediatekRadio.outputDevice = 4
				Keys.onEnterPressed: MediatekRadio.outputDevice = 4
				Keys.onReturnPressed: MediatekRadio.outputDevice = 4
				KeyNavigation.left: wiredHeadsetButton
				KeyNavigation.right: seekUpButton
				KeyNavigation.down: speakerAndHeadphoneButton
			}
			RadioButton {
				id: bluetoothScoButton
				enabled: MediatekRadio.bluetoothScoAvailable
				checked: MediatekRadio.outputDevice == 5
				text: qsTr("Bluetooth Sco")
				onClicked: MediatekRadio.outputDevice = 5
				Keys.onEnterPressed: MediatekRadio.outputDevice = 5
				Keys.onReturnPressed: MediatekRadio.outputDevice = 5
				KeyNavigation.up: earpieceButton
				KeyNavigation.left: seekDownButton
				KeyNavigation.right: scoHeadsetButton
				KeyNavigation.down: seekDownButton
			}
			RadioButton {
				id: scoHeadsetButton
				enabled: MediatekRadio.scoHeadsetAvailable
				checked: MediatekRadio.outputDevice == 6
				text: qsTr("Sco Headset")
				onClicked: MediatekRadio.outputDevice = 6
				Keys.onEnterPressed: MediatekRadio.outputDevice = 6
				Keys.onReturnPressed: MediatekRadio.outputDevice = 6
				KeyNavigation.up: speakerButton
				KeyNavigation.left: bluetoothScoButton
				KeyNavigation.right: scoCarKitButton
				KeyNavigation.down: seekDownButton
			}
			RadioButton {
				id: scoCarKitButton
				enabled: MediatekRadio.scoCarKitAvailable
				checked: MediatekRadio.outputDevice == 7
				text: qsTr("Sco CarKit")
				onClicked: MediatekRadio.outputDevice = 7
				Keys.onEnterPressed: MediatekRadio.outputDevice = 7
				Keys.onReturnPressed: MediatekRadio.outputDevice = 7
				KeyNavigation.up: wiredHeadsetButton
				KeyNavigation.left: scoHeadsetButton
				KeyNavigation.right: speakerAndHeadphoneButton
				KeyNavigation.down: seekUpButton
			}
			RadioButton {
				id: speakerAndHeadphoneButton
				enabled: MediatekRadio.speakerAndHeadphoneAvailable
				checked: MediatekRadio.outputDevice == 8
				text: qsTr("Headphone and Speaker")
				onClicked: MediatekRadio.outputDevice = 8
				Keys.onEnterPressed: MediatekRadio.outputDevice = 8
				Keys.onReturnPressed: MediatekRadio.outputDevice = 8
				KeyNavigation.up: wiredHeadphoneButton
				KeyNavigation.left: scoCarKitButton
				KeyNavigation.right: seekUpButton
				KeyNavigation.down: seekUpButton
			}
		}

		GridLayout {
			id: frequencyGrid
			columns: 3

			anchors {
				top: outputSelect.bottom
				margins: units.gu(2)
				left: parent.left
				right: parent.right
			}

			Button {
				id: seekDownButton
				height: units.gu(20)
				text: i18n.tr('\<')
				font.pixelSize: units.gu(10)
				activeFocusOnTab: true
				enabled: MediatekRadio.radioRunning
				KeyNavigation.up: bluetoothScoButton
				KeyNavigation.right: seekUpButton
				KeyNavigation.down: startStopButton
				onClicked: {
					MediatekRadio.seekDown()
					frequency.text = MediatekRadio.getFrequency() / 100
				}
				Keys.onEnterPressed: {
					MediatekRadio.seekDown()
					frequency.text = MediatekRadio.getFrequency() / 100
				}
				Keys.onReturnPressed: {
					MediatekRadio.seekDown()
					frequency.text = MediatekRadio.getFrequency() / 100
				}
			}

			Label {
				id: frequency
				Layout.alignment: Qt.AlignHCenter
				font.pixelSize: units.gu(10)
				text: MediatekRadio.getFrequency() / 100
			}

			Button {
				id: seekUpButton
				Layout.alignment: Qt.AlignRight
				height: units.gu(20)
				text: i18n.tr('\>')
				font.pixelSize: units.gu(10)
				enabled: MediatekRadio.radioRunning
				activeFocusOnTab: true
				KeyNavigation.up: speakerAndHeadphoneButton
				KeyNavigation.left: seekDownButton
				KeyNavigation.down: startStopButton
				onClicked: {
					MediatekRadio.seekUp()
					frequency.text = MediatekRadio.getFrequency() / 100
				}
				Keys.onEnterPressed: {
					MediatekRadio.seekUp()
					frequency.text = MediatekRadio.getFrequency() / 100
				}
				Keys.onReturnPressed: {
					MediatekRadio.seekUp()
					frequency.text = MediatekRadio.getFrequency() / 100
				}
			}
		}

		Button {
			id: startStopButton
			Layout.alignment: Qt.AlignHCenter
			anchors {
				top: frequencyGrid.bottom
				margins: units.gu(2)
				left: parent.left
				right: parent.right
				bottom: parent.bottom
			}

			font.pixelSize: units.gu(6)
			text: i18n.tr('Start radio')
			activeFocusOnTab: true
			KeyNavigation.up: seekDownButton
			KeyNavigation.left: seekDownButton
			KeyNavigation.right: seekUpButton
			onClicked: {
				if(!MediatekRadio.radioRunning) {
					text = MediatekRadio.startRadio(MediatekRadio.getFrequency())
				} else {
					text = MediatekRadio.stopRadio()
				}
			}
			Keys.onEnterPressed: {
				if(!MediatekRadio.radioRunning) {
					text = MediatekRadio.startRadio(MediatekRadio.getFrequency())
				} else {
					text = MediatekRadio.stopRadio()
				}
			}
			Keys.onReturnPressed: {
				if(!MediatekRadio.radioRunning) {
					text = MediatekRadio.startRadio(MediatekRadio.getFrequency())
				} else {
					text = MediatekRadio.stopRadio()
				}
			}
		}

		Component.onCompleted: {
			startStopButton.forceActiveFocus();
		}
	}
}
