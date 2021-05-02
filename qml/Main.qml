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

	width: units.gu(90)
	height: units.gu(90)

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
			columns: 3

			anchors {
				top: parent.top
				margins: units.gu(2)
				left: parent.left
				right: parent.right
				bottom: parent.bottom
			}

			Item {
				height: units.gu(20)
			}

			ColumnLayout {
				id: outputSelect
				RadioButton {
					id: earpieceButton
					enabled: MediatekRadio.earpieceAvailable
					checked: MediatekRadio.outputDevice == 1
					text: qsTr("Earpiece")
					onClicked: MediatekRadio.outputDevice = 1
					Keys.onEnterPressed: MediatekRadio.outputDevice = 1
					Keys.onReturnPressed: MediatekRadio.outputDevice = 1
					KeyNavigation.left: seekDownButton
					KeyNavigation.right: seekUpButton
					KeyNavigation.down: speakerButton
				}
				RadioButton {
					id: speakerButton
					enabled: MediatekRadio.speakerAvailable
					checked: MediatekRadio.outputDevice == 2
					text: qsTr("Speaker")
					onClicked: MediatekRadio.outputDevice = 2
					Keys.onEnterPressed: MediatekRadio.outputDevice = 2
					Keys.onReturnPressed: MediatekRadio.outputDevice = 2
					KeyNavigation.up: earpieceButton
					KeyNavigation.left: seekDownButton
					KeyNavigation.right: seekUpButton
					KeyNavigation.down: wiredHeadsetButton
				}
				RadioButton {
					id: wiredHeadsetButton
					enabled: MediatekRadio.wiredHeadsetAvailable
					checked: MediatekRadio.outputDevice == 3
					text: qsTr("Headset")
					onClicked: MediatekRadio.outputDevice = 3
					Keys.onEnterPressed: MediatekRadio.outputDevice = 3
					Keys.onReturnPressed: MediatekRadio.outputDevice = 3
					KeyNavigation.up: speakerButton
					KeyNavigation.left: seekDownButton
					KeyNavigation.right: seekUpButton
					KeyNavigation.down: wiredHeadphoneButton
				}
				RadioButton {
					id: wiredHeadphoneButton
					enabled: MediatekRadio.wiredHeadphoneAvailable
					checked: MediatekRadio.outputDevice == 4
					text: qsTr("Headphone")
					onClicked: MediatekRadio.outputDevice = 4
					Keys.onEnterPressed: MediatekRadio.outputDevice = 4
					Keys.onReturnPressed: MediatekRadio.outputDevice = 4
					KeyNavigation.up: wiredHeadsetButton
					KeyNavigation.left: seekDownButton
					KeyNavigation.right: seekUpButton
					KeyNavigation.down: bluetoothScoButton
				}
				RadioButton {
					id: bluetoothScoButton
					enabled: MediatekRadio.bluetoothScoAvailable
					checked: MediatekRadio.outputDevice == 5
					text: qsTr("Bluetooth Sco")
					onClicked: MediatekRadio.outputDevice = 5
					Keys.onEnterPressed: MediatekRadio.outputDevice = 5
					Keys.onReturnPressed: MediatekRadio.outputDevice = 5
					KeyNavigation.up: wiredHeadphoneButton
					KeyNavigation.left: seekDownButton
					KeyNavigation.right: seekUpButton
					KeyNavigation.down: scoHeadsetButton
				}
				RadioButton {
					id: scoHeadsetButton
					enabled: MediatekRadio.scoHeadsetAvailable
					checked: MediatekRadio.outputDevice == 6
					text: qsTr("Sco Headset")
					onClicked: MediatekRadio.outputDevice = 6
					Keys.onEnterPressed: MediatekRadio.outputDevice = 6
					Keys.onReturnPressed: MediatekRadio.outputDevice = 6
					KeyNavigation.up: bluetoothScoButton
					KeyNavigation.left: seekDownButton
					KeyNavigation.right: seekUpButton
					KeyNavigation.down: scoCarKitButton
				}
				RadioButton {
					id: scoCarKitButton
					enabled: MediatekRadio.scoCarKitAvailable
					checked: MediatekRadio.outputDevice == 7
					text: qsTr("Sco CarKit")
					onClicked: MediatekRadio.outputDevice = 7
					Keys.onEnterPressed: MediatekRadio.outputDevice = 7
					Keys.onReturnPressed: MediatekRadio.outputDevice = 7
					KeyNavigation.up: scoHeadsetButton
					KeyNavigation.left: seekDownButton
					KeyNavigation.right: seekUpButton
					KeyNavigation.down: speakerAndHeadphoneButton
				}
				RadioButton {
					id: speakerAndHeadphoneButton
					enabled: MediatekRadio.speakerAndHeadphoneAvailable
					checked: MediatekRadio.outputDevice == 8
					text: qsTr("Headphone and Speaker")
					onClicked: MediatekRadio.outputDevice = 8
					Keys.onEnterPressed: MediatekRadio.outputDevice = 8
					Keys.onReturnPressed: MediatekRadio.outputDevice = 8
					KeyNavigation.up: scoCarKitButton
					KeyNavigation.left: seekDownButton
					KeyNavigation.right: seekUpButton
					KeyNavigation.down: seekDownButton
				}
			}

			Item {
				height: units.gu(20)
			}

			Button {
				id: seekDownButton
				height: units.gu(20)
				text: i18n.tr('\<')
				font.pixelSize: units.gu(10)
				//activeFocusOnPress: true
				activeFocusOnTab: true
				KeyNavigation.up: speakerAndHeadphoneButton
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
				font.pixelSize: units.gu(10)
				text: MediatekRadio.getFrequency() / 100
			}

			Button {
				id: seekUpButton
				height: units.gu(20)
				text: i18n.tr('\>')
				font.pixelSize: units.gu(10)
				//activeFocusOnPress: true
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

			Item {
				Layout.fillHeight: true
			}

			Button {
				id: startStopButton
				Layout.alignment: Qt.AlignHCenter
				font.pixelSize: units.gu(6)
				text: i18n.tr('Start radio')
				//activeFocusOnPress: true
				activeFocusOnTab: true
				KeyNavigation.up: seekDownButton
				KeyNavigation.left: seekDownButton
				KeyNavigation.right: seekUpButton

				onClicked: {
					if(!MediatekRadio.isRadioRunning()) {
						text = MediatekRadio.startRadio(MediatekRadio.getFrequency())
					} else {
						text = MediatekRadio.stopRadio()
					}
				}
				Keys.onEnterPressed: {
					if(!MediatekRadio.isRadioRunning()) {
						text = MediatekRadio.startRadio(MediatekRadio.getFrequency())
					} else {
						text = MediatekRadio.stopRadio()
					}
				}
				Keys.onReturnPressed: {
					if(!MediatekRadio.isRadioRunning()) {
						text = MediatekRadio.startRadio(MediatekRadio.getFrequency())
					} else {
						text = MediatekRadio.stopRadio()
					}
				}
			}

/*			Item {
				Layout.fillHeight: true
			}
*/

		}

		Component.onCompleted: {
			startStopButton.forceActiveFocus();
		}

	}
}
